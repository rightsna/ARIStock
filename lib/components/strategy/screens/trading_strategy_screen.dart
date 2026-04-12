import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:ari_plugin/ari_plugin.dart';
import '../models/trading_strategy_model.dart';
import '../providers/trading_strategy_provider.dart';
import '../../watchlist/providers/watchlist_provider.dart';
import 'widgets/stock_daily_chart.dart';
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
            Icon(
              Icons.candlestick_chart_outlined,
              size: 48,
              color: AppTheme.textMain24,
            ),
            SizedBox(height: 16),
            Text(
              '종목을 선택해주세요',
              style: TextStyle(color: AppTheme.textMain54, fontSize: 15),
            ),
          ],
        ),
      );
    }

    final strategy = strategyProvider.selectedStrategy;
    final content = strategy?.content ?? '';

    // 1. 구조화된 데이터(배열) 우선 사용
    // 2. 없으면 텍스트 파싱 시도 (하위 호환성)
    List<double>? entryPrices = strategy?.entryPrices;
    if (entryPrices == null || entryPrices.isEmpty) {
      final p = _extractPrice(content, ['매수가', '진입가', '매수포인트']);
      if (p != null) entryPrices = [p];
    }

    List<double>? targetPrices = strategy?.targetPrices;
    if (targetPrices == null || targetPrices.isEmpty) {
      final p = _extractPrice(content, ['목표가', '익절가', '1차 목표가']);
      if (p != null) targetPrices = [p];
    }

    final stopLoss =
        strategy?.stopLoss ?? _extractPrice(content, ['손절가', '리스크 관리']);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${selectedStock.name} 매매전략',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textMain,
                  ),
                ),
                const Spacer(),
                if (strategy != null)
                  Text(
                    '업데이트: ${strategy.updatedAt}',
                    style: const TextStyle(
                      color: AppTheme.textSub,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          StockDailyChart(
            entryPrices: entryPrices,
            targetPrices: targetPrices,
            stopLoss: stopLoss,
          ),
          Expanded(
            child: strategy == null
                ? _buildEmpty(selectedStock.symbol, selectedStock.name)
                : _buildContent(
                    context,
                    strategy,
                    strategyProvider,
                    selectedStock.name,
                  ),
          ),
        ],
      ),
    );
  }

  double? _extractPrice(String content, List<String> labels) {
    for (final label in labels) {
      // 1. 볼드 처리된 경우 (**매수가**: 10000)
      // 2. 일반 텍스트 (매수가: 10000)
      // 3. 공백 및 특수기호 유연하게 대응
      final regExp = RegExp(
        '(?:\\*\\*\\s*)?$label(?:\\s*\\*\\*)?\\s*[:：]\\s*([0-9,]+)',
        multiLine: true,
      );
      final match = regExp.firstMatch(content);
      if (match != null) {
        final val = match.group(1)?.replaceAll(',', '');
        if (val != null) return double.tryParse(val);
      }
    }
    return null;
  }

  Widget _buildEmpty(String symbol, String stockName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: AppTheme.textMain24,
            ),
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
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                if (!AriAgent.isConnected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI 에이전트와 연결되어 있지 않습니다. 서버 상태를 확인해주세요.'),
                      backgroundColor: AppTheme.accentRed,
                    ),
                  );
                  return;
                }
                context.read<AriChatProvider>().sendAgentMessage(
                  '$stockName($symbol)에 대한 매매전략을 수립해줘. (매수가, 손절가, 목표가 포함)',
                  appId: 'aristock',
                  platform: 'aristock',
                );
              },
              icon: const Icon(Icons.auto_awesome, size: 14),
              label: const Text(
                'AI 매매전략 수립 요청',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                foregroundColor: AppTheme.primaryBlue,
                side: const BorderSide(color: AppTheme.primaryBlue, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TradingStrategy strategy,
    TradingStrategyProvider provider,
    String stockName,
  ) {
    final hasDiff = provider.hasPendingDiff(strategy.symbol);
    final originalContent = provider.getOriginalContent(strategy.symbol);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '매매전략 지시서',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: strategy.content),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('전략 내용이 클립보드에 복사되었습니다.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.copy_rounded,
                              size: 14,
                              color: AppTheme.textSub,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '복사',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSub,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'AI가 수립한 시장 분석 결과를 바탕으로 최적의 포지션 진입 및 청산 전략을 관리하며, 실제 매매 시 AI는 이 지시서의 가이드라인을 엄격히 준수합니다. 수정이나 새로운 전략 수립이 필요하면 AI에게 요청해 주세요.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSub,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          AriMarkdownEditor(
            content: strategy.content,
            previousContent: originalContent,
            hasDiff: hasDiff,
            onApproveAll: () => provider.approveUpdate(strategy.symbol),
            onRejectAll: () => provider.rejectUpdate(strategy.symbol),
            onPartialUpdate: (content, previous) {
              provider.updateStrategy(strategy.copyWith(content: content));
            },
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.center,
            child: Text(
              '이 AI전략은 자동매매에 사용되며, 수정이 필요하면 AI에게 요청할 수 있습니다.',
              style: TextStyle(color: AppTheme.textMain38, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () => _showResetConfirm(context),
              icon: const Icon(
                Icons.delete_outline,
                size: 16,
                color: AppTheme.textMain38,
              ),
              label: const Text(
                '현재 종목 매매전략 초기화',
                style: TextStyle(color: AppTheme.textMain38, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showResetConfirm(BuildContext context) {
    final strategyProvider = context.read<TradingStrategyProvider>();
    final symbol = context.read<WatchlistProvider>().selectedSymbol;
    if (symbol == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text(
          '데이터 초기화',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '해당 종목의 매매전략 데이터가 삭제됩니다. 계속하시겠습니까?',
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
              strategyProvider.deleteStrategy(symbol);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"$symbol" 매매전략이 초기화되었습니다.')),
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
