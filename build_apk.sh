#!/usr/bin/env bash

# ==============================================================================
# 🎬 Manga Cinema - Build & Release Manager (Android APK & iOS IPA)
# ==============================================================================

set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

GITHUB_REPO="ZXD44/manga-cinema"
GITHUB_URL="https://github.com/$GITHUB_REPO"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

export PATH="/home/zirconx/development/flutter/bin:$PATH"
export ANDROID_HOME="/home/zirconx/Android/Sdk"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="/home/zirconx/.local/bin:$PATH"

ADB_BIN="$ANDROID_HOME/platform-tools/adb"
if ! command -v "$ADB_BIN" &> /dev/null; then
    ADB_BIN="adb"
fi

RELEASE_DIR="$PROJECT_DIR/release"
mkdir -p "$RELEASE_DIR"
DEST_APK="$RELEASE_DIR/Manga-Cinema.apk"

get_current_version() {
    APP_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | cut -d'+' -f1 | tr -d ' "')
    if [ -z "$APP_VERSION" ]; then
        APP_VERSION="1.0.0"
    fi
    echo "$APP_VERSION"
}

get_current_build() {
    BUILD_NUM=$(grep '^version:' pubspec.yaml | cut -d'+' -f2 | tr -d ' "' || echo "1")
    echo "$BUILD_NUM"
}

set_new_version() {
    local NEW_VER="$1"
    if [ -z "$NEW_VER" ]; then
        return
    fi

    CURRENT_BUILD=$(get_current_build)
    NEW_BUILD=$((CURRENT_BUILD + 1))
    sed -i "s/^version: .*/version: $NEW_VER+$NEW_BUILD/" pubspec.yaml
    echo -e "${GREEN}✓ อัปเดตเวอร์ชันเป็น: v$NEW_VER (Build $NEW_BUILD)${NC}"
}

do_build_apk() {
    local VER=$(get_current_version)
    local BUILD=$(get_current_build)
    echo ""
    echo -e "${BLUE}${BOLD}🔨 เริ่มกระบวนการคอมไพล์ Manga Cinema Release APK (v$VER Build $BUILD)...${NC}"
    
    flutter build apk --release --target-platform android-arm,android-arm64
    
    local SOURCE_APK="$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
    if [ -f "$SOURCE_APK" ]; then
        cp -f "$SOURCE_APK" "$DEST_APK"
        echo -e "${GREEN}${BOLD}✓ คอมไพล์ APK สำเร็จ!${NC}"
        echo -e "📦 ที่อยู่ไฟล์: ${YELLOW}$DEST_APK${NC}"
    else
        echo -e "${RED}❌ ไม่พบไฟล์ APK ที่ build ออกมา${NC}"
        exit 1
    fi
}

do_install_usb() {
    echo ""
    echo -e "${MAGENTA}${BOLD}📱 ตรวจสอบการเชื่อมต่ออุปกรณ์ Android ผ่าน USB ADB...${NC}"
    local DEVICES=$("$ADB_BIN" devices | grep -v "List" | grep "device$" | awk '{print $1}' || true)
    
    if [ -z "$DEVICES" ]; then
        echo -e "${YELLOW}⚠️  ไม่พบอุปกรณ์ Android ที่เชื่อมต่ออยู่${NC}"
        return 1
    fi

    for DEV in $DEVICES; do
        echo -e "🚀 กำลังติดตั้งลงอุปกรณ์: ${GREEN}$DEV${NC}"
        "$ADB_BIN" -s "$DEV" install -r "$DEST_APK"
        echo -e "${GREEN}✓ ติดตั้งบน $DEV สำเร็จ!${NC}"
    done
}

do_github_release() {
    local VER=$(get_current_version)
    echo ""
    echo -e "${BLUE}${BOLD}🐙 ขั้นตอนการอัปโหลด Release ขึ้น GitHub (v$VER)...${NC}"
    
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ ไม่พบคำสั่ง gh (GitHub CLI)${NC}"
        return 1
    fi

    echo ""
    echo -e "${CYAN}${BOLD}📝 ระบุรายละเอียดสิ่งที่ทำในเวอร์ชันนี้ (Release Notes):${NC}"
    read -p "👉 รายละเอียด: " -r USER_NOTES

    if [ -z "$USER_NOTES" ]; then
        USER_NOTES="🎬 Manga Cinema v$VER:
- Cross-platform Android APK & iOS IPA
- AI Multi-character Thai Voice Dubbing
- Cinematic Hands-free Reader with Auto Focus & Smart Pacing"
    fi

    # Trigger GitHub Actions macOS & Ubuntu runner to build and attach IPA + APK
    git add .
    git commit -m "release: v$VER" || true
    git tag -f "v$VER"
    git push origin main --tags -f

    echo ""
    echo -e "${GREEN}${BOLD}✓ ยิง Tag v$VER ขึ้น GitHub สำเร็จ!${NC}"
    echo -e "${CYAN}🍏 GitHub Actions เริ่มคอมไพล์ Android APK + iOS IPA บน Cloud Runner อัตโนมัติ...${NC}"
    echo -e "🔗 หน้า Actions Workflow: ${CYAN}${GITHUB_URL}/actions${NC}"
    echo ""
    
    read -p "🍏 ต้องการให้แสดงสถานะและรอแนบ iOS IPA อัตโนมัติเลยไหม? (y/N): " -r WATCH_IPA
    if [[ "$WATCH_IPA" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⏳ กำลังติดตามสถานะการคอมไพล์บน macOS Server...${NC}"
        sleep 5
        local RUN_ID=$(gh run list --workflow="build_release.yml" -L 1 --json databaseId -q '.[0].databaseId' 2>/dev/null || true)
        if [ -n "$RUN_ID" ]; then
            gh run watch "$RUN_ID" --exit-status || true
            echo -e "${GREEN}✓ การคอมไพล์บน macOS เสร็จสิ้น! ตรวจสอบ Release v$VER${NC}"
            gh release view "v$VER"
        fi
    fi
}


# Check flags
if [ "$1" == "--build" ] || [ "$1" == "-b" ]; then
    do_build_apk
    exit 0
elif [ "$1" == "--github" ] || [ "$1" == "-g" ]; then
    do_github_release
    exit 0
fi

clear
APP_VERSION=$(get_current_version)
APP_BUILD=$(get_current_build)
echo -e "${CYAN}${BOLD}"
echo "============================================================"
echo "    🎬 Manga Cinema - Build & Release Manager (APK & IPA)   "
echo "============================================================"
echo -e "${NC}"
echo -e "🏷️  เวอร์ชันปัจจุบัน: ${BOLD}${GREEN}v${APP_VERSION} (Build ${APP_BUILD})${NC}"
echo -e "🔗 GitHub Repo:     ${BLUE}${GITHUB_URL}${NC}"
echo ""
echo -e "${BOLD}เลือกการทำงาน:${NC}"
echo -e "  ${GREEN}1.${NC} 🔨 ${BOLD}Build APK เท่านั้น${NC}"
echo -e "  ${MAGENTA}2.${NC} 📱 ${BOLD}Build APK + ติดตั้งลงมือถือ (USB ADB)${NC}"
echo -e "  ${BLUE}3.${NC} 🐙 ${BOLD}อัปโหลด Release ขึ้น GitHub (Build APK + IPA บน Actions)${NC}"
echo -e "  ${RED}0.${NC} ❌ ออกจากโปรแกรม"
echo ""

read -p "👉 กรุณาเลือกหมายเลข (0-3) [ค่าเริ่มต้น 1]: " -r CHOICE || CHOICE="1"
CHOICE=${CHOICE:-1}

case "$CHOICE" in
    1) do_build_apk ;;
    2) do_build_apk && do_install_usb ;;
    3) do_github_release ;;
    *) echo "ออกจากการทำงาน" ;;
esac
