import 'package:flutter/material.dart';

import '../../domain/entities/order_history_entry.dart';
import '../../domain/entities/payment_operation.dart';
import '../../domain/repositories/order_history_repository.dart';

class OrderHistoryController extends ChangeNotifier {
  OrderHistoryController({required this.repository});

  final OrderHistoryRepository repository;

  List<OrderHistoryEntry> _orders = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  String? _cancellingOrderId;
  String? _requestingPaymentOrderId;

  List<OrderHistoryEntry> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool isCancelling(String orderId) => _cancellingOrderId == orderId;
  bool isRequestingPayment(String orderId) =>
      _requestingPaymentOrderId == orderId;

  void ensureLoaded() {
    if (_hasLoaded || _isLoading) {
      return;
    }
    _hasLoaded = true;
    loadHistory();
  }

  Future<void> loadHistory() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await repository.fetchHistory();
    } catch (error) {
      _errorMessage = _mapError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderHistoryEntry> fetchOrder(String orderId) {
    return repository.fetchOrder(orderId);
  }

  Future<String?> cancelOrder(String orderId) async {
    if (_cancellingOrderId != null) {
      return 'Подождите, заявка обрабатывается';
    }

    _cancellingOrderId = orderId;
    notifyListeners();
    try {
      await repository.cancelOrder(orderId);
      await loadHistory();
      return null;
    } catch (error) {
      return _mapError(error);
    } finally {
      _cancellingOrderId = null;
      notifyListeners();
    }
  }

  Future<PaymentOperation> requestPaymentLink(String orderId) async {
    if (_requestingPaymentOrderId != null) {
      throw StateError('Подождите, ссылка на оплату создаётся');
    }

    _requestingPaymentOrderId = orderId;
    notifyListeners();
    try {
      return await repository.requestPaymentLink(orderId);
    } finally {
      _requestingPaymentOrderId = null;
      notifyListeners();
    }
  }

  String _mapError(Object error) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }

    return 'Что-то пошло не так. Попробуйте снова';
  }
}
