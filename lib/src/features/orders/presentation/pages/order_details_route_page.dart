import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../domain/entities/order_history_entry.dart';
import '../controllers/order_history_controller.dart';
import 'order_history_details_page.dart';

class OrderDetailsRoutePage extends StatefulWidget {
  const OrderDetailsRoutePage({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailsRoutePage> createState() => _OrderDetailsRoutePageState();
}

class _OrderDetailsRoutePageState extends State<OrderDetailsRoutePage> {
  late Future<OrderHistoryEntry> _orderFuture;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  void _loadOrder() {
    _orderFuture = context.read<OrderHistoryController>().fetchOrder(
      widget.orderId,
    );
  }

  void _retry() {
    setState(_loadOrder);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderHistoryEntry>(
      future: _orderFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return OrderHistoryDetailsPage(order: snapshot.requireData);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(),
                ),
                Expanded(
                  child: Center(
                    child: snapshot.hasError
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.danger,
                                  size: 42,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage(snapshot.error!),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 20),
                                FilledButton(
                                  onPressed: _retry,
                                  child: const Text('Попробовать снова'),
                                ),
                              ],
                            ),
                          )
                        : const CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _errorMessage(Object error) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }
    return 'Не удалось загрузить заявку';
  }
}
