import 'package:flutter/material.dart';
import 'package:klinomania/src/shared/helpers/phone_mask.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import 'cta_button.dart';

class PhoneStep extends StatefulWidget {
  const PhoneStep({
    super.key,
    required this.controller,
    required this.viewportHeight,
  });

  final AuthController controller;
  final double viewportHeight;

  @override
  State<PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<PhoneStep> {
  late final MaskTextInputFormatter _mask;
  late final TextEditingController _phoneController;
  bool _isAgreementChecked = false;

  @override
  void initState() {
    super.initState();
    _mask = MaskTextInputFormatter(
      mask: phoneMask.getMask(),
      type: phoneMask.type,
    );
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;
    final String normalizedPhone = _normalizePhone(_phoneController.text);
    final bool isValid =
        _isAgreementChecked &&
        _isPhoneValid(normalizedPhone) &&
        !controller.isLoading;
    final bool hasFixedHeight =
        widget.viewportHeight.isFinite && widget.viewportHeight > 0;

    final content = Column(
      mainAxisSize: hasFixedHeight ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Введите номер телефона',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [_mask],
          onChanged: (_) {
            widget.controller.clearError();
            setState(() {});
          },
          decoration: const InputDecoration(hintText: '+7'),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () {
            widget.controller.clearError();
            setState(() => _isAgreementChecked = !_isAgreementChecked);
          },
          child: Row(
            children: [
              Checkbox(
                value: _isAgreementChecked,
                onChanged: (value) {
                  widget.controller.clearError();
                  setState(() => _isAgreementChecked = value ?? false);
                },
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'Я ознакомлен(а) и согласен(на) с ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: 'условиями обработки персональных данных',
                        style: TextStyle(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (controller.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            controller.errorMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.danger,
            ),
          ),
        ],
        if (hasFixedHeight) const Spacer() else const SizedBox(height: 24),
        CTAButton(
          label: 'Получить СМС с кодом',
          isLoading: controller.isLoading,
          onPressed: isValid
              ? () => controller.submitPhone(normalizedPhone)
              : null,
        ),
        const SizedBox(height: 8),
      ],
    );

    if (hasFixedHeight) {
      return SizedBox(height: widget.viewportHeight, child: content);
    }

    return content;
  }

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return '';
    }
    var normalized = digits;
    if (normalized.length > 11) {
      normalized = normalized.substring(0, 11);
    }
    if (normalized.length == 11) {
      if (normalized.startsWith('8')) {
        normalized = '7${normalized.substring(1)}';
      } else if (!normalized.startsWith('7')) {
        normalized = '7${normalized.substring(1)}';
      }
    } else if (normalized.length == 10) {
      normalized = '7$normalized';
    }
    return '+$normalized';
  }

  bool _isPhoneValid(String phone) {
    return RegExp(r'^\+7\d{10}$').hasMatch(phone);
  }
}
