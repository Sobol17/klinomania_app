import '../../domain/entities/order_history_entry.dart';
import '../../domain/entities/payment_operation.dart';
import '../../domain/repositories/order_history_repository.dart';
import '../datasources/order_history_remote_data_source.dart';

class OrderHistoryRepositoryImpl implements OrderHistoryRepository {
  OrderHistoryRepositoryImpl({required this.remoteDataSource});

  final OrderHistoryRemoteDataSource remoteDataSource;

  @override
  Future<List<OrderHistoryEntry>> fetchHistory() async {
    final items = await remoteDataSource.fetchHistory();
    return items.map((item) => item.toEntry()).toList();
  }

  @override
  Future<OrderHistoryEntry> fetchOrder(String orderId) async {
    final item = await remoteDataSource.fetchOrder(orderId);
    return item.toEntry();
  }

  @override
  Future<void> cancelOrder(String orderId) {
    return remoteDataSource.cancelOrder(orderId);
  }

  @override
  Future<PaymentOperation> requestPaymentLink(String orderId) {
    return remoteDataSource.requestPaymentLink(orderId);
  }
}
