/// OHLCV 캔들 데이터 모델
/// 모든 기술적 지표의 기반이 되는 표준화된 가격 데이터
class Candle {
  final DateTime timestamp;
  final double open;      // 시가
  final double high;      // 고가
  final double low;       // 저가
  final double close;     // 종가
  final int volume;       // 거래량

  Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  /// 캔들 몸통 크기 (종가 - 시가)
  double get bodySize => (close - open).abs();

  /// 상승 캔들 여부
  bool get isBullish => close >= open;

  /// 하락 캔들 여부
  bool get isBearish => close < open;

  /// 범위 (고가 - 저가)
  double get range => high - low;

  /// 이전 종가를 기준으로 계산한 True Range
  double trueRangeFromPreviousClose(double previousClose) {
    final highLow = high - low;
    final highClose = (high - previousClose).abs();
    final lowClose = (low - previousClose).abs();
    return [highLow, highClose, lowClose].reduce((a, b) => a > b ? a : b);
  }

  /// 종가가 범위에서 차지하는 비율 (0~1)
  double get closeRatio {
    if (range == 0) return 0.5;
    return (close - low) / range;
  }

  /// 맵으로 변환 (JSON 직렬화용)
  Map<String, dynamic> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': volume,
      };

  /// 맵에서 생성
  factory Candle.fromMap(Map<String, dynamic> map) {
    return Candle(
      timestamp: DateTime.parse(map['timestamp'] as String? ?? DateTime.now().toIso8601String()),
      open: (map['open'] as num).toDouble(),
      high: (map['high'] as num).toDouble(),
      low: (map['low'] as num).toDouble(),
      close: (map['close'] as num).toDouble(),
      volume: map['volume'] as int? ?? 0,
    );
  }
}
