import 'package:hive/hive.dart';
import '../models/stock_analysis_model.dart';

class AnalysisRepository {
  static const String analysisBoxName = 'analysis_record_v2'; // 통합된 새로운 박스

  Future<Box<StockAnalysis>> _openBox() async {
    return await Hive.openBox<StockAnalysis>(analysisBoxName);
  }

  // 분석 데이터 저장 (신규 종목 포함)
  Future<void> saveAnalysis(StockAnalysis analysis) async {
    final box = await _openBox();
    // 심볼을 키로 사용하여 종목당 항상 최신의 통합 리포트를 유지
    await box.put(analysis.symbol, analysis);
  }

  // 특정 종목의 분석 데이터 조회
  Future<StockAnalysis?> getAnalysis(String symbol) async {
    final box = await _openBox();
    return box.get(symbol);
  }

  // 모든 분석된 종목 리스트 조회
  Future<List<StockAnalysis>> getAllAnalyses() async {
    final box = await _openBox();
    return box.values.toList();
  }

  // 특정 종목 레코드 삭제
  Future<void> deleteAnalysis(String symbol) async {
    final box = await _openBox();
    await box.delete(symbol);
  }

  // 모든 데이터 초기화
  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }

  // 데이터베이스 완전 삭제
  Future<void> forceDeleteFromDisk() async {
    if (Hive.isBoxOpen(analysisBoxName)) {
      await Hive.box<StockAnalysis>(analysisBoxName).close();
    }
    await Hive.deleteBoxFromDisk(analysisBoxName);
  }
}
