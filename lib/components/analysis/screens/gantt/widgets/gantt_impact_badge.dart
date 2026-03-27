import 'package:flutter/material.dart';
import '../../../../../shared/theme.dart';

class GanttImpactBadge extends StatelessWidget {
  final int impact;

  const GanttImpactBadge({super.key, required this.impact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppTheme.textMain10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate( impact, (index) => const Icon(
          Icons.star,
          size: 8,
          color: Colors.orange,
        )),
      ),
    );
  }
}
