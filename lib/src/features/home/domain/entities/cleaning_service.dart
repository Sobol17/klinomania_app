enum CleaningServiceCardStyle { light, dark }

class CleaningService {
  const CleaningService({
    required this.id,
    required this.title,
    required this.cleaners,
    required this.duration,
    this.subtitle,
    this.imageAsset,
    this.imageUrl,
    this.shortDescription,
    this.description,
    this.priceFrom,
    this.gallery = const [],
    this.cardStyle = CleaningServiceCardStyle.light,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String cleaners;
  final String duration;
  final String? imageAsset;
  final String? imageUrl;
  final String? shortDescription;
  final String? description;
  final double? priceFrom;
  final List<String> gallery;
  final CleaningServiceCardStyle cardStyle;

  bool get hasImage {
    final asset = imageAsset;
    if (asset != null && asset.trim().isNotEmpty) {
      return true;
    }
    final url = imageUrl;
    if (url != null && url.trim().isNotEmpty) {
      return true;
    }
    return false;
  }

  CleaningService copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? cleaners,
    String? duration,
    String? imageAsset,
    String? imageUrl,
    String? shortDescription,
    String? description,
    double? priceFrom,
    List<String>? gallery,
    CleaningServiceCardStyle? cardStyle,
  }) {
    return CleaningService(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      cleaners: cleaners ?? this.cleaners,
      duration: duration ?? this.duration,
      imageAsset: imageAsset ?? this.imageAsset,
      imageUrl: imageUrl ?? this.imageUrl,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      priceFrom: priceFrom ?? this.priceFrom,
      gallery: gallery ?? this.gallery,
      cardStyle: cardStyle ?? this.cardStyle,
    );
  }
}
