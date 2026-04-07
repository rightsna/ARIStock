import '../market/candle.dart';
import 'moving_average_result.dart';

/// ATR (Average True Range) 결과 - 변동성 계산
class ATRResult {
  final double value;
  final bool isHighVolatility; // 평년대비 높음

  ATRResult({required this.value, this.isHighVolatility = false});

  factory ATRResult.fromCandles(List<Candle> candles, {int period = 14}) {
    if (candles.length < period + 1) return ATRResult(value: 0);

    final trueRanges = <double>[];
    for (int i = 1; i < candles.length; i++) {
      trueRanges.add(
        candles[i].trueRangeFromPreviousClose(candles[i - 1].close),
      );
    }

    final smoothed = MovingAverageResult.sma(trueRanges, period);
    final atr = smoothed.lastWhere((v) => v != null, orElse: () => 0) ?? 0;

    return ATRResult(value: atr);
  }

  Map<String, dynamic> toMap() => {
        'value': value,
        'isHighVolatility': isHighVolatility,
      };
}
