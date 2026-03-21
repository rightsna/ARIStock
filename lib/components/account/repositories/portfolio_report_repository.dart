import 'package:hive/hive.dart';
import '../models/portfolio_report_model.dart';

class PortfolioReportRepository {
  static const String boxName = 'portfolio_report_box';
  static const String latestKey = 'latest_report';

  Future<Box<PortfolioReport>> _openBox() async {
    return await Hive.openBox<PortfolioReport>(boxName);
  }

  // 최신 리포트 저장 (히스토리 없이 하나만 유지)
  Future<void> saveLatestReport(PortfolioReport report) async {
    final box = await _openBox();
    await box.put(latestKey, report);
  }

  // 최신 리포트 가져오기
  Future<PortfolioReport?> getLatestReport() async {
    final box = await _openBox();
    return box.get(latestKey);
  }

  // 리포트 삭제
  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
