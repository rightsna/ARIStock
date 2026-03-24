import 'package:flutter/material.dart';
import '../../../shared/theme.dart';

class TrendSummaryCard extends StatelessWidget {
  final double? shortTerm; // 0.0 to 1.0
  final double? mediumTerm;
  final double? longTerm;

  const TrendSummaryCard({
    super.key,
    this.shortTerm,
    this.mediumTerm,
    this.longTerm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.textMain.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.batch_prediction, color: AppTheme.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'AI 트렌드 예측 요약',
                style: TextStyle(
                  color: AppTheme.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTrendItem('단기', shortTerm ?? 0.78)),
              _buildDivider(),
              Expanded(child: _buildTrendItem('중기', mediumTerm ?? 0.50)),
              _buildDivider(),
              Expanded(child: _buildTrendItem('장기', longTerm ?? 0.35)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String label, double score) {
    String sign;
    Color color;
    IconData icon;

    if (score > 0.6) {
      sign = '오른다';
      color = AppTheme.accentRed;
      icon = Icons.trending_up;
    } else if (score < 0.4) {
      sign = '내린다';
      color = AppTheme.primaryBlue;
      icon = Icons.trending_down;
    } else {
      sign = '보합';
      color = AppTheme.textMain54;
      icon = Icons.trending_flat;
    }

    final percentage = (score * 100).toInt();

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textMain54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          sign,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$percentage%',
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppTheme.textMain.withValues(alpha: 0.05),
    );
  }
}
