import 'package:flutter/material.dart';

import '../../home/domain/entities/cleaning_service.dart';
import 'service_detail_config.dart';

class ServiceDetailPresets {
  const ServiceDetailPresets._();

  static final List<ServiceRoomOption> _defaultRooms = const [
    ServiceRoomOption(id: 'room-1', label: '1-комнатная', area: '30-50 м²'),
    ServiceRoomOption(id: 'room-2', label: '2-комнатная', area: '50-70 м²'),
    ServiceRoomOption(id: 'room-3', label: '3-комнатная', area: '70-100 м²'),
    ServiceRoomOption(id: 'room-4', label: '4-комнатная', area: 'от 100 м²'),
  ];

  static ServiceDetailConfig resolve(CleaningService service) {
    switch (service.id) {
      case 'premium':
        return ServiceDetailConfig(
          layout: ServiceDetailLayout.apartment,
          description:
              'Если у вас мало времени на уборку и нет серьезных загрязнений, то экспресс уборка для вас.',
          darkCard: false,
          heroGradient: const [Color(0xFFB8DDFF), Color(0xFFFFFFFF)],
          heroIcon: Icons.king_bed_outlined,
          roomOptions: _defaultRooms,
        );
      case 'standard':
        return ServiceDetailConfig(
          layout: ServiceDetailLayout.apartment,
          description:
              'Если у вас мало времени на уборку и нет серьезных загрязнений, то экспресс уборка для вас.',
          darkCard: false,
          heroGradient: const [Color(0xFFB8DDFF), Colors.white],
          heroIcon: Icons.weekend_outlined,
          roomOptions: _defaultRooms,
        );
      case 'express':
        return ServiceDetailConfig(
          layout: ServiceDetailLayout.apartment,
          description:
              'Быстрая уборка основных зон и поддержание чистоты на каждый день.',
          darkCard: false,
          heroGradient: const [Color(0xFFB8DDFF), Color(0xFFFFFFFF)],
          heroIcon: Icons.flash_on_outlined,
          roomOptions: _defaultRooms,
        );
      case 'office':
        return ServiceDetailConfig(
          layout: ServiceDetailLayout.apartment,
          description:
              'Поддержим порядок в офисе: чистим рабочие зоны, санузлы и переговорные.',
          darkCard: false,
          heroGradient: const [Color(0xFFB8DDFF), Color(0xFFFFFFFF)],
          heroIcon: Icons.apartment,
          roomOptions: _defaultRooms,
        );
      case 'kids':
        return ServiceDetailConfig(
          layout: ServiceDetailLayout.apartment,
          description:
              'Особое внимание к детским комнатам, игрушкам и деликатным поверхностям.',
          darkCard: false,
          heroGradient: const [Color(0xFFB8DDFF), Color(0xFFFFFFFF)],
          heroIcon: Icons.toys_outlined,
          roomOptions: _defaultRooms,
        );
      case 'cottage':
        return ServiceDetailConfig(
          layout: ServiceDetailLayout.house,
          description:
              'Наведём чистоту и порядок в вашем доме. Проводим поддерживающую уборку, генеральную и после ремонта.',
          darkCard: false,
          heroGradient: const [Color(0xFFB8DDFF), Color(0xFFFFFFFF)],
          heroIcon: Icons.house_outlined,
          cleaningOptions: const [
            ServiceCleaningOption(id: 'support', label: 'Поддерживающая'),
            ServiceCleaningOption(id: 'general', label: 'Генеральная'),
            ServiceCleaningOption(id: 'repair', label: 'После ремонта'),
            ServiceCleaningOption(
              id: 'windows',
              label: '+ Мойка окон',
              subtitle: 'Дополнительная опция',
              isAddon: true,
            ),
          ],
          initialArea: 120,
          minArea: 60,
          maxArea: 600,
          areaStep: 20,
        );
      default:
        return ServiceDetailConfig(
          layout: ServiceDetailLayout.apartment,
          description:
              service.subtitle ??
              'Мы бережно наведём чистоту и порядок в любом помещении.',
          heroGradient: const [Color(0xFFB8DDFF), Colors.white],
          heroIcon: Icons.cleaning_services,
          roomOptions: _defaultRooms,
        );
    }
  }
}
