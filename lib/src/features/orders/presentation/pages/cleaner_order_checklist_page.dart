import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../auth/presentation/widgets/cta_button.dart';
import '../../domain/entities/cleaner_order.dart';
import '../controllers/cleaner_order_details_controller.dart';
import '../controllers/cleaner_orders_controller.dart';

class CleanerOrderChecklistPage extends StatefulWidget {
  const CleanerOrderChecklistPage({super.key, required this.order});

  final CleanerOrder order;

  @override
  State<CleanerOrderChecklistPage> createState() =>
      _CleanerOrderChecklistPageState();
}

class _CleanerOrderChecklistPageState extends State<CleanerOrderChecklistPage> {
  List<CleanerOrderChecklistItem> _items(CleanerOrder order) {
    return order.checklistSections
        .expand((section) => section.items)
        .toList(growable: false);
  }

  Future<void> _completeItem(CleanerOrder order, String itemId) async {
    final error = await context
        .read<CleanerOrderDetailsController>()
        .completeChecklistItem(orderId: order.id, itemId: itemId);
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _closeOrder(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final controller = context.read<CleanerOrdersController>();
    final detailsController = context.read<CleanerOrderDetailsController>();
    final result = await controller.completeOrder(widget.order.id);
    if (!mounted) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result.checklistIncomplete
                ? 'Отметьте все пункты чеклиста перед завершением заказа'
                : result.errorMessage ?? 'Заявка закрыта',
          ),
        ),
      );

    if (result.checklistIncomplete) {
      await detailsController.loadOrder(widget.order.id);
      if (!mounted) return;
    } else if (result.isSuccess) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detailsController = context.watch<CleanerOrderDetailsController>();
    final order = detailsController.order ?? widget.order;
    final items = _items(order);
    final total = items.length;
    final completed = items.where((item) => item.completed).length;
    final progress = total == 0 ? 0.0 : completed / total;
    final canClose = completed == total;
    final isClosing = context.watch<CleanerOrdersController>().isCompleting(
      widget.order.id,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const AppBackButton(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                children: [
                  Text(
                    'Чеклист уборки',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    order.planName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (order.mainCleaningOption != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      order.mainCleaningOption!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    order.address,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ProgressPanel(
                    completed: completed,
                    total: total,
                    progress: progress,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Пункты уборки',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    const _EmptyChecklist()
                  else
                    for (int i = 0; i < items.length; i++) ...[
                      _ChecklistTile(
                        index: i + 1,
                        label: items[i].label,
                        isChecked: items[i].completed,
                        isLoading: detailsController.isUpdatingChecklistItem(
                          items[i].id,
                        ),
                        onTap: items[i].completed
                            ? null
                            : () => _completeItem(order, items[i].id),
                      ),
                      if (i != items.length - 1) const SizedBox(height: 10),
                    ],
                ],
              ),
            ),
            _PinnedProgressBar(
              completed: completed,
              total: total,
              canClose: canClose,
              isLoading: isClosing,
              onClose: canClose && !isClosing
                  ? () => _closeOrder(context)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({
    required this.completed,
    required this.total,
    required this.progress,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$completed/$total',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'выполнено',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress,
              backgroundColor: AppColors.fieldBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.index,
    required this.label,
    required this.isChecked,
    required this.isLoading,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool isChecked;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isChecked ? const Color(0xFFF7F7F8) : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isChecked ? AppColors.primary : AppColors.fieldBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 34,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primary, width: 1.4),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(6),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : isChecked
                  ? const Icon(Icons.check, color: AppColors.white, size: 20)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChecklist extends StatelessWidget {
  const _EmptyChecklist();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Text(
        'Дополнительных опций нет',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PinnedProgressBar extends StatelessWidget {
  const _PinnedProgressBar({
    required this.completed,
    required this.total,
    required this.canClose,
    required this.isLoading,
    required this.onClose,
  });

  final int completed;
  final int total;
  final bool canClose;
  final bool isLoading;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = total > 0 && completed == total;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.fieldBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isCompleted
                      ? 'Все пункты отмечены'
                      : 'Отмечено $completed из $total',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isCompleted
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          CTAButton(
            label: 'Закрыть заявку',
            onPressed: onClose,
            isLoading: isLoading,
            leading: Icon(
              Icons.check_circle_outline,
              size: 22,
              color: canClose ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
