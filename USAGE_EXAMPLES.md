# Referral Client Usage Examples

This document provides comprehensive examples of how to use the `referral_client` package in your Flutter applications.

## Table of Contents

1. [Basic Setup](#basic-setup)
2. [Simple Usage](#simple-usage)
3. [Advanced Usage](#advanced-usage)
4. [Error Handling](#error-handling)
5. [Integration Patterns](#integration-patterns)
6. [Testing](#testing)

## Basic Setup

### 1. Add to pubspec.yaml

```yaml
dependencies:
  referral_client:
    path: ../referral_client  # or git: https://github.com/your-repo/referral_client
```

### 2. Initialize in main.dart

```dart
import 'package:flutter/material.dart';
import 'package:referral_client/refer_me.dart';

late final ReferralClient referral;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the referral client
  referral = ReferralClient(
    backendBaseUrl: 'https://api.yourdomain.com',
    androidPackage: 'com.yourapp',
    appStoreId: '1234567890',
  );

  // Start listening for deep links
  referral.startLinkListener();

  // Check for install referrer
  await referral.confirmInstallIfPossible();

  runApp(const MyApp());
}
```

## Simple Usage

### Generate a Referral Link

```dart
Future<void> generateReferralLink(String userId) async {
  try {
    final shortLink = await referral.createShortLink(referrerId: userId);
    
    if (shortLink != null) {
      print('Generated referral link: $shortLink');
      // Share this link with others
    } else {
      print('Failed to generate referral link');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Share Referral Link

```dart
Future<void> shareReferralLink(String userId) async {
  final shortLink = await referral.createShortLink(referrerId: userId);
  
  if (shortLink != null) {
    // Using share_plus package
    await Share.share(
      'Check out this amazing app! $shortLink',
      subject: 'App Referral',
    );
  }
}
```

### Manual Confirmation

```dart
Future<void> confirmReferral(String token) async {
  try {
    final result = await referral.confirmInstall(token: token);
    
    if (result != null) {
      print('Referral confirmed!');
      print('Referral code: ${result['referralCode']}');
    } else {
      print('Failed to confirm referral');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## Advanced Usage

### User Referral Manager

```dart
class UserReferralManager {
  final ReferralClient referral;
  final String userId;

  UserReferralManager(this.referral, this.userId);

  /// Generate referral link for user
  Future<String?> generateReferralLink() async {
    return await referral.createShortLink(referrerId: userId);
  }

  /// Check if user was referred
  Future<bool> wasReferred() async {
    final result = await referral.confirmInstallIfPossible();
    return result != null;
  }

  /// Get referral information
  Future<Map<String, dynamic>?> getReferralInfo() async {
    return await referral.confirmInstallIfPossible();
  }

  /// Handle deep link manually
  Future<void> handleDeepLink(String link) async {
    final uri = Uri.parse(link);
    final token = uri.queryParameters['uid'] ?? 
                  uri.queryParameters['ref'] ?? 
                  uri.queryParameters['code'];
    
    if (token != null) {
      await referral.confirmInstall(token: token);
    }
  }
}
```

### Referral Analytics

```dart
class ReferralAnalytics {
  final ReferralClient referral;

  ReferralAnalytics(this.referral);

  /// Track referral generation
  Future<void> trackReferralGenerated(String userId) async {
    final link = await referral.createShortLink(referrerId: userId);
    
    if (link != null) {
      // Send analytics event
      await _sendAnalyticsEvent('referral_generated', {
        'userId': userId,
        'link': link,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Track referral confirmation
  Future<void> trackReferralConfirmed(Map<String, dynamic> result) async {
    await _sendAnalyticsEvent('referral_confirmed', {
      'referralCode': result['referralCode'],
      'deviceId': result['deviceId'],
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _sendAnalyticsEvent(String event, Map<String, dynamic> data) async {
    // Implement your analytics tracking here
    print('Analytics: $event - $data');
  }
}
```

## Error Handling

### Robust Error Handling

```dart
class ReferralErrorHandler {
  final ReferralClient referral;

  ReferralErrorHandler(this.referral);

  /// Generate link with retry logic
  Future<String?> generateLinkWithRetry(String referrerId, {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await referral.createShortLink(referrerId: referrerId);
      } catch (e) {
        print('Attempt ${i + 1} failed: $e');
        
        if (i == maxRetries - 1) {
          // Log final failure
          _logError('generate_link_failed', e);
          return null;
        }
        
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: 1 << i));
      }
    }
    return null;
  }

  /// Confirm install with error handling
  Future<Map<String, dynamic>?> confirmInstallSafely(String token) async {
    try {
      return await referral.confirmInstall(token: token);
    } catch (e) {
      _logError('confirm_install_failed', e);
      return null;
    }
  }

  void _logError(String type, dynamic error) {
    // Implement error logging
    print('Error [$type]: $error');
  }
}
```

### Network Error Handling

```dart
class NetworkAwareReferral {
  final ReferralClient referral;

  NetworkAwareReferral(this.referral);

  /// Check network connectivity before making requests
  Future<String?> generateLinkWithNetworkCheck(String referrerId) async {
    if (!await _isNetworkAvailable()) {
      throw Exception('No network connection');
    }

    return await referral.createShortLink(referrerId: referrerId);
  }

  Future<bool> _isNetworkAvailable() async {
    // Implement network connectivity check
    // You can use connectivity_plus package
    return true; // Placeholder
  }
}
```

## Integration Patterns

### State Management Integration

```dart
// Using Provider
class ReferralProvider extends ChangeNotifier {
  final ReferralClient referral;
  String? _referralLink;
  bool _isLoading = false;
  String? _error;

  ReferralProvider(this.referral);

  String? get referralLink => _referralLink;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> generateReferralLink(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _referralLink = await referral.createShortLink(referrerId: userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Using Riverpod
final referralProvider = StateNotifierProvider<ReferralNotifier, ReferralState>((ref) {
  return ReferralNotifier(ReferralClient(
    backendBaseUrl: 'https://api.yourdomain.com',
    androidPackage: 'com.yourapp',
    appStoreId: '1234567890',
  ));
});

class ReferralState {
  final String? referralLink;
  final bool isLoading;
  final String? error;

  ReferralState({
    this.referralLink,
    this.isLoading = false,
    this.error,
  });
}

class ReferralNotifier extends StateNotifier<ReferralState> {
  final ReferralClient referral;

  ReferralNotifier(this.referral) : super(ReferralState());

  Future<void> generateReferralLink(String userId) async {
    state = ReferralState(isLoading: true);

    try {
      final link = await referral.createShortLink(referrerId: userId);
      state = ReferralState(referralLink: link);
    } catch (e) {
      state = ReferralState(error: e.toString());
    }
  }
}
```

### Widget Integration

```dart
class ReferralWidget extends StatefulWidget {
  final String userId;

  const ReferralWidget({super.key, required this.userId});

  @override
  State<ReferralWidget> createState() => _ReferralWidgetState();
}

class _ReferralWidgetState extends State<ReferralWidget> {
  String? _referralLink;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _generateLink,
          child: _isLoading 
            ? const CircularProgressIndicator()
            : const Text('Generate Referral Link'),
        ),
        if (_referralLink != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Referral Link:'),
                const SizedBox(height: 8),
                SelectableText(_referralLink!),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _copyToClipboard(_referralLink!),
                        child: const Text('Copy'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _shareLink(_referralLink!),
                        child: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _generateLink() async {
    setState(() => _isLoading = true);

    try {
      final link = await referral.createShortLink(referrerId: widget.userId);
      setState(() => _referralLink = link);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _shareLink(String link) {
    Share.share('Check out this app! $link');
  }
}
```

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:referral_client/refer_me.dart';

void main() {
  group('ReferralClient', () {
    late ReferralClient client;

    setUp(() {
      client = ReferralClient(
        backendBaseUrl: 'https://api.example.com',
        androidPackage: 'com.example.app',
        appStoreId: '1234567890',
      );
    });

    test('should be created with correct parameters', () {
      expect(client.backendBaseUrl, 'https://api.example.com');
      expect(client.androidPackage, 'com.example.app');
      expect(client.appStoreId, '1234567890');
    });

    test('should generate referral link', () async {
      // Mock the HTTP response
      // You can use http_mock_adapter or similar
      
      final link = await client.createShortLink(referrerId: 'USER123');
      expect(link, isNotNull);
    });
  });
}
```

### Integration Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Referral Integration Tests', () {
    testWidgets('should generate and display referral link', (tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Enter user ID
      await tester.enterText(
        find.byType(TextField),
        'USER123',
      );

      // Tap generate button
      await tester.tap(find.text('Generate Referral Link'));
      await tester.pumpAndSettle();

      // Verify link is displayed
      expect(find.textContaining('https://'), findsOneWidget);
    });
  });
}
```

## Platform-Specific Setup

### Android Setup

1. **Add to AndroidManifest.xml**:
```xml
<activity android:name=".MainActivity">
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="yourdomain.com" />
  </intent-filter>
</activity>
```

2. **Play Store Setup**:
   - Configure your Play Store redirect URL to include the referrer parameter
   - Example: `https://play.google.com/store/apps/details?id=com.yourapp&referrer=uniqueId=UUIDv4`

### iOS Setup

1. **Add to Info.plist**:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>yourdomain.com</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>yourapp</string>
    </array>
  </dict>
</array>
```

2. **Associated Domains**:
   - Add `applinks:yourdomain.com` to your Associated Domains capability
   - Create `apple-app-site-association` file on your domain

## Best Practices

1. **Initialize Early**: Initialize the referral client in `main()` before running the app
2. **Handle Errors**: Always wrap API calls in try-catch blocks
3. **User Experience**: Show loading states and provide feedback
4. **Analytics**: Track referral events for insights
5. **Testing**: Test on real devices, especially for deep links
6. **Security**: Validate tokens and implement rate limiting on your backend
7. **Privacy**: Follow platform guidelines for user data handling

## Troubleshooting

### Common Issues

1. **Deep links not working**:
   - Check Associated Domains setup (iOS)
   - Verify intent filters (Android)
   - Test with real devices

2. **Install referrer not found**:
   - Ensure Play Store redirect includes referrer parameter
   - Check that the app was installed via the Play Store link

3. **Network errors**:
   - Verify backend URL is correct
   - Check network connectivity
   - Implement retry logic

4. **Platform-specific issues**:
   - iOS: Check Universal Links setup
   - Android: Verify Install Referrer permissions

For more detailed examples, see the `example/` directory in the package repository.
