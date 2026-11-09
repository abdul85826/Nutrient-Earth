-- ==============================================================================
-- Migration: 20261106000100_enable_pgvector_and_evidence_embeddings.sql
-- Description: Enables pgvector extension, provisions public.evidence_chunks
-- with HNSW cosine index, Full-Text GIN index, Reciprocal Rank Fusion (RRF),
-- Retraction tracking, and strict Row Level Security.
-- ==============================================================================

-- 1. Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA extensions;

-- 2. Evidence Chunks Table (System of Record for Scientific Research)
CREATE TABLE IF NOT EXISTS public.evidence_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pmid TEXT,
    doi TEXT,
    title TEXT NOT NULL,
    authors_or_journal TEXT NOT NULL,
    publication_year INT NOT NULL,
    study_design TEXT NOT NULL DEFAULT 'unspecified',
    evidence_grade TEXT NOT NULL DEFAULT 'Evidence Synthesis',
    chunk_index INT NOT NULL DEFAULT 0,
    chunk_content TEXT NOT NULL,
    embedding extensions.vector(1536),
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_retracted BOOLEAN NOT NULL DEFAULT false,
    retraction_date TIMESTAMPTZ,
    retraction_reason TEXT,
    retraction_notice_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3. Comments for documentation integrity
COMMENT ON TABLE public.evidence_chunks IS 'Scientific literature chunks with dense embeddings, FTS metadata, and retraction state.';
COMMENT ON COLUMN public.evidence_chunks.embedding IS '1536-dimensional semantic vector embedding (OpenAI/text-embedding-3 or Gemini compatible).';
COMMENT ON COLUMN public.evidence_chunks.is_retracted IS 'Flag indicating whether the paper has been formally retracted by the issuing journal.';

-- 4. Fast Lookups & Unique Identifiers
CREATE INDEX IF NOT EXISTS idx_evidence_chunks_pmid ON public.evidence_chunks (pmid) WHERE pmid IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_evidence_chunks_doi ON public.evidence_chunks (doi) WHERE doi IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_evidence_chunks_retracted ON public.evidence_chunks (is_retracted);

-- 5. HNSW Cosine Index for Sub-10ms Approximate Nearest Neighbor Retrieval
CREATE INDEX IF NOT EXISTS idx_evidence_chunks_hnsw 
ON public.evidence_chunks 
USING hnsw (embedding extensions.vector_cosine_ops) 
WITH (m = 16, ef_construction = 64);

-- 6. Full-Text Search GIN Index for Hybrid RRF Retrival
CREATE INDEX IF NOT EXISTS idx_evidence_chunks_fts 
ON public.evidence_chunks 
USING gin (to_tsvector('english', chunk_content));

-- 7. Reciprocal Rank Fusion (RRF) Hybrid Search Function
-- Combines Dense Vector Similarity (HNSW) and Sparse Keyword Relevance (FTS)
-- k = 60 is standard RRF constant per Cormack et al.
CREATE OR REPLACE FUNCTION public.match_evidence_rrf(
    query_text TEXT,
    query_embedding extensions.vector(1536),
    match_count INT DEFAULT 5,
    rrf_k INT DEFAULT 60
)
RETURNS TABLE (
    id UUID,
    pmid TEXT,
    doi TEXT,
    title TEXT,
    authors_or_journal TEXT,
    publication_year INT,
    study_design TEXT,
    evidence_grade TEXT,
    chunk_content TEXT,
    is_retracted BOOLEAN,
    combined_score FLOAT8
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
    RETURN QUERY
    WITH vector_matches AS (
        SELECT 
            ec.id,
            ROW_NUMBER() OVER (ORDER BY ec.embedding <=> query_embedding) as rank_vec
        FROM public.evidence_chunks ec
        WHERE ec.is_retracted = false 
          AND ec.embedding IS NOT NULL
        LIMIT (match_count * 3)
    ),
    fts_matches AS (
        SELECT 
            ec.id,
            ROW_NUMBER() OVER (
                ORDER BY ts_rank_cd(to_tsvector('english', ec.chunk_content), plainto_tsquery('english', query_text)) DESC
            ) as rank_fts
        FROM public.evidence_chunks ec
        WHERE ec.is_retracted = false
          AND to_tsvector('english', ec.chunk_content) @@ plainto_tsquery('english', query_text)
        LIMIT (match_count * 3)
    ),
    fused_scores AS (
        SELECT 
            COALESCE(v.id, f.id) as chunk_id,
            (COALESCE(1.0 / (rrf_k + v.rank_vec), 0.0) + COALESCE(1.0 / (rrf_k + f.rank_fts), 0.0)) as rrf_score
        FROM vector_matches v
        FULL OUTER JOIN fts_matches f ON v.id = f.id
    )
    SELECT 
        ec.id,
        ec.pmid,
        ec.doi,
        ec.title,
        ec.authors_or_journal,
        ec.publication_year,
        ec.study_design,
        ec.evidence_grade,
        ec.chunk_content,
        ec.is_retracted,
        fs.rrf_score as combined_score
    FROM fused_scores fs
    JOIN public.evidence_chunks ec ON ec.id = fs.chunk_id
    ORDER BY fs.rrf_score DESC
    LIMIT match_count;
END;
$$;

-- 8. Row Level Security Enforcement
ALTER TABLE public.evidence_chunks ENABLE ROW LEVEL SECURITY;

-- Anonymous and authenticated app clients have read-only access to unretracted evidence
CREATE POLICY "Allow public read access to unretracted scientific evidence"
    ON public.evidence_chunks
    FOR SELECT
    TO anon, authenticated
    USING (is_retracted = false);

-- Service role has full administrative access (ingestion, retraction updates)
CREATE POLICY "Allow service_role full administrative access"
    ON public.evidence_chunks
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

