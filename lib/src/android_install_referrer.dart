import 'dart:io';
// import 'package:install_referrer/install_referrer.dart'; // REMOVED due to Android compatibility issues

/// Reads the Play Store Install Referrer string and extracts your token.
///
/// IMPORTANT:
/// Set your Play redirect to include a single token, e.g.:
///   ...&referrer=uniqueId=UUIDv4
/// or just
///   ...&referrer=UUIDv4
///
/// This helper supports both formats.
class AndroidInstallReferrer {
  static Future<String?> readReferrerToken() async {
    try {
      // Only attempt to read on Android
      if (!Platform.isAndroid) {
        return null;
      }

      // The install_referrer package has been removed due to Android compatibility issues
      // For now, we'll use the fallback method
      // TODO: Implement using Google Play Install Referrer API directly
      return await readReferrerTokenFallback();
    } catch (e) {
      // Log the error but don't crash the app
      print('Warning: Could not read install referrer: $e');
      return null;
    }
  }

  /// Alternative method that doesn't rely on the install_referrer package
  /// This can be used as a fallback or for testing
  static Future<String?> readReferrerTokenFallback() async {
    try {
      if (!Platform.isAndroid) {
        return null;
      }

      // For now, return null since we can't read the install referrer
      // In a production app, you might want to:
      // 1. Use Google Play Install Referrer API directly via platform channels
      // 2. Store referrer in SharedPreferences when app is first launched
      // 3. Use Firebase Dynamic Links or other referral tracking
      
      print('Info: Install referrer reading is disabled due to package compatibility issues');
      return null;
    } catch (e) {
      print('Warning: Fallback referrer reading failed: $e');
      return null;
    }
  }
}
