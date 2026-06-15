import '../models/cleaner_order_item_model.dart';

class CleanerOrderHistoryRemoteDataSource {
  CleanerOrderHistoryRemoteDataSource();

  final List<CleanerOrderItemModel> _history = [
    CleanerOrderItemModel(
      id: 'cleaner-history-1',
      status: 'completed',
      propertyType: 'standard',
      address: 'ул. Декабрьских Событий, 7',
      entrance: '1',
      floor: '3',
      apartment: '15',
      intercom: null,
      comment: 'Ключ у консьержа',
      scheduledAt: DateTime(2026, 6, 12, 9),
      areaSqm: 0,
      cleaningType: 'standard',
      windowCleaning: false,
      paymentMethod: '',
      totalPrice: 8500,
      roomsDescription: '1-комнатная',
      additionalOptions: ['Холодильник внутри', 'Микроволновка внутри'],
    ),
    CleanerOrderItemModel(
      id: 'cleaner-history-2',
      status: 'completed',
      propertyType: 'premium',
      address: 'ул. Байкальская, 25',
      entrance: '2',
      floor: '8',
      apartment: '81',
      intercom: null,
      comment: 'Особое внимание ванной комнате',
      scheduledAt: DateTime(2026, 6, 10, 12),
      areaSqm: 0,
      cleaningType: 'premium',
      windowCleaning: true,
      paymentMethod: '',
      totalPrice: 23850,
      roomsDescription: '2-комнатная',
      additionalOptions: [
        'Убираем на балконе/лоджии',
        'Моем лоток и миски питомца',
      ],
    ),
  ];

  Future<List<CleanerOrderItemModel>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List<CleanerOrderItemModel>.unmodifiable(_history);
  }
}
