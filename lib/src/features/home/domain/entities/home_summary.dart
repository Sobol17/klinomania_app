class HomeSummary {
  const HomeSummary({
    required this.activeOrdersCount,
    required this.activeOrderStatus,
    required this.activeOrderStatusLabel,
  });

  final int activeOrdersCount;
  final String? activeOrderStatus;
  final String? activeOrderStatusLabel;
}
