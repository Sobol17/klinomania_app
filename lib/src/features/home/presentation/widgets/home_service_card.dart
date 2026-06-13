import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/service_image_preview.dart';
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
    final bool isDark = service.cardStyle == CleaningServiceCardStyle.dark;
    final Color textColor = AppColors.textPrimary;
    final Color descriptionColor = AppColors.textSecondary;
    final Color background = isDark ? AppColors.softBlue : AppColors.surface;

    final arrowColor = AppColors.textSecondary;
    final card = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppStyle.panelRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  service.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: arrowColor, size: 22),
            ],
          ),
          if (service.subtitle != null && !service.hasImage) ...[
            const SizedBox(height: 12),
            Text(
              service.subtitle!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: descriptionColor,
                height: 1.35,
              ),
            ),
          ],
          if (service.hasImage) const SizedBox(height: 12),
          if (service.hasImage)
            ServiceImagePreview(
              isDark: isDark,
              imageAsset: service.imageAsset,
              imageUrl: service.imageUrl,
              cleaners: service.cleaners,
              duration: service.duration,
            ),
          if (!service.hasImage) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoPill(
                  icon: Icons.cleaning_services,
                  label: service.cleaners,
                  dark: isDark,
                ),
                InfoPill(
                  icon: Icons.schedule,
                  label: service.duration,
                  dark: isDark,
                ),
              ],
            ),
          ],
        ],
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}
