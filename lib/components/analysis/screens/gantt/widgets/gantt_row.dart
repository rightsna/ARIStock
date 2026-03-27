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
  final Function(InvestmentIssue)? onApprove;
  final Function(InvestmentIssue)? onReject;
  final Function(InvestmentIssue, IssueHistory)? onApproveHistory;
  final Function(InvestmentIssue, IssueHistory)? onRejectHistory;

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
    this.onApprove,
    this.onReject,
    this.onApproveHistory,
    this.onRejectHistory,
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

    final isModified = issue.isAiModified || issue.isAiAdded;

    return Container(
      height: getRowHeight(issue),
      decoration: BoxDecoration(
        color: isModified 
          ? Colors.deepPurple.withValues(alpha: 0.05)
          : Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.textMain10.withValues(alpha: 0.3)),
          left: isModified ? const BorderSide(color: Colors.deepPurple, width: 3) : BorderSide.none,
        ),
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
            child: GestureDetector(
              onTap: () => onIssueTap?.call(issue),
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
          ),
        
          if (issue.history != null) 
            ...issue.history!.asMap().entries.map((entry) {
              final h = entry.value;
              final hDate = DateTime.parse(h.date);
              final hOffset = hDate.difference(startDate).inDays * dayWidth + (dayWidth / 2);
              
              final historyList = issue.history!.reversed.toList();
              final visibleIndex = historyList.indexOf(h);
              final isNewHistory = h.isAiAdded;

              return Stack(
                children: [
                  Positioned(
                    left: hOffset - (isNewHistory ? 4 : 3),
                    top: isNewHistory ? 31 : 32,
                    child: Container(
                      width: isNewHistory ? 8 : 6, 
                      height: isNewHistory ? 8 : 6,
                      decoration: BoxDecoration(
                        color: isNewHistory ? Colors.deepPurple : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: isNewHistory ? Colors.white : color, width: 1.5),
                      ),
                    ),
                  ),
                  if (isExpanded && visibleIndex != -1) ...[
                    Positioned(
                      left: hOffset - 0.75,
                      top: 38,
                      height: rowHeight + (visibleIndex * 30.0) + 15.0 - 38.0,
                      width: 1.5,
                      child: Container(color: isNewHistory ? Colors.deepPurple.withValues(alpha: 0.8) : color.withValues(alpha: 0.6)),
                    ),
                    Positioned(
                      left: hOffset + 6,
                      top: rowHeight + (visibleIndex * 30.0) + 15.0,
                      width: 200,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isNewHistory) 
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => onApproveHistory?.call(issue, h),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, size: 10, color: Colors.green),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => onRejectHistory?.call(issue, h),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 10, color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Flexible(
                            child: GestureDetector(
                              onTap: () => onIssueTap?.call(issue),
                              child: Container(
                                padding: isNewHistory ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1) : EdgeInsets.zero,
                                decoration: isNewHistory ? BoxDecoration(
                                  color: Colors.deepPurple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ) : null,
                                child: Text(
                                  h.content,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10, 
                                    color: isNewHistory ? Colors.deepPurple : color.withValues(alpha: 0.8), 
                                    fontWeight: isNewHistory ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }),
        ],
      ),
    );
  }
}
