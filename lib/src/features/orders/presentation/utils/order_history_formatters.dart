import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_history_entry.dart';

class OrderHistoryFormatters {
  const OrderHistoryFormatters._();

  static String formatNumericDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  static String formatShortDayMonth(DateTime date) {
    return '${date.day} ${_shortMonths[date.month - 1]}';
  }

  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatFullDateTime(DateTime date) {
    final weekday = _weekdays[date.weekday - 1];
    final datePart = formatNumericDate(date);
    return '$weekday, $datePart в ${formatTime(date)}';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final parts = <String>[];
    if (hours > 0) {
      parts.add('$hours ч');
    }
    if (minutes > 0) {
      parts.add('$minutes мин');
    }
    if (parts.isEmpty) {
      return 'Менее минуты';
    }
    return parts.join(' ');
  }

  static String formatPrice(double value) {
    final amount = value.round();
    final digits = amount.toString();
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

  static const List<String> _shortMonths = <String>[
    'янв.',
    'февр.',
    'мар.',
    'апр.',
    'мая',
    'июн.',
    'июл.',
    'авг.',
    'сен.',
    'окт.',
    'нояб.',
    'дек.',
  ];

  static const List<String> _weekdays = <String>[
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];
}

extension OrderHistoryStatusStyle on OrderHistoryStatus {
  String get label {
    switch (this) {
      case OrderHistoryStatus.awaitingCleaner:
        return 'Ожидает клинера';
      case OrderHistoryStatus.inProgress:
        return 'В процессе';
      case OrderHistoryStatus.completed:
        return 'Завершен';
      case OrderHistoryStatus.cancelled:
        return 'Отменен';
    }
  }

  Color get color {
    switch (this) {
      case OrderHistoryStatus.awaitingCleaner:
        return AppColors.primary;
      case OrderHistoryStatus.inProgress:
        return AppColors.primary;
      case OrderHistoryStatus.completed:
        return AppColors.success;
      case OrderHistoryStatus.cancelled:
        return AppColors.danger;
    }
  }
}
