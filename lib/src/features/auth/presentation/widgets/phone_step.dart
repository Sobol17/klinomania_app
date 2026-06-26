import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:klinomania/src/shared/helpers/phone_mask.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/pages/profile_info_pages.dart';
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
  bool _isPersonalDataConsentChecked = false;
  bool _isOfferAcceptedChecked = false;

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
        _isPersonalDataConsentChecked &&
        _isOfferAcceptedChecked &&
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
        _AgreementCheckbox(
          value: _isPersonalDataConsentChecked,
          onChanged: (value) {
            widget.controller.clearError();
            setState(() => _isPersonalDataConsentChecked = value);
          },
          parts: const [
            _AgreementTextPart(
              'Я даю согласие на обработку персональных '
              'данных в соответствии с ',
            ),
            _AgreementTextPart(
              'Согласием на обработку персональных данных',
              documentTitle: 'Согласие на обработку персональных данных',
            ),
            _AgreementTextPart(' и '),
            _AgreementTextPart(
              'Политикой в отношении обработки персональных данных',
              documentTitle:
                  'Политика в отношении обработки персональных данных',
            ),
          ],
        ),
        const SizedBox(height: 10),
        _AgreementCheckbox(
          value: _isOfferAcceptedChecked,
          onChanged: (value) {
            widget.controller.clearError();
            setState(() => _isOfferAcceptedChecked = value);
          },
          parts: const [
            _AgreementTextPart('Принимаю условия '),
            _AgreementTextPart(
              'Публичной оферты',
              documentTitle: 'Публичная оферта',
            ),
            _AgreementTextPart(' и подтверждаю оформление Заказа'),
          ],
        ),
        const SizedBox(height: 18),
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

class _AgreementCheckbox extends StatefulWidget {
  const _AgreementCheckbox({
    required this.value,
    required this.onChanged,
    required this.parts,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final List<_AgreementTextPart> parts;

  @override
  State<_AgreementCheckbox> createState() => _AgreementCheckboxState();
}

class _AgreementCheckboxState extends State<_AgreementCheckbox> {
  late final List<TapGestureRecognizer?> _recognizers;

  @override
  void initState() {
    super.initState();
    _recognizers = [
      for (final part in widget.parts)
        part.documentTitle == null
            ? null
            : (TapGestureRecognizer()
                ..onTap = () {
                  ProfileLegalPage.openDocument(context, part.documentTitle!);
                }),
    ];
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      height: 1.35,
    );
    final linkStyle = textStyle?.copyWith(
      color: AppColors.primary,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primary,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Checkbox(
            value: widget.value,
            onChanged: (checked) => widget.onChanged(checked ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text.rich(
              TextSpan(
                children: [
                  for (var index = 0; index < widget.parts.length; index++)
                    TextSpan(
                      text: widget.parts[index].text,
                      style: widget.parts[index].documentTitle == null
                          ? textStyle
                          : linkStyle,
                      recognizer: _recognizers[index],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgreementTextPart {
  const _AgreementTextPart(this.text, {this.documentTitle});

  final String text;
  final String? documentTitle;
}
