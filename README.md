# 📈 ARIStock: AI-Powered Smart Investment Platform

![ARIStock Banner](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![AriAgent](https://img.shields.io/badge/ARI--Agent-FF6F00?style=for-the-badge&logo=ai&logoColor=white)
![Kiwoom API](https://img.shields.io/badge/Kiwoom-OpenAPI-EF5350?style=for-the-badge)

**ARIStock**은 비개발자와 일반 투자자가 AI 에이전트와 실시간으로 협업하여 투자의 전 과정을 관리할 수 있도록 설계된 차세대 AI 주식 분석/운용 플랫폼입니다.

단순한 데이터 조회를 넘어, AI가 발견한 '투자 가설'의 생애 주기를 **이슈 트레이스(Issue Trace)**로 추적하며, 사용자는 AI와 대화하며 투자 전략을 정교화할 수 있습니다.

---

## ✨ 핵심 기능 (Key Features)

### 1. 🕰️ Issue Trace (투자 이슈 생애 주기 관리)

- **AI-Driven Analysis**: AI가 종목별 핵심 재료와 이슈를 실시간으로 탐지하고 관리합니다.
- **Investment Issues vs Analysis**: 정적인 분석 리포트가 아닌, 개별 이슈의 흐름(생성-변화-소멸)을 기록합니다.
- **Gantt Chart & Issue Trace UI**: 이슈의 영향력(Impact)과 진행 상태를 시각화하여 최적의 매수/매도 타이밍을 제공합니다.

### 2. 🤖 AriAgent Integration (AI 협업 인터페이스)

- **Standard Protocol**: `AriAgent` 라이브러리를 통해 AI와 앱 간의 양방향 통신을 구현합니다.
- **Context-Aware Agent**: 사용자의 질문에 답할 뿐만 아니라, 현재 선택된 종목이나 잔고 상태를 파악하여 능동적으로 제안합니다.
- **Real-time Report**: 앱의 모든 주요 활동을 AI에게 리포트하며, AI는 이를 바탕으로 투자 리빙 리포트를 업데이트합니다.

### 3. 🔌 Kiwoom Open API Integration

- **Full Infrastructure**: 키움증권 Open API를 활용한 실시간 시세 및 계좌 연동.
- **Account Management**: 보유 종목 수익률, 예수금, 자산 추이 실시간 추적.
- **Market Data**: 분/일/주 단위 차트 데이터 분석 및 기술적 지표(Indicator) 계산 지원.

---

## 🛠 기술 스택 (Tech Stack)

- **Frontend**: Flutter (MacOS Native 특화)
- **State Management**: Provider (반응형 상태 관리)
- **Data Persistence**: Hive (고성능 로컬 NoSQL, 오프라인 모드 지원)
- **Protocol**: [ARI Agent Framework](https://github.com/rightsna/ARIAgent.git) (`AriAgent`)
- **Theme**: Dark Mode 기반의 Rich & Premium 디자인 시스템

---

## 📂 폴더 구조 (Directory Structure)

`SPECIFICATION.md`의 규칙에 따른 견고한 레이어드 구조를 따릅니다:

```text
lib/
├── components/           # 독립된 UI/비즈니스 기능 모듈
│   ├── account/          # 계좌, 자산 관리 및 디버그 화면
│   ├── analysis/         # Issue Trace (StockAnalysis, InvestmentIssue)
│   ├── layout/           # 앱의 메인 레이아웃 및 내비게이션
│   └── watchlist/        # 관심 종목 관리
├── shared/               # 앱 전역 공통 레이어
│   ├── infra/            # 외부 API 연동 본체 (Kiwoom API Client 등)
│   ├── repository/       # 도메인 데이터 접근 레이어 (Kiwoom Repositories)
│   ├── services/         # 분석 엔진 및 ARI Protocol Handler
│   ├── models/           # 공통 데이터 엔티티
│   └── theme.dart        # 전역 디자인 시스템
└── main.dart             # 앱 초기화 및 진입점
```

---

## 📄 가이드라인 및 개발 규칙

ARIStock은 AI 에이전트와의 협업을 전제로 개발됩니다. 아래 가이드를 엄격히 준수합니다:

- **[SKILL.md](./SKILL.md)**: 에이전트가 이해해야 할 앱의 기능 명세 및 프로토콜 규약
- **Log Management**: `LogProvider`를 통한 모든 행동의 체계적 기록

---

© 2026 ARIStock Team. All rights reserved.
