import 'package:hive/hive.dart';

part 'portfolio_report_model.g.dart';

@HiveType(typeId: 5)
class PortfolioReport extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final String content; // 마크다운 분석 리포트

  PortfolioReport({
    required this.date,
    required this.content,
  });
}
