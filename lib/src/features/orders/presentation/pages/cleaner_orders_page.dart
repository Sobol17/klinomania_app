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
  CleanerOrdersFilter _filter = CleanerOrdersFilter.all;

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
                          'Заявки на уборку',
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
                          'Заявки',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
    bool isActive(CleanerOrder order) => !order.isCompleted;

    switch (_filter) {
      case CleanerOrdersFilter.all:
        return orders.where(isActive).toList(growable: false);
      case CleanerOrdersFilter.basic:
        return orders
            .where(
              (order) => isActive(order) && order.planName == 'Базовый минимум',
            )
            .toList(growable: false);
      case CleanerOrdersFilter.general:
        return orders
            .where(
              (order) => isActive(order) && order.planName == 'Генеральская',
            )
            .toList(growable: false);
      case CleanerOrdersFilter.luxury:
        return orders
            .where(
              (order) =>
                  isActive(order) && order.planName == 'Роскошный максимум',
            )
            .toList(growable: false);
    }
  }
}

enum CleanerOrdersFilter { all, basic, general, luxury }

extension CleanerOrdersFilterData on CleanerOrdersFilter {
  String get label {
    switch (this) {
      case CleanerOrdersFilter.all:
        return 'Все';
      case CleanerOrdersFilter.basic:
        return 'Базовый минимум';
      case CleanerOrdersFilter.general:
        return 'Генеральская';
      case CleanerOrdersFilter.luxury:
        return 'Роскошный максимум';
    }
  }
}

class _CleanerOrdersFilterBar extends StatelessWidget {
  const _CleanerOrdersFilterBar({required this.value, required this.onChanged});

  final CleanerOrdersFilter value;
  final ValueChanged<CleanerOrdersFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
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

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  filter.label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
    return normalized == 'роскошный максимум' || normalized == 'premium';
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
      case CleanerOrdersFilter.basic:
        message = 'Нет доступных заявок по услуге «Базовый минимум»';
        break;
      case CleanerOrdersFilter.general:
        message = 'Нет доступных заявок по услуге «Генеральская»';
        break;
      case CleanerOrdersFilter.luxury:
        message = 'Нет доступных заявок по услуге «Роскошный максимум»';
        break;
      case CleanerOrdersFilter.all:
        message = 'Новые заявки появятся в ближайшее время';
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
