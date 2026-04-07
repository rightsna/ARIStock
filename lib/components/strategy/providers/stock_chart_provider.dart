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
  int _selectedPeriod = 90;

  List<Candle> _currentCandles = [];
  List<Candle> get currentCandles => _currentCandles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedPeriod => _selectedPeriod;

  // period == 0: 1분봉 1시간치 = 60개
  // period == 1: 30분봉 24시간치 = 48개
  static const int _intraday1minCandles = 60;
  static const int _intraday30minCandles = 48;

  String _cacheKey(String symbol, int period) => '${symbol}_$period';

  Future<void> fetchDailyChart(String symbol) async {
    final key = _cacheKey(symbol, _selectedPeriod);

    if (_cache.containsKey(key) && _cache[key]!.isFresh) {
      debugPrint('StockChartProvider: Using fresh cache for $key');
      _currentCandles = _cache[key]!.candles;
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('StockChartProvider: Fetching real API for $key');
      final MarketTimeframe timeframe;
      final int limit;
      if (_selectedPeriod == 0) {
        timeframe = MarketTimeframe.minute1;
        limit = _intraday1minCandles;
      } else if (_selectedPeriod == 1) {
        timeframe = MarketTimeframe.minute30;
        limit = _intraday30minCandles;
      } else {
        timeframe = MarketTimeframe.day;
        limit = _selectedPeriod;
      }
      final result = await marketDataRepository.fetchCandles(
        symbol: symbol,
        timeframe: timeframe,
        limit: limit,
      );

      _cache[key] = _ChartCacheEntry(result, DateTime.now());
      _currentCandles = result;
    } catch (e) {
      _error = e.toString();
      _currentCandles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setPeriod(int period, String? symbol) async {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners();
    if (symbol != null) {
      await fetchDailyChart(symbol);
    }
  }

  void clearCache() {
    _cache.clear();
  }
}
