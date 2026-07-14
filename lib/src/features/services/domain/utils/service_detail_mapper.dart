import '../../../home/domain/entities/cleaning_service.dart';
import '../entities/service_detail.dart';
import '../service_detail_config.dart';
import '../service_detail_presets.dart';

class ServiceDetailMapper {
  const ServiceDetailMapper._();

  static ServiceDetailConfig buildConfig({
    required CleaningService service,
    required ServiceDetail detail,
  }) {
    final preset = ServiceDetailPresets.resolve(service);
    final roomOptions =
        (detail.roomOptions.toList()
              ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0)))
            .map(
              (option) => ServiceRoomOption(
                id: option.id,
                label: option.title,
                area: option.subtitle ?? '',
                priceModifier: option.priceModifier,
              ),
            )
            .toList();
    final cleaningOptions =
        (detail.cleaningOptions.toList()
              ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0)))
            .map(
              (option) => ServiceCleaningOption(
                id: option.id,
                label: option.title,
                subtitle: option.subtitle,
                isAddon: option.isAddon,
                priceModifier: option.priceModifier,
              ),
            )
            .toList();
    final extraOptions =
        (detail.extraOptions.toList()
              ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0)))
            .map(
              (option) => ServiceCleaningOption(
                id: option.id,
                label: option.title,
                subtitle: option.subtitle,
                isAddon: true,
                priceModifier: option.priceModifier,
              ),
            )
            .toList();
    final mergedCleaningOptions = [...cleaningOptions, ...extraOptions];

    final bool hasRooms = roomOptions.isNotEmpty;
    final bool hasCleaning = mergedCleaningOptions.isNotEmpty;
    final bool presetHouse = preset.layout == ServiceDetailLayout.house;
    final ServiceDetailLayout layout = presetHouse
        ? ServiceDetailLayout.house
        : hasRooms
        ? ServiceDetailLayout.apartment
        : hasCleaning
        ? ServiceDetailLayout.house
        : preset.layout;

    final description = _resolveDescription(
      service,
      detail,
      preset.description,
    );

    final double minArea = detail.pricing?.minArea ?? preset.minArea;
    final double maxArea = detail.pricing?.maxArea ?? preset.maxArea;
    final double initialArea = _clampDouble(
      detail.pricing?.minArea ?? preset.initialArea,
      minArea,
      maxArea,
    );

    return ServiceDetailConfig(
      layout: layout,
      description: description,
      darkCard: preset.darkCard,
      arrivalMinutes: preset.arrivalMinutes,
      heroGradient: preset.heroGradient,
      heroIcon: preset.heroIcon,
      roomOptions: hasRooms ? roomOptions : preset.roomOptions,
      cleaningOptions: hasCleaning
          ? mergedCleaningOptions
          : preset.cleaningOptions,
      initialArea: initialArea,
      minArea: minArea,
      maxArea: maxArea,
      areaStep: detail.pricing?.areaStep ?? preset.areaStep,
      basePrice: detail.pricing?.basePrice,
      pricePerSqm: detail.pricing?.pricePerSqm,
      minPrice: detail.pricing?.minPrice,
    );
  }

  static String _resolveDescription(
    CleaningService service,
    ServiceDetail detail,
    String fallback,
  ) {
    final description = detail.description?.trim();
    if (description != null && description.isNotEmpty) {
      return description;
    }
    final shortDescription = detail.shortDescription?.trim();
    if (shortDescription != null && shortDescription.isNotEmpty) {
      return shortDescription;
    }
    return service.subtitle ?? fallback;
  }

  static double _clampDouble(double value, double min, double max) {
    if (min > max) {
      return value;
    }
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
