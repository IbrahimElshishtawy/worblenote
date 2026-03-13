# writdle

Flutter productivity app with Firebase integration.

## CI/CD

This project now includes GitHub Actions workflows for:

- `CI`: format check, `flutter analyze`, `flutter test`, and `flutter build web`
- `CD`: Firebase Hosting preview deploys for pull requests and live deploys from `main`

### Required GitHub Secrets

Add this repository secret before using deployment:

- `FIREBASE_SERVICE_ACCOUNT_WRITDLE`: Firebase service account JSON for the `writdle` project

### Deployment Flow

1. Every pull request runs CI and creates a Firebase Hosting preview URL.
2. Every push to `main` runs CI and deploys the web build to the live Firebase Hosting channel.

### Local Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release
```
