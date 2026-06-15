import '../models/service_detail_model.dart';
import '../models/service_model.dart';

class ServicesRemoteDataSource {
  ServicesRemoteDataSource();

  static const List<ServiceOptionModel> _defaultRoomOptions = [
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
    ServiceOptionModel(
      id: 'room-3',
      title: '3-комнатная',
      subtitle: '70-100 м²',
      isAddon: false,
      isDefault: false,
      priceModifier: 1200,
    ),
    ServiceOptionModel(
      id: 'room-4',
      title: '4-комнатная',
      subtitle: 'от 100 м²',
      isAddon: false,
      isDefault: false,
      priceModifier: 1800,
    ),
  ];

  static const List<ServiceOptionModel> _basicMinimumExtraOptions = [
    ServiceOptionModel(
      id: 'fridge-inside',
      title: 'Холодильник внутри (освобожденный и размороженный)',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 800,
    ),
    ServiceOptionModel(
      id: 'microwave-inside',
      title: 'Микроволновка внутри',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 700,
    ),
    ServiceOptionModel(
      id: 'hood-grates',
      title: 'Кухонная вытяжка с решетками',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 800,
    ),
    ServiceOptionModel(
      id: 'oven-inside',
      title: 'Духовка внутри',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 800,
    ),
    ServiceOptionModel(
      id: 'pet-tray-bowls',
      title: 'Моем лоток и миски питомца',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 700,
    ),
    ServiceOptionModel(
      id: 'kitchen-cabinets-inside',
      title:
          'Шкафы и ящики кухонного гарнитура внутри при условии, что они пустые',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 1500,
    ),
    ServiceOptionModel(
      id: 'washer-dryer-inside',
      title: 'Стиральную/сушильную машину внутри',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 300,
    ),
    ServiceOptionModel(
      id: 'bathroom-tile-deep',
      title:
          'Очистить кафельную плитку, межплиточные швы и вытяжку от сильных загрязнений по всей высоте (в санузле)',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 1500,
    ),
    ServiceOptionModel(
      id: 'sanitary-deep',
      title:
          'Очистить сантехнику, смесители от сильных загрязнений: ржавчина, водный камень, известковый налет (1 час)',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 1200,
    ),
    ServiceOptionModel(
      id: 'ironing-hour',
      title: 'Глажка (1 час)',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 1200,
    ),
    ServiceOptionModel(
      id: 'steam-generator',
      title: 'Уборка парогенератором',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 1500,
    ),
    ServiceOptionModel(
      id: 'windows-room-1',
      title: 'Помыть окна',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 3500,
    ),
    ServiceOptionModel(
      id: 'windows-room-2',
      title: 'Помыть окна',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 5250,
    ),
    ServiceOptionModel(
      id: 'windows-room-3',
      title: 'Помыть окна',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 7700,
    ),
    ServiceOptionModel(
      id: 'windows-room-4',
      title: 'Помыть окна',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 8750,
    ),
    ServiceOptionModel(
      id: 'ladder',
      title: 'Стремянка',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 1500,
    ),
  ];

  static const List<ServiceOptionModel> _generalExtraOptions = [
    ServiceOptionModel(
      id: 'chandelier-cleaning',
      title: 'Моем сложные и хрустальные люстры и светильники',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 1000,
    ),
    ServiceOptionModel(
      id: 'balcony-loggia',
      title: 'Убираем на балконе/лоджии (включая окна)',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 4000,
    ),
    ServiceOptionModel(
      id: 'pet-tray-bowls',
      title: 'Моем лоток и миски питомца',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 700,
    ),
    ServiceOptionModel(
      id: 'bedding-wash-hang',
      title: 'Стираем и развешиваем постельное белье (до 2 загрузок)',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 700,
    ),
    ServiceOptionModel(
      id: 'ironing-hour',
      title: 'Гладим вещи (до 60 минут)',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 1200,
    ),
    ServiceOptionModel(
      id: 'special-errands',
      title:
          'Выполним особые поручения (до 30 минут): отнести вещи в химчистку, покормить питомца и т.д.',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 1200,
    ),
    ServiceOptionModel(
      id: 'windows-room-1',
      title: 'Помыть окна',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 3500,
    ),
    ServiceOptionModel(
      id: 'windows-room-2',
      title: 'Помыть окна',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 5250,
    ),
    ServiceOptionModel(
      id: 'windows-room-3',
      title: 'Помыть окна',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 7700,
    ),
    ServiceOptionModel(
      id: 'windows-room-4',
      title: 'Помыть окна',
      subtitle: null,
      isAddon: true,
      isDefault: false,
      priceModifier: 8750,
    ),
  ];

  final List<ServiceDetailModel> _services = [
    ServiceDetailModel(
      id: 'standard',
      title: 'Базовый минимум',
      subtitle: 'Базовый минимум. Расширенная поддерживающая уборка',
      shortDescription:
          'Оптимальный выбор для регулярного поддержания чистоты.',
      description:
          'Оптимальный выбор для регулярного поддержания чистоты. Клинеры обрабатывают все доступные поверхности на уровне человеческого роста, моют полы, чистят кухню и санузел, приводят в порядок мебель и технику.Стремянка и парогенератор при этом тарифе не включены — предоставляются по запросу.',
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
      roomOptions: _defaultRoomOptions,
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
      extraOptions: _basicMinimumExtraOptions,
      createdAt: null,
      updatedAt: null,
    ),
    ServiceDetailModel(
      id: 'premium',
      title: 'Генеральская',
      subtitle: 'Глубокая уборка с проработкой деталей',
      shortDescription: 'глубокая уборка с проработкой деталей',
      description:
          'Если нужно обновить квартиру и тщательно очистить труднодоступные зоны. Мы отмываем плитку и швы, фасады мебели, сантехнику и все комнаты «до блеска».Подходит для тех, кто хочет «разобраться с уборкой разом», не устраивая домашний субботник.',
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
      roomOptions: _defaultRoomOptions,
      cleaningOptions: const [],
      extraOptions: _generalExtraOptions,
      createdAt: null,
      updatedAt: null,
    ),
    ServiceDetailModel(
      id: 'cottage',
      title: 'Роскошный максимум',
      subtitle: 'Премиальный клининг «всё включено»',
      shortDescription: 'Максимальный уровень комфорта ',
      description:
          'Максимальный уровень комфорта: \n- чистка мягкой мебели от пылевых клещей (пылесос + парогенератор); \n- мойка хрустальных люстр и светильников; \n- мойка окон – включена в тариф без доплат и сложных настроек; \n- уборка балкона или лоджии; \n- уход за растениями, животными, текстилем (стирка, глажка, развешивание белья, до 2 загрузок); \n- выполнение мелких поручений (до 30 мин: доставка в химчистку, кормление питомца и др.); \n- обработка труднодоступных поверхностей, удаление плесени, разбор шкафов и ящиков — по запросу.',
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
