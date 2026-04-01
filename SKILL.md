# ARI Plugin Skill: ARIStock (Smart Investment Agent)

## Overview
`aristock`는 AI 에이전트가 주식 시장 데이터를 분석하고, 실시간 계좌 상태를 파악하며, 'Issue Trace' 시스템을 통해 투자 가설의 생애 주기를 관리할 수 있도록 돕는 플러그인입니다.

### App ID
`aristock`

---

## Core Concepts (핵심 개념)

ARIStock은 AI 에이전트와 앱 UI 간의 유기적인 협력을 위해 다음 세 가지 계층을 사용합니다:

1. **분석 (`StockAnalysis`)**: 종목에 대한 전체적인 **투자 가설(Hypothesis)**입니다. 핵심 요약, 의견, 단/중/장기 점수가 포함됩니다.
2. **이슈 (`Investment Issue`, 이하 '재료')**: 투자 가설을 지지하거나 부정하는 구체적인 **증거(Evidence)**입니다. 뉴스 공시, 수급 주체의 변화, 기술적 돌파 패턴, 매크로 지표 등 주가에 영향을 줄 수 있는 모든 요소를 '재료'라고 부르며, 이를 **이슈 트레이스(Issue Trace)**에 기록하여 지속적으로 추적합니다.
3. **이슈 트레이스 (`IssueHistory`)**: 특정 재료가 시간에 따라 어떻게 생성, 변화, 소멸하는지 기록하는 흐름입니다.

---

## Commands

### 1. Issue Trace (투자 분석 및 관리)
AI는 주식에 대한 정적인 메모가 아닌, **이슈(Issue)의 흐름**을 추적해야 합니다.

- `SET_ANALYSIS`: 종목의 핵심 분석 요약, 점수, 본문을 저장합니다. 새로운 종목 저장 시 반드시 초기 이슈 리스트를 포함해야 합니다.
  - Params: `symbol`, `summary?`, `content?`, `shortTermScore?`, `mediumTermScore?`, `longTermScore?`, `issues?` (`List<{title, isPositive, impact, status}>`)
- `GET_ANALYSIS`: 종목의 분석 요약 및 핵심 점수를 조회합니다. (`type: "full"|"recent"`)
- `GET_ANALYSIS_ISSUES`: 종목에 등록된 모든 투자 이슈 목록을 조회합니다. 해결된 이슈는 기본적으로 제외됩니다.
  - Params: `symbol`, `includeResolved?` (default: `false`)
- `ADD_ANALYSIS_ISSUE`: 신규 투자 재료(이슈) 하나를 추가합니다. 이슈를 처음 발견한 배경과 상세 내용을 `history`에 포함하여 시간의 흐름을 시작하세요.
  - Params: `symbol`, `title`, `isPositive`, `impact`, `status?`, `history?` (`{content, detail?}`)
- `REMOVE_ANALYSIS_ISSUE`: 특정 이슈를 리스트에서 제거합니다. (`issueTitle`)
- `UPDATE_ANALYSIS_ISSUE`: 특정 이슈의 상태, 점수를 변경하거나 이슈 트레이스 진행 내역(History)을 추가합니다.
  - Params: `symbol`, `issueTitle`, `status?`, `impact?`, `history?` (`{content, detail?}`)

### 2. Market Data & Indicators (시장 분석)
- `GET_MARKET_DATA`: 차트 캔들 또는 틱 데이터를 조회합니다.
  - Params: `symbol`, `timeframe` (`"1m"`, `"5m"`, `"15m"`, `"1d"` 등), `limit` (개수)
- `CALCULATE_INDICATOR`: 특정 기술적 지표를 계산합니다.
  - Params: `symbol`, `type` (`"rsi"`, `"macd"`, `"ma"`, `"bollinger"`, `"atr"`, `"vwap"`, `"trend"`)

> **⚠️ Rate Limit 주의**: `GET_MARKET_DATA`와 `CALCULATE_INDICATOR`는 내부적으로 외부 증권사 API(KIS)를 호출합니다. **단시간에 연속 호출 시 429 오류가 발생합니다.**
> - 여러 지표를 연속으로 요청할 경우 각 호출 사이에 **1~2초 간격**을 두세요.
> - 429 오류 수신 시 즉시 재시도하지 말고 **3초 이상 대기** 후 재시도하세요.
> - 한 번에 여러 종목의 지표를 동시에 계산하는 것은 피하세요.

### 3. Trading Strategy (매매전략)
AI가 수립한 매매전략을 저장하고 조회합니다. 자동매매 실행 시 참고 자료로 활용됩니다.

- `SET_STRATEGY`: 특정 종목의 매매전략을 저장합니다. Markdown 형식으로 작성하며, 진입 조건, 목표가, 손절가, 보유 기간 등을 포함합니다.
  - Params: `symbol`, `content` (Markdown 문자열)
- `GET_STRATEGY`: 저장된 매매전략을 조회합니다.
  - Params: `symbol`

### 4. Account & Watchlist (자산 및 관심종목)
- `GET_ACCOUNT_INFO`: 계좌의 자산 현황과 보유 종목 리스트를 조회합니다.
- `GET_WATCHLIST`: 사용자의 관심 종목 리스트를 조회합니다.

### 5. App Status
- `GET_APP_STATUS`: 앱 버전 및 실행 모드 정보를 확인합니다.

---

## Writing Rules
1. **분석-이슈 관계**: `SET_ANALYSIS`는 종목의 전체적인 '가설'을 설정하며, `ISSUE`들은 그 가설을 뒷받침하는 구체적인 '근거/재료'입니다. 처음 종목을 분석할 때는 반드시 근거(Issues)를 함께 저장하세요.
2. **이슈 단위 관리**: 이슈가 해결되거나 사라지면 `REMOVE_ANALYSIS_ISSUE`를, 상황이 변하면 `UPDATE_ANALYSIS_ISSUE`를 사용하세요.
3. **이슈 트레이스 히스토리**: `UPDATE_ANALYSIS_ISSUE`의 `history` 필드를 통해 해당 이슈가 시간에 따라 어떻게 변해왔는지 'Issue Trace'를 구축하세요.
4. **매매전략**: `SET_STRATEGY`는 분석을 바탕으로 실제 매매에 적용할 구체적인 전략을 저장합니다. 진입 조건, 목표가, 손절가를 명확히 명시하세요. 자동매매 실행 전 반드시 최신 전략이 저장되어 있어야 합니다.
5. **API 호출 제한 및 에러 처리**: 주가 조회 등 외부 API(예: 키움, 네이버 등) 호출 시 초당 호출 제한(Rate Limit)으로 인한 에러가 발생할 수 있습니다. 
   - 에러 메시지에 '제한', 'frequency', 'too many requests' 등의 문구가 포함된 경우, 즉시 **`delay`** 도구를 사용하여 1~2초간 대기한 후 동일한 명령을 재시도하십시오.
   - 스스로 상황을 판단하여 대기 후 재시도하는 것이 중요합니다.
   
---

## Examples

### 분석 정보 세팅 (최초 저장 시)
```json
{
  "command": "SET_ANALYSIS",
  "params": {
    "symbol": "005930",
    "summary": "반도체 업황 턴어라운드 국면 진입",
    "shortTermScore": 0.85,
    "issues": [
      {
        "title": "HBM3E 양산 개시",
        "isPositive": true,
        "impact": 5,
        "status": "active"
      }
    ]
  }
}
```

### 새로운 개별 이슈 추가 (발견 배경 포함)
```json
{
  "command": "ADD_ANALYSIS_ISSUE",
  "params": {
    "symbol": "005930",
    "title": "파운드리 수주 확대",
    "isPositive": true,
    "impact": 4,
    "status": "active",
    "history": {
      "content": "최근 대형 고객사와의 파트너십 체결 소식 확인",
      "detail": "공격적인 수주 활동이 실적으로 연결될 가능성 높음"
    }
  }
}
```

### 매매전략 저장
```json
{
  "command": "SET_STRATEGY",
  "params": {
    "symbol": "005930",
    "content": "## 매매전략\n\n### 진입 조건\n- 60일선 지지 확인 후 양봉 전환 시 매수\n- RSI 40 이하에서 반등 신호 시 분할 매수\n\n### 목표가\n- 1차: 82,000원 (5%)\n- 2차: 86,000원 (10%)\n\n### 손절가\n- 74,000원 이탈 시 즉시 손절 (-5%)\n\n### 보유 기간\n- 최대 4주, 목표가 도달 시 분할 매도"
  }
}
```

### 특정 이슈 업데이트 및 히스토리 기록
```json
{
  "command": "UPDATE_ANALYSIS_ISSUE",
  "params": {
    "symbol": "005930",
    "issueTitle": "HBM3E 양산 개시",
    "history": {
      "content": "엔비디아 정식 공급 계약 체결 소식",
      "detail": "공격적인 CAPA 증설 예고"
    },
    "status": "completed"
  }
}
```