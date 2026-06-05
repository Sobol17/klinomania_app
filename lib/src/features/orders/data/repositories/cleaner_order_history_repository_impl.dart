import '../../domain/entities/cleaner_order.dart';
import '../../domain/repositories/cleaner_order_history_repository.dart';
import '../datasources/cleaner_order_history_remote_data_source.dart';

class CleanerOrderHistoryRepositoryImpl
    implements CleanerOrderHistoryRepository {
  CleanerOrderHistoryRepositoryImpl({required this.remoteDataSource});

  final CleanerOrderHistoryRemoteDataSource remoteDataSource;

  @override
  Future<List<CleanerOrder>> fetchHistory() async {
    final items = await remoteDataSource.fetchHistory();
    return items.map((item) => item.toEntity()).toList();
  }
}
