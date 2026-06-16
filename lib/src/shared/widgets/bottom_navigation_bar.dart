import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.firstLabel = 'Уборки',
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final String firstLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle =
        theme.textTheme.labelMedium?.copyWith(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ) ??
        const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        );

    final bar = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.primary.withValues(alpha: 0.36),
          selectedIconTheme: const IconThemeData(color: AppColors.primary),
          unselectedIconTheme: IconThemeData(
            color: AppColors.primary.withValues(alpha: 0.36),
          ),
          selectedLabelStyle: labelStyle.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: labelStyle.copyWith(
            color: AppColors.primary.withValues(alpha: 0.36),
          ),
          showUnselectedLabels: true,
          selectedFontSize: labelStyle.fontSize ?? 12,
          unselectedFontSize: labelStyle.fontSize ?? 12,
          currentIndex: currentIndex,
          onTap: onDestinationSelected,
          items: [
            BottomNavigationBarItem(
              icon: const _NavIcon(
                asset: 'assets/icons/navigation/cleaning.svg',
                activeAsset: 'assets/icons/navigation/cleaning.svg',
              ),
              activeIcon: const _NavIcon(
                asset: 'assets/icons/navigation/cleaning.svg',
                activeAsset: 'assets/icons/navigation/cleaning.svg',
                isActive: true,
              ),
              label: firstLabel,
            ),
            const BottomNavigationBarItem(
              icon: _NavIcon(
                asset: 'assets/icons/navigation/time.svg',
                activeAsset: 'assets/icons/navigation/time.svg',
              ),
              activeIcon: _NavIcon(
                asset: 'assets/icons/navigation/time.svg',
                activeAsset: 'assets/icons/navigation/time.svg',
                isActive: true,
              ),
              label: 'История',
            ),
            const BottomNavigationBarItem(
              icon: _NavIcon(
                asset: 'assets/icons/navigation/profile.svg',
                activeAsset: 'assets/icons/navigation/profile.svg',
              ),
              activeIcon: _NavIcon(
                asset: 'assets/icons/navigation/profile.svg',
                activeAsset: 'assets/icons/navigation/profile.svg',
                isActive: true,
              ),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );

    return Theme(
      data: theme.copyWith(
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
      ),
      child: SafeArea(top: false, child: bar),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.asset,
    required this.activeAsset,
    this.isActive = false,
  });

  final String asset;
  final String activeAsset;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final iconColor = IconTheme.of(context).color ?? AppColors.primary;
    final icon = SvgPicture.asset(
      isActive ? activeAsset : asset,
      height: 24,
      width: 24,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );

    return Container(
      height: 34,
      width: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: !isActive ? Colors.transparent : AppColors.softBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: icon,
    );
  }
}
