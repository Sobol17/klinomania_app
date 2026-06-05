import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import 'otp_code_input.dart';

class OtpStep extends StatefulWidget {
  const OtpStep({super.key, required this.controller});

  final AuthController controller;

  @override
  State<OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<OtpStep> {
  bool _autoSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Код из СМС',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Отправлен на номер ${controller.phoneNumber}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black.withAlpha((0.6 * 255).round()),
          ),
        ),
        const SizedBox(height: 28),
        OtpCodeInput(
          length: 4,
          enabled: !controller.isLoading,
          onChanged: _handleCodeChanged,
        ),
        const SizedBox(height: 42),
        Column(
          children: [
            Text('Не получили код?', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: controller.isLoading ? null : controller.requestSmsCode,
              child: Text(
                'Отправить снова',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (controller.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            controller.errorMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.redAccent,
            ),
          ),
        ],
      ],
    );
  }

  void _handleCodeChanged(String value) {
    widget.controller.clearError();
    if (value.length == 4 && !_autoSubmitting && !widget.controller.isLoading) {
      _autoSubmitting = true;
      widget.controller.submitCode(value).whenComplete(() {
        if (mounted) {
          setState(() {
            _autoSubmitting = false;
          });
        } else {
          _autoSubmitting = false;
        }
      });
    }
  }
}
