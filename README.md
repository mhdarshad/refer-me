# Referral Client

Client SDK for your referral backend (short links, deep links, install confirmation).

## Features

- **Short Link Generation**: Create branded referral links for your users
- **Android Install Referrer**: Deterministic post-install attribution via Play Store Install Referrer
- **iOS Universal Links**: Installed-case deep link attribution via Universal Links
- **Unified API**: Simple, consistent interface for both platforms

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  referral_client:
    path: ../referral_client  # or git: https://github.com/your-repo/referral_client
```

## Quick Start

### 1. Initialize on App Boot

```dart
import 'package:flutter/material.dart';
import 'package:referral_client/refer_me.dart';

late final ReferralClient referral;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  referral = ReferralClient(
    backendBaseUrl: 'https://api.yourdomain.com', // your REST base
    androidPackage: 'com.yourapp',
    appStoreId: '1234567890',
  );

  // 1) Start listening for in-app links (installed case)
  referral.startLinkListener();

  // 2) Try confirming via Android Install Referrer (post-install case)
  await referral.confirmInstallIfPossible();

  runApp(const MyApp());
}
```

### 2. Generate a Short Link to Share

```dart
Future<void> shareMyReferral(String myUserIdOrCode) async {
  final shortLink = await referral.createShortLink(referrerId: myUserIdOrCode);
  // Present in UI / copy / share
  debugPrint('Share this: $shortLink');
}
```

### 3. Manual Confirmation (Optional)

```dart
await referral.confirmInstall(token: 'someTokenYouCaptured');
```

## Backend API Expectations

### POST /create-referral

**Request:**
```json
{
  "referrerId": "USER123"
}
```

**Response:**
```json
{
  "shortLink": "https://go.yourapp.com/aB12xY"
}
```

### GET /:shortId (click handler)

Detect Android/iOS by User-Agent

**Android redirect:**
```
https://play.google.com/store/apps/details?id=com.yourapp&referrer=uniqueId=<UUIDv4>
```

**iOS redirect:**
Universal link or App Store (append `?ref=<token>` for installed-case deep link)

**Record:**
```json
{
  "shortId": "aB12xY",
  "token": "unique per click",
  "referrerId": "USER123",
  "ip": "user_ip",
  "ua": "user_agent",
  "clickedAt": "timestamp"
}
```

### POST /confirm-install

**Request:**
```json
{
  "referrerToken": "<token>",
  "deviceId": "<idfv/androidId_fallback>"
}
```

**Response:**
```json
{
  "success": true,
  "referralCode": "USER123"
}
```

## Platform Setup

### Android

No extra setup needed for Install Referrer. Ensure your Play Store redirect uses a unique per-click token (UUID) in `&referrer=`.

### iOS

Set up Associated Domains + `apple-app-site-association` on your universal link domain so links like `https://links.yourdomain.com/r?uid=...` open the app when installed.

## Package Structure

```
referral_client/
├─ pubspec.yaml
└─ lib/
    ├─ referral_client.dart
    └─ src/
        ├─ referral_service.dart
        ├─ android_install_referrer.dart
        └─ link_listener.dart
```

## Dependencies

- `http: ^1.2.2` - HTTP client for API calls
- `install_referrer: ^1.1.2` - Android Play Install Referrer
- `uni_links2: ^0.6.0` - Universal/App Links (iOS & Android)
- `device_info_plus: ^11.0.0` - Lightweight device identifier
- `crypto: ^3.0.3` - Hash util (optional)
- `meta: ^1.15.0` - Metadata annotations

## License

This project is licensed under the MIT License.
