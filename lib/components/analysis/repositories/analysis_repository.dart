import 'package:hive/hive.dart';
import '../models/analysis_model.dart';

class AnalysisRepository {
  static const String stockBoxName = 'analysis_stock_box';
  static const String logBoxName = 'analysis_log_box';

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

  // 분석 로그 관련
  Future<void> saveLog(AnalysisLog log) async {
    final box = await _openLogBox();
    // 키를 '종목_날짜' 형식으로 저장하여 고유성 확보
    await box.put('${log.symbol}_${log.date}', log);
  }

  Future<List<AnalysisLog>> getLogsByStock(String stockSymbol) async {
    final box = await _openLogBox();
    return box.values
        .where((log) => log.symbol == stockSymbol)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<AnalysisLog?> getLatestLog(String stockSymbol) async {
    final logs = await getLogsByStock(stockSymbol);
    return logs.isNotEmpty ? logs.first : null;
  }

  // 모든 분석 데이터 삭제 (내용 비우기)
  Future<void> clearAll() async {
    final sBox = await _openStockBox();
    final lBox = await _openLogBox();
    await sBox.clear();
    await lBox.clear();
  }

  // 데이터베이스 완전 삭제 (구조 변경 등으로 오류 발생 시 디스크에서 날림)
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
