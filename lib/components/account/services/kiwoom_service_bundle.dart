import 'kiwoom_account_service.dart';
import 'kiwoom_api_client.dart';
import 'kiwoom_market_service.dart';
import 'kiwoom_trading_service.dart';

/// 키움 관련 서비스들을 같은 클라이언트 기반으로 묶어 제공한다.
class KiwoomServiceBundle {
  final KiwoomApiClient client;
  final KiwoomAccountService account;
  final KiwoomMarketService market;
  final KiwoomTradingService trading;

  KiwoomServiceBundle._({
    required this.client,
    required this.account,
    required this.market,
    required this.trading,
  });

  factory KiwoomServiceBundle({
    KiwoomApiClient? client,
  }) {
    final sharedClient = client ?? KiwoomApiClient();
    return KiwoomServiceBundle._(
      client: sharedClient,
      account: KiwoomAccountService(sharedClient),
      market: KiwoomMarketService(sharedClient),
      trading: KiwoomTradingService(sharedClient),
    );
  }
}
