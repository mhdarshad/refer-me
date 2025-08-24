import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:meta/meta.dart';

import 'android_install_referrer.dart';
import 'link_listener.dart';

/// Abstract interface for referral service
abstract class IReferralService {
  Future<String?> createShortLink({required String referrerId});
  void startLinkListener();
  void startLinkListenerWithParameters(DeepLinkHandler handler);
  Future<void> stopLinkListener();
  Future<Map<String, dynamic>?> confirmInstallIfPossible();
  Future<Map<String, dynamic>?> confirmInstall({required String shortId});
  Future<Map<String, String>?> getInitialLink();
  Future<String?> getInitialToken();
  Future<String> getUserAgent();
  Future<String?> getPrivateIpAddress();
}

/// High-level API your app will call.
class ReferralClient implements IReferralService {
  String backendBaseUrl = "https://short-refer.me"; // e.g. https://api.yourdomain.com
  final String key;
  final bool debugMode;

  ReferralClient({
    required this.key,
    this.debugMode = false,
  });

  /// Creates a short referral link for the given referrerId (your user's id / code).
  ///
  /// Calls POST {backend}/create-referral with JSON: { referrerId }
  /// Returns a shortLink string from your backend, e.g. https://go.yourapp.com/ab12Cd
  Future<String?> createShortLink({required String referrerId}) async {
    _debugLog('🔗 Creating short link for referrerId: $referrerId');
    _debugLog('📡 Backend URL: $backendBaseUrl/api/referrals');
    
    final uri = Uri.parse('$backendBaseUrl/api/referrals');
    final userAgent = await _getChromeStyleUserAgent();
    final ipAddress = await _getPrivateIpAddress();
    
    final headers = {
      'Content-Type': 'application/json', 
      'X-API-Key': key,
      'User-Agent': userAgent,
    };
    
    final bodyData = <String, dynamic>{
      'referrerId': referrerId,
    };
    
    // Add IP address if available
    if (ipAddress != null) {
      bodyData['ipAddress'] = ipAddress;
      _debugLog('📡 Including IP address: $ipAddress');
    }
    
    final body = jsonEncode(bodyData);
    
    _debugLog('📤 Request Headers: ${_maskApiKey(headers)}');
    _debugLog('📤 Request Body: $body');
    
    try {
      final resp = await http.post(uri, headers: headers, body: body);
      
      _debugLog('📥 Response Status: ${resp.statusCode}');
      _debugLog('📥 Response Headers: ${resp.headers}');
      _debugLog('📥 Response Body: ${resp.body}');
      
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final shortLink = data['data']['shortLink'] as String?;
          _debugLog('✅ Short link created successfully: $shortLink');
          return shortLink;
        } else {
          final errorMessage = data['message'];
          _debugLog('❌ API returned error: $errorMessage');
          throw Exception(errorMessage);
        }
      }
      
      _logHttpError('createShortLink', resp);
      return null;
    } catch (e) {
      _debugLog('❌ Exception during createShortLink: $e');
      rethrow;
    }
  }

  /// Start listening for in-app deep links (Universal/App Links).
  /// If a link with ?uid=... or ?ref=... or ?code=... arrives, this method will
  /// call _confirmByToken() automatically.
  ///
  /// Call this once during app boot (e.g. in main or first screen initState).
  void startLinkListener() {
    _debugLog('🎧 Starting link listener for token-based deep links');
    LinkListener.listenForToken((shortId) async {
      _debugLog('🔗 Deep link token received: $shortId');
      await _confirmByShortId(shortId);
    });
  }

  /// Start listening for deep links with full parameter access.
  /// 
  /// [handler] - Callback function that receives all link parameters
  /// Use this when you need access to all parameters, not just the token
  void startLinkListenerWithParameters(DeepLinkHandler handler) {
    _debugLog('🎧 Starting link listener with full parameter access');
    LinkListener.listen((parameters) async {
      _debugLog('🔗 Deep link received with parameters: $parameters');

      // Ensure parameters is Map<String, String> as required by handler
      final shortId = parameters != null ? parameters['segment_0'] ?? '' : '';
      await handler(await confirmInstall(shortId: shortId));
    });
  }
  Future<void> stopLinkListener() async {
    _debugLog('🛑 Stopping link listener');
    await LinkListener.dispose();
  }

  /// Get the initial link that launched the app (if any).
  /// 
  /// Returns a map of all parameters from the initial deep link
  Future<Map<String, String>?> getInitialLink() async {
    _debugLog('🔍 Checking for initial link that launched the app');
    final initialLink = await LinkListener.getInitialLink();
    if (initialLink != null) {
      _debugLog('✅ Initial link found: $initialLink');
    } else {
      _debugLog('ℹ️ No initial link found');
    }
    return initialLink;
  }

  /// Get the initial token from the link that launched the app (if any).
  /// 
  /// Returns the token string if found in common parameter names
  Future<String?> getInitialToken() async {
    _debugLog('🔍 Checking for initial token from launch link');
    final initialToken = await LinkListener.getInitialToken();
    if (initialToken != null) {
      _debugLog('✅ Initial token found: $initialToken');
    } else {
      _debugLog('ℹ️ No initial token found');
    }
    return initialToken;
  }

  /// Get the Chrome-style user agent string for external use
  /// 
  /// Returns a realistic browser user agent string for better API compatibility
  Future<String> getUserAgent() async {
    return await _getChromeStyleUserAgent();
  }

  /// Get the device's private IP address for external use
  /// 
  /// Returns the local network IP address if available
  Future<String?> getPrivateIpAddress() async {
    return await _getPrivateIpAddress();
  }

  /// Call on first cold start after install (or every cold start, safe to repeat).
  /// - Android: reads Install Referrer and confirms with backend.
  /// - iOS: nothing to read (App Store doesn't provide), rely on link listener or fallback.
  Future<Map<String, dynamic>?> confirmInstallIfPossible() async {
    _debugLog('🔍 Checking for install referrer on platform: ${Platform.operatingSystem}');
    
    if (Platform.isAndroid) {
      _debugLog('🤖 Android platform detected, reading install referrer');
      try {
        final token = await AndroidInstallReferrer.readReferrerToken();
        if (token != null && token.isNotEmpty) {
          _debugLog('✅ Install referrer token found: $token');
          return await _confirmByToken(token);
        } else {
          _debugLog('ℹ️ No install referrer token found');
        }
      } catch (e) {
        _debugLog('❌ Error reading install referrer: $e');
      }
    } else {
      _debugLog('🍎 iOS platform detected, no install referrer to read');
    }
    
    _debugLog('ℹ️ No install referrer confirmation possible');
    return null;
  }

  /// Low-level: explicitly confirm install using a known token (uniqueId/referrerId/shortId).
  Future<Map<String, dynamic>?> confirmInstall({required String shortId}) async {
    _debugLog('🔐 Confirming install with shortId: $shortId');
    return await _confirmByShortId(shortId);
  }

  @protected
  Future<Map<String, dynamic>?> _confirmByToken(String token) async {
    _debugLog('🔐 Confirming install by token: $token');
    _debugLog('📡 Backend URL: $backendBaseUrl/api/referrals/confirm-install');
    
    final deviceId = await _deviceId();
    _debugLog('📱 Device ID: $deviceId');
    
    final uri = Uri.parse('$backendBaseUrl/api/referrals/confirm-install');
    final headers = {'Content-Type': 'application/json', 'X-API-Key': key};
    final body = {
      // Your backend can accept any of these (choose one to key on):
      // - uniqueInstallId (Android Install Referrer unique token, if you use that)
      // - referrerToken / referrerId (if you pass a plain code)
      // - shortId (if you want to confirm by the clicked short code)
      // This SDK sends a unified "referrerToken".
      'referrerToken': token,
      'deviceId': deviceId,
    };

    _debugLog('📤 Request Headers: ${_maskApiKey(headers)}');
    _debugLog('📤 Request Body: $body');

    try {
      final resp = await http.post(uri, headers: headers, body: jsonEncode(body));
      
      _debugLog('📥 Response Status: ${resp.statusCode}');
      _debugLog('📥 Response Headers: ${resp.headers}');
      _debugLog('📥 Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final result = jsonDecode(resp.body) as Map<String, dynamic>;
        _debugLog('✅ Install confirmation successful: $result');
        return result;
      }
      
      _logHttpError('confirm-install', resp);
      return null;
    } catch (e) {
      _debugLog('❌ Exception during install confirmation: $e');
      rethrow;
    }
  }

  @protected
  Future<Map<String, dynamic>?> _confirmByShortId(String shortId) async {
    _debugLog('🔐 Confirming install by shortId: $shortId');
    _debugLog('📡 Backend URL: $backendBaseUrl/api/referrals/confirm-install');
    
    // final deviceId = await _deviceId();
    // _debugLog('📱 Device ID: $deviceId');
    
    final uri = Uri.parse('$backendBaseUrl/api/referrals/confirm-install');
    final userAgent = await _getChromeStyleUserAgent();
    final ipAddress = await _getPrivateIpAddress();
    
    _debugLog('📱 User Agent: $userAgent');
    if (ipAddress != null) {
      _debugLog('📡 IP Address: $ipAddress');
    }
    
    final headers = {
      'Content-Type': 'application/json', 
      'X-API-Key': key,
      'User-Agent': userAgent,
    };
    
    final bodyData = <String, dynamic>{
      // Your backend can accept any of these (choose one to key on):
      // - uniqueInstallId (Android Install Referrer unique token, if you use that)
      // - referrerToken / referrerId (if you pass a plain code)
      // - shortId (if you want to confirm by the clicked short code)
      // This SDK sends a unified "referrerToken".
      'shortId': shortId,
      // 'deviceId': deviceId,
    };
    
    // Add IP address if available
    if (ipAddress != null) {
      bodyData['ipAddress'] = ipAddress;
    }

    _debugLog('📤 Request Headers: ${_maskApiKey(headers)}');
    _debugLog('📤 Request Body: $bodyData');

    try {
      final resp = await http.post(uri, headers: headers, body: jsonEncode(bodyData));
      
      _debugLog('📥 Response Status: ${resp.statusCode}');
      _debugLog('📥 Response Headers: ${resp.headers}');
      _debugLog('📥 Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final result = jsonDecode(resp.body) as Map<String, dynamic>;
        _debugLog('✅ Install confirmation successful: $result');
        return result;
      }
      
      _logHttpError('confirm-install', resp);
      return null;
    } catch (e) {
      _debugLog('❌ Exception during install confirmation: $e');
      rethrow;
    }
  }
  Future<String> _deviceId() async {
    _debugLog('📱 Getting device identifier');
    final info = DeviceInfoPlugin();
    
    try {
      if (Platform.isAndroid) {
        _debugLog('🤖 Getting Android device info');
        final a = await info.androidInfo;
        
        final deviceId = a.id.isNotEmpty ? a.id : 
                        a.fingerprint.isNotEmpty ? a.fingerprint : 
                        a.board.isNotEmpty ? a.board : 'android-device';
        
        _debugLog('📱 Android device ID: $deviceId');
        _debugLog('📱 Android info: id=${a.id}, fingerprint=${a.fingerprint}, board=${a.board}');
        
        return deviceId;
      } else {
        _debugLog('🍎 Getting iOS device info');
        final i = await info.iosInfo;
        final deviceId = i.identifierForVendor ?? 'ios-device';
        
        _debugLog('📱 iOS device ID: $deviceId');
        _debugLog('📱 iOS info: identifierForVendor=${i.identifierForVendor}');
        
        return deviceId;
      }
    } catch (e) {
      _debugLog('❌ Error getting device ID: $e');
      return 'unknown-device';
    }
  }

  /// Generate a Chrome-style user agent string for better API compatibility
  Future<String> _getChromeStyleUserAgent() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final package = await PackageInfo.fromPlatform();
      String ua = "";

      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        ua = "Mozilla/5.0 (Linux; Android ${android.version.release}; ${android.model}) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/${package.version}.0.0.0 Mobile Safari/537.36";
        
        _debugLog('🤖 Generated Android User-Agent: $ua');
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        ua = "Mozilla/5.0 (iPhone; CPU iPhone OS ${ios.systemVersion.replaceAll('.', '_')} like Mac OS X) "
            "AppleWebKit/605.1.15 (KHTML, like Gecko) "
            "Version/15.0 Mobile/15E148 Safari/604.1 "
            "Chrome/${package.version}.0.0.0";
        
        _debugLog('🍎 Generated iOS User-Agent: $ua');
      } else {
        ua = "Mozilla/5.0 (Unknown; Flutter App) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.0.0 Safari/537.36";
        _debugLog('❓ Generated Unknown Platform User-Agent: $ua');
      }

      return ua;
    } catch (e) {
      _debugLog('❌ Error generating user agent: $e');
      // Fallback to a generic Chrome user agent
      return "Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36";
    }
  }

  /// Get the device's private IP address for network identification
  Future<String?> _getPrivateIpAddress() async {
    try {
      final networkInfo = NetworkInfo();
      final wifiIP = await networkInfo.getWifiIP();
      
      if (wifiIP != null && wifiIP.isNotEmpty) {
        _debugLog('📡 WiFi IP Address: $wifiIP');
        return wifiIP;
      }
      
      // Fallback to any available IP
      final ipAddress = await networkInfo.getWifiIP();
      if (ipAddress != null && ipAddress.isNotEmpty) {
        _debugLog('📡 IP Address: $ipAddress');
        return ipAddress;
      }
      
      _debugLog('ℹ️ No IP address available');
      return null;
    } catch (e) {
      _debugLog('❌ Error getting IP address: $e');
      return null;
    }
  }

  /// Debug logging method that only logs when debug mode is enabled
  void _debugLog(String message) {
    if (debugMode) {
      // ignore: avoid_print
      print('[ReferralClient DEBUG] $message');
    }
  }

  /// Mask API key in headers for secure logging
  Map<String, String> _maskApiKey(Map<String, String> headers) {
    final maskedHeaders = Map<String, String>.from(headers);
    if (maskedHeaders.containsKey('X-API-Key')) {
      final apiKey = maskedHeaders['X-API-Key']!;
      if (apiKey.length > 8) {
        maskedHeaders['X-API-Key'] = '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}';
      } else {
        maskedHeaders['X-API-Key'] = '***';
      }
    }
    return maskedHeaders;
  }

  void _logHttpError(String where, http.Response r) {
    if (debugMode) {
      _debugLog('❌ HTTP Error in $where: ${r.statusCode} -> ${r.body}');
    } else {
      // ignore: avoid_print
      print('$where error: ${r.statusCode} -> ${r.body}');
    }
  }
}
