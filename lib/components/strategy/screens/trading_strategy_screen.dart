import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ari_plugin/ari_plugin.dart';

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
  final TextEditingController _requestController = TextEditingController();

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

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

  void _requestStrategy(String symbol, String stockName) {
    if (!AriAgent.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 에이전트가 연결되어 있지 않습니다.')),
      );
      return;
    }
    final userNote = _requestController.text.trim();
    final message = userNote.isNotEmpty
        ? '$symbol ($stockName) 종목에 대한 매매전략을 수립해줘. 추가 요청사항: $userNote'
        : '$symbol ($stockName) 종목에 대한 매매전략을 수립해줘.';
    AriAgent.report(
      appId: 'aristock',
      type: 'REQUEST_STRATEGY',
      message: message,
      details: {
        'symbol': symbol,
        'stockName': stockName,
        if (userNote.isNotEmpty) 'userNote': userNote,
      },
    );
    _requestController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('AI가 $stockName 매매전략을 수립합니다...')),
    );
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
          _buildRequestButton(selectedStock.symbol, selectedStock.name),
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

  Widget _buildRequestButton(String symbol, String stockName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.textMain10, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _requestController,
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              hintText: '추가 요청사항을 입력하세요 (선택)',
              hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMain38),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.textMain10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.textMain10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.primaryBlue),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
            ),
            style: const TextStyle(fontSize: 13, color: AppTheme.textMain),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _requestStrategy(symbol, stockName),
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('AI에게 매매전략 재요청'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
