import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Mock backend service for testing the referral client
/// This simulates the expected API responses
class MockBackendService {
  static const String _baseUrl = 'https://httpbin.org'; // Using httpbin for testing
  static final Map<String, String> _referralLinks = {};
  static final Map<String, String> _referralTokens = {};

  /// Mock implementation of create-referral endpoint
  static Future<http.Response> createReferral(String referrerId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Generate a mock short link
    final shortId = _generateShortId();
    final shortLink = 'https://go.yourapp.com/$shortId';
    
    // Store the mapping
    _referralLinks[shortId] = referrerId;
    _referralTokens[shortId] = _generateToken();
    
    // Return mock response
    return http.Response(
      jsonEncode({'shortLink': shortLink}),
      200,
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Mock implementation of confirm-install endpoint
  static Future<http.Response> confirmInstall(String referrerToken, String deviceId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Find the referrer ID for this token
    String? referrerId;
    for (final entry in _referralTokens.entries) {
      if (entry.value == referrerToken) {
        referrerId = _referralLinks[entry.key];
        break;
      }
    }
    
    if (referrerId != null) {
      return http.Response(
        jsonEncode({
          'success': true,
          'referralCode': referrerId,
          'deviceId': deviceId,
          'confirmedAt': DateTime.now().toIso8601String(),
        }),
        200,
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      return http.Response(
        jsonEncode({
          'success': false,
          'error': 'Invalid referral token',
        }),
        400,
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Generate a random short ID
  static String _generateShortId() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// Generate a random token
  static String _generateToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(32, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// Get stored data for debugging
  static Map<String, dynamic> getDebugInfo() {
    return {
      'referralLinks': _referralLinks,
      'referralTokens': _referralTokens,
    };
  }

  /// Clear stored data
  static void clearData() {
    _referralLinks.clear();
    _referralTokens.clear();
  }
}
