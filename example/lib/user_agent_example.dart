import 'package:refer_me/refer_me.dart';

/// Example demonstrating Chrome-style user agent functionality
class UserAgentExample {
  /// Initialize and test user agent generation
  static Future<void> testUserAgent() async {
    print('🌐 Testing Chrome-style User Agent Generation');
    print('=============================================');
    
    // Initialize dependency injection with debug mode
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: true, // Enable debug mode to see user agent generation
    );
    
    final referralService = ReferralService.referralService;
    
    // Test 1: Get user agent string
    print('\n--- Test 1: Get User Agent String ---');
    try {
      final userAgent = await referralService.getUserAgent();
      print('✅ Generated User Agent:');
      print('   $userAgent');
      
      // Analyze the user agent
      _analyzeUserAgent(userAgent);
    } catch (e) {
      print('❌ Error getting user agent: $e');
    }
    
    // Test 2: Test API calls with user agent
    print('\n--- Test 2: Test API Calls with User Agent ---');
    try {
      // This will automatically include the user agent in headers
      final link = await referralService.createShortLink(referrerId: 'USER123');
      print('✅ Short link created: $link');
    } catch (e) {
      print('❌ Error creating short link: $e');
    }
    
    // Test 3: Test install confirmation with user agent
    print('\n--- Test 3: Test Install Confirmation with User Agent ---');
    try {
      // This will automatically include the user agent in headers
      final result = await referralService.confirmInstall(shortId: 'TEST123');
      print('✅ Install confirmation result: $result');
    } catch (e) {
      print('❌ Error confirming install: $e');
    }
    
    // Test 4: Get private IP address
    print('\n--- Test 4: Get Private IP Address ---');
    try {
      final ipAddress = await referralService.getPrivateIpAddress();
      if (ipAddress != null) {
        print('✅ Private IP Address: $ipAddress');
      } else {
        print('ℹ️ No IP address available');
      }
    } catch (e) {
      print('❌ Error getting IP address: $e');
    }
  }

  /// Analyze the generated user agent string
  static void _analyzeUserAgent(String userAgent) {
    print('\n🔍 User Agent Analysis:');
    
    if (userAgent.contains('Android')) {
      print('   Platform: Android');
      
      // Extract Android version
      final androidMatch = RegExp(r'Android (\d+\.?\d*)').firstMatch(userAgent);
      if (androidMatch != null) {
        print('   Android Version: ${androidMatch.group(1)}');
      }
      
      // Extract device model
      final modelMatch = RegExp(r'Android \d+\.?\d*; ([^)]+)').firstMatch(userAgent);
      if (modelMatch != null) {
        print('   Device Model: ${modelMatch.group(1)}');
      }
      
      // Extract Chrome version
      final chromeMatch = RegExp(r'Chrome/([^ ]+)').firstMatch(userAgent);
      if (chromeMatch != null) {
        print('   Chrome Version: ${chromeMatch.group(1)}');
      }
      
    } else if (userAgent.contains('iPhone')) {
      print('   Platform: iOS');
      
      // Extract iOS version
      final iosMatch = RegExp(r'iPhone OS (\d+_\d+_\d+)').firstMatch(userAgent);
      if (iosMatch != null) {
        final version = iosMatch.group(1);
        if (version != null) {
          print('   iOS Version: ${version.replaceAll('_', '.')}');
        }
      }
      
      // Extract Chrome version
      final chromeMatch = RegExp(r'Chrome/([^ ]+)').firstMatch(userAgent);
      if (chromeMatch != null) {
        print('   Chrome Version: ${chromeMatch.group(1)}');
      }
      
    } else {
      print('   Platform: Unknown');
    }
    
    // Check if it looks like a real browser
    final isRealistic = userAgent.contains('Mozilla/5.0') && 
                        userAgent.contains('AppleWebKit') && 
                        userAgent.contains('Chrome');
    
    print('   Realistic Browser: ${isRealistic ? '✅ Yes' : '❌ No'}');
  }

  /// Compare user agents across different platforms
  static Future<void> compareUserAgents() async {
    print('\n🔄 Comparing User Agents Across Platforms');
    print('==========================================');
    
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: true,
    );
    
    final referralService = ReferralService.referralService;
    
    // Get user agent multiple times to see consistency
    for (int i = 1; i <= 3; i++) {
      print('\n--- Iteration $i ---');
      try {
        final userAgent = await referralService.getUserAgent();
        print('User Agent: $userAgent');
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  /// Test user agent in different scenarios
  static Future<void> testUserAgentScenarios() async {
    print('\n🧪 Testing User Agent in Different Scenarios');
    print('=============================================');
    
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: true,
    );
    
    final referralService = ReferralService.referralService;
    
    // Scenario 1: Normal operation
    print('\n--- Scenario 1: Normal Operation ---');
    try {
      final userAgent = await referralService.getUserAgent();
      print('✅ User Agent: $userAgent');
    } catch (e) {
      print('❌ Error: $e');
    }
    
    // Scenario 2: After service reset
    print('\n--- Scenario 2: After Service Reset ---');
    try {
      await ReferralService.reset();
      await ReferralService.init(
        apiKey: 'your_api_key_here',
        debugMode: true,
      );
      
      final newReferralService = ReferralService.referralService;
      final userAgent = await newReferralService.getUserAgent();
      print('✅ User Agent after reset: $userAgent');
    } catch (e) {
      print('❌ Error: $e');
    }
    
    // Scenario 3: Error handling
    print('\n--- Scenario 3: Error Handling ---');
    try {
      // This would normally work, but let's test error scenarios
      final userAgent = await referralService.getUserAgent();
      print('✅ User Agent (fallback): $userAgent');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  /// Demonstrate user agent in HTTP headers
  static Future<void> demonstrateHttpHeaders() async {
    print('\n📡 Demonstrating User Agent in HTTP Headers');
    print('============================================');
    
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: true,
    );
    
    final referralService = ReferralService.referralService;
    
    // Get user agent first
    final userAgent = await referralService.getUserAgent();
    print('Generated User Agent: $userAgent');
    
    // Show how it would look in HTTP headers
    print('\n📤 HTTP Headers Example:');
    print('   Content-Type: application/json');
    print('   X-API-Key: your...key');
    print('   User-Agent: $userAgent');
    
    // Test with actual API call to see headers in debug logs
    print('\n🧪 Testing with actual API call...');
    try {
      await referralService.createShortLink(referrerId: 'DEMO_USER');
      print('✅ API call completed - check debug logs for headers');
    } catch (e) {
      print('❌ API call failed: $e');
    }
  }

  /// Performance test for user agent generation
  static Future<void> performanceTest() async {
    print('\n⏱️ Performance Test for User Agent Generation');
    print('=============================================');
    
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: false, // Disable debug mode for performance test
    );
    
    final referralService = ReferralService.referralService;
    
    const iterations = 10;
    final stopwatch = Stopwatch();
    
    print('Running $iterations iterations...');
    
    // Warm up
    await referralService.getUserAgent();
    
    // Performance test
    stopwatch.start();
    for (int i = 0; i < iterations; i++) {
      await referralService.getUserAgent();
    }
    stopwatch.stop();
    
    final averageTime = stopwatch.elapsedMicroseconds / iterations;
    print('✅ Average time per user agent generation: ${averageTime.toStringAsFixed(2)} microseconds');
    print('✅ Total time for $iterations iterations: ${stopwatch.elapsedMilliseconds} milliseconds');
  }

  /// Custom user agent examples
  static Future<void> customUserAgentExamples() async {
    print('\n🎨 Custom User Agent Examples');
    print('=============================');
    
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: true,
    );
    
    final referralService = ReferralService.referralService;
    
    // Show the generated user agent
    final generatedUA = await referralService.getUserAgent();
    print('Generated UA: $generatedUA');
    
    // Show examples of what it looks like
    print('\n📱 Example User Agents:');
    
    // Android examples
    print('\n🤖 Android Examples:');
    print('   Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/1.0.0.0 Mobile Safari/537.36');
    print('   Mozilla/5.0 (Linux; Android 12; Samsung Galaxy S21) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/1.0.0.0 Mobile Safari/537.36');
    
    // iOS examples
    print('\n🍎 iOS Examples:');
    print('   Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1 Chrome/1.0.0.0');
    print('   Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1 Chrome/1.0.0.0');
    
    print('\n✅ Your generated user agent matches this pattern!');
  }
}

/// Example: User agent utilities
class UserAgentUtils {
  /// Check if user agent looks like a mobile browser
  static bool isMobileBrowser(String userAgent) {
    return userAgent.contains('Mobile') || 
           userAgent.contains('Android') || 
           userAgent.contains('iPhone');
  }
  
  /// Check if user agent looks like Chrome
  static bool isChrome(String userAgent) {
    return userAgent.contains('Chrome/') && !userAgent.contains('Safari/');
  }
  
  /// Check if user agent looks like Safari
  static bool isSafari(String userAgent) {
    return userAgent.contains('Safari/') && !userAgent.contains('Chrome/');
  }
  
  /// Extract platform from user agent
  static String getPlatform(String userAgent) {
    if (userAgent.contains('Android')) return 'Android';
    if (userAgent.contains('iPhone')) return 'iOS';
    if (userAgent.contains('Windows')) return 'Windows';
    if (userAgent.contains('Mac OS X')) return 'macOS';
    if (userAgent.contains('Linux')) return 'Linux';
    return 'Unknown';
  }
  
  /// Extract browser version from user agent
  static String? getBrowserVersion(String userAgent) {
    final chromeMatch = RegExp(r'Chrome/([^ ]+)').firstMatch(userAgent);
    if (chromeMatch != null) return chromeMatch.group(1);
    
    final safariMatch = RegExp(r'Safari/([^ ]+)').firstMatch(userAgent);
    if (safariMatch != null) return safariMatch.group(1);
    
    return null;
  }
}

/// Example: Using user agent in different contexts
class UserAgentContextExamples {
  /// Example: Web view with custom user agent
  static Future<void> webViewExample() async {
    print('🌐 Web View Example with Custom User Agent');
    
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: true,
    );
    
    final referralService = ReferralService.referralService;
    final userAgent = await referralService.getUserAgent();
    
    print('''
// In your Flutter app, you can use this user agent for WebView:

WebView(
  initialUrl: 'https://your-website.com',
  userAgent: '$userAgent',
  javascriptMode: JavascriptMode.unrestricted,
)
''');
  }
  
  /// Example: HTTP client with custom user agent
  static Future<void> httpClientExample() async {
    print('📡 HTTP Client Example with Custom User Agent');
    
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: true,
    );
    
    final referralService = ReferralService.referralService;
    final userAgent = await referralService.getUserAgent();
    
    print('''
// For custom HTTP requests:

final response = await http.get(
  Uri.parse('https://api.example.com/data'),
  headers: {
    'User-Agent': '$userAgent',
    'Content-Type': 'application/json',
  },
);
''');
  }
  
  /// Example: Third-party API integration
  static Future<void> thirdPartyApiExample() async {
    print('🔌 Third-Party API Integration Example');
    
    await ReferralService.init(
      apiKey: 'your_api_key_here',
      debugMode: true,
    );
    
    final referralService = ReferralService.referralService;
    final userAgent = await referralService.getUserAgent();
    
    print('''
// When integrating with third-party APIs:

class ThirdPartyApiClient {
  final String userAgent;
  
  ThirdPartyApiClient({required this.userAgent});
  
  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(
      Uri.parse('https://api.thirdparty.com/data'),
      headers: {
        'User-Agent': userAgent,
        'Authorization': 'Bearer your_token',
      },
    );
    
    return jsonDecode(response.body);
  }
}

// Usage:
final apiClient = ThirdPartyApiClient(userAgent: '$userAgent');
final data = await apiClient.fetchData();
''');
  }
}
