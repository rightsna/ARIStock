import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/investment_issue_model.dart';
import '../../providers/analysis_provider.dart';
import '../../../../shared/theme.dart';
import 'widgets/issue_header.dart';
import 'widgets/issue_meta_info.dart';
import 'widgets/issue_trace.dart';
import 'widgets/issue_action_buttons.dart';

class IssueDetailSheet extends StatefulWidget {
  final String symbol;
  final InvestmentIssue issue;
  final AnalysisProvider provider;

  const IssueDetailSheet({
    super.key,
    required this.symbol,
    required this.issue,
    required this.provider,
  });

  @override
  State<IssueDetailSheet> createState() => _IssueDetailSheetState();
}

class _IssueDetailSheetState extends State<IssueDetailSheet> {
  InvestmentIssue get _currentIssue {
    final analysis = widget.provider.getAnalysisForSymbol(widget.symbol);
    if (analysis != null && analysis.issues != null) {
      try {
        return analysis.issues!.firstWhere((i) => i.id == widget.issue.id);
      } catch (_) {}
    }
    return widget.issue;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.provider,
      builder: (context, _) {
        final issue = _currentIssue;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IssueHeader(
                  issue: issue,
                  onDelete: () => _showDeleteConfirm(context, issue),
                  onClose: () => widget.provider.selectIssue(null),
                ),
                const Divider(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IssueMetaInfo(issue: issue),
                        const SizedBox(height: 24),
                        IssueTrace(
                          issue: issue,
                          onHistoryDelete: (h) =>
                              _showHistoryDeleteConfirm(context, issue, h),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          '최신 조사 결과',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        MarkdownBody(
                          data: issue.lastInvestigation ?? '상세 조사 내용이 아직 없습니다.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                IssueActionButtons(
                  issue: issue,
                  onToggleResolved: () {
                    widget.provider.toggleIssueResolved(issue);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, InvestmentIssue issue) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text(
          '이슈 삭제',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('이 이슈와 관련된 모든 히스토리 기록이 영구적으로 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: AppTheme.textSub)),
          ),
          TextButton(
            onPressed: () {
              widget.provider.deleteIssue(issue);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showHistoryDeleteConfirm(
    BuildContext context,
    InvestmentIssue issue,
    IssueHistory history,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text(
          '기록 삭제',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('선택한 이슈 트레이스 기록을 영구적으로 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: AppTheme.textSub)),
          ),
          TextButton(
            onPressed: () async {
              await widget.provider.deleteHistoryItem(issue, history);
              Navigator.pop(ctx);
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }
}
