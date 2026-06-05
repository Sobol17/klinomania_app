enum CleanerOrderStatus { available, assigned, completed }

class CleanerOrderServiceOption {
  const CleanerOrderServiceOption({required this.label, this.enabled = true});

  final String label;
  final bool enabled;
}

class CleanerOrder {
  const CleanerOrder({
    required this.id,
    required this.planName,
    required this.objectType,
    required this.address,
    required this.price,
    required this.startAt,
    required this.cleanersLabel,
    required this.durationLabel,
    required this.comment,
    required this.area,
    required this.status,
    required this.services,
    this.highlightCard = false,
  });

  final String id;
  final String planName;
  final String objectType;
  final String address;
  final double price;
  final DateTime startAt;
  final String cleanersLabel;
  final String durationLabel;
  final String comment;
  final double area;
  final CleanerOrderStatus status;
  final List<CleanerOrderServiceOption> services;
  final bool highlightCard;

  bool get canAccept => status == CleanerOrderStatus.available;
  bool get isCompleted => status == CleanerOrderStatus.completed;
}

List<CleanerOrder> buildMockCleanerOrders() {
  final now = DateTime.now();
  final baseDate = DateTime(now.year, now.month, now.day, 12, 30);

  return <CleanerOrder>[
    CleanerOrder(
      id: 'premium-available',
      planName: 'Премиум',
      objectType: 'Коттедж',
      address: 'Кутузовский проспект, 23к2, подъезд 1, кв. 44',
      price: 7500,
      startAt: baseDate,
      cleanersLabel: '1-3 клинера',
      durationLabel: '2-4 часа',
      comment: 'Позвоните за 25 минут до прибытия',
      area: 360,
      status: CleanerOrderStatus.available,
      highlightCard: true,
      services: const [
        CleanerOrderServiceOption(label: 'Поддерживающая'),
        CleanerOrderServiceOption(label: 'Мойка окон', enabled: false),
      ],
    ),
    CleanerOrder(
      id: 'express-assigned',
      planName: 'Экспресс',
      objectType: 'Квартира',
      address: 'Кутузовский проспект, 23к2, подъезд 1, кв. 44',
      price: 3500,
      startAt: baseDate.add(const Duration(hours: 2)),
      cleanersLabel: '1 клинер',
      durationLabel: '2 часа',
      comment: 'Код на домофоне #4444',
      area: 65,
      status: CleanerOrderStatus.assigned,
      services: const [
        CleanerOrderServiceOption(label: 'Стандартная'),
        CleanerOrderServiceOption(label: 'Мытьё посуды'),
      ],
    ),
    CleanerOrder(
      id: 'standard-assigned',
      planName: 'Стандарт',
      objectType: 'Квартира',
      address: 'Кутузовский проспект, 23к2, подъезд 1, кв. 44',
      price: 4500,
      startAt: baseDate.add(const Duration(days: 1)),
      cleanersLabel: '1-2 клинера',
      durationLabel: '3 часа',
      comment: 'Оцените кухню особое внимание',
      area: 70,
      status: CleanerOrderStatus.assigned,
      services: const [
        CleanerOrderServiceOption(label: 'Поддерживающая'),
        CleanerOrderServiceOption(label: 'Мойка окон', enabled: false),
      ],
    ),
    CleanerOrder(
      id: 'office-completed',
      planName: 'Офис',
      objectType: 'Офис',
      address: 'Пресненская наб., 10, офис 1201',
      price: 3500,
      startAt: baseDate.subtract(const Duration(days: 1)),
      cleanersLabel: '1 клинер',
      durationLabel: '2 часа',
      comment: 'Пропуск у охраны, спросите менеджера',
      area: 180,
      status: CleanerOrderStatus.completed,
      services: const [
        CleanerOrderServiceOption(label: 'Еженедельная'),
        CleanerOrderServiceOption(label: 'Мытьё окон', enabled: false),
      ],
    ),
    CleanerOrder(
      id: 'kids-completed',
      planName: 'Детская',
      objectType: 'Квартира',
      address: 'Садовая-Триумфальная, 4, кв. 21',
      price: 3500,
      startAt: baseDate.subtract(const Duration(days: 2)),
      cleanersLabel: '1 клинер',
      durationLabel: '2 часа',
      comment: 'Используйте гипоаллергенные средства',
      area: 50,
      status: CleanerOrderStatus.completed,
      services: const [
        CleanerOrderServiceOption(label: 'Генеральная'),
        CleanerOrderServiceOption(label: 'Мойка окон'),
      ],
    ),
    CleanerOrder(
      id: 'office-assigned',
      planName: 'Офис',
      objectType: 'Офис',
      address: 'Пресненская наб., 12, офис 801',
      price: 3500,
      startAt: baseDate.add(const Duration(days: 2)),
      cleanersLabel: '1 клинер',
      durationLabel: '2 часа',
      comment: 'Стоянка через шлагбаум, позвоните менеджеру',
      area: 110,
      status: CleanerOrderStatus.assigned,
      services: const [
        CleanerOrderServiceOption(label: 'Еженедельная'),
        CleanerOrderServiceOption(label: 'Мойка окон', enabled: false),
      ],
    ),
  ];
}
