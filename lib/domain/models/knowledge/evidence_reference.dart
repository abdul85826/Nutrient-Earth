class EvidenceReference {
  final String citationId; // e.g. 'PMID:123456'
  final String title;
  final String source; // e.g. 'Journal of Clinical Sleep Medicine'
  final DateTime publicationDate;
  final List<String> authors;
  final double confidenceLevel; // 0.0 - 1.0 (How robust is the methodology?)
  final String evidenceGrade; // 'A' (RCTs), 'B' (Observational), 'C' (Mechanistic), 'D' (Expert Opinion)
  final String healthDomain; // 'sleep', 'recovery', 'nutrition'

  EvidenceReference({
    required this.citationId,
    required this.title,
    required this.source,
    required this.publicationDate,
    required this.authors,
    required this.confidenceLevel,
    required this.evidenceGrade,
    required this.healthDomain,
  });
}
