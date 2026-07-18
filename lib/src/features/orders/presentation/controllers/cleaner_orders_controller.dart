import 'package:flutter/material.dart';

import '../../domain/entities/cleaner_order.dart';
import '../../domain/repositories/cleaner_orders_repository.dart';

class CleanerOrdersController extends ChangeNotifier {
  CleanerOrdersController({required this.repository});

  final CleanerOrdersRepository repository;

  List<CleanerOrder> _orders = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  String? _acceptingOrderId;
  String? _startingOrderId;
  String? _completingOrderId;
  final Set<String> _startedOrderIds = <String>{};

  List<CleanerOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool isAccepting(String orderId) => _acceptingOrderId == orderId;
  bool isStarting(String orderId) => _startingOrderId == orderId;
  bool isCompleting(String orderId) => _completingOrderId == orderId;
  bool isStarted(String orderId) => _startedOrderIds.contains(orderId);

  void ensureLoaded() {
    if (_hasLoaded || _isLoading) {
      return;
    }
    _hasLoaded = true;
    loadOrders();
  }

  Future<void> loadOrders() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await repository.fetchOrders();
      _startedOrderIds.removeWhere((id) {
        final index = _orders.indexWhere((order) => order.id == id);
        if (index == -1) return true;
        return _orders[index].isCompleted;
      });
    } catch (error) {
      _errorMessage = _mapError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> acceptOrder(String orderId) async {
    if (_acceptingOrderId != null) {
      return 'Подождите, заказ обрабатывается';
    }
    _acceptingOrderId = orderId;
    notifyListeners();

    try {
      await repository.acceptOrder(orderId);
      _markOrderAccepted(orderId);
      return null;
    } catch (error) {
      return _mapError(error);
    } finally {
      _acceptingOrderId = null;
      notifyListeners();
    }
  }

  void _markOrderAccepted(String orderId) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return;
    }
    final existing = _orders[index];
    final updated = CleanerOrder(
      id: existing.id,
      planName: existing.planName,
      objectType: existing.objectType,
      address: existing.address,
      price: existing.price,
      startAt: existing.startAt,
      cleanersLabel: existing.cleanersLabel,
      durationLabel: existing.durationLabel,
      comment: existing.comment,
      area: existing.area,
      status: CleanerOrderStatus.assigned,
      services: existing.services,
      highlightCard: false,
    );
    final updatedOrders = List<CleanerOrder>.from(_orders);
    updatedOrders[index] = updated;
    _orders = updatedOrders;
  }

  Future<String?> startOrder(String orderId) async {
    if (_startingOrderId != null || _completingOrderId != null) {
      return 'Подождите, заказ обрабатывается';
    }
    if (_startedOrderIds.contains(orderId)) {
      return 'Заказ уже в работе';
    }
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return 'Заказ не найден';
    }
    final order = _orders[index];
    if (order.isCompleted) {
      return 'Заказ уже завершен';
    }
    if (order.status != CleanerOrderStatus.assigned) {
      return 'Сначала примите заказ';
    }

    _startingOrderId = orderId;
    notifyListeners();

    try {
      await repository.startOrder(orderId);
      _startedOrderIds.add(orderId);
      return null;
    } catch (error) {
      return _mapError(error);
    } finally {
      _startingOrderId = null;
      notifyListeners();
    }
  }

  Future<String?> completeOrder(String orderId) async {
    if (_startingOrderId != null || _completingOrderId != null) {
      return 'Подождите, заказ обрабатывается';
    }
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return 'Заказ не найден';
    }
    final existing = _orders[index];
    if (existing.isCompleted) {
      return 'Заказ уже завершен';
    }
    if (existing.status != CleanerOrderStatus.assigned) {
      return 'Сначала примите заказ';
    }

    _completingOrderId = orderId;
    notifyListeners();

    try {
      await repository.completeOrder(orderId);
      _markOrderCompleted(orderId);
      return null;
    } catch (error) {
      return _mapError(error);
    } finally {
      _completingOrderId = null;
      notifyListeners();
    }
  }

  void _markOrderCompleted(String orderId) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return;
    }
    _startedOrderIds.remove(orderId);
    final existing = _orders[index];
    final updated = CleanerOrder(
      id: existing.id,
      planName: existing.planName,
      objectType: existing.objectType,
      address: existing.address,
      price: existing.price,
      startAt: existing.startAt,
      cleanersLabel: existing.cleanersLabel,
      durationLabel: existing.durationLabel,
      comment: existing.comment,
      area: existing.area,
      status: CleanerOrderStatus.completed,
      services: existing.services,
      highlightCard: false,
    );
    final updatedOrders = List<CleanerOrder>.from(_orders);
    updatedOrders[index] = updated;
    _orders = updatedOrders;
  }

  String _mapError(Object error) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }

    return 'Что-то пошло не так. Попробуйте снова';
  }
}
