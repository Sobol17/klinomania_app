import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../../domain/entities/order_history_entry.dart';
import '../controllers/order_history_controller.dart';
import '../utils/order_history_formatters.dart';
import 'order_history_details_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderHistoryController>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderHistoryController>(
      builder: (context, controller, _) {
        final sections = _groupOrders(controller.orders);
        final content = _buildContent(
          context,
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
}

List<Widget> _buildContent(
  BuildContext context, {
  required OrderHistoryController controller,
  required List<_OrderHistorySectionData> sections,
}) {
  final items = <Widget>[const _HistoryHeaderCard()];
  if (controller.isLoading && controller.orders.isEmpty) {
    items.add(const _HistoryLoadingCard());
    return items;
  }

  if (controller.errorMessage != null) {
    items.add(_HistoryErrorCard(message: controller.errorMessage!));
  }

  if (sections.isEmpty) {
    items.add(const _HistoryEmptyCard());
    return items;
  }

  items.addAll(
    sections.map((section) => _OrderHistorySection(section: section)),
  );
  return items;
}

class _OrderHistorySection extends StatelessWidget {
  const _OrderHistorySection({required this.section});

  final _OrderHistorySectionData section;

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
              _OrderHistoryCard(order: section.orders[i]),
              if (i != section.orders.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({required this.order});

  final OrderHistoryEntry order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool highlighted = order.highlightCard;
    final Color background = highlighted
        ? AppColors.softBlue
        : AppColors.surface;
    final metaLabel = _orderMetaLabel(order);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrderHistoryDetailsPage(order: order),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppStyle.cardRadius),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  order.status.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: order.status.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '${OrderHistoryFormatters.formatShortDayMonth(order.scheduledAt)}, ${OrderHistoryFormatters.formatTime(order.scheduledAt)}',
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
                    order.serviceName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  OrderHistoryFormatters.formatPrice(order.price),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
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

  String? _orderMetaLabel(OrderHistoryEntry order) {
    final parts = <String>[];
    final rooms = order.roomsDescription?.trim();
    if (rooms != null && rooms.isNotEmpty) {
      parts.add(rooms);
    }
    final cleaningType = order.cleaningType.trim();
    if (cleaningType.isNotEmpty && cleaningType != order.serviceName) {
      parts.add(cleaningType);
    }
    if (order.additionalOptions.isNotEmpty) {
      final options = order.additionalOptions.take(2).join(', ');
      final restCount = order.additionalOptions.length - 2;
      parts.add(restCount > 0 ? '$options + еще $restCount' : options);
    }
    return parts.isEmpty ? null : parts.join(' / ');
  }
}

class _HistoryHeaderCard extends StatelessWidget {
  const _HistoryHeaderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'История уборок',
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'LovelaceText',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Следите за статусами заказов и повторяйте понравившиеся услуги',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _HistoryLoadingCard extends StatelessWidget {
  const _HistoryLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _HistoryErrorCard extends StatelessWidget {
  const _HistoryErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
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

class _HistoryEmptyCard extends StatelessWidget {
  const _HistoryEmptyCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'История заказов пока пуста',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _OrderHistorySectionData {
  _OrderHistorySectionData({required this.title, required this.orders});

  final String title;
  final List<OrderHistoryEntry> orders;
}

List<_OrderHistorySectionData> _groupOrders(List<OrderHistoryEntry> orders) {
  if (orders.isEmpty) {
    return const [];
  }

  final sorted = List<OrderHistoryEntry>.from(orders)
    ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final todayOrders = <OrderHistoryEntry>[];
  final yesterdayOrders = <OrderHistoryEntry>[];
  final earlierOrders = <OrderHistoryEntry>[];

  for (final order in sorted) {
    final orderDay = DateTime(
      order.scheduledAt.year,
      order.scheduledAt.month,
      order.scheduledAt.day,
    );
    if (orderDay == today) {
      todayOrders.add(order);
    } else if (orderDay == yesterday) {
      yesterdayOrders.add(order);
    } else {
      earlierOrders.add(order);
    }
  }

  final sections = <_OrderHistorySectionData>[];
  if (todayOrders.isNotEmpty) {
    sections.add(
      _OrderHistorySectionData(
        title: 'Сегодня, ${OrderHistoryFormatters.formatNumericDate(today)}',
        orders: todayOrders,
      ),
    );
  }
  if (yesterdayOrders.isNotEmpty) {
    sections.add(
      _OrderHistorySectionData(
        title: 'Вчера, ${OrderHistoryFormatters.formatNumericDate(yesterday)}',
        orders: yesterdayOrders,
      ),
    );
  }
  if (earlierOrders.isNotEmpty) {
    sections.add(
      _OrderHistorySectionData(title: 'Ранее', orders: earlierOrders),
    );
  }
  return sections;
}
