import 'package:get_it/get_it.dart';
import 'referral_service.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Configuration class for dependency injection
class ReferralService {
  /// Initialize all dependencies
  static Future<void> init({required String apiKey, bool debugMode = false}) async {
    // Register ReferralClient as a singleton with interface
    getIt.registerLazySingleton<IReferralService>(
      () => ReferralClient(
        key: apiKey,
        debugMode: debugMode,
      ),
    );
  }
  static IReferralService get referralService => getIt.get<IReferralService>();


  /// Reset all dependencies (useful for testing)
  static Future<void> reset() async {
    await getIt.reset();
  }
}

/// Extension methods for easier dependency access
extension DependencyInjectionExtension on GetIt {
  /// Get ReferralClient instance
  IReferralService get referralService => get<IReferralService>();
}
