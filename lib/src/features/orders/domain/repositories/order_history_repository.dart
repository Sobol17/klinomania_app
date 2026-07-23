import '../entities/order_history_entry.dart';
import '../entities/payment_operation.dart';

abstract class OrderHistoryRepository {
  Future<List<OrderHistoryEntry>> fetchHistory();
  Future<OrderHistoryEntry> fetchOrder(String orderId);
  Future<void> cancelOrder(String orderId);
  Future<PaymentOperation> requestPaymentLink(String orderId);
}
