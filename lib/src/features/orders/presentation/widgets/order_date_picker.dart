import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OrderDatePicker extends StatefulWidget {
  const OrderDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<OrderDatePicker> createState() => _OrderDatePickerState();
}

class _OrderDatePickerState extends State<OrderDatePicker> {
  late DateTime _selectedDate;
  late DateTime _visibleMonth;

  static const List<String> _monthNames = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];

  static const List<String> _weekdays = [
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
    'Вс',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = _clampDate(_dateOnly(widget.initialDate));
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(18, 14, 18, 18 + bottomPadding),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: _SheetHandle()),
            const SizedBox(height: 18),
            _PickerHeader(
              visibleMonth: _visibleMonth,
              monthLabel: _monthLabel,
              canGoBack: _canGoToPreviousMonth,
              canGoForward: _canGoToNextMonth,
              onPrevious: () => _changeMonth(-1),
              onNext: () => _changeMonth(1),
            ),
            const SizedBox(height: 18),
            const _WeekdayRow(weekdays: _weekdays),
            const SizedBox(height: 8),
            _CalendarGrid(
              visibleMonth: _visibleMonth,
              selectedDate: _selectedDate,
              firstDate: _dateOnly(widget.firstDate),
              lastDate: _dateOnly(widget.lastDate),
              onDateSelected: (date) => setState(() => _selectedDate = date),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _DatePickerButton(
                    label: 'Отмена',
                    onPressed: () => Navigator.of(context).pop(),
                    variant: _DatePickerButtonVariant.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerButton(
                    label: 'Готово',
                    onPressed: () => Navigator.of(context).pop(_selectedDate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _monthLabel {
    return '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}';
  }

  bool get _canGoToPreviousMonth {
    final previousMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    final firstMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    return !previousMonth.isBefore(firstMonth);
  }

  bool get _canGoToNextMonth {
    final nextMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    return !nextMonth.isAfter(lastMonth);
  }

  void _changeMonth(int offset) {
    final nextMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + offset,
    );
    final firstMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);

    if (nextMonth.isBefore(firstMonth) || nextMonth.isAfter(lastMonth)) {
      return;
    }

    setState(() => _visibleMonth = nextMonth);
  }

  DateTime _clampDate(DateTime date) {
    final firstDate = _dateOnly(widget.firstDate);
    final lastDate = _dateOnly(widget.lastDate);

    if (date.isBefore(firstDate)) {
      return firstDate;
    }
    if (date.isAfter(lastDate)) {
      return lastDate;
    }
    return date;
  }
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({
    required this.visibleMonth,
    required this.monthLabel,
    required this.canGoBack,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime visibleMonth;
  final String monthLabel;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            monthLabel,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _MonthButton(
          icon: Icons.chevron_left_rounded,
          enabled: canGoBack,
          onPressed: onPrevious,
        ),
        const SizedBox(width: 8),
        _MonthButton(
          icon: Icons.chevron_right_rounded,
          enabled: canGoForward,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
      ),
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow({required this.weekdays});

  final List<String> weekdays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        for (final weekday in weekdays)
          Expanded(
            child: Center(
              child: Text(
                weekday,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.visibleMonth,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final days = _monthGridDays(visibleMonth);

    return Container(
      decoration: BoxDecoration(color: AppColors.surface),
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(6),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: days.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          mainAxisExtent: 44,
        ),
        itemBuilder: (context, index) {
          final date = days[index];
          final isCurrentMonth = date.month == visibleMonth.month;
          final isSelected = _isSameDate(date, selectedDate);
          final isEnabled =
              isCurrentMonth &&
              !date.isBefore(firstDate) &&
              !date.isAfter(lastDate);

          return _CalendarDayButton(
            date: date,
            isCurrentMonth: isCurrentMonth,
            isSelected: isSelected,
            isEnabled: isEnabled,
            onPressed: () => onDateSelected(date),
          );
        },
      ),
    );
  }

  List<DateTime> _monthGridDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month);
    final leadingDays = firstDay.weekday - 1;
    final firstGridDay = firstDay.subtract(Duration(days: leadingDays));

    return List.generate(42, (index) {
      return firstGridDay.add(Duration(days: index));
    });
  }
}

class _CalendarDayButton extends StatelessWidget {
  const _CalendarDayButton({
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isEnabled,
    required this.onPressed,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = isSelected
        ? AppColors.white
        : isEnabled
        ? AppColors.textPrimary
        : AppColors.muted;

    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(isSelected ? 14 : 12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isCurrentMonth
                ? AppColors.softBlue
                : Colors.transparent,
          ),
        ),
        child: Text(
          '${date.day}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: foregroundColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

enum _DatePickerButtonVariant { primary, secondary }

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({
    required this.label,
    required this.onPressed,
    this.variant = _DatePickerButtonVariant.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final _DatePickerButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrimary = variant == _DatePickerButtonVariant.primary;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isPrimary ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
