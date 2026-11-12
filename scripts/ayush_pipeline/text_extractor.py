"""
Nutrient Earth — PDF Text Extraction Module
Extracts plain text from downloaded PDFs while retaining original PDF binary files unchanged.
"""

import os
import re
import zlib
from pathlib import Path
from typing import Optional, Tuple
from .models import AyushRecord
from .config import PDFS_RAW_DIR, EXTRACTED_TEXT_DIR

class PDFTextExtractor:
    def __init__(self):
        pass

    def extract_text_from_record(self, record: AyushRecord) -> AyushRecord:
        """Extracts text for record's downloaded PDF and saves to text file."""
        if record.pdf_status != "downloaded" or not record.pdf_filename:
            return record

        pdf_path = PDFS_RAW_DIR / record.pdf_filename
        if not pdf_path.exists() or pdf_path.stat().st_size == 0:
            return record

        text_filename = f"{pdf_path.stem}.txt"
        target_text_path = EXTRACTED_TEXT_DIR / text_filename

        # If already extracted, load cached count
        if target_text_path.exists() and target_text_path.stat().st_size > 0:
            record.extracted_text_path = str(target_text_path)
            with open(target_text_path, "r", encoding="utf-8", errors="ignore") as f:
                record.extracted_char_count = len(f.read())
            return record

        # Extract text from raw PDF bytes
        extracted_text = self._extract_text_from_pdf_file(pdf_path)
        
        # Save extracted text
        with open(target_text_path, "w", encoding="utf-8") as f:
            f.write(extracted_text)

        record.extracted_text_path = str(target_text_path)
        record.extracted_char_count = len(extracted_text)

        # Backfill abstract or authors from authentic PDF text if missing from landing page
        if not record.abstract and extracted_text:
            m_abs = re.search(r"Background\s*:\s*([^Keywords\n]+)", extracted_text, re.I)
            if m_abs:
                record.abstract = f"Background: {m_abs.group(1).strip()}"

        if not record.authors and extracted_text:
            m_auth = re.search(r"Author\s*:\s*([^\n]+)", extracted_text, re.I)
            if m_auth:
                record.authors = m_auth.group(1).strip()

        return record

    def _extract_text_from_pdf_file(self, pdf_path: Path) -> str:
        """Reads PDF binary without modification and decompresses content streams."""
        try:
            with open(pdf_path, "rb") as f:
                pdf_bytes = f.read()

            extracted_fragments = []

            # 1. Search for FlateDecode compressed streams
            stream_matches = re.findall(b"stream[\r\n]+([\\s\\S]*?)[\r\n]+endstream", pdf_bytes)
            for raw_stream in stream_matches:
                try:
                    decomp = zlib.decompress(raw_stream)
                    # Extract text tokens inside parentheses: (text) Tj or [(part1)(part2)] TJ
                    tokens = re.findall(rb"\((.*?)\)", decomp)
                    for t in tokens:
                        decoded = self._decode_pdf_string(t)
                        if decoded.strip():
                            extracted_fragments.append(decoded.strip())
                except Exception:
                    # Not compressed with standard zlib or raw image stream
                    pass

            # 2. If stream extraction yielded fragments, join them cleanly
            if extracted_fragments:
                # Group fragments into logical lines / sentences
                full_text = " ".join(extracted_fragments)
                # Normalize spaces and standard punctuation
                full_text = re.sub(r"\s+", " ", full_text)
                # Restore structured field breaks if present
                for marker in ["Legacy ID :", "Journal :", "Year :", "Volume :", "Issue :", "Page :", 
                               "Author :", "ARP ID :", "Author's Affiliation :", "Type :", 
                               "Corresponding Author Details :", "Category :", "Sub-Category :", 
                               "Body System :", "Disease :", "Abstract/ Summary/ Synopsis/ Outline:", 
                               "Background :", "Keywords :", "URL :", "DOI :", "PMID :"]:
                    full_text = full_text.replace(marker, f"\n{marker} ")
                return full_text.strip()

            # 3. Fallback: Extract ASCII strings >= 4 chars
            raw_strings = re.findall(b"[a-zA-Z0-9 ,.:;()/-]{4,}", pdf_bytes)
            ascii_lines = [s.decode('latin1', errors='ignore') for s in raw_strings if not s.startswith(b"/")]
            return "\n".join(ascii_lines).strip()

        except Exception as e:
            return f"[Extraction Error: {e}]"

    def _decode_pdf_string(self, raw_bytes: bytes) -> str:
        """Decodes PDF string literal handling escape sequences."""
        s = raw_bytes.decode('latin1', errors='ignore')
        s = s.replace(r"\(", "(").replace(r"\)", ")").replace(r"\\", "\\")
        s = s.replace(r"\n", "\n").replace(r"\r", "\r").replace(r"\t", "\t")
        return s
