import 'package:flutter/material.dart';
import '../../../models/analysis_model.dart';
import '../../../../../shared/theme.dart';

class GanttRow extends StatelessWidget {
  final InvestmentIssue issue;
  final DateTime startDate;
  final double dayWidth;
  final double rowHeight;
  final int totalDays;
  final bool isExpanded;
  final Function(InvestmentIssue)? onIssueTap;
  final double Function(InvestmentIssue) getRowHeight;

  const GanttRow({
    super.key,
    required this.issue,
    required this.startDate,
    required this.dayWidth,
    required this.rowHeight,
    required this.totalDays,
    required this.isExpanded,
    required this.onIssueTap,
    required this.getRowHeight,
  });

  @override
  Widget build(BuildContext context) {
    final start = DateTime.parse(issue.startDate);
    final end = issue.endDate != null ? DateTime.parse(issue.endDate!) : DateTime.now();
    
    final startOffset = start.difference(startDate).inDays * dayWidth;
    final durationWidth = (end.difference(start).inDays + 1) * dayWidth;
    
    Color color = issue.isPositive ? AppTheme.accentRed : AppTheme.primaryBlue;
    if (issue.isResolved) color = AppTheme.accentGreen;
    if (issue.status == 'evolving') color = Colors.orange;

    return GestureDetector(
      onTap: () => onIssueTap?.call(issue),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: getRowHeight(issue),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppTheme.textMain10.withValues(alpha: 0.3))),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ...List.generate(totalDays, (index) => Positioned(
              left: index * dayWidth,
              top: 0, bottom: 0, width: 0.5,
              child: Container(color: AppTheme.textMain10.withValues(alpha: 0.3)),
            )),
            
            Positioned(
              left: startOffset + 4,
              top: 25,
              width: durationWidth - 8,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color, width: 1.5),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    if (issue.isPositive) 
                      Icon(Icons.add_circle_outline, size: 10, color: color)
                    else 
                      Icon(Icons.remove_circle_outline, size: 10, color: color),
                    const SizedBox(width: 4),
                    if (issue.status == 'evolving') Icon(Icons.auto_fix_high, size: 10, color: color),
                  ],
                ),
              ),
            ),
          
            if (issue.history != null) 
              ...issue.history!.asMap().entries.map((entry) {
                final h = entry.value;
                final hDate = DateTime.parse(h.date);
                final hOffset = hDate.difference(startDate).inDays * dayWidth + (dayWidth / 2);
                
                final historyList = issue.history!.reversed.toList();
                final visibleIndex = historyList.indexOf(h);

                return Stack(
                  children: [
                    Positioned(
                      left: hOffset - 3,
                      top: 32,
                      child: Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 1.5),
                        ),
                      ),
                    ),
                    if (isExpanded && visibleIndex != -1) ...[
                      Positioned(
                        left: hOffset - 0.5,
                        top: 38,
                        height: rowHeight - 38 + (visibleIndex * 30.0) + 15.0,
                        width: 1,
                        child: Container(color: color.withValues(alpha: 0.2)),
                      ),
                      Positioned(
                        left: hOffset + 6,
                        top: rowHeight + (visibleIndex * 30.0) + 15.0,
                        width: 200,
                        child: Text(
                          h.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10, 
                            color: color.withValues(alpha: 0.8), 
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}
