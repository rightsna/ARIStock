import 'package:flutter/material.dart';
import '../../../../../shared/theme.dart';

class AnalysisReportHeader extends StatelessWidget {
  final String stockName;
  final String date;
  final VoidCallback? onRequestUpdate;

  const AnalysisReportHeader({
    super.key,
    required this.stockName,
    required this.date,
    this.onRequestUpdate,
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
        ElevatedButton.icon(
          onPressed: onRequestUpdate,
          icon: const Icon(Icons.auto_awesome, size: 14),
          label: const Text('리서치 업데이트', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
