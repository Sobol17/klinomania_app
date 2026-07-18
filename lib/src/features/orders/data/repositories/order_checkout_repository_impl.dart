import '../../domain/repositories/order_checkout_repository.dart';
import '../datasources/order_checkout_remote_data_source.dart';

class OrderCheckoutRepositoryImpl implements OrderCheckoutRepository {
  OrderCheckoutRepositoryImpl({required this.remoteDataSource});

  final OrderCheckoutRemoteDataSource remoteDataSource;

  @override
  Future<void> createOrder({
    required String serviceId,
    required String? roomOptionId,
    required String? cleaningOptionId,
    required Set<String> extraOptionIds,
    required String idempotencyKey,
    required Map<String, dynamic> address,
    required String? comment,
    required DateTime scheduledAt,
  }) => remoteDataSource.createOrder(
    idempotencyKey: idempotencyKey,
    payload: {
      'service_id': serviceId,
      if (roomOptionId != null) 'room_option_id': roomOptionId,
      if (cleaningOptionId != null) 'cleaning_option_id': cleaningOptionId,
      'extra_option_ids': extraOptionIds.toList(growable: false),
      'address': address,
      if (comment != null) 'comment': comment,
      'scheduled_at': scheduledAt.toIso8601String(),
      'payment_method': null,
    },
  );
}
