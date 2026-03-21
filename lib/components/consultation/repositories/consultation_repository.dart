import 'package:hive/hive.dart';
import '../models/consultation_model.dart';

class ConsultationRepository {
  static const String stockBoxName = 'consultation_stock_box';
  static const String logBoxName = 'consultation_log_box';

  Future<Box<ConsultationStock>> _openStockBox() async {
    return await Hive.openBox<ConsultationStock>(stockBoxName);
  }

  Future<Box<ConsultationLog>> _openLogBox() async {
    return await Hive.openBox<ConsultationLog>(logBoxName);
  }

  // 상담 종목 리스트 관련
  Future<void> addStock(ConsultationStock stock) async {
    final box = await _openStockBox();
    await box.put(stock.symbol, stock);
  }

  Future<List<ConsultationStock>> getAllStocks() async {
    final box = await _openStockBox();
    return box.values.toList();
  }

  // 상담 로그 관련
  Future<void> saveLog(ConsultationLog log) async {
    final box = await _openLogBox();
    // 키를 '종목_날짜' 형식으로 저장하여 고유성 확보
    await box.put('${log.stockSymbol}_${log.date}', log);
  }

  Future<List<ConsultationLog>> getLogsByStock(String stockSymbol) async {
    final box = await _openLogBox();
    return box.values
        .where((log) => log.stockSymbol == stockSymbol)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<ConsultationLog?> getLatestLog(String stockSymbol) async {
    final logs = await getLogsByStock(stockSymbol);
    return logs.isNotEmpty ? logs.first : null;
  }

  // 모든 상담 데이터 삭제
  Future<void> clearAll() async {
    final sBox = await _openStockBox();
    final lBox = await _openLogBox();
    await sBox.clear();
    await lBox.clear();
  }
}
