import '../../domain/entities/cleaner_order.dart';
import '../../domain/repositories/cleaner_orders_repository.dart';
import '../datasources/cleaner_orders_remote_data_source.dart';

class CleanerOrdersRepositoryImpl implements CleanerOrdersRepository {
  CleanerOrdersRepositoryImpl({required this.remoteDataSource});

  final CleanerOrdersRemoteDataSource remoteDataSource;

  @override
  Future<List<CleanerOrder>> fetchOrders() async {
    final items = await remoteDataSource.fetchOrders();
    return items.map((item) => item.toEntity()).toList();
  }

  @override
  Future<CleanerOrder> fetchOrderDetails(String publicId) async {
    final item = await remoteDataSource.fetchOrderDetails(publicId);
    return item.toEntity();
  }

  @override
  Future<void> acceptOrder(String orderId) {
    return remoteDataSource.acceptOrder(orderId);
  }

  @override
  Future<void> startOrder(String orderId) {
    return remoteDataSource.startOrder(orderId);
  }

  @override
  Future<void> completeOrder(String orderId) {
    return remoteDataSource.completeOrder(orderId);
  }
}
