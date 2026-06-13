import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import 'cta_button.dart';

class InfoStep extends StatefulWidget {
  const InfoStep({
    super.key,
    required this.controller,
    required this.viewportHeight,
  });

  final AuthController controller;
  final double viewportHeight;

  @override
  State<InfoStep> createState() => _InfoStepState();
}

class _InfoStepState extends State<InfoStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.controller.lastSubmittedName,
    );
    _emailController = TextEditingController(
      text: widget.controller.lastSubmittedEmail,
    );
    _addressController = TextEditingController(
      text: widget.controller.lastSubmittedAddress,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;
    final bool isValid =
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        !controller.isLoading;
    final bool hasFixedHeight =
        widget.viewportHeight.isFinite && widget.viewportHeight > 0;

    final content = Column(
      mainAxisSize: hasFixedHeight ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Завершите регистрацию',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Эл. почта'),
          onChanged: (_) {
            widget.controller.clearError();
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _addressController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Адрес',
            suffixIcon: Icon(Icons.expand_more),
          ),
          onChanged: (_) {
            widget.controller.clearError();
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Имя'),
          onChanged: (_) {
            widget.controller.clearError();
            setState(() {});
          },
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
          label: 'Продолжить',
          isLoading: controller.isLoading,
          onPressed: isValid
              ? () => controller.completeInfoFill(
                  name: _nameController.text,
                  email: _emailController.text,
                  address: _addressController.text,
                )
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
}
