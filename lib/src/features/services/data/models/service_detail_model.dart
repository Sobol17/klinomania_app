import '../../domain/entities/service_detail.dart';

class ServiceDetailModel {
  const ServiceDetailModel({
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
    required this.pricing,
    required this.roomOptions,
    required this.cleaningOptions,
    required this.extraOptions,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? shortDescription;
  final String? description;
  final String? cleanersLabel;
  final String? durationLabel;
  final double? priceFrom;
  final String? imageUrl;
  final List<String> gallery;
  final ServicePricingModel? pricing;
  final List<ServiceOptionModel> roomOptions;
  final List<ServiceOptionModel> cleaningOptions;
  final List<ServiceOptionModel> extraOptions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subtitle: _stringOrNull(json['subtitle']),
      shortDescription: _stringOrNull(
        json['short_description'] ?? json['shortDescription'],
      ),
      description: _stringOrNull(json['description']),
      cleanersLabel: _stringOrNull(
        json['cleaners_label'] ?? json['cleanersLabel'],
      ),
      durationLabel: _stringOrNull(
        json['duration_label'] ?? json['durationLabel'],
      ),
      priceFrom: _parseDouble(json['price_from'] ?? json['priceFrom']),
      imageUrl: _stringOrNull(json['image_url'] ?? json['imageUrl']),
      gallery: _parseGallery(json['gallery']),
      pricing: _parsePricing(json['pricing']),
      roomOptions: _parseOptions(json['room_options'], defaultIsAddon: false),
      cleaningOptions: _parseOptions(
        json['cleaning_options'],
        defaultIsAddon: false,
      ),
      extraOptions: _parseOptions(json['extra_options'], defaultIsAddon: true),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  ServiceDetail toEntity() {
    return ServiceDetail(
      id: id,
      title: title,
      subtitle: subtitle,
      shortDescription: shortDescription,
      description: description,
      cleanersLabel: cleanersLabel,
      durationLabel: durationLabel,
      priceFrom: priceFrom,
      imageUrl: imageUrl,
      gallery: gallery,
      pricing: pricing?.toEntity(),
      roomOptions: roomOptions.map((option) => option.toEntity()).toList(),
      cleaningOptions: cleaningOptions
          .map((option) => option.toEntity())
          .toList(),
      extraOptions: extraOptions.map((option) => option.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static ServicePricingModel? _parsePricing(dynamic value) {
    if (value is Map<String, dynamic>) {
      return ServicePricingModel.fromJson(value);
    }
    return null;
  }

  static List<ServiceOptionModel> _parseOptions(
    dynamic value, {
    required bool defaultIsAddon,
  }) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => ServiceOptionModel.fromJson(
              item,
              defaultIsAddon: defaultIsAddon,
            ),
          )
          .toList();
    }
    return const [];
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

  static String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return value.toString();
  }
}

class ServicePricingModel {
  const ServicePricingModel({
    required this.basePrice,
    required this.pricePerSqm,
    required this.minArea,
    required this.maxArea,
    required this.minPrice,
  });

  final double? basePrice;
  final double? pricePerSqm;
  final double? minArea;
  final double? maxArea;
  final double? minPrice;

  factory ServicePricingModel.fromJson(Map<String, dynamic> json) {
    return ServicePricingModel(
      basePrice: _parseDouble(json['base_price'] ?? json['basePrice']),
      pricePerSqm: _parseDouble(json['price_per_sqm'] ?? json['pricePerSqm']),
      minArea: _parseDouble(json['min_area'] ?? json['minArea']),
      maxArea: _parseDouble(json['max_area'] ?? json['maxArea']),
      minPrice: _parseDouble(json['min_price'] ?? json['minPrice']),
    );
  }

  ServicePricing toEntity() {
    return ServicePricing(
      basePrice: basePrice,
      pricePerSqm: pricePerSqm,
      minArea: minArea,
      maxArea: maxArea,
      minPrice: minPrice,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class ServiceOptionModel {
  const ServiceOptionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isAddon,
    required this.isDefault,
    required this.priceModifier,
  });

  final String id;
  final String title;
  final String? subtitle;
  final bool isAddon;
  final bool isDefault;
  final double? priceModifier;

  factory ServiceOptionModel.fromJson(
    Map<String, dynamic> json, {
    required bool defaultIsAddon,
  }) {
    return ServiceOptionModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subtitle: _stringOrNull(json['subtitle']),
      isAddon: json['is_addon'] == true ? true : defaultIsAddon,
      isDefault: json['default'] == true,
      priceModifier: _parseDouble(
        json['price_modifier'] ?? json['priceModifier'],
      ),
    );
  }

  ServiceOption toEntity() {
    return ServiceOption(
      id: id,
      title: title,
      subtitle: subtitle,
      isAddon: isAddon,
      isDefault: isDefault,
      priceModifier: priceModifier,
    );
  }

  static String? _stringOrNull(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
