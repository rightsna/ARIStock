import '../market/candle.dart';
import 'moving_average_result.dart';

/// MACD 결과 및 계산
class MacdResult {
  final double macdLine;
  final double signalLine;
  final double histogram; // MACD - Signal
  final bool isBullish; // MACD > Signal

  MacdResult({required this.macdLine, required this.signalLine})
      : histogram = macdLine - signalLine,
        isBullish = macdLine > signalLine;

  factory MacdResult.fromCandles(
    List<Candle> candles, {
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) {
    if (candles.length < slowPeriod + signalPeriod - 1) {
      return MacdResult(macdLine: 0, signalLine: 0);
    }

    final closePrices = candles.map((c) => c.close).toList();
    final fastEMA = MovingAverageResult.ema(closePrices, fastPeriod);
    final slowEMA = MovingAverageResult.ema(closePrices, slowPeriod);

    final macdLineSeries = <double?>[];
    for (int i = 0; i < fastEMA.length; i++) {
      if (fastEMA[i] != null && slowEMA[i] != null) {
        macdLineSeries.add(fastEMA[i]! - slowEMA[i]!);
      } else {
        macdLineSeries.add(null);
      }
    }

    final macdValues = macdLineSeries.whereType<double>().toList();
    final signalSeries = MovingAverageResult.ema(macdValues, signalPeriod);

    final lastMacd =
        macdLineSeries.lastWhere((v) => v != null, orElse: () => 0) ?? 0;
    final lastSignal =
        signalSeries.lastWhere((v) => v != null, orElse: () => 0) ?? 0;

    return MacdResult(macdLine: lastMacd, signalLine: lastSignal);
  }

  Map<String, dynamic> toMap() => {
        'macdLine': macdLine,
        'signalLine': signalLine,
        'histogram': histogram,
        'isBullish': isBullish,
      };
}
