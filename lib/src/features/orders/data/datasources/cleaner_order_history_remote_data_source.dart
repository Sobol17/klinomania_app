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
      scheduledAt: DateTime(2026, 3, 20, 9),
      areaSqm: 48,
      cleaningType: 'standard',
      windowCleaning: false,
      paymentMethod: 'card',
      totalPrice: 3200,
    ),
  ];

  Future<List<CleanerOrderItemModel>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List<CleanerOrderItemModel>.unmodifiable(_history);
  }
}
