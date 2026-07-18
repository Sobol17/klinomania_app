import 'package:flutter/material.dart';

import '../../domain/entities/cleaner_order.dart';
import '../../domain/repositories/cleaner_orders_repository.dart';

class CleanerOrderDetailsController extends ChangeNotifier {
  CleanerOrderDetailsController({required this.repository});

  final CleanerOrdersRepository repository;

  CleanerOrder? _order;
  bool _isLoading = false;
  String? _errorMessage;

  CleanerOrder? get order => _order;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrder(String publicId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _order = await repository.fetchOrderDetails(publicId);
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
    return 'Не удалось загрузить детали заявки';
  }
}
