# 🎬 Manga Cinema (มังงะ ซินีม่า)
### AI Manga/Webtoon Motion Reader & Audio Cinema for Android & iOS

<p align="center">
  <img src="https://raw.githubusercontent.com/ZXD44/manga-cinema/main/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="96" height="96" alt="Manga Cinema Logo"><br>
  <b>เปลี่ยนการอ่านการ์ตูนและเว็บตูน ให้เป็นประสบการณ์ภาพยนตร์พร้อมเสียงพากย์เสมือนจริง (Cross-Platform Mobile App)</b><br>
  <i>Transforming Manga & Webtoons into Hands-Free Cinematic Audio Experiences on Android (APK) & iOS (IPA)</i>
</p>

<p align="center">
  <a href="https://github.com/ZXD44/manga-cinema/releases/latest"><img src="https://img.shields.io/github/v/release/ZXD44/manga-cinema?style=for-the-badge&color=FF3366&label=Latest%20Release" alt="Latest Release"></a>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-6C5CE7?style=for-the-badge&logo=flutter" alt="Platforms">
  <img src="https://img.shields.io/badge/Flutter-3.47.1-02569B?style=for-the-badge&logo=flutter" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Design-OLED%20Pure%20Black-0A0A0C?style=for-the-badge" alt="OLED Design">
</p>

---

## 🌐 Language / ภาษา
- [ภาษาไทย (Thai)](#-ภาษาไทย-thai)
- [English](#-english)

---

## 🇹🇭 ภาษาไทย (Thai)

### 📖 ภาพรวมระบบ (Overview)
**Manga Cinema** คือแอปพลิเคชันสำหรับอ่านมังงะและเว็บตูนรูปแบบใหม่ ออกแบบมาเพื่อมอบประสบการณ์ **"ดูภาพ + ฟังพากย์ เหมือนดูหนัง"** โดยที่ผู้ใช้ไม่ต้องแตะเลื่อนหน้าจอเอง ระบบขับเคลื่อนด้วย AI Multi-Role Voice Acting ช่วยพากย์บทสนทนาภาษาไทยแยกตามตัวละคร พร้อมการเคลื่อนไหวของมุมกล้อง (Pan, Zoom & Focus) สไตล์ภาพยนตร์อนิเมะ

### 📦 ไฟล์ติดตั้งพร้อมใช้งาน (Installation Artifacts)
สามารถดาวน์โหลดไฟล์ติดตั้งเวอร์ชันล่าสุดได้จาก [GitHub Releases](https://github.com/ZXD44/manga-cinema/releases/latest):
* 🤖 **Android (APK):** `Manga-Cinema.apk` (รองรับ Android 7.0 ขึ้นไป ทั้ง ARM64 และ ARMv7)
* 🍎 **iOS (IPA):** `Manga-Cinema.ipa` (สำหรับ iPhone / iPad รองรับการติดตั้งผ่าน AltStore, Sideloadly, หรือ TrollStore)

---

### ✨ ฟีเจอร์หลัก (Key Features)

#### 1. 🎬 โหมดรับชมแบบ Hands-Free Cinema (Director Engine)
* **ไม่ต้องใช้นิ้วเลื่อนหน้าจอ:** กล้องจะค่อยๆ แพน (Smooth Panning) และซูมเน้น (Camera Focus) ไปยังช่องและตัวละครที่กำลังพูดโดยอัตโนมัติ
* **Dramatic Pause & Pacing:** เว้นจังหวะหายใจ 1-1.5 วินาทีหลังจบแต่ละบทสนทนา เพื่อให้ผู้ชมซึมซับอารมณ์ของลายเส้นเหมือนดูอนิเมะ

#### 2. 🎙️ ระบบพากย์เสียงหลายตัวละคร (AI Multi-Role Thai TTS)
* จำแนกและสังเคราะห์เสียงพากย์ภาษาไทยตามบทบาทตัวละคร:
  * 👑 **พระเอก (Hero):** เสียงหนักแน่น มั่นใจ
  * 🌸 **นางเอก (Heroine):** เสียงหวาน อบอุ่น
  * ⚡ **ตัวร้าย (Villain):** เสียงทุ้มลึก ดุดัน
  * 💭 **เสียงคิดในใจ (Internal Monologue / Thought):** เสียงนุ่ม ก้องกังวาน
  * 📜 **ผู้บรรยาย (Narrator):** เสียงสุขุม เป็นกลาง

#### 3. 🌙 ดีไซน์เพื่อหน้าจอ OLED (Pure Black Cinema Theme)
* พื้นหลังสีดำสนิท `#0A0A0C` ประหยัดพลังงานแบตเตอรี่บนหน้าจอ OLED
* สไตล์ **Glassmorphism Chrome** พร้อมแถบสถานะโปร่งแสง และระบบ Auto-hide ซ่อนปุ่มอัตโนมัติเพื่อการรับชมแบบไร้สิ่งบดบัง
* ไฮไลต์กล่องคำพูด (Speech Bubble Spotlight) เรืองแสงตามตัวละครที่กำลังพูด

#### 4. 📲 ระบบอัปเดตอัตโนมัติภายในแอป (In-App Self-Updater)
* ตรวจสอบ Release ใหม่จาก GitHub Releases API โดยอัตโนมัติ
* หน้าต่างแจ้งเตือนสไตล์ OLED Glassmorphism แสดง Changelog อย่างชัดเจน
* ดาวน์โหลดไฟล์ APK พร้อมแถบแสดง Progress แบบเรียลไทม์ และเรียกติดตั้งผ่าน Android `FileProvider` ได้ทันที

---

### 📱 วิธีติดตั้งบน iOS (iPhone & iPad)
1. ดาวน์โหลดไฟล์ `Manga-Cinema.ipa` จากหน้า Releases
2. นำไฟล์เข้าคอมพิวเตอร์และติดตั้งผ่านโปรแกรม **Sideloadly** หรือ **AltStore** (Sign ฟรีด้วย Apple ID)
3. บน iPhone เข้าไปที่: **การตั้งค่า (Settings)** ➔ **ทั่วไป (General)** ➔ **VPN & การจัดการอุปกรณ์** แล้วแตะ **เชื่อถือ (Trust)**

---

## 🇬🇧 English

### 📖 Overview
**Manga Cinema** is a next-generation cross-platform mobile reader designed to transform static manga and vertical webtoons into an immersive, hands-free **Motion Comic & Audio Cinema Experience**. Driven by AI multi-character voice acting and an autonomous camera director engine, users can sit back and watch stories unfold effortlessly on both Android and iOS devices.

### 📦 Installation Artifacts
Download ready-to-use binaries from [GitHub Releases](https://github.com/ZXD44/manga-cinema/releases/latest):
* 🤖 **Android (APK):** `Manga-Cinema.apk` (Supports ARM64-v8a & ARMv7 devices)
* 🍎 **iOS (IPA):** `Manga-Cinema.ipa` (Supports sideloading via AltStore, Sideloadly, or TrollStore)

---

### 🌟 Key Features

#### 1. 🎬 Hands-Free Cinema Mode (Director Engine)
* **Zero Scrolling Required:** Autonomous keyframe system pans and zooms smoothly into current dialogue panels.
* **Smart Pacing & Dramatic Pauses:** Intelligently pauses between speech bubbles to let readers absorb visual emotion.

#### 2. 🎙️ AI Multi-Role Voice Acting (Thai TTS)
* Distinct voice personalities tailored for different roles:
  * 👑 **Hero / Protagonist:** Confident & determined tone
  * 🌸 **Heroine:** Warm & expressive tone
  * ⚡ **Villain:** Deep & intense timbre
  * 💭 **Internal Monologue:** Soft & reverberant thought delivery
  * 📜 **Narrator:** Formal & balanced narration

#### 3. 🌙 Pure Black OLED Design System
* Engineered around a `#0A0A0C` true dark aesthetic to maximize battery efficiency on OLED displays.
* Frosted glass UI (Glassmorphism) with auto-hiding playback chrome.
* Dynamic speech bubble highlight tracking active voice lines.

#### 4. 📲 Seamless In-App Self-Updater
* Periodic semantic version checks against official GitHub Releases.
* In-app download with real-time transfer progress and automated Android package installer trigger.

---

## 🏗️ โครงสร้างสถาปัตยกรรม (Architecture Structure)

```
manga_cinema_app/
├── .github/workflows/
│   └── build_release.yml         # CI/CD Dual-Runner: Ubuntu (APK) + macOS (IPA)
├── android/                      # Android Native Configuration & FileProvider
├── ios/                          # iOS Runner & Xcode Project Configuration
├── build_apk.sh                  # Interactive CLI Manager for Build & GitHub Release
├── lib/
│   ├── main.dart                 # App Entry Point & Theme Setup
│   ├── theme/
│   │   └── cinema_colors.dart    # OLED Cinema Palette & Design Tokens
│   ├── models/
│   │   └── cinema_models.dart    # PanelKeyframe, BubbleAnnotation, DialogueRole
│   ├── services/
│   │   ├── voice_engine.dart     # Multi-Role Thai TTS Voice Synthesizer
│   │   └── auto_update_service.dart # GitHub Release In-App Updater Service
│   ├── state/
│   │   └── cinema_playback_state.dart # Playback Loop & Timecode Director
│   ├── screens/
│   │   └── cinema_viewer_screen.dart # Motion Canvas, Subtitle Overlay & Controls
│   └── widgets/
│       └── cinema_update_dialog.dart # OLED Glassmorphism In-App Updater Dialog
```

---

## 🛠️ การพัฒนาและ Build ในเครื่อง (Local Development)

### ข้อกำหนดเบื้องต้น (Prerequisites)
* **Flutter SDK:** `^3.47.1`
* **Dart SDK:** `^3.13.1`
* **Android SDK:** API 34+
* **GitHub CLI:** `gh` (สำหรับการปล่อย Release อัตโนมัติ)

### คำสั่งเริ่มต้น (Quick Start)
```bash
# 1. ติดตั้ง Dependencies
flutter pub get

# 2. รันแอปพลิเคชันเพื่อทดสอบ
flutter run

# 3. รัน Unit & Widget Tests
flutter test

# 4. ใช้งาน Release Manager CLI
./build_apk.sh
```

---

## 📄 License & Terms
Developed for private reading & multimedia adaptation studies. Manga content belongs to respective copyright owners and creators.
