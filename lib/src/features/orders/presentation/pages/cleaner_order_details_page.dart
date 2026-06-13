import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/cta_button.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../domain/entities/cleaner_order.dart';
import '../controllers/cleaner_orders_controller.dart';
import '../utils/order_history_formatters.dart';

class CleanerOrderDetailsPage extends StatelessWidget {
  const CleanerOrderDetailsPage({super.key, required this.order});

  final CleanerOrder order;

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _acceptOrder(BuildContext context) async {
    final controller = context.read<CleanerOrdersController>();
    final error = await controller.acceptOrder(order.id);
    if (!context.mounted) return;
    if (error == null) {
      _showSnack(context, 'Заказ закреплён за вами');
    } else {
      _showSnack(context, error);
    }
  }

  Future<void> _startOrder(BuildContext context) async {
    final controller = context.read<CleanerOrdersController>();
    final error = await controller.startOrder(order.id);
    if (!context.mounted) return;
    if (error == null) {
      _showSnack(context, 'Выполнение начато');
    } else {
      _showSnack(context, error);
    }
  }

  Future<void> _completeOrder(BuildContext context) async {
    final controller = context.read<CleanerOrdersController>();
    final error = await controller.completeOrder(order.id);
    if (!context.mounted) return;
    if (error == null) {
      _showSnack(context, 'Заказ завершен');
    } else {
      _showSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<CleanerOrdersController>();
    final CleanerOrder activeOrder = controller.orders.firstWhere(
      (existing) => existing.id == order.id,
      orElse: () => order,
    );
    final bool isCompleted = activeOrder.isCompleted;
    final bool canAccept = activeOrder.canAccept;
    final bool isStarted = controller.isStarted(activeOrder.id);
    final bool isAccepting = controller.isAccepting(activeOrder.id);
    final bool isStarting = controller.isStarting(activeOrder.id);
    final bool isCompleting = controller.isCompleting(activeOrder.id);
    final bool isProgressLoading = isStarting || isCompleting;
    final String actionLabel;
    if (canAccept) {
      actionLabel = 'Принять заказ';
    } else if (isCompleted) {
      actionLabel = 'Заказ завершен';
    } else {
      actionLabel = 'Связаться с клиентом';
    }
    final VoidCallback? action = isCompleted
        ? null
        : () {
            if (canAccept) {
              _acceptOrder(context);
            } else {
              _showSnack(context, 'Мы уведомим клиента о вашем статусе');
            }
          };
    final bool showProgressActions = !isCompleted && !canAccept;
    final String progressLabel = isStarted
        ? 'Завершить заказ'
        : 'Начать выполнение';
    final VoidCallback? progressAction = showProgressActions
        ? () {
            if (isStarted) {
              _completeOrder(context);
            } else {
              _startOrder(context);
            }
          }
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: HomeBackground()),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const AppBackButton(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OrderHeaderCard(order: activeOrder),
                        const SizedBox(height: 16),
                        _SectionTitle('Адрес:'),
                        _InfoField(value: activeOrder.address),
                        const SizedBox(height: 12),
                        _SectionTitle('Комментарий:'),
                        _InfoField(value: activeOrder.comment),
                        const SizedBox(height: 12),
                        _SectionTitle('Дата и начало уборки:'),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoField(
                                value: OrderHistoryFormatters.formatNumericDate(
                                  activeOrder.startAt,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoField(
                                value: OrderHistoryFormatters.formatTime(
                                  activeOrder.startAt,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _SectionTitle('Детали заказа:'),
                        _AreaRow(area: activeOrder.area),
                        const SizedBox(height: 12),
                        _ServicesGrid(services: activeOrder.services),
                        const SizedBox(height: 18),
                        Theme(
                          data: theme.copyWith(
                            colorScheme: theme.colorScheme.copyWith(
                              primary: AppColors.success,
                            ),
                          ),
                          child: CTAButton(
                            label: 'Как добраться?',
                            onPressed: () =>
                                _showSnack(context, 'Скоро построим маршрут'),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Divider(color: AppColors.border.withValues(alpha: 0.8)),
                        const SizedBox(height: 12),
                        _TotalRow(totalPrice: activeOrder.price),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: showProgressActions
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CTAButton(
                              label: progressLabel,
                              onPressed: isProgressLoading
                                  ? null
                                  : progressAction,
                              isLoading: isProgressLoading,
                            ),
                            const SizedBox(height: 12),
                            CTAButton(
                              label: 'Связаться с клиентом',
                              variant: CTAButtonVariant.outline,
                              onPressed: isProgressLoading ? null : action,
                            ),
                          ],
                        )
                      : CTAButton(
                          label: actionLabel,
                          onPressed: isAccepting ? null : action,
                          isLoading: isAccepting,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHeaderCard extends StatelessWidget {
  const _OrderHeaderCard({required this.order});

  final CleanerOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.objectType,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoChip(icon: Icons.people_outline, label: order.cleanersLabel),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.schedule, label: order.durationLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        value,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AreaRow extends StatelessWidget {
  const _AreaRow({required this.area});

  final double area;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Row(
            children: [
              const Icon(Icons.square_foot, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Площадь',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${area.toStringAsFixed(0)} м²',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({required this.services});

  final List<CleanerOrderServiceOption> services;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool multiColumn = services.length > 1;
        final double spacing = multiColumn ? 12 : 0;
        final double itemWidth = multiColumn
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: spacing,
          runSpacing: 12,
          children: services
              .map(
                (service) => SizedBox(
                  width: itemWidth,
                  child: _ServiceCard(service: service),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final CleanerOrderServiceOption service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool enabled = service.enabled;
    final Color textColor = enabled
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!enabled) ...[
            const SizedBox(height: 4),
            Text(
              'Отключено',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.totalPrice});

  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          'Итоговая стоимость:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          OrderHistoryFormatters.formatPrice(totalPrice),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
