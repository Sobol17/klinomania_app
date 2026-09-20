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
    this.roomsDescription,
    this.mainCleaningOption,
    this.additionalOptions = const [],
    this.checklistSections = const [],
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
  final String? roomsDescription;
  final String? mainCleaningOption;
  final List<String> additionalOptions;
  final List<CleanerOrderChecklistSection> checklistSections;

  factory CleanerOrderItemModel.fromJson(Map<String, dynamic> json) {
    final address = _map(json['address']);
    final service = _map(json['service']);
    final lineItems = _mapList(json['line_items']);
    final directRoomOption = _map(json['room_option']);
    final roomOption = directRoomOption.isNotEmpty
        ? directRoomOption
        : _lineItem(lineItems, 'room_option');
    final directCleaningOption = _map(json['cleaning_option']);
    final cleaningOption = directCleaningOption.isNotEmpty
        ? directCleaningOption
        : _lineItem(lineItems, 'cleaning_option');
    final mainCleaningOption = _stringOrNull(cleaningOption['title']);
    final directAdditionalOptions = _stringList(
      json['additional_options'] ??
          json['additionalOptions'] ??
          json['extra_options'],
    );
    return CleanerOrderItemModel(
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
          mainCleaningOption ??
          service['title']?.toString() ??
          '',
      windowCleaning: _parseBool(json['window_cleaning']),
      paymentMethod: json['payment_method']?.toString() ?? '',
      totalPrice: _parseDouble(json['total_price']),
      roomsDescription: _stringOrNull(
        json['rooms_description'] ??
            json['roomsDescription'] ??
            roomOption['title'],
      ),
      mainCleaningOption: mainCleaningOption,
      additionalOptions: directAdditionalOptions.isNotEmpty
          ? directAdditionalOptions
          : _lineItemTitles(lineItems, 'extra_option'),
      checklistSections: _parseChecklist(
        checklist: json['checklist'],
        sections: json['checklist_sections'],
      ),
    );
  }

  CleanerOrder toEntity() {
    final statusValue = _mapStatus(status);
    final rawPlanName = propertyType.isNotEmpty
        ? propertyType
        : cleaningType.isNotEmpty
        ? cleaningType
        : 'Уборка';
    final planName = _mapPlanName(rawPlanName);
    final objectType = roomsDescription ?? 'Квартира';
    final services = _buildServices(
      windowCleaning: windowCleaning,
      additionalOptions: additionalOptions,
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
      mainCleaningOption: mainCleaningOption,
      checklistSections: checklistSections,
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
    required bool windowCleaning,
    required List<String> additionalOptions,
  }) {
    final services = <CleanerOrderServiceOption>[];
    services.addAll(
      additionalOptions.map(
        (option) => CleanerOrderServiceOption(label: option),
      ),
    );
    if (windowCleaning) {
      services.add(const CleanerOrderServiceOption(label: 'Моем окна'));
    }
    return services;
  }

  static List<CleanerOrderChecklistSection> _parseChecklist({
    required dynamic checklist,
    required dynamic sections,
  }) {
    if (checklist is! List) return const [];
    final items = checklist
        .whereType<Map>()
        .map(
          (item) => CleanerOrderChecklistItem(
            id: _stringOrNull(item['id']) ?? '',
            kind: _stringOrNull(item['kind']) ?? 'base_service',
            zone: _stringOrNull(item['zone']) ?? 'everywhere',
            label:
                _stringOrNull(item['text'] ?? item['title'] ?? item['label']) ??
                '',
            completed: _parseBool(item['completed']),
          ),
        )
        .where((item) => item.id.isNotEmpty && item.label.isNotEmpty)
        .toList(growable: false);
    if (items.isEmpty) return const [];

    final sectionMaps = sections is List
        ? sections.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : const <Map<String, dynamic>>[];
    if (sectionMaps.isEmpty) {
      return [
        CleanerOrderChecklistSection(
          zone: 'everywhere',
          title: 'Везде',
          items: items,
        ),
      ];
    }

    return sectionMaps
        .map((section) {
          final zone =
              _stringOrNull(
                section['zone'] ?? section['id'] ?? section['key'],
              ) ??
              '';
          return CleanerOrderChecklistSection(
            zone: zone,
            title:
                _stringOrNull(
                  section['title'] ?? section['name'] ?? section['label'],
                ) ??
                zone,
            items: items
                .where((item) => item.zone == zone)
                .toList(growable: false),
          );
        })
        .where((section) => section.zone.isNotEmpty && section.items.isNotEmpty)
        .toList(growable: false);
  }

  static CleanerOrderStatus _mapStatus(String value) {
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'completed':
        return CleanerOrderStatus.completed;
      case 'assigned':
      case 'team_formed':
      case 'in_progress':
      case 'inprogress':
      case 'accepted':
        return CleanerOrderStatus.assigned;
      case 'awaiting_payment':
        return CleanerOrderStatus.awaitingPayment;
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

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .toList(growable: false);
  }

  static Map<String, dynamic> _lineItem(
    List<Map<String, dynamic>> items,
    String kind,
  ) {
    for (final item in items) {
      if (item['kind'] == kind) return item;
    }
    return const {};
  }

  static List<String> _lineItemTitles(
    List<Map<String, dynamic>> items,
    String kind,
  ) {
    return items
        .where((item) => item['kind'] == kind)
        .map((item) => _stringOrNull(item['title']))
        .whereType<String>()
        .toList(growable: false);
  }

  static String _mapPlanName(String value) {
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'standard':
      case 'express':
      case 'support':
        return 'Базовый минимум';
      case 'premium':
        return 'Генеральская';
      case 'cottage':
        return 'Роскошный максимум';
      default:
        return value;
    }
  }
}
