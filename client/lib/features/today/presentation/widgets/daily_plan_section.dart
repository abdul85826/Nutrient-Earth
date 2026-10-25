import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/today_state.dart';

class DailyPlanSection extends StatelessWidget {
  final List<DailyPlanTask> tasks;
  final String counterLabel;
  final ValueChanged<int> onToggleTask;
  final VoidCallback? onWhyRoutineTap;

  const DailyPlanSection({
    super.key,
    required this.tasks,
    required this.counterLabel,
    required this.onToggleTask,
    this.onWhyRoutineTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(NETokens.radiusXl),
        border: Border.all(color: const Color(0xFFD5E2D8)),
        boxShadow: NETokens.cardShadow,
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: NETokens.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Your daily plan',
                        style: GoogleFonts.newsreader(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: NETokens.primary,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                counterLabel,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: NETokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFECEFEA), height: 1),

          // Task List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const Divider(
              color: Color(0xFFF1EBE0),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskRow(task, index);
            },
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFF1EBE0), height: 1),
          const SizedBox(height: 10),

          // Footer
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 6,
            children: [
              InkWell(
                onTap: onWhyRoutineTap,
                child: Text.rich(
                  TextSpan(
                    text: 'Why this routine fits your goals ',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: NETokens.emerald,
                    ),
                    children: const [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(Icons.arrow_forward_rounded, size: 14, color: NETokens.emerald),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'Goal: Endurance Recovery',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: NETokens.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskRow(DailyPlanTask task, int index) {
    return InkWell(
      onTap: () => onToggleTask(index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        decoration: BoxDecoration(
          color: (task.isUpNext && !task.isCompleted)
              ? const Color(0xFFF7F5EE).withValues(alpha: 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Checkbox Box
            Container(
              margin: const EdgeInsets.only(top: 2.0),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? NETokens.deepGreen
                    : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.isCompleted
                      ? NETokens.deepGreen
                      : (task.isUpNext ? NETokens.emerald : const Color(0xFFD5E2D8)),
                  width: (task.isUpNext && !task.isCompleted) ? 2.0 : 1.2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            fontWeight: task.isCompleted
                                ? FontWeight.w500
                                : (task.isUpNext ? FontWeight.w700 : FontWeight.w600),
                            color: task.isCompleted
                                ? NETokens.textMuted
                                : NETokens.primary,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: NETokens.textMuted,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (task.isUpNext && !task.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF5F0),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFD8E6DB)),
                          ),
                          child: Text(
                            'UP NEXT',
                            style: GoogleFonts.manrope(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: NETokens.emerald,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      else
                        Text(
                          task.timeString,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: NETokens.textMuted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    task.note,
                    style: GoogleFonts.manrope(
                      fontSize: 11.5,
                      fontWeight: (task.isUpNext && !task.isCompleted) ? FontWeight.w600 : FontWeight.w500,
                      color: task.isCompleted
                          ? NETokens.textMuted
                          : ((task.isUpNext && !task.isCompleted) ? const Color(0xFF3D554B) : NETokens.textSecondary),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
