import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_navigation_bar.dart';
import '../../../auth/domain/entities/auth_session.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../orders/presentation/pages/cleaner_order_history_page.dart';
import '../../../orders/presentation/pages/cleaner_orders_page.dart';
import '../../../orders/presentation/pages/order_history_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../services/presentation/controllers/services_controller.dart';
import '../../../services/presentation/pages/service_detail_page.dart';
import '../../domain/entities/cleaning_service.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_background.dart';
import '../widgets/home_service_card.dart';
import '../widgets/home_status_row.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthController>().role;
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        final bool isCleaner = role == UserRole.cleaner;
        final Widget homeTab = isCleaner
            ? const CleanerOrdersPage()
            : _HomeTab(controller: controller);
        final Widget historyTab = isCleaner
            ? const CleanerOrderHistoryPage()
            : const OrderHistoryPage();
        return Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: controller.currentNavigationIndex,
            onDestinationSelected: controller.selectNavigationIndex,
          ),
          body: IndexedStack(
            index: controller.currentNavigationIndex,
            children: [homeTab, historyTab, const ProfilePage()],
          ),
        );
      },
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab({required this.controller});

  final HomeController controller;

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ServicesController>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Stack(
      children: [
        const Positioned.fill(child: HomeBackground()),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeStatusRow(controller: controller),
                const SizedBox(height: 24),
                Consumer<ServicesController>(
                  builder: (context, servicesController, _) {
                    final services = servicesController.services;
                    if (servicesController.isLoading && services.isEmpty) {
                      return const _ServicesStateCard(
                        label: 'Загружаем услуги...',
                        showLoader: true,
                      );
                    }
                    if (servicesController.listError != null &&
                        services.isEmpty) {
                      return _ServicesStateCard(
                        label: servicesController.listError!,
                        icon: Icons.error_outline,
                      );
                    }
                    if (services.isEmpty) {
                      return const _ServicesStateCard(
                        label: 'Пока нет доступных услуг.',
                        icon: Icons.cleaning_services_outlined,
                      );
                    }
                    return _ServicesList(services: services);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ServicesList extends StatelessWidget {
  const _ServicesList({required this.services});

  final List<CleaningService> services;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Выберите уборку',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontFamily: 'LovelaceText',
            fontWeight: FontWeight.w400,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Три тарифа для разных сценариев: от регулярной поддержки до максимального набора услуг.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < services.length; i++) ...[
          _buildServiceCard(context, services[i]),
          if (i != services.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, CleaningService service) {
    return HomeServiceCard(
      service: service,
      onTap: () => _openService(context, service),
    );
  }

  void _openService(BuildContext context, CleaningService service) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServiceDetailPage(service: service),
      ),
    );
  }
}

class _ServicesStateCard extends StatelessWidget {
  const _ServicesStateCard({
    required this.label,
    this.icon,
    this.showLoader = false,
  });

  final String label;
  final IconData? icon;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyle.panelRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          if (showLoader)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (icon != null)
            Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
