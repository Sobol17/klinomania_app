enum OrderHistoryStatus { awaitingCleaner, inProgress, completed, cancelled }

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
    this.district,
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
  final String? district;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? startStatusLabel;
  final String? endStatusLabel;
  final String? durationLabel;
  final bool highlightCard;
  final OrderCleaner cleaner;

  bool get canCancel => status == OrderHistoryStatus.awaitingCleaner;
  bool get canRepeat => status != OrderHistoryStatus.awaitingCleaner;
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
      id: 'awaiting-standard',
      status: OrderHistoryStatus.awaitingCleaner,
      serviceName: 'Стандарт',
      cleaningType: 'Поддерживающая',
      roomsDescription: '1-комнатная',
      address: 'Кутузовский проспект, 23к2, подъезд 1, кв. 44',
      district: 'Центральный',
      price: 4500,
      paymentMethod: 'ПОДЕЛИ',
      scheduledAt: today.add(const Duration(hours: 11)),
      startStatusLabel: 'Ожидание клинера',
      endStatusLabel: 'Ожидание клинера',
      durationLabel: 'Ожидание клинера',
      cleaner: cleaner,
    ),
    OrderHistoryEntry(
      id: 'progress-express',
      status: OrderHistoryStatus.inProgress,
      serviceName: 'Экспресс',
      cleaningType: 'Поддерживающая',
      area: 65,
      address: 'Кутузовский проспект, 23к2, подъезд 1, кв. 44',
      district: 'Центральный',
      price: 3500,
      paymentMethod: 'СБП',
      scheduledAt: today.add(const Duration(hours: 9, minutes: 30)),
      startTime: today.add(const Duration(hours: 12)),
      endStatusLabel: 'В процессе',
      durationLabel: 'В процессе',
      cleaner: cleaner,
    ),
    OrderHistoryEntry(
      id: 'completed-premium',
      status: OrderHistoryStatus.completed,
      serviceName: 'Премиум',
      cleaningType: 'Генеральная',
      area: 120,
      address: 'Профсоюзная улица, 16, подъезд 3, кв. 88',
      district: 'Южный',
      price: 7500,
      paymentMethod: 'СБП',
      scheduledAt: yesterday.add(const Duration(hours: 11, minutes: 30)),
      startTime: yesterday.add(const Duration(hours: 11, minutes: 30)),
      endTime: yesterday.add(const Duration(hours: 14)),
      durationLabel: '2 ч 30 мин',
      highlightCard: true,
      cleaner: cleaner,
    ),
    OrderHistoryEntry(
      id: 'cancelled-office',
      status: OrderHistoryStatus.cancelled,
      serviceName: 'Офис',
      cleaningType: 'Поддерживающая',
      area: 180,
      address: 'Пресненская наб., 10, офис 1201',
      district: 'Западный',
      price: 2500,
      paymentMethod: 'СБП',
      scheduledAt: earlierTwo.add(const Duration(hours: 9, minutes: 30)),
      startTime: earlierTwo.add(const Duration(hours: 12)),
      endStatusLabel: 'В процессе',
      durationLabel: 'В процессе',
      cleaner: cleaner,
    ),
    OrderHistoryEntry(
      id: 'completed-standard',
      status: OrderHistoryStatus.completed,
      serviceName: 'Стандарт',
      cleaningType: 'Поддерживающая',
      area: 70,
      address: 'Большая Никитская, 18, подъезд 2, кв. 12',
      district: 'Северный',
      price: 4500,
      paymentMethod: 'СБП',
      scheduledAt: earlierThree.add(const Duration(hours: 8)),
      startTime: earlierThree.add(const Duration(hours: 8)),
      endTime: earlierThree.add(const Duration(hours: 10, minutes: 30)),
      durationLabel: '2 ч 30 мин',
      cleaner: cleaner,
    ),
    OrderHistoryEntry(
      id: 'completed-express-2',
      status: OrderHistoryStatus.completed,
      serviceName: 'Экспресс',
      cleaningType: 'После ремонта',
      area: 55,
      address: 'Садовая-Триумфальная, 4, подъезд 1, кв. 21',
      district: 'Восточный',
      price: 4000,
      paymentMethod: 'Наличные',
      scheduledAt: earlierFour.add(const Duration(hours: 8)),
      startTime: earlierFour.add(const Duration(hours: 8)),
      endTime: earlierFour.add(const Duration(hours: 9, minutes: 40)),
      durationLabel: '1 ч 40 мин',
      cleaner: cleaner,
    ),
  ];

  orders.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  return orders;
}
