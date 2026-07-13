import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/features/auth/data/models/auth_session_model.dart';
import 'package:klinomania/src/features/auth/domain/entities/auth_session.dart';

void main() {
  group('AuthSessionModel', () {
    test('maps client auth API response', () {
      final session = AuthSessionModel.fromJson({
        'token': '1|plain-text-token',
        'user': {
          'id': 1,
          'name': null,
          'email': null,
          'phone': '+79990000001',
          'role': 'client',
        },
      });

      expect(session.accessToken, '1|plain-text-token');
      expect(session.tokenType, 'Bearer');
      expect(session.phoneNumber, '+79990000001');
      expect(session.role, UserRole.client);
    });

    test('maps cleaner auth API response', () {
      final session = AuthSessionModel.fromJson({
        'token': '2|plain-text-token',
        'user': {
          'id': 2,
          'name': 'Cleaner',
          'phone': '+79990000003',
          'role': 'cleaner',
        },
      });

      expect(session.accessToken, '2|plain-text-token');
      expect(session.phoneNumber, '+79990000003');
      expect(session.role, UserRole.cleaner);
    });
  });
}
