import '../models/service_detail_model.dart';
import '../models/service_model.dart';

class ServicesRemoteDataSource {
  ServicesRemoteDataSource();

  final List<ServiceDetailModel> _services = [
    ServiceDetailModel(
      id: 'standard',
      title: 'Базовый минимум',
      subtitle: 'Оптимальный выбор для регулярного поддержания чистоты.',
      shortDescription:
          'Оптимальный выбор для регулярного поддержания чистоты.',
      description:
          'Оптимальный выбор для регулярного поддержания чистоты.\n\n'
          'Стремянка и парогенератор при этом тарифе не включены, '
          'предоставляются по запросу.\n\n'
          'Стоимость для однокомнатной квартиры.',
      cleanersLabel: '1 клинер',
      durationLabel: '2-3 часа',
      priceFrom: 7700,
      imageUrl: null,
      gallery: const [],
      pricing: const ServicePricingModel(
        basePrice: 7700,
        pricePerSqm: 0,
        minArea: 30,
        maxArea: 160,
        minPrice: 7700,
      ),
      roomOptions: const [
        ServiceOptionModel(
          id: 'room-1',
          title: '1-комнатная',
          subtitle: '30-50 м²',
          isAddon: false,
          isDefault: true,
          priceModifier: 0,
        ),
        ServiceOptionModel(
          id: 'room-2',
          title: '2-комнатная',
          subtitle: '50-70 м²',
          isAddon: false,
          isDefault: false,
          priceModifier: 600,
        ),
      ],
      cleaningOptions: const [
        ServiceOptionModel(
          id: 'support',
          title: 'Поддерживающая',
          subtitle: null,
          isAddon: false,
          isDefault: true,
          priceModifier: 0,
        ),
        ServiceOptionModel(
          id: 'general',
          title: 'Генеральная',
          subtitle: null,
          isAddon: false,
          isDefault: false,
          priceModifier: 1800,
        ),
      ],
      extraOptions: const [
        ServiceOptionModel(
          id: 'windows',
          title: 'Мойка окон',
          subtitle: 'Дополнительная опция',
          isAddon: true,
          isDefault: false,
          priceModifier: 900,
        ),
      ],
      createdAt: null,
      updatedAt: null,
    ),
    ServiceDetailModel(
      id: 'premium',
      title: 'Генеральская',
      subtitle:
          'Тщательная уборка для возвращения идеального порядка в каждом углу.',
      shortDescription:
          'Тщательная уборка для возвращения идеального порядка в каждом углу.',
      description:
          'Тщательная уборка для возвращения идеального порядка в каждом углу.\n\n'
          'Мы отмываем плитку и швы, фасады мебели, сантехнику и все комнаты.\n\n'
          'Стоимость для однокомнатной квартиры.',
      cleanersLabel: '2 клинера',
      durationLabel: '4-6 часов',
      priceFrom: 18000,
      imageUrl: null,
      gallery: const [],
      pricing: const ServicePricingModel(
        basePrice: 18000,
        pricePerSqm: 0,
        minArea: 30,
        maxArea: 220,
        minPrice: 18000,
      ),
      roomOptions: const [],
      cleaningOptions: const [],
      extraOptions: const [],
      createdAt: null,
      updatedAt: null,
    ),
    ServiceDetailModel(
      id: 'cottage',
      title: 'Роскошный максимум',
      subtitle: 'Максимальный уровень чистоты. Мойка окон включена в тариф.',
      shortDescription:
          'Максимальный уровень чистоты. Мойка окон включена в тариф.',
      description:
          'Максимальный уровень чистоты. Мойка окон включена в тариф.\n\n'
          'Включены: уборка балкона, уход за растениями, животными, '
          'мелкие поручения.\n\n'
          'Стоимость для однокомнатной квартиры.',
      cleanersLabel: '2-4 клинера',
      durationLabel: 'от 5 часов',
      priceFrom: 25000,
      imageUrl: null,
      gallery: const [],
      pricing: const ServicePricingModel(
        basePrice: 25000,
        pricePerSqm: 0,
        minArea: 60,
        maxArea: 600,
        minPrice: 25000,
      ),
      roomOptions: const [],
      cleaningOptions: const [
        ServiceOptionModel(
          id: 'support',
          title: 'Поддерживающая',
          subtitle: null,
          isAddon: false,
          isDefault: true,
          priceModifier: 0,
        ),
        ServiceOptionModel(
          id: 'repair',
          title: 'После ремонта',
          subtitle: null,
          isAddon: false,
          isDefault: false,
          priceModifier: 3500,
        ),
      ],
      extraOptions: const [],
      createdAt: null,
      updatedAt: null,
    ),
  ];

  Future<List<ServiceModel>> fetchServices() async {
    await _mockDelay();
    return _services.map(_toServiceModel).toList(growable: false);
  }

  Future<ServiceDetailModel> fetchServiceDetail(String id) async {
    await _mockDelay();
    return _services.firstWhere(
      (service) => service.id == id,
      orElse: () => _services.first,
    );
  }

  ServiceModel _toServiceModel(ServiceDetailModel detail) {
    return ServiceModel(
      id: detail.id,
      title: detail.title,
      subtitle: detail.subtitle,
      shortDescription: detail.shortDescription,
      description: detail.description,
      cleanersLabel: detail.cleanersLabel ?? '-',
      durationLabel: detail.durationLabel ?? '-',
      priceFrom: detail.priceFrom,
      imageUrl: detail.imageUrl,
      gallery: detail.gallery,
      createdAt: detail.createdAt,
      updatedAt: detail.updatedAt,
    );
  }

  Future<void> _mockDelay() {
    return Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
