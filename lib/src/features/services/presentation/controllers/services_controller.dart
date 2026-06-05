import 'package:flutter/material.dart';

import '../../../home/domain/entities/cleaning_service.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/repositories/services_repository.dart';
import '../../domain/utils/service_detail_mapper.dart';
import '../../domain/service_detail_config.dart';

class ServicesController extends ChangeNotifier {
  ServicesController({required this.repository, this.useApi = true}) {
    if (!useApi) {
      _services = _mockServices;
      _seedCache(_services);
    }
  }

  final ServicesRepository repository;
  final bool useApi;

  List<CleaningService> _services = [];
  final Map<String, CleaningService> _cache = {};
  final Map<String, ServiceDetailConfig> _detailConfigs = {};
  final Set<String> _detailLoading = {};
  final Map<String, String> _detailErrors = {};
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _listError;

  List<CleaningService> get services => List.unmodifiable(_services);
  bool get isLoading => _isLoading;
  String? get listError => _listError;

  CleaningService? serviceById(String id) => _cache[id];
  ServiceDetailConfig? detailConfig(String id) => _detailConfigs[id];
  bool isDetailLoading(String id) => _detailLoading.contains(id);
  String? detailError(String id) => _detailErrors[id];

  void ensureLoaded() {
    if (_hasLoaded || _isLoading) {
      return;
    }
    _hasLoaded = true;
    loadServices();
  }

  Future<void> loadServices() async {
    if (_isLoading) return;
    _isLoading = true;
    _listError = null;
    notifyListeners();

    try {
      if (useApi) {
        _services = await repository.fetchServices();
      } else {
        _services = _mockServices;
      }
      _seedCache(_services);
    } catch (error) {
      _listError = _mapError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadServiceDetails(String id) async {
    if (!useApi) {
      return;
    }
    if (_detailLoading.contains(id)) return;
    if (_detailConfigs.containsKey(id)) return;

    _detailErrors.remove(id);
    _detailLoading.add(id);
    notifyListeners();

    try {
      final detail = await repository.fetchServiceDetail(id);

      final service = _mergeServiceDetail(detail);
      final config = ServiceDetailMapper.buildConfig(
        service: service,
        detail: detail,
      );
      _detailConfigs[id] = config;
    } catch (error) {
      _detailErrors[id] = _mapError(error);
    } finally {
      _detailLoading.remove(id);
      notifyListeners();
    }
  }

  CleaningService _mergeServiceDetail(ServiceDetail detail) {
    final bool isPremium = detail.id.toLowerCase() == 'premium';
    final existing = _cache[detail.id];
    final mergedGallery = detail.gallery.isNotEmpty
        ? detail.gallery
        : existing?.gallery ?? const [];
    final mergedShortDescription =
        detail.shortDescription ?? existing?.shortDescription;
    final mergedDescription = detail.description ?? existing?.description;
    final mergedSubtitle = detail.subtitle ?? existing?.subtitle;
    final mergedCleaners = detail.cleanersLabel ?? existing?.cleaners ?? '-';
    final mergedDuration = detail.durationLabel ?? existing?.duration ?? '-';
    final mergedImageUrl = detail.imageUrl ?? existing?.imageUrl;
    final mergedPriceFrom = detail.priceFrom ?? existing?.priceFrom;

    final updated = CleaningService(
      id: detail.id,
      title: detail.title,
      subtitle: mergedSubtitle,
      cleaners: mergedCleaners,
      duration: mergedDuration,
      imageUrl: mergedImageUrl,
      shortDescription: mergedShortDescription,
      description: mergedDescription,
      priceFrom: mergedPriceFrom,
      gallery: mergedGallery,
      cardStyle: isPremium
          ? CleaningServiceCardStyle.dark
          : CleaningServiceCardStyle.light,
    );

    if (existing != null) {
      final merged = existing.copyWith(
        title: updated.title,
        subtitle: mergedSubtitle,
        cleaners: mergedCleaners,
        duration: mergedDuration,
        imageUrl: mergedImageUrl,
        shortDescription: mergedShortDescription,
        description: mergedDescription,
        priceFrom: mergedPriceFrom,
        gallery: mergedGallery,
        cardStyle: updated.cardStyle,
      );
      _cache[detail.id] = merged;
      final index = _services.indexWhere((item) => item.id == detail.id);
      if (index >= 0) {
        _services[index] = merged;
      }
      return merged;
    }

    _cache[detail.id] = updated;
    return updated;
  }

  void _seedCache(List<CleaningService> items) {
    for (final service in items) {
      _cache[service.id] = service;
    }
  }

  String _mapError(Object error) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }

    return 'Что-то пошло не так. Попробуйте снова';
  }

  static final List<CleaningService> _mockServices = [
    CleaningService(
      id: 'express',
      title: 'Экспресс',
      subtitle: 'Быстрая уборка общих зон',
      cleaners: '1 клинер',
      duration: '2 часа',
      imageAsset: 'assets/images/interier_png.png',
    ),
    CleaningService(
      id: 'standard',
      title: 'Стандарт',
      subtitle: 'Поддерживающая уборка',
      cleaners: '1-2 клинера',
      duration: '2 часа',
      imageAsset: 'assets/images/interier_png.png',
    ),
    CleaningService(
      id: 'cottage',
      title: 'Коттедж',
      subtitle: 'Наведём порядок в больших помещениях',
      cleaners: '1 клинер',
      duration: '2-4 часа',
      imageAsset: 'assets/images/cottage_png.png',
    ),
    CleaningService(
      id: 'premium',
      title: 'Премиум',
      subtitle: 'Для больших пространств',
      cleaners: '1-3 клинера',
      duration: '2-4 часа',
      cardStyle: CleaningServiceCardStyle.dark,
    ),
    CleaningService(
      id: 'office',
      title: 'Офис',
      cleaners: '1 клинер',
      duration: '2 часа',
      imageAsset: 'assets/images/interier_png.png',
    ),
    CleaningService(
      id: 'kids',
      title: 'Детская',
      cleaners: '1 клинер',
      duration: '2 часа',
      imageAsset: 'assets/images/interier_png.png',
    ),
  ];
}
