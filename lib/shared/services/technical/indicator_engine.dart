import '../../models/market/candle.dart';
import 'analyzer/stock_analysis_result.dart';
import 'analyzer/technical_analyzer.dart';
import 'indicators/momentum.dart';
import 'indicators/moving_average.dart';
import 'indicators/trend.dart';
import 'indicators/volatility.dart';
import 'indicators/volume.dart';

/// 에이전트가 전략에 맞춰 조합할 수 있는 원자 지표 계산 엔진
class IndicatorEngine {
  static Map<String, dynamic> calculateAtomic({
    required List<Candle> candles,
    required List<Map<String, dynamic>> indicators,
  }) {
    if (candles.isEmpty) {
      throw ArgumentError('Candles list is empty');
    }

    final result = <String, dynamic>{
      'price': candles.last.close,
      'timestamp': candles.last.timestamp.toIso8601String(),
      'candleCount': candles.length,
    };

    for (final indicator in indicators) {
      final type = (indicator['type'] ?? '').toString().trim().toLowerCase();
      final key = (indicator['key'] ?? type).toString();
      final params = Map<String, dynamic>.from(
        indicator['params'] as Map? ?? const <String, dynamic>{},
      );

      result[key] = _calculateSingle(
        candles: candles,
        type: type,
        params: params,
      );
    }

    return result;
  }

  static Future<Map<String, dynamic>> calculateStrategySnapshot({
    required String symbol,
    required List<Candle> candles,
  }) async {
    final analysis = await TechnicalAnalyzer.analyze(symbol: symbol, candles: candles);
    return _toStrategySnapshot(analysis);
  }

  static Map<String, dynamic> _calculateSingle({
    required List<Candle> candles,
    required String type,
    required Map<String, dynamic> params,
  }) {
    final closePrices = candles.map((c) => c.close).toList();

    switch (type) {
      case 'sma':
      case 'ma':
        final period = _readInt(params, 'period', 20);
        return _lastValue(MovingAverage.sma(closePrices, period), period);
      case 'ema':
        final period = _readInt(params, 'period', 20);
        return _lastValue(MovingAverage.ema(closePrices, period), period);
      case 'rsi':
        final period = _readInt(params, 'period', 14);
        return RelativeStrengthIndex(period: period).calculate(candles).toMap();
      case 'macd':
        final fastPeriod = _readInt(params, 'fastPeriod', 12);
        final slowPeriod = _readInt(params, 'slowPeriod', 26);
        final signalPeriod = _readInt(params, 'signalPeriod', 9);
        return MACD(
          fastPeriod: fastPeriod,
          slowPeriod: slowPeriod,
          signalPeriod: signalPeriod,
        ).calculate(candles).toMap();
      case 'bollinger':
      case 'bollinger_bands':
        final period = _readInt(params, 'period', 20);
        final stdDev = _readDouble(params, 'stdDev', 2.0);
        return BollingerBands(period: period, stdDev: stdDev).calculate(candles).toMap();
      case 'atr':
        final period = _readInt(params, 'period', 14);
        return AverageTrueRange(period: period).calculate(candles).toMap();
      case 'volume_ratio':
      case 'volume':
        final period = _readInt(params, 'period', 20);
        return VolumeAnalyzer(period: period).calculate(candles).toMap();
      case 'trend':
        final period = _readInt(params, 'period', 20);
        return TrendAnalyzer(period: period).calculate(candles).toMap();
      case 'vwap':
        return {
          'value': VolumeWeightedAveragePrice().calculate(candles),
        };
      case 'price_change':
        final lookback = _readInt(params, 'lookback', 1);
        if (candles.length <= lookback) {
          return {
            'lookback': lookback,
            'value': 0.0,
            'percent': 0.0,
          };
        }
        final previous = candles[candles.length - 1 - lookback].close;
        final current = candles.last.close;
        return {
          'lookback': lookback,
          'value': current - previous,
          'percent': previous == 0 ? 0.0 : ((current - previous) / previous) * 100,
        };
      default:
        throw ArgumentError('Unsupported indicator type: $type');
    }
  }

  static Map<String, dynamic> _lastValue(List<double?> series, int period) {
    final value = series.lastWhere((entry) => entry != null, orElse: () => null);
    return {
      'period': period,
      'value': value,
    };
  }

  static Map<String, dynamic> _toStrategySnapshot(StockAnalysisResult analysis) {
    return {
      'symbol': analysis.symbol,
      'timestamp': analysis.timestamp.toIso8601String(),
      'lastCandle': analysis.lastCandle.toMap(),
      'movingAverages': analysis.movingAverages.toMap(),
      'rsi': analysis.rsi.toMap(),
      'macd': analysis.macd.toMap(),
      'atr': analysis.atr.toMap(),
      'bollingerBands': analysis.bollingerBands.toMap(),
      'volumeAnalysis': analysis.volumeAnalysis.toMap(),
      'trend': analysis.trend.toMap(),
      'tradingSignalScore': analysis.tradingSignalScore,
      'tradingSignalText': analysis.tradingSignalText,
      'warningSignals': analysis.warningSignals,
    };
  }

  static int _readInt(Map<String, dynamic> params, String key, int fallback) {
    final value = params[key];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _readDouble(Map<String, dynamic> params, String key, double fallback) {
    final value = params[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
