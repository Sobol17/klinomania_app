class PaymentOperation {
  const PaymentOperation({
    required this.id,
    required this.paymentUrl,
    required this.expiresAt,
    required this.status,
  });

  final String id;
  final Uri paymentUrl;
  final DateTime expiresAt;
  final String status;
}
