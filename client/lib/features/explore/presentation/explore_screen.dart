import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/intelligence/intelligence_contracts.dart';
import '../../../core/intelligence/product_intelligence_catalog.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchFilter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EvidenceItem> _getFilteredEvidence() {
    const all = ProductIntelligenceCatalog.scientificEvidence;
    return all.where((ev) {
      final matchesSearch =
          _searchFilter.isEmpty ||
          ev.title.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          ev.authors.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          ev.keyFinding.toLowerCase().contains(_searchFilter.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Proteins') {
        return ev.id.contains('BABAULT') ||
            ev.title.toLowerCase().contains('protein');
      }
      if (_selectedCategory == 'Minerals') {
        return ev.id.contains('WEAVER') || ev.id.contains('MAGNESIUM');
      }
      if (_selectedCategory == 'Vitamins') {
        return ev.id.contains('HOLICK') ||
            ev.title.toLowerCase().contains('vitamin');
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredEvidence();

    return Scaffold(
      backgroundColor: NeTokens.warmIvory,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(NeTokens.spacing20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Evidence Explorer',
                  style: TextStyle(
                    fontFamily: NeTokens.fontFamilySerif,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: NeTokens.deepForest,
                  ),
                ),
                IconButton(
                  tooltip: 'Privacy & Settings',
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: NeTokens.deepForest,
                  ),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            const SizedBox(height: NeTokens.spacing6),
            const Text(
              'Search peer-reviewed clinical literature, nutrition assays, and evidence-graded health observations.',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySans,
                fontSize: 13,
                color: NeTokens.slateMuted,
              ),
            ),
            const SizedBox(height: NeTokens.spacing16),

            // Search Bar
            NeCard(
              padding: const EdgeInsets.symmetric(
                horizontal: NeTokens.spacing12,
                vertical: 2,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: NeTokens.mossGreen,
                    size: 20,
                  ),
                  const SizedBox(width: NeTokens.spacing8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontFamily: NeTokens.fontFamilySans,
                        fontSize: 14,
                        color: NeTokens.deepForest,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search studies, nutrients, or authors...',
                        hintStyle: TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 13,
                          color: NeTokens.slateMuted,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchFilter = val.trim();
                        });
                      },
                    ),
                  ),
                  if (_searchFilter.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: NeTokens.slateMuted,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchFilter = '';
                        });
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: NeTokens.spacing14),

            // Evidence Quality Hierarchy Card
            NeCard(
              color: NeTokens.sandDune.withValues(alpha: 0.25),
              padding: const EdgeInsets.all(NeTokens.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EVIDENCE CLASSIFICATION STANDARD',
                    style: TextStyle(
                      fontFamily: NeTokens.fontFamilySans,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: NeTokens.mossGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildGradeTag(
                        'Grade A',
                        'Clinical RCTs',
                        NeTokens.botanicalEvergreen,
                      ),
                      const SizedBox(width: 8),
                      _buildGradeTag(
                        'Grade B',
                        'Cohort Studies',
                        NeTokens.mossGreen,
                      ),
                      const SizedBox(width: 8),
                      _buildGradeTag(
                        'Grade C',
                        'Traditional Use',
                        NeTokens.slateMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Traditional practices reflect historical culture; they are never described as proven clinical cures without robust trials.',
                    style: TextStyle(
                      fontFamily: NeTokens.fontFamilySans,
                      fontSize: 10.5,
                      color: NeTokens.slateMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: NeTokens.spacing16),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  NeChip(
                    label: 'All Clinical Trials',
                    isSelected: _selectedCategory == 'All',
                    onTap: () => setState(() => _selectedCategory = 'All'),
                  ),
                  const SizedBox(width: NeTokens.spacing8),
                  NeChip(
                    label: 'Proteins & Amino Acids',
                    isSelected: _selectedCategory == 'Proteins',
                    onTap: () => setState(() => _selectedCategory = 'Proteins'),
                  ),
                  const SizedBox(width: NeTokens.spacing8),
                  NeChip(
                    label: 'Minerals & Electrolytes',
                    isSelected: _selectedCategory == 'Minerals',
                    onTap: () => setState(() => _selectedCategory = 'Minerals'),
                  ),
                  const SizedBox(width: NeTokens.spacing8),
                  NeChip(
                    label: 'Vitamins & Cofactors',
                    isSelected: _selectedCategory == 'Vitamins',
                    onTap: () => setState(() => _selectedCategory = 'Vitamins'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: NeTokens.spacing16),

            if (filteredList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(NeTokens.spacing32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 40,
                        color: NeTokens.slateMuted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No studies found matching "$_searchFilter"',
                        style: const TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 13,
                          color: NeTokens.slateMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filteredList.map(
                (ev) => Padding(
                  padding: const EdgeInsets.only(bottom: NeTokens.spacing12),
                  child: InkWell(
                    onTap: () =>
                        context.push('/ask?q=${Uri.encodeComponent(ev.title)}'),
                    borderRadius: BorderRadius.circular(NeTokens.radius16),
                    child: NeCard(
                      padding: const EdgeInsets.all(NeTokens.spacing14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: NeTokens.mossGreen.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    NeTokens.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  ev.studyType,
                                  style: const TextStyle(
                                    fontFamily: NeTokens.fontFamilySans,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: NeTokens.botanicalEvergreen,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Score: ${(ev.qualityScore * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontFamily: NeTokens.fontFamilySans,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: NeTokens.mossGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: NeTokens.spacing8),
                          Text(
                            ev.title,
                            style: const TextStyle(
                              fontFamily: NeTokens.fontFamilySans,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: NeTokens.deepForest,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ev.authors} (${ev.year}) — ${ev.source}',
                            style: const TextStyle(
                              fontFamily: NeTokens.fontFamilySans,
                              fontSize: 11,
                              color: NeTokens.slateMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ev.keyFinding,
                            style: const TextStyle(
                              fontFamily: NeTokens.fontFamilySans,
                              fontSize: 12,
                              color: NeTokens.deepForest,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(
                                Icons.biotech_rounded,
                                size: 13,
                                color: NeTokens.botanicalEvergreen,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Analyze Clinical Findings in Ask →',
                                style: TextStyle(
                                  fontFamily: NeTokens.fontFamilySans,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: NeTokens.botanicalEvergreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeTag(String grade, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(NeTokens.radius4),
      ),
      child: Text(
        '$grade: $label',
        style: TextStyle(
          fontFamily: NeTokens.fontFamilySans,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
