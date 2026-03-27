import 'package:flutter/material.dart';
import '../../../shared/theme.dart';

class TrendSummaryCard extends StatelessWidget {
  final double? shortTerm;
  final double? mediumTerm;
  final double? longTerm;
  final String? summary;

  const TrendSummaryCard({
    super.key,
    this.shortTerm,
    this.mediumTerm,
    this.longTerm,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textMain10, width: 1.5), // 노트 스타일의 실선 테두리
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_mosaic_rounded, color: AppTheme.primaryBlue, size: 16),
              SizedBox(width: 8),
              Text(
                'AI TREND ANALYSIS',
                style: TextStyle(
                  color: AppTheme.textSub,
                  fontSize: 11,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTrendItem('단기', shortTerm ?? 0.78)),
              _buildVerticalDivider(),
              Expanded(child: _buildTrendItem('중기', mediumTerm ?? 0.50)),
              _buildVerticalDivider(),
              Expanded(child: _buildTrendItem('장기', longTerm ?? 0.35)),
            ],
          ),
          if (summary != null && summary!.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryBlue, size: 16),
                SizedBox(width: 8),
                Text(
                  '종합 전망 요약',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              summary!,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSub, height: 1.6),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendItem(String label, double score) {
    String sign;
    Color color;
    IconData icon;

    if (score > 0.6) {
      sign = '강세';
      color = AppTheme.accentRed;
      icon = Icons.north_east;
    } else if (score < 0.4) {
      sign = '약세';
      color = AppTheme.primaryBlue;
      icon = Icons.south_east;
    } else {
      sign = '중립';
      color = AppTheme.textMain54;
      icon = Icons.horizontal_rule;
    }

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSub, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          sign,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${(score * 100).toInt()}%',
          style: TextStyle(
            color: color.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1.5,
      color: AppTheme.textMain10.withValues(alpha: 0.5),
    );
  }
}
