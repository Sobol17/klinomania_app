import '../../domain/entities/order_history_entry.dart';
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
}
