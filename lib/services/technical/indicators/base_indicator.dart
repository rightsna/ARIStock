import '../../../models/market/candle.dart';

/// 모든 기술적 지표의 기본 추상 클래스
/// 각 지표는 이를 상속받아 calculate() 메서드 구현
abstract class BaseIndicator {
  /// 캔들 데이터 리스트를 받아 지표 값을 계산
  /// [candles]: 시간순 정렬된 OHLCV 데이터
  /// 반환: 지표별로 다양한 형태의 결과 (double, List, Map 등)
  dynamic calculate(List<Candle> candles);
}
