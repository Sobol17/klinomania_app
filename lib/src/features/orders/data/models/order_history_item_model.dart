import '../../domain/entities/order_history_entry.dart';

class OrderHistoryItemModel {
  const OrderHistoryItemModel({
    required this.id,
    required this.status,
    required this.propertyType,
    required this.address,
    required this.district,
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
  });

  final String id;
  final String status;
  final String propertyType;
  final String address;
  final String? district;
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

  factory OrderHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryItemModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      propertyType: json['property_type']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      district: json['district']?.toString(),
      entrance: json['entrance']?.toString(),
      floor: json['floor']?.toString(),
      apartment: json['apartment']?.toString(),
      intercom: json['intercom']?.toString(),
      comment: json['comment']?.toString(),
      scheduledAt: _parseDate(json['scheduled_at']) ?? DateTime.now(),
      areaSqm: _parseDouble(json['area_sqm']),
      cleaningType: json['cleaning_type']?.toString() ?? '',
      windowCleaning: json['window_cleaning'] == true,
      paymentMethod: json['payment_method']?.toString() ?? '',
      totalPrice: _parseDouble(json['total_price']),
    );
  }

  OrderHistoryEntry toEntry() {
    final mappedStatus = _mapStatus(status);
    final statusLabel = _statusLabel(mappedStatus);
    final formattedAddress = _formatAddress();
    final mappedPayment = _formatPaymentMethod(paymentMethod);
    final rawServiceName = cleaningType.isNotEmpty
        ? cleaningType
        : propertyType.isNotEmpty
        ? propertyType
        : 'Уборка';
    final serviceName = _mapPlanName(rawServiceName);
    final baseCleaningLabel = cleaningType.isNotEmpty
        ? cleaningType
        : propertyType.isNotEmpty
        ? propertyType
        : '-';
    final mappedBaseLabel = _mapPlanName(baseCleaningLabel);
    final cleaningLabel = windowCleaning
        ? '$mappedBaseLabel + Мойка окон'
        : mappedBaseLabel;

    return OrderHistoryEntry(
      id: id,
      status: mappedStatus,
      serviceName: serviceName,
      cleaningType: cleaningLabel,
      address: formattedAddress,
      district: district,
      price: totalPrice,
      paymentMethod: mappedPayment,
      scheduledAt: scheduledAt,
      area: areaSqm > 0 ? areaSqm : null,
      startStatusLabel: statusLabel,
      endStatusLabel: statusLabel,
      durationLabel: statusLabel,
      cleaner: _fallbackCleaner,
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

  static OrderHistoryStatus _mapStatus(String value) {
    switch (value) {
      case 'in_progress':
      case 'inProgress':
        return OrderHistoryStatus.inProgress;
      case 'completed':
        return OrderHistoryStatus.completed;
      case 'cancelled':
      case 'canceled':
        return OrderHistoryStatus.cancelled;
      case 'new':
        return OrderHistoryStatus.awaitingCleaner;
    }
    return OrderHistoryStatus.awaitingCleaner;
  }

  static String _statusLabel(OrderHistoryStatus status) {
    switch (status) {
      case OrderHistoryStatus.inProgress:
        return 'В процессе';
      case OrderHistoryStatus.completed:
        return 'Завершено';
      case OrderHistoryStatus.cancelled:
        return 'Отменено';
      case OrderHistoryStatus.awaitingCleaner:
        return 'Ожидание клинера';
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

  static const OrderCleaner _fallbackCleaner = OrderCleaner(
    name: 'Клинер назначается',
    speciality: 'Все виды уборки',
  );

  static String _mapPlanName(String value) {
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'standard':
        return 'Стандарт';
      case 'express':
        return 'Экспресс';
      case 'premium':
        return 'Премиум';
      case 'cottage':
        return 'Коттедж';
      case 'support':
        return 'Поддержка чистоты';
      default:
        return value;
    }
  }
}
