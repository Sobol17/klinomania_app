import 'package:flutter/material.dart';

enum ServiceDetailLayout { apartment, house }

class ServiceRoomOption {
  const ServiceRoomOption({
    required this.id,
    required this.label,
    required this.area,
    this.priceModifier,
  });

  final String id;
  final String label;
  final String area;
  final double? priceModifier;
}

class ServiceCleaningOption {
  const ServiceCleaningOption({
    required this.id,
    required this.label,
    this.subtitle,
    this.isAddon = false,
    this.priceModifier,
  });

  final String id;
  final String label;
  final String? subtitle;
  final bool isAddon;
  final double? priceModifier;
}

class ServiceDetailConfig {
  const ServiceDetailConfig({
    required this.layout,
    required this.description,
    this.darkCard = false,
    this.arrivalMinutes = 60,
    this.heroGradient = const [Color(0xFFE3EDFF), Color(0xFFFFFFFF)],
    this.heroIcon = Icons.weekend,
    this.roomOptions,
    this.cleaningOptions,
    this.initialArea = 60,
    this.minArea = 30,
    this.maxArea = 400,
    this.areaStep = 10,
    this.basePrice,
    this.pricePerSqm,
    this.minPrice,
  });

  final ServiceDetailLayout layout;
  final String description;
  final bool darkCard;
  final int arrivalMinutes;
  final List<Color> heroGradient;
  final IconData heroIcon;
  final List<ServiceRoomOption>? roomOptions;
  final List<ServiceCleaningOption>? cleaningOptions;
  final double initialArea;
  final double minArea;
  final double maxArea;
  final double areaStep;
  final double? basePrice;
  final double? pricePerSqm;
  final double? minPrice;

  ServiceCheckoutPayload toCheckoutPayload({
    required double area,
    required String? selectedRoomId,
    required String? selectedCleaningId,
    required Set<String> selectedAddOns,
  }) {
    return ServiceCheckoutPayload(
      area: area,
      selectedRoomId: selectedRoomId,
      selectedCleaningId: selectedCleaningId,
      selectedAddOns: selectedAddOns,
    );
  }

  double calculateTotalPrice({
    required double area,
    required String? selectedRoomId,
    required String? selectedCleaningId,
    required Set<String> selectedAddOns,
    double? fallbackPrice,
  }) {
    final double safeArea = area.isFinite && area > 0 ? area : 0;
    final bool hasPricing = basePrice != null || pricePerSqm != null;
    double total = hasPricing
        ? (basePrice ?? 0) + (pricePerSqm ?? 0) * safeArea
        : (fallbackPrice ?? 0);

    total += _modifierForRoom(selectedRoomId);
    total += _modifierForCleaning(selectedCleaningId);
    total += _modifiersForAddOns(selectedAddOns);

    final double? minimum = minPrice;
    if (minimum != null && total < minimum) {
      total = minimum;
    }

    return total.isFinite && total >= 0 ? total : 0;
  }

  double _modifierForRoom(String? roomId) {
    if (roomId == null) return 0;
    for (final option in roomOptions ?? const <ServiceRoomOption>[]) {
      if (option.id == roomId) {
        return option.priceModifier ?? 0;
      }
    }
    return 0;
  }

  double _modifierForCleaning(String? cleaningId) {
    if (cleaningId == null) return 0;
    for (final option in cleaningOptions ?? const <ServiceCleaningOption>[]) {
      if (option.id == cleaningId) {
        return option.priceModifier ?? 0;
      }
    }
    return 0;
  }

  double _modifiersForAddOns(Set<String> addOns) {
    if (addOns.isEmpty) return 0;
    double total = 0;
    for (final option in cleaningOptions ?? const <ServiceCleaningOption>[]) {
      if (option.isAddon && addOns.contains(option.id)) {
        total += option.priceModifier ?? 0;
      }
    }
    return total;
  }
}

class ServiceCheckoutPayload {
  const ServiceCheckoutPayload({
    required this.area,
    required this.selectedRoomId,
    required this.selectedCleaningId,
    required this.selectedAddOns,
  });

  final double area;
  final String? selectedRoomId;
  final String? selectedCleaningId;
  final Set<String> selectedAddOns;
}
