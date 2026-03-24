import 'package:flutter/material.dart';
import '../../../../shared/theme.dart';

class AnalysisReportHeader extends StatelessWidget {
  final String stockName;
  final String date;

  const AnalysisReportHeader({
    super.key,
    required this.stockName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$stockName 분석 리포트',
              style: const TextStyle(
                color: AppTheme.textMain,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 6),
                Text(
                  '분석일자: $date',
                  style: const TextStyle(color: AppTheme.textSub, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.analytics_outlined,
            color: AppTheme.primaryBlue,
            size: 28,
          ),
        ),
      ],
    );
  }
}
