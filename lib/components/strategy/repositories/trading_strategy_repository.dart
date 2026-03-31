import 'package:hive_flutter/hive_flutter.dart';
import '../models/trading_strategy_model.dart';

class TradingStrategyRepository {
  static const _boxName = 'trading_strategy_v1';

  Future<Box<TradingStrategy>> _openBox() => Hive.openBox<TradingStrategy>(_boxName);

  Future<void> save(TradingStrategy strategy) async {
    final box = await _openBox();
    await box.put(strategy.symbol, strategy);
  }

  Future<TradingStrategy?> get(String symbol) async {
    final box = await _openBox();
    return box.get(symbol);
  }

  Future<void> delete(String symbol) async {
    final box = await _openBox();
    await box.delete(symbol);
  }
}
