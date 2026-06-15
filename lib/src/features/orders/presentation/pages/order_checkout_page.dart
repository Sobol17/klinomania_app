import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_navigation_bar.dart';
import '../../../auth/presentation/widgets/cta_button.dart';
import '../../../home/domain/entities/cleaning_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../../../services/domain/service_detail_config.dart';
import '../controllers/order_history_controller.dart';
import '../utils/order_history_formatters.dart';

class OrderCheckoutPage extends StatefulWidget {
  const OrderCheckoutPage({
    super.key,
    required this.service,
    required this.config,
    required this.area,
    required this.selectedRoomId,
    required this.selectedCleaningId,
    required this.selectedAddOns,
  });

  final CleaningService service;
  final ServiceDetailConfig config;
  final double area;
  final String? selectedRoomId;
  final String? selectedCleaningId;
  final Set<String> selectedAddOns;

  @override
  State<OrderCheckoutPage> createState() => _OrderCheckoutPageState();
}

class _OrderCheckoutPageState extends State<OrderCheckoutPage> {
  late double _area;
  late final TextEditingController _addressController;
  late final TextEditingController _entranceController;
  late final TextEditingController _floorController;
  late final TextEditingController _apartmentController;
  late final TextEditingController _intercomController;
  late final TextEditingController _commentController;
  late DateTime _date;
  late TimeOfDay _time;
  bool _isSubmitting = false;
  String? _errorMessage;

  static const double _fallbackTotalPrice = 7500;
  @override
  void initState() {
    super.initState();
    _area = widget.area;
    _addressController = TextEditingController();
    _entranceController = TextEditingController();
    _floorController = TextEditingController();
    _apartmentController = TextEditingController();
    _intercomController = TextEditingController();
    _commentController = TextEditingController();
    _date = DateTime.now().add(const Duration(days: 1));
    _time = const TimeOfDay(hour: 11, minute: 0);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _entranceController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _intercomController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CheckoutHeader(service: widget.service),
                        const SizedBox(height: 16),
                        _AddressSection(
                          addressController: _addressController,
                          entranceController: _entranceController,
                          floorController: _floorController,
                          apartmentController: _apartmentController,
                          intercomController: _intercomController,
                          commentController: _commentController,
                        ),
                        const SizedBox(height: 16),
                        _DateTimeSection(
                          date: _date,
                          time: _time,
                          onSelectDate: _pickDate,
                          onSelectTime: _pickTime,
                        ),
                        const SizedBox(height: 16),
                        _OrderDetailsSection(
                          roomLabel: _roomLabel,
                          addOns: _selectedAddOnLabels,
                        ),
                      ],
                    ),
                  ),
                ),
                _CheckoutBar(
                  total: OrderHistoryFormatters.formatPrice(_totalPrice),
                  isLoading: _isSubmitting,
                  errorMessage: _errorMessage,
                  onSubmit: _isSubmitting ? null : _submitOrder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double get _totalPrice => widget.config.calculateTotalPrice(
    area: _area,
    selectedRoomId: widget.selectedRoomId,
    selectedCleaningId: widget.selectedCleaningId,
    selectedAddOns: widget.selectedAddOns,
    fallbackPrice: widget.service.priceFrom ?? _fallbackTotalPrice,
  );

  String? get _roomLabel {
    final roomOptions = widget.config.roomOptions;
    if (roomOptions == null || roomOptions.isEmpty) {
      return null;
    }
    return roomOptions
        .firstWhere(
          (option) => option.id == widget.selectedRoomId,
          orElse: () => roomOptions.first,
        )
        .label;
  }

  List<String> get _selectedAddOnLabels {
    if (widget.config.cleaningOptions == null) {
      return const [];
    }
    return widget.config.cleaningOptions!
        .where(
          (option) =>
              option.isAddon && widget.selectedAddOns.contains(option.id),
        )
        .map((e) => e.label)
        .toList();
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final homeController = context.read<HomeController>();
      final historyController = context.read<OrderHistoryController>();
      homeController.selectNavigationIndex(HomeController.historyTabIndex);
      historyController.loadHistory();
      Navigator.of(context).popUntil((route) => route.isFirst);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Заказ на уборку оформлен успешно!')),
        );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _mapError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _mapError(Object error) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }

    return 'Что-то пошло не так. Попробуйте снова';
  }

  Future<void> _pickDate() async {
    final minimumDate = DateTime.now();
    final maximumDate = DateTime.now().add(const Duration(days: 365));
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      DateTime tempDate = _date;
      final result = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (_) => _CupertinoPickerSheet<DateTime>(
          onSubmitted: () => tempDate,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            initialDateTime: _date,
            onDateTimeChanged: (value) => tempDate = value,
          ),
        ),
      );
      if (result != null) {
        setState(() => _date = result);
      }
      return;
    }

    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: minimumDate,
      lastDate: maximumDate,
    );
    if (result != null) {
      setState(() => _date = result);
    }
  }

  Future<void> _pickTime() async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      final now = DateTime.now();
      DateTime tempTime = DateTime(
        now.year,
        now.month,
        now.day,
        _time.hour,
        _time.minute,
      );
      final result = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (_) => _CupertinoPickerSheet<DateTime>(
          onSubmitted: () => tempTime,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            use24hFormat: true,
            initialDateTime: tempTime,
            onDateTimeChanged: (value) => tempTime = value,
          ),
        ),
      );
      if (result != null) {
        setState(
          () => _time = TimeOfDay(hour: result.hour, minute: result.minute),
        );
      }
      return;
    }

    final result = await showTimePicker(context: context, initialTime: _time);
    if (result != null) {
      setState(() => _time = result);
    }
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.service});

  final CleaningService service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _CheckoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Назад',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Оформление заказа',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Услуга: ${service.title}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Проверьте детали, укажите адрес и удобное время уборки.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.person_outline, label: service.cleaners),
              _InfoChip(icon: Icons.schedule, label: service.duration),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
      ),
      child: child,
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({
    required this.addressController,
    required this.entranceController,
    required this.floorController,
    required this.apartmentController,
    required this.intercomController,
    required this.commentController,
  });

  final TextEditingController addressController;
  final TextEditingController entranceController;
  final TextEditingController floorController;
  final TextEditingController apartmentController;
  final TextEditingController intercomController;
  final TextEditingController commentController;

  @override
  Widget build(BuildContext context) {
    return _CheckoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.location_on_outlined,
            title: 'Адрес',
            subtitle: 'Укажите место, куда должен приехать клинер.',
          ),
          const SizedBox(height: 16),
          _OrderTextField(
            controller: addressController,
            label: 'Улица, дом, корпус',
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OrderTextField(
                  controller: entranceController,
                  label: 'Подъезд',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OrderTextField(
                  controller: floorController,
                  label: 'Этаж',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OrderTextField(
                  controller: apartmentController,
                  label: 'Кв./офис',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OrderTextField(
                  controller: intercomController,
                  label: 'Домофон',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _OrderTextField(
            controller: commentController,
            label: 'Комментарий для клинера',
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            minLines: 3,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _DateTimeSection extends StatelessWidget {
  const _DateTimeSection({
    required this.date,
    required this.time,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  final DateTime date;
  final TimeOfDay time;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  @override
  Widget build(BuildContext context) {
    return _CheckoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.event_available_outlined,
            title: 'Дата и время',
            subtitle: 'Выберите удобное окно для уборки.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DropdownField(
                  label:
                      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                  onTap: onSelectDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DropdownField(
                  label:
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  onTap: onSelectTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsSection extends StatelessWidget {
  const _OrderDetailsSection({required this.roomLabel, required this.addOns});

  final String? roomLabel;
  final List<String> addOns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _CheckoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.receipt_long_outlined,
            title: 'Детали заказа',
            subtitle: 'Параметры, которые вы выбрали в калькуляторе.',
          ),
          const SizedBox(height: 16),
          if (roomLabel != null)
            _OrderInfoRow(label: 'Количество комнат', value: roomLabel!),
          if (addOns.isNotEmpty) ...[
            if (roomLabel != null) const SizedBox(height: 12),
            Text(
              'Дополнительные опции',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                for (int i = 0; i < addOns.length; i++) ...[
                  _SelectedAddOnRow(label: addOns[i]),
                  if (i != addOns.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
          ] else ...[
            if (roomLabel != null) const SizedBox(height: 12),
            Text(
              'Дополнительные опции',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const _EmptyAddOnsRow(),
          ],
          if (roomLabel == null && addOns.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Параметры заказа будут переданы клинеру.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  const _OrderInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBlue),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedAddOnRow extends StatelessWidget {
  const _SelectedAddOnRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBlue),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAddOnsRow extends StatelessWidget {
  const _EmptyAddOnsRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyle.inputRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Не выбраны',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.total,
    required this.onSubmit,
    required this.isLoading,
    this.errorMessage,
  });

  final String total;
  final VoidCallback? onSubmit;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding.bottom;
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + padding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (errorMessage != null) ...[
            Text(
              errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
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
                width: 168,
                height: 48,
                child: CTAButton(
                  label: 'Заказать',
                  isLoading: isLoading,
                  onPressed: onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(AppStyle.inputRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTextField extends StatelessWidget {
  const _OrderTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      minLines: minLines,
      style: theme.textTheme.titleMedium,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyle.inputRadius),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyle.inputRadius),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _CupertinoPickerSheet<T> extends StatelessWidget {
  const _CupertinoPickerSheet({required this.child, required this.onSubmitted});

  final Widget child;
  final T Function() onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 320,
        color: AppColors.surface,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                onPressed: () => Navigator.of(context).pop(onSubmitted()),
                child: const Text(
                  'Готово',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppStyle.inputRadius),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
