import 'package:hive/hive.dart';

part 'stock.g.dart';

@HiveType(typeId: 6)
class Stock extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String symbol;      // 종목 코드 (예: AAPL)
  @HiveField(2)
  final String name;        // 종목명 (예: Apple Inc)
  @HiveField(3)
  final double quantity;    // 보유 수량
  @HiveField(4)
  final double purchasePrice; // 평균 단가
  @HiveField(5)
  double currentPrice;        // 현재가 (변동 가능)

  Stock({
    required this.id,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.purchasePrice,
    this.currentPrice = 0.0,
  });

  // 총 매수 금액
  double get totalPurchaseAmount => quantity * purchasePrice;
  
  // 현재 총 가치
  double get totalCurrentAmount => quantity * currentPrice;

  // 총 손익
  double get totalProfit => totalCurrentAmount - totalPurchaseAmount;

  // 수익률 (%)
  double get profitPercentage {
    if (purchasePrice == 0) return 0;
    return (totalProfit / totalPurchaseAmount) * 100;
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'currentPrice': currentPrice,
    };
  }
}

