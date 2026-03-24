import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/watchlist_model.dart';
import '../../account/providers/account_provider.dart';

class WatchlistProvider with ChangeNotifier {
  late Box<WatchlistStock> _box;
  List<WatchlistStock> _items = [];
  String? _selectedSymbol;
  bool _initialized = false;

  List<WatchlistStock> get items => _items;
  String? get selectedSymbol => _selectedSymbol;
  bool get initialized => _initialized;

  WatchlistStock? get selectedStock => _selectedSymbol != null
      ? _items.firstWhere((s) => s.symbol == _selectedSymbol, orElse: () => _items.first)
      : (_items.isNotEmpty ? _items.first : null);

  Future<void> init(AccountProvider? accountProvider) async {
    if (_initialized) return;
    
    _box = await Hive.openBox<WatchlistStock>('watchlist_box');
    _loadItems();
    
    if (_items.isNotEmpty) {
      _selectedSymbol = _items.first.symbol;
    }
    
    if (accountProvider != null) {
      syncWithHoldings(accountProvider);
    }

    _initialized = true;
    notifyListeners();
  }

  void selectStock(String symbol) {
    _selectedSymbol = symbol;
    notifyListeners();
  }

  void _loadItems() {
    _items = _box.values.toList();
    _items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  Future<void> addStock(String symbol, String name, {bool isHolding = false}) async {
    // 중복 체크
    if (_box.values.any((item) => item.symbol == symbol)) {
      return;
    }

    final newItem = WatchlistStock(symbol: symbol, name: name, isHolding: isHolding);
    await _box.add(newItem);
    _loadItems();
    notifyListeners();
  }

  Future<void> removeStock(String symbol) async {
    final key = _box.keys.firstWhere(
      (k) => _box.get(k)?.symbol == symbol,
      orElse: () => null,
    );
    
    if (key != null) {
      await _box.delete(key);
      _loadItems();
      notifyListeners();
    }
  }

  // AccountProvider의 보유 종목과 동기화
  void syncWithHoldings(AccountProvider accountProvider) {
    for (final stock in accountProvider.kiwoomStocks) {
      if (!_box.values.any((item) => item.symbol == stock.symbol)) {
        addStock(stock.symbol, stock.name, isHolding: true);
      }
    }
  }
}
