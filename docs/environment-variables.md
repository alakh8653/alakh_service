# Environment Variables

This document lists all environment variables and `--dart-define` values used by the AlakhService apps.

---

## Overview

AlakhService uses `--dart-define` to pass environment-specific values at build time. These are **not** stored in `.env` files that Flutter reads — they are passed directly to the Flutter compiler.

---

## How to Pass Dart Defines

### CLI

```bash
flutter run \
  --dart-define=API_BASE_URL=https://api.dev.alakhservice.com \
  --dart-define=WS_BASE_URL=wss://ws.dev.alakhservice.com \
  --dart-define=FLAVOR=dev
```

### Using a defines file (recommended for development)

```bash
# Create a file: apps/mobile_app/dart_defines/dev.json
{
  "FLAVOR": "dev",
  "API_BASE_URL": "https://api.dev.alakhservice.com",
  "WS_BASE_URL": "wss://ws.dev.alakhservice.com",
  "GOOGLE_MAPS_API_KEY": "your_dev_key",
  "RAZORPAY_KEY_ID": "rzp_test_xxxxxxxx"
}

# Run with the defines file
flutter run --dart-define-from-file=dart_defines/dev.json
```

---

## Variables by App

### Mobile App (`apps/mobile_app`)

| Variable | Type | Required | Dev Example | Description |
|----------|------|----------|-------------|-------------|
| `FLAVOR` | string | ✅ | `dev` | Build flavor: `dev`, `staging`, `production` |
| `API_BASE_URL` | URL | ✅ | `https://api.dev.alakhservice.com` | REST API base URL |
| `WS_BASE_URL` | URL | ✅ | `wss://ws.dev.alakhservice.com` | WebSocket server URL |
| `GOOGLE_MAPS_API_KEY` | string | ✅ | `AIza...` | Google Maps API key |
| `RAZORPAY_KEY_ID` | string | ✅ | `rzp_test_...` | Razorpay payment key |
| `SENTRY_DSN` | URL | ❌ | — | Sentry error reporting DSN |
| `AMPLITUDE_API_KEY` | string | ❌ | — | Amplitude analytics key |
| `FIREBASE_APP_ID_ANDROID` | string | ✅ | — | Firebase Android App ID |
| `FIREBASE_APP_ID_IOS` | string | ✅ | — | Firebase iOS App ID |
| `SUPPORT_EMAIL` | string | ❌ | `support@dev.alakhservice.com` | In-app support email |
| `APP_STORE_URL` | URL | ❌ | — | iOS App Store URL |
| `PLAY_STORE_URL` | URL | ❌ | — | Google Play Store URL |

### Shop Web (`apps/shop_web`)

| Variable | Type | Required | Dev Example | Description |
|----------|------|----------|-------------|-------------|
| `FLAVOR` | string | ✅ | `dev` | Build flavor |
| `API_BASE_URL` | URL | ✅ | `https://api.dev.alakhservice.com` | REST API base URL |
| `WS_BASE_URL` | URL | ✅ | `wss://ws.dev.alakhservice.com` | WebSocket server URL |
| `GOOGLE_MAPS_API_KEY` | string | ✅ | `AIza...` | Google Maps API key (for geo displays) |
| `SENTRY_DSN` | URL | ❌ | — | Sentry DSN |

### Admin Web (`apps/admin_web`)

| Variable | Type | Required | Dev Example | Description |
|----------|------|----------|-------------|-------------|
| `FLAVOR` | string | ✅ | `dev` | Build flavor |
| `API_BASE_URL` | URL | ✅ | `https://api.dev.alakhservice.com` | REST API base URL |
| `WS_BASE_URL` | URL | ✅ | `wss://ws.dev.alakhservice.com` | WebSocket server URL |
| `SENTRY_DSN` | URL | ❌ | — | Sentry DSN |

---

## Environment Tiers

| Tier | API URL | Purpose |
|------|---------|---------|
| `dev` | `https://api.dev.alakhservice.com` | Local development |
| `staging` | `https://api.staging.alakhservice.com` | Pre-production testing |
| `production` | `https://api.alakhservice.com` | Live production |

---

## Reading Variables in Dart

```dart
class AppConfig {
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.dev.alakhservice.com',
  );

  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://ws.dev.alakhservice.com',
  );

  static bool get isProduction => flavor == 'production';
  static bool get isDev => flavor == 'dev';
}
```

---

## CI/CD Secrets

GitHub Actions secrets required for CI/CD pipelines:

| Secret | Used In | Description |
|--------|---------|-------------|
| `CODECOV_TOKEN` | `ci.yml` | Codecov upload token |
| `ANDROID_KEYSTORE_BASE64` | `build-mobile.yml` | Base64-encoded Android keystore |
| `ANDROID_KEYSTORE_PASSWORD` | `build-mobile.yml` | Keystore password |
| `ANDROID_KEY_ALIAS` | `build-mobile.yml` | Key alias |
| `ANDROID_KEY_PASSWORD` | `build-mobile.yml` | Key password |
| `FIREBASE_SERVICE_ACCOUNT_SHOP` | `build-web.yml` | Firebase service account for shop_web |
| `FIREBASE_SERVICE_ACCOUNT_ADMIN` | `build-web.yml` | Firebase service account for admin_web |
| `FIREBASE_PROJECT_ID_SHOP` | `build-web.yml` | Firebase project ID for shop_web |
| `FIREBASE_PROJECT_ID_ADMIN` | `build-web.yml` | Firebase project ID for admin_web |
