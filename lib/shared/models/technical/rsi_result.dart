import '../market/candle.dart';

/// RSI (Relative Strength Index) 결과 및 계산
class RSIResult {
  final double value; // 0-100
  final bool isOverbought; // > 70
  final bool isOversold; // < 30

  RSIResult({required this.value})
      : isOverbought = value > 70,
        isOversold = value < 30;

  factory RSIResult.fromCandles(List<Candle> candles, {int period = 14}) {
    if (candles.length < period + 1) return RSIResult(value: 50);

    double gainSum = 0;
    double lossSum = 0;

    for (int i = 1; i <= period; i++) {
      final change = candles[i].close - candles[i - 1].close;
      if (change >= 0) {
        gainSum += change;
      } else {
        lossSum += -change;
      }
    }

    double averageGain = gainSum / period;
    double averageLoss = lossSum / period;

    for (int i = period + 1; i < candles.length; i++) {
      final change = candles[i].close - candles[i - 1].close;
      final gain = change > 0 ? change : 0.0;
      final loss = change < 0 ? -change : 0.0;
      averageGain = ((averageGain * (period - 1)) + gain) / period;
      averageLoss = ((averageLoss * (period - 1)) + loss) / period;
    }

    if (averageLoss == 0) return RSIResult(value: 100);
    final rs = averageGain / averageLoss;
    return RSIResult(value: 100 - (100 / (1 + rs)));
  }

  Map<String, dynamic> toMap() => {
        'value': value.isFinite ? value : 50.0,
        'isOverbought': isOverbought,
        'isOversold': isOversold,
      };
}
