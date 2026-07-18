import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../../domain/entities/cleaner_order.dart';
import '../controllers/cleaner_order_history_controller.dart';
import '../utils/order_history_formatters.dart';
import 'cleaner_order_details_page.dart';

class CleanerOrderHistoryPage extends StatefulWidget {
  const CleanerOrderHistoryPage({super.key});

  @override
  State<CleanerOrderHistoryPage> createState() =>
      _CleanerOrderHistoryPageState();
}

class _CleanerOrderHistoryPageState extends State<CleanerOrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CleanerOrderHistoryController>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CleanerOrderHistoryController>(
      builder: (context, controller, _) {
        final sections = _groupOrders(controller.orders);
        final content = _buildContent(
          controller: controller,
          sections: sections,
        );

        return Stack(
          children: [
            const Positioned.fill(child: HomeBackground()),
            SafeArea(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                itemBuilder: (context, index) => content[index],
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemCount: content.length,
              ),
            ),
          ],
        );
      },
    );
  }

  List<_CleanerOrderHistorySectionData> _groupOrders(
    List<CleanerOrder> orders,
  ) {
    final Map<CleanerOrderStatus, List<CleanerOrder>> grouped = {};
    for (final status in CleanerOrderStatus.values) {
      grouped[status] = [];
    }
    for (final order in orders) {
      grouped[order.status]?.add(order);
    }

    return CleanerOrderStatus.values
        .map(
          (status) => _CleanerOrderHistorySectionData(
            title: _statusHistoryLabel(status),
            orders: List<CleanerOrder>.from(grouped[status] ?? [])
              ..sort((a, b) => b.startAt.compareTo(a.startAt)),
          ),
        )
        .where((section) => section.orders.isNotEmpty)
        .toList();
  }
}

List<Widget> _buildContent({
  required CleanerOrderHistoryController controller,
  required List<_CleanerOrderHistorySectionData> sections,
}) {
  final items = <Widget>[const _CleanerHistoryHeader()];
  if (controller.isLoading && controller.orders.isEmpty) {
    items.add(const _CleanerHistoryLoadingCard());
    return items;
  }

  if (controller.errorMessage != null) {
    items.add(_CleanerHistoryErrorCard(message: controller.errorMessage!));
  }

  if (sections.isEmpty) {
    items.add(const _CleanerHistoryEmptyCard());
    return items;
  }

  items.addAll(
    sections.map((section) => _CleanerOrderHistorySection(section: section)),
  );
  return items;
}

String _statusHistoryLabel(CleanerOrderStatus status) {
  switch (status) {
    case CleanerOrderStatus.available:
      return 'Новые заказы';
    case CleanerOrderStatus.assigned:
      return 'В работе';
    case CleanerOrderStatus.completed:
      return 'Завершённые';
  }
}

class _CleanerOrderHistorySection extends StatelessWidget {
  const _CleanerOrderHistorySection({required this.section});

  final _CleanerOrderHistorySectionData section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            for (int i = 0; i < section.orders.length; i++) ...[
              _CleanerOrderHistoryCard(order: section.orders[i]),
              if (i != section.orders.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _CleanerOrderHistoryCard extends StatelessWidget {
  const _CleanerOrderHistoryCard({required this.order});

  final CleanerOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color statusColor = _statusColor(order.status);
    final metaLabel = _cleanerOrderMetaLabel(order);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              CleanerOrderDetailsPage(order: order, isHistoryView: true),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: order.highlightCard ? AppColors.softBlue : Colors.white,
          borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _statusLabel(order.status),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${OrderHistoryFormatters.formatShortDayMonth(order.startAt)}, '
                  '${OrderHistoryFormatters.formatTime(order.startAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.planName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  OrderHistoryFormatters.formatPrice(order.price),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (metaLabel != null) ...[
              Text(
                metaLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              order.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _cleanerOrderMetaLabel(CleanerOrder order) {
    final parts = <String>[];
    if (order.objectType.trim().isNotEmpty) {
      parts.add(order.objectType.trim());
    }
    final services = order.services
        .where((service) => service.enabled)
        .map((service) => service.label.trim())
        .where((label) => label.isNotEmpty)
        .take(2)
        .toList(growable: false);
    if (services.isNotEmpty) {
      parts.add(services.join(', '));
    }
    return parts.isEmpty ? null : parts.join(' / ');
  }
}

class _CleanerHistoryHeader extends StatelessWidget {
  const _CleanerHistoryHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'История заявок',
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'LovelaceText',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Следите за статусом заявок и просматривайте завершённые работы.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _CleanerHistoryLoadingCard extends StatelessWidget {
  const _CleanerHistoryLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _CleanerHistoryErrorCard extends StatelessWidget {
  const _CleanerHistoryErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.danger),
      ),
    );
  }
}

class _CleanerHistoryEmptyCard extends StatelessWidget {
  const _CleanerHistoryEmptyCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'История заявок пока пуста',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _CleanerOrderHistorySectionData {
  const _CleanerOrderHistorySectionData({
    required this.title,
    required this.orders,
  });

  final String title;
  final List<CleanerOrder> orders;
}

String _statusLabel(CleanerOrderStatus status) {
  switch (status) {
    case CleanerOrderStatus.available:
      return 'Новый заказ';
    case CleanerOrderStatus.assigned:
      return 'В работе';
    case CleanerOrderStatus.completed:
      return 'Завершен';
  }
}

Color _statusColor(CleanerOrderStatus status) {
  switch (status) {
    case CleanerOrderStatus.available:
      return AppColors.primary;
    case CleanerOrderStatus.assigned:
      return AppColors.primary;
    case CleanerOrderStatus.completed:
      return AppColors.success;
  }
}
