import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_navigation_bar.dart';
import '../../../home/domain/entities/cleaning_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../orders/presentation/pages/order_checkout_page.dart';
import '../../domain/service_detail_config.dart';
import '../../domain/service_detail_presets.dart';
import '../controllers/services_controller.dart';

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
    final totalPrice = config.calculateTotalPrice(
      selectedRoomId: _selectedRoomId,
      selectedCleaningId: _selectedCleaningId,
      selectedAddOns: _selectedAddOns,
      fallbackPrice: service.priceFrom,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
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
      body: SafeArea(
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
                          if (isLoading &&
                              servicesController.detailConfig(
                                    widget.service.id,
                                  ) ==
                                  null) ...[
                            const _DetailStatusCard(
                              label: 'Загружаем детали услуги...',
                              showLoader: true,
                            ),
                            const SizedBox(height: 14),
                          ],
                          if (detailError != null) ...[
                            _DetailStatusCard(
                              label: detailError,
                              icon: Icons.error_outline,
                            ),
                            const SizedBox(height: 14),
                          ],
                          if (config.description.trim().isNotEmpty) ...[
                            _ServiceDescriptionCard(
                              description: config.description,
                            ),
                            const SizedBox(height: 20),
                          ],
                          _ApartmentOptions(
                            roomOptions: config.roomOptions ?? const [],
                            addOnOptions: _addOnOptions(config),
                            selectedId: _selectedRoomId,
                            selectedAddOns: _selectedAddOns,
                            onSelect: _handleRoomSelection,
                            onAddOnSelect: _handleCleaningSelection,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomActionBar(
              total: _formatPrice(totalPrice) ?? '0 ₽',
              onPressed: _openCheckout,
            ),
          ],
        ),
      ),
    );
  }

  void _handleRoomSelection(String id) {
    final config = _activeConfig;
    final addOns = config.cleaningOptions ?? const <ServiceCleaningOption>[];
    final bool hasSelectedWindows = addOns.any(
      (option) =>
          _isWindowOption(option) && _selectedAddOns.contains(option.id),
    );

    setState(() {
      _selectedRoomId = id;
      if (!hasSelectedWindows) {
        return;
      }

      for (final option in addOns.where(_isWindowOption)) {
        _selectedAddOns.remove(option.id);
      }

      ServiceCleaningOption? nextWindowOption;
      for (final option in addOns.where(_isWindowOption)) {
        if (_windowOptionMatchesRoom(option, id)) {
          nextWindowOption = option;
          break;
        }
      }
      if (nextWindowOption != null) {
        _selectedAddOns.add(nextWindowOption.id);
      }
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
      selectedRoomId: _selectedRoomId,
      selectedCleaningId: _selectedCleaningId,
      selectedAddOns: _selectedAddOns,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderCheckoutPage(
          service: _activeService,
          config: config,
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

  List<ServiceCleaningOption> _addOnOptions(ServiceDetailConfig config) {
    return (config.cleaningOptions ?? const <ServiceCleaningOption>[])
        .where((option) => option.isAddon)
        .toList(growable: false);
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
    final theme = Theme.of(context);
    final price = _formatPrice(service.priceFrom ?? config.minPrice);
    final bool hasImage = service.hasImage;

    return SizedBox(
      height: hasImage ? 292 : 248,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            _HeroImageBackground(
              imageAsset: service.imageAsset,
              imageUrl: service.imageUrl,
              config: config,
            )
          else
            _HeroPlaceholder(config: config),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x1414213E),
                  Color(0x3314213E),
                  Color(0xD914213E),
                ],
                stops: [0, 0.48, 1],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Material(
              color: AppColors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(AppStyle.buttonRadius),
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(AppStyle.buttonRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppStyle.buttonRadius),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.72),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  service.subtitle ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.88),
                    height: 1.32,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (price != null)
                      _InfoPill(
                        icon: Icons.payments_outlined,
                        label: 'от $price',
                        dark: true,
                      ),
                    _InfoPill(
                      icon: Icons.person_outline,
                      label: service.cleaners,
                      dark: true,
                    ),
                    _InfoPill(
                      icon: Icons.schedule,
                      label: service.duration,
                      dark: true,
                    ),
                  ],
                ),
              ],
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

    if (resolvedUrl != null) {
      return Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return placeholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return placeholder();
        },
      );
    }

    if (resolvedAsset != null) {
      return Image.asset(
        resolvedAsset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return placeholder();
        },
      );
    }

    return placeholder();
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
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 28),
          child: Icon(
            config.heroIcon,
            size: 92,
            color: AppColors.primary.withValues(alpha: 0.24),
          ),
        ),
      ),
    );
  }
}

String? _formatPrice(double? value) {
  if (value == null || !value.isFinite || value <= 0) {
    return null;
  }

  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    buffer.write(digits[i]);
    final remaining = digits.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write(' ');
    }
  }
  return '${buffer.toString()} ₽';
}

class _ServiceDescriptionCard extends StatelessWidget {
  const _ServiceDescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Описание',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            height: 1.16,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ApartmentOptions extends StatelessWidget {
  const _ApartmentOptions({
    required this.roomOptions,
    required this.addOnOptions,
    required this.selectedId,
    required this.selectedAddOns,
    required this.onSelect,
    required this.onAddOnSelect,
  });

  final List<ServiceRoomOption> roomOptions;
  final List<ServiceCleaningOption> addOnOptions;
  final String? selectedId;
  final Set<String> selectedAddOns;
  final ValueChanged<String> onSelect;
  final ValueChanged<ServiceCleaningOption> onAddOnSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Размер квартиры',
          subtitle: 'Выберите вариант, который ближе всего к вашей квартире.',
        ),
        const SizedBox(height: 16),
        _OptionGrid(
          children: roomOptions.map((option) {
            final bool selected = option.id == selectedId;
            return _SelectableCard(
              title: option.label,
              selected: selected,
              onTap: () => onSelect(option.id),
            );
          }).toList(),
        ),
        if (addOnOptions.isNotEmpty) ...[
          const SizedBox(height: 32),
          _AdditionalOptions(
            options: addOnOptions,
            selectedRoomId: selectedId,
            selectedIds: selectedAddOns,
            onSelect: onAddOnSelect,
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            height: 1.16,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class _OptionGrid extends StatelessWidget {
  const _OptionGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool singleColumn = constraints.maxWidth < 300;
        final double itemWidth = singleColumn
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _AdditionalOptions extends StatelessWidget {
  const _AdditionalOptions({
    required this.options,
    required this.selectedRoomId,
    required this.selectedIds,
    required this.onSelect,
  });

  final List<ServiceCleaningOption> options;
  final String? selectedRoomId;
  final Set<String> selectedIds;
  final ValueChanged<ServiceCleaningOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final regularOptions = options
        .where((option) => !_isWindowOption(option))
        .toList(growable: false);
    final windowOptions = options
        .where(_isWindowOption)
        .where((option) => _windowOptionMatchesRoom(option, selectedRoomId))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Дополнительные опции'),
        if (regularOptions.isNotEmpty) ...[
          const SizedBox(height: 12),
          _OptionList(children: _buildOptionCards(regularOptions)),
        ],
        if (windowOptions.isNotEmpty) ...[
          const SizedBox(height: 32),
          const _SectionHeader(title: 'Мытье окон'),
          const SizedBox(height: 12),
          _OptionList(children: _buildOptionCards(windowOptions)),
        ],
      ],
    );
  }

  List<Widget> _buildOptionCards(List<ServiceCleaningOption> source) {
    return source.map((option) {
      return _SelectableCard(
        title: _formatOptionTitle(option),
        selected: selectedIds.contains(option.id),
        onTap: () => onSelect(option),
        isAddon: true,
      );
    }).toList();
  }
}

class _OptionList extends StatelessWidget {
  const _OptionList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          SizedBox(width: double.infinity, child: children[i]),
          if (i != children.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

String _formatOptionTitle(ServiceCleaningOption option) {
  final price = _formatPrice(option.priceModifier);
  if (price == null) {
    return option.label;
  }
  return '${option.label}: $price';
}

bool _isWindowOption(ServiceCleaningOption option) {
  final id = option.id.toLowerCase();
  return id.startsWith('window') || id.startsWith('windows');
}

bool _windowOptionMatchesRoom(
  ServiceCleaningOption option,
  String? selectedRoomId,
) {
  if (!_isWindowOption(option)) {
    return false;
  }
  if (selectedRoomId == null || selectedRoomId.isEmpty) {
    return true;
  }
  final optionId = option.id.toLowerCase();
  final roomId = selectedRoomId.toLowerCase();
  if (optionId.contains(roomId)) {
    return true;
  }
  final roomNumber = RegExp(r'\d+').firstMatch(roomId)?.group(0);
  if (roomNumber == null) {
    return true;
  }
  return optionId.contains('window-$roomNumber') ||
      optionId.contains('windows-$roomNumber') ||
      optionId.contains('okna-$roomNumber');
}

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.title,
    required this.selected,
    required this.onTap,
    this.isAddon = false,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool isAddon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color borderColor = selected ? AppColors.primary : AppColors.border;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: isAddon ? 0 : 116),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppStyle.cardRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppStyle.cardRadius),
              border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SelectionIndicator(active: selected, checkbox: isAddon),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
        ? AppColors.white.withValues(alpha: 0.12)
        : AppColors.softBlue;
    final Color textColor = dark ? AppColors.white : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppStyle.inputRadius),
        border: dark ? null : Border.all(color: AppColors.border),
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
  const _SelectionIndicator({required this.active, this.checkbox = false});

  final bool active;
  final bool checkbox;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: checkbox ? 20 : 14,
      width: checkbox ? 20 : 14,
      decoration: BoxDecoration(
        shape: checkbox ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: checkbox ? BorderRadius.circular(4) : null,
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
          width: checkbox ? 1.8 : 2,
        ),
        color: active ? AppColors.primary : Colors.transparent,
      ),
      child: checkbox && active
          ? const Icon(Icons.check, color: AppColors.white, size: 14)
          : null,
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
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
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
  const _BottomActionBar({required this.total, required this.onPressed});

  final String total;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding.bottom;
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + padding),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Итого',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 156,
            height: 48,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppStyle.buttonRadius),
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(AppStyle.buttonRadius),
                child: Center(
                  child: Text(
                    'Продолжить',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
