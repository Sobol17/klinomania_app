import '../../domain/entities/service_quote.dart';
import '../../domain/repositories/order_checkout_repository.dart';
import '../datasources/order_checkout_remote_data_source.dart';

class OrderCheckoutRepositoryImpl implements OrderCheckoutRepository {
  OrderCheckoutRepositoryImpl({required this.remoteDataSource});

  final OrderCheckoutRemoteDataSource remoteDataSource;

  @override
  Future<ServiceQuote> createQuote({
    required String serviceId,
    required double area,
    required String? roomOptionId,
    required String? cleaningOptionId,
    required Set<String> extraOptionIds,
  }) => remoteDataSource.createQuote({
    'service_id': serviceId,
    'area_sqm': area,
    if (roomOptionId != null) 'room_option_id': roomOptionId,
    if (cleaningOptionId != null) 'cleaning_option_id': cleaningOptionId,
    'extra_option_ids': extraOptionIds.toList(growable: false),
  });

  @override
  Future<void> createOrder({
    required String quoteId,
    required String idempotencyKey,
    required Map<String, dynamic> address,
    required DateTime scheduledAt,
  }) => remoteDataSource.createOrder(
    idempotencyKey: idempotencyKey,
    payload: {
      'quote_id': quoteId,
      'address': address,
      'scheduled_at': scheduledAt.toIso8601String(),
      'payment_method': null,
    },
  );
}
