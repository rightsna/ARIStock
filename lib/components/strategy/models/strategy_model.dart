import 'package:hive/hive.dart';

part 'strategy_model.g.dart';

@HiveType(typeId: 3)
class Strategy extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String content; // 마크다운 형식의 매매 전략

  Strategy({
    required this.symbol,
    required this.name,
    required this.content,
  });
}

@HiveType(typeId: 4)
class TradingLog extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String date;

  @HiveField(2)
  final String type; // 매수/매도

  @HiveField(3)
  final String price;

  @HiveField(4)
  final String quantity;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final String strategySnapshot; // 매매 당시의 매매 전략 전문

  @HiveField(7)
  final String? aiReason; // AI가 매매를 결정한 이유 (자동매매 시 활용)

  TradingLog({
    required this.symbol,
    required this.date,
    required this.type,
    required this.price,
    required this.quantity,
    required this.status,
    required this.strategySnapshot,
    this.aiReason,
  });
}
