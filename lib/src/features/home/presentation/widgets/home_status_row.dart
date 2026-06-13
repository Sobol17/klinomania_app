import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/home_controller.dart';

class HomeStatusRow extends StatelessWidget {
  const HomeStatusRow({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
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
        Expanded(child: _PlanCard(controller: controller)),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.controller});

  final HomeController controller;

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
            controller.activePlan,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'В процессе',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
