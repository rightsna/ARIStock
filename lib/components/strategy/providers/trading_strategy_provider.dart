import 'package:flutter/material.dart';
import '../models/trading_strategy_model.dart';
import '../repositories/trading_strategy_repository.dart';

class TradingStrategyProvider extends ChangeNotifier {
  final TradingStrategyRepository _repository = TradingStrategyRepository();

  final Map<String, TradingStrategy> _strategies = {};
  String? _selectedSymbol;

  // Diff 관리 (AI의 전략 수정 제안)
  final Map<String, String> _originalContents = {}; // symbol -> original_content

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
    _originalContents.remove(symbol);
    notifyListeners();
  }

  // --- Diff 관리 로직 ---

  void updateStrategy(TradingStrategy newStrategy) {
    final symbol = newStrategy.symbol;
    final current = _strategies[symbol];

    // 내용이 다를 때만 원본 보관 (Diff UI를 위한 준비)
    if (current != null && current.content != newStrategy.content) {
      if (!_originalContents.containsKey(symbol)) {
        _originalContents[symbol] = current.content;
      }
    }

    // 예외 없이 즉시 최신화 (메모리 + DB)
    _strategies[symbol] = newStrategy;
    _repository.save(newStrategy);

    notifyListeners();
  }

  bool hasPendingDiff(String symbol) => _originalContents.containsKey(symbol);
  String? getOriginalContent(String symbol) => _originalContents[symbol];

  void approveUpdate(String symbol) {
    // 승인은 보관된 원본만 지워 Diff UI를 제거함
    _originalContents.remove(symbol);
    notifyListeners();
  }

  void rejectUpdate(String symbol) async {
    final original = _originalContents.remove(symbol);
    final current = _strategies[symbol];

    if (original != null && current != null) {
      final reverted = current.copyWith(content: original);

      // 거절 시에만 명시적으로 이전 내용으로 롤백 (메모리 + DB)
      _strategies[symbol] = reverted;
      await _repository.save(reverted);

      notifyListeners();
    }
  }
}
