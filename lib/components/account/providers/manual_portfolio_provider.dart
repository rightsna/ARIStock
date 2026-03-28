import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/stock.dart';

/// 포트폴리오의 상태(종목 리스트, 총 자산 등)를 관리하는 클래스입니다.
class ManualPortfolioProvider with ChangeNotifier {
  static const String boxName = 'manual_portfolio_box';
  List<Stock> _stocks = [];

  List<Stock> get stocks => [..._stocks];

  Future<void> init() async {
    final box = await Hive.openBox<Stock>(boxName);
    _stocks = box.values.toList();
    notifyListeners();
  }

  // 총 자산 (현재가 기준)
  double get totalAssets => _stocks.fold(0, (sum, stock) => sum + stock.totalCurrentAmount);

  // 총 매수 금액
  double get totalInvestment => _stocks.fold(0, (sum, stock) => sum + stock.totalPurchaseAmount);

  // 전체 수익률
  double get totalProfitPercentage {
    if (totalInvestment == 0) return 0;
    return ((totalAssets - totalInvestment) / totalInvestment) * 100;
  }

  // 종목 추가
  Future<void> addStock(Stock stock) async {
    final box = await Hive.openBox<Stock>(boxName);
    await box.put(stock.id, stock);
    _stocks = box.values.toList();
    notifyListeners();
  }

  // 종목 삭제
  Future<void> removeStock(String id) async {
    final box = await Hive.openBox<Stock>(boxName);
    await box.delete(id);
    _stocks = box.values.toList();
    notifyListeners();
  }

  // 모든 종목 초기화
  Future<void> clearAll() async {
    final box = await Hive.openBox<Stock>(boxName);
    await box.clear();
    _stocks = [];
    notifyListeners();
  }
}
