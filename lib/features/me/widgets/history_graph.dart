import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HistoryGraph extends StatelessWidget {
  final String title;
  final List<double> dataPoints;
  final String unit;

  const HistoryGraph({
    super.key,
    required this.title,
    required this.dataPoints,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.moss.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              Text('Past 7 Days', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10, color: AppTheme.cloud.withValues(alpha: 0.5))),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: dataPoints.map((point) {
                // Normalize point for height display (mock logic)
                double maxVal = dataPoints.reduce((curr, next) => curr > next ? curr : next);
                double minVal = dataPoints.reduce((curr, next) => curr < next ? curr : next);
                double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;
                double normalizedHeight = ((point - minVal) / range) * 60 + 20;
 
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(point.toInt().toString(), style: const TextStyle(color: AppTheme.cloud, fontSize: 10)),
                      const SizedBox(height: 8),
                      Container(
                        width: 16,
                        height: normalizedHeight,
                        decoration: BoxDecoration(
                          color: AppTheme.earth,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Trend: Improving',
              style: TextStyle(color: AppTheme.moss, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
