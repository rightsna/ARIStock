import 'package:flutter/material.dart';
import '../models/strategy_model.dart';
import '../repositories/strategy_repository.dart';

class StrategyProvider with ChangeNotifier {
  final StrategyRepository _repository = StrategyRepository();

  List<Strategy> _strategies = [];
  Strategy? _selectedStrategy;
  List<TradingLog> _tradingLogs = [];
  bool _isLoading = false;

  List<Strategy> get strategies => _strategies;
  Strategy? get selectedStrategy => _selectedStrategy;
  List<TradingLog> get tradingLogs => _tradingLogs;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _strategies = await _repository.getAllStrategies();

    if (_strategies.isNotEmpty) {
      await selectStrategy(_strategies.first.symbol);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectStrategy(String symbol) async {
    _selectedStrategy = await _repository.getStrategy(symbol);
    _tradingLogs = await _repository.getTradingLogs(symbol);
    notifyListeners();
  }

  Future<void> saveStrategy(String symbol, String name, String content) async {
    final strategy = Strategy(
      symbol: symbol,
      name: name,
      content: content,
    );
    await _repository.saveStrategy(strategy);
    _strategies = await _repository.getAllStrategies();
    await selectStrategy(symbol);
    notifyListeners();
  }

  Future<void> saveTradingLog({
    required String symbol,
    required String type,
    required String price,
    required String quantity,
    required String status,
    required String aiReason,
  }) async {
    final strategy = await _repository.getStrategy(symbol);
    final log = TradingLog(
      symbol: symbol,
      date: DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '.'),
      type: type,
      price: price,
      quantity: quantity,
      status: status,
      strategySnapshot: strategy?.content ?? '전략 정보 없음',
      aiReason: aiReason,
    );
    await _repository.saveTradingLog(log);
    if (_selectedStrategy?.symbol == symbol) {
      _tradingLogs = await _repository.getTradingLogs(symbol);
    }
    notifyListeners();
  }

  // 모든 전략 데이터 삭제
  Future<void> clearAll() async {
    await _repository.clearAll();
    _strategies = [];
    _selectedStrategy = null;
    _tradingLogs = [];
    notifyListeners();
  }
}
