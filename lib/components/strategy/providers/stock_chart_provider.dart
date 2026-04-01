import 'package:flutter/material.dart';
import '../../../../shared/models/market/candle.dart';
import '../../../../shared/models/market/market_timeframe.dart';
import '../../../../shared/repository/kiwoom/market_data_repository.dart';

class _ChartCacheEntry {
  final List<Candle> candles;
  final DateTime updatedAt;

  _ChartCacheEntry(this.candles, this.updatedAt);

  bool get isFresh =>
      DateTime.now().difference(updatedAt).inMinutes < 1;
}

class StockChartProvider extends ChangeNotifier {
  final KiwoomMarketDataRepository marketDataRepository;
  StockChartProvider(this.marketDataRepository);

  final Map<String, _ChartCacheEntry> _cache = {};
  bool _isLoading = false;
  String? _error;

  List<Candle> _currentCandles = [];
  List<Candle> get currentCandles => _currentCandles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDailyChart(String symbol) async {
    // 1분 이내 동일 종목 요청시 캐시 반환
    if (_cache.containsKey(symbol) && _cache[symbol]!.isFresh) {
      debugPrint('StockChartProvider: Using fresh cache for $symbol');
      _currentCandles = _cache[symbol]!.candles;
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('StockChartProvider: Fetching real API for $symbol');
      final result = await marketDataRepository.fetchCandles(
        symbol: symbol,
        timeframe: MarketTimeframe.day,
        limit: 90,
      );
      
      _cache[symbol] = _ChartCacheEntry(result, DateTime.now());
      _currentCandles = result;
    } catch (e) {
      _error = e.toString();
      _currentCandles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _cache.clear();
  }
}
