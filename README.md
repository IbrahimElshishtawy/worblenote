# Writdle V2

<p align="center">
  <strong>A polished local-first productivity app built with Flutter.</strong>
</p>

<p align="center">
  Notes, tasks, profile personalization, Wordle-style daily gameplay, local notifications, bilingual support, and a smoother app-wide navigation experience.
</p>

<p align="center">
  <img src="assets/github/writdle-v2-showcase.png" alt="Writdle V2 Showcase" width="100%" />
</p>

<p align="center">
  Replace the image above with your final screenshots collage before publishing.
</p>

---

## Overview

**Writdle V2** is the second major version of the project, focused on delivering a cleaner product experience, stronger local persistence, better UI consistency, and a more professional day-to-day flow across the app.

This version moves the app closer to a real production-style experience by improving:

- onboarding and local profile setup
- settings persistence
- game customization and HUD quality
- local notifications outside the app
- navigation consistency
- Arabic and English language support
- GitHub presentation and release readiness

---

## What's New In V2

### V2 highlights

- Local-first onboarding with **name-only profile setup**
- Removed the old login/register complexity in favor of a simpler device profile flow
- Improved **Wordle game settings** and immediate application of changes
- Refined **game status panel** and stats presentation
- Better **bottom navigation consistency** across core sections
- Cleaner **home dashboard cards** and snapshot presentation
- Local notifications for:
  - daily game reminders
  - task reminders
- Added **language switching** from settings
- Improved support for **Arabic and English**
- More polished settings layout and general UI spacing

---

## Core Features

### Productivity

- Create and manage **notes**
- Organize **daily tasks**
- Track task progress by date
- Edit a personal local profile

### Wordle Experience

- Daily Wordle-style game flow
- Adjustable difficulty
- Configurable cooldown timing
- Manual restart mode
- Competitive layout option
- High contrast mode
- Gameplay hints and HUD badges

### Local Experience

- Local profile storage
- Local note storage
- Local task storage
- Local statistics
- Local notifications that can appear **outside the app**

### Personalization

- Theme mode
- Text scaling
- Reduced motion mode
- Arabic / English language choice

---

## Screens Included

Writdle V2 includes a full multi-section app experience:

- Home dashboard
- Wordle game
- Notes
- Activity
- Profile
- Settings
- Game statistics sheet
- Task editor sheet
- Note editor sheet

---

## UI / UX Improvements In V2

This version puts noticeable effort into polish, not just functionality.

- Smoother transitions between pages
- More consistent bottom sheets
- Cleaner app-wide spacing and card sizing
- Improved status cards and dashboard blocks
- More compact and clearer game HUD
- Better readability in Arabic layouts
- Improved bottom navigation sizing for multilingual labels

---

## Tech Stack

- **Flutter**
- **Dart**
- **flutter_bloc**
- **shared_preferences**
- **flutter_local_notifications**
- **timezone**
- **intl**
- **table_calendar**
- **fl_chart**

---

## Project Direction

Writdle V2 is designed around a **local-first experience**.

That means the app prioritizes:

- fast access
- simple personal setup
- device-based persistence
- reduced friction for daily use

This makes the app especially suitable for users who want a lightweight productivity + game companion without a heavy account flow.

---

## Folder Structure

```text
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

## Getting Started

### Requirements

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android device or emulator

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Optional checks

```bash
flutter analyze
flutter test
```

---

## Android Installation

If you want users to install the Android version directly:

### Option 1: GitHub Releases

1. Build the APK:

```bash
flutter build apk --release
```

2. Find the file here:

```text
build/app/outputs/flutter-apk/app-release.apk
```

3. Upload it to the **Releases** section of your GitHub repository.

4. Users can then:
   - open the latest release
   - download the APK
   - install it on Android

### Option 2: Direct APK Sharing

You can also share the generated APK file directly with Android users after building it with:

```bash
flutter build apk --release
```

### Android installation note

On some Android devices, users may need to enable:

- **Install unknown apps**

before opening the APK manually.

---

## Screenshot Section

You said you will add one image that contains a combined screenshot showcase.

Use this file path in the repo:

```text
assets/github/writdle-v2-showcase.png
```

If the folder does not exist yet, create it:

```text
assets/github/
```

Then place your collage image there and keep this line in the README:

```html
<img src="assets/github/writdle-v2-showcase.png" alt="Writdle V2 Showcase" width="100%" />
```

---

## Why V2 Matters

Compared to the previous version, V2 is more:

- professional in presentation
- stable in local user flow
- polished in game experience
- practical for daily usage
- ready to be shown on GitHub as a serious app project

---

## CI / GitHub Actions

The repository already includes GitHub Actions workflows for automated checks and deployment flow.

Current workflow support includes:

- CI checks
- formatting / analyze / test flow
- web build pipeline
- Firebase-related deployment setup in the repository configuration

---

## Future Improvement Ideas

- final full localization sweep across every remaining text string
- APK release automation
- richer profile insights
- shareable Wordle results
- cloud sync as an optional feature

---

## Author

**Developed by Ibrahim Elshishtawy**

---

## License

You can add your preferred license here, for example:

- MIT
- Apache 2.0
- Proprietary / Personal Project

If you want, I can also prepare a matching `LICENSE` file for the repo.
