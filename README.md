<div align="center">

# Writdle V2

**A polished local-first productivity app built with Flutter.**

Notes · Tasks · Wordle Game · Bilingual · Local Notifications · Profile Personalization

<br/>

<img src="assets/github/writdle-v2-showcase.png" alt="Writdle V2 Showcase" width="100%" />

<br/>

[![Download APK](https://img.shields.io/badge/Download-APK-brightgreen?style=for-the-badge&logo=android)](https://github.com/YOUR_USERNAME/writdle-v2/releases/latest)
&nbsp;&nbsp;
[![View Releases](https://img.shields.io/badge/View-Releases-blue?style=for-the-badge&logo=github)](https://github.com/YOUR_USERNAME/writdle-v2/releases)

</div>

---

## Overview

**Writdle V2** is a local-first Flutter app built for people who want a clean, fast, and lightweight productivity + gaming experience — no accounts, no cloud friction, just a smooth daily companion on your device.

This version focuses on delivering a production-quality experience:

- Simple device-based profile setup
- Full notes and task management
- Daily Wordle-style gameplay with customizable rules
- Local notifications that work even when the app is closed
- Complete Arabic and English support
- Polished UI with consistent navigation throughout

---

## Features

### Productivity
- Create and manage **notes** with a clean editor
- Organize **daily tasks** and track progress by date
- Edit your personal local profile

### Wordle Game
- Daily Wordle-style gameplay
- Adjustable difficulty and cooldown timing
- Manual restart and competitive layout options
- High contrast mode and gameplay hints

### Local Experience
- All data stored locally on your device
- Notes, tasks, stats, and profile — no account needed
- Local notifications for daily game reminders and task alerts

### Personalization
- Light and dark theme support
- Text scaling
- Reduced motion mode
- Arabic / English language switch

---

## Screens

| Home Dashboard | Wordle Game | Notes | Activity |
|:-:|:-:|:-:|:-:|
| Profile | Settings | Stats Sheet | Task Editor |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter + Dart |
| State Management | flutter_bloc |
| Persistence | shared_preferences |
| Notifications | flutter_local_notifications + timezone |
| Localization | intl |
| Calendar | table_calendar |
| Charts | fl_chart |

---

## Download & Install

### Android (Direct APK)

1. Go to the **[Releases](https://github.com/YOUR_USERNAME/writdle-v2/releases/latest)** page
2. Download the latest `app-release.apk`
3. Open the file on your Android device
4. If prompted, enable **Install unknown apps** in your device settings
5. Install and enjoy

> **Note:** Writdle V2 is currently available for Android only.

---

## Project Structure

```
lib/
├─ core/
├─ data/
├─ domain/
├─ presentation/
│  ├─ bloc/
│  ├─ screens/
│  └─ widgets/
└─ main.dart
```

---

## Author

**Developed by Ibrahim Elshishtawy**

---

## License

This project is for personal and portfolio use.
You may view the source for reference but redistribution or commercial use is not permitted without explicit permission.
