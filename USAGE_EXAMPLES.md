# Refer Me Usage Examples

This document provides comprehensive examples of how to use the `refer_me` package in your Flutter applications with dependency injection and app_links deep link handling.

## Table of Contents

1. [Basic Setup](#basic-setup)
2. [Dependency Injection](#dependency-injection)
3. [Deep Link Handling](#deep-link-handling)
4. [Simple Usage](#simple-usage)
5. [Advanced Usage](#advanced-usage)
6. [Error Handling](#error-handling)
7. [Integration Patterns](#integration-patterns)
8. [Testing](#testing)

## Basic Setup

### 1. Add to pubspec.yaml

```yaml
dependencies:
  refer_me: ^0.1.0
```

### 2. Initialize with Dependency Injection

```dart
import 'package:flutter/material.dart';
import 'package:refer_me/refer_me.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await ReferralService.init(apiKey: 'your_api_key_here');
  
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

## Dependency Injection

### Service Locator Pattern

```dart
class MyService {
  void doSomething() {
    // Get the referral service from the service locator
    final referralService = ReferralService.referralService;
    
    // Use the service
    referralService.createShortLink(referrerId: 'USER123');
  }
}
```

### Constructor Injection (Recommended)

```dart
class ReferralManager {
  final IReferralService _referralService;

  ReferralManager(this._referralService);

  Future<String?> generateLink(String userId) async {
    return await _referralService.createShortLink(referrerId: userId);
  }
}

// Usage
final manager = ReferralManager(ReferralService.referralService);
```

### Custom Configuration

```dart
class ReferralConfiguration {
  static Future<void> initializeWithConfig({
    required String apiKey,
    String? baseUrl,
  }) async {
    // Reset existing dependencies
    await ReferralService.reset();
    
    // Register with custom configuration
    getIt.registerLazySingleton<IReferralService>(
      () => ReferralClient(key: apiKey),
    );
  }
}

// Usage
await ReferralConfiguration.initializeWithConfig(
  apiKey: 'your_custom_api_key',
);
```

## Deep Link Handling

### Basic Deep Link Listening

```dart
void setupDeepLinkListening() {
  final referralService = ReferralService.referralService;
  
  referralService.startLinkListenerWithParameters((parameters) async {
    print('Deep link received: $parameters');
    
    // Handle the deep link
    await handleDeepLink(parameters);
  });
}

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

### Advanced Deep Link Routing

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

### Initial Link Detection

```dart
Future<void> checkInitialLink() async {
  final referralService = ReferralService.referralService;
  
  // Get initial link parameters
  final initialParameters = await referralService.getInitialLink();
  if (initialParameters != null) {
    print('App was launched via deep link!');
    print('Initial link parameters: $initialParameters');
    
    // Handle the initial link
    await handleDeepLink(initialParameters);
  } else {
    print('App was launched normally (no deep link)');
  }
  
  // Get initial token specifically
  final initialToken = await referralService.getInitialToken();
  if (initialToken != null) {
    print('Initial token found: $initialToken');
    await processReferralToken(initialToken);
  }
}
```

## Simple Usage

### Generate a Referral Link

```dart
Future<void> generateReferralLink(String userId) async {
  try {
    final referralService = ReferralService.referralService;
    final shortLink = await referralService.createShortLink(referrerId: userId);
    
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
  final referralService = ReferralService.referralService;
  final shortLink = await referralService.createShortLink(referrerId: userId);
  
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
    final referralService = ReferralService.referralService;
    final result = await referralService.confirmInstall(token: token);
    
    if (result != null) {
      print('Referral confirmed!');
      print('Referral data: $result');
    } else {
      print('Failed to confirm referral');
    }
  } catch (e) {
    print('Error confirming referral: $e');
  }
}
```

## Advanced Usage

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

### Campaign Tracking

```dart
class CampaignTracker {
  final IReferralService _referralService;
  
  CampaignTracker(this._referralService);
  
  Future<void> trackCampaign(Map<String, String> parameters) async {
    final campaignId = parameters['campaign'];
    final source = parameters['source'];
    final medium = parameters['medium'];
    final term = parameters['term'];
    
    if (campaignId != null) {
      print('Tracking campaign: $campaignId');
      print('Source: $source, Medium: $medium, Term: $term');
      
      // Implement your campaign tracking logic here
      // This could involve analytics, user segmentation, etc.
      
      await _logCampaignEvent(campaignId, source, medium, term);
    }
  }
  
  Future<void> _logCampaignEvent(String campaign, String? source, String? medium, String? term) async {
    // Log campaign event to your analytics service
    print('Campaign event logged: $campaign from $source via $medium');
  }
}
```

### User Referral Management

```dart
class UserReferralManager {
  final IReferralService _referralService;
  final String userId;

  UserReferralManager(this._referralService, this.userId);

  /// Generate and store referral link for user
  Future<String?> generateUserReferralLink() async {
    return await _referralService.createShortLink(referrerId: userId);
  }

  /// Check if user was referred
  Future<bool> checkIfUserWasReferred() async {
    final result = await _referralService.confirmInstallIfPossible();
    return result != null;
  }

  /// Get referral information
  Future<Map<String, dynamic>?> getReferralInfo() async {
    return await _referralService.confirmInstallIfPossible();
  }

  /// Handle deep link manually
  Future<void> handleDeepLink(String link) async {
    final uri = Uri.parse(link);
    final token = uri.queryParameters['uid'] ?? 
                  uri.queryParameters['ref'] ?? 
                  uri.queryParameters['code'];
    
    if (token != null) {
      await _referralService.confirmInstall(token: token);
    }
  }
}
```

## Error Handling

### Comprehensive Error Handling

```dart
class ReferralErrorHandling {
  final IReferralService _referralService;

  ReferralErrorHandling(this._referralService);

  /// Generate link with proper error handling
  Future<String?> generateLinkSafely(String referrerId) async {
    try {
      return await _referralService.createShortLink(referrerId: referrerId);
    } catch (e) {
      // Log the error
      print('Error generating referral link: $e');
      
      // Return null or throw custom exception
      return null;
    }
  }

  /// Confirm install with retry logic
  Future<Map<String, dynamic>?> confirmInstallWithRetry(String token, {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final result = await _referralService.confirmInstall(token: token);
        return result;
      } catch (e) {
        print('Attempt ${i + 1} failed: $e');
        if (i == maxRetries - 1) {
          rethrow;
        }
        // Wait before retry
        await Future.delayed(Duration(seconds: 1 << i)); // Exponential backoff
      }
    }
    return null;
  }
}
```

### Deep Link Error Handling

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

## Integration Patterns

### Service Integration

```dart
class AppService {
  final IReferralService _referralService;
  final AnalyticsService _analytics;
  final UserService _userService;
  
  AppService(this._referralService, this._analytics, this._userService);
  
  Future<void> handleReferralFlow() async {
    // Check if user was referred
    final referralInfo = await _referralService.confirmInstallIfPossible();
    
    if (referralInfo != null) {
      // Track referral event
      await _analytics.trackEvent('referral_received', {
        'referral_code': referralInfo['referralCode'],
        'device_id': referralInfo['deviceId'],
      });
      
      // Update user profile
      await _userService.updateReferralInfo(referralInfo);
      
      // Show referral reward UI
      showReferralReward(referralInfo);
    }
  }
}
```

### State Management Integration

```dart
class ReferralBloc extends Bloc<ReferralEvent, ReferralState> {
  final IReferralService _referralService;
  
  ReferralBloc(this._referralService) : super(ReferralInitial()) {
    on<GenerateReferralLink>(_onGenerateReferralLink);
    on<ConfirmReferral>(_onConfirmReferral);
    on<CheckReferralStatus>(_onCheckReferralStatus);
  }
  
  Future<void> _onGenerateReferralLink(
    GenerateReferralLink event,
    Emitter<ReferralState> emit,
  ) async {
    emit(ReferralLoading());
    
    try {
      final link = await _referralService.createShortLink(referrerId: event.userId);
      emit(ReferralLinkGenerated(link));
    } catch (e) {
      emit(ReferralError(e.toString()));
    }
  }
  
  Future<void> _onConfirmReferral(
    ConfirmReferral event,
    Emitter<ReferralState> emit,
  ) async {
    emit(ReferralLoading());
    
    try {
      final result = await _referralService.confirmInstall(token: event.token);
      emit(ReferralConfirmed(result));
    } catch (e) {
      emit(ReferralError(e.toString()));
    }
  }
  
  Future<void> _onCheckReferralStatus(
    CheckReferralStatus event,
    Emitter<ReferralState> emit,
  ) async {
    emit(ReferralLoading());
    
    try {
      final result = await _referralService.confirmInstallIfPossible();
      if (result != null) {
        emit(ReferralConfirmed(result));
      } else {
        emit(ReferralNotConfirmed());
      }
    } catch (e) {
      emit(ReferralError(e.toString()));
    }
  }
}
```

## Testing

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

void tearDown() async {
  // Clean up
  await ReferralService.reset();
}

class MockReferralService implements IReferralService {
  @override
  Future<String?> createShortLink({required String referrerId}) async {
    return 'https://test.com/ref/$referrerId';
  }

  @override
  void startLinkListener() {
    // Mock implementation
  }

  @override
  void startLinkListenerWithParameters(DeepLinkHandler handler) {
    // Mock implementation
  }

  @override
  Future<void> stopLinkListener() async {
    // Mock implementation
  }

  @override
  Future<Map<String, dynamic>?> confirmInstallIfPossible() async {
    return {'referralCode': 'TEST123', 'deviceId': 'test-device'};
  }

  @override
  Future<Map<String, dynamic>?> confirmInstall({required String token}) async {
    return {'referralCode': 'TEST123', 'deviceId': 'test-device'};
  }

  @override
  Future<Map<String, String>?> getInitialLink() async {
    return {'path': '/test', 'token': 'TEST123'};
  }

  @override
  Future<String?> getInitialToken() async {
    return 'TEST123';
  }
}
```

### Test Examples

```dart
test('should generate referral link', () async {
  final manager = ReferralManager(getIt.get<IReferralService>());
  final link = await manager.generateUserReferralLink('USER123');
  
  expect(link, equals('https://test.com/ref/USER123'));
});

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

test('should confirm referral with retry', () async {
  final errorHandler = ReferralErrorHandling(getIt.get<IReferralService>());
  final result = await errorHandler.confirmInstallWithRetry('TEST123');
  
  expect(result, isNotNull);
  expect(result!['referralCode'], equals('TEST123'));
});
```

### Integration Testing

```dart
testWidgets('should handle deep link in widget', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  // Simulate deep link
  final parameters = {'token': 'TEST123', 'source': 'email'};
  await handleDeepLink(parameters);
  
  await tester.pump();
  
  // Verify UI updates
  expect(find.text('Referral Confirmed'), findsOneWidget);
});
```

## Platform-Specific Examples

### iOS Universal Links

```dart
// iOS Info.plist configuration
// Add Associated Domains capability
// Add apple-app-site-association file to your domain

// Handle Universal Links
void setupUniversalLinks() {
  final referralService = ReferralService.referralService;
  
  referralService.startLinkListenerWithParameters((parameters) async {
    // Handle Universal Link parameters
    final token = parameters['token'];
    final campaign = parameters['campaign'];
    
    if (token != null) {
      await referralService.confirmInstall(token: token);
    }
  });
}
```

### Android App Links

```dart
// Android AndroidManifest.xml configuration
// Add intent filters for your domain

// Handle App Links
void setupAppLinks() {
  final referralService = ReferralService.referralService;
  
  referralService.startLinkListenerWithParameters((parameters) async {
    // Handle App Link parameters
    final token = parameters['token'];
    final source = parameters['source'];
    
    if (token != null) {
      await referralService.confirmInstall(token: token);
    }
  });
}
```

This comprehensive guide covers all aspects of using the Refer Me package with dependency injection and app_links deep link handling.
