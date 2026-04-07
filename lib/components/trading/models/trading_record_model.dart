import 'package:hive/hive.dart';

part 'trading_record_model.g.dart';

@HiveType(typeId: 9)
class TradingRecord extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String date;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String side; // 'BUY' | 'SELL'

  @HiveField(4)
  final double quantity;

  @HiveField(5)
  final String reason;

  @HiveField(6)
  final String? createdAt;

  TradingRecord({
    required this.symbol,
    required this.date,
    required this.price,
    required this.side,
    required this.quantity,
    required this.reason,
    this.createdAt,
  });

  factory TradingRecord.fromMap(Map<String, dynamic> map) {
    return TradingRecord(
      symbol: map['symbol'] as String,
      date: map['date'] as String? ?? DateTime.now().toString().split(' ')[0],
      price: double.tryParse(map['price'].toString()) ?? 0.0,
      side: map['side'] as String? ?? 'BUY',
      quantity: double.tryParse(map['quantity'].toString()) ?? 1.0,
      reason: map['reason'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? DateTime.now().toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'symbol': symbol,
    'date': date,
    'price': price,
    'side': side,
    'quantity': quantity,
    'reason': reason,
    'createdAt': createdAt,
  };
}
