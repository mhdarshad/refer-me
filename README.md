# Refer Me - Flutter Referral SDK

A comprehensive Flutter SDK for implementing referral systems with deep link handling, dependency injection, and cross-platform support.

## 🚀 Features

- **🔗 Deep Link Handling**: Full app_links integration with parameter extraction
- **💉 Dependency Injection**: Built-in DI with get_it for better testability
- **🔧 Debug Mode**: Comprehensive logging for development and troubleshooting
- **📱 Cross-Platform**: iOS and Android support with Universal Links
- **🔗 Short Link Generation**: Create branded referral links for your users
- **📊 Install Attribution**: Post-install attribution via Play Store Install Referrer
- **🎯 Campaign Tracking**: Advanced campaign and source tracking
- **🧪 Testing Support**: Comprehensive testing utilities and mock services
- **📚 Documentation**: Extensive guides and examples

## 📦 Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  refer_me: ^0.1.0
```

## ⚡ Quick Start

### 1. Initialize with Dependency Injection

```dart
import 'package:flutter/material.dart';
import 'package:refer_me/refer_me.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection with debug mode
  await ReferralService.init(
    apiKey: 'your_api_key_here',
    debugMode: true, // Enable debug logging
  );
  
  final referralService = ReferralService.referralService;

  // Start listening for deep links with full parameter access
  referralService.startLinkListenerWithParameters((parameters) async {
    print('Deep link received: $parameters');
    
    // Extract token and handle referral
    final token = parameters['uid'] ?? 
                  parameters['ref'] ?? 
                  parameters['code'] ?? 
                  parameters['token'] ?? 
                  parameters['referral'];
    
    if (token != null) {
      await referralService.confirmInstall(token: token);
    }
  });

  // Check for initial link that launched the app
  final initialLink = await referralService.getInitialLink();
  if (initialLink != null) {
    print('App launched via deep link: $initialLink');
  }

  // Check for install referrer
  await referralService.confirmInstallIfPossible();

  runApp(MyApp());
}
```

### 2. Generate and Share Referral Links

```dart
class ReferralManager {
  final IReferralService _referralService;

  ReferralManager(this._referralService);

  Future<void> shareReferralLink(String userId) async {
    final shortLink = await _referralService.createShortLink(referrerId: userId);
    
    if (shortLink != null) {
      print('Share this link: $shortLink');
      // Use share_plus package to share the link
      // await Share.share('Check out this app! $shortLink');
    }
  }
}

// Usage
final manager = ReferralManager(ReferralService.referralService);
await manager.shareReferralLink('USER123');
```

### 3. Advanced Deep Link Routing

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
    final token = parameters['token'];
    final campaign = parameters['campaign'];
    
    switch (path) {
      case '/referral':
        if (token != null) {
          await _referralService.confirmInstall(token: token);
        }
        break;
      case '/campaign':
        print('Campaign: $campaign');
        // Handle campaign tracking
        break;
      default:
        print('Default handling: $parameters');
    }
  }
}
```

## 🔗 Deep Link Examples

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

## 🧪 Testing

### Mock Service Setup

```dart
void setUp() async {
  // Reset dependencies
  await ReferralService.reset();
  
  // Register mock service
  getIt.registerLazySingleton<IReferralService>(
    () => MockReferralService(),
  );
}

class MockReferralService implements IReferralService {
  @override
  Future<String?> createShortLink({required String referrerId}) async {
    return 'https://test.com/ref/$referrerId';
  }
  
  // ... implement other methods
}
```

### Test Deep Links

```dart
test('should handle deep link parameters', () async {
  final parameters = {
    'path': '/referral',
    'token': 'TEST123',
    'source': 'email',
    'campaign': 'winter2024'
  };
  
  await handleDeepLink(parameters);
  
  // Verify the behavior
});
```

## 📚 Documentation

- **[Dependency Injection Guide](DEPENDENCY_INJECTION_GUIDE.md)** - Complete DI setup and usage
- **[App Links Guide](APP_LINKS_GUIDE.md)** - Deep link handling with app_links
- **[Usage Examples](USAGE_EXAMPLES.md)** - Comprehensive usage examples
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues and solutions

## 🏗️ Architecture

### Dependency Injection
- **Service Locator Pattern**: Using get_it for dependency management
- **Interface-based Design**: IReferralService for better testability
- **Singleton Management**: Automatic lifecycle management
- **Configuration Management**: Flexible API key and configuration setup

### Deep Link Handling
- **app_links Integration**: Universal deep link support
- **Parameter Extraction**: Full access to all link parameters
- **Initial Link Detection**: Handle links that launched the app
- **Flexible Routing**: Custom routing based on paths and parameters

### Platform Support
- **iOS**: Universal Links and custom URL schemes
- **Android**: App Links and Play Store Install Referrer
- **Cross-Platform**: Consistent API across platforms

## 📦 Dependencies

- `http: ^1.2.2` - HTTP client for API calls
- `app_links: ^3.4.5` - Universal deep link handling
- `device_info_plus: ^11.0.0` - Device identification
- `get_it: ^7.6.7` - Dependency injection
- `crypto: ^3.0.3` - Hash utilities
- `meta: ^1.15.0` - Metadata annotations

## 🔧 Platform Setup

### iOS Configuration

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

### Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="referme" />
</intent-filter>
```

## 🚀 Getting Started

1. **Install the package**: Add `refer_me: ^0.1.0` to your `pubspec.yaml`
2. **Initialize DI**: Call `ReferralService.init(apiKey: 'your_key', debugMode: true)`
3. **Setup deep links**: Configure platform-specific deep link handling
4. **Start listening**: Use `startLinkListenerWithParameters()` for full control
5. **Generate links**: Create referral links with `createShortLink()`

## 🔧 Debug Mode

Enable comprehensive logging for development and troubleshooting:

```dart
// Development with full logging
await ReferralService.init(
  apiKey: 'your_api_key',
  debugMode: true, // Shows all operations, requests, and responses
);

// Production with no logging
await ReferralService.init(
  apiKey: 'your_api_key',
  debugMode: false, // Silent operation (default)
);
```

**Debug Mode Features:**
- 🔍 Detailed operation logging
- 📡 HTTP request/response logging
- 🔐 Secure API key masking
- 📱 Device information logging
- 🔗 Deep link parameter logging
- ⚡ Performance tracking
- 🛡️ Error handling with context

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For support, please open an issue on GitHub or contact the maintainers.
