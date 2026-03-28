import 'package:aristock/shared/infra/kiwoom/api_client.dart';

/// 주문/매매 전용 서비스
class KiwoomTradingRepository {
  static const String trBuyOrder = 'kt10000';

  final KiwoomApiClient _client;

  KiwoomTradingRepository(this._client);

  Future<KiwoomResponse> buyStock({
    required String stockCode,
    required String quantity,
    String price = '',
    String tradeType = '3',
    String exchange = KiwoomApiClient.exchangeKrx,
  }) {
    return _client.callApi(
      endpoint: '/api/dostk/ordr',
      apiId: trBuyOrder,
      params: {
        'dmst_stex_tp': exchange,
        'stk_cd': stockCode,
        'ord_qty': quantity,
        'ord_uv': price,
        'trde_tp': tradeType,
      },
    );
  }
}
