import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_navigation_bar.dart';
import '../../../auth/presentation/widgets/cta_button.dart';
import '../../../home/domain/entities/cleaning_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../../../orders/presentation/pages/order_checkout_page.dart';
import '../controllers/services_controller.dart';
import '../../domain/service_detail_config.dart';
import '../../domain/service_detail_presets.dart';

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({super.key, required this.service});

  final CleaningService service;

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  late final ServiceDetailConfig _fallbackConfig;
  String? _selectedRoomId;
  String? _selectedCleaningId;
  late final Set<String> _selectedAddOns;
  late double _area;

  @override
  void initState() {
    super.initState();
    _fallbackConfig = ServiceDetailPresets.resolve(widget.service);
    _selectedRoomId = _fallbackConfig.roomOptions?.isNotEmpty == true
        ? _fallbackConfig.roomOptions!.first.id
        : null;
    final nonAddons = _fallbackConfig.cleaningOptions
        ?.where((option) => !option.isAddon)
        .toList();
    _selectedCleaningId = nonAddons != null && nonAddons.isNotEmpty
        ? nonAddons.first.id
        : null;
    _selectedAddOns = <String>{};
    _area = _fallbackConfig.initialArea;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ServicesController>().loadServiceDetails(widget.service.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final servicesController = context.watch<ServicesController>();
    final service =
        servicesController.serviceById(widget.service.id) ?? widget.service;
    final config =
        servicesController.detailConfig(widget.service.id) ?? _fallbackConfig;
    final bool isLoading = servicesController.isDetailLoading(
      widget.service.id,
    );
    final String? detailError = servicesController.detailError(
      widget.service.id,
    );

    _syncSelection(config);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: Consumer<HomeController>(
        builder: (context, homeController, _) {
          return CustomBottomNavigation(
            currentIndex: homeController.currentNavigationIndex,
            onDestinationSelected: (index) {
              if (index != homeController.currentNavigationIndex) {
                homeController.selectNavigationIndex(index);
              }
              Navigator.of(context).maybePop();
            },
          );
        },
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: HomeBackground()),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroSection(
                          service: service,
                          config: config,
                          onBack: () => Navigator.of(context).maybePop(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ServiceInfoCard(
                                service: service,
                                config: config,
                              ),
                              if (isLoading &&
                                  servicesController.detailConfig(
                                        widget.service.id,
                                      ) ==
                                      null) ...[
                                const SizedBox(height: 16),
                                const _DetailStatusCard(
                                  label: 'Загружаем детали услуги...',
                                  showLoader: true,
                                ),
                              ],
                              if (detailError != null) ...[
                                const SizedBox(height: 16),
                                _DetailStatusCard(
                                  label: detailError,
                                  icon: Icons.error_outline,
                                ),
                              ],
                              const SizedBox(height: 24),
                              if (config.layout ==
                                  ServiceDetailLayout.apartment)
                                _ApartmentOptions(
                                  roomOptions: config.roomOptions ?? const [],
                                  selectedId: _selectedRoomId,
                                  onSelect: (id) =>
                                      setState(() => _selectedRoomId = id),
                                )
                              else
                                _HouseOptions(
                                  area: _area,
                                  onAreaChanged: _changeArea,
                                  cleaningOptions:
                                      config.cleaningOptions ?? const [],
                                  selectedId: _selectedCleaningId,
                                  selectedAddOns: _selectedAddOns,
                                  onSelect: _handleCleaningSelection,
                                ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _BottomActionBar(onPressed: _openCheckout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _changeArea(double delta) {
    final config = _activeConfig;
    setState(() {
      final next = (_area + delta).clamp(config.minArea, config.maxArea);
      _area = next;
    });
  }

  void _handleCleaningSelection(ServiceCleaningOption option) {
    setState(() {
      if (option.isAddon) {
        if (_selectedAddOns.contains(option.id)) {
          _selectedAddOns.remove(option.id);
        } else {
          _selectedAddOns.add(option.id);
        }
      } else {
        _selectedCleaningId = option.id;
      }
    });
  }

  void _openCheckout() {
    final config = _activeConfig;
    final payload = config.toCheckoutPayload(
      area: _area,
      selectedRoomId: _selectedRoomId,
      selectedCleaningId: _selectedCleaningId,
      selectedAddOns: _selectedAddOns,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderCheckoutPage(
          service: _activeService,
          config: config,
          area: payload.area,
          selectedRoomId: payload.selectedRoomId,
          selectedCleaningId: payload.selectedCleaningId,
          selectedAddOns: payload.selectedAddOns,
        ),
      ),
    );
  }

  ServiceDetailConfig get _activeConfig {
    final controller = context.read<ServicesController>();
    return controller.detailConfig(widget.service.id) ?? _fallbackConfig;
  }

  CleaningService get _activeService {
    final controller = context.read<ServicesController>();
    return controller.serviceById(widget.service.id) ?? widget.service;
  }

  void _syncSelection(ServiceDetailConfig config) {
    final roomOptions = config.roomOptions ?? const [];
    final cleaningOptions = config.cleaningOptions ?? const [];
    final bool hasRooms = config.layout == ServiceDetailLayout.apartment;
    final bool hasCleaning = config.layout == ServiceDetailLayout.house;

    if (hasRooms &&
        roomOptions.isNotEmpty &&
        !roomOptions.any((option) => option.id == _selectedRoomId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedRoomId = roomOptions.first.id);
      });
    }

    if (hasCleaning) {
      final nonAddons = cleaningOptions
          .where((option) => !option.isAddon)
          .toList();
      if (nonAddons.isNotEmpty &&
          !nonAddons.any((option) => option.id == _selectedCleaningId)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _selectedCleaningId = nonAddons.first.id);
        });
      }
    }

    final double minArea = config.minArea;
    final double maxArea = config.maxArea;
    if (_area < minArea || _area > maxArea) {
      final double clamped = _area.clamp(minArea, maxArea);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _area = clamped);
      });
    }
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.service,
    required this.config,
    required this.onBack,
  });

  final CleaningService service;
  final ServiceDetailConfig config;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = service.hasImage;
    final double height = hasImage ? 260 : 200;
    final placeholder = _HeroPlaceholder(config: config);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: hasImage
                ? _HeroImageBackground(
                    imageAsset: service.imageAsset,
                    imageUrl: service.imageUrl,
                    config: config,
                  )
                : placeholder,
          ),
          Positioned(
            top: 16,
            left: 24,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Назад',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 32,
            child: Text(
              service.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImageBackground extends StatelessWidget {
  const _HeroImageBackground({
    required this.imageAsset,
    required this.imageUrl,
    required this.config,
  });

  final String? imageAsset;
  final String? imageUrl;
  final ServiceDetailConfig config;

  @override
  Widget build(BuildContext context) {
    final String? resolvedUrl = imageUrl != null && imageUrl!.trim().isNotEmpty
        ? imageUrl
        : null;
    final String? resolvedAsset =
        imageAsset != null && imageAsset!.trim().isNotEmpty ? imageAsset : null;
    Widget placeholder() => _HeroPlaceholder(config: config);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (resolvedUrl != null)
          Image.network(
            resolvedUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return placeholder();
            },
            errorBuilder: (context, error, stackTrace) {
              return placeholder();
            },
          )
        else if (resolvedAsset != null)
          Image.asset(
            resolvedAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return placeholder();
            },
          )
        else
          placeholder(),
        Container(color: Colors.black.withValues(alpha: 0.1)),
      ],
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.config});

  final ServiceDetailConfig config;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Icon(
            config.heroIcon,
            size: 72,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

class _ServiceInfoCard extends StatelessWidget {
  const _ServiceInfoCard({required this.service, required this.config});

  final CleaningService service;
  final ServiceDetailConfig config;

  @override
  Widget build(BuildContext context) {
    final bool dark = config.darkCard;
    final Color background = dark ? AppColors.darkCard : Colors.white;
    final Color textColor = dark ? Colors.white : AppColors.textPrimary;
    final Color secondary = dark
        ? Colors.white.withValues(alpha: 0.8)
        : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: dark ? 0.3 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  service.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              Text(
                'Прибытие через: ${config.arrivalMinutes} мин',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: secondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                icon: Icons.person_outline,
                label: service.cleaners,
                dark: dark,
              ),
              _InfoPill(
                icon: Icons.schedule,
                label: service.duration,
                dark: dark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            config.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: secondary),
          ),
        ],
      ),
    );
  }
}

class _ApartmentOptions extends StatelessWidget {
  const _ApartmentOptions({
    required this.roomOptions,
    required this.selectedId,
    required this.onSelect,
  });

  final List<ServiceRoomOption> roomOptions;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Количество комнат в квартире:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: roomOptions.map((option) {
            final bool selected = option.id == selectedId;
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 2,
              child: _SelectableCard(
                title: option.label,
                subtitle: option.area,
                selected: selected,
                onTap: () => onSelect(option.id),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _HouseOptions extends StatelessWidget {
  const _HouseOptions({
    required this.area,
    required this.onAreaChanged,
    required this.cleaningOptions,
    required this.selectedId,
    required this.selectedAddOns,
    required this.onSelect,
  });

  final double area;
  final ValueChanged<double> onAreaChanged;
  final List<ServiceCleaningOption> cleaningOptions;
  final String? selectedId;
  final Set<String> selectedAddOns;
  final ValueChanged<ServiceCleaningOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.square_foot, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Площадь',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _AreaStepper(area: area, onChanged: onAreaChanged),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Вид уборки:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cleaningOptions.map((option) {
            final bool selected = option.isAddon
                ? selectedAddOns.contains(option.id)
                : option.id == selectedId;
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 2,
              child: _SelectableCard(
                title: option.label,
                subtitle: option.subtitle ?? '',
                selected: selected,
                onTap: () => onSelect(option),
                isAddon: option.isAddon,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.isAddon = false,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool isAddon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color borderColor = selected
        ? AppColors.secondary
        : AppColors.border.withValues(alpha: 0.8);
    final Color background = selected
        ? AppColors.secondary.withValues(alpha: 0.08)
        : Colors.white;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _SelectionIndicator(active: selected),
                ],
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (isAddon) ...[
                const SizedBox(height: 8),
                Text(
                  selected ? 'Включено' : 'Отключено',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: selected
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.dark,
  });

  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color background = dark
        ? Colors.white.withValues(alpha: 0.1)
        : AppColors.background;
    final Color textColor = dark ? Colors.white : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 14,
      width: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? AppColors.secondary : AppColors.border,
          width: 2,
        ),
        color: active ? AppColors.secondary : Colors.transparent,
      ),
    );
  }
}

class _AreaStepper extends StatelessWidget {
  const _AreaStepper({required this.area, required this.onChanged});

  final double area;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundIconButton(icon: Icons.remove, onTap: () => onChanged(-20)),
        const SizedBox(width: 12),
        Text('${area.round()} м²', style: textStyle),
        const SizedBox(width: 12),
        _RoundIconButton(icon: Icons.add, onTap: () => onChanged(20)),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _DetailStatusCard extends StatelessWidget {
  const _DetailStatusCard({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + padding),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: CTAButton(label: 'Продолжить', onPressed: onPressed),
    );
  }
}
