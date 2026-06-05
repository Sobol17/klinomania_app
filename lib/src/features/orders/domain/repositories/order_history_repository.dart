import '../entities/order_history_entry.dart';

abstract class OrderHistoryRepository {
  Future<List<OrderHistoryEntry>> fetchHistory();
}
