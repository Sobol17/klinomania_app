import '../entities/cleaner_order.dart';

abstract class CleanerOrdersRepository {
  Future<List<CleanerOrder>> fetchOrders();
  Future<CleanerOrder> fetchOrderDetails(String publicId);
  Future<void> acceptOrder(String orderId);
  Future<void> startOrder(String orderId);
  Future<void> completeOrder(String orderId);
}
