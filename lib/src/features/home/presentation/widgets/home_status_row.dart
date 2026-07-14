import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/home_controller.dart';
import '../../domain/entities/home_summary.dart';

class HomeStatusRow extends StatelessWidget {
  const HomeStatusRow({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final summary = controller.summary;
    return Row(
      children: [
        Expanded(
          child: Text(
            'Клиномания',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontFamily: 'LovelaceText',
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PlanCard(
            summary: summary,
            isLoading: controller.isSummaryLoading,
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.summary, required this.isLoading});

  final HomeSummary? summary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyle.panelRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Text(
            isLoading
                ? 'Загрузка...'
                : _countLabel(summary?.activeOrdersCount ?? 0),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (!isLoading &&
              (summary?.activeOrderStatusLabel?.isNotEmpty ?? false)) ...[
            const SizedBox(width: 8),
            Text(
              summary!.activeOrderStatusLabel!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _countLabel(int count) {
    final remainder = count % 100;
    if (remainder >= 11 && remainder <= 14) return '$count уборок';
    switch (count % 10) {
      case 1:
        return '$count уборка';
      case 2:
      case 3:
      case 4:
        return '$count уборки';
      default:
        return '$count уборок';
    }
  }
}
