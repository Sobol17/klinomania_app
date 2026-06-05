import '../entities/cleaner_order.dart';

abstract class CleanerOrdersRepository {
  Future<List<CleanerOrder>> fetchOrders({String? district});
  Future<void> acceptOrder(String orderId);
  Future<void> startOrder(String orderId);
  Future<void> completeOrder(String orderId);
}
