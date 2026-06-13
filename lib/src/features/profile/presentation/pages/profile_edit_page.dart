import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/cta_button.dart';
import '../../domain/entities/client_profile.dart';
import '../controllers/profile_controller.dart';

BoxDecoration _editSectionDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(18),
  );
}

Color _editTileColor() {
  return AppColors.primary.withValues(alpha: 0.05);
}

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String? _profileId;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        _fill(controller.profile);

        return Scaffold(
          backgroundColor: AppColors.disabled,
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                const _EditBackButton(),
                const SizedBox(height: 16),
                _EditHeader(controller: controller),
                const SizedBox(height: 16),
                _EditForm(
                  nameController: _nameController,
                  emailController: _emailController,
                  addressController: _addressController,
                ),
                if (controller.updateError != null) ...[
                  const SizedBox(height: 12),
                  _EditErrorMessage(message: controller.updateError!),
                ],
                const SizedBox(height: 20),
                CTAButton(
                  label: 'Сохранить',
                  isLoading: controller.isSaving,
                  onPressed: controller.isSaving
                      ? null
                      : () => _save(context, controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _fill(ClientProfile? profile) {
    if (profile == null || _profileId == profile.id) return;
    _profileId = profile.id;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _addressController.text = profile.address;
  }

  Future<void> _save(BuildContext context, ProfileController controller) async {
    FocusScope.of(context).unfocus();
    final success = await controller.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
    );
    if (!context.mounted || !success) return;
    Navigator.of(context).maybePop();
  }
}

class _EditBackButton extends StatelessWidget {
  const _EditBackButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(AppStyle.inputRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Назад',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditHeader extends StatelessWidget {
  const _EditHeader({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phone = controller.profile?.phone;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _editSectionDecoration(),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: _editTileColor(),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Личные данные',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'LovelaceText',
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                if (phone != null && phone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({
    required this.nameController,
    required this.emailController,
    required this.addressController,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController addressController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _editSectionDecoration(),
      child: Column(
        children: [
          _EditTextField(
            controller: nameController,
            label: 'Имя',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _EditTextField(
            controller: emailController,
            label: 'Эл. почта',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _EditTextField(
            controller: addressController,
            label: 'Адрес',
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}

class _EditTextField extends StatelessWidget {
  const _EditTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _EditErrorMessage extends StatelessWidget {
  const _EditErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: _editSectionDecoration(),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
