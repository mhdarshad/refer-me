import 'package:refer_me/refer_me.dart';


/// Simple usage example demonstrating the referral client API
/// This shows the basic usage without UI complexity
class SimpleUsageExample {
  late final IReferralService referral;

  /// Initialize the referral client with dependency injection
  Future<void> initializeReferralClient() async {
    // Initialize dependency injection
    await ReferralService.init(apiKey: 'your_api_key_here');
    
    // Get the referral service from the service locator
    referral = ReferralService.referralService;

    // Start listening for deep links
    referral.startLinkListener();
  }

  /// Example: Generate a referral link for a user
  Future<void> generateReferralLink() async {
    try {
      final shortLink = await referral.createShortLink(referrerId: 'USER123');
      
      if (shortLink != null) {
        print('Generated referral link: $shortLink');
        // Now you can share this link with others
      } else {
        print('Failed to generate referral link');
      }
    } catch (e) {
      print('Error generating referral link: $e');
    }
  }

  /// Example: Confirm an install with a known token
  Future<void> confirmInstallWithToken() async {
    try {
      final result = await referral.confirmInstall(token: 'someToken123');
      
      if (result != null) {
        print('Install confirmed successfully!');
        print('Referral code: ${result['referralCode']}');
        print('Device ID: ${result['deviceId']}');
      } else {
        print('Failed to confirm install');
      }
    } catch (e) {
      print('Error confirming install: $e');
    }
  }

  /// Example: Check for install referrer on app startup
  Future<void> checkInstallReferrer() async {
    try {
      final result = await referral.confirmInstallIfPossible();
      
      if (result != null) {
        print('Install referrer found and confirmed!');
        print('Result: $result');
      } else {
        print('No install referrer found or already confirmed');
      }
    } catch (e) {
      print('Error checking install referrer: $e');
    }
  }

  /// Example: Clean up when app is disposed
  Future<void> dispose() async {
    await referral.stopLinkListener();
  }
}

/// Example usage in a Flutter app
class FlutterAppExample {
  static late final IReferralService referral;

  /// Initialize in main() function with dependency injection
  static Future<void> initialize() async {
    // Initialize dependency injection
    await ReferralService.init(apiKey: 'your_api_key_here');
    
    // Get the referral service from the service locator
    referral = ReferralService.referralService;

    // Start listening for deep links
    referral.startLinkListener();

    // Check for install referrer
    await referral.confirmInstallIfPossible();
  }

  /// Example: Share referral link
  static Future<void> shareMyReferral(String myUserId) async {
    final shortLink = await referral.createShortLink(referrerId: myUserId);
    
    if (shortLink != null) {
      // Share the link using your preferred method
      print('Share this link: $shortLink');
      // You could use share_plus package here:
      // await Share.share('Check out this app! $shortLink');
    }
  }

  /// Example: Handle deep link manually
  static Future<void> handleDeepLink(String link) async {
    // Parse the link to extract token
    final uri = Uri.parse(link);
    final token = uri.queryParameters['uid'] ?? 
                  uri.queryParameters['ref'] ?? 
                  uri.queryParameters['code'];
    
    if (token != null) {
      await referral.confirmInstall(token: token);
    }
  }
}

/// Example: Integration with user management
class UserReferralManager {
  final IReferralService referral;
  final String userId;

  UserReferralManager(this.referral, this.userId);

  /// Generate and store referral link for user
  Future<String?> generateUserReferralLink() async {
    return await referral.createShortLink(referrerId: userId);
  }

  /// Check if user was referred
  Future<bool> checkIfUserWasReferred() async {
    final result = await referral.confirmInstallIfPossible();
    return result != null;
  }

  /// Get referral information
  Future<Map<String, dynamic>?> getReferralInfo() async {
    return await referral.confirmInstallIfPossible();
  }
}

/// Example: Error handling patterns
class ReferralErrorHandling {
  final IReferralService referral;

  ReferralErrorHandling(this.referral);

  /// Generate link with proper error handling
  Future<String?> generateLinkSafely(String referrerId) async {
    try {
      return await referral.createShortLink(referrerId: referrerId);
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
        final result = await referral.confirmInstall(token: token);
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
