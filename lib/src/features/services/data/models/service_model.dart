import '../../../home/domain/entities/cleaning_service.dart';

class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.shortDescription,
    required this.description,
    required this.cleanersLabel,
    required this.durationLabel,
    required this.priceFrom,
    required this.imageUrl,
    required this.gallery,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? shortDescription;
  final String? description;
  final String cleanersLabel;
  final String durationLabel;
  final double? priceFrom;
  final String? imageUrl;
  final List<String> gallery;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subtitle: _stringOrNull(json['subtitle']),
      shortDescription: _stringOrNull(
        json['short_description'] ?? json['shortDescription'],
      ),
      description: _stringOrNull(json['description']),
      cleanersLabel: _stringOrEmpty(
        json['cleaners_label'] ?? json['cleanersLabel'],
      ),
      durationLabel: _stringOrEmpty(
        json['duration_label'] ?? json['durationLabel'],
      ),
      priceFrom: _parseDouble(json['price_from'] ?? json['priceFrom']),
      imageUrl: _stringOrNull(json['image_url'] ?? json['imageUrl']),
      gallery: _parseGallery(json['gallery']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  CleaningService toEntity() {
    final bool isPremium = id.toLowerCase() == 'premium';
    return CleaningService(
      id: id,
      title: title,
      subtitle: subtitle,
      cleaners: cleanersLabel.isNotEmpty ? cleanersLabel : '-',
      duration: durationLabel.isNotEmpty ? durationLabel : '-',
      imageUrl: imageUrl,
      shortDescription: shortDescription,
      description: description,
      priceFrom: priceFrom,
      gallery: gallery,
      cardStyle: isPremium
          ? CleaningServiceCardStyle.dark
          : CleaningServiceCardStyle.light,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String> _parseGallery(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return const [];
  }

  static String _stringOrEmpty(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static String? _stringOrNull(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }
}
