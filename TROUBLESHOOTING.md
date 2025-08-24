# Troubleshooting Guide

## Common Issues and Solutions

### 1. Android Gradle Plugin (AGP) Namespace Issue

**Error:**
```
A problem occurred configuring project ':install_referrer'.
> Could not create an instance of type com.android.build.api.variant.impl.LibraryVariantBuilderImpl.
> Namespace not specified. Specify a namespace in the module's build file
```

**Cause:**
This error occurs when using the `install_referrer` package with newer versions of Android Gradle Plugin (AGP). The package hasn't been updated to include the required namespace declaration in its build.gradle file.

**Solutions:**

#### Solution 1: Use the Workaround Version (Recommended for Examples)

For the example app, we've created a workaround version that doesn't use the problematic `install_referrer` package:

```dart
// Use ReferralClientWorkaround instead of ReferralClient
import 'referral_client_workaround.dart';

late final ReferralClientWorkaround referral;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  referral = ReferralClientWorkaround(
    backendBaseUrl: 'https://api.yourdomain.com',
    androidPackage: 'com.yourapp',
    appStoreId: '1234567890',
  );

  referral.startLinkListener();
  await referral.confirmInstallIfPossible();

  runApp(const MyApp());
}
```

#### Solution 2: Downgrade Android Gradle Plugin

If you need to use the full `ReferralClient` with `install_referrer`, you can downgrade your AGP version:

**In `android/build.gradle`:**
```gradle
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0' // Use older version
    }
}
```

**In `android/gradle/wrapper/gradle-wrapper.properties`:**
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
```

#### Solution 3: Add Namespace Manually

You can manually add the namespace to the install_referrer package's build.gradle file:

1. Navigate to the package location:
   ```bash
   cd ~/.pub-cache/hosted/pub.dev/install_referrer-1.2.1/android/
   ```

2. Edit `build.gradle` and add:
   ```gradle
   android {
       namespace 'com.example.install_referrer' // Add this line
       // ... rest of configuration
   }
   ```

**Note:** This is a temporary fix and will be overwritten when the package is updated.

#### Solution 4: Use Alternative Packages

Consider using alternative packages for Android Install Referrer:

```yaml
dependencies:
  # Alternative to install_referrer
  google_play_install_referrer: ^1.0.0
  # or
  play_install_referrer: ^1.0.0
```

### 2. Platform-Specific Issues

#### Android Issues

**Problem:** Install referrer not being read
- **Solution:** Ensure the app was installed via Play Store link with referrer parameter
- **Check:** Verify your Play Store redirect URL includes `&referrer=uniqueId=UUIDv4`

**Problem:** Deep links not working
- **Solution:** Add proper intent filters in `AndroidManifest.xml`
- **Check:** Verify `android:autoVerify="true"` is set

#### iOS Issues

**Problem:** Universal Links not working
- **Solution:** Set up Associated Domains and apple-app-site-association file
- **Check:** Verify your domain has proper SSL certificate

### 3. Network and API Issues

**Problem:** HTTP requests failing
- **Solutions:**
  - Check network connectivity
  - Verify backend URL is correct
  - Ensure backend is running and accessible
  - Check CORS settings (for web)

**Problem:** Timeout errors
- **Solutions:**
  - Increase timeout values
  - Implement retry logic
  - Check server response times

### 4. Package Version Conflicts

**Problem:** Dependency conflicts
- **Solution:** Use `flutter pub deps` to identify conflicts
- **Check:** Update packages to compatible versions

**Problem:** Flutter version compatibility
- **Solution:** Check Flutter version requirements
- **Update:** Use `flutter upgrade` if needed

## Testing Solutions

### 1. Test the Workaround Version

```bash
cd example
flutter pub get
flutter run
```

### 2. Test with Mock Backend

The example includes a mock backend for testing:

```dart
// Use the mock backend for testing
final mockResponse = await MockBackendService.createReferral('USER123');
```

### 3. Test Deep Links

**Android:**
```bash
adb shell am start -W -a android.intent.action.VIEW -d "https://yourdomain.com/r?uid=test123" com.yourapp
```

**iOS Simulator:**
```bash
xcrun simctl openurl booted "https://yourdomain.com/r?uid=test123"
```

## Best Practices

### 1. Error Handling

Always wrap API calls in try-catch blocks:

```dart
try {
  final link = await referral.createShortLink(referrerId: userId);
  // Handle success
} catch (e) {
  // Handle error gracefully
  print('Error: $e');
}
```

### 2. Graceful Degradation

Implement fallback mechanisms:

```dart
Future<String?> getReferralLink(String userId) async {
  try {
    return await referral.createShortLink(referrerId: userId);
  } catch (e) {
    // Fallback to local storage or alternative method
    return await _getCachedReferralLink(userId);
  }
}
```

### 3. Platform Detection

Always check platform before using platform-specific features:

```dart
if (Platform.isAndroid) {
  // Android-specific code
} else if (Platform.isIOS) {
  // iOS-specific code
}
```

### 4. Testing

- Test on real devices, not just simulators
- Test with actual Play Store installs
- Test deep links with real URLs
- Test error scenarios

## Getting Help

### 1. Check Package Issues

- Visit the package's GitHub repository
- Check for open issues related to AGP compatibility
- Look for alternative packages

### 2. Community Resources

- Flutter GitHub issues
- Stack Overflow
- Flutter Discord/Reddit

### 3. Package Updates

Monitor package updates for fixes:

```bash
flutter pub outdated
flutter pub upgrade
```

## Alternative Approaches

### 1. Custom Implementation

If the packages continue to cause issues, consider implementing a custom solution:

```dart
class CustomReferralClient {
  // Implement your own referral logic
  // Use platform channels for native functionality
}
```

### 2. Backend-Only Solution

Handle all referral logic on the backend:

```dart
class BackendOnlyReferral {
  // Send device info to backend
  // Let backend handle attribution
}
```

### 3. Third-Party Services

Consider using established referral services:
- Branch.io
- AppsFlyer
- Adjust
- Firebase Dynamic Links

## Summary

The most common issue is the AGP namespace problem with the `install_referrer` package. The recommended solution for examples is to use the `ReferralClientWorkaround` class, which provides the same API without the problematic dependency.

For production apps, consider:
1. Using the workaround version
2. Downgrading AGP temporarily
3. Using alternative packages
4. Implementing a custom solution

Always test thoroughly on real devices and implement proper error handling.
