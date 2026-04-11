<div align="center">

<br/>

```
██╗  ██╗██╗   ██╗███████╗██╗  ██╗
██║  ██║██║   ██║██╔════╝██║  ██║
███████║██║   ██║███████╗███████║
██╔══██║██║   ██║╚════██║██╔══██║
██║  ██║╚██████╔╝███████║██║  ██║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
```

### Block the Noise. Answer the Call. Own Your Time.

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Aladhan API](https://img.shields.io/badge/Aladhan_API-Prayer_Times-1B4332?style=flat-square)](https://aladhan.com/prayer-times-api)
[![Audio](https://img.shields.io/badge/Azan-audioplayers-099DFD?style=flat-square)](https://pub.dev/packages/audioplayers)
[![Version](https://img.shields.io/badge/Version-1.0-0F766E?style=flat-square)](https://github.com/menakhaled/hush)
[![Status](https://img.shields.io/badge/Status-Phase_1_Active-16A34A?style=flat-square)](https://github.com/menakhaled/hush)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)](https://android.com)

<br/>

> *An Android app that enforces Islamic prayer times and deep focus sessions at the OS level.*
> *When it's time to pray — everything stops. When it's time to study — everything stops.*
> *No exceptions. No distractions.*

<br/>

</div>

---

## 📖 Table of Contents

| | Section |
|---|---|
| 01 | [Project Overview](#-project-overview) |
| 02 | [Key Features](#-key-features) |
| 03 | [Smart Handoff Flow](#-smart-handoff-flow) |
| 04 | [Tech Stack](#-tech-stack) |
| 05 | [Flutter Packages](#-flutter-packages) |
| 06 | [Android Permissions](#-android-permissions) |
| 07 | [Project Structure](#-project-structure) |
| 08 | [Build Phases](#-build-phases) |
| 09 | [Getting Started](#-getting-started) |
| 10 | [Running the App](#-running-the-app) |
| 11 | [Commit Convention](#-commit-convention) |
| 12 | [Branch Strategy](#-branch-strategy) |
| 13 | [Build Progress](#-build-progress) |

---

## 🌟 Project Overview

**HUSH** is an Android-only Flutter application built for Muslims who want to protect their prayer time and build deep focus habits — enforced at the operating system level, not just as a reminder.

The app operates in two modes: **Prayer Mode** and **Focus Mode**. Both modes use Android's Accessibility Service to block apps at the system level — not through app-level alerts that can be dismissed, but through a full-screen overlay that cannot be bypassed without confirmation.

### The Problem HUSH Solves

| Challenge | HUSH's Solution |
|---|---|
| Phone distractions during prayer time | Full-screen prayer dialog locks all apps until confirmation |
| Forgetting prayer times while focused | Azan plays automatically via GPS-synced prayer time API |
| Breaking focus sessions constantly | OS-level app blocker prevents switching to blocked apps |
| Prayer and focus modes conflicting | Smart handoff pauses focus, handles prayer, then resumes |
| No accountability for missed prayers | Emergency bypass is always logged, never silently allowed |

---

## ✨ Key Features

### 🕌 Prayer Mode
- Automatically fetches 5 daily prayer times based on GPS location
- Plays the azan at each prayer time via foreground service
- Waits 5 minutes then locks the phone with a full-screen prayer dialog
- Blocks all apps until the user confirms they have prayed
- Emergency bypass is available — every use is logged for accountability

### 🎯 Focus Mode
- Set a study session: 25 min, 50 min, or custom duration
- Blocks all non-whitelisted apps for the full session using Accessibility Service
- Built-in Pomodoro: study 25 min → break 5 min → repeat
- If azan arrives mid-session: session pauses → prayer dialog → session resumes automatically
- Whitelist specific apps you need during sessions (notes, maps, emergency calls)

### 📊 Dashboard
- Next prayer time with live countdown
- Active focus session status and elapsed time
- Weekly stats: prayers kept, hours focused, streaks
- Emergency bypass history log

### ⚡ Smart Handoff
- Prayer and focus modes communicate with each other automatically
- No manual toggling between modes required
- Transition is seamless — focus state is preserved across prayer interruptions

---

## 🔄 Smart Handoff Flow

```
Azan time hits
      │
      ▼
 ┌─────────────────────────────┐
 │  Azan audio plays            │  ← Foreground service, survives screen lock
 └──────────────┬──────────────┘
                │
                ▼
 ┌─────────────────────────────┐
 │  5-minute grace countdown   │  ← Notification countdown visible to user
 └──────────────┬──────────────┘
                │
                ▼
 ┌─────────────────────────────┐
 │  Full-screen prayer dialog  │  ← Accessibility Service blocks all apps
 │  [Cannot be dismissed]      │
 └──────────┬──────────────────┘
            │
            ├── "I Prayed" ──────→ Apps unblock
            │                      Focus session resumes if it was active
            │
            └── "Emergency" ────→ Apps unblock
                                   Bypass logged with timestamp
                                   Focus session paused
```

---

## 🏗 Tech Stack

| Layer | Tool |
|---|---|
| Framework | Flutter (Dart) |
| Prayer Times API | [Aladhan API](https://aladhan.com/prayer-times-api) |
| App Blocking | Android Accessibility Service (Kotlin) |
| Flutter ↔ Android Bridge | MethodChannel |
| Background Service | Android Foreground Service |
| Audio | audioplayers |
| Notifications | flutter_local_notifications |
| Location | geolocator |
| Local Storage | shared_preferences + sqflite |
| State Management | Provider |

---

## 📦 Flutter Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0                          # Prayer times API calls
  audioplayers: ^6.0.0                  # Azan audio playback
  flutter_local_notifications: ^17.0.0  # Prayer time alerts and reminders
  geolocator: ^12.0.0                   # GPS-based prayer time calculation
  shared_preferences: ^2.2.3            # Lightweight local settings storage
  sqflite: ^2.3.3                       # Focus session history and stats
  provider: ^6.1.2                      # App-wide state management
  flutter_foreground_task: ^8.17.0      # Keep services alive in background
```

---

## 🔐 Android Permissions

```xml
<!-- Network -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Location — GPS-based prayer time accuracy -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

<!-- Background services -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />

<!-- Scheduling -->
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />

<!-- App blocking — OS-level accessibility -->
<uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />

<!-- Detect foreground app for blocking -->
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" />

<!-- Full-screen prayer overlay -->
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
```

---

## 📁 Project Structure

```
hush/
│
├── lib/
│   ├── main.dart
│   │
│   ├── screens/
│   │   ├── home_screen.dart               # Dashboard — next prayer, focus status, stats
│   │   ├── prayer_screen.dart             # Full-screen prayer dialog
│   │   ├── focus_screen.dart              # Focus session setup and active timer
│   │   └── settings_screen.dart           # Whitelist, preferences, bypass log
│   │
│   ├── services/
│   │   ├── prayer_service.dart            # Aladhan API + prayer time scheduling
│   │   ├── blocker_service.dart           # MethodChannel → Kotlin Accessibility bridge
│   │   ├── audio_service.dart             # Azan playback via audioplayers
│   │   └── focus_service.dart             # Pomodoro timer + session state
│   │
│   ├── models/
│   │   ├── prayer_time.dart               # Prayer time data model
│   │   └── focus_session.dart             # Focus session data model
│   │
│   └── widgets/
│       ├── prayer_dialog.dart             # Full-screen prayer overlay widget
│       ├── countdown_timer.dart           # Reusable animated countdown
│       └── focus_card.dart                # Focus session status card
│
├── android/
│   └── app/src/main/
│       ├── kotlin/
│       │   └── HushAccessibilityService.kt  # OS-level app blocker
│       └── AndroidManifest.xml
│
├── assets/
│   └── audio/
│       └── azan.mp3
│
├── pubspec.yaml
└── README.md
```

---

## 🗺 Build Phases

| Phase | What Gets Built | Status |
|---|---|---|
| **Phase 1** | Flutter setup, dependencies, first run on device | ✅ Complete |
| **Phase 2** | Prayer times screen — fetch and display 5 daily prayers | 🚧 Active |
| **Phase 3** | Azan audio playback + local notification scheduling | ⏳ Pending |
| **Phase 4** | Full-screen prayer dialog with 5-minute countdown | ⏳ Pending |
| **Phase 5** | Android Accessibility Service — OS-level app blocker | ⏳ Pending |
| **Phase 6** | Focus mode — timer, Pomodoro engine, whitelist manager | ⏳ Pending |
| **Phase 7** | Dashboard, weekly stats, settings, streaks, polish | ⏳ Pending |

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version | Link |
|---|---|---|
| Flutter SDK | 3.x stable | [docs.flutter.dev](https://docs.flutter.dev/get-started/install) |
| Dart SDK | 3.x | Included with Flutter |
| Android Studio | Latest | For Android emulator and SDK manager |
| Git | Any | [git-scm.com](https://git-scm.com) |
| Android SDK | 35.0.0 | Via Android Studio SDK Manager |

### Clone & Install

```bash
# Clone the repository
git clone https://github.com/menakhaled/hush.git
cd hush

# Install all dependencies
flutter pub get

# Accept Android licenses (required on first setup)
flutter doctor --android-licenses

# Verify your Flutter setup
flutter doctor
```

---

## ▶️ Running the App

```bash
# ── Android device (USB connected) ──────────────────
flutter run

# ── Android emulator ────────────────────────────────
flutter emulators --launch <emulator_id>
flutter run

# ── List all connected devices ───────────────────────
flutter devices

# ── Check available emulators ────────────────────────
flutter emulators

# ── Production builds ────────────────────────────────
flutter build apk              # Android APK
flutter build appbundle        # Google Play bundle
```

### While the App Is Running

| Key | Action |
|---|---|
| `r` | Hot reload — fast, preserves state |
| `R` | Hot restart — full restart |
| `q` | Quit |
| `p` | Toggle widget inspector overlay |

### Troubleshooting

```bash
# Clean corrupted build cache
flutter clean
flutter pub get
flutter run

# Kill stale Kotlin daemon (Windows PowerShell)
Get-Process -Name "java" | Stop-Process -Force

# Clear Gradle cache (Windows PowerShell)
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\daemon"
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches"

# If Kotlin incremental cache causes cross-drive errors
# Add this line to android/gradle.properties:
# kotlin.incremental=false
```

---

## 📝 Commit Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/).

```
type(scope): short description

Types:  feat · fix · refactor · style · chore · docs · test
Scopes: prayer · focus · blocker · dialog · audio · settings · home
```

**Examples:**
```bash
init: scaffold HUSH Flutter project
feat(prayer): fetch prayer times from aladhan API
feat(blocker): add accessibility service for app blocking
feat(focus): implement pomodoro session timer
feat(audio): play azan at scheduled prayer times
fix(dialog): emergency button not dismissing overlay
style(home): redesign dashboard card layout
chore: add geolocator and audioplayers packages
docs: update phase 2 screen reference
```

---

## 🌿 Branch Strategy

| Branch | Purpose |
|---|---|
| `main` | Stable, working code only — merge when a full feature is complete and tested |
| `dev` | Daily work branch — always work here, never commit directly to `main` |

```bash
# Daily workflow — always start from dev
git checkout dev
git pull

# After your changes
git add .
git commit -m "feat(prayer): display 5 daily prayer times"
git push

# Merge to main only when a full feature is complete
git checkout main
git merge dev
git push
```

---

## 📊 Build Progress

| Phase | Built | Total | Progress |
|---|---|---|---|
| ✅ Phase 1 — Setup | 1 | 1 | `██████████` 100% |
| 🚧 Phase 2 — Prayer Times | 0 | 1 | `░░░░░░░░░░` 0% |
| ⏳ Phase 3 — Azan & Notifications | 0 | 1 | `░░░░░░░░░░` 0% |
| ⏳ Phase 4 — Prayer Dialog | 0 | 1 | `░░░░░░░░░░` 0% |
| ⏳ Phase 5 — App Blocker | 0 | 1 | `░░░░░░░░░░` 0% |
| ⏳ Phase 6 — Focus Mode | 0 | 1 | `░░░░░░░░░░` 0% |
| ⏳ Phase 7 — Dashboard & Polish | 0 | 1 | `░░░░░░░░░░` 0% |
| **Total** | **1** | **7** | **14%** |

### Phase 1 — Complete ✅

```
✅  Flutter project scaffold
✅  Android device connection configured
✅  All dependencies installed
✅  AndroidManifest.xml configured
✅  Foreground service registered
```

### Phase 2 — In Progress 🚧

```
🟡  Aladhan API integration
🟡  GPS location fetch
🟡  5 daily prayer times display
🟡  Prayer countdown on home screen
🟡  Local notification scheduling
```

---

<div align="center">

<br/>

**HUSH** · v1.0 · 2026 · Cairo, Egypt

Built with Flutter · Prayer times by Aladhan API · App blocking via Android Accessibility Service

*Block the noise. Answer the call. Own your time.*

<br/>

</div>
