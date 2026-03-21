import 'package:hive/hive.dart';

part 'consultation_model.g.dart';

@HiveType(typeId: 1)
class ConsultationStock extends HiveObject {
  @HiveField(0)
  final String symbol; // 종목 코드 또는 심볼

  @HiveField(1)
  final String name; // 종목 이름

  ConsultationStock({
    required this.symbol,
    required this.name,
  });
}

@HiveType(typeId: 2)
class ConsultationLog extends HiveObject {
  @HiveField(0)
  final String stockSymbol; // 연결된 종목 심볼

  @HiveField(1)
  final String date; // 상담 일자 (YYYY-MM-DD)

  @HiveField(2)
  final String content; // 마크다운 상담 내용

  ConsultationLog({
    required this.stockSymbol,
    required this.date,
    required this.content,
  });
}
