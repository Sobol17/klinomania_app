import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/features/orders/data/models/address_suggestion_model.dart';

void main() {
  group('AddressSuggestionModel', () {
    test('maps Yandex suggest response fields', () {
      final suggestion = AddressSuggestionModel.fromJson({
        'title': {'text': 'Иркутск, улица Ленина, 1'},
        'subtitle': {'text': 'Иркутск'},
        'address': {'formatted_address': 'Иркутск, улица Ленина, 1'},
      });

      expect(suggestion.title, 'Иркутск, улица Ленина, 1');
      expect(suggestion.subtitle, 'Иркутск');
      expect(suggestion.address, 'Иркутск, улица Ленина, 1');
    });

    test('falls back to title when formatted address is missing', () {
      final suggestion = AddressSuggestionModel.fromJson({
        'title': {'text': 'Иркутск, улица Ленина, 1'},
        'subtitle': {'text': 'Иркутск'},
        'address': <String, dynamic>{},
      });

      expect(suggestion.address, 'Иркутск, улица Ленина, 1');
    });
  });
}
