# ARI Plugins Skill: ARIStock

## Overview
`aristock`는 투자 분석 기록과 시장 데이터 조회를 함께 제공하는 ARI 플러그인입니다.

### App ID
`aristock`

## Execution Modes
- **GUI Mode (Default)**: Opens the full stock analysis dashboard.
- **Headless Mode (`--headless`)**: Runs as a background service without a UI window. Ideal for AI-driven background tasks and data collection.
  - Run command: `open -a ARIStock --args --headless` or `flutter run -d macos --args "--headless"`

## State
가벼운 상태 스냅샷입니다. 상세 정보는 `GET_*` 커맨드로 조회하십시오.

- `isApiConnected`
- `totalAssets`
- `profitPercentage`
- `stockCount`
- `selectedStock`
- `hasBriefingToday`
- `hasLatestReport`

## Market Data Rules
- 지원 시간프레임: `tick`, `1m`, `3m`, `5m`, `10m`, `15m`, `30m`, `45m`, `60m`, `1d`
- candle 응답 필드: `timestamp`, `open`, `high`, `low`, `close`, `volume`
- tick 응답 필드: `timestamp`, `price`, `volume`

## Commands

### GET
- `GET_ACCOUNT_INFO`
  - 최신 계좌 정보 반환
  - 응답: `stocks`, `deposit`, `totalAssets`, `profitPercentage`
- `GET_BRIEFING`
  - 오늘 브리핑 본문 반환
- `GET_ANALYSIS`
  - 현재 선택 종목 분석 기록 반환
- `GET_PORTFOLIO_REPORT`
  - 최신 포트폴리오 리포트 반환
- `GET_MARKET_DATA`
  - Params: `symbol`, `timeframe`, `limit?`
  - 응답: `candles` 또는 `ticks`
- `GET_TRADING_CONTEXT`
  - Params: `symbol`, `timeframe`, `limit?`
  - 응답: `lastCandle`, `movingAverages`, `rsi`, `macd`, `atr`, `bollingerBands`, `volumeAnalysis`, `trend`, `tradingSignalScore`, `tradingSignalText`, `warningSignals`
- `GET_APP_STATUS`
  - 현재 앱의 실행 모드(GUI/Headless)와 버전 정보 확인

### ANALYZE
- `CALCULATE_INDICATORS`
  - Params: `symbol`, `timeframe`, `limit?`, `indicators?`
  - 지원 지표 타입: `sma`, `ma`, `ema`, `rsi`, `macd`, `bollinger`, `atr`, `volume`, `volume_ratio`, `trend`, `vwap`, `price_change`
  - `indicators` 형식:
```json
[
  {"type":"ema","key":"ema20","params":{"period":20}},
  {"type":"rsi","key":"rsi14","params":{"period":14}},
  {"type":"macd","key":"macd"}
]
```

### REFRESH
- `REFRESH_ALL`
- `CLEAR_DATABASE`

### SAVE
- `SAVE_BRIEFING`
  - Params: `content`
- `SAVE_ANALYSIS`
  - Params: `symbol`, `name`, `content`
- `SAVE_STRATEGY`
  - Params: `symbol`, `name`, `content`
- `SAVE_PORTFOLIO_REPORT`
  - Params: `content`

## Writing Rules
- 저장용 `content`는 Markdown으로 작성하십시오.
- 제목, 목록, 표를 적절히 사용하되 과하게 꾸미지 마십시오.
- 이모지는 필수 아닙니다. 필요할 때만 최소한으로 사용하십시오.

## Recommended Use
1. 먼저 State 확인
2. 계좌 정보가 필요하면 `GET_ACCOUNT_INFO`
3. 시계열 원시 데이터가 필요하면 `GET_MARKET_DATA`
4. 일부 지표만 필요하면 `CALCULATE_INDICATORS`
5. 전략 요약이 필요하면 `GET_TRADING_CONTEXT`
6. 결과를 Markdown으로 정리 후 `SAVE_*`로 기록

## Examples
- 삼성전자 5분봉 120개 조회
```json
{"command":"GET_MARKET_DATA","params":{"symbol":"005930","timeframe":"5m","limit":120}}
```
- 삼성전자 일봉 기준 EMA 20, RSI 14, MACD 계산
```json
{
  "command":"CALCULATE_INDICATORS",
  "params":{
    "symbol":"005930",
    "timeframe":"1d",
    "limit":200,
    "indicators":[
      {"type":"ema","key":"ema20","params":{"period":20}},
      {"type":"rsi","key":"rsi14","params":{"period":14}},
      {"type":"macd","key":"macd"}
    ]
  }
}
```