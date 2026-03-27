import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:ari_plugin/ari_plugin.dart';

import '../providers/analysis_provider.dart';
import '../../watchlist/providers/watchlist_provider.dart';
import '../models/analysis_model.dart';
import '../../../shared/theme.dart';

// 리팩토링된 위젯들
import '../widgets/trend_summary_card.dart';
import '../widgets/analysis_report_header.dart';
import 'gantt/analysis_issue_gantt.dart';
import '../widgets/analysis_info_card.dart';
import '../widgets/user_note_card.dart';
import 'issue/issue_detail_sheet.dart';
import 'issue/add_issue_request_dialog.dart';
import '../widgets/analysis_state_views.dart';

/// 종목분석 화면: 단일 종목에 대한 통합 투자 이슈 매니지먼트를 담당합니다 (Living Report).
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String? _lastSyncedSymbol;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedSymbol = context.watch<WatchlistProvider>().selectedSymbol;

    if (selectedSymbol != null && selectedSymbol != _lastSyncedSymbol) {
      _lastSyncedSymbol = selectedSymbol;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AnalysisProvider>().selectStock(selectedSymbol);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchlistProvider = context.watch<WatchlistProvider>();
    final analysisProvider = context.watch<AnalysisProvider>();
    final selectedStock = watchlistProvider.selectedStock;

    if (selectedStock == null) {
      return const NoStockSelectedView();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: analysisProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (analysisProvider.selectedLog != null)
                    _buildMainAnalysisContent(
                      context,
                      analysisProvider,
                      selectedStock,
                    )
                  else
                    EmptyAnalysisView(
                      symbol: selectedStock.symbol,
                      onRequestAnalysis: () =>
                          _requestAIUpdate(context, selectedStock.symbol),
                    ),
                  const SizedBox(height: 48),
                  if (kDebugMode)
                    _buildDebugTools(analysisProvider, selectedStock),
                  _buildFooterActions(
                    context,
                    analysisProvider,
                    selectedStock.symbol,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRequestAnalysisButton(BuildContext context, String symbol) {
    return ElevatedButton.icon(
      onPressed: () => _requestAIUpdate(context, symbol),
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

  Widget _buildMainAnalysisContent(
    BuildContext context,
    AnalysisProvider provider,
    dynamic stock,
  ) {
    final log = provider.selectedLog!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalysisReportHeader(stockName: stock.name, date: log.date),
        const SizedBox(height: 32),
        TrendSummaryCard(
          shortTerm: log.shortTermScore,
          mediumTerm: log.mediumTermScore,
          longTerm: log.longTermScore,
        ),
        const SizedBox(height: 32),
        AnalysisIssueGantt(
          issues: log.issues ?? [],
          onIssueTap: (issue) =>
              _showDetails(context, stock.symbol, issue, provider),
          onAddRequest: () => _showAddRequest(context, stock.symbol),
        ),
        const SizedBox(height: 32),
        AnalysisInfoCard(
          title: '종합 전망 요약',
          content: log.summary ?? '',
          icon: Icons.lightbulb_outline,
          themeColor: AppTheme.primaryBlue,
        ),
        const SizedBox(height: 32),
        UserNoteCard(
          initialNote: log.userNote,
          onChanged: (value) => provider.updateUserNote(value),
        ),
      ],
    );
  }

  void _showDetails(
    BuildContext context,
    String symbol,
    InvestmentIssue issue,
    AnalysisProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          IssueDetailSheet(symbol: symbol, issue: issue, provider: provider),
    );
  }

  void _showAddRequest(BuildContext context, String symbol) {
    showDialog(
      context: context,
      builder: (ctx) => AddIssueRequestDialog(symbol: symbol),
    );
  }

  void _requestAIUpdate(BuildContext context, String symbol) {
    if (WsManager.isConnected) {
      WsManager.sendAsync('/APP.REPORT', {
        'appId': 'aristock',
        'event': 'REQUEST_ANALYSIS',
        'message': '$symbol 종목에 대한 최신 상황을 분석하여 통합 이슈 타임라인을 업데이트해줘.',
        'params': {'symbol': symbol},
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI에게 "$symbol" 리서치 업데이트를 요청했습니다...')),
      );
    }
  }

  Widget _buildDebugTools(AnalysisProvider provider, dynamic stock) {
    return Center(
      child: TextButton.icon(
        onPressed: () => provider.loadSampleTimeline(stock.symbol, stock.name),
        icon: const Icon(
          Icons.playlist_add_check_circle_rounded,
          size: 16,
          color: Colors.blue,
        ),
        label: const Text(
          'DEBUG: 복합 간트 차트 샘플 생성',
          style: TextStyle(color: Colors.blue, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildFooterActions(
    BuildContext context,
    AnalysisProvider provider,
    String symbol,
  ) {
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
                '현재 종목 타임라인 전체 초기화',
                style: TextStyle(color: AppTheme.textMain38, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
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
        content: const Text('현재까지 누적된 모든 투자 이슈와 간트 차트 기록이 삭제됩니다.\n계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(ctx);
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
