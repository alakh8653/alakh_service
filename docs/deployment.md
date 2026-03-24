# Deployment Guide

This guide covers deploying AlakhService apps to production.

---

## Table of Contents

- [Android (Google Play Store)](#android-google-play-store)
- [iOS (Apple App Store)](#ios-apple-app-store)
- [Web — Firebase Hosting](#web--firebase-hosting)
- [CI/CD Automated Deployment](#cicd-automated-deployment)

---

## Android (Google Play Store)

### Prerequisites

- Google Play Console account
- A release keystore (`.jks` file)
- App registered on Play Console

### Step 1: Generate a Release Keystore

```bash
keytool -genkey -v \
  -keystore alakhservice-release.jks \
  -alias alakhservice \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

> ⚠️ Store the keystore and passwords securely. You **cannot** re-sign an app with a different keystore once published.

### Step 2: Configure Signing in Android

Create `apps/mobile_app/android/key.properties` (do NOT commit):

```properties
storePassword=<keystore_password>
keyPassword=<key_password>
keyAlias=alakhservice
storeFile=../alakhservice-release.jks
```

### Step 3: Build Release APK / AAB

```bash
cd apps/mobile_app

# Build App Bundle (recommended for Play Store)
flutter build appbundle \
  --flavor production \
  --dart-define=FLAVOR=production \
  --dart-define=API_BASE_URL=https://api.alakhservice.com \
  --dart-define=WS_BASE_URL=wss://ws.alakhservice.com
```

The AAB will be at:
`build/app/outputs/bundle/productionRelease/app-production-release.aab`

### Step 4: Upload to Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Navigate to your app → **Release** → **Production**
3. Create a new release and upload the `.aab`
4. Add release notes
5. Submit for review

---

## iOS (Apple App Store)

### Prerequisites

- Apple Developer Program membership
- App registered on App Store Connect
- Certificates and provisioning profiles configured

### Step 1: Configure Signing in Xcode

1. Open `apps/mobile_app/ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target
3. Under **Signing & Capabilities**, select your team
4. Create a distribution certificate if needed

### Step 2: Build Archive

```bash
cd apps/mobile_app

# Install pods
cd ios && pod install && cd ..

# Build for production
flutter build ios \
  --flavor production \
  --dart-define=FLAVOR=production \
  --dart-define=API_BASE_URL=https://api.alakhservice.com \
  --dart-define=WS_BASE_URL=wss://ws.alakhservice.com \
  --release
```

### Step 3: Archive in Xcode

1. Open Xcode → **Product** → **Archive**
2. Once archived, in the **Organizer**: **Distribute App**
3. Choose **App Store Connect** → **Upload**

### Step 4: Submit on App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to your app → **TestFlight** or **App Store**
3. Select the uploaded build
4. Fill in metadata (screenshots, description, keywords)
5. Submit for review

---

## Web — Firebase Hosting

### Prerequisites

- Firebase project created
- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase Hosting configured for `shop_web` and `admin_web`

### Step 1: Build Web Apps

```bash
# Shop Web
cd apps/shop_web
flutter build web \
  --dart-define=FLAVOR=production \
  --dart-define=API_BASE_URL=https://api.alakhservice.com

# Admin Web
cd ../admin_web
flutter build web \
  --dart-define=FLAVOR=production \
  --dart-define=API_BASE_URL=https://api.alakhservice.com
```

### Step 2: Configure Firebase Hosting

Create `apps/shop_web/firebase.json`:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      },
      {
        "source": "index.html",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache"
          }
        ]
      }
    ]
  }
}
```

### Step 3: Deploy

```bash
# Login to Firebase
firebase login

# Deploy shop_web
cd apps/shop_web
firebase deploy --project <your-firebase-project-id>

# Deploy admin_web
cd ../admin_web
firebase deploy --project <your-admin-firebase-project-id>
```

---

## CI/CD Automated Deployment

### Automated via GitHub Actions

| Trigger | Workflow | Action |
|---------|---------|--------|
| `git tag v1.0.0` | `build-mobile.yml` | Build signed APK/AAB, create GitHub Release |
| `git tag v1.0.0` | `build-web.yml` | Build and deploy to Firebase Hosting |
| Manual dispatch | `build-mobile.yml` | Build for selected flavor |
| Manual dispatch | `build-web.yml` | Build and optionally deploy web apps |

### Required GitHub Secrets

Set these in **Repository Settings → Secrets and variables → Actions**:

| Secret | Value |
|--------|-------|
| `ANDROID_KEYSTORE_BASE64` | `base64 < alakhservice-release.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias |
| `ANDROID_KEY_PASSWORD` | Key password |
| `FIREBASE_SERVICE_ACCOUNT_SHOP` | Firebase service account JSON (base64) |
| `FIREBASE_SERVICE_ACCOUNT_ADMIN` | Firebase service account JSON (base64) |
| `FIREBASE_PROJECT_ID_SHOP` | Firebase project ID for shop |
| `FIREBASE_PROJECT_ID_ADMIN` | Firebase project ID for admin |
| `CODECOV_TOKEN` | Codecov upload token |

### Triggering a Release

```bash
# Tag and push
git tag v1.2.0
git push origin v1.2.0
```

This automatically:
1. Builds the signed Android APK and AAB
2. Builds the iOS app
3. Creates a GitHub Release with APK/AAB attached
4. Builds and deploys shop_web and admin_web to Firebase Hosting
