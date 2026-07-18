abstract class OrderCheckoutRepository {
  Future<void> createOrder({
    required String serviceId,
    required String? roomOptionId,
    required String? cleaningOptionId,
    required Set<String> extraOptionIds,
    required String idempotencyKey,
    required Map<String, dynamic> address,
    required String? comment,
    required DateTime scheduledAt,
  });
}
