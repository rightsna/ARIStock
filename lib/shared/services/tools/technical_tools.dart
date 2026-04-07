import '../../models/market/market_timeframe.dart';
import '../../repository/kiwoom/market_data_repository.dart';
import '../../models/market/candle.dart';
import '../../models/technical/moving_average_result.dart';
import '../../models/technical/rsi_result.dart';
import '../../models/technical/macd_result.dart';
import '../../models/technical/bollinger_bands_result.dart';
import '../../models/technical/atr_result.dart';
import '../../models/technical/vwap_result.dart';
import '../../models/technical/volume_analysis_result.dart';
import '../../models/technical/trend_result.dart';

/// 에이전트(AI)가 웹소켓 프로토콜을 통해 호출할 수 있는 기술적 분석 도구 세트
class TechnicalTools {
  final KiwoomMarketDataRepository _marketDataService;

  TechnicalTools(this._marketDataService);

  /// 에이전트 전용 통합 도구: 데이터 조회부터 지표 계산까지 한 번에 처리
  Future<Map<String, dynamic>> analyzeStockIndicator({
    required String symbol,
    required MarketTimeframe timeframe,
    required int limit,
    required String indicatorType,
    Map<String, dynamic> params = const {},
  }) async {
    // 1. 시장 데이터 서비스에서 캔들 조회 (내부에서 처리)
    final candles = await _marketDataService.fetchCandles(
      symbol: symbol,
      timeframe: timeframe,
      limit: limit,
    );

    // 2. 조회된 데이터를 기반으로 지표 계산
    return calculate(
      candles: candles,
      indicatorType: indicatorType,
      params: params,
    );
  }

  /// 요청된 지표 타입에 따라 계산을 수행하고 결과를 반환합니다.
  static Map<String, dynamic> calculate({
    required List<Candle> candles,
    required String indicatorType,
    Map<String, dynamic> params = const {},
  }) {
    if (candles.isEmpty) {
      throw ArgumentError('Candles list is empty');
    }

    final type = indicatorType.toLowerCase().trim();

    switch (type) {
      case 'ma':
      case 'moving_average':
        final periods = _readIntList(params, 'periods', [20, 50, 200]);
        return MovingAverageResult.fromCandles(
          candles,
          periods: periods,
        ).toMap();

      case 'rsi':
        final period = _readInt(params, 'period', 14);
        return RSIResult.fromCandles(candles, period: period).toMap();

      case 'macd':
        final fast = _readInt(params, 'fastPeriod', 12);
        final slow = _readInt(params, 'slowPeriod', 26);
        final signal = _readInt(params, 'signalPeriod', 9);
        return MacdResult.fromCandles(
          candles,
          fastPeriod: fast,
          slowPeriod: slow,
          signalPeriod: signal,
        ).toMap();

      case 'bollinger':
      case 'bollinger_bands':
        final period = _readInt(params, 'period', 20);
        final stdDev = _readDouble(params, 'stdDev', 2.0);
        return BollingerBandsResult.fromCandles(
          candles,
          period: period,
          stdDev: stdDev,
        ).toMap();

      case 'atr':
        final period = _readInt(params, 'period', 14);
        return ATRResult.fromCandles(candles, period: period).toMap();

      case 'vwap':
        return VWAPResult.fromCandles(candles).toMap();

      case 'volume':
      case 'volume_analysis':
        final period = _readInt(params, 'period', 20);
        return VolumeAnalysisResult.fromCandles(
          candles,
          period: period,
        ).toMap();

      case 'trend':
        final period = _readInt(params, 'period', 20);
        return TrendResult.fromCandles(candles, period: period).toMap();

      default:
        throw ArgumentError('Unsupported indicator type: $indicatorType');
    }
  }

  /// 헬퍼: 정수 파라미터 읽기
  static int _readInt(Map<String, dynamic> params, String key, int fallback) {
    final val = params[key];
    if (val is int) return val;
    return int.tryParse(val?.toString() ?? '') ?? fallback;
  }

  /// 헬퍼: 실수 파라미터 읽기
  static double _readDouble(
    Map<String, dynamic> params,
    String key,
    double fallback,
  ) {
    final val = params[key];
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val?.toString() ?? '') ?? fallback;
  }

  /// 헬퍼: 정수 리스트 읽기
  static List<int> _readIntList(
    Map<String, dynamic> params,
    String key,
    List<int> fallback,
  ) {
    final val = params[key];
    if (val is List) {
      return val
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((e) => e > 0)
          .toList();
    }
    return fallback;
  }
}
