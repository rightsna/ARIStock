#!/bin/bash
# ============================================================
# ARIStock 배포 스크립트
# 빌드 → 기존 앱 제거 → 새 앱 설치 → ARIAgent 재실행
# ============================================================

set -e

APP_ID="aristock"
SKILL_DIR="$HOME/.ari-agent/skills/$APP_ID"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_OUTPUT="$PROJECT_DIR/build/macos/Build/Products/Release/$APP_ID.app"
TEMP_DIR="$PROJECT_DIR/.deploy_temp"

echo ""
echo "=========================================="
echo "  🚀 ARIStock 배포 스크립트"
echo "=========================================="
echo ""

# ── 1. 프로젝트 빌드 ──────────────────────────
echo "📦 [1/5] Flutter macOS 릴리스 빌드 중..."
cd "$PROJECT_DIR"
flutter build macos --release
echo "   ✅ 빌드 완료"
echo ""

# ── 2. 임시 폴더에 산출물 준비 ─────────────────
echo "📂 [2/5] 임시 폴더에 산출물 준비 중..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

cp -R "$BUILD_OUTPUT" "$TEMP_DIR/"
cp "$PROJECT_DIR/SKILL.md" "$TEMP_DIR/"
echo "   ✅ $TEMP_DIR 에 준비 완료"
echo ""

# ── 3. 기존 앱 제거 ────────────────────────────
echo "🗑️  [3/5] 기존 배포 제거 중..."
if [ -d "$SKILL_DIR" ]; then
    rm -rf "$SKILL_DIR"
    echo "   ✅ 기존 $SKILL_DIR 삭제 완료"
else
    echo "   ℹ️  기존 배포 없음 (신규 설치)"
fi
echo ""

# ── 4. 새 앱 설치 ──────────────────────────────
echo "📥 [4/5] 새 앱 설치 중..."
mkdir -p "$SKILL_DIR"
cp -R "$TEMP_DIR/$APP_ID.app" "$SKILL_DIR/"
cp "$TEMP_DIR/SKILL.md" "$SKILL_DIR/"
echo "   ✅ $SKILL_DIR 에 설치 완료"

# 임시 폴더 정리
rm -rf "$TEMP_DIR"
echo "   🧹 임시 폴더 정리 완료"
echo ""

# ── 5. ARIAgent 재실행 ─────────────────────────
echo "🔄 [5/5] ARIAgent 재실행 중..."
pkill -f "AriAgent" 2>/dev/null || true
sleep 1
open -a "AriAgent" 2>/dev/null && echo "   ✅ ARIAgent 재실행 완료" || echo "   ⚠️  ARIAgent를 찾을 수 없습니다. 수동으로 실행해주세요."
echo ""

# ── 검증 ───────────────────────────────────────
echo "=========================================="
echo "  ✅ 배포 완료! 검증 결과:"
echo "=========================================="
echo ""
if [ -f "$SKILL_DIR/SKILL.md" ] && [ -d "$SKILL_DIR/$APP_ID.app" ]; then
    echo "  📄 SKILL.md ······ OK"
    echo "  📦 $APP_ID.app ··· OK"
    echo "  📁 경로: $SKILL_DIR"
    echo ""
    echo "  🎉 배포가 성공적으로 완료되었습니다!"
else
    echo "  ❌ 배포 파일 검증 실패! 수동으로 확인해주세요."
    echo "  📁 경로: $SKILL_DIR"
fi
echo ""
