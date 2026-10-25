import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';

class TodayDrawer extends StatelessWidget {
  final VoidCallback onNewChat;
  final ValueChanged<String> onSelectHistory;
  final VoidCallback onProfileTap;

  const TodayDrawer({
    super.key,
    required this.onNewChat,
    required this.onSelectHistory,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: NETokens.background,
      elevation: 4,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header with Brand Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: NETokens.borderDefault),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.eco_rounded, size: 20, color: NETokens.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Nutrient Earth',
                          style: GoogleFonts.newsreader(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: NETokens.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'EVIDENCE COMPANION',
                          style: GoogleFonts.manrope(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: NETokens.textSecondary,
                            letterSpacing: 1.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: NETokens.borderSubtle, height: 1),

            // New Chat Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onNewChat();
                },
                borderRadius: BorderRadius.circular(NETokens.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: NETokens.surface,
                    borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    border: Border.all(color: NETokens.borderDefault),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_comment_outlined, size: 18, color: NETokens.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'New Research Inquiry',
                          style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: NETokens.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Conversation History List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Text(
                'RECENT INQUIRIES',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: NETokens.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                children: [
                  _buildHistoryItem(
                    context,
                    title: 'Magnesium glycinate vs oxide bioavailability',
                    dateTag: 'Today',
                    query: 'How does magnesium glycinate compare to oxide for sleep quality?',
                  ),
                  _buildHistoryItem(
                    context,
                    title: 'Post-workout protein timing and MPS window',
                    dateTag: 'Yesterday',
                    query: 'What is the optimal protein threshold for muscle recovery?',
                  ),
                  _buildHistoryItem(
                    context,
                    title: 'Dietary nitrate efficacy in aerobic running',
                    dateTag: '3 days ago',
                    query: 'Does beetroot juice increase running efficiency?',
                  ),
                  _buildHistoryItem(
                    context,
                    title: 'Circadian blue light attenuation protocol',
                    dateTag: 'Last week',
                    query: 'How does screen light affect sleep quality?',
                  ),
                ],
              ),
            ),

            const Divider(color: NETokens.borderSubtle, height: 1),

            // Profile Link Footer
            ListTile(
              onTap: () {
                Navigator.pop(context);
                onProfileTap();
              },
              leading: const CircleAvatar(
                radius: 16,
                backgroundColor: NETokens.surfaceContainer,
                child: Icon(Icons.person_rounded, size: 18, color: NETokens.primary),
              ),
              title: Text(
                'Sarah Jenkins',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NETokens.primary,
                ),
              ),
              subtitle: Text(
                'Active Goal: Endurance Recovery',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: NETokens.textSecondary,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: NETokens.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context, {
    required String title,
    required String dateTag,
    required String query,
  }) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      leading: const Icon(Icons.history_rounded, size: 16, color: NETokens.textMuted),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: NETokens.primary,
        ),
      ),
      subtitle: Text(
        dateTag,
        style: GoogleFonts.manrope(
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
          color: NETokens.textMuted,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onSelectHistory(query);
      },
    );
  }
}
