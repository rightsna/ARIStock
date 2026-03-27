import 'package:flutter/material.dart';
import '../../../models/analysis_model.dart';
import '../../../../../shared/theme.dart';
import 'gantt_impact_badge.dart';

class GanttStickyTitles extends StatelessWidget {
  final List<InvestmentIssue> issues;
  final double titleWidth;
  final double rowHeight;
  final Set<String> expandedTitles;
  final Function(InvestmentIssue) onIssueTap;
  final Function(InvestmentIssue) onToggleExpand;
  final double Function(InvestmentIssue) getRowHeight;

  const GanttStickyTitles({
    super.key,
    required this.issues,
    required this.titleWidth,
    required this.rowHeight,
    required this.expandedTitles,
    required this.onIssueTap,
    required this.onToggleExpand,
    required this.getRowHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: titleWidth,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(right: BorderSide(color: AppTheme.textMain10, width: 1.5)),
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.textMain10, width: 1.5)),
            ),
            child: const Text(
              'INVESTMENT ISSUE', 
              style: TextStyle(fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: AppTheme.textSub),
            ),
          ),
          ...issues.map((issue) {
            final isExpanded = expandedTitles.contains(issue.title);
            return GestureDetector(
              onTap: () => onIssueTap(issue),
              child: Container(
                width: titleWidth,
                height: getRowHeight(issue),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.textMain10.withValues(alpha: 0.5))),
                  color: issue.isResolved ? Colors.grey.withValues(alpha: 0.03) : Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            issue.isPositive ? Icons.trending_up : Icons.trending_down,
                            size: 14,
                            color: issue.isPositive ? AppTheme.accentRed : AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                issue.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: issue.isResolved ? AppTheme.textMain38 : AppTheme.textMain,
                                  decoration: issue.isResolved ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GanttImpactBadge(impact: issue.impact),
                            ],
                          ),
                        ),
                        // 토글 버튼
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => onToggleExpand(issue),
                          icon: Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppTheme.textSub,
                          ),
                        ),
                      ],
                    ),
                    if (isExpanded && issue.history != null) ...[
                      const SizedBox(height: 12),
                      ...issue.history!.reversed.map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: const SizedBox(height: 22),
                      )),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
