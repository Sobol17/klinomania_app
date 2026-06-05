import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  static const List<String> _districtOptions = [
    'Центральный',
    'Северный',
    'Южный',
    'Восточный',
    'Западный',
  ];

  late final TextEditingController _phoneController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(
      text: widget.controller.phoneNumber,
    );
    _nameController = TextEditingController(
      text: widget.controller.lastSubmittedName,
    );
    _emailController = TextEditingController(
      text: widget.controller.lastSubmittedEmail,
    );
    _addressController = TextEditingController(
      text: widget.controller.lastSubmittedAddress,
    );
    _selectedDistrict = widget.controller.lastSubmittedDistrict;
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
        _selectedDistrict != null &&
        _selectedDistrict!.isNotEmpty &&
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
          controller: _phoneController,
          readOnly: true,
          enabled: false,
          decoration: const InputDecoration(labelText: 'Телефон'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Имя'),
          onChanged: (_) {
            widget.controller.clearError();
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
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
        _buildDistrictField(context),
        if (controller.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            controller.errorMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.redAccent,
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
                  district: _selectedDistrict!,
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

  Widget _buildDistrictField(BuildContext context) {
    final platform = Theme.of(context).platform;
    final bool isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    if (isCupertino) {
      return _CupertinoDistrictField(
        value: _selectedDistrict,
        onTap: _openCupertinoDistrictPicker,
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedDistrict,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Район'),
      items: _districtOptions
          .map(
            (district) => DropdownMenuItem<String>(
              value: district,
              child: Text(district),
            ),
          )
          .toList(),
      onChanged: (value) {
        widget.controller.clearError();
        setState(() {
          _selectedDistrict = value;
        });
      },
    );
  }

  void _openCupertinoDistrictPicker() {
    FocusScope.of(context).unfocus();
    final current = _selectedDistrict;
    final initialIndex = current != null
        ? _districtOptions.indexOf(current)
        : 0;
    final resolvedIndex = initialIndex >= 0 ? initialIndex : 0;
    int tempIndex = resolvedIndex;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        final separatorColor = CupertinoColors.separator.resolveFrom(context);
        final controller = FixedExtentScrollController(
          initialItem: resolvedIndex,
        );
        return Container(
          height: 280,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Отмена'),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.controller.clearError();
                          setState(() {
                            _selectedDistrict = _districtOptions[tempIndex];
                          });
                        },
                        child: const Text('Готово'),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: separatorColor),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: controller,
                    itemExtent: 36,
                    onSelectedItemChanged: (index) {
                      tempIndex = index;
                    },
                    children: _districtOptions
                        .map((district) => Center(child: Text(district)))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CupertinoDistrictField extends StatelessWidget {
  const _CupertinoDistrictField({required this.value, required this.onTap});

  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasValue = value != null && value!.isNotEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Район',
          suffixIcon: Icon(Icons.expand_more),
        ),
        isEmpty: !hasValue,
        child: Text(
          hasValue ? value! : 'Выберите район',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: hasValue
                ? theme.textTheme.bodyMedium?.color
                : Colors.black54,
          ),
        ),
      ),
    );
  }
}
