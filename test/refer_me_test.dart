import 'package:flutter_test/flutter_test.dart';
import 'package:refer_me/refer_me.dart';

void main() {
  group('ReferralClient', () {
    late ReferralClient client;

    setUp(() {
      client = ReferralClient(
        key: 'your_key',
      );
    });

    test('should be created with correct parameters', () {
      expect(client.key, 'your_key');
    });
  });
}
