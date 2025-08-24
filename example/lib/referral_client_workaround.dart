// import 'dart:convert';
// import 'dart:io';
//
// import 'package:http/http.dart' as http;
// import 'package:device_info_plus/device_info_plus.dart';
//
// /// Simplified referral client for the example app
// /// This version doesn't use the problematic install_referrer package
// class ReferralClientWorkaround {
//   final String backendBaseUrl;
//   final String? appStoreId;
//   final String? androidPackage;
//
//   ReferralClientWorkaround({
//     required this.backendBaseUrl,
//     this.appStoreId,
//     this.androidPackage,
//   });
//
//   /// Creates a short referral link for the given referrerId
//   Future<String?> createShortLink({required String referrerId}) async {
//     final uri = Uri.parse('$backendBaseUrl/api/referrals');
//     final resp = await http.post(
//       uri,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'referrerId': referrerId}),
//     );
//     if (resp.statusCode == 200) {
//       final data = jsonDecode(resp.body) as Map<String, dynamic>;
//       return data['shortLink'] as String?;
//     }
//     _logHttpError('createShortLink', resp);
//     return null;
//   }
//
//   /// Start listening for in-app deep links (simplified version)
//   void startLinkListener() {
//     print('Link listener started (simplified version)');
//     // In a real implementation, this would set up uni_links2
//   }
//
//   /// Stop link listener
//   Future<void> stopLinkListener() async {
//     print('Link listener stopped');
//   }
//
//   /// Simplified install confirmation (no Android Install Referrer)
//   Future<Map<String, dynamic>?> confirmInstallIfPossible() async {
//     print('Install confirmation check (simplified - no Android Install Referrer)');
//     return null;
//   }
//
//   /// Manual confirmation using a token
//   Future<Map<String, dynamic>?> confirmInstall({required String token}) async {
//     final deviceId = await _deviceId();
//     final uri = Uri.parse('$backendBaseUrl/api/referrals/confirm-install');
//
//     final body = {
//       'referrerToken': token,
//       'deviceId': deviceId,
//     };
//
//     final resp = await http.post(
//       uri,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(body),
//     );
//
//     if (resp.statusCode == 200) {
//       return jsonDecode(resp.body) as Map<String, dynamic>;
//     }
//     _logHttpError('confirm-install', resp);
//     return null;
//   }
//
//   Future<String> _deviceId() async {
//     final info = DeviceInfoPlugin();
//     if (Platform.isAndroid) {
//       final a = await info.androidInfo;
//       return a.id.isNotEmpty ? a.id : a.fingerprint.isNotEmpty ? a.fingerprint : a.board.isNotEmpty ? a.board : 'android-device';
//     } else {
//       final i = await info.iosInfo;
//       return i.identifierForVendor ?? 'ios-device';
//     }
//   }
//
//   void _logHttpError(String where, http.Response r) {
//     print('$where error: ${r.statusCode} -> ${r.body}');
//   }
// }
