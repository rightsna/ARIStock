import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ari_plugin/ari_plugin.dart';
import '../../models/investment_issue_model.dart';
import '../../providers/analysis_provider.dart';
import '../../../../shared/theme.dart';
import 'widgets/issue_header.dart';
import 'widgets/issue_meta_info.dart';
import 'widgets/issue_trace.dart';
import 'widgets/issue_collaboration_input.dart';
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.82,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IssueHeader(
                  issue: issue,
                  onDelete: () => _showDeleteConfirm(context, issue),
                  onClose: () => Navigator.pop(context),
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
                          onHistoryDelete: (h) => _showHistoryDeleteConfirm(context, issue, h),
                        ),
                        const SizedBox(height: 32),
                        const Text('최신 조사 결과', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                        const SizedBox(height: 8),
                        MarkdownBody(data: issue.lastInvestigation ?? '상세 조사 내용이 아직 없습니다.'),
                        const SizedBox(height: 32),
                        IssueCollaborationInput(
                          onSend: (req) => _sendAIRequest(issue, req),
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
        title: const Text('이슈 삭제', style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: const Text('삭제', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showHistoryDeleteConfirm(BuildContext context, InvestmentIssue issue, IssueHistory history) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text('기록 삭제', style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: const Text('삭제', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  void _sendAIRequest(InvestmentIssue issue, String userRequest) {
    final String baseMessage = '${widget.symbol} 종목의 "${issue.title}" 이슈에 대한 최신 상황을 더 조사해서 이슈 트레이스에 기록해줘.';
    final String finalMessage = userRequest.isNotEmpty 
      ? '$baseMessage\n\n[사용자 지시사항]: $userRequest'
      : baseMessage;
 
    if (AriAgent.isConnected) {
      AriAgent.report(
        appId: 'aristock',
        type: 'INVESTIGATE_ISSUE',
        message: finalMessage,
        details: {
          'symbol': widget.symbol,
          'issueTitle': issue.title,
          'userRequest': userRequest,
        },
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI가 "${issue.title}" 이슈에 대한 정밀 리서치를 시작합니다...')),
      );
    }
  }
}
