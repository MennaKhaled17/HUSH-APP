# HUSH 🤫

> **Block the noise. Answer the call. Own your time.**

HUSH is an Android app built with Flutter that combines Islamic prayer enforcement with a professional focus mode. When it's time to pray — everything stops. When it's time to study — everything stops. No exceptions, no distractions.

---

## What HUSH does

### Prayer Mode
- Automatically fetches your 5 daily prayer times based on your GPS location
- Plays the azan at each prayer time
- Waits 5 minutes then locks your phone with a full-screen prayer dialog
- Blocks all apps until you confirm you have prayed
- Emergency bypass available (logged for accountability)

### Focus Mode
- Set a study session: 25 min, 50 min, or custom duration
- Blocks all non-whitelisted apps for the full session
- Built-in Pomodoro mode: study 25 min → break 5 min → repeat
- If azan arrives mid-session: session pauses → prayer dialog → session resumes
- Whitelist specific apps you need (e.g. notes, maps, calls)

### Dashboard
- Shows next prayer time with countdown
- Shows active focus session status
- Weekly stats: prayers kept, hours focused, streaks

---

## Tech stack

| Layer | Tool |
|---|---|
| Framework | Flutter (Dart) |
| Prayer times API | [Aladhan API](https://aladhan.com/prayer-times-api) |
| App blocking | Android Accessibility Service (Kotlin) |
| Flutter ↔ Android bridge | MethodChannel |
| Background service | Android Foreground Service |
| Audio | audioplayers package |
| Notifications | flutter_local_notifications |
| Location | geolocator package |
| Local storage | shared_preferences + sqflite |
| State management | Provider |

---

## Flutter packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  audioplayers: ^6.0.0
  flutter_local_notifications: ^17.0.0
  geolocator: ^12.0.0
  shared_preferences: ^2.2.3
  sqflite: ^2.3.3
  provider: ^6.1.2
```

---

## Project structure

```
hush/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── prayer_screen.dart
│   │   ├── focus_screen.dart
│   │   └── settings_screen.dart
│   ├── services/
│   │   ├── prayer_service.dart
│   │   ├── blocker_service.dart
│   │   ├── audio_service.dart
│   │   └── focus_service.dart
│   ├── models/
│   │   ├── prayer_time.dart
│   │   └── focus_session.dart
│   └── widgets/
│       ├── prayer_dialog.dart
│       ├── countdown_timer.dart
│       └── focus_card.dart
├── android/
│   └── app/src/main/kotlin/
│       └── HushAccessibilityService.kt
├── assets/
│   └── audio/
│       └── azan.mp3
└── pubspec.yaml
```

---

## Build phases

| Phase | What gets built |
|---|---|
| 1 | Flutter setup, project creation, first run |
| 2 | Prayer times screen — fetch and display 5 prayers |
| 3 | Azan audio + local notification scheduling |
| 4 | Full-screen prayer dialog with countdown |
| 5 | Android Accessibility Service — app blocker |
| 6 | Focus mode — timer, pomodoro, whitelist |
| 7 | Dashboard, stats, settings, polish |

---

## Android permissions required

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" />
```

---

## How the smart handoff works

```
Azan time hits
    └── Playing azan audio
        └── 5 minute countdown begins
            └── Full-screen dialog appears
                ├── "I prayed" → apps unblock → if focus was active, resume session
                └── "Emergency" → apps unblock → emergency logged → focus paused
```

---

## Commit convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/).

```
type(scope): short description

Types: feat · fix · refactor · style · chore · docs · test
Scopes: prayer · focus · blocker · dialog · audio · settings · home
```

Examples:
```
init: scaffold HUSH Flutter project
feat(prayer): fetch prayer times from aladhan API
feat(blocker): add accessibility service for app blocking
feat(focus): implement pomodoro session timer
fix(dialog): emergency button not dismissing overlay
style(home): redesign dashboard card layout
chore: add geolocator and audioplayers packages
```

---

## Branch strategy

```
main   → stable, working code only
dev    → daily work branch
```

Always work on `dev`. Merge into `main` only when a full feature is complete and tested.

---

## Status

🚧 **In active development** — Phase 1 in progress

---

## Developer

Built by [your name] · Cairo, Egypt  
A personal tool to protect prayer time and build deep focus habits.

---

*HUSH — Block the noise. Answer the call. Own your time.*
