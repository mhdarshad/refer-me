# Troubleshooting Guide

This guide helps you resolve common issues when using the Refer Me Flutter package with dependency injection and app_links deep link handling.

## Table of Contents

1. [Dependency Injection Issues](#dependency-injection-issues)
2. [Deep Link Issues](#deep-link-issues)
3. [Platform-Specific Issues](#platform-specific-issues)
4. [Network and API Issues](#network-and-api-issues)
5. [Testing Issues](#testing-issues)
6. [Common Error Messages](#common-error-messages)

## Dependency Injection Issues

### 1. Service Not Registered Error

**Error:**
```
Exception: Service not found: IReferralService
```

**Cause:**
The dependency injection hasn't been initialized before trying to access the service.

**Solution:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection BEFORE using services
  await ReferralService.init(apiKey: 'your_api_key_here');
  
  // Now you can use the service
  final referralService = ReferralService.referralService;
  
  runApp(MyApp());
}
```

### 2. Circular Dependencies

**Error:**
```
Exception: Circular dependency detected
```

**Cause:**
Two or more services depend on each other, creating a circular dependency.

**Solution:**
- Restructure your dependencies to avoid circular references
- Use lazy initialization where possible
- Consider using interfaces to break circular dependencies

```dart
// Good - No circular dependency
class ServiceA {
  final IReferralService _referralService;
  ServiceA(this._referralService);
}

class ServiceB {
  final IReferralService _referralService;
  ServiceB(this._referralService);
}

// Bad - Circular dependency
class ServiceA {
  final ServiceB _serviceB;
  ServiceA(this._serviceB);
}

class ServiceB {
  final ServiceA _serviceA; // This creates a circle
  ServiceB(this._serviceA);
}
```

### 3. Configuration Issues

**Error:**
```
Exception: API key is required
```

**Cause:**
The API key wasn't provided during initialization.

**Solution:**
```dart
// Make sure to provide a valid API key
await ReferralService.init(apiKey: 'your_actual_api_key');

// Or use environment variables
const apiKey = String.fromEnvironment('REFERRAL_API_KEY');
await ReferralService.init(apiKey: apiKey);
```

## Deep Link Issues

### 1. Deep Links Not Working

**Symptoms:**
- Deep links don't open the app
- Parameters not being received
- App doesn't respond to links

**Solutions:**

#### Check Platform Configuration

**iOS (Info.plist):**
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

**Android (AndroidManifest.xml):**
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="referme" />
</intent-filter>
```

#### Check Deep Link Listener Setup

```dart
void main() async {
  await ReferralService.init(apiKey: 'your_api_key');
  
  final referralService = ReferralService.referralService;
  
  // Make sure to start listening
  referralService.startLinkListenerWithParameters((parameters) async {
    print('Deep link received: $parameters');
    // Handle the deep link
  });
  
  runApp(MyApp());
}
```

### 2. Initial Link Not Detected

**Symptoms:**
- App launched via deep link but no parameters received
- `getInitialLink()` returns null

**Solutions:**

#### Check Initialization Order

```dart
void main() async {
  await ReferralService.init(apiKey: 'your_api_key');
  
  final referralService = ReferralService.referralService;
  
  // Check for initial link BEFORE starting listener
  final initialLink = await referralService.getInitialLink();
  if (initialLink != null) {
    print('App launched via deep link: $initialLink');
    await handleDeepLink(initialLink);
  }
  
  // Then start listening for future deep links
  referralService.startLinkListenerWithParameters((parameters) async {
    await handleDeepLink(parameters);
  });
  
  runApp(MyApp());
}
```

#### Test with Different Scenarios

```bash
# iOS Simulator
xcrun simctl openurl booted "referme://referral?token=TEST123"

# Android Emulator
adb shell am start -W -a android.intent.action.VIEW -d "referme://referral?token=TEST123" com.yourapp.package
```

### 3. Parameters Not Being Extracted

**Symptoms:**
- Deep link opens app but parameters are empty
- Token not found in parameters

**Solutions:**

#### Check Parameter Names

The package looks for tokens in these parameter names (in order):
- `uid`
- `ref`
- `code`
- `token`
- `referral`

```dart
Future<void> handleDeepLink(Map<String, String> parameters) async {
  // Check all possible parameter names
  final token = parameters['uid'] ?? 
                parameters['ref'] ?? 
                parameters['code'] ?? 
                parameters['token'] ?? 
                parameters['referral'];
  
  if (token != null) {
    await ReferralService.referralService.confirmInstall(token: token);
  } else {
    print('No token found in parameters: $parameters');
  }
}
```

#### Debug Parameter Extraction

```dart
referralService.startLinkListenerWithParameters((parameters) async {
  print('=== Deep Link Debug ===');
  parameters.forEach((key, value) {
    print('$key: $value');
  });
  
  // Your handling logic
  await handleDeepLink(parameters);
});
```

## Platform-Specific Issues

### iOS Issues

#### Universal Links Not Working

**Symptoms:**
- HTTPS links don't open the app
- Links open in browser instead of app

**Solutions:**

1. **Check Associated Domains:**
   ```xml
   <key>com.apple.developer.associated-domains</key>
   <array>
       <string>applinks:yourdomain.com</string>
   </array>
   ```

2. **Verify apple-app-site-association file:**
   - Must be served from `https://yourdomain.com/.well-known/apple-app-site-association`
   - Must be served with `Content-Type: application/json`
   - Must not redirect

3. **Test with real device:**
   - Universal Links don't work in simulator
   - Test on physical iOS device

#### Custom URL Schemes Not Working

**Symptoms:**
- `referme://` links don't work
- App doesn't respond to custom scheme

**Solutions:**

1. **Check URL Types in Info.plist:**
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

2. **Test with simulator:**
   ```bash
   xcrun simctl openurl booted "referme://referral?token=TEST123"
   ```

### Android Issues

#### App Links Not Working

**Symptoms:**
- HTTPS links don't open the app
- Links open in browser

**Solutions:**

1. **Check Intent Filters:**
   ```xml
   <intent-filter android:autoVerify="true">
       <action android:name="android.intent.action.VIEW" />
       <category android:name="android.intent.category.DEFAULT" />
       <category android:name="android.intent.category.BROWSABLE" />
       <data android:scheme="https" 
             android:host="yourdomain.com" />
   </intent-filter>
   ```

2. **Verify Digital Asset Links:**
   - Create `/.well-known/assetlinks.json` on your domain
   - Include your app's package name and SHA-256 fingerprint

3. **Test with real device:**
   - App Links verification requires real device
   - Clear app data and reinstall if needed

#### Custom URL Schemes Not Working

**Symptoms:**
- `referme://` links don't work
- App doesn't respond to custom scheme

**Solutions:**

1. **Check Intent Filters:**
   ```xml
   <intent-filter>
       <action android:name="android.intent.action.VIEW" />
       <category android:name="android.intent.category.DEFAULT" />
       <category android:name="android.intent.category.BROWSABLE" />
       <data android:scheme="referme" />
   </intent-filter>
   ```

2. **Test with ADB:**
   ```bash
   adb shell am start -W -a android.intent.action.VIEW -d "referme://referral?token=TEST123" com.yourapp.package
   ```

## Network and API Issues

### 1. API Connection Errors

**Error:**
```
Exception: Failed to connect to API
```

**Solutions:**

#### Check API Key and URL

```dart
// Make sure you're using the correct API key
await ReferralService.init(apiKey: 'your_valid_api_key');

// The backend URL is automatically set to https://short-refer.me
```

#### Check Network Connectivity

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> isNetworkAvailable() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

Future<void> generateLinkWithNetworkCheck(String userId) async {
  if (!await isNetworkAvailable()) {
    throw Exception('No network connection');
  }
  
  final referralService = ReferralService.referralService;
  return await referralService.createShortLink(referrerId: userId);
}
```

### 2. API Response Errors

**Error:**
```
Exception: Invalid API response
```

**Solutions:**

#### Check Response Format

The API expects this response format:
```json
{
  "success": true,
  "data": {
    "shortLink": "https://short-refer.me/abc123"
  }
}
```

#### Handle API Errors

```dart
Future<String?> generateLinkSafely(String userId) async {
  try {
    final referralService = ReferralService.referralService;
    return await referralService.createShortLink(referrerId: userId);
  } catch (e) {
    print('Error generating link: $e');
    
    // Handle specific error types
    if (e.toString().contains('401')) {
      print('Invalid API key');
    } else if (e.toString().contains('429')) {
      print('Rate limit exceeded');
    }
    
    return null;
  }
}
```

## Testing Issues

### 1. Mock Service Not Working

**Error:**
```
Exception: Service not found in tests
```

**Solution:**
```dart
void setUp() async {
  // Reset dependencies before each test
  await ReferralService.reset();
  
  // Register mock service
  getIt.registerLazySingleton<IReferralService>(
    () => MockReferralService(),
  );
}

void tearDown() async {
  // Clean up after each test
  await ReferralService.reset();
}
```

### 2. Deep Link Testing Issues

**Symptoms:**
- Deep link tests not working
- Parameters not being received in tests

**Solutions:**

#### Test Deep Link Parameters

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
  // Add your assertions here
});
```

#### Mock Deep Link Handler

```dart
class MockDeepLinkHandler {
  List<Map<String, String>> receivedParameters = [];
  
  Future<void> handleDeepLink(Map<String, String> parameters) async {
    receivedParameters.add(parameters);
  }
}

test('should receive deep link parameters', () async {
  final handler = MockDeepLinkHandler();
  
  await handler.handleDeepLink({
    'token': 'TEST123',
    'source': 'email'
  });
  
  expect(handler.receivedParameters.length, equals(1));
  expect(handler.receivedParameters.first['token'], equals('TEST123'));
});
```

## Common Error Messages

### 1. "Service not found" Errors

**Error:** `Exception: Service not found: IReferralService`

**Solution:** Initialize dependency injection before using services.

### 2. "API key is required" Errors

**Error:** `Exception: API key is required`

**Solution:** Provide a valid API key during initialization.

### 3. "Deep link not supported" Errors

**Error:** `Exception: Deep link not supported`

**Solution:** Check platform configuration and ensure deep link listener is started.

### 4. "Network error" Errors

**Error:** `Exception: Network error`

**Solution:** Check internet connectivity and API endpoint availability.

### 5. "Invalid response format" Errors

**Error:** `Exception: Invalid response format`

**Solution:** Check API response format and handle errors appropriately.

## Getting Help

If you're still experiencing issues:

1. **Check the documentation:**
   - [Dependency Injection Guide](DEPENDENCY_INJECTION_GUIDE.md)
   - [App Links Guide](APP_LINKS_GUIDE.md)
   - [Usage Examples](USAGE_EXAMPLES.md)

2. **Review the examples:**
   - Check the `example/` directory for working implementations

3. **Enable debug logging:**
   ```dart
   // Add debug prints to track issues
   print('Debug: Initializing referral service');
   print('Debug: Deep link received: $parameters');
   ```

4. **Open an issue:**
   - Provide detailed error messages
   - Include platform and version information
   - Share relevant code snippets

5. **Test on real devices:**
   - Some features (like Universal Links) require real devices
   - Test on both iOS and Android devices
