import '../models/cleaner_order_item_model.dart';

class CleanerOrdersRemoteDataSource {
  CleanerOrdersRemoteDataSource();

  final List<CleanerOrderItemModel> _orders = [
    CleanerOrderItemModel(
      id: 'cleaner-order-1',
      status: 'new',
      propertyType: 'standard',
      address: 'ул. Карла Маркса, 12',
      entrance: '1',
      floor: '5',
      apartment: '34',
      intercom: '34',
      comment: 'Есть домашние растения на подоконниках',
      scheduledAt: DateTime(2026, 4, 18, 11),
      areaSqm: 54,
      cleaningType: 'standard',
      windowCleaning: true,
      paymentMethod: 'card',
      totalPrice: 4200,
    ),
    CleanerOrderItemModel(
      id: 'cleaner-order-2',
      status: 'assigned',
      propertyType: 'premium',
      address: 'ул. Советская, 18',
      entrance: '3',
      floor: '2',
      apartment: '9',
      intercom: null,
      comment: 'Нужна уборка кухни после ремонта',
      scheduledAt: DateTime(2026, 4, 19, 14),
      areaSqm: 66,
      cleaningType: 'premium',
      windowCleaning: false,
      paymentMethod: 'sbp',
      totalPrice: 6100,
    ),
  ];

  Future<void> acceptOrder(String orderId) async {
    await _mockDelay();
  }

  Future<void> startOrder(String orderId) async {
    await _mockDelay();
  }

  Future<void> completeOrder(String orderId) async {
    await _mockDelay();
  }

  Future<List<CleanerOrderItemModel>> fetchOrders() async {
    await _mockDelay();
    return List<CleanerOrderItemModel>.unmodifiable(_orders);
  }

  Future<void> _mockDelay() {
    return Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
