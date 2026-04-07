import 'package:aristock/shared/infra/kiwoom_api_client.dart';

/// 주문/매매 전용 서비스
class KiwoomTradingRepository {
  static const String trOrder = 'kt10000'; // 주식 주문 (매수/매도 공용 또는 매수)

  final KiwoomApiClient _client;

  KiwoomTradingRepository(this._client);

  /// 주식 매수 주문
  Future<KiwoomResponse> buyStock({
    required String stockCode,
    required String quantity,
    String price = '',
    String orderType = '01', // 01: 현금매수
    String tradeType = '00', // 00: 지정가
    String exchange = KiwoomApiClient.exchangeKrx,
  }) {
    return _client.callApi(
      endpoint: '/api/dostk/ordr',
      apiId: trOrder,
      params: {
        'dmst_stex_tp': exchange,
        'stk_cd': stockCode,
        'ord_qty': quantity,
        'ord_unpr': price,
        'ord_tp': orderType,
        'trde_tp': tradeType,
        'sll_buy_tp': '02', // 01: 매도, 02: 매수 (KIS 기준 관례)
      },
    );
  }

  /// 주식 매도 주문
  Future<KiwoomResponse> sellStock({
    required String stockCode,
    required String quantity,
    String price = '',
    String orderType = '01', // 01: 현금매도
    String tradeType = '00', // 00: 지정가
    String exchange = KiwoomApiClient.exchangeKrx,
  }) {
    return _client.callApi(
      endpoint: '/api/dostk/ordr',
      apiId: trOrder,
      params: {
        'dmst_stex_tp': exchange,
        'stk_cd': stockCode,
        'ord_qty': quantity,
        'ord_unpr': price,
        'ord_tp': orderType,
        'trde_tp': tradeType,
        'sll_buy_tp': '01', // 01: 매도, 02: 매수
      },
    );
  }
}
