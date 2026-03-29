# 📈 ARIStock: AI-Powered Smart Investment Platform

![ARIStock Banner](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![AI-Powered](https://img.shields.io/badge/AI--Powered-FF6F00?style=for-the-badge&logo=ai&logoColor=white)
![Kiwoom API](https://img.shields.io/badge/Kiwoom-OpenAPI-EF5350?style=for-the-badge)

**ARIStock**은 비개발자와 일반 투자자가 AI 에이전트와 협업하여 투자의 전 과정을 관리할 수 있도록 설계된 차세대 AI 주식 분석/운용 플랫폼입니다. 단순히 데이터를 보는 것을 넘어, AI가 분석한 '투자 가설'의 생애 주기를 **이슈 트레이스(Issue Trace)**로 추적합니다.

---

## ✨ 핵심 기능 (Key Features)

### 1. 🕰️ Issue Trace (투자 이슈 생애 주기 관리)
- **AI-Driven Analysis**: AI가 종목별 핵심 재료와 이슈를 탐지하고 관리합니다.
- **Investment Issues vs Analysis**: 정적인 분석 리포트가 아닌, 개별 이슈의 흐름을 추적합니다.
- **Gantt Chart & Issue Trace UI**: 이슈의 영향력(Impact)과 진행 상태를 시각화하여 최적의 매수/매도 타이밍을 판단하도록 돕습니다.

### 2. 🔌 Kiwoom Open API Integration
- **Full Infrastructure**: 키움증권 Open API를 활용한 실시간 시세 및 계좌 연동.
- **Account Management**: 보유 종목 수익률, 예수금, 자산 추이 실시간 추적.
- **Market Data**: 분/일/주 단위 차트 데이터 분석 및 기술적 지표(Indicator) 계산 지원.

### 3. 🤖 ARI Protocol (AI 협업 인터페이스)
- **Command-Based Protocol**: AI 에이전트가 앱을 제어하고 분석 데이터를 기록할 수 있는 표준화된 통신 규약.
- **Context-Aware Agent**: 사용자의 질문에 답할 뿐만 아니라, 현재 열린 종목이나 잔고 상태를 파악하여 능동적으로 제안합니다.

---

## 🛠 기술 스택 (Tech Stack)

- **Frontend**: Flutter (MacOS, Windows, Mobile 지원)
- **State Management**: Provider (반응형 상태 관리)
- **Data Persistence**: Hive (고성능 로컬 NoSQL)
- **Network & API**: HTTP, URL Launcher, [Kiwoom Node Proxy](https://github.com/rightsna/ARIStock-Proxy) (Planned/Optional)
- **AI Integration**: [ARI Agent Framework](https://github.com/rightsna/ARIAgent.git) 연동

---

## 📂 폴더 구조 (Directory Structure)

`SPECIFICATION.md`의 규칙에 따른 견고한 레이어드 구조를 따릅니다:

```text
lib/
├── components/           # 독립된 UI/비즈니스 기능 모듈
│   ├── account/          # 계좌, 자산 관리 및 디버그 화면
│   ├── analysis/         # Issue Trace (StockAnalysis, InvestmentIssue)
│   ├── briefing/         # AI 브리핑 및 리서치
│   └── watchlist/        # 관심 종목 관리
├── shared/               # 앱 전역 공통 레이어
│   ├── infra/            # 외부 API 연동 본체 (Kiwoom API Client 등)
│   ├── repository/       # 도메인 데이터 접근 레이어 (Kiwoom Repositories)
│   ├── services/         # 분석 엔진 및 ARI Protocol Handler
│   ├── models/           # 공통 데이터 엔티티
│   └── theme.dart        # 전역 디자인 시스템 (Rich Aesthetics)
└── main.dart             # 앱 초기화 및 진입점
```

---

## 🚀 시작하기 (Quick Start)

### 사전 준비
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.11.1 이상)
- [Kiwoom Open API+](https://www.kiwoom.com/h/help/openapi/VHelpOpenApiMainView) 설치 및 로그인
- Git (버전 관리 및 ARI 협업용)

### 설치 및 실행
1. 저장소를 클론합니다.
2. 의존성을 설치합니다:
   ```bash
   flutter pub get
   ```
3. 코드 생성기(Hive Adapter 등)를 실행합니다:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. 앱을 실행합니다:
   ```bash
   flutter run -d macos  # 또는 다른 타겟
   ```

---

## 📄 가이드라인 및 개발 규칙

ARIStock은 AI 에이전트와의 협업을 전제로 개발됩니다. 아래 가이드를 엄격히 준수합니다:
- **[SPECIFICATION.md](./SPECIFICATION.md)**: 전체 아키텍처 및 코딩 컨벤션
- **AI-Agent Instructions**: 에이전트는 모든 코드 변경 시 `LogProvider`를 통한 기록과 `ARIProtocolHandler`의 무결성을 유지해야 합니다.

---

© 2026 ARIStock Team. All rights reserved.

