import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ari_plugin/ari_plugin.dart';
import '../../models/analysis_model.dart';
import '../../providers/analysis_provider.dart';
import '../../../../shared/theme.dart';

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
  final TextEditingController _requestController = TextEditingController();

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            _buildHeader(context),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetaInfo(),
                    const SizedBox(height: 24),
                    _buildHistoryTimeline(),
                    const SizedBox(height: 32),
                    const Text('최신 조사 결과', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                    const SizedBox(height: 8),
                    MarkdownBody(data: widget.issue.lastInvestigation ?? '상세 조사 내용이 아직 없습니다.'),
                    const SizedBox(height: 32),
                    _buildCollaborationInput(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          widget.issue.isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          color: widget.issue.isPositive ? AppTheme.accentRed : AppTheme.primaryBlue,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.issue.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain),
          ),
        ),
        IconButton(
          onPressed: () => _showDeleteConfirm(context),
          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textSub),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context) {
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
              widget.provider.deleteIssue(widget.issue);
              Navigator.pop(ctx); // 다이얼로그 닫기
              Navigator.pop(context); // 시트 닫기
            },
            child: const Text('삭제', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showHistoryDeleteConfirm(BuildContext context, IssueHistory history) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text('기록 삭제', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('선택한 타임라인 기록을 영구적으로 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: AppTheme.textSub)),
          ),
          TextButton(
            onPressed: () {
              widget.provider.deleteHistoryItem(widget.issue, history);
              Navigator.pop(ctx);
              setState(() {
                widget.issue.history?.removeWhere((h) => 
                  h.date == history.date && h.content == history.content && h.detail == history.detail
                );
              });
            },
            child: const Text('삭제', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildInfoItem(Icons.calendar_today_rounded, '시작일', widget.issue.startDate),
        if (widget.issue.endDate != null) 
          _buildInfoItem(Icons.event_available_rounded, '종료일', widget.issue.endDate!),
        _buildInfoItem(Icons.analytics_rounded, '임팩트', 'Level ${widget.issue.impact}'),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSub),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: AppTheme.textSub)),
        Text(value, style: const TextStyle(fontSize: 12, color: AppTheme.textMain, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCollaborationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, size: 14, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text('AI 입체 분석 요청', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.textMain10, width: 1.5),
                ),
                child: TextField(
                  controller: _requestController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: '이슈의 특정 부분을 수정하거나 더 분석해달라고 요청하세요...',
                    hintStyle: TextStyle(fontSize: 12, color: AppTheme.textMain24),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 56,
              width: 56,
              child: ElevatedButton(
                onPressed: _sendAIRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Icon(Icons.send_rounded, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryTimeline() {
    if (widget.issue.history == null || widget.issue.history!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('타임라인 히스토리', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSub)),
        const SizedBox(height: 16),
        ...widget.issue.history!.reversed.map((h) => Padding(
          padding: const EdgeInsets.only(bottom: 20, right: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const CircleAvatar(radius: 4, backgroundColor: AppTheme.textMain38),
                  Container(width: 1, height: 40, color: AppTheme.textMain10),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(h.date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSub)),
                        GestureDetector(
                          onTap: () => _showHistoryDeleteConfirm(context, h),
                          child: const Icon(Icons.close_rounded, size: 14, color: AppTheme.textMain24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(h.content, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMain)),
                    if (h.detail != null) ...[
                      const SizedBox(height: 4),
                      Text(h.detail!, style: const TextStyle(fontSize: 12, color: AppTheme.textSub, height: 1.4)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          widget.provider.toggleIssueResolved(widget.issue);
          Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: widget.issue.isResolved ? AppTheme.textMain54 : AppTheme.accentGreen,
          side: BorderSide(color: widget.issue.isResolved ? AppTheme.textMain10 : AppTheme.accentGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          widget.issue.isResolved ? '이슈 재활성화 (Active 전환)' : '이슈 종료 처리 (Resolved 전환)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _sendAIRequest() {
    final userRequest = _requestController.text.trim();
    final String baseMessage = '${widget.symbol} 종목의 "${widget.issue.title}" 이슈에 대한 최신 상황을 더 조사해서 타임라인에 기록해줘.';
    final String finalMessage = userRequest.isNotEmpty 
      ? '$baseMessage\n\n[사용자 지시사항]: $userRequest'
      : baseMessage;

    if (WsManager.isConnected) {
      WsManager.sendAsync('/APP.REPORT', {
        'appId': 'aristock',
        'event': 'INVESTIGATE_ISSUE',
        'message': finalMessage,
        'params': {
          'symbol': widget.symbol,
          'issueTitle': widget.issue.title,
          'userRequest': userRequest
        }
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI가 "${widget.issue.title}" 이슈에 대한 정밀 리서치를 시작합니다...')),
      );
    }
  }
}
