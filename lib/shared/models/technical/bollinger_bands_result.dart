import 'dart:math';
import '../market/candle.dart';
import 'moving_average_result.dart';

/// Bollinger Bands 결과 및 계산
class BollingerBandsResult {
  final double upperBand;
  final double middleBand;
  final double lowerBand;
  final double bandwidthRatio;
  final bool isAtTop; // 종가가 상단에 가까움
  final bool isAtBottom; // 종가가 하단에 가까움
  final double squeeze; // 밴드폭 축소 정도 (0-1)

  BollingerBandsResult({
    required this.upperBand,
    required this.middleBand,
    required this.lowerBand,
    required double lastClose,
  })  : bandwidthRatio =
            middleBand == 0 ? 0 : (upperBand - lowerBand) / middleBand,
        isAtTop = lastClose > middleBand + (upperBand - middleBand) * 0.8,
        isAtBottom = lastClose < middleBand - (middleBand - lowerBand) * 0.8,
        squeeze = 1 /
            (1 + (middleBand == 0 ? 0 : (upperBand - lowerBand) / middleBand));

  factory BollingerBandsResult.fromCandles(
    List<Candle> candles, {
    int period = 20,
    double stdDev = 2.0,
  }) {
    final lastClose = candles.last.close;
    if (candles.length < period) {
      return BollingerBandsResult(
        upperBand: lastClose * 1.1,
        middleBand: lastClose,
        lowerBand: lastClose * 0.9,
        lastClose: lastClose,
      );
    }

    final closePrices = candles.map((c) => c.close).toList();
    final smaValues = MovingAverageResult.sma(closePrices, period);
    final middle = smaValues.lastWhere((s) => s != null) ?? lastClose;

    final lastWindow = closePrices.sublist(closePrices.length - period);
    final mean = lastWindow.reduce((a, b) => a + b) / period;
    final variance = lastWindow
            .map((p) => (p - mean) * (p - mean))
            .fold<double>(0, (a, b) => a + b) /
        period;
    final stdValue = variance.isNaN ? 0.0 : sqrt(variance);

    return BollingerBandsResult(
      upperBand: middle + (stdValue * stdDev),
      middleBand: middle,
      lowerBand: middle - (stdValue * stdDev),
      lastClose: lastClose,
    );
  }

  Map<String, dynamic> toMap() => {
        'upperBand': upperBand.isFinite ? upperBand : 0.0,
        'middleBand': middleBand.isFinite ? middleBand : 0.0,
        'lowerBand': lowerBand.isFinite ? lowerBand : 0.0,
        'bandwidthRatio': bandwidthRatio.isFinite ? bandwidthRatio : 0.0,
        'isAtTop': isAtTop,
        'isAtBottom': isAtBottom,
        'squeeze': squeeze.isFinite ? squeeze : 1.0,
      };
}
