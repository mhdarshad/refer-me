import 'package:refer_me/refer_me.dart';

/// Example demonstrating app_links deep link handling
class AppLinksExample {
  /// Initialize the referral service with app_links support
  static Future<void> initialize() async {
    await ReferralService.init(apiKey: 'your_api_key_here');
    
    final referralService = ReferralService.referralService;
    
    // Start listening for deep links with full parameter access
    referralService.startLinkListenerWithParameters((parameters) async {
      print('Deep link received with parameters: $parameters');
      
      // Handle different types of deep links
      await _handleDeepLink(parameters);
    });
    
    // Check for initial link that launched the app
    await _checkInitialLink(referralService);
  }

  /// Handle deep link with full parameter access
  static Future<void> _handleDeepLink(Map<String, String> parameters) async {
    print('=== Deep Link Parameters ===');
    parameters.forEach((key, value) {
      print('$key: $value');
    });
    
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
    if (token != null && token.isNotEmpty) {
      print('Processing referral token: $token');
      await _processReferralToken(token);
    }
    
    // Handle campaign tracking
    if (campaign != null) {
      print('Campaign detected: $campaign');
      await _trackCampaign(campaign, source, medium);
    }
    
    // Handle custom parameters
    if (parameters['action'] == 'share') {
      await _handleShareAction(parameters);
    }
    
    if (parameters['action'] == 'invite') {
      await _handleInviteAction(parameters);
    }
  }

  /// Process referral token
  static Future<void> _processReferralToken(String token) async {
    try {
      final referralService = ReferralService.referralService;
      final result = await referralService.confirmInstall(token: token);
      
      if (result != null) {
        print('Referral confirmed successfully!');
        print('Referral data: $result');
        
        // You can now reward the user or show referral UI
        await _showReferralReward(result);
      }
    } catch (e) {
      print('Error processing referral token: $e');
    }
  }

  /// Track campaign
  static Future<void> _trackCampaign(String campaign, String? source, String? medium) async {
    print('Tracking campaign: $campaign');
    print('Source: $source, Medium: $medium');
    
    // Implement your campaign tracking logic here
    // This could involve analytics, user segmentation, etc.
  }

  /// Handle share action
  static Future<void> _handleShareAction(Map<String, String> parameters) async {
    final userId = parameters['user_id'];
    final message = parameters['message'];
    
    if (userId != null) {
      final referralService = ReferralService.referralService;
      final link = await referralService.createShortLink(referrerId: userId);
      
      if (link != null) {
        print('Generated share link: $link');
        print('Share message: $message');
        
        // Implement your sharing logic here
        // await Share.share('$message $link');
      }
    }
  }

  /// Handle invite action
  static Future<void> _handleInviteAction(Map<String, String> parameters) async {
    final userId = parameters['user_id'];
    final inviteCode = parameters['invite_code'];
    
    print('Processing invite for user: $userId');
    print('Invite code: $inviteCode');
    
    // Implement your invite logic here
  }

  /// Show referral reward
  static Future<void> _showReferralReward(Map<String, dynamic> referralData) async {
    print('Showing referral reward...');
    print('Referral code: ${referralData['referralCode']}');
    print('Device ID: ${referralData['deviceId']}');
    
    // Implement your reward UI logic here
  }

  /// Check for initial link that launched the app
  static Future<void> _checkInitialLink(IReferralService referralService) async {
    // Get initial link parameters
    final initialParameters = await referralService.getInitialLink();
    if (initialParameters != null) {
      print('App was launched via deep link!');
      print('Initial link parameters: $initialParameters');
      
      // Handle the initial link
      await _handleDeepLink(initialParameters);
    } else {
      print('App was launched normally (no deep link)');
    }
    
    // Get initial token specifically
    final initialToken = await referralService.getInitialToken();
    if (initialToken != null) {
      print('Initial token found: $initialToken');
      await _processReferralToken(initialToken);
    }
  }
}

/// Example: Advanced deep link handling with custom routing
class AdvancedDeepLinkHandler {
  final IReferralService _referralService;

  AdvancedDeepLinkHandler(this._referralService);

  /// Start listening with custom routing logic
  void startListening() {
    _referralService.startLinkListenerWithParameters((parameters) async {
      await _routeDeepLink(parameters);
    });
  }

  /// Route deep links based on path and parameters
  Future<void> _routeDeepLink(Map<String, String> parameters) async {
    final path = parameters['path'];
    final action = parameters['action'];
    
    print('Routing deep link - Path: $path, Action: $action');
    
    switch (path) {
      case '/referral':
        await _handleReferralPath(parameters);
        break;
      case '/campaign':
        await _handleCampaignPath(parameters);
        break;
      case '/invite':
        await _handleInvitePath(parameters);
        break;
      case '/share':
        await _handleSharePath(parameters);
        break;
      default:
        await _handleDefaultPath(parameters);
    }
  }

  /// Handle /referral path
  Future<void> _handleReferralPath(Map<String, String> parameters) async {
    final token = parameters['token'] ?? parameters['code'];
    if (token != null) {
      await _referralService.confirmInstall(token: token);
    }
  }

  /// Handle /campaign path
  Future<void> _handleCampaignPath(Map<String, String> parameters) async {
    final campaignId = parameters['id'];
    final source = parameters['source'];
    
    print('Campaign: $campaignId from $source');
    // Implement campaign tracking
  }

  /// Handle /invite path
  Future<void> _handleInvitePath(Map<String, String> parameters) async {
    final inviteCode = parameters['code'];
    final inviterId = parameters['inviter'];
    
    print('Invite code: $inviteCode from user: $inviterId');
    // Implement invite logic
  }

  /// Handle /share path
  Future<void> _handleSharePath(Map<String, String> parameters) async {
    final userId = parameters['user'];
    final message = parameters['message'];
    
    if (userId != null) {
      final link = await _referralService.createShortLink(referrerId: userId);
      print('Share link: $link');
      print('Message: $message');
    }
  }

  /// Handle default path
  Future<void> _handleDefaultPath(Map<String, String> parameters) async {
    print('Default path handling with parameters: $parameters');
    // Implement default handling
  }
}

/// Example: Deep link testing utilities
class DeepLinkTester {
  /// Test deep link handling with sample parameters
  static Future<void> testDeepLinkHandling() async {
    await ReferralService.init(apiKey: 'test_api_key');
    
    final referralService = ReferralService.referralService;
    
    // Test different deep link scenarios
    final testLinks = [
      {
        'path': '/referral',
        'token': 'TEST123',
        'source': 'email',
        'campaign': 'winter2024'
      },
      {
        'path': '/invite',
        'code': 'INVITE456',
        'inviter': 'user789',
        'message': 'Join me!'
      },
      {
        'path': '/share',
        'user': 'user123',
        'message': 'Check out this app!',
        'medium': 'social'
      }
    ];
    
    for (final link in testLinks) {
      print('\n=== Testing Deep Link ===');
      await AppLinksExample._handleDeepLink(Map<String, String>.from(link));
    }
  }

  /// Simulate deep link parameters
  static Map<String, String> createTestParameters({
    String? path,
    String? token,
    String? campaign,
    String? source,
    String? action,
    String? userId,
    String? message,
  }) {
    final parameters = <String, String>{};
    
    if (path != null) parameters['path'] = path;
    if (token != null) parameters['token'] = token;
    if (campaign != null) parameters['campaign'] = campaign;
    if (source != null) parameters['source'] = source;
    if (action != null) parameters['action'] = action;
    if (userId != null) parameters['user_id'] = userId;
    if (message != null) parameters['message'] = message;
    
    return parameters;
  }
}

/// Example: Deep link configuration
class DeepLinkConfig {
  /// Supported deep link schemes
  static const List<String> supportedSchemes = [
    'myapp',
    'referme',
    'https',
  ];

  /// Supported hosts
  static const List<String> supportedHosts = [
    'myapp.com',
    'refer.me',
    'short-refer.me',
  ];

  /// Common parameter names for tokens
  static const List<String> tokenParameters = [
    'uid',
    'ref',
    'code',
    'token',
    'referral',
  ];

  /// Validate if a deep link is supported
  static bool isSupportedLink(Map<String, String> parameters) {
    final scheme = parameters['scheme'];
    final host = parameters['host'];
    
    return supportedSchemes.contains(scheme) || 
           supportedHosts.contains(host);
  }

  /// Extract token from parameters
  static String? extractToken(Map<String, String> parameters) {
    for (final param in tokenParameters) {
      final value = parameters[param];
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}
