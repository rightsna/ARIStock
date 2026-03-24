import 'package:flutter/material.dart';
import '../models/analysis_model.dart';
import '../../../../shared/theme.dart';

class AnalysisCheckPointCard extends StatelessWidget {
  final List<AnalysisCheckPoint> checkPoints;
  final Function(AnalysisCheckPoint) onToggle;

  const AnalysisCheckPointCard({
    super.key,
    required this.checkPoints,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (checkPoints.isEmpty) return const SizedBox.shrink();

    final positives = checkPoints.where((p) => p.isPositive).toList();
    final negatives = checkPoints.where((p) => !p.isPositive).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (positives.isNotEmpty)
          Expanded(
            child: _buildCheckPointGroup(
              '상승 관점',
              positives,
              Icons.trending_up,
              AppTheme.accentGreen,
            ),
          ),
        if (positives.isNotEmpty && negatives.isNotEmpty)
          const SizedBox(width: 16),
        if (negatives.isNotEmpty)
          Expanded(
            child: _buildCheckPointGroup(
              '하락 관점',
              negatives,
              Icons.trending_down,
              AppTheme.accentRed,
            ),
          ),
      ],
    );
  }

  Widget _buildCheckPointGroup(
    String title,
    List<AnalysisCheckPoint> points,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: points
                .map(
                  (p) => CheckboxListTile(
                    value: p.isChecked,
                    onChanged: (_) => onToggle(p),
                    title: Text(
                      p.content,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMain,
                        decoration: p.isChecked
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppTheme.textMain38,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Text('중요도 ', style: TextStyle(fontSize: 10, color: AppTheme.textMain38)),
                          ...List.generate(5, (index) => Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              index < p.impactValue ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 12,
                              color: index < p.impactValue ? Colors.orange : AppTheme.textMain10,
                            ),
                          )),
                        ],
                      ),
                    ),
                    activeColor: color,
                    checkColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
