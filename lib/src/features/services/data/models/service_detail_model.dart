import '../../domain/entities/service_detail.dart';

class ServiceDetailModel {
  const ServiceDetailModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.shortDescription,
    required this.description,
    required this.checklist,
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
  final List<ServiceChecklistSection> checklist;
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
      checklist: _parseChecklist(
        checklist: json['checklist'],
        sections: json['checklist_sections'],
      ),
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
      checklist: checklist,
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

  static List<ServiceChecklistSection> _parseChecklist({
    required dynamic checklist,
    required dynamic sections,
  }) {
    final items = _parseChecklistItems(checklist);
    if (items.isEmpty) return const [];

    final sectionMaps = sections is List
        ? sections.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : const <Map<String, dynamic>>[];
    if (sectionMaps.isEmpty) {
      return [
        ServiceChecklistSection(
          zone: 'everywhere',
          title: 'Везде',
          items: items.map((item) => item.text).toList(growable: false),
        ),
      ];
    }

    return sectionMaps
        .map((section) {
          final zone =
              _stringOrNull(
                section['zone'] ?? section['id'] ?? section['key'],
              ) ??
              '';
          final title =
              _stringOrNull(
                section['title'] ?? section['name'] ?? section['label'],
              ) ??
              zone;
          return ServiceChecklistSection(
            zone: zone,
            title: title,
            items: items
                .where((item) => item.zone == zone)
                .map((item) => item.text)
                .toList(growable: false),
          );
        })
        .where((section) => section.zone.isNotEmpty && section.items.isNotEmpty)
        .toList(growable: false);
  }

  static List<_ChecklistItem> _parseChecklistItems(dynamic value) {
    if (value is! List) return const [];

    return value
        .map((item) {
          if (item is String) {
            return _ChecklistItem(zone: 'everywhere', text: item.trim());
          }
          if (item is Map) {
            return _ChecklistItem(
              zone: _stringOrNull(item['zone']) ?? 'everywhere',
              text:
                  _stringOrNull(
                    item['text'] ?? item['title'] ?? item['label'],
                  ) ??
                  '',
            );
          }
          return const _ChecklistItem(zone: '', text: '');
        })
        .where((item) => item.text.isNotEmpty)
        .toList(growable: false);
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

class _ChecklistItem {
  const _ChecklistItem({required this.zone, required this.text});

  final String zone;
  final String text;
}

class ServicePricingModel {
  const ServicePricingModel({
    required this.basePrice,
    required this.pricePerSqm,
    required this.minArea,
    required this.maxArea,
    required this.minPrice,
    required this.areaStep,
  });

  final double? basePrice;
  final double? pricePerSqm;
  final double? minArea;
  final double? maxArea;
  final double? minPrice;
  final double? areaStep;

  factory ServicePricingModel.fromJson(Map<String, dynamic> json) {
    return ServicePricingModel(
      basePrice: _parseDouble(json['base_price'] ?? json['basePrice']),
      pricePerSqm: _parseDouble(json['price_per_sqm'] ?? json['pricePerSqm']),
      minArea: _parseDouble(json['min_area'] ?? json['minArea']),
      maxArea: _parseDouble(json['max_area'] ?? json['maxArea']),
      minPrice: _parseDouble(json['min_price'] ?? json['minPrice']),
      areaStep: _parseDouble(json['area_step'] ?? json['areaStep']),
    );
  }

  ServicePricing toEntity() {
    return ServicePricing(
      basePrice: basePrice,
      pricePerSqm: pricePerSqm,
      minArea: minArea,
      maxArea: maxArea,
      minPrice: minPrice,
      areaStep: areaStep,
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
    required this.sortOrder,
  });

  final String id;
  final String title;
  final String? subtitle;
  final bool isAddon;
  final bool isDefault;
  final double? priceModifier;
  final int? sortOrder;

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
      sortOrder: _parseInt(json['sort_order'] ?? json['sortOrder']),
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
      sortOrder: sortOrder,
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

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
