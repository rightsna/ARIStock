# 📈 ARIStock

![ARIStock Banner](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![AI-Powered](https://img.shields.io/badge/AI--Powered-FF6F00?style=for-the-badge&logo=ai&logoColor=white)

**ARIStock**은 비개발자와 일반 투자자도 직관적으로 주식 데이터를 분석하고 관리할 수 있도록 설계된 차세대 AI 주식 관리 플랫폼입니다.

---

## ✨ 핵심 철학 (Core Philosophy)

1. **단순함 (Simplicity)**: 비개발자가 읽어도 직관적으로 이해할 수 있는 코드로 유지됩니다.
2. **격리 (Isolation)**: 각 기능은 독립된 모듈로 구성되어 수정이 다른 기능에 영향을 주지 않습니다.
3. **비개발자 중심 (Citizen-friendly)**: 설명적인 주석과 비즈니스 용어를 사용합니다.

---

## 🛠 기술 스택 (Tech Stack)

- **Frontend**: Flutter (MacOS, Web, Mobile 지원)
- **State Management**: Provider
- **Local DB**: Hive
- **Network**: HTTP, URL Launcher
- **Infrastructure**: Git, Vercel (Web deployment)
- **AI Framework**: [ARI Agent Framework](https://github.com/rightsna/ARIAgent.git) 연동

---

## 📂 폴더 구조 (Directory Structure)

`SPECIFICATION.md`의 규칙에 따른 격리된 구조를 따릅니다:

```text
lib/
├── components/              # 독립된 기능 모듈
│   ├── account/             # 계좌 및 포트폴리오 관리
│   ├── briefing/            # 리서치 및 브리핑 세션
│   ├── consultation/        # 투자 상담 로직
│   ├── strategy/            # 투자 전략
│   └── portfolio/           # 대시보드 및 자산 요약
├── shared/                  # 전역 공통 자원 (Theme, Widgets)
├── services/                # 기술적 분석 및 외부 연동 엔진
└── main.dart                # 앱 진입점
```

---

## 🚀 시작하기 (Quick Start)

### 사전 준비
- [Flutter SDK](https://docs.flutter.dev/get-started/install) 설치 (v3.11.1 이상 권장)
- Git 설치 및 계정 연동

### 설치 및 실행
1. 저장소를 클론합니다.
2. 의존성을 설치합니다:
   ```bash
   flutter pub get
   ```
3. 코드를 생성합니다 (Hive 등):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. 앱을 실행합니다:
   ```bash
   flutter run
   ```

---

## 📄 가이드라인

개발 시 상세한 규칙은 [SPECIFICATION.md](./SPECIFICATION.md) 파일을 참조하십시오. AI 에이전트와 협업할 때는 반드시 이 가이드를 먼저 숙지해야 합니다.

---

© 2026 ARIStock Team. All rights reserved.
