import '../models/service_detail_model.dart';
import '../models/service_model.dart';

class ServicesRemoteDataSource {
  ServicesRemoteDataSource();

  final List<ServiceDetailModel> _services = [
    ServiceDetailModel(
      id: 'standard',
      title: 'Стандарт',
      subtitle: 'Регулярная уборка квартиры',
      shortDescription: 'Поддержим чистоту в основных зонах.',
      description:
          'Пыль, полы, кухня, санузел и аккуратная расстановка вещей на видимых поверхностях.',
      cleanersLabel: '1 клинер',
      durationLabel: '2-3 часа',
      priceFrom: 2900,
      imageUrl: null,
      gallery: const [],
      pricing: const ServicePricingModel(
        basePrice: 1200,
        pricePerSqm: 35,
        minArea: 30,
        maxArea: 160,
        minPrice: 2900,
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
      title: 'Премиум',
      subtitle: 'Глубокая уборка с вниманием к деталям',
      shortDescription: 'Для сложных загрязнений и подготовки квартиры.',
      description:
          'Расширенный набор работ, включая труднодоступные места, фасады и деликатные поверхности.',
      cleanersLabel: '2 клинера',
      durationLabel: '4-6 часов',
      priceFrom: 5900,
      imageUrl: null,
      gallery: const [],
      pricing: const ServicePricingModel(
        basePrice: 2500,
        pricePerSqm: 55,
        minArea: 30,
        maxArea: 220,
        minPrice: 5900,
      ),
      roomOptions: const [],
      cleaningOptions: const [],
      extraOptions: const [],
      createdAt: null,
      updatedAt: null,
    ),
    ServiceDetailModel(
      id: 'cottage',
      title: 'Коттедж',
      subtitle: 'Уборка домов и больших помещений',
      shortDescription: 'Настраиваем объём работ под площадь дома.',
      description:
          'Поддерживающая, генеральная уборка или уборка после ремонта для частного дома.',
      cleanersLabel: '2-4 клинера',
      durationLabel: 'от 5 часов',
      priceFrom: 9900,
      imageUrl: null,
      gallery: const [],
      pricing: const ServicePricingModel(
        basePrice: 3500,
        pricePerSqm: 45,
        minArea: 60,
        maxArea: 600,
        minPrice: 9900,
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
