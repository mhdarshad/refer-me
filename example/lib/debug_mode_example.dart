import 'package:refer_me/refer_me.dart';

/// Example demonstrating debug mode usage
class DebugModeExample {
  /// Initialize with debug mode enabled
  static Future<void> initializeWithDebugMode() async {
    print('🔧 Initializing ReferralClient with debug mode enabled...');
    
    // Initialize dependency injection with debug mode
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: true, // Enable debug mode
    );
    
    final referralService = ReferralService.referralService;
    
    // Start listening for deep links with debug logging
    referralService.startLinkListenerWithParameters((parameters) async {
      // Debug logging will show all the deep link processing
      if (parameters != null) {
        final stringParams = Map<String, String>.from(parameters);
        await _handleDeepLink(stringParams);
      }
    });
    
    // Check for initial link with debug logging
    final initialLink = await referralService.getInitialLink();
    if (initialLink != null) {
      print('App launched via deep link: $initialLink');
    }
    
    // Check for install referrer with debug logging
    await referralService.confirmInstallIfPossible();
  }

  /// Initialize with debug mode disabled (production mode)
  static Future<void> initializeProductionMode() async {
    print('🚀 Initializing ReferralClient in production mode...');
    
    // Initialize dependency injection without debug mode
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: false, // Disable debug mode (default)
    );
    
    final referralService = ReferralService.referralService;
    
    // Start listening for deep links (no debug logging)
    referralService.startLinkListenerWithParameters((parameters) async {
      if (parameters != null) {
        final stringParams = Map<String, String>.from(parameters);
        await _handleDeepLink(stringParams);
      }
    });
    
    // Check for initial link (no debug logging)
    final initialLink = await referralService.getInitialLink();
    if (initialLink != null) {
      print('App launched via deep link: $initialLink');
    }
    
    // Check for install referrer (no debug logging)
    await referralService.confirmInstallIfPossible();
  }

  /// Handle deep link with debug logging
  static Future<void> _handleDeepLink(Map<String, String> parameters) async {
    print('=== Deep Link Parameters ===');
    parameters.forEach((key, value) {
      print('$key: $value');
    });
    
    // Extract shortId from parameters
    final shortId = parameters['uid'] ?? 
                    parameters['ref'] ?? 
                    parameters['code'] ?? 
                    parameters['token'] ?? 
                    parameters['referral'] ??
                    parameters['segment_0'] ?? // New parameter from app_links
                    '';
    
    if (shortId.isNotEmpty) {
      final referralService = ReferralService.referralService;
      await referralService.confirmInstall(shortId: shortId);
    }
  }

  /// Test debug mode with different operations
  static Future<void> testDebugMode() async {
    print('🧪 Testing debug mode functionality...');
    
    final referralService = ReferralService.referralService;
    
    // Test 1: Generate referral link (will show debug logs)
    print('\n--- Test 1: Generate Referral Link ---');
    try {
      final link = await referralService.createShortLink(referrerId: 'USER123');
      print('Generated link: $link');
    } catch (e) {
      print('Error: $e');
    }
    
    // Test 2: Check install referrer (will show debug logs)
    print('\n--- Test 2: Check Install Referrer ---');
    try {
      final result = await referralService.confirmInstallIfPossible();
      print('Install referrer result: $result');
    } catch (e) {
      print('Error: $e');
    }
    
    // Test 3: Manual install confirmation (will show debug logs)
    print('\n--- Test 3: Manual Install Confirmation ---');
    try {
      final result = await referralService.confirmInstall(shortId: 'TEST_TOKEN_123');
      print('Manual confirmation result: $result');
    } catch (e) {
      print('Error: $e');
    }
    
    // Test 4: User agent generation (will show debug logs)
    print('\n--- Test 4: User Agent Generation ---');
    try {
      final userAgent = await referralService.getUserAgent();
      print('Generated user agent: $userAgent');
    } catch (e) {
      print('Error: $e');
    }
    
    // Test 5: Private IP address (will show debug logs)
    print('\n--- Test 5: Private IP Address ---');
    try {
      final ipAddress = await referralService.getPrivateIpAddress();
      if (ipAddress != null) {
        print('Generated IP address: $ipAddress');
      } else {
        print('No IP address available');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Toggle debug mode at runtime
  static Future<void> toggleDebugMode() async {
    print('🔄 Toggling debug mode...');
    
    // First, initialize with debug mode disabled
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: false,
    );
    
    print('Debug mode: DISABLED');
    await _testOperations();
    
    // Reset and enable debug mode
    await ReferralService.reset();
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: true,
    );
    
    print('\nDebug mode: ENABLED');
    await _testOperations();
  }

  /// Test operations to see debug output
  static Future<void> _testOperations() async {
    final referralService = ReferralService.referralService;
    
    // Test device ID generation
    print('Testing device ID generation...');
    try {
      // This will trigger device ID generation internally
      await referralService.confirmInstallIfPossible();
    } catch (e) {
      print('Expected error (no token): $e');
    }
  }

  /// Environment-based debug mode
  static Future<void> initializeWithEnvironmentDebug() async {
    print('🌍 Initializing with environment-based debug mode...');
    
    // Get debug mode from environment variable
    const debugMode = bool.fromEnvironment('REFERRAL_DEBUG_MODE', defaultValue: false);
    
    print('Debug mode from environment: $debugMode');
    
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: debugMode,
    );
    
    final referralService = ReferralService.referralService;
    
    // Start services
    referralService.startLinkListenerWithParameters((parameters) async {
      if (parameters != null) {
        final stringParams = Map<String, String>.from(parameters);
        await _handleDeepLink(stringParams);
      }
    });
    
    await referralService.confirmInstallIfPossible();
  }

  /// Conditional debug mode based on build configuration
  static Future<void> initializeWithConditionalDebug() async {
    print('⚙️ Initializing with conditional debug mode...');
    
    // Enable debug mode in debug builds, disable in release builds
    const isDebugBuild = bool.fromEnvironment('dart.vm.product') == false;
    final debugMode = isDebugBuild && const bool.fromEnvironment('REFERRAL_DEBUG', defaultValue: false);
    
    print('Is debug build: $isDebugBuild');
    print('Debug mode enabled: $debugMode');
    
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: debugMode,
    );
    
    final referralService = ReferralService.referralService;
    
    // Start services
    referralService.startLinkListenerWithParameters((parameters) async {
      if (parameters != null) {
        final stringParams = Map<String, String>.from(parameters);
        await _handleDeepLink(stringParams);
      }
    });
    
    await referralService.confirmInstallIfPossible();
  }
}

/// Example: Debug mode configuration
class DebugModeConfig {
  /// Enable debug mode for development
  static const bool developmentDebug = true;
  
  /// Enable debug mode for testing
  static const bool testingDebug = true;
  
  /// Enable debug mode for staging
  static const bool stagingDebug = false;
  
  /// Enable debug mode for production
  static const bool productionDebug = false;
  
  /// Get debug mode based on environment
  static bool getDebugMode(String environment) {
    switch (environment.toLowerCase()) {
      case 'development':
        return developmentDebug;
      case 'testing':
        return testingDebug;
      case 'staging':
        return stagingDebug;
      case 'production':
        return productionDebug;
      default:
        return false;
    }
  }
  
  /// Initialize with environment-based debug mode
  static Future<void> initializeWithEnvironment(String environment) async {
    final debugMode = getDebugMode(environment);
    
    print('🌍 Environment: $environment');
    print('🔧 Debug mode: $debugMode');
    
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: debugMode,
    );
  }
}

/// Example: Debug mode usage in different scenarios
class DebugModeScenarios {
  /// Development scenario with full debug logging
  static Future<void> developmentScenario() async {
    print('🛠️ Development Scenario - Full Debug Logging');
    
    await ReferralService.init(
      apiKey: 'dev_api_key',
      debugMode: true,
    );
    
    final referralService = ReferralService.referralService;
    
    // All operations will show detailed debug logs
    referralService.startLinkListenerWithParameters((parameters) async {
      print('Deep link received in dev mode: $parameters');
    });
    
    await referralService.confirmInstallIfPossible();
  }
  
  /// Production scenario with no debug logging
  static Future<void> productionScenario() async {
    print('🚀 Production Scenario - No Debug Logging');
    
    await ReferralService.init(
      apiKey: 'prod_api_key',
      debugMode: false,
    );
    
    final referralService = ReferralService.referralService;
    
    // All operations will run silently without debug logs
    referralService.startLinkListenerWithParameters((parameters) async {
      print('Deep link received in prod mode: $parameters');
    });
    
    await referralService.confirmInstallIfPossible();
  }
  
  /// Testing scenario with conditional debug logging
  static Future<void> testingScenario() async {
    print('🧪 Testing Scenario - Conditional Debug Logging');
    
    // Enable debug mode only for verbose testing
    const verboseTesting = bool.fromEnvironment('VERBOSE_TESTING', defaultValue: false);
    
    await ReferralService.init(
      apiKey: 'test_api_key',
      debugMode: verboseTesting,
    );
    
    final referralService = ReferralService.referralService;
    
    // Debug logging depends on verbose testing flag
    referralService.startLinkListenerWithParameters((parameters) async {
      print('Deep link received in test mode: $parameters');
    });
    
    await referralService.confirmInstallIfPossible();
  }
}

/// Example: Debug mode best practices
class DebugModeBestPractices {
  /// Never log sensitive information
  static void logSensitiveInfo(String apiKey, bool debugMode) {
    if (debugMode) {
      // ❌ Bad: Logging full API key
      // print('API Key: $apiKey');
      
      // ✅ Good: Logging masked API key
      final maskedKey = apiKey.length > 8 
          ? '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}'
          : '***';
      print('API Key: $maskedKey');
    }
  }
  
  /// Use structured logging for better debugging
  static void structuredLogging(String operation, Map<String, dynamic> data, bool debugMode) {
    if (debugMode) {
      print('''
=== $operation ===
${data.entries.map((e) => '${e.key}: ${e.value}').join('\n')}
================
''');
    }
  }
  
  /// Log performance metrics in debug mode
  static Future<T> logPerformance<T>(String operation, Future<T> Function() task, bool debugMode) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await task();
      
      if (debugMode) {
        print('⏱️ $operation completed in ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return result;
    } catch (e) {
      if (debugMode) {
        print('❌ $operation failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }
}
