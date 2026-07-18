import 'package:flutter/material.dart';

import '../../domain/entities/cleaner_order.dart';
import '../../domain/repositories/cleaner_orders_repository.dart';

class CleanerOrderDetailsController extends ChangeNotifier {
  CleanerOrderDetailsController({required this.repository});

  final CleanerOrdersRepository repository;

  CleanerOrder? _order;
  bool _isLoading = false;
  String? _errorMessage;
  final Set<String> _updatingChecklistItemIds = <String>{};

  CleanerOrder? get order => _order;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool isUpdatingChecklistItem(String itemId) =>
      _updatingChecklistItemIds.contains(itemId);

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

  Future<String?> completeChecklistItem({
    required String orderId,
    required String itemId,
  }) async {
    if (_updatingChecklistItemIds.contains(itemId)) return null;

    _updatingChecklistItemIds.add(itemId);
    notifyListeners();
    try {
      await repository.updateChecklistItem(orderId: orderId, itemId: itemId);
      _markChecklistItemCompleted(itemId);
      return null;
    } catch (error) {
      return _mapError(error);
    } finally {
      _updatingChecklistItemIds.remove(itemId);
      notifyListeners();
    }
  }

  void _markChecklistItemCompleted(String itemId) {
    final order = _order;
    if (order == null) return;
    _order = CleanerOrder(
      id: order.id,
      planName: order.planName,
      objectType: order.objectType,
      address: order.address,
      price: order.price,
      startAt: order.startAt,
      cleanersLabel: order.cleanersLabel,
      durationLabel: order.durationLabel,
      comment: order.comment,
      area: order.area,
      status: order.status,
      services: order.services,
      checklistSections: order.checklistSections
          .map(
            (section) => CleanerOrderChecklistSection(
              zone: section.zone,
              title: section.title,
              items: section.items
                  .map(
                    (item) => item.id == itemId
                        ? item.copyWith(completed: true)
                        : item,
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
      highlightCard: order.highlightCard,
    );
  }

  String _mapError(Object error) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }
    return 'Не удалось загрузить детали заявки';
  }
}
