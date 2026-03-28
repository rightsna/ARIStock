import '../market/candle.dart';

/// 이동평균 결과 (SMA, EMA 계산 로직 포함)
class MovingAverageResult {
  final Map<int, double> values; // {기간: 값}

  MovingAverageResult({required this.values});

  /// 캔들 리스트로부터 이동평균 생성
  factory MovingAverageResult.fromCandles(
    List<Candle> candles, {
    List<int> periods = const [20, 50, 200],
  }) {
    final closePrices = candles.map((c) => c.close).toList();
    final maValues = <int, double>{};

    for (final period in periods) {
      final smaValues = sma(closePrices, period);
      final lastValue =
          smaValues.lastWhere((s) => s != null, orElse: () => null);
      if (lastValue != null) {
        maValues[period] = lastValue;
      }
    }

    return MovingAverageResult(values: maValues);
  }


  /// 단순 이동평균 (SMA)
  static List<double?> sma(List<double> prices, int period) {
    if (prices.length < period) return List.filled(prices.length, null);
    final result = List<double?>.filled(prices.length, null);
    for (int i = period - 1; i < prices.length; i++) {
      final sum =
          prices.sublist(i - period + 1, i + 1).fold<double>(0, (a, b) => a + b);
      result[i] = sum / period;
    }
    return result;
  }

  /// 지수 이동평균 (EMA)
  static List<double?> ema(List<double> prices, int period) {
    if (prices.length < period) return List.filled(prices.length, null);
    final result = List<double?>.filled(prices.length, null);
    final multiplier = 2.0 / (period + 1);
    double emaValue =
        prices.sublist(0, period).fold<double>(0, (a, b) => a + b) / period;
    result[period - 1] = emaValue;
    for (int i = period; i < prices.length; i++) {
      emaValue = prices[i] * multiplier + emaValue * (1 - multiplier);
      result[i] = emaValue;
    }
    return result;
  }

  /// 특정 기간의 이동평균 값
  double? get(int period) => values[period];

  Map<String, dynamic> toMap() => {
        'values': values.map((k, v) => MapEntry(k.toString(), v)),
      };
}
