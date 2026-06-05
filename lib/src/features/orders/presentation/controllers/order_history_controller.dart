import 'package:flutter/material.dart';

import '../../domain/entities/order_history_entry.dart';
import '../../domain/repositories/order_history_repository.dart';

class OrderHistoryController extends ChangeNotifier {
  OrderHistoryController({required this.repository, this.useApi = true}) {
    if (!useApi) {
      _orders = buildMockOrderHistory();
    }
  }

  final OrderHistoryRepository repository;
  final bool useApi;

  List<OrderHistoryEntry> _orders = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<OrderHistoryEntry> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
      if (useApi) {
        _orders = await repository.fetchHistory();
      } else {
        _orders = buildMockOrderHistory();
      }
    } catch (error) {
      _errorMessage = _mapError(error);
    } finally {
      _isLoading = false;
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
