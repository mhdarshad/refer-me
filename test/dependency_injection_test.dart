import 'package:flutter_test/flutter_test.dart';
import 'package:refer_me/refer_me.dart';

void main() {
  group('Dependency Injection Tests', () {
    setUp(() async {
      // Reset dependencies before each test
      await ReferralService.reset();
    });

    tearDown(() async {
      // Clean up after each test
      await ReferralService.reset();
    });

    test('should initialize dependency injection', () async {
      // Act
      await ReferralService.init(apiKey: 'test_api_key');

      // Assert
      expect(getIt.isRegistered<IReferralService>(), isTrue);
    });

    test('should get referral service from service locator', () async {
      // Arrange
      await ReferralService.init(apiKey: 'test_api_key');

      // Act
      final service = getIt.referralService;

      // Assert
      expect(service, isNotNull);
      expect(service, isA<IReferralService>());
      expect(service, isA<ReferralClient>());
    });

    test('should reset dependencies', () async {
      // Arrange
      await ReferralService.init(apiKey: 'test_api_key');
      expect(getIt.isRegistered<IReferralService>(), isTrue);

      // Act
      await ReferralService.reset();

      // Assert
      expect(getIt.isRegistered<IReferralService>(), isFalse);
    });

    test('should register custom configuration', () async {
      // Arrange
      const customApiKey = 'custom_api_key';

      // Act
      getIt.registerLazySingleton<IReferralService>(
        () => ReferralClient(key: customApiKey),
      );

      // Assert
      final service = getIt.referralService as ReferralClient;
      expect(service.key, equals(customApiKey));
    });

    test('should work with constructor injection', () {
      // Arrange
      getIt.registerLazySingleton<IReferralService>(
        () => ReferralClient(key: 'test_key'),
      );

      // Act
      final manager = ReferralManager(getIt.referralService);

      // Assert
      expect(manager, isNotNull);
    });
  });
}

/// Test helper class
class ReferralManager {
  final IReferralService _referralService;

  ReferralManager(this._referralService);

  IReferralService get service => _referralService;
}
