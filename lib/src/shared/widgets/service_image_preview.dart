import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ServiceImagePreview extends StatelessWidget {
  const ServiceImagePreview({
    super.key,
    required this.isDark,
    this.imageAsset,
    this.imageUrl,
    required this.cleaners,
    required this.duration,
    this.height = 150,
  });

  final bool isDark;
  final String? imageAsset;
  final String? imageUrl;
  final String cleaners;
  final String duration;
  final double height;

  @override
  Widget build(BuildContext context) {
    final String? resolvedUrl = imageUrl != null && imageUrl!.trim().isNotEmpty
        ? imageUrl
        : null;
    final String? resolvedAsset =
        imageAsset != null && imageAsset!.trim().isNotEmpty ? imageAsset : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (resolvedUrl != null)
              Image.network(
                resolvedUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _ImagePlaceholder(isDark: isDark);
                },
                errorBuilder: (context, error, stackTrace) {
                  return _ImagePlaceholder(isDark: isDark);
                },
              )
            else if (resolvedAsset != null)
              Image.asset(resolvedAsset, fit: BoxFit.cover)
            else
              _ImagePlaceholder(isDark: isDark),
            Positioned(
              left: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImageInfoChip(icon: Icons.person_outline, label: cleaners),
                  const SizedBox(height: 6),
                  _ImageInfoChip(icon: Icons.access_time, label: duration),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageInfoChip extends StatelessWidget {
  const _ImageInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.darkCard : AppColors.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.chair_alt,
        color: isDark
            ? Colors.white.withValues(alpha: 0.7)
            : AppColors.primary.withValues(alpha: 0.6),
        size: 48,
      ),
    );
  }
}
