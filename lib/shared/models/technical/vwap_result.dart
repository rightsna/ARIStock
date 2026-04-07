import '../market/candle.dart';

/// VWAP (Volume Weighted Average Price) 결과 및 계산
class VWAPResult {
  final double value;

  VWAPResult({required this.value});

  factory VWAPResult.fromCandles(List<Candle> candles) {
    if (candles.isEmpty) return VWAPResult(value: 0);

    double typicalPriceVolume = 0;
    int totalVolume = 0;

    for (final candle in candles) {
      final typicalPrice = (candle.high + candle.low + candle.close) / 3;
      typicalPriceVolume += typicalPrice * candle.volume;
      totalVolume += candle.volume;
    }

    return VWAPResult(
        value: totalVolume > 0 ? typicalPriceVolume / totalVolume : 0);
  }

  Map<String, dynamic> toMap() => {
        'value': value,
      };
}
