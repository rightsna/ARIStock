import '../../../models/market/candle.dart';
import 'base_indicator.dart';

/// 이동평균 지표 (이동평균은 다른 지표의 기반이 되므로 static 메서드 제공)
class MovingAverage extends BaseIndicator {
  final int period;

  MovingAverage({this.period = 20});

  /// 단순 이동평균 (SMA - Simple Moving Average)
  /// 기간 내 종가의 단순 평균
  static List<double?> sma(List<double> prices, int period) {
    if (prices.length < period) return List.filled(prices.length, null);

    final result = List<double?>.filled(prices.length, null);
    for (int i = period - 1; i < prices.length; i++) {
      final sum = prices.sublist(i - period + 1, i + 1).fold<double>(0, (a, b) => a + b);
      result[i] = sum / period;
    }
    return result;
  }

  /// 지수 이동평균 (EMA - Exponential Moving Average)
  /// 최근 데이터에 더 큰 가중치를 줌
  static List<double?> ema(List<double> prices, int period) {
    if (prices.length < period) return List.filled(prices.length, null);

    final result = List<double?>.filled(prices.length, null);
    final multiplier = 2.0 / (period + 1);

    // 초기값: 첫 SMA
    double emaValue = prices.sublist(0, period).fold<double>(0, (a, b) => a + b) / period;
    result[period - 1] = emaValue;

    // 나머지는 지수 가중치 적용
    for (int i = period; i < prices.length; i++) {
      emaValue = prices[i] * multiplier + emaValue * (1 - multiplier);
      result[i] = emaValue;
    }

    return result;
  }

  /// 가중 이동평균 (WMA - Weighted Moving Average)
  /// 최근 데이터에 선형으로 가중치 증가
  static List<double?> wma(List<double> prices, int period) {
    if (prices.length < period) return List.filled(prices.length, null);

    final result = List<double?>.filled(prices.length, null);
    final weights = List<double>.generate(period, (i) => i + 1); // 1, 2, 3, ..., period
    final weightSum = weights.fold<double>(0, (a, b) => a + b);

    for (int i = period - 1; i < prices.length; i++) {
      final windowPrices = prices.sublist(i - period + 1, i + 1);
      double weightedSum = 0;
      for (int j = 0; j < period; j++) {
        weightedSum += windowPrices[j] * weights[j];
      }
      result[i] = weightedSum / weightSum;
    }
    return result;
  }

  /// 여러 기간의 이동평균을 한 번에 계산
  static Map<int, List<double?>> multipleMA(List<double> prices, List<int> periods) {
    final result = <int, List<double?>>{};
    for (final period in periods) {
      result[period] = sma(prices, period);
    }
    return result;
  }

  @override
  List<double?> calculate(List<Candle> candles) {
    final closePrices = candles.map((c) => c.close).toList();
    return sma(closePrices, period);
  }
}
