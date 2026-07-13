import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/features/auth/domain/entities/auth_session.dart';
import 'package:klinomania/src/features/profile/data/models/client_profile_model.dart';

void main() {
  group('ClientProfileModel', () {
    test('maps client profile API response', () {
      final profile = ClientProfileModel.fromJson({
        'data': {
          'id': 1,
          'name': 'Иван',
          'email': 'ivan@example.com',
          'phone': '+79990000001',
          'role': 'client',
          'client_profile': {
            'id': 1,
            'user_id': 1,
            'name': 'Иван',
            'address': 'Москва, ул. Тверская, 1',
            'push_notifications_enabled': true,
            'email_marketing_enabled': false,
          },
        },
      });

      expect(profile.id, '1');
      expect(profile.name, 'Иван');
      expect(profile.email, 'ivan@example.com');
      expect(profile.phone, '+79990000001');
      expect(profile.role, UserRole.client);
      expect(profile.address, 'Москва, ул. Тверская, 1');
      expect(profile.pushNotificationsEnabled, isTrue);
      expect(profile.emailMarketingEnabled, isFalse);
      expect(profile.isActive, isNull);
    });

    test('maps cleaner profile API response', () {
      final profile = ClientProfileModel.fromJson({
        'data': {
          'id': 2,
          'name': 'Cleaner',
          'email': null,
          'phone': '+79990000003',
          'role': 'cleaner',
          'cleaner_profile': {
            'id': 1,
            'user_id': 2,
            'name': null,
            'is_active': true,
          },
        },
      });

      expect(profile.id, '2');
      expect(profile.name, 'Cleaner');
      expect(profile.email, '');
      expect(profile.phone, '+79990000003');
      expect(profile.role, UserRole.cleaner);
      expect(profile.address, '');
      expect(profile.isActive, isTrue);
    });
  });
}
