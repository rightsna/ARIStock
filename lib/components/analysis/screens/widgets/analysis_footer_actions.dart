import 'package:flutter/material.dart';
import 'package:ari_plugin/ari_plugin.dart';
import '../../providers/analysis_provider.dart';
import '../../../../shared/theme.dart';

class AnalysisFooterActions extends StatelessWidget {
  final AnalysisProvider provider;
  final String symbol;

  const AnalysisFooterActions({
    super.key,
    required this.provider,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 40),
      child: Column(
        children: [
          Center(child: _buildRequestAnalysisButton(context, symbol)),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () => _showResetConfirm(context, provider),
              icon: const Icon(
                Icons.delete_outline,
                size: 16,
                color: AppTheme.textMain38,
              ),
              label: const Text(
                '현재 종목 이슈 트레이스 전체 초기화',
                style: TextStyle(color: AppTheme.textMain38, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestAnalysisButton(BuildContext context, String symbol) {
    return ElevatedButton.icon(
      onPressed: () => requestAIUpdate(context, symbol),
      icon: const Icon(Icons.auto_awesome, size: 14),
      label: const Text('AI 리서치 업데이트', style: TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  static void requestAIUpdate(BuildContext context, String symbol) {
    if (WsManager.isConnected) {
      WsManager.sendAsync('/APP.REPORT', {
        'appId': 'aristock',
        'event': 'REQUEST_ANALYSIS',
        'message': '$symbol 종목에 대한 최신 상황을 분석하여 통합 이슈 트레이스를 업데이트해줘.',
        'params': {'symbol': symbol},
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI에게 "$symbol" 리서치 업데이트를 요청했습니다...')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ARI 서버와 연결되어 있지 않습니다.')));
    }
  }

  void _showResetConfirm(BuildContext context, AnalysisProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text(
          '데이터 초기화',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '해당 종목의 모든 이슈와 분석 내용이 삭제되며, 초기화 상태로 되돌아갑니다. 계속하시겠습니까?',
          style: TextStyle(fontSize: 14, color: AppTheme.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              '취소',
              style: TextStyle(color: AppTheme.textMain38),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.clearLog(symbol);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"$symbol" 분석 데이터가 초기화되었습니다.')),
              );
            },
            child: const Text(
              '초기화',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }
}
