import 'package:flutter/material.dart';
import 'package:klinomania/src/shared/helpers/phone_mask.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import 'cta_button.dart';

class CleanerLoginStep extends StatefulWidget {
  const CleanerLoginStep({
    super.key,
    required this.controller,
    required this.viewportHeight,
  });

  final AuthController controller;
  final double viewportHeight;

  @override
  State<CleanerLoginStep> createState() => _CleanerLoginStepState();
}

class _CleanerLoginStepState extends State<CleanerLoginStep> {
  late final MaskTextInputFormatter _mask;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  bool _isPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    _mask = MaskTextInputFormatter(
      mask: phoneMask.getMask(),
      type: phoneMask.type,
    );
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;
    final normalizedPhone = _normalizePhone(_phoneController.text);
    final isValid =
        _isPhoneValid(normalizedPhone) &&
        _passwordController.text.trim().isNotEmpty &&
        !controller.isLoading;
    final hasFixedHeight =
        widget.viewportHeight.isFinite && widget.viewportHeight > 0;

    final content = Column(
      mainAxisSize: hasFixedHeight ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Вход для клинера',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Введите номер телефона и пароль',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [_mask],
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            controller.clearError();
            setState(() {});
          },
          decoration: const InputDecoration(
            labelText: 'Телефон',
            hintText: '+7',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: _isPasswordHidden,
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            controller.clearError();
            setState(() {});
          },
          onSubmitted: (_) {
            if (isValid) {
              _submit(normalizedPhone);
            }
          },
          decoration: InputDecoration(
            labelText: 'Пароль',
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _isPasswordHidden = !_isPasswordHidden);
              },
              icon: Icon(
                _isPasswordHidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
            ),
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
          label: 'Войти',
          isLoading: controller.isLoading,
          onPressed: isValid ? () => _submit(normalizedPhone) : null,
        ),
        const SizedBox(height: 8),
      ],
    );

    if (hasFixedHeight) {
      return SizedBox(height: widget.viewportHeight, child: content);
    }

    return content;
  }

  void _submit(String normalizedPhone) {
    widget.controller.submitCleanerCredentials(
      phone: normalizedPhone,
      password: _passwordController.text,
    );
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
