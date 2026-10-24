import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 30: Research History (Secondary Destination)
/// Route: /history
/// Authoritative Stitch Reference: research_history
class ResearchHistoryScreen extends StatefulWidget {
  const ResearchHistoryScreen({super.key});

  @override
  State<ResearchHistoryScreen> createState() => _ResearchHistoryScreenState();
}

class _ResearchHistoryScreenState extends State<ResearchHistoryScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _historyItems = [
    {
      'id': 'REF-2024-884C',
      'title':
          'How does dietary magnesium glycinate bioavailability compare to magnesium oxide for sleep quality?',
      'category': 'Biochemistry',
      'time': '2m ago',
      'sourcesCount': 3,
      'consensus': 'High Consensus • 3 Trials',
    },
    {
      'id': 'REF-2024-882A',
      'title':
          'Pacific Wild Salmon with Quinoa & Broccoli macronutrient matrix',
      'category': 'Meal Studies',
      'time': '1d ago',
      'sourcesCount': 2,
      'consensus': 'Verified USDA Dataset',
    },
    {
      'id': 'REF-2024-879F',
      'title':
          'Bioavailability of Curcumin with Piperine co-administration',
      'category': 'Supplements',
      'time': '3d ago',
      'sourcesCount': 4,
      'consensus': 'Moderate Consensus • 4 Trials',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = _historyItems.where((item) {
      final matchesFilter = _selectedFilter == 'all' ||
          item['category'] == _selectedFilter;
      final matchesQuery = query.isEmpty ||
          (item['title'] as String).toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        backgroundColor: NETokens.surface.withValues(alpha: 0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NETokens.onSurface),
          onPressed: () => context.pop(),
          tooltip: 'Navigate back',
        ),
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.eco, size: 20, color: NETokens.secondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Research History',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NETokens.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: NETokens.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: NETokens.onPrimary, size: 18),
            ),
            onPressed: () => context.push('/profile/context'),
            tooltip: 'Account profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pipeline Subtitle & Header Block
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: NETokens.secondaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: NETokens.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ARCHIVAL DOSSIER • VERIFIED INQUIRIES',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: NETokens.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Research history',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Return to questions you've explored across clinical & biochemical telemetry.",
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: NETokens.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search your research...',
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 13,
                      color: NETokens.outlineVariant,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: NETokens.onSurfaceVariant,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () =>
                                setState(() => _searchController.clear()),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'All inquiries'),
                    _buildFilterChip('Biochemistry', 'Biochemistry'),
                    _buildFilterChip('Supplements', 'Supplements'),
                    _buildFilterChip('Meal Studies', 'Meal Studies'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // History Stream / Empty State
              if (filtered.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: NETokens.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.manage_search,
                          size: 24,
                          color: NETokens.secondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your research starts here',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: NETokens.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No matching inquiries found in this view.',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: NETokens.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...filtered.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: NETokens.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: InkWell(
                      onTap: () {
                        context.push(
                          '/history/detail',
                          extra: {
                            'id': item['id'],
                            'title': item['title'],
                            'category': item['category'],
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: NETokens.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item['category'] as String,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: NETokens.secondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      item['id'] as String,
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        color: NETokens.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  item['time'] as String,
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    color: NETokens.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: NETokens.onSurface,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['consensus'] as String,
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: NETokens.secondary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${item['sourcesCount']} sources cited',
                                      style: GoogleFonts.manrope(
                                        fontSize: 11,
                                        color: NETokens.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 11,
                                      color: NETokens.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String id, String label) {
    final isSelected = _selectedFilter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? NETokens.primaryContainer
                : NETokens.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? NETokens.onPrimary : NETokens.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
