import 'package:flutter/material.dart';

import '../../home/domain/entities/cleaning_service.dart';
import 'service_detail_config.dart';

class ServiceDetailPresets {
  const ServiceDetailPresets._();

  static final List<ServiceRoomOption> _defaultRooms = const [
    ServiceRoomOption(
      id: 'room-1',
      label: '1-комнатная',
      area: '30-50 м²',
      priceModifier: 0,
    ),
    ServiceRoomOption(
      id: 'room-2',
      label: '2-комнатная',
      area: '50-70 м²',
      priceModifier: 600,
    ),
    ServiceRoomOption(
      id: 'room-3',
      label: '3-комнатная',
      area: '70-100 м²',
      priceModifier: 1200,
    ),
    ServiceRoomOption(
      id: 'room-4',
      label: '4-комнатная',
      area: 'от 100 м²',
      priceModifier: 1800,
    ),
  ];

  static final List<ServiceCleaningOption> _basicMinimumAddOns = const [
    ServiceCleaningOption(
      id: 'fridge-inside',
      label: 'Холодильник внутри (освобожденный и размороженный)',
      isAddon: true,
      priceModifier: 800,
    ),
    ServiceCleaningOption(
      id: 'microwave-inside',
      label: 'Микроволновка внутри',
      isAddon: true,
      priceModifier: 700,
    ),
    ServiceCleaningOption(
      id: 'hood-grates',
      label: 'Кухонная вытяжка с решетками',
      isAddon: true,
      priceModifier: 800,
    ),
    ServiceCleaningOption(
      id: 'oven-inside',
      label: 'Духовка внутри',
      isAddon: true,
      priceModifier: 800,
    ),
    ServiceCleaningOption(
      id: 'pet-tray-bowls',
      label: 'Моем лоток и миски питомца',
      isAddon: true,
      priceModifier: 700,
    ),
    ServiceCleaningOption(
      id: 'kitchen-cabinets-inside',
      label:
          'Шкафы и ящики кухонного гарнитура внутри при условии, что они пустые',
      isAddon: true,
      priceModifier: 1500,
    ),
    ServiceCleaningOption(
      id: 'washer-dryer-inside',
      label: 'Стиральную/сушильную машину внутри',
      isAddon: true,
      priceModifier: 300,
    ),
    ServiceCleaningOption(
      id: 'bathroom-tile-deep',
      label:
          'Очистить кафельную плитку, межплиточные швы и вытяжку от сильных загрязнений по всей высоте (в санузле)',
      isAddon: true,
      priceModifier: 1500,
    ),
    ServiceCleaningOption(
      id: 'sanitary-deep',
      label:
          'Очистить сантехнику, смесители от сильных загрязнений: ржавчина, водный камень, известковый налет (1 час)',
      isAddon: true,
      priceModifier: 1200,
    ),
    ServiceCleaningOption(
      id: 'ironing-hour',
      label: 'Глажка (1 час)',
      isAddon: true,
      priceModifier: 1200,
    ),
    ServiceCleaningOption(
      id: 'steam-generator',
      label: 'Уборка парогенератором',
      isAddon: true,
      priceModifier: 1500,
    ),
    ServiceCleaningOption(
      id: 'ladder',
      label: 'Стремянка',
      isAddon: true,
      priceModifier: 1500,
    ),
    ServiceCleaningOption(
      id: 'windows-room-1',
      label: 'Помыть окна',
      isAddon: true,
      priceModifier: 3500,
    ),
    ServiceCleaningOption(
      id: 'windows-room-2',
      label: 'Помыть окна',
      isAddon: true,
      priceModifier: 5250,
    ),
    ServiceCleaningOption(
      id: 'windows-room-3',
      label: 'Помыть окна',
      isAddon: true,
      priceModifier: 7700,
    ),
    ServiceCleaningOption(
      id: 'windows-room-4',
      label: 'Помыть окна',
      isAddon: true,
      priceModifier: 8750,
    ),
  ];

  static final List<ServiceCleaningOption> _generalAddOns = const [
    ServiceCleaningOption(
      id: 'chandelier-cleaning',
      label: 'Моем сложные и хрустальные люстры и светильники',
      isAddon: true,
      priceModifier: 1000,
    ),
    ServiceCleaningOption(
      id: 'balcony-loggia',
      label: 'Убираем на балконе/лоджии (включая окна)',
      isAddon: true,
      priceModifier: 4000,
    ),
    ServiceCleaningOption(
      id: 'pet-tray-bowls',
      label: 'Моем лоток и миски питомца',
      isAddon: true,
      priceModifier: 700,
    ),
    ServiceCleaningOption(
      id: 'bedding-wash-hang',
      label: 'Стираем и развешиваем постельное белье (до 2 загрузок)',
      isAddon: true,
      priceModifier: 700,
    ),
    ServiceCleaningOption(
      id: 'ironing-hour',
      label: 'Гладим вещи (до 60 минут)',
      isAddon: true,
      priceModifier: 1200,
    ),
    ServiceCleaningOption(
      id: 'special-errands',
      label:
          'Выполним особые поручения (до 30 минут): отнести вещи в химчистку, покормить питомца и т.д.',
      isAddon: true,
      priceModifier: 1200,
    ),
    ServiceCleaningOption(
      id: 'windows-room-1',
      label: 'Помыть окна',
      isAddon: true,
      priceModifier: 3500,
    ),
    ServiceCleaningOption(
      id: 'windows-room-2',
      label: 'Помыть окна',
      isAddon: true,
      priceModifier: 5250,
    ),
    ServiceCleaningOption(
      id: 'windows-room-3',
      label: 'Помыть окна',
      isAddon: true,
      priceModifier: 7700,
    ),
    ServiceCleaningOption(
      id: 'windows-room-4',
      label: 'Помыть окна',
      isAddon: true,
      priceModifier: 8750,
    ),
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
          cleaningOptions: _generalAddOns,
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
          cleaningOptions: _basicMinimumAddOns,
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
          cleaningOptions: _basicMinimumAddOns,
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
          cleaningOptions: _basicMinimumAddOns,
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
          cleaningOptions: _basicMinimumAddOns,
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
          cleaningOptions: _basicMinimumAddOns,
        );
    }
  }
}
