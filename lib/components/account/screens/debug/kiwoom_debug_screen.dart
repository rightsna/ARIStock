import 'dart:convert';
import 'package:flutter/material.dart';
import '../../providers/account_provider.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme.dart';

class KiwoomDebugScreen extends StatefulWidget {
  const KiwoomDebugScreen({super.key});

  @override
  State<KiwoomDebugScreen> createState() => _KiwoomDebugScreenState();
}

class _KiwoomDebugScreenState extends State<KiwoomDebugScreen> {
  String _result = '버튼을 눌러 API를 테스트하세요.';
  bool _isLoading = false;

  void _updateResult(dynamic data) {
    setState(() {
      if (data is Map || data is List) {
        _result = const JsonEncoder.withIndent('  ').convert(data);
      } else {
        _result = data.toString();
      }
      _isLoading = false;
    });
  }

  Future<void> _runTest(String name, Future<dynamic> Function() testFn) async {
    setState(() {
      _isLoading = true;
      _result = '$name 테스트 중...';
    });
    try {
      final res = await testFn();
      _updateResult(res);
    } catch (e) {
      _updateResult('에러 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.read<AccountProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('키움 API 디버그 도구'),
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTestButton('계좌 목록 (ka00001)', () => ap.accountService.getAccounts().then((r) => r.body)),
                  _buildTestButton('계좌 평가 (kt00004)', () => ap.accountService.getAccountEvaluation(accountNo: ap.selectedAccountNo ?? '').then((r) => r.body)),
                  _buildTestButton('예수금 상세 (kt00001)', () => ap.accountService.getDepositDetails(accountNo: ap.selectedAccountNo ?? '').then((r) => r.body)),
                  _buildTestButton('주식 잔고 (kt00018)', () => ap.accountService.getAccountBalance(accountNo: ap.selectedAccountNo ?? '').then((r) => r.body)),
                  const Divider(),
                  _buildTestButton('현재가 조회 (ka10004)', () => ap.marketService.getStockQuote(stockCode: '005930').then((r) => r.body)),
                  _buildTestButton('주식 기본정보 (ka10001)', () => ap.marketService.getStockInfo(stockCode: '005930').then((r) => r.body)),
                  _buildTestButton('틱 차트 (ka10079)', () => ap.marketService.getStockTickChart(stockCode: '005930').then((r) => r.body)),
                  _buildTestButton('분 차트 (ka10080)', () => ap.marketService.getStockMinuteChart(stockCode: '005930', ticScope: '1').then((r) => r.body)),
                  _buildTestButton('일 차트 (ka10081)', () => ap.marketService.getStockDailyChart(stockCode: '005930', baseDate: '20240328').then((r) => r.body)),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.all(12),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
                : SingleChildScrollView(
                    child: Text(
                      _result,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String label, Future<dynamic> Function() onTap) {
    return ElevatedButton(
      onPressed: () => _runTest(label, onTap),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textMain,
        elevation: 0,
        side: const BorderSide(color: AppTheme.textMain10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
      ),
      child: Text(label),
    );
  }
}
