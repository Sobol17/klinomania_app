import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../../domain/entities/cleaner_order.dart';
import '../controllers/cleaner_orders_controller.dart';
import '../utils/order_history_formatters.dart';
import 'cleaner_order_details_page.dart';

class CleanerOrdersPage extends StatefulWidget {
  const CleanerOrdersPage({super.key});

  @override
  State<CleanerOrdersPage> createState() => _CleanerOrdersPageState();
}

class _CleanerOrdersPageState extends State<CleanerOrdersPage> {
  CleanerOrdersFilter _filter = CleanerOrdersFilter.myOrders;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CleanerOrdersController>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<CleanerOrdersController>(
      builder: (context, controller, _) {
        final filteredOrders = _filteredOrders(controller.orders);
        final bool showLoading =
            controller.isLoading && controller.orders.isEmpty;
        final Widget listContent;
        if (showLoading) {
          listContent = const Center(child: CircularProgressIndicator());
        } else if (filteredOrders.isEmpty) {
          listContent = _EmptyOrdersPlaceholder(filter: _filter);
        } else {
          listContent = ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return _CleanerOrderCard(
                order: order,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CleanerOrderDetailsPage(order: order),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: filteredOrders.length,
          );
        }

        return Stack(
          children: [
            const Positioned.fill(child: HomeBackground()),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Мои заказы',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Актуальные заявки ждут подтверждения',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _CleanerOrdersFilterBar(
                          value: _filter,
                          onChanged: (value) {
                            if (value == _filter) return;
                            setState(() => _filter = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Заказы',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (controller.errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            controller.errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: listContent),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<CleanerOrder> _filteredOrders(List<CleanerOrder> orders) {
    switch (_filter) {
      case CleanerOrdersFilter.myOrders:
        return orders
            .where((order) => !order.isCompleted)
            .toList(growable: false);
      case CleanerOrdersFilter.standard:
        return orders
            .where((order) => order.planName == 'Стандарт')
            .toList(growable: false);
      case CleanerOrdersFilter.completed:
        return orders
            .where((order) => order.isCompleted)
            .toList(growable: false);
    }
  }
}

enum CleanerOrdersFilter { myOrders, standard, completed }

extension CleanerOrdersFilterData on CleanerOrdersFilter {
  String get label {
    switch (this) {
      case CleanerOrdersFilter.myOrders:
        return 'Все заказы';
      case CleanerOrdersFilter.standard:
        return 'Стандарт';
      case CleanerOrdersFilter.completed:
        return 'Завершен';
    }
  }

  IconData? get icon =>
      this == CleanerOrdersFilter.myOrders ? Icons.schedule : null;
}

class _CleanerOrdersFilterBar extends StatelessWidget {
  const _CleanerOrdersFilterBar({required this.value, required this.onChanged});

  final CleanerOrdersFilter value;
  final ValueChanged<CleanerOrdersFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: CleanerOrdersFilter.values.map((filter) {
        final bool isSelected = value == filter;
        final Color background = isSelected
            ? AppColors.primary
            : AppColors.surface;
        final Color borderColor = isSelected
            ? AppColors.primary
            : AppColors.border.withValues(alpha: 0.9);
        final Color textColor = isSelected
            ? AppColors.white
            : AppColors.textPrimary;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onChanged(filter),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(AppStyle.cardRadius),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (filter.icon != null) ...[
                      Icon(filter.icon, color: textColor, size: 18),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        filter.label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CleanerOrderCard extends StatelessWidget {
  const _CleanerOrderCard({required this.order, required this.onTap});

  final CleanerOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool highlight =
        order.highlightCard && order.canAccept && _isPremium(order.planName);
    final Color textColor = AppColors.textPrimary;
    final Color secondaryColor = AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: highlight ? AppColors.softBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(AppStyle.cardRadius),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: highlight
                        ? AppColors.surface.withValues(alpha: 0.65)
                        : AppColors.softBlue,
                    borderRadius: BorderRadius.circular(AppStyle.inputRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    order.status.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: order.status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${OrderHistoryFormatters.formatShortDayMonth(order.startAt)} • '
                  '${OrderHistoryFormatters.formatTime(order.startAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.planName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: textColor),
                const SizedBox(width: 4),
                Text(
                  OrderHistoryFormatters.formatPrice(order.price),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              order.address,
              style: theme.textTheme.bodySmall?.copyWith(color: secondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPremium(String planName) {
    final normalized = planName.trim().toLowerCase();
    return normalized == 'премиум' || normalized == 'premium';
  }
}

class _EmptyOrdersPlaceholder extends StatelessWidget {
  const _EmptyOrdersPlaceholder({required this.filter});

  final CleanerOrdersFilter filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    late final String message;
    switch (filter) {
      case CleanerOrdersFilter.completed:
        message = 'Завершённых заказов пока нет';
        break;
      case CleanerOrdersFilter.standard:
        message = 'Нет доступных заказов в тарифе «Стандарт»';
        break;
      case CleanerOrdersFilter.myOrders:
        message = 'Новые заказы появятся в ближайшее время';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

extension CleanerOrderStatusStyle on CleanerOrderStatus {
  String get label {
    switch (this) {
      case CleanerOrderStatus.available:
        return 'Новый заказ';
      case CleanerOrderStatus.assigned:
        return 'В работе';
      case CleanerOrderStatus.completed:
        return 'Завершен';
    }
  }

  Color get color {
    switch (this) {
      case CleanerOrderStatus.available:
        return AppColors.primary;
      case CleanerOrderStatus.assigned:
        return AppColors.primary;
      case CleanerOrderStatus.completed:
        return AppColors.success;
    }
  }
}
