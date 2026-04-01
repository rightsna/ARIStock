import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../providers/trading_strategy_provider.dart';
import '../../watchlist/providers/watchlist_provider.dart';
import '../../../shared/theme.dart';

class TradingStrategyScreen extends StatefulWidget {
  const TradingStrategyScreen({super.key});

  @override
  State<TradingStrategyScreen> createState() => _TradingStrategyScreenState();
}

class _TradingStrategyScreenState extends State<TradingStrategyScreen> {
  String? _lastSyncedSymbol;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedSymbol = context.watch<WatchlistProvider>().selectedSymbol;

    if (selectedSymbol != null && selectedSymbol != _lastSyncedSymbol) {
      _lastSyncedSymbol = selectedSymbol;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TradingStrategyProvider>().selectStock(selectedSymbol);
        context.read<TradingStrategyProvider>().loadStrategy(selectedSymbol);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final watchlistProvider = context.watch<WatchlistProvider>();
    final strategyProvider = context.watch<TradingStrategyProvider>();
    final selectedStock = watchlistProvider.selectedStock;

    if (selectedStock == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.candlestick_chart_outlined, size: 48, color: AppTheme.textMain24),
            SizedBox(height: 16),
            Text('종목을 선택해주세요', style: TextStyle(color: AppTheme.textMain54, fontSize: 15)),
          ],
        ),
      );
    }

    final strategy = strategyProvider.selectedStrategy;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: strategy == null
                ? _buildEmpty(selectedStock.symbol, selectedStock.name)
                : _buildContent(strategy.content, strategy.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String symbol, String stockName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_outlined, size: 48, color: AppTheme.textMain24),
            const SizedBox(height: 16),
            const Text(
              'AI가 작성한 매매전략이 없습니다',
              style: TextStyle(fontSize: 15, color: AppTheme.textMain54),
            ),
            const SizedBox(height: 8),
            Text(
              '$stockName에 대한 매매전략을 AI에게 요청해보세요.',
              style: const TextStyle(fontSize: 13, color: AppTheme.textMain38),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String content, String updatedAt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: AppTheme.primaryBlue),
              const SizedBox(width: 6),
              const Text(
                'AI 매매전략',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              const Spacer(),
              Text(
                updatedAt,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMain38),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 14, height: 1.6, color: AppTheme.textMain),
              h2: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textMain),
              h3: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

}
