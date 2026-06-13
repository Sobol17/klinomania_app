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
  late String _paymentMethod;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _paymentMethods = const ['СБП', 'ПОДЕЛИ', 'плати', 'Нал'];
  static const double _fallbackTotalPrice = 7500;
  @override
  void initState() {
    super.initState();
    _area = widget.area;
    _addressController = TextEditingController(
      text: 'Кутузовский проспект, 23к2',
    );
    _entranceController = TextEditingController(text: '1');
    _floorController = TextEditingController(text: '14');
    _apartmentController = TextEditingController(text: '44');
    _intercomController = TextEditingController(text: '44');
    _commentController = TextEditingController();
    _date = DateTime.now().add(const Duration(days: 1));
    _time = const TimeOfDay(hour: 11, minute: 0);
    _paymentMethod = _paymentMethods.first;
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
                const _BackNav(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ServiceSummary(service: widget.service),
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
                          area: _area,
                          onEditArea: _openAreaEdit,
                          cleaningLabel: _cleaningLabel,
                          addOns: _selectedAddOnLabels,
                        ),
                        const SizedBox(height: 16),
                        _PaymentSection(
                          paymentMethods: _paymentMethods,
                          selected: _paymentMethod,
                          onSelect: (value) =>
                              setState(() => _paymentMethod = value),
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

  String get _cleaningLabel {
    if (widget.config.cleaningOptions == null) {
      return 'Поддерживающая';
    }
    return widget.config.cleaningOptions!
        .firstWhere(
          (option) => option.id == widget.selectedCleaningId,
          orElse: () => widget.config.cleaningOptions!.first,
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

  Future<void> _openAreaEdit() async {
    final newArea = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppStyle.cardRadius),
        ),
      ),
      builder: (context) => _AreaEditSheet(initialArea: _area),
    );
    if (!mounted || newArea == null) {
      return;
    }
    setState(() => _area = newArea);
  }
}

class _BackNav extends StatelessWidget {
  const _BackNav();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Назад',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceSummary extends StatelessWidget {
  const _ServiceSummary({required this.service});

  final CleaningService service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Адрес:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _OrderTextField(
          controller: addressController,
          label: 'Улица',
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Выберите дату и время:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
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
    );
  }
}

class _OrderDetailsSection extends StatelessWidget {
  const _OrderDetailsSection({
    required this.area,
    required this.onEditArea,
    required this.cleaningLabel,
    required this.addOns,
  });

  final double area;
  final VoidCallback onEditArea;
  final String cleaningLabel;
  final List<String> addOns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final areaLabel = area.truncateToDouble() == area
        ? area.toStringAsFixed(0)
        : area.toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Детали заказа:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _EditableTile(
          label: 'Площадь',
          value: '$areaLabel м²',
          onTap: onEditArea,
        ),
        const SizedBox(height: 12),
        _SelectionChip(label: cleaningLabel, selected: true),
        const SizedBox(height: 12),
        if (addOns.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: addOns
                .map((label) => _SelectionChip(label: label, selected: true))
                .toList(),
          )
        else
          _SelectionChip(label: '+ Мойка окон', selected: false),
      ],
    );
  }
}

class _AreaEditSheet extends StatefulWidget {
  const _AreaEditSheet({required this.initialArea});

  final double initialArea;

  @override
  State<_AreaEditSheet> createState() => _AreaEditSheetState();
}

class _AreaEditSheetState extends State<_AreaEditSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialArea;
    final formatted = initial.truncateToDouble() == initial
        ? initial.toStringAsFixed(0)
        : initial.toStringAsFixed(1);
    _controller = TextEditingController(text: formatted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final sanitized = _controller.text.replaceAll(',', '.');
    final value = double.tryParse(sanitized);
    if (value != null && value > 0) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: padding + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(
            'Изменить площадь',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _OrderTextField(
            controller: _controller,
            label: 'Площадь (м²)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          CTAButton(label: 'Сохранить', onPressed: _submit),
        ],
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.paymentMethods,
    required this.selected,
    required this.onSelect,
  });

  final List<String> paymentMethods;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Способ оплаты:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: paymentMethods.map((method) {
              final active = method == selected;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => onSelect(method),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppColors.softBlue : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppStyle.inputRadius),
                      border: Border.all(
                        color: active ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (active)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        Text(
                          method,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Итоговая стоимость:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                total,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CTAButton(
            label: 'Заказать уборку',
            isLoading: isLoading,
            onPressed: onSubmit,
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

class _EditableTile extends StatelessWidget {
  const _EditableTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppStyle.inputRadius),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SelectionChip extends StatelessWidget {
  const _SelectionChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.softBlue : AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyle.inputRadius),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
