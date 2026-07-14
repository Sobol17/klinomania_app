import '../entities/service_quote.dart';

abstract class OrderCheckoutRepository {
  Future<ServiceQuote> createQuote({
    required String serviceId,
    required double area,
    required String? roomOptionId,
    required String? cleaningOptionId,
    required Set<String> extraOptionIds,
  });

  Future<void> createOrder({
    required String quoteId,
    required String idempotencyKey,
    required Map<String, dynamic> address,
    required DateTime scheduledAt,
  });
}
