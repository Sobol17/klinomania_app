import '../models/order_history_item_model.dart';

class OrderHistoryRemoteDataSource {
  OrderHistoryRemoteDataSource();

  final List<OrderHistoryItemModel> _history = [
    OrderHistoryItemModel(
      id: 'order-1',
      status: 'completed',
      propertyType: 'standard',
      address: 'ул. Ленина, 10',
      entrance: '1',
      floor: '4',
      apartment: '42',
      intercom: '42',
      comment: 'Позвонить за 15 минут',
      scheduledAt: DateTime(2026, 6, 12, 10),
      areaSqm: 0,
      cleaningType: 'standard',
      windowCleaning: false,
      paymentMethod: '',
      totalPrice: 8500,
      roomsDescription: '1-комнатная',
      additionalOptions: ['Холодильник внутри', 'Микроволновка внутри'],
    ),
    OrderHistoryItemModel(
      id: 'order-2',
      status: 'new',
      propertyType: 'premium',
      address: 'ул. Байкальская, 25',
      entrance: '2',
      floor: '8',
      apartment: '81',
      intercom: null,
      comment: null,
      scheduledAt: DateTime(2026, 6, 15, 12),
      areaSqm: 0,
      cleaningType: 'premium',
      windowCleaning: true,
      paymentMethod: '',
      totalPrice: 23850,
      roomsDescription: '2-комнатная',
      additionalOptions: ['Убираем на балконе/лоджии', 'Моем окна'],
    ),
    OrderHistoryItemModel(
      id: 'order-3',
      status: 'completed',
      propertyType: 'cottage',
      address: 'ул. Советская, 18',
      entrance: null,
      floor: null,
      apartment: '12',
      intercom: null,
      comment: null,
      scheduledAt: DateTime(2026, 6, 10, 9),
      areaSqm: 0,
      cleaningType: 'cottage',
      windowCleaning: false,
      paymentMethod: '',
      totalPrice: 25000,
      additionalOptions: const [],
    ),
  ];

  Future<List<OrderHistoryItemModel>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List<OrderHistoryItemModel>.unmodifiable(_history);
  }
}
