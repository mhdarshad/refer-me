import 'dart:async';
import 'package:app_links/app_links.dart';

/// Callback function type for handling deep link parameters
typedef DeepLinkHandler = Future<void> Function(Map<String, dynamic>? parameters);

/// Callback function type for handling token from deep links
typedef TokenHandler = Future<void> Function(String token);

/// Service for listening to deep links using app_links package
class LinkListener {
  static StreamSubscription? _sub;
  static final AppLinks _appLinks = AppLinks();

  /// Listen for deep links and handle them with parameters
  /// 
  /// [handler] - Callback function that receives a map of link parameters
  /// The parameters map contains all query parameters from the deep link
  static void listen(DeepLinkHandler handler) {
    _sub?.cancel();
    
    _sub = _appLinks.uriLinkStream.listen(
      (Uri uri) async {
        try {
          // Extract all query parameters
          final parameters = <String, String>{};
          
          // Add path segments as parameters
          if (uri.pathSegments.isNotEmpty) {
            parameters['path'] = uri.path;
            for (int i = 0; i < uri.pathSegments.length; i++) {
              parameters['segment_$i'] = uri.pathSegments[i];
            }
          }
          
          // Add query parameters
          parameters.addAll(uri.queryParameters);
          
          // Add host and scheme
          if (uri.host.isNotEmpty) {
            parameters['host'] = uri.host;
          }
          if (uri.scheme.isNotEmpty) {
            parameters['scheme'] = uri.scheme;
          }
          
          // Call the handler with all parameters
          await handler(parameters);
        } catch (e) {
          print('Error handling deep link: $e');
        }
      },
      onError: (error) {
        print('Error listening to deep links: $error');
      },
    );
  }

  /// Listen for deep links and extract token from common parameter names
  /// 
  /// [handler] - Callback function that receives the token string
  /// Looks for token in parameters: uid, ref, code, token, referral
  static void listenForToken(TokenHandler handler) {
    listen((parameters) async {
      print(parameters);
      // Look for token in common parameter names

      // Ensure parameters is Map<String, String> as required by handler
      final shortId = parameters != null ? parameters['segment_0'] ?? '' : '';
      await handler(shortId);
    });
  }

  /// Get the initial link that launched the app (if any)
  /// 
  /// Returns a map of parameters from the initial link
  static Future<Map<String, String>?> getInitialLink() async {
    try {
      final uri = await _appLinks.getInitialAppLink();
      if (uri != null) {
        final parameters = <String, String>{};
        
        // Add path segments as parameters
        if (uri.pathSegments.isNotEmpty) {
          parameters['path'] = uri.path;
          for (int i = 0; i < uri.pathSegments.length; i++) {
            parameters['segment_$i'] = uri.pathSegments[i];
          }
        }
        
        // Add query parameters
        parameters.addAll(uri.queryParameters);
        
        // Add host and scheme
        if (uri.host.isNotEmpty) {
          parameters['host'] = uri.host;
        }
        if (uri.scheme.isNotEmpty) {
          parameters['scheme'] = uri.scheme;
        }
        
        return parameters;
      }
    } catch (e) {
      print('Error getting initial link: $e');
    }
    return null;
  }

  /// Get the initial token from the link that launched the app (if any)
  /// 
  /// Returns the token string if found in common parameter names
  static Future<String?> getInitialToken() async {
    final parameters = await getInitialLink();
    if (parameters != null) {
      return parameters['uid'] ?? 
             parameters['ref'] ?? 
             parameters['code'] ?? 
             parameters['token'] ?? 
             parameters['referral'];
    }
    return null;
  }

  /// Dispose and clean up the link listener
  static Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
