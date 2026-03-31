import 'package:flutter/material.dart';
import '../models/trading_strategy_model.dart';
import '../repositories/trading_strategy_repository.dart';

class TradingStrategyProvider extends ChangeNotifier {
  final TradingStrategyRepository _repository = TradingStrategyRepository();

  final Map<String, TradingStrategy> _strategies = {};
  String? _selectedSymbol;

  TradingStrategy? get selectedStrategy =>
      _selectedSymbol != null ? _strategies[_selectedSymbol] : null;

  void selectStock(String symbol) {
    _selectedSymbol = symbol;
    notifyListeners();
  }

  TradingStrategy? getStrategyForSymbol(String symbol) => _strategies[symbol];

  Future<void> saveStrategy(TradingStrategy strategy) async {
    await _repository.save(strategy);
    _strategies[strategy.symbol] = strategy;
    notifyListeners();
  }

  Future<void> loadStrategy(String symbol) async {
    final strategy = await _repository.get(symbol);
    if (strategy != null) {
      _strategies[symbol] = strategy;
      notifyListeners();
    }
  }

  Future<void> deleteStrategy(String symbol) async {
    await _repository.delete(symbol);
    _strategies.remove(symbol);
    notifyListeners();
  }
}
