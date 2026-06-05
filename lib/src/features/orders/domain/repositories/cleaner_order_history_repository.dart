import '../entities/cleaner_order.dart';

abstract class CleanerOrderHistoryRepository {
  Future<List<CleanerOrder>> fetchHistory();
}
