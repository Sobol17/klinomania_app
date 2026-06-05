class ServiceDetail {
  const ServiceDetail({
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
  final ServicePricing? pricing;
  final List<ServiceOption> roomOptions;
  final List<ServiceOption> cleaningOptions;
  final List<ServiceOption> extraOptions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class ServicePricing {
  const ServicePricing({
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
}

class ServiceOption {
  const ServiceOption({
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
}
