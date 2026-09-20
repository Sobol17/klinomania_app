import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../auth/presentation/widgets/cta_button.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../../domain/entities/cleaner_order.dart';
import '../controllers/cleaner_order_details_controller.dart';
import '../controllers/cleaner_orders_controller.dart';
import '../utils/order_history_formatters.dart';
import 'cleaner_order_checklist_page.dart';
import 'cleaner_order_details_error.dart';

class CleanerOrderDetailsPage extends StatefulWidget {
  const CleanerOrderDetailsPage({
    super.key,
    required this.order,
    this.isHistoryView = false,
  });

  final CleanerOrder order;
  final bool isHistoryView;

  @override
  State<CleanerOrderDetailsPage> createState() =>
      _CleanerOrderDetailsPageState();
}

class _CleanerOrderDetailsPageState extends State<CleanerOrderDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CleanerOrderDetailsController>().loadOrder(widget.order.id);
    });
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _acceptOrder(BuildContext context) async {
    final controller = context.read<CleanerOrdersController>();
    final detailsController = context.read<CleanerOrderDetailsController>();
    final error = await controller.acceptOrder(widget.order.id);
    if (!context.mounted) return;
    if (error == null) {
      await detailsController.loadOrder(widget.order.id);
      if (!context.mounted) return;
      _showSnack(context, 'Заказ закреплён за вами');
    } else {
      _showSnack(context, error);
    }
  }

  void _contactManager(BuildContext context) {
    _showSnack(context, 'Свяжем вас с менеджером');
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CleanerOrdersController>();
    final CleanerOrder activeOrder = controller.orders.firstWhere(
      (existing) => existing.id == widget.order.id,
      orElse: () => widget.order,
    );
    final detailsController = context.watch<CleanerOrderDetailsController>();
    final detailsOrder = detailsController.order;
    final order = detailsOrder ?? activeOrder;
    final bool isLoading = detailsController.isLoading && detailsOrder == null;
    final String? loadError = detailsController.errorMessage;
    final bool isCompleted = order.isCompleted;
    final bool isAwaitingPayment = order.isAwaitingPayment;
    final bool canAccept = order.canAccept;
    final bool isAccepting = controller.isAccepting(order.id);
    final String actionLabel;
    if (canAccept) {
      actionLabel = 'Принять заказ';
    } else if (isAwaitingPayment) {
      actionLabel = 'Ожидает оплаты';
    } else if (isCompleted) {
      actionLabel = 'Заказ завершен';
    } else {
      actionLabel = 'Связаться с клиентом';
    }
    final VoidCallback? action = isCompleted || isAwaitingPayment
        ? null
        : () {
            if (canAccept) {
              _acceptOrder(context);
            } else {
              _showSnack(context, 'Мы уведомим клиента о вашем статусе');
            }
          };
    final bool showProgressActions =
        !isCompleted && !isAwaitingPayment && !canAccept;

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
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 64),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else ...[
                          if (loadError != null) ...[
                            DetailsLoadError(message: loadError),
                            const SizedBox(height: 16),
                          ],
                          _OrderHeaderCard(order: order),
                          const SizedBox(height: 16),
                          _CleanerOrderDetailsCard(order: order),
                          if (!widget.isHistoryView) ...[
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: CTAButton(
                                    label: 'Как добраться?',
                                    onPressed: () => _showSnack(
                                      context,
                                      'Скоро построим маршрут',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CTAButton(
                                    label: 'Задать вопрос',
                                    variant: CTAButtonVariant.outline,
                                    onPressed: () => _contactManager(context),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: widget.isHistoryView
                      ? CTAButton(
                          label: 'Задать вопрос',
                          variant: CTAButtonVariant.outline,
                          onPressed: () => _contactManager(context),
                        )
                      : showProgressActions
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CTAButton(
                              label: 'Чеклист уборки',
                              leading: const Icon(
                                Icons.checklist_outlined,
                                size: 22,
                                color: AppColors.white,
                              ),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      CleanerOrderChecklistPage(order: order),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            CTAButton(
                              label: 'Связаться с клиентом',
                              variant: CTAButtonVariant.outline,
                              onPressed: action,
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
            order.planName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoChip(icon: Icons.people_outline, label: order.cleanersLabel),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.home_outlined, label: order.objectType),
            ],
          ),
        ],
      ),
    );
  }
}

class _CleanerOrderDetailsCard extends StatelessWidget {
  const _CleanerOrderDetailsCard({required this.order});

  final CleanerOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailItem(label: 'Количество комнат', value: order.objectType),
          if (order.mainCleaningOption != null)
            _DetailItem(
              label: 'Основной вариант уборки',
              value: order.mainCleaningOption!,
            ),
          _DetailItem(
            label: 'Дата и время',
            value: OrderHistoryFormatters.formatFullDateTime(order.startAt),
          ),
          _DetailItem(label: 'Адрес', value: order.address),
          _DetailItem(label: 'Комментарий', value: order.comment),
          if (order.services.isNotEmpty)
            _DetailItem(
              label: 'Дополнительные опции',
              value: order.services
                  .where((service) => service.enabled)
                  .map((service) => service.label)
                  .join('\n'),
            ),
          const SizedBox(height: 12),
          Divider(color: AppColors.border.withValues(alpha: 0.8)),
          const SizedBox(height: 12),
          _TotalRow(totalPrice: order.price),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
