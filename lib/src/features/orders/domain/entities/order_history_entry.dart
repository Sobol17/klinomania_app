enum OrderHistoryStatus {
  processing,
  confirmed,
  teamFormed,
  inProgress,
  awaitingPayment,
  completed,
  cancelled,
}

class OrderCleaner {
  const OrderCleaner({
    required this.name,
    required this.speciality,
    this.avatarAsset,
  });

  final String name;
  final String speciality;
  final String? avatarAsset;
}

class OrderHistoryEntry {
  const OrderHistoryEntry({
    required this.id,
    required this.status,
    required this.serviceName,
    required this.cleaningType,
    required this.address,
    required this.price,
    required this.paymentMethod,
    required this.scheduledAt,
    required this.cleaner,
    this.area,
    this.roomsDescription,
    this.mainCleaningOption,
    this.additionalOptions = const [],
    this.startTime,
    this.endTime,
    this.startStatusLabel,
    this.endStatusLabel,
    this.durationLabel,
    this.highlightCard = false,
  });

  final String id;
  final OrderHistoryStatus status;
  final String serviceName;
  final String cleaningType;
  final String address;
  final double price;
  final String paymentMethod;
  final DateTime scheduledAt;
  final double? area;
  final String? roomsDescription;
  final String? mainCleaningOption;
  final List<String> additionalOptions;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? startStatusLabel;
  final String? endStatusLabel;
  final String? durationLabel;
  final bool highlightCard;
  final OrderCleaner cleaner;

  bool get canCancel =>
      status == OrderHistoryStatus.processing ||
      status == OrderHistoryStatus.confirmed;
  bool get canRepeat => !canCancel;
  bool get canPay => status == OrderHistoryStatus.awaitingPayment;
}

List<OrderHistoryEntry> buildMockOrderHistory() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final earlierTwo = today.subtract(const Duration(days: 2));
  final earlierThree = today.subtract(const Duration(days: 3));
  final earlierFour = today.subtract(const Duration(days: 4));

  const cleaner = OrderCleaner(
    name: 'Наталия Бердникова',
    speciality: 'Все виды уборки',
    avatarAsset: null,
  );

  final orders = <OrderHistoryEntry>[
    OrderHistoryEntry(
      id: 'awaiting-basic-minimum',
      status: OrderHistoryStatus.processing,
      serviceName: 'Базовый минимум',
      cleaningType: 'Расширенная поддерживающая уборка',
      roomsDescription: '1-комнатная',
      additionalOptions: ['Холодильник внутри', 'Микроволновка внутри'],
      address: 'Кутузовский проспект, 23к2, подъезд 1, кв. 44',
      price: 8500,
      paymentMethod: 'Не выбран',
      scheduledAt: today.add(const Duration(hours: 11)),
      startStatusLabel: 'Ожидание клинера',
      endStatusLabel: 'Ожидание клинера',
      durationLabel: 'Ожидание клинера',
      cleaner: cleaner,
    ),
    OrderHistoryEntry(
      id: 'progress-general',
      status: OrderHistoryStatus.inProgress,
      serviceName: 'Генеральская',
      cleaningType: 'Глубокая уборка с проработкой деталей',
      roomsDescription: '2-комнатная',
      additionalOptions: ['Убираем на балконе/лоджии', 'Моем окна'],
      address: 'Кутузовский проспект, 23к2, подъезд 1, кв. 44',
      price: 24600,
      paymentMethod: 'Не выбран',
      scheduledAt: today.add(const Duration(hours: 9, minutes: 30)),
      startTime: today.add(const Duration(hours: 12)),
      endStatusLabel: 'В процессе',
      durationLabel: 'В процессе',
      cleaner: cleaner,
    ),
    OrderHistoryEntry(
      id: 'completed-luxury-maximum',
      status: OrderHistoryStatus.completed,
      serviceName: 'Роскошный максимум',
      cleaningType: 'Премиальный клининг «всё включено»',
      additionalOptions: const [],
      address: 'Профсоюзная улица, 16, подъезд 3, кв. 88',
      price: 25000,
      paymentMethod: 'Не выбран',
      scheduledAt: yesterday.add(const Duration(hours: 11, minutes: 30)),
      startTime: yesterday.add(const Duration(hours: 11, minutes: 30)),
      endTime: yesterday.add(const Duration(hours: 17)),
      durationLabel: '5 ч 30 мин',
      highlightCard: true,
      cleaner: cleaner,
    ),
    OrderHistoryEntry(
      id: 'cancelled-basic-minimum',
      status: OrderHistoryStatus.cancelled,
      serviceName: 'Базовый минимум',
      cleaningType: 'Расширенная поддерживающая уборка',
      roomsDescription: '3-комнатная',
      additionalOptions: ['Духовка внутри', 'Стремянка'],
      address: 'Пресненская наб., 10, офис 1201',
      price: 8900,
      paymentMethod: 'Не выбран',
      scheduledAt: earlierTwo.add(const Duration(hours: 9, minutes: 30)),
      startStatusLabel: 'Отменено',
      endStatusLabel: 'Отменено',
      durationLabel: 'Отменено',
      cleaner: cleaner,
    ),
    OrderHistoryEntry(
      id: 'completed-basic-minimum',
      status: OrderHistoryStatus.completed,
      serviceName: 'Базовый минимум',
      cleaningType: 'Расширенная поддерживающая уборка',
      roomsDescription: '2-комнатная',
      additionalOptions: ['Шкафы и ящики кухонного гарнитура внутри', 'Окна'],
      address: 'Большая Никитская, 18, подъезд 2, кв. 12',
      price: 13450,
      paymentMethod: 'Не выбран',
      scheduledAt: earlierThree.add(const Duration(hours: 8)),
      startTime: earlierThree.add(const Duration(hours: 8)),
      endTime: earlierThree.add(const Duration(hours: 11)),
      durationLabel: '3 ч',
      cleaner: cleaner,
    ),
    OrderHistoryEntry(
      id: 'completed-general',
      status: OrderHistoryStatus.completed,
      serviceName: 'Генеральская',
      cleaningType: 'Глубокая уборка с проработкой деталей',
      roomsDescription: '4-комнатная',
      additionalOptions: [
        'Моем сложные и хрустальные люстры и светильники',
        'Гладим вещи',
      ],
      address: 'Садовая-Триумфальная, 4, подъезд 1, кв. 21',
      price: 28000,
      paymentMethod: 'Не выбран',
      scheduledAt: earlierFour.add(const Duration(hours: 8)),
      startTime: earlierFour.add(const Duration(hours: 8)),
      endTime: earlierFour.add(const Duration(hours: 13, minutes: 20)),
      durationLabel: '5 ч 20 мин',
      cleaner: cleaner,
    ),
  ];

  orders.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  return orders;
}
