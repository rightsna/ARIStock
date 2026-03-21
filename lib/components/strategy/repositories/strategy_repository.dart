import 'package:hive/hive.dart';
import '../models/strategy_model.dart';

class StrategyRepository {
  static const String strategyBoxName = 'strategy_box';
  static const String tradingLogBoxName = 'trading_log_box';

  Future<Box<Strategy>> _openStrategyBox() async {
    return await Hive.openBox<Strategy>(strategyBoxName);
  }

  Future<Box<TradingLog>> _openTradingLogBox() async {
    return await Hive.openBox<TradingLog>(tradingLogBoxName);
  }

  // 매매 전략 CRUD
  Future<void> saveStrategy(Strategy strategy) async {
    final box = await _openStrategyBox();
    await box.put(strategy.symbol, strategy);
  }

  Future<Strategy?> getStrategy(String symbol) async {
    final box = await _openStrategyBox();
    return box.get(symbol);
  }

  Future<List<Strategy>> getAllStrategies() async {
    final box = await _openStrategyBox();
    return box.values.toList();
  }

  // 매매 로그 CRUD
  Future<void> saveTradingLog(TradingLog log) async {
    final box = await _openTradingLogBox();
    await box.add(log);
  }

  Future<List<TradingLog>> getTradingLogs(String symbol) async {
    final box = await _openTradingLogBox();
    return box.values
        .where((log) => log.symbol == symbol)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // 모든 전략 및 로그 삭제
  Future<void> clearAll() async {
    final sBox = await _openStrategyBox();
    final tBox = await _openTradingLogBox();
    await sBox.clear();
    await tBox.clear();
  }
}
