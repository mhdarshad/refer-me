# App Links Deep Link Handling Guide

This guide explains how to use app_links for deep link handling in your Refer Me Flutter app, providing full access to link parameters and flexible routing.

## Overview

The Refer Me SDK now uses the `app_links` package for deep link handling, which provides:

- **Universal Links Support**: iOS and Android deep link handling
- **Full Parameter Access**: Access to all query parameters and path segments
- **Initial Link Detection**: Handle links that launched the app
- **Flexible Routing**: Custom routing based on paths and parameters
- **Error Handling**: Robust error handling and logging

## Setup

### 1. Dependencies

The `app_links` package is already included in `pubspec.yaml`:

```yaml
dependencies:
  app_links: ^3.4.5
```

### 2. Platform Configuration

#### iOS Configuration

Add to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>referme</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>referme</string>
        </array>
    </dict>
</array>
```

For Universal Links, add to `ios/Runner/Info.plist`:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:yourdomain.com</string>
</array>
```

#### Android Configuration

Add to `android/app/src/main/AndroidManifest.xml` inside the `<activity>` tag:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="referme" />
</intent-filter>

<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" 
          android:host="yourdomain.com" />
</intent-filter>
```

## Basic Usage

### Initialize with Deep Link Support

```dart
import 'package:refer_me/refer_me.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize referral service
  await ReferralService.init(apiKey: 'your_api_key');
  
  final referralService = ReferralService.referralService;
  
  // Start listening for deep links with full parameter access
  referralService.startLinkListenerWithParameters((parameters) async {
    print('Deep link received: $parameters');
    
    // Handle the deep link
    await handleDeepLink(parameters);
  });
  
  // Check for initial link that launched the app
  final initialLink = await referralService.getInitialLink();
  if (initialLink != null) {
    print('App launched via deep link: $initialLink');
    await handleDeepLink(initialLink);
  }
  
  runApp(MyApp());
}
```

### Handle Deep Link Parameters

```dart
Future<void> handleDeepLink(Map<String, String> parameters) async {
  // Extract common referral parameters
  final token = parameters['uid'] ?? 
                parameters['ref'] ?? 
                parameters['code'] ?? 
                parameters['token'] ?? 
                parameters['referral'];
  
  final campaign = parameters['campaign'];
  final source = parameters['source'];
  final medium = parameters['medium'];
  
  // Handle referral token
  if (token != null) {
    final referralService = ReferralService.referralService;
    final result = await referralService.confirmInstall(token: token);
    
    if (result != null) {
      print('Referral confirmed: $result');
      // Show reward UI or handle referral
    }
  }
  
  // Handle campaign tracking
  if (campaign != null) {
    print('Campaign: $campaign from $source via $medium');
    // Track campaign analytics
  }
}
```

## Advanced Usage

### Custom Deep Link Routing

```dart
class DeepLinkRouter {
  final IReferralService _referralService;
  
  DeepLinkRouter(this._referralService);
  
  void startListening() {
    _referralService.startLinkListenerWithParameters((parameters) async {
      await routeDeepLink(parameters);
    });
  }
  
  Future<void> routeDeepLink(Map<String, String> parameters) async {
    final path = parameters['path'];
    final action = parameters['action'];
    
    switch (path) {
      case '/referral':
        await handleReferral(parameters);
        break;
      case '/campaign':
        await handleCampaign(parameters);
        break;
      case '/invite':
        await handleInvite(parameters);
        break;
      case '/share':
        await handleShare(parameters);
        break;
      default:
        await handleDefault(parameters);
    }
  }
  
  Future<void> handleReferral(Map<String, String> parameters) async {
    final token = parameters['token'] ?? parameters['code'];
    if (token != null) {
      await _referralService.confirmInstall(token: token);
    }
  }
  
  Future<void> handleCampaign(Map<String, String> parameters) async {
    final campaignId = parameters['id'];
    final source = parameters['source'];
    
    print('Campaign: $campaignId from $source');
    // Implement campaign tracking
  }
  
  Future<void> handleInvite(Map<String, String> parameters) async {
    final inviteCode = parameters['code'];
    final inviterId = parameters['inviter'];
    
    print('Invite: $inviteCode from $inviterId');
    // Implement invite logic
  }
  
  Future<void> handleShare(Map<String, String> parameters) async {
    final userId = parameters['user'];
    final message = parameters['message'];
    
    if (userId != null) {
      final link = await _referralService.createShortLink(referrerId: userId);
      print('Share: $link with message: $message');
    }
  }
  
  Future<void> handleDefault(Map<String, String> parameters) async {
    print('Default handling: $parameters');
  }
}
```

### Widget Integration

```dart
class ReferralWidget extends StatefulWidget {
  @override
  _ReferralWidgetState createState() => _ReferralWidgetState();
}

class _ReferralWidgetState extends State<ReferralWidget> {
  late final IReferralService _referralService;
  late final DeepLinkRouter _router;
  
  @override
  void initState() {
    super.initState();
    _referralService = ReferralService.referralService;
    _router = DeepLinkRouter(_referralService);
    _router.startListening();
  }
  
  @override
  void dispose() {
    _referralService.stopLinkListener();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _shareReferralLink,
      child: Text('Share Referral Link'),
    );
  }
  
  Future<void> _shareReferralLink() async {
    final link = await _referralService.createShortLink(referrerId: 'USER123');
    if (link != null) {
      // Share the link
      print('Share: $link');
    }
  }
}
```

## Deep Link Examples

### Referral Links

```
referme://referral?token=ABC123&source=email&campaign=winter2024
https://yourdomain.com/referral?token=ABC123&source=email&campaign=winter2024
```

### Campaign Links

```
referme://campaign?id=winter2024&source=social&medium=facebook
https://yourdomain.com/campaign?id=winter2024&source=social&medium=facebook
```

### Invite Links

```
referme://invite?code=INVITE456&inviter=user789&message=Join%20me!
https://yourdomain.com/invite?code=INVITE456&inviter=user789&message=Join%20me!
```

### Share Links

```
referme://share?user=user123&message=Check%20out%20this%20app!
https://yourdomain.com/share?user=user123&message=Check%20out%20this%20app!
```

## Parameter Reference

### Common Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `path` | URL path segment | `/referral` |
| `scheme` | URL scheme | `referme`, `https` |
| `host` | URL host | `yourdomain.com` |
| `uid`, `ref`, `code`, `token`, `referral` | Referral token | `ABC123` |
| `campaign` | Campaign identifier | `winter2024` |
| `source` | Traffic source | `email`, `social` |
| `medium` | Traffic medium | `facebook`, `twitter` |
| `action` | Action to perform | `share`, `invite` |

### Path Segments

For URLs like `referme://app/referral/ABC123`, the parameters will include:

```dart
{
  'path': '/referral/ABC123',
  'segment_0': 'referral',
  'segment_1': 'ABC123',
  'scheme': 'referme',
  'host': 'app'
}
```

## Testing Deep Links

### iOS Simulator

```bash
# Test custom scheme
xcrun simctl openurl booted "referme://referral?token=TEST123"

# Test Universal Link
xcrun simctl openurl booted "https://yourdomain.com/referral?token=TEST123"
```

### Android Emulator

```bash
# Test custom scheme
adb shell am start -W -a android.intent.action.VIEW -d "referme://referral?token=TEST123" com.yourapp.package

# Test Universal Link
adb shell am start -W -a android.intent.action.VIEW -d "https://yourdomain.com/referral?token=TEST123" com.yourapp.package
```

### Programmatic Testing

```dart
class DeepLinkTester {
  static Future<void> testDeepLinks() async {
    final testLinks = [
      'referme://referral?token=TEST123&source=email',
      'https://yourdomain.com/campaign?id=winter2024&source=social',
      'referme://invite?code=INVITE456&inviter=user789',
    ];
    
    for (final link in testLinks) {
      print('Testing: $link');
      // Simulate deep link handling
    }
  }
}
```

## Error Handling

```dart
void startDeepLinkListening() {
  final referralService = ReferralService.referralService;
  
  referralService.startLinkListenerWithParameters((parameters) async {
    try {
      await handleDeepLink(parameters);
    } catch (e) {
      print('Error handling deep link: $e');
      // Handle error gracefully
    }
  });
}

Future<void> handleDeepLink(Map<String, String> parameters) async {
  // Validate parameters
  if (!DeepLinkConfig.isSupportedLink(parameters)) {
    print('Unsupported deep link: $parameters');
    return;
  }
  
  // Extract and validate token
  final token = DeepLinkConfig.extractToken(parameters);
  if (token == null) {
    print('No valid token found in deep link');
    return;
  }
  
  // Process the deep link
  final referralService = ReferralService.referralService;
  final result = await referralService.confirmInstall(token: token);
  
  if (result != null) {
    print('Deep link processed successfully: $result');
  } else {
    print('Failed to process deep link');
  }
}
```

## Best Practices

### 1. Validate Deep Links

Always validate deep links before processing:

```dart
bool isValidDeepLink(Map<String, String> parameters) {
  final scheme = parameters['scheme'];
  final host = parameters['host'];
  
  // Check if it's a supported scheme/host
  return scheme == 'referme' || host == 'yourdomain.com';
}
```

### 2. Handle Initial Links

Always check for initial links that launched the app:

```dart
Future<void> checkInitialLink() async {
  final referralService = ReferralService.referralService;
  final initialLink = await referralService.getInitialLink();
  
  if (initialLink != null) {
    await handleDeepLink(initialLink);
  }
}
```

### 3. Use Proper Error Handling

Implement robust error handling for deep link processing:

```dart
Future<void> processDeepLink(Map<String, String> parameters) async {
  try {
    // Process the deep link
    await handleDeepLink(parameters);
  } catch (e) {
    print('Error processing deep link: $e');
    // Log error, show user-friendly message, etc.
  }
}
```

### 4. Test Thoroughly

Test deep links on both platforms and in different scenarios:

- App closed (cold start)
- App in background
- App in foreground
- Different link formats
- Invalid links

## Troubleshooting

### Common Issues

1. **Deep links not working on iOS**: Check Universal Links configuration
2. **Deep links not working on Android**: Verify intent filters in AndroidManifest.xml
3. **Parameters not being received**: Check URL encoding and parameter names
4. **Initial link not detected**: Ensure proper initialization order

### Debug Mode

Enable debug logging for app_links:

```dart
void main() async {
  // Enable debug logging
  // Note: app_links doesn't have built-in debug mode, but you can add logging
  
  await ReferralService.init(apiKey: 'your_api_key');
  
  final referralService = ReferralService.referralService;
  referralService.startLinkListenerWithParameters((parameters) async {
    print('DEBUG: Deep link received: $parameters');
    await handleDeepLink(parameters);
  });
  
  runApp(MyApp());
}
```

## API Reference

### IReferralService Methods

- `startLinkListenerWithParameters(handler)`: Start listening with full parameter access
- `getInitialLink()`: Get initial link that launched the app
- `getInitialToken()`: Get initial token from launch link

### LinkListener Methods

- `listen(handler)`: Listen for deep links with parameters
- `listenForToken(handler)`: Listen for deep links and extract token
- `getInitialLink()`: Get initial link parameters
- `getInitialToken()`: Get initial token
- `dispose()`: Clean up listener

The app_links integration provides a robust and flexible solution for handling deep links in your Refer Me Flutter app.
