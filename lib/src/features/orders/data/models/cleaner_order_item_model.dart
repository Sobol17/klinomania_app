import '../../domain/entities/cleaner_order.dart';

class CleanerOrderItemModel {
  const CleanerOrderItemModel({
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

  factory CleanerOrderItemModel.fromJson(Map<String, dynamic> json) {
    return CleanerOrderItemModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      propertyType: json['property_type']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      entrance: json['entrance']?.toString(),
      floor: json['floor']?.toString(),
      apartment: json['apartment']?.toString(),
      intercom: json['intercom']?.toString(),
      comment: json['comment']?.toString(),
      scheduledAt: _parseDate(json['scheduled_at']) ?? DateTime.now(),
      areaSqm: _parseDouble(json['area_sqm']),
      cleaningType: json['cleaning_type']?.toString() ?? '',
      windowCleaning: _parseBool(json['window_cleaning']),
      paymentMethod: json['payment_method']?.toString() ?? '',
      totalPrice: _parseDouble(json['total_price']),
    );
  }

  CleanerOrder toEntity() {
    final statusValue = _mapStatus(status);
    final rawPlanName = cleaningType.isNotEmpty
        ? cleaningType
        : propertyType.isNotEmpty
        ? propertyType
        : 'Уборка';
    final planName = _mapPlanName(rawPlanName);
    final rawObjectType = propertyType.isNotEmpty
        ? propertyType
        : cleaningType.isNotEmpty
        ? cleaningType
        : 'Уборка';
    final objectType = _mapPlanName(rawObjectType);
    final services = _buildServices(
      baseLabel: planName,
      windowCleaning: windowCleaning,
    );

    return CleanerOrder(
      id: id,
      planName: planName,
      objectType: objectType,
      address: _formatAddress(),
      price: totalPrice,
      startAt: scheduledAt,
      cleanersLabel: '1 клинер',
      durationLabel: 'Уточняется',
      comment: _formatComment(),
      area: areaSqm,
      status: statusValue,
      services: services,
      highlightCard: statusValue == CleanerOrderStatus.available,
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

  String _formatComment() {
    final parts = <String>[];
    if (comment != null && comment!.isNotEmpty) {
      parts.add(comment!);
    }
    if (intercom != null && intercom!.isNotEmpty) {
      parts.add('Домофон: ${intercom!}');
    }
    return parts.isEmpty ? '-' : parts.join(' • ');
  }

  static List<CleanerOrderServiceOption> _buildServices({
    required String baseLabel,
    required bool windowCleaning,
  }) {
    return [
      CleanerOrderServiceOption(label: baseLabel),
      CleanerOrderServiceOption(label: 'Мойка окон', enabled: windowCleaning),
    ];
  }

  static CleanerOrderStatus _mapStatus(String value) {
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'completed':
        return CleanerOrderStatus.completed;
      case 'assigned':
      case 'in_progress':
      case 'inprogress':
      case 'accepted':
        return CleanerOrderStatus.assigned;
      case 'cancelled':
      case 'canceled':
        return CleanerOrderStatus.completed;
      case 'new':
      default:
        return CleanerOrderStatus.available;
    }
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

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }

  static String _mapPlanName(String value) {
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'standard':
        return 'Стандарт';
      case 'express':
        return 'Экспресс';
      case 'premium':
        return 'Премиум';
      default:
        return value;
    }
  }
}
