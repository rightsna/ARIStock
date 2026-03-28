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
  final Function(InvestmentIssue)? onApprove;
  final Function(InvestmentIssue)? onReject;
  final Function(InvestmentIssue, IssueHistory)? onApproveHistory;
  final Function(InvestmentIssue, IssueHistory)? onRejectHistory;

  const GanttStickyTitles({
    super.key,
    required this.issues,
    required this.titleWidth,
    required this.rowHeight,
    required this.expandedTitles,
    required this.onIssueTap,
    required this.onToggleExpand,
    required this.getRowHeight,
    this.onApprove,
    this.onReject,
    this.onApproveHistory,
    this.onRejectHistory,
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
            final isAiUpdated = issue.isAiModified || issue.isAiAdded;
            final isExpanded = expandedTitles.contains(issue.id) || isAiUpdated;
            final isModified = issue.isAiModified || issue.isAiAdded;
            
            return Container(
              width: titleWidth,
              height: getRowHeight(issue),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.textMain10.withValues(alpha: 0.5)),
                  left: isModified ? const BorderSide(color: Colors.deepPurple, width: 3) : BorderSide.none,
                ),
                color: isModified 
                  ? Colors.deepPurple.withValues(alpha: 0.05)
                  : (issue.isResolved ? Colors.grey.withValues(alpha: 0.03) : Colors.white),
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
                            if (isModified)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(4)),
                                      child: const Text('AI 수정', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => onApprove?.call(issue),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.green, width: 0.5)),
                                        child: const Text('승인', style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => onReject?.call(issue),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.red, width: 0.5)),
                                        child: const Text('거절', style: TextStyle(fontSize: 8, color: Colors.red, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            GestureDetector(
                              onTap: () => onIssueTap(issue),
                              behavior: HitTestBehavior.opaque,
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
                        child: h.isAiAdded 
                          ? Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 21),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('NEW', style: TextStyle(fontSize: 7, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('AI 추가 히스토리를 삭제합니다. (기능 준비 중)')),
                                    );
                                  },
                                  child: const Icon(Icons.history_rounded, size: 10, color: Colors.deepPurple),
                                ),
                              ],
                            )
                          : const SizedBox(height: 22),
                      )),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }
}
