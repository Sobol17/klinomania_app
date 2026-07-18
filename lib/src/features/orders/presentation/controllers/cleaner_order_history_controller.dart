import 'package:flutter/material.dart';

import '../../domain/entities/cleaner_order.dart';
import '../../domain/repositories/cleaner_order_history_repository.dart';

class CleanerOrderHistoryController extends ChangeNotifier {
  CleanerOrderHistoryController({required this.repository});

  final CleanerOrderHistoryRepository repository;

  List<CleanerOrder> _orders = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<CleanerOrder> get orders => _orders;
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
      _orders = await repository.fetchHistory();
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
