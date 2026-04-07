import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/theme.dart';

class GanttTimeAxis extends StatelessWidget {
  final DateTime startDate;
  final int totalDays;
  final double dayWidth;

  const GanttTimeAxis({
    super.key,
    required this.startDate,
    required this.totalDays,
    required this.dayWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(bottom: BorderSide(color: AppTheme.textMain10, width: 1.5)),
      ),
      child: Stack(
        children: List.generate(totalDays, (index) {
          final date = startDate.add(Duration(days: index));
          final isToday = DateFormat('yyyy-MM-dd').format(date) == 
              DateFormat('yyyy-MM-dd').format(DateTime.now());
          
          return Positioned(
            left: index * dayWidth,
            top: 0, bottom: 0, width: dayWidth,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: AppTheme.textMain10.withValues(alpha: 0.5))),
                color: isToday ? AppTheme.primaryBlue.withValues(alpha: 0.03) : null,
              ),
              child: Text(
                DateFormat('MM/dd').format(date),
                style: TextStyle(
                  fontSize: 10, 
                  color: isToday ? AppTheme.primaryBlue : AppTheme.textSub, 
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
