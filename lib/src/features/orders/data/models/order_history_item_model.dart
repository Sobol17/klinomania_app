import '../../domain/entities/order_history_entry.dart';

class OrderHistoryItemModel {
  const OrderHistoryItemModel({
    required this.id,
    required this.status,
    required this.propertyType,
    required this.address,
    required this.entrance,
    required this.floor,
    required this.apartment,
    required this.intercom,
    required this.comment,
    required this.scheduledAt,
    required this.areaSqm,
    required this.cleaningType,
    required this.windowCleaning,
    required this.paymentMethod,
    required this.totalPrice,
    required this.cleaner,
    this.roomsDescription,
    this.additionalOptions = const [],
  });

  final String id;
  final String status;
  final String propertyType;
  final String address;
  final String? entrance;
  final String? floor;
  final String? apartment;
  final String? intercom;
  final String? comment;
  final DateTime scheduledAt;
  final double areaSqm;
  final String cleaningType;
  final bool windowCleaning;
  final String paymentMethod;
  final double totalPrice;
  final OrderCleaner cleaner;
  final String? roomsDescription;
  final List<String> additionalOptions;

  factory OrderHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final address = _map(json['address']);
    final service = _map(json['service']);
    final roomOption = _map(json['room_option']);
    final cleaningOption = _map(json['cleaning_option']);
    return OrderHistoryItemModel(
      id: json['public_id']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      propertyType:
          json['property_type']?.toString() ?? service['id']?.toString() ?? '',
      address:
          address['full_address']?.toString() ??
          json['address']?.toString() ??
          '',
      entrance: address['entrance']?.toString() ?? json['entrance']?.toString(),
      floor: address['floor']?.toString() ?? json['floor']?.toString(),
      apartment:
          address['apartment']?.toString() ?? json['apartment']?.toString(),
      intercom: address['intercom']?.toString() ?? json['intercom']?.toString(),
      comment: address['comment']?.toString() ?? json['comment']?.toString(),
      scheduledAt: _parseDate(json['scheduled_at']) ?? DateTime.now(),
      areaSqm: _parseDouble(json['area_sqm']),
      cleaningType:
          json['cleaning_type']?.toString() ??
          cleaningOption['title']?.toString() ??
          service['title']?.toString() ??
          '',
      windowCleaning: json['window_cleaning'] == true,
      paymentMethod: json['payment_method']?.toString() ?? '',
      totalPrice: _parseDouble(json['total_price']),
      cleaner: _parseCleaner(json['cleaners']),
      roomsDescription: _stringOrNull(
        json['rooms_description'] ??
            json['roomsDescription'] ??
            roomOption['title'],
      ),
      additionalOptions: _stringList(
        json['additional_options'] ??
            json['additionalOptions'] ??
            json['extra_options'],
      ),
    );
  }

  OrderHistoryEntry toEntry() {
    final mappedStatus = _mapStatus(status);
    final statusLabel = _statusLabel(mappedStatus);
    final formattedAddress = _formatAddress();
    final mappedPayment = _formatPaymentMethod(paymentMethod);
    final rawServiceName = propertyType.isNotEmpty
        ? propertyType
        : cleaningType.isNotEmpty
        ? cleaningType
        : 'Уборка';
    final serviceName = _mapPlanName(rawServiceName);
    final baseCleaningLabel = cleaningType.isNotEmpty
        ? cleaningType
        : propertyType.isNotEmpty
        ? propertyType
        : '-';
    final mappedBaseLabel = _mapCleaningTypeLabel(baseCleaningLabel);
    final cleaningLabel = windowCleaning
        ? '$mappedBaseLabel + Мойка окон'
        : mappedBaseLabel;

    return OrderHistoryEntry(
      id: id,
      status: mappedStatus,
      serviceName: serviceName,
      cleaningType: cleaningLabel,
      address: formattedAddress,
      price: totalPrice,
      paymentMethod: mappedPayment,
      scheduledAt: scheduledAt,
      area: areaSqm > 0 ? areaSqm : null,
      roomsDescription: roomsDescription,
      additionalOptions: additionalOptions,
      startStatusLabel: statusLabel,
      endStatusLabel: statusLabel,
      durationLabel: statusLabel,
      cleaner: cleaner,
    );
  }

  String _formatAddress() {
    final parts = <String>[];
    if (address.isNotEmpty) {
      parts.add(address);
    }
    if (entrance != null && entrance!.isNotEmpty) {
      parts.add('подъезд ${entrance!}');
    }
    if (floor != null && floor!.isNotEmpty) {
      parts.add('этаж ${floor!}');
    }
    if (apartment != null && apartment!.isNotEmpty) {
      parts.add('кв. ${apartment!}');
    }
    return parts.isEmpty ? '-' : parts.join(', ');
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static List<String> _stringList(dynamic value) {
    if (value is Iterable) {
      return value
          .map((item) {
            if (item is Map) {
              return item['title']?.toString().trim() ?? '';
            }
            return item.toString().trim();
          })
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const {};
  }

  static OrderCleaner _parseCleaner(dynamic value) {
    if (value is! Iterable || value.isEmpty) {
      return _unassignedCleaner;
    }

    final cleaner = _map(value.first);
    final profile = _map(cleaner['cleaner_profile']);
    final name = profile['name']?.toString().trim();
    final fallbackName = cleaner['name']?.toString().trim();
    final phone = cleaner['phone']?.toString().trim();
    final email = cleaner['email']?.toString().trim();
    final contact = phone?.isNotEmpty == true
        ? 'Телефон: $phone'
        : email?.isNotEmpty == true
        ? 'Email: $email'
        : 'Клинер';

    return OrderCleaner(
      name: name?.isNotEmpty == true
          ? name!
          : fallbackName?.isNotEmpty == true
          ? fallbackName!
          : 'Клинер',
      speciality: contact,
    );
  }

  static OrderHistoryStatus _mapStatus(String value) {
    switch (value.toLowerCase()) {
      case 'processing':
        return OrderHistoryStatus.processing;
      case 'confirmed':
        return OrderHistoryStatus.confirmed;
      case 'team_formed':
        return OrderHistoryStatus.teamFormed;
      case 'in_progress':
        return OrderHistoryStatus.inProgress;
      case 'awaiting_payment':
        return OrderHistoryStatus.awaitingPayment;
      case 'completed':
        return OrderHistoryStatus.completed;
      case 'cancelled':
      case 'canceled':
        return OrderHistoryStatus.cancelled;
      case 'new':
        return OrderHistoryStatus.processing;
    }
    return OrderHistoryStatus.processing;
  }

  static String _statusLabel(OrderHistoryStatus status) {
    switch (status) {
      case OrderHistoryStatus.processing:
        return 'В обработке';
      case OrderHistoryStatus.confirmed:
        return 'Подтверждена';
      case OrderHistoryStatus.teamFormed:
        return 'Команда сформирована';
      case OrderHistoryStatus.inProgress:
        return 'В работе';
      case OrderHistoryStatus.awaitingPayment:
        return 'Ожидает оплаты';
      case OrderHistoryStatus.completed:
        return 'Выполнена';
      case OrderHistoryStatus.cancelled:
        return 'Отменена';
    }
  }

  static String _formatPaymentMethod(String value) {
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'sbp':
        return 'СБП';
      case 'podeli':
        return 'ПОДЕЛИ';
      case 'plati':
        return 'плати';
      case 'cash':
        return 'Нал';
      case 'card':
        return 'Карта';
      default:
        return value.isNotEmpty ? value : '-';
    }
  }

  static const OrderCleaner _unassignedCleaner = OrderCleaner(
    name: 'Клинер назначается',
    speciality: 'Все виды уборки',
  );

  static String _mapPlanName(String value) {
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'standard':
        return 'Базовый минимум';
      case 'express':
        return 'Базовый минимум';
      case 'premium':
        return 'Генеральская';
      case 'cottage':
        return 'Роскошный максимум';
      case 'support':
        return 'Базовый минимум';
      default:
        return value;
    }
  }

  static String _mapCleaningTypeLabel(String value) {
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'standard':
      case 'express':
      case 'support':
        return 'Расширенная поддерживающая уборка';
      case 'premium':
        return 'Глубокая уборка с проработкой деталей';
      case 'cottage':
        return 'Премиальный клининг «всё включено»';
      default:
        return value;
    }
  }
}
