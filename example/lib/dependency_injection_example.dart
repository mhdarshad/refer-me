import 'package:refer_me/refer_me.dart';
import 'package:refer_me/src/link_listener.dart';

/// Example demonstrating dependency injection usage
class DependencyInjectionExample {
  /// Initialize dependency injection in your app's main function
  static Future<void> initializeApp() async {
    // Initialize all dependencies
    await ReferralService.init(apiKey: 'your_api_key_here');
    
    // Get the referral service from the service locator
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
  }

  /// Example: Generate a referral link using dependency injection
  static Future<void> generateReferralLink(String userId) async {
    try {
      // Get the service from the service locator
      final referralService = ReferralService.referralService;
      
      final shortLink = await referralService.createShortLink(referrerId: userId);
      
      if (shortLink != null) {
        print('Generated referral link: $shortLink');
      } else {
        print('Failed to generate referral link');
      }
    } catch (e) {
      print('Error generating referral link: $e');
    }
  }

  /// Example: Confirm install with dependency injection
  static Future<void> confirmInstallWithToken(String token) async {
    try {
      final referralService = ReferralService.referralService;
      final result = await referralService.confirmInstall(token: token);
      
      if (result != null) {
        print('Install confirmed successfully!');
        print('Result: $result');
      } else {
        print('Failed to confirm install');
      }
    } catch (e) {
      print('Error confirming install: $e');
    }
  }

  /// Clean up when app is disposed
  static Future<void> dispose() async {
    final referralService = ReferralService.referralService;
    await referralService.stopLinkListener();
  }
}

/// Example: Service class that uses dependency injection
class ReferralManager {
  final IReferralService _referralService;

  /// Constructor injection - recommended approach
  ReferralManager(this._referralService);

  /// Alternative: Get service from service locator
  ReferralManager.fromServiceLocator() 
      : _referralService = ReferralService.referralService;

  /// Generate referral link for user
  Future<String?> generateUserReferralLink(String userId) async {
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

/// Example: Widget that uses dependency injection
class ReferralWidget {
  final IReferralService _referralService;

  ReferralWidget(this._referralService);

  /// Generate and share referral link
  Future<void> shareReferralLink(String userId) async {
    final shortLink = await _referralService.createShortLink(referrerId: userId);
    
    if (shortLink != null) {
      print('Share this link: $shortLink');
      // Use share_plus package to share the link
      // await Share.share('Check out this app! $shortLink');
    }
  }

  /// Check referral status
  Future<void> checkReferralStatus() async {
    final result = await _referralService.confirmInstallIfPossible();
    
    if (result != null) {
      print('User was referred!');
      print('Referral data: $result');
    } else {
      print('User was not referred');
    }
  }
}

/// Mock implementation for testing
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

/// Example: Testing with dependency injection
class ReferralServiceTest {

  /// Setup for testing
  static Future<void> setupForTesting() async {
    // Reset dependencies
    await ReferralService.reset();
    
    // Register mock service
    getIt.registerLazySingleton<IReferralService>(
      () => MockReferralService(),
    );
  }

  /// Test referral manager
  static Future<void> testReferralManager() async {
    await setupForTesting();
    
    final manager = ReferralManager.fromServiceLocator();
    
    // Test generating link
    final link = await manager.generateUserReferralLink('USER123');
    print('Generated link: $link');
    
    // Test checking referral
    final wasReferred = await manager.checkIfUserWasReferred();
    print('Was referred: $wasReferred');
  }
}

/// Example: Configuration management with dependency injection
class ReferralConfiguration {
  static const String _apiKey = 'your_actual_api_key';
  static const String _baseUrl = 'https://your-api.com';

  /// Initialize with custom configuration
  static Future<void> initializeWithConfig({
    required String apiKey,
    String? baseUrl,
  }) async {
    // Reset existing dependencies
    await ReferralService.reset();
    
    // Register with custom configuration
    getIt.registerLazySingleton<IReferralService>(
      () => ReferralClient(
        key: apiKey,
      ),
    );
  }

  /// Initialize with environment variables
  static Future<void> initializeFromEnvironment() async {
    const apiKey = String.fromEnvironment('REFERRAL_API_KEY');
    const baseUrl = String.fromEnvironment('REFERRAL_BASE_URL');
    
    await initializeWithConfig(
      apiKey: apiKey,
      baseUrl: baseUrl,
    );
  }
}
