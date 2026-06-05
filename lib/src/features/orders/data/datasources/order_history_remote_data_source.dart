import '../models/order_history_item_model.dart';

class OrderHistoryRemoteDataSource {
  OrderHistoryRemoteDataSource();

  final List<OrderHistoryItemModel> _history = [
    OrderHistoryItemModel(
      id: 'order-1',
      status: 'completed',
      propertyType: 'standard',
      address: 'ул. Ленина, 10',
      district: 'Центральный',
      entrance: '1',
      floor: '4',
      apartment: '42',
      intercom: '42',
      comment: 'Позвонить за 15 минут',
      scheduledAt: DateTime(2026, 4, 8, 10),
      areaSqm: 58,
      cleaningType: 'standard',
      windowCleaning: false,
      paymentMethod: 'card',
      totalPrice: 3600,
    ),
    OrderHistoryItemModel(
      id: 'order-2',
      status: 'new',
      propertyType: 'premium',
      address: 'ул. Байкальская, 25',
      district: 'Октябрьский',
      entrance: '2',
      floor: '8',
      apartment: '81',
      intercom: null,
      comment: null,
      scheduledAt: DateTime(2026, 4, 15, 12),
      areaSqm: 72,
      cleaningType: 'premium',
      windowCleaning: true,
      paymentMethod: 'sbp',
      totalPrice: 6800,
    ),
  ];

  Future<List<OrderHistoryItemModel>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List<OrderHistoryItemModel>.unmodifiable(_history);
  }
}
