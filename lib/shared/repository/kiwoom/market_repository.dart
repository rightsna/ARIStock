import 'package:aristock/shared/infra/kiwoom_api_client.dart';

/// 종목/시세 조회 전용 서비스
class KiwoomMarketRepository {
  static const String trStockQuote = 'ka10004';
  static const String trStockInfo = 'ka10001';
  static const String trTickChart = 'ka10079';
  static const String trMinuteChart = 'ka10080';
  static const String trDailyChart = 'ka10081';

  final KiwoomApiClient _client;

  KiwoomMarketRepository(this._client);

  Future<KiwoomResponse> getStockQuote({required String stockCode}) {
    return _client.callApi(
      endpoint: '/api/dostk/mrkcond',
      apiId: trStockQuote,
      params: {'stk_cd': stockCode},
    );
  }

  Future<KiwoomResponse> getStockInfo({required String stockCode}) {
    return _client.callApi(
      endpoint: '/api/dostk/stkinfo',
      apiId: trStockInfo,
      params: {'stk_cd': stockCode},
    );
  }

  Future<KiwoomResponse> getStockTickChart({
    required String stockCode,
    String ticScope = '1',
    String updatePriceType = '0',
    String contYn = 'N',
    String nextKey = '',
  }) {
    return _client.callApi(
      endpoint: '/api/dostk/chart',
      apiId: trTickChart,
      params: {
        'stk_cd': stockCode,
        'tic_scope': ticScope,
        'upd_stkpc_tp': updatePriceType,
        'dmst_stex_tp': KiwoomApiClient.exchangeKrx,
        'qry_tp': KiwoomApiClient.queryTypeDetail,
      },
      contYn: contYn,
      nextKey: nextKey,
    );
  }

  Future<KiwoomResponse> getStockMinuteChart({
    required String stockCode,
    String ticScope = '1',
    String updatePriceType = '0',
    String? baseDate,
    String contYn = 'N',
    String nextKey = '',
  }) {
    return _client.callApi(
      endpoint: '/api/dostk/chart',
      apiId: trMinuteChart,
      params: {
        'stk_cd': stockCode,
        'tic_scope': ticScope,
        'upd_stkpc_tp': updatePriceType,
        'dmst_stex_tp': KiwoomApiClient.exchangeKrx,
        'qry_tp': KiwoomApiClient.queryTypeDetail,
        if (baseDate != null && baseDate.isNotEmpty) 'base_dt': baseDate,
      },
      contYn: contYn,
      nextKey: nextKey,
    );
  }

  Future<KiwoomResponse> getStockDailyChart({
    required String stockCode,
    required String baseDate,
    String updatePriceType = '0',
    String contYn = 'N',
    String nextKey = '',
  }) {
    return _client.callApi(
      endpoint: '/api/dostk/chart',
      apiId: trDailyChart,
      params: {
        'stk_cd': stockCode,
        'base_dt': baseDate,
        'upd_stkpc_tp': updatePriceType,
        'dmst_stex_tp': KiwoomApiClient.exchangeKrx,
        'qry_tp': KiwoomApiClient.queryTypeDetail,
      },
      contYn: contYn,
      nextKey: nextKey,
    );
  }
}
