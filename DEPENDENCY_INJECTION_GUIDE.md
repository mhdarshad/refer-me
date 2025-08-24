# Dependency Injection Guide for Refer Me

This guide explains how to use dependency injection with the Refer Me SDK to improve testability, maintainability, and code organization.

## Overview

The Refer Me SDK now supports dependency injection using the `get_it` package, which provides:

- **Service Locator Pattern**: Easy access to dependencies throughout your app
- **Singleton Management**: Automatic lifecycle management of services
- **Interface-based Design**: Better testability and loose coupling
- **Configuration Management**: Flexible configuration options

## Setup

### 1. Add Dependencies

The `get_it` package is already included in the `pubspec.yaml`:

```yaml
dependencies:
  get_it: ^7.6.7
```

### 2. Initialize Dependency Injection

In your app's `main()` function:

```dart
import 'package:refer_me/refer_me.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await DependencyInjection.init();
  
  // Start the app
  runApp(MyApp());
}
```

## Basic Usage

### Getting the Referral Service

```dart
import 'package:refer_me/refer_me.dart';

class MyService {
  void doSomething() {
    // Get the referral service from the service locator
    final referralService = getIt.referralService;
    
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
final manager = ReferralManager(getIt.referralService);
```

## Advanced Usage

### Custom Configuration

```dart
class ReferralConfiguration {
  static Future<void> initializeWithConfig({
    required String apiKey,
    String? baseUrl,
  }) async {
    // Reset existing dependencies
    await DependencyInjection.reset();
    
    // Register with custom configuration
    getIt.registerLazySingleton<IReferralService>(
      () => ReferralClient(
        key: apiKey,
      ),
    );
  }
}

// Usage
await ReferralConfiguration.initializeWithConfig(
  apiKey: 'your_custom_api_key',
);
```

### Environment-based Configuration

```dart
// In your build configuration
flutter build apk --dart-define=REFERRAL_API_KEY=your_api_key

// In your code
class ReferralConfiguration {
  static Future<void> initializeFromEnvironment() async {
    const apiKey = String.fromEnvironment('REFERRAL_API_KEY');
    
    await DependencyInjection.reset();
    getIt.registerLazySingleton<IReferralService>(
      () => ReferralClient(key: apiKey),
    );
  }
}
```

## Testing

### Mock Implementation

```dart
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
}
```

### Test Setup

```dart
void setUp() async {
  // Reset dependencies
  await DependencyInjection.reset();
  
  // Register mock service
  getIt.registerLazySingleton<IReferralService>(
    () => MockReferralService(),
  );
}

void tearDown() async {
  // Clean up
  await DependencyInjection.reset();
}
```

### Test Example

```dart
test('should generate referral link', () async {
  setUp();
  
  final manager = ReferralManager(getIt.referralService);
  final link = await manager.generateUserReferralLink('USER123');
  
  expect(link, equals('https://test.com/ref/USER123'));
});
```

## Widget Integration

### Using in Flutter Widgets

```dart
class ReferralWidget extends StatefulWidget {
  @override
  _ReferralWidgetState createState() => _ReferralWidgetState();
}

class _ReferralWidgetState extends State<ReferralWidget> {
  late final IReferralService _referralService;

  @override
  void initState() {
    super.initState();
    _referralService = getIt.referralService;
  }

  Future<void> _shareReferralLink() async {
    final link = await _referralService.createShortLink(referrerId: 'USER123');
    if (link != null) {
      // Share the link
      print('Share: $link');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _shareReferralLink,
      child: Text('Share Referral Link'),
    );
  }
}
```

## Best Practices

### 1. Use Constructor Injection

Prefer constructor injection over service locator for better testability:

```dart
// Good
class MyService {
  final IReferralService _referralService;
  MyService(this._referralService);
}

// Less ideal
class MyService {
  void doSomething() {
    final service = getIt.referralService; // Direct service locator usage
  }
}
```

### 2. Initialize Early

Initialize dependency injection as early as possible in your app lifecycle:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init(); // Early initialization
  runApp(MyApp());
}
```

### 3. Use Interfaces

Always depend on interfaces (`IReferralService`) rather than concrete implementations (`ReferralClient`):

```dart
// Good
final service = getIt.referralService; // Returns IReferralService

// Avoid
final service = getIt.get<ReferralClient>(); // Direct concrete type
```

### 4. Reset for Testing

Always reset dependencies in test setup:

```dart
setUp(() async {
  await DependencyInjection.reset();
  // Register test dependencies
});
```

## Migration from Direct Usage

If you're migrating from direct `ReferralClient` usage:

### Before (Direct Usage)
```dart
class MyService {
  late final ReferralClient referral;

  void initialize() {
    referral = ReferralClient(key: 'your_key');
  }
}
```

### After (Dependency Injection)
```dart
class MyService {
  final IReferralService _referralService;

  MyService(this._referralService);

  // Or use service locator
  MyService.fromServiceLocator() 
      : _referralService = getIt.referralService;
}
```

## Troubleshooting

### Common Issues

1. **Service not registered**: Make sure to call `DependencyInjection.init()` before using services
2. **Circular dependencies**: Avoid circular dependencies between services
3. **Memory leaks**: Use `DependencyInjection.reset()` in tests to clean up

### Debug Mode

Enable debug logging for dependency injection:

```dart
void main() async {
  // Enable debug logging
  GetIt.I.debugMode = true;
  
  await DependencyInjection.init();
  runApp(MyApp());
}
```

## API Reference

### DependencyInjection

- `init()`: Initialize all dependencies
- `reset()`: Reset all dependencies (useful for testing)

### getIt Extension

- `referralService`: Get the referral service instance

### IReferralService Interface

- `createShortLink(referrerId)`: Create a referral link
- `startLinkListener()`: Start listening for deep links
- `stopLinkListener()`: Stop listening for deep links
- `confirmInstallIfPossible()`: Check for install referrer
- `confirmInstall(token)`: Confirm install with token
