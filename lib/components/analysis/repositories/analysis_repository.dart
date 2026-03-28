import 'package:hive/hive.dart';
import '../models/analysis_model.dart';

class AnalysisRepository {
  static const String stockBoxName = 'analysis_stock_box';
  static const String logBoxName = 'analysis_log_box_v1'; // 단일 로그 체계로 변경된 새로운 박스

  Future<Box<AnalysisStock>> _openStockBox() async {
    return await Hive.openBox<AnalysisStock>(stockBoxName);
  }

  Future<Box<AnalysisLog>> _openLogBox() async {
    return await Hive.openBox<AnalysisLog>(logBoxName);
  }

  // 분석 종목 리스트 관련
  Future<void> addStock(AnalysisStock stock) async {
    final box = await _openStockBox();
    await box.put(stock.symbol, stock);
  }

  Future<List<AnalysisStock>> getAllStocks() async {
    final box = await _openStockBox();
    return box.values.toList();
  }

  // 분석 로그 관련 (1종목 1로그 체제)
  Future<void> saveLog(AnalysisLog log) async {
    final box = await _openLogBox();
    // 심볼을 키로 사용하여 종목당 항상 최신의 단일 리포트(타임라인 포함)를 유지
    await box.put(log.symbol, log);
  }

  Future<AnalysisLog?> getLogByStock(String stockSymbol) async {
    final box = await _openLogBox();
    return box.get(stockSymbol);
  }

  // 특정 데이터 삭제
  Future<void> deleteStockRecord(String symbol) async {
    final sBox = await _openStockBox();
    final lBox = await _openLogBox();
    await sBox.delete(symbol);
    await lBox.delete(symbol);
  }

  // 모든 분석 데이터 삭제
  Future<void> clearAll() async {
    final sBox = await _openStockBox();
    final lBox = await _openLogBox();
    await sBox.clear();
    await lBox.clear();
  }

  // 데이터베이스 완전 삭제
  Future<void> forceDeleteFromDisk() async {
    if (Hive.isBoxOpen(stockBoxName)) {
      await Hive.box<AnalysisStock>(stockBoxName).close();
    }
    if (Hive.isBoxOpen(logBoxName)) {
      await Hive.box<AnalysisLog>(logBoxName).close();
    }
    await Hive.deleteBoxFromDisk(stockBoxName);
    await Hive.deleteBoxFromDisk(logBoxName);
  }
}
