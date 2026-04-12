import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/analysis_provider.dart';
import '../../watchlist/providers/watchlist_provider.dart';
import '../../../shared/theme.dart';

// 리팩토링된 위젯들
import 'widgets/trend_summary_card.dart';
import 'widgets/analysis_report_header.dart';
import 'gantt/analysis_issue_gantt.dart';
import 'widgets/analysis_state_views.dart';
import 'widgets/analysis_footer_actions.dart';

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
                  if (analysisProvider.selectedAnalysis != null)
                    _buildMainAnalysisContent(
                      context,
                      analysisProvider,
                      selectedStock,
                    )
                  else
                    EmptyAnalysisView(
                      symbol: selectedStock.symbol,
                      onRequestAnalysis: () =>
                          AnalysisFooterActions.requestAIUpdate(
                            context,
                            selectedStock.symbol,
                          ),
                    ),
                  if (analysisProvider.selectedAnalysis != null)
                    AnalysisFooterActions(
                      provider: analysisProvider,
                      symbol: selectedStock.symbol,
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildMainAnalysisContent(
    BuildContext context,
    AnalysisProvider provider,
    dynamic stock,
  ) {
    final analysis = provider.selectedAnalysis!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnalysisReportHeader(
          stockName: stock.name,
          date: analysis.date,
          onRequestUpdate: () =>
              AnalysisFooterActions.requestAIUpdate(context, stock.symbol),
        ),
        const SizedBox(height: 32),
        TrendSummaryCard(
          shortTerm: analysis.shortTermScore,
          mediumTerm: analysis.mediumTermScore,
          longTerm: analysis.longTermScore,
          summary: analysis.summary,
        ),
        const SizedBox(height: 32),
        AnalysisIssueGantt(symbol: stock.symbol, issues: analysis.issues ?? []),
      ],
    );
  }
}
