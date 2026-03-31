import 'package:hive/hive.dart';

part 'trading_strategy_model.g.dart';

@HiveType(typeId: 8)
class TradingStrategy extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String updatedAt;

  TradingStrategy({
    required this.symbol,
    required this.content,
    required this.updatedAt,
  });

  factory TradingStrategy.fromMap(Map<String, dynamic> map) {
    return TradingStrategy(
      symbol: map['symbol'] as String,
      content: map['content'] as String,
      updatedAt: map['updatedAt'] as String? ?? DateTime.now().toString().split(' ')[0],
    );
  }

  Map<String, dynamic> toMap() => {
    'symbol': symbol,
    'content': content,
    'updatedAt': updatedAt,
  };

  TradingStrategy copyWith({String? content, String? updatedAt}) {
    return TradingStrategy(
      symbol: symbol,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
