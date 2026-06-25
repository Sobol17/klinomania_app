import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_navigation_bar.dart';
import '../../../auth/presentation/widgets/cta_button.dart';
import '../../../home/domain/entities/cleaning_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../../../services/domain/service_detail_config.dart';
import '../controllers/order_history_controller.dart';
import '../../domain/entities/address_suggestion.dart';
import '../../domain/use_cases/fetch_address_suggestions.dart';
import '../utils/order_history_formatters.dart';
import '../widgets/order_date_picker.dart';

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
  late final TextEditingController _timeController;
  late final MaskTextInputFormatter _timeMask;
  Timer? _suggestDebounce;
  late DateTime _date;
  late TimeOfDay _time;
  List<AddressSuggestion> _addressSuggestions = const [];
  AddressSuggestion? _selectedAddressSuggestion;
  bool _isSubmitting = false;
  bool _isSuggestLoading = false;
  String? _errorMessage;
  bool _timeInputHasError = false;
  int _suggestRequestId = 0;

  static const double _fallbackTotalPrice = 7500;
  static const Duration _suggestDebounceDuration = Duration(milliseconds: 350);

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
    _timeMask = MaskTextInputFormatter(
      mask: '##:##',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
    _date = DateTime.now().add(const Duration(days: 1));
    _time = const TimeOfDay(hour: 11, minute: 0);
    _timeController = TextEditingController(text: _formatTime(_time));
  }

  @override
  void dispose() {
    _suggestDebounce?.cancel();
    _addressController.dispose();
    _entranceController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _intercomController.dispose();
    _commentController.dispose();
    _timeController.dispose();
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
                          suggestions: _addressSuggestions,
                          isSuggestLoading: _isSuggestLoading,
                          hasSelectedAddressSuggestion:
                              _hasSelectedAddressSuggestion,
                          onAddressChanged: _handleAddressChanged,
                          onSuggestionSelected: _selectAddressSuggestion,
                        ),
                        const SizedBox(height: 16),
                        _DateTimeSection(
                          date: _date,
                          timeController: _timeController,
                          timeFormatter: _timeMask,
                          timeInputHasError: _timeInputHasError,
                          onSelectDate: _pickDate,
                          onTimeChanged: _handleTimeChanged,
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
                  onSubmit: _isSubmitting || !_hasSelectedAddressSuggestion
                      ? null
                      : _submitOrder,
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

  bool get _hasSelectedAddressSuggestion {
    final suggestion = _selectedAddressSuggestion;
    if (suggestion == null) {
      return false;
    }
    return _addressController.text.trim() == suggestion.address.trim();
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) {
      return;
    }

    if (!_hasSelectedAddressSuggestion) {
      return;
    }

    final parsedTime = _parseTime(_timeController.text);
    if (parsedTime == null) {
      setState(() {
        _timeInputHasError = true;
        _errorMessage = 'Укажите время в формате 00:00-23:59';
      });
      return;
    }

    setState(() {
      _time = parsedTime;
      _isSubmitting = true;
      _errorMessage = null;
      _timeInputHasError = false;
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

  void _handleAddressChanged(String value) {
    _suggestDebounce?.cancel();
    final query = value.trim();
    final requestId = ++_suggestRequestId;

    setState(() {
      _selectedAddressSuggestion = null;
      _addressSuggestions = const [];
      _isSuggestLoading = false;
    });

    if (query.length < 3) {
      return;
    }

    _suggestDebounce = Timer(
      _suggestDebounceDuration,
      () => _loadAddressSuggestions(query, requestId),
    );
  }

  Future<void> _loadAddressSuggestions(String query, int requestId) async {
    if (!mounted || requestId != _suggestRequestId) {
      return;
    }

    setState(() => _isSuggestLoading = true);

    try {
      final suggestions = await context
          .read<FetchAddressSuggestionsUseCase>()
          .call(query);
      if (!mounted || requestId != _suggestRequestId) {
        return;
      }
      setState(() {
        _addressSuggestions = suggestions;
        _isSuggestLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _suggestRequestId) {
        return;
      }
      setState(() {
        _addressSuggestions = const [];
        _isSuggestLoading = false;
      });
    }
  }

  void _selectAddressSuggestion(AddressSuggestion suggestion) {
    _suggestDebounce?.cancel();
    _suggestRequestId++;
    _addressController.text = suggestion.address.trim();
    setState(() {
      _selectedAddressSuggestion = suggestion;
      _addressSuggestions = const [];
      _isSuggestLoading = false;
    });
    FocusScope.of(context).unfocus();
  }

  String _mapError(Object error) {
    if (error is StateError && error.message.isNotEmpty) {
      return error.message;
    }

    return 'Что-то пошло не так. Попробуйте снова';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final minimumDate = DateTime(now.year, now.month, now.day);
    final maximumDate = minimumDate.add(const Duration(days: 365));
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => OrderDatePicker(
        initialDate: _date,
        firstDate: minimumDate,
        lastDate: maximumDate,
      ),
    );
    if (result != null) {
      setState(() => _date = result);
    }
  }

  void _handleTimeChanged(String value) {
    final parsedTime = _parseTime(value);
    setState(() {
      _timeInputHasError = value.length == 5 && parsedTime == null;
      if (parsedTime != null) {
        _time = parsedTime;
      }
      if (_errorMessage == 'Укажите время в формате 00:00-23:59' &&
          parsedTime != null) {
        _errorMessage = null;
      }
    });
  }

  TimeOfDay? _parseTime(String value) {
    if (value.length != 5) {
      return null;
    }

    final parts = value.split(':');
    if (parts.length != 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
    required this.suggestions,
    required this.isSuggestLoading,
    required this.hasSelectedAddressSuggestion,
    required this.onAddressChanged,
    required this.onSuggestionSelected,
  });

  final TextEditingController addressController;
  final TextEditingController entranceController;
  final TextEditingController floorController;
  final TextEditingController apartmentController;
  final TextEditingController intercomController;
  final TextEditingController commentController;
  final List<AddressSuggestion> suggestions;
  final bool isSuggestLoading;
  final bool hasSelectedAddressSuggestion;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<AddressSuggestion> onSuggestionSelected;

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
          _AddressSuggestField(
            controller: addressController,
            suggestions: suggestions,
            isLoading: isSuggestLoading,
            hasSelectedAddressSuggestion: hasSelectedAddressSuggestion,
            onChanged: onAddressChanged,
            onSuggestionSelected: onSuggestionSelected,
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
    required this.timeController,
    required this.timeFormatter,
    required this.timeInputHasError,
    required this.onSelectDate,
    required this.onTimeChanged,
  });

  final DateTime date;
  final TextEditingController timeController;
  final TextInputFormatter timeFormatter;
  final bool timeInputHasError;
  final VoidCallback onSelectDate;
  final ValueChanged<String> onTimeChanged;

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
                child: _TimeInputField(
                  controller: timeController,
                  inputFormatter: timeFormatter,
                  hasError: timeInputHasError,
                  onChanged: onTimeChanged,
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

class _AddressSuggestField extends StatelessWidget {
  const _AddressSuggestField({
    required this.controller,
    required this.suggestions,
    required this.isLoading,
    required this.hasSelectedAddressSuggestion,
    required this.onChanged,
    required this.onSuggestionSelected,
  });

  static const double _fieldHeight = 56;
  static const double _dropdownGap = 8;
  static const double _loadingHeight = 46;
  static const double _itemHeight = 65;
  static const double _maxDropdownHeight = 236;

  final TextEditingController controller;
  final List<AddressSuggestion> suggestions;
  final bool isLoading;
  final bool hasSelectedAddressSuggestion;
  final ValueChanged<String> onChanged;
  final ValueChanged<AddressSuggestion> onSuggestionSelected;

  bool get _showsDropdown => isLoading || suggestions.isNotEmpty;

  double get _dropdownHeight {
    if (isLoading) {
      return _loadingHeight;
    }
    final height = suggestions.length * _itemHeight;
    return height.clamp(0, _maxDropdownHeight).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownHeight = _showsDropdown ? _dropdownHeight : 0.0;

    return SizedBox(
      height:
          _fieldHeight + (_showsDropdown ? _dropdownGap + dropdownHeight : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _OrderTextField(
            controller: controller,
            label: 'Улица, дом, корпус',
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            onChanged: onChanged,
            suffixIcon: hasSelectedAddressSuggestion
                ? const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                  )
                : null,
          ),
          if (_showsDropdown)
            Positioned(
              top: _fieldHeight + _dropdownGap,
              left: 0,
              right: 0,
              child: _AddressSuggestResults(
                height: dropdownHeight,
                suggestions: suggestions,
                isLoading: isLoading,
                onSuggestionSelected: onSuggestionSelected,
              ),
            ),
        ],
      ),
    );
  }
}

class _AddressSuggestResults extends StatelessWidget {
  const _AddressSuggestResults({
    required this.height,
    required this.suggestions,
    required this.isLoading,
    required this.onSuggestionSelected,
  });

  final double height;
  final List<AddressSuggestion> suggestions;
  final bool isLoading;
  final ValueChanged<AddressSuggestion> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Material(
        color: AppColors.surface,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppStyle.inputRadius),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppStyle.inputRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: isLoading
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Ищем адрес',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: suggestions.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return _AddressSuggestionTile(
                      suggestion: suggestion,
                      onTap: () => onSuggestionSelected(suggestion),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _AddressSuggestionTile extends StatelessWidget {
  const _AddressSuggestionTile({required this.suggestion, required this.onTap});

  final AddressSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = suggestion.subtitle.trim();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyle.inputRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title.isNotEmpty
                        ? suggestion.title
                        : suggestion.address,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
    this.onChanged,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int minLines;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
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
        suffixIcon: suffixIcon,
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

class _TimeInputField extends StatelessWidget {
  const _TimeInputField({
    required this.controller,
    required this.inputFormatter,
    required this.hasError,
    required this.onChanged,
  });

  final TextEditingController controller;
  final TextInputFormatter inputFormatter;
  final bool hasError;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [inputFormatter],
      onChanged: onChanged,
      style: theme.textTheme.titleMedium,
      decoration: InputDecoration(
        hintText: '00:00',
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyle.inputRadius),
          borderSide: BorderSide(
            color: hasError ? AppColors.danger : AppColors.fieldBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyle.inputRadius),
          borderSide: BorderSide(
            color: hasError ? AppColors.danger : AppColors.primary,
          ),
        ),
        suffixIcon: const Icon(
          Icons.schedule_outlined,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
