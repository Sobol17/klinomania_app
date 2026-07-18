import 'package:flutter_test/flutter_test.dart';
import 'package:klinomania/src/features/orders/data/models/order_history_item_model.dart';
import 'package:klinomania/src/features/orders/domain/entities/order_history_entry.dart';

void main() {
  test('maps awaiting_payment to a payable order', () {
    final order = OrderHistoryItemModel.fromJson({
      'public_id': 'order-public-id',
      'status': 'awaiting_payment',
      'scheduled_at': '2026-07-19T12:00:00Z',
      'total_price': 1500,
    }).toEntry();

    expect(order.status, OrderHistoryStatus.awaitingPayment);
    expect(order.canPay, isTrue);
  });
}
