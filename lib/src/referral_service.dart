import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
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
  Future<Map<String, dynamic>?> confirmInstall({required String token});
  Future<Map<String, String>?> getInitialLink();
  Future<String?> getInitialToken();
}

/// High-level API your app will call.
class ReferralClient implements IReferralService {
  String backendBaseUrl = "https://short-refer.me"; // e.g. https://api.yourdomain.com
  final String key;

  ReferralClient({
    required this.key,
  });

  /// Creates a short referral link for the given referrerId (your user's id / code).
  ///
  /// Calls POST {backend}/create-referral with JSON: { referrerId }
  /// Returns a shortLink string from your backend, e.g. https://go.yourapp.com/ab12Cd
  Future<String?> createShortLink({required String referrerId}) async {
    final uri = Uri.parse('$backendBaseUrl/api/referrals');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'X-API-Key': key},
      body: jsonEncode({'referrerId': referrerId}),
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data']['shortLink'] as String?;
      } else {
        throw Exception(data['message']);
      }
    }
    _logHttpError('createShortLink', resp);
    return null;
  }

  /// Start listening for in-app deep links (Universal/App Links).
  /// If a link with ?uid=... or ?ref=... or ?code=... arrives, this method will
  /// call _confirmByToken() automatically.
  ///
  /// Call this once during app boot (e.g. in main or first screen initState).
  void startLinkListener() {
    LinkListener.listenForToken((token) async {
      await _confirmByToken(token);
    });
  }

  /// Start listening for deep links with full parameter access.
  /// 
  /// [handler] - Callback function that receives all link parameters
  /// Use this when you need access to all parameters, not just the token
  void startLinkListenerWithParameters(DeepLinkHandler handler) {
    LinkListener.listen(handler);
  }

  /// Stop link listener (optional, e.g. on app dispose).
  Future<void> stopLinkListener() => LinkListener.dispose();

  /// Get the initial link that launched the app (if any).
  /// 
  /// Returns a map of all parameters from the initial deep link
  Future<Map<String, String>?> getInitialLink() async {
    return await LinkListener.getInitialLink();
  }

  /// Get the initial token from the link that launched the app (if any).
  /// 
  /// Returns the token string if found in common parameter names
  Future<String?> getInitialToken() async {
    return await LinkListener.getInitialToken();
  }

  /// Call on first cold start after install (or every cold start, safe to repeat).
  /// - Android: reads Install Referrer and confirms with backend.
  /// - iOS: nothing to read (App Store doesn't provide), rely on link listener or fallback.
  Future<Map<String, dynamic>?> confirmInstallIfPossible() async {
    if (Platform.isAndroid) {
      final token = await AndroidInstallReferrer.readReferrerToken();
      if (token != null && token.isNotEmpty) {
        return _confirmByToken(token);
      }
    }
    // iOS has no reliable "install referrer"; universal links are handled in startLinkListener().
    return null;
  }

  /// Low-level: explicitly confirm install using a known token (uniqueId/referrerId/shortId).
  Future<Map<String, dynamic>?> confirmInstall({required String token}) =>
      _confirmByToken(token);

  @protected
  Future<Map<String, dynamic>?> _confirmByToken(String token) async {
    final deviceId = await _deviceId();
    final uri = Uri.parse('$backendBaseUrl/api/referrals/confirm-install');

    final body = {
      // Your backend can accept any of these (choose one to key on):
      // - uniqueInstallId (Android Install Referrer unique token, if you use that)
      // - referrerToken / referrerId (if you pass a plain code)
      // - shortId (if you want to confirm by the clicked short code)
      // This SDK sends a unified "referrerToken".
      'referrerToken': token,
      'deviceId': deviceId,
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'X-API-Key': key},
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    _logHttpError('confirm-install', resp);
    return null;
  }

  Future<String> _deviceId() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      // ANDROID_ID is not directly exposed; use a stable combination that's acceptable for install matching.
      // Here we use the hardware+fingerprint+board as a light identifier; backend should treat it as best-effort only.
      return a.id.isNotEmpty ? a.id : a.fingerprint.isNotEmpty ? a.fingerprint : a.board.isNotEmpty ? a.board : 'android-device';
    } else {
      final i = await info.iosInfo;
      return i.identifierForVendor ?? 'ios-device';
    }
  }

  void _logHttpError(String where, http.Response r) {
    // ignore: avoid_print
    print('$where error: ${r.statusCode} -> ${r.body}');
  }
}
