import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/today_state.dart';

class DailyPlanSection extends StatelessWidget {
  final List<DailyPlanTask> tasks;
  final String counterLabel;
  final ValueChanged<int> onToggleTask;
  final VoidCallback? onWhyRoutineTap;
  final ValueChanged<DailyPlanTask>? onViewEvidenceTap;

  const DailyPlanSection({
    super.key,
    required this.tasks,
    required this.counterLabel,
    required this.onToggleTask,
    this.onWhyRoutineTap,
    this.onViewEvidenceTap,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF5F0),
                  borderRadius: BorderRadius.circular(NETokens.radiusFull),
                  border: Border.all(color: const Color(0xFFD5E2D8)),
                ),
                child: Text(
                  counterLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: NETokens.emerald,
                  ),
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
    final isNow = task.isUpNext && !task.isCompleted;

    if (isNow) {
      // Highlighted Active NOW Card Container
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD5E2D8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => onToggleTask(index),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF7D8F85), width: 2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.title,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NETokens.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(NETokens.radiusFull),
                      border: Border.all(color: const Color(0xFFCEEAD6)),
                    ),
                    child: Text(
                      '${task.timeString} · NOW',
                      style: GoogleFonts.manrope(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF137333),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (task.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Text(
                  task.note,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: NETokens.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: InkWell(
                onTap: () => onViewEvidenceTap?.call(task),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View evidence',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: NETokens.emerald,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 13, color: NETokens.emerald),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Standard task row
    return InkWell(
      onTap: () => onToggleTask(index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Checkbox Box
            Container(
              margin: const EdgeInsets.only(top: 2.0),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: task.isCompleted ? NETokens.deepGreen : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? NETokens.deepGreen : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
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
                            fontWeight: task.isCompleted ? FontWeight.w500 : FontWeight.w600,
                            color: task.isCompleted ? NETokens.textMuted : NETokens.primary,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: NETokens.textMuted,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                  if (task.note.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      task.note,
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: task.isCompleted ? NETokens.textMuted : NETokens.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
