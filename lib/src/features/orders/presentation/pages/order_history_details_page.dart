import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../auth/presentation/widgets/cta_button.dart';
import '../../domain/entities/order_history_entry.dart';
import '../controllers/order_history_controller.dart';
import '../utils/order_history_formatters.dart';
import 'payment_webview_page.dart';

class OrderHistoryDetailsPage extends StatefulWidget {
  const OrderHistoryDetailsPage({super.key, required this.order});

  final OrderHistoryEntry order;

  @override
  State<OrderHistoryDetailsPage> createState() =>
      _OrderHistoryDetailsPageState();
}

class _OrderHistoryDetailsPageState extends State<OrderHistoryDetailsPage> {
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _cancelOrder() async {
    final error = await context.read<OrderHistoryController>().cancelOrder(
      widget.order.id,
    );
    if (!mounted) return;
    if (error != null) {
      _showMessage(error);
      return;
    }
    _showMessage('Заявка отменена');
    Navigator.of(context).pop();
  }

  Future<void> _openPayment(OrderHistoryEntry order) async {
    try {
      final payment = await context
          .read<OrderHistoryController>()
          .requestPaymentLink(order.id);
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PaymentWebViewPage(paymentUrl: payment.paymentUrl),
        ),
      );
      if (!mounted) return;
      await context.read<OrderHistoryController>().loadHistory();
    } catch (error) {
      if (mounted) {
        _showMessage(_mapError(error));
      }
    }
  }

  String _mapError(Object error) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }
    return 'Что-то пошло не так. Попробуйте снова';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<OrderHistoryController>();
    final order = widget.order;
    final bool hasCleanerAssigned =
        order.status == OrderHistoryStatus.teamFormed ||
        order.status == OrderHistoryStatus.inProgress ||
        order.status == OrderHistoryStatus.awaitingPayment ||
        order.status == OrderHistoryStatus.completed;
    final Widget actionButton = order.canPay
        ? CTAButton(
            label: 'Оплатить',
            isLoading: controller.isRequestingPayment(order.id),
            onPressed: controller.isRequestingPayment(order.id)
                ? null
                : () => _openPayment(order),
          )
        : order.canCancel
        ? Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: AppColors.danger,
              ),
            ),
            child: CTAButton(
              label: 'Отменить',
              isLoading: controller.isCancelling(order.id),
              onPressed: controller.isCancelling(order.id)
                  ? null
                  : _cancelOrder,
            ),
          )
        : CTAButton(
            label: 'Повторить уборку',
            onPressed: () => _showMessage('Скоро повтор заказа будет доступен'),
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const AppBackButton(),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    child: Column(
                      children: [
                        _OrderHistoryDetailCard(order: order),
                        const SizedBox(height: 16),
                        _CleanerCard(
                          cleaner: order.cleaner,
                          hasCleanerAssigned: hasCleanerAssigned,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: actionButton,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryDetailCard extends StatelessWidget {
  const _OrderHistoryDetailCard({required this.order});

  final OrderHistoryEntry order;

  String _formatStartEnd() {
    final String start = order.startTime != null
        ? OrderHistoryFormatters.formatTime(order.startTime!)
        : (order.startStatusLabel ?? '-');
    final String end = order.endTime != null
        ? OrderHistoryFormatters.formatTime(order.endTime!)
        : (order.endStatusLabel ?? '-');
    return '$start - $end';
  }

  String _formatDuration() {
    if (order.durationLabel != null) {
      return order.durationLabel!;
    }
    if (order.startTime != null && order.endTime != null) {
      return OrderHistoryFormatters.formatDuration(
        order.endTime!.difference(order.startTime!),
      );
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Text(
            order.status.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: order.status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            order.serviceName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _DetailItem(
            label: order.mainCleaningOption == null
                ? 'Вид уборки'
                : 'Основной вариант уборки',
            value: order.mainCleaningOption ?? order.cleaningType,
          ),
          if (order.area != null)
            _DetailItem(
              label: 'Площадь',
              value: '${order.area!.toStringAsFixed(0)} м²',
            ),
          if (order.roomsDescription != null)
            _DetailItem(
              label: 'Количество комнат в квартире',
              value: order.roomsDescription!,
            ),
          if (order.additionalOptions.isNotEmpty)
            _DetailItem(
              label: 'Дополнительные опции',
              value: order.additionalOptions.join('\n'),
            ),
          _DetailItem(label: 'Адрес', value: order.address),
          _DetailItem(
            label: 'Дата и время',
            value: OrderHistoryFormatters.formatFullDateTime(order.scheduledAt),
          ),
          _DetailItem(label: 'Начало и конец уборки', value: _formatStartEnd()),
          _DetailItem(label: 'Уборка заняла', value: _formatDuration()),
          const SizedBox(height: 12),
          Divider(color: AppColors.border.withValues(alpha: 0.8)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Итоговая стоимость:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                OrderHistoryFormatters.formatPrice(order.price),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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

class _CleanerCard extends StatelessWidget {
  const _CleanerCard({required this.cleaner, required this.hasCleanerAssigned});

  final OrderCleaner cleaner;
  final bool hasCleanerAssigned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trimmedName = cleaner.name.trim();
    final initials = trimmedName.isNotEmpty
        ? trimmedName
              .split(' ')
              .where((word) => word.isNotEmpty)
              .map((word) => word[0])
              .take(2)
              .join()
        : '?';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.softBlue,
            child: hasCleanerAssigned
                ? cleaner.avatarAsset != null
                      ? ClipOval(child: Image.asset(cleaner.avatarAsset!))
                      : Text(
                          initials,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                : const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasCleanerAssigned) ...[
                  Text(
                    cleaner.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cleaner.speciality,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else
                  Text(
                    'Клинер назначается',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
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
