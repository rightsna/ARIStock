import '../../../models/market/candle.dart';
import '../../../models/technical/indicator_results.dart';
import 'base_indicator.dart';
import 'moving_average.dart';

/// RSI (Relative Strength Index) - 모멘텀 지표
/// 가격의 상승과 하락의 강도를 측정 (0-100)
class RelativeStrengthIndex extends BaseIndicator {
  final int period;

  RelativeStrengthIndex({this.period = 14});

  @override
  RSIResult calculate(List<Candle> candles) {
    final values = calculateAll(candles);
    final lastValue = values.lastWhere((value) => value != null, orElse: () => 50);
    return RSIResult(value: lastValue ?? 50);
  }

  /// 모든 RSI 값을 반환 (List)
  List<double?> calculateAll(List<Candle> candles) {
    if (candles.length < period + 1) {
      return List.filled(candles.length, null);
    }

    final result = List<double?>.filled(candles.length, null);
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
    result[period] = _calculateRsiValue(averageGain, averageLoss);

    for (int i = period + 1; i < candles.length; i++) {
      final change = candles[i].close - candles[i - 1].close;
      final gain = change > 0 ? change : 0.0;
      final loss = change < 0 ? -change : 0.0;

      averageGain = ((averageGain * (period - 1)) + gain) / period;
      averageLoss = ((averageLoss * (period - 1)) + loss) / period;
      result[i] = _calculateRsiValue(averageGain, averageLoss);
    }

    return result;
  }

  double _calculateRsiValue(double averageGain, double averageLoss) {
    if (averageLoss == 0) return 100;
    final rs = averageGain / averageLoss;
    return 100 - (100 / (1 + rs));
  }
}

/// MACD (Moving Average Convergence Divergence) - 모멘텀 지표
/// 빠른 EMA와 느린 EMA의 차이로 추세 찾기
class MACD extends BaseIndicator {
  final int fastPeriod;
  final int slowPeriod;
  final int signalPeriod;

  MACD({
    this.fastPeriod = 12,
    this.slowPeriod = 26,
    this.signalPeriod = 9,
  });

  @override
  MacdResult calculate(List<Candle> candles) {
    if (candles.length < slowPeriod + signalPeriod - 1) {
      return MacdResult(macdLine: 0, signalLine: 0);
    }

    final series = calculateAll(candles);
    final macdValue = series['macd']!.lastWhere((value) => value != null, orElse: () => 0) ?? 0;
    final signalLine = series['signal']!.lastWhere((value) => value != null, orElse: () => 0) ?? 0;

    return MacdResult(
      macdLine: macdValue,
      signalLine: signalLine,
    );
  }

  /// 모든 MACD 값을 반환
  Map<String, List<double?>> calculateAll(List<Candle> candles) {
    final closePrices = candles.map((c) => c.close).toList();

    final fastEMA = MovingAverage.ema(closePrices, fastPeriod);
    final slowEMA = MovingAverage.ema(closePrices, slowPeriod);

    // MACD 계산
    final macdLine = <double?>[];
    for (int i = 0; i < fastEMA.length; i++) {
      if (fastEMA[i] != null && slowEMA[i] != null) {
        macdLine.add(fastEMA[i]! - slowEMA[i]!);
      } else {
        macdLine.add(null);
      }
    }

    // Signal 계산
    final macdValues = macdLine.whereType<double>().toList();
    final rawSignalSeries = MovingAverage.ema(macdValues, signalPeriod);
    final signalLine = List<double?>.filled(macdLine.length, null);
    int signalIndex = 0;

    for (int i = 0; i < macdLine.length; i++) {
      if (macdLine[i] == null) {
        continue;
      }
      if (signalIndex < rawSignalSeries.length) {
        signalLine[i] = rawSignalSeries[signalIndex];
      }
      signalIndex++;
    }

    // Histogram = MACD - Signal
    final histogram = <double?>[];
    for (int i = 0; i < macdLine.length; i++) {
      if (macdLine[i] != null && signalLine[i] != null) {
        histogram.add(macdLine[i]! - signalLine[i]!);
      } else {
        histogram.add(null);
      }
    }

    return {
      'macd': macdLine,
      'signal': signalLine,
      'histogram': histogram,
    };
  }
}

/// Stochastic Oscillator - 모멘텀 지표
/// 현재 종가가 기간 내 최고/최저 범위에서 어디에 위치하는지 측정 (0-100)
class StochasticOscillator extends BaseIndicator {
  final int period;
  final int smoothK;
  final int smoothD;

  StochasticOscillator({
    this.period = 14,
    this.smoothK = 3,
    this.smoothD = 3,
  });

  @override
  List<double?> calculate(List<Candle> candles) {
    if (candles.length < period) {
      return List.filled(candles.length, null);
    }

    final result = List<double?>.filled(candles.length, null);

    // 1. %K 계산
    final percentK = <double?>[];
    for (int i = period - 1; i < candles.length; i++) {
      final window = candles.sublist(i - period + 1, i + 1);
      final high = window.map((c) => c.high).reduce((a, b) => a > b ? a : b);
      final low = window.map((c) => c.low).reduce((a, b) => a < b ? a : b);
      final close = candles[i].close;

      final k = high == low ? 50.0 : (close - low) / (high - low) * 100;
      percentK.add(k);
    }

    // 2. %K를 smoothing (일반적으로 3일 SMA)
    final smoothedK = MovingAverage.sma(percentK.whereType<double>().toList(), smoothK);
    for (int i = 0; i < smoothedK.length; i++) {
      result[period - 1 + i] = smoothedK[i];
    }

    return result;
  }
}
