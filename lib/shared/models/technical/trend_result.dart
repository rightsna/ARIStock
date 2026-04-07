import 'dart:math';
import '../market/candle.dart';

/// 추세 분석 결과 (선형 회귀 기반)
class TrendResult {
  final String direction; // "UP", "DOWN", "NEUTRAL"
  final double slope; // 기울기 (양수=상승, 음수=하락)
  final double strength; // 추세 강도 (0-1)

  TrendResult({
    required this.direction,
    required this.slope,
    required this.strength,
  });

  factory TrendResult.fromCandles(List<Candle> candles, {int period = 20}) {
    if (candles.length < 5) {
      return TrendResult(direction: 'NEUTRAL', slope: 0, strength: 0);
    }
    final window = candles.length > period
        ? candles.sublist(candles.length - period)
        : candles;
    final closePrices = window.map((c) => c.close).toList();

    // 선형 회귀 기울기 계산
    final n = closePrices.length.toDouble();
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;

    for (int i = 0; i < closePrices.length; i++) {
      sumX += i;
      sumY += closePrices[i];
      sumXY += i * closePrices[i];
      sumX2 += i * i;
    }

    final denominator = (n * sumX2) - (sumX * sumX);
    final slope =
        denominator == 0 ? 0.0 : ((n * sumXY) - (sumX * sumY)) / denominator;

    // R² (결정계수) 계산 - 추세 강도
    final mean = sumY / n;
    final ssTot = closePrices.fold<double>(
      0,
      (sum, p) => sum + pow(p - mean, 2).toDouble(),
    );
    final intercept = mean - (slope * (n - 1) / 2);
    final ssRes = closePrices.asMap().entries.fold<double>(0, (sum, entry) {
      final predicted = slope * entry.key + intercept;
      return sum + pow(entry.value - predicted, 2).toDouble();
    });
    final strength =
        ssTot == 0 ? 0.0 : (1 - (ssRes / ssTot)).clamp(0, 1).toDouble();

    String direction = 'NEUTRAL';
    if (slope > 0.5) direction = 'UP';
    if (slope < -0.5) direction = 'DOWN';

    return TrendResult(direction: direction, slope: slope, strength: strength);
  }

  Map<String, dynamic> toMap() => {
        'direction': direction,
        'slope': slope,
        'strength': strength,
      };
}
