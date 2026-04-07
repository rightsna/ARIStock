import 'package:flutter/material.dart';
import 'package:ari_plugin/ari_plugin.dart';
import '../../../../shared/theme.dart';

class AddIssueRequestDialog extends StatefulWidget {
  final String symbol;

  const AddIssueRequestDialog({
    super.key,
    required this.symbol,
  });

  @override
  State<AddIssueRequestDialog> createState() => _AddIssueRequestDialogState();
}

class _AddIssueRequestDialogState extends State<AddIssueRequestDialog> {
  final TextEditingController _requestController = TextEditingController();

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceWhite,
      title: Row(
        children: [
          const Icon(Icons.add_task_rounded, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 8),
          Text(
            '이슈 추가 및 편집 지시',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '추가하고 싶은 구체적인 이슈나, 기존 이슈 리스트를 어떻게 수정하고 싶은지 AI에게 알려주세요.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMain70),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.textMain10, width: 1.5),
            ),
            child: TextField(
              controller: _requestController,
              maxLines: 4,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '예: 신규 계약 체결 소식을 분석해서 추가해줘. 기존 부정적 리스크는 이제 해소된 거 같아.',
                hintStyle: TextStyle(fontSize: 12, color: AppTheme.textMain24),
                contentPadding: EdgeInsets.all(12),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: AppTheme.textMain54)),
        ),
        ElevatedButton(
          onPressed: _sendAddRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('AI에게 지시'),
        ),
      ],
    );
  }

  void _sendAddRequest() {
    final requestText = _requestController.text.trim();
    if (requestText.isNotEmpty && AriAgent.isConnected) {
      AriAgent.report(
        appId: 'aristock',
        type: 'REQUEST_ANALYSIS',
        message:
            '${widget.symbol} 종목에 대해 다음 요청사항을 반영하여 투자 이슈 매니지먼트 보드를 대대적으로 업데이트해줘:\n\n[사용자 지시사항]: $requestText',
        details: {'symbol': widget.symbol, 'editRequest': requestText},
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI가 요청한 내용으로 "${widget.symbol}" 이슈 리빙 리포트를 재구성합니다...')),
      );
    }
  }
}
