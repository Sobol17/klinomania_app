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
      planName: 'Роскошный максимум',
      objectType: '4-комнатная',
      address: 'Кутузовский проспект, 23к2, подъезд 1, кв. 44',
      price: 25000,
      startAt: baseDate,
      cleanersLabel: '1-3 клинера',
      durationLabel: '5-6 часов',
      comment: 'Позвоните за 25 минут до прибытия',
      area: 0,
      status: CleanerOrderStatus.available,
      highlightCard: true,
      services: const [
        CleanerOrderServiceOption(label: 'Премиальный клининг «всё включено»'),
      ],
    ),
    CleanerOrder(
      id: 'express-assigned',
      planName: 'Базовый минимум',
      objectType: '1-комнатная',
      address: 'Кутузовский проспект, 23к2, подъезд 1, кв. 44',
      price: 8500,
      startAt: baseDate.add(const Duration(hours: 2)),
      cleanersLabel: '1 клинер',
      durationLabel: '3 часа',
      comment: 'Код на домофоне #4444',
      area: 0,
      status: CleanerOrderStatus.assigned,
      services: const [
        CleanerOrderServiceOption(label: 'Расширенная поддерживающая уборка'),
        CleanerOrderServiceOption(label: 'Холодильник внутри'),
        CleanerOrderServiceOption(label: 'Микроволновка внутри'),
      ],
    ),
    CleanerOrder(
      id: 'standard-assigned',
      planName: 'Генеральская',
      objectType: '2-комнатная',
      address: 'Кутузовский проспект, 23к2, подъезд 1, кв. 44',
      price: 23850,
      startAt: baseDate.add(const Duration(days: 1)),
      cleanersLabel: '1-2 клинера',
      durationLabel: '4-5 часов',
      comment: 'Оцените кухню особое внимание',
      area: 0,
      status: CleanerOrderStatus.assigned,
      services: const [
        CleanerOrderServiceOption(
          label: 'Глубокая уборка с проработкой деталей',
        ),
        CleanerOrderServiceOption(label: 'Убираем на балконе/лоджии'),
        CleanerOrderServiceOption(label: 'Моем окна'),
      ],
    ),
    CleanerOrder(
      id: 'office-completed',
      planName: 'Базовый минимум',
      objectType: '3-комнатная',
      address: 'Пресненская наб., 10, офис 1201',
      price: 8900,
      startAt: baseDate.subtract(const Duration(days: 1)),
      cleanersLabel: '1 клинер',
      durationLabel: '3 часа',
      comment: 'Пропуск у охраны, спросите менеджера',
      area: 0,
      status: CleanerOrderStatus.completed,
      services: const [
        CleanerOrderServiceOption(label: 'Расширенная поддерживающая уборка'),
        CleanerOrderServiceOption(label: 'Духовка внутри'),
        CleanerOrderServiceOption(label: 'Стремянка'),
      ],
    ),
    CleanerOrder(
      id: 'kids-completed',
      planName: 'Генеральская',
      objectType: '4-комнатная',
      address: 'Садовая-Триумфальная, 4, кв. 21',
      price: 28000,
      startAt: baseDate.subtract(const Duration(days: 2)),
      cleanersLabel: '1 клинер',
      durationLabel: '5 ч 20 мин',
      comment: 'Используйте гипоаллергенные средства',
      area: 0,
      status: CleanerOrderStatus.completed,
      services: const [
        CleanerOrderServiceOption(
          label: 'Глубокая уборка с проработкой деталей',
        ),
        CleanerOrderServiceOption(
          label: 'Моем сложные и хрустальные люстры и светильники',
        ),
        CleanerOrderServiceOption(label: 'Гладим вещи'),
      ],
    ),
    CleanerOrder(
      id: 'office-assigned',
      planName: 'Базовый минимум',
      objectType: '2-комнатная',
      address: 'Пресненская наб., 12, офис 801',
      price: 13450,
      startAt: baseDate.add(const Duration(days: 2)),
      cleanersLabel: '1 клинер',
      durationLabel: '3 часа',
      comment: 'Стоянка через шлагбаум, позвоните менеджеру',
      area: 0,
      status: CleanerOrderStatus.assigned,
      services: const [
        CleanerOrderServiceOption(label: 'Расширенная поддерживающая уборка'),
        CleanerOrderServiceOption(
          label: 'Шкафы и ящики кухонного гарнитура внутри',
        ),
        CleanerOrderServiceOption(label: 'Моем окна'),
      ],
    ),
  ];
}
