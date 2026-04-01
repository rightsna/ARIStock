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

  @HiveField(3)
  final List<double>? entryPrices;

  @HiveField(4)
  final List<double>? targetPrices;

  @HiveField(5)
  final double? stopLoss;

  TradingStrategy({
    required this.symbol,
    required this.content,
    required this.updatedAt,
    this.entryPrices,
    this.targetPrices,
    this.stopLoss,
  });

  factory TradingStrategy.fromMap(Map<String, dynamic> map) {
    return TradingStrategy(
      symbol: map['symbol'] as String,
      content: map['content'] as String,
      entryPrices: _toDoubleList(map['entryPrices']),
      targetPrices: _toDoubleList(map['targetPrices']),
      stopLoss: _toDouble(map['stopLoss']),
      updatedAt: map['updatedAt'] as String? ?? DateTime.now().toString().split(' ')[0],
    );
  }

  static List<double>? _toDoubleList(dynamic val) {
    if (val == null || val is! List) return null;
    return val.map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    return double.tryParse(val.toString());
  }

  Map<String, dynamic> toMap() => {
    'symbol': symbol,
    'content': content,
    'entryPrices': entryPrices,
    'targetPrices': targetPrices,
    'stopLoss': stopLoss,
    'updatedAt': updatedAt,
  };

  TradingStrategy copyWith({
    String? content,
    String? updatedAt,
    List<double>? entryPrices,
    List<double>? targetPrices,
    double? stopLoss,
  }) {
    return TradingStrategy(
      symbol: symbol,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      entryPrices: entryPrices ?? this.entryPrices,
      targetPrices: targetPrices ?? this.targetPrices,
      stopLoss: stopLoss ?? this.stopLoss,
    );
  }
}
