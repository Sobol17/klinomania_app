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
    final Color textColor = isDark ? Colors.white : AppColors.textPrimary;
    final Color descriptionColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : AppColors.textSecondary;
    final Color background = isDark ? AppColors.darkCard : AppColors.surface;

    final arrowColor = isDark ? Colors.white : AppColors.textSecondary;
    final card = Container(
      padding: isDark ? EdgeInsets.all(16) : EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12, right: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    service.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: arrowColor, size: 20),
              ],
            ),
          ),
          if (service.subtitle != null && !service.hasImage) ...[
            const SizedBox(height: 4),
            Text(
              service.subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: descriptionColor),
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
