import '../../domain/entities/address_suggestion.dart';

class AddressSuggestionModel extends AddressSuggestion {
  const AddressSuggestionModel({
    required super.title,
    required super.subtitle,
    required super.address,
  });

  factory AddressSuggestionModel.fromJson(Map<String, dynamic> json) {
    final title = _nestedText(json['title']).trim();
    final subtitle = _nestedText(json['subtitle']).trim();
    final formattedAddress = _nestedText(
      json['address'],
      'formatted_address',
    ).trim();

    return AddressSuggestionModel(
      title: title,
      subtitle: subtitle,
      address: formattedAddress.isNotEmpty ? formattedAddress : title,
    );
  }

  static String _nestedText(Object? value, [String key = 'text']) {
    if (value is Map<String, dynamic>) {
      return value[key]?.toString() ?? '';
    }
    if (value is Map) {
      return value[key]?.toString() ?? '';
    }
    return '';
  }
}
