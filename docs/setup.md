# Setup Guide

This guide walks you through setting up the AlakhService development environment from scratch.

---

## Prerequisites

### Required Tools

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| **Flutter** | 3.22.2 | App framework | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| **Git** | 2.40+ | Version control | [git-scm.com](https://git-scm.com) |
| **Melos** | 6.x | Monorepo management | `dart pub global activate melos` |
| **FVM** | latest | Flutter version management | `dart pub global activate fvm` |

### Platform-Specific Requirements

#### macOS (for iOS builds)
- Xcode 15+ (from Mac App Store)
- CocoaPods: `sudo gem install cocoapods`
- iOS Simulator or physical device

#### All Platforms (for Android builds)
- Android Studio with Android SDK
- Java 17: `brew install openjdk@17` or via Android Studio

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/alakh8653/alakh_service.git
cd alakh_service
```

---

## Step 2: Install the Correct Flutter Version

Using FVM (recommended):

```bash
# Install FVM
dart pub global activate fvm

# Install the pinned Flutter version
fvm install

# Use it in this project
fvm use

# Verify
fvm flutter --version
```

Or install Flutter directly from [flutter.dev](https://flutter.dev/docs/get-started/install) at version **3.22.2**.

---

## Step 3: Install Melos

```bash
dart pub global activate melos

# Verify
melos --version
```

---

## Step 4: Bootstrap the Workspace

```bash
melos bootstrap
```

This runs `flutter pub get` across all apps and packages, linking local package references.

---

## Step 5: Run Code Generation

Several packages use code generators (Freezed, JsonSerializable, Injectable, etc.):

```bash
melos run build:runner
```

This will generate:
- `*.g.dart` — JSON serialization
- `*.freezed.dart` — Immutable data classes
- `*.config.dart` — Dependency injection
- `*.gr.dart` — Type-safe routing

---

## Step 6: Generate Localizations

```bash
melos run gen:l10n
```

This generates ARB-based localizations for all apps.

---

## Step 7: Set Up Environment Variables

Each app uses `--dart-define` for configuration. Create `.env` files (not committed):

```bash
# apps/mobile_app/.env (example)
API_BASE_URL=https://api.dev.alakhservice.com
WS_BASE_URL=wss://ws.dev.alakhservice.com
GOOGLE_MAPS_API_KEY=your_key_here
RAZORPAY_KEY_ID=your_key_here
```

See [`docs/environment-variables.md`](environment-variables.md) for all variables.

---

## Step 8: Add Firebase Config (Mobile App)

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android and iOS apps to the Firebase project
3. Download and place config files:
   - `apps/mobile_app/android/app/google-services.json`
   - `apps/mobile_app/ios/Runner/GoogleService-Info.plist`
4. Run `flutterfire configure` in `apps/mobile_app/` to generate `firebase_options.dart`

---

## Running Apps

### Mobile App (Android)

```bash
cd apps/mobile_app

# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator-id>

# Run dev flavor
flutter run --flavor dev --dart-define=FLAVOR=dev \
  --dart-define=API_BASE_URL=https://api.dev.alakhservice.com
```

### Mobile App (iOS)

```bash
cd apps/mobile_app

# Install pods
cd ios && pod install && cd ..

# Run on simulator
flutter run --flavor dev --dart-define=FLAVOR=dev -d "iPhone 15"
```

### Shop Web Dashboard

```bash
cd apps/shop_web
flutter run -d chrome --dart-define=FLAVOR=dev \
  --dart-define=API_BASE_URL=https://api.dev.alakhservice.com
```

### Admin Web Panel

```bash
cd apps/admin_web
flutter run -d chrome --dart-define=FLAVOR=dev \
  --dart-define=API_BASE_URL=https://api.dev.alakhservice.com
```

---

## Makefile Shortcuts

The root `Makefile` provides shortcuts for common tasks:

```bash
make setup          # Install Melos + bootstrap workspace
make get            # Run flutter pub get everywhere
make build-runner   # Run code generation
make test           # Run all tests
make analyze        # Analyze all code
make format-fix     # Auto-format all code
make ci             # Full CI check (format + analyze + test)
```

---

## Troubleshooting

### `melos bootstrap` fails

```bash
# Ensure you're using the correct Flutter version
flutter --version   # should be 3.22.2

# Clear pub cache and retry
dart pub cache clean
melos clean
melos bootstrap
```

### Build runner fails

```bash
# Delete conflicting outputs and rebuild
melos exec --depends-on=build_runner -- \
  dart run build_runner build --delete-conflicting-outputs
```

### iOS CocoaPods issues

```bash
cd apps/mobile_app/ios
pod deintegrate
pod install --repo-update
```

### Android Gradle issues

```bash
cd apps/mobile_app/android
./gradlew clean
```
