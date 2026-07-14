class ServiceQuote {
  const ServiceQuote({
    required this.id,
    required this.totalPrice,
    required this.currency,
    required this.expiresAt,
  });

  final String id;
  final double totalPrice;
  final String currency;
  final DateTime? expiresAt;
}
