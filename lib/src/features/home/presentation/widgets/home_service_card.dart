import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/cleaning_service.dart';
import 'info_pill.dart';

class HomeServiceCard extends StatelessWidget {
  const HomeServiceCard({
    super.key,
    required this.service,
    this.minHeight,
    this.onTap,
  });

  final CleaningService service;
  final double? minHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  service.title,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _DetailsBadge(),
            ],
          ),
          if (service.subtitle != null) ...[
            const SizedBox(height: 14),
            Text(
              service.subtitle!,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.38,
              ),
            ),
          ],

          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoPill(
                      icon: Icons.cleaning_services_outlined,
                      label: service.cleaners,
                    ),
                    InfoPill(icon: Icons.schedule, label: service.duration),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: card,
        ),
      ),
    );
  }
}

class _DetailsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.bgBlue,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textPrimary,
        size: 16,
      ),
    );
  }
}
