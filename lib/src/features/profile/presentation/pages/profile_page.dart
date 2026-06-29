import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/auth_session.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/widgets/cta_button.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../../domain/entities/profile_info_field.dart';
import '../../domain/entities/profile_menu_item.dart';
import '../controllers/profile_controller.dart';
import 'profile_edit_page.dart';
import 'profile_info_pages.dart';

BoxDecoration _profileBlockDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppStyle.inputRadius),
    border: Border.all(color: AppColors.fieldBorder),
  );
}

BoxDecoration _profileSectionDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppStyle.cardRadius),
  );
}

Color _profileTileColor() {
  return AppColors.softBlue;
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (auth.role == UserRole.cleaner) {
          return Consumer<ProfileController>(
            builder: (context, controller, _) {
              return _CleanerProfileView(
                controller: controller,
                onLogout: auth.logout,
              );
            },
          );
        }
        return Consumer<ProfileController>(
          builder: (context, controller, _) {
            return _ClientProfileView(
              controller: controller,
              onLogout: auth.logout,
            );
          },
        );
      },
    );
  }
}

void _showEditFieldSheet(
  BuildContext context,
  ProfileController controller,
  ProfileInfoField field,
) {
  controller.clearUpdateError();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppStyle.cardRadius),
      ),
    ),
    builder: (_) => _EditProfileFieldSheet(field: field),
  );
}

class _EditProfileFieldSheet extends StatefulWidget {
  const _EditProfileFieldSheet({required this.field});

  final ProfileInfoField field;

  @override
  State<_EditProfileFieldSheet> createState() => _EditProfileFieldSheetState();
}

class _EditProfileFieldSheetState extends State<_EditProfileFieldSheet> {
  TextEditingController? _textController;

  bool get _isDescription =>
      widget.field.type == ProfileInfoFieldType.description;

  @override
  void initState() {
    super.initState();
    final normalized = _normalizeValue(widget.field.value);
    _textController = TextEditingController(text: normalized);
  }

  @override
  void dispose() {
    _textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          final isSaving = controller.isSaving;
          final canSubmit = _canSubmit && !isSaving;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Редактировать ${widget.field.label.toLowerCase()}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textController,
                keyboardType: _isDescription
                    ? TextInputType.multiline
                    : _keyboardTypeFor(widget.field.type),
                textInputAction: _isDescription
                    ? TextInputAction.newline
                    : TextInputAction.done,
                minLines: _isDescription ? 4 : 1,
                maxLines: _isDescription ? 6 : 1,
                decoration: InputDecoration(labelText: widget.field.label),
                onChanged: (_) {
                  controller.clearUpdateError();
                  setState(() {});
                },
              ),
              if (controller.updateError != null) ...[
                const SizedBox(height: 12),
                Text(
                  controller.updateError!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              CTAButton(
                label: 'Сохранить',
                isLoading: isSaving,
                onPressed: canSubmit
                    ? () async {
                        final success = await controller.updateProfile(
                          name: widget.field.type == ProfileInfoFieldType.name
                              ? _currentValue
                              : null,
                          email: widget.field.type == ProfileInfoFieldType.email
                              ? _currentValue
                              : null,
                          address:
                              widget.field.type == ProfileInfoFieldType.address
                              ? _currentValue
                              : null,
                          description:
                              widget.field.type ==
                                  ProfileInfoFieldType.description
                              ? _currentValue
                              : null,
                        );
                        if (!mounted) return;
                        if (!context.mounted) return;
                        if (success) {
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  bool get _canSubmit {
    final value = _currentValue.trim();
    return value.isNotEmpty;
  }

  String get _currentValue {
    return _textController?.text ?? '';
  }

  static String _normalizeValue(String value) {
    if (value == '-') {
      return '';
    }
    return value;
  }

  static TextInputType _keyboardTypeFor(ProfileInfoFieldType type) {
    switch (type) {
      case ProfileInfoFieldType.email:
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }
}

class _ClientProfileView extends StatefulWidget {
  const _ClientProfileView({required this.controller, required this.onLogout});

  final ProfileController controller;
  final VoidCallback onLogout;

  @override
  State<_ClientProfileView> createState() => _ClientProfileViewState();
}

class _ClientProfileViewState extends State<_ClientProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.ensureLoaded();
    });
  }

  @override
  void didUpdateWidget(covariant _ClientProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.ensureLoaded();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final theme = Theme.of(context);
    final profile = controller.profile;
    final name = _valueOrDefault(profile?.name, 'Профиль');
    final phone = _valueOrDefault(profile?.phone, '');
    final email = _valueOrDefault(profile?.email, '');

    return Stack(
      children: [
        const Positioned.fill(child: HomeBackground()),
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileSummaryCard(name: name, phone: phone, email: email),
                const SizedBox(height: 18),
                if (controller.isLoading && controller.profile == null)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (controller.loadError != null) ...[
                  Text(
                    controller.loadError!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _ProfileMenuGroup(
                  items: controller.primaryMenuItems,
                  onItemTap: (item) => _handleMenuItem(context, item),
                ),
                const SizedBox(height: 16),
                _ProfileMenuGroup(
                  items: controller.supportMenuItems,
                  onItemTap: (item) => _handleMenuItem(context, item),
                ),
                const SizedBox(height: 16),
                _ProfileDangerSection(
                  item: controller.deleteMenuItem,
                  onTap: () =>
                      _handleMenuItem(context, controller.deleteMenuItem),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _valueOrDefault(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }
    return value;
  }

  void _handleMenuItem(BuildContext context, ProfileMenuItem item) {
    switch (item.action) {
      case ProfileMenuAction.personalData:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProfileEditPage()),
        );
        return;
      case ProfileMenuAction.settings:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProfileSettingsPage()),
        );
        return;
      case ProfileMenuAction.history:
        context.read<HomeController>().selectNavigationIndex(1);
        return;
      case ProfileMenuAction.contacts:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProfileContactsPage()),
        );
        return;
      case ProfileMenuAction.legal:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProfileLegalPage()),
        );
        return;
      case ProfileMenuAction.logout:
        widget.onLogout();
        return;
      case ProfileMenuAction.delete:
        widget.controller.onMenuItemSelected(item.action);
        return;
    }
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.name,
    required this.phone,
    required this.email,
    this.subtitle,
  });

  final String name;
  final String phone;
  final String email;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _profileSectionDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: _profileTileColor(),
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
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (phone.isNotEmpty) ...[
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
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
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

class _ProfileMenuGroup extends StatelessWidget {
  const _ProfileMenuGroup({required this.items, required this.onItemTap});

  final List<ProfileMenuItem> items;
  final ValueChanged<ProfileMenuItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _profileSectionDecoration(),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _ProfileMenuRow(
              item: items[index],
              onTap: () => onItemTap(items[index]),
            ),
            if (index != items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({required this.item, required this.onTap});

  final ProfileMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasChevron = _hasChevron(item.action);
    final textColor = item.isDestructive
        ? AppColors.danger
        : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyle.inputRadius),
      child: Container(
        constraints: const BoxConstraints(minHeight: 68),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: item.isDestructive ? AppColors.surface : AppColors.bgBlue,
          borderRadius: BorderRadius.circular(AppStyle.inputRadius),
        ),
        child: Row(
          children: [
            if (item.action == ProfileMenuAction.logout) ...[
              Icon(Icons.logout, color: textColor, size: 22),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                item.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (hasChevron)
              Icon(
                Icons.chevron_right,
                color: AppColors.primary.withValues(alpha: 0.48),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  bool _hasChevron(ProfileMenuAction action) {
    switch (action) {
      case ProfileMenuAction.personalData:
      case ProfileMenuAction.settings:
      case ProfileMenuAction.history:
      case ProfileMenuAction.contacts:
      case ProfileMenuAction.legal:
        return true;
      case ProfileMenuAction.logout:
      case ProfileMenuAction.delete:
        return false;
    }
  }
}

class _ProfileDangerSection extends StatelessWidget {
  const _ProfileDangerSection({required this.item, required this.onTap});

  final ProfileMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _profileSectionDecoration(),
      child: _ProfileMenuRow(item: item, onTap: onTap),
    );
  }
}

class _CleanerProfileView extends StatefulWidget {
  const _CleanerProfileView({required this.controller, required this.onLogout});

  final ProfileController controller;
  final VoidCallback onLogout;

  @override
  State<_CleanerProfileView> createState() => _CleanerProfileViewState();
}

class _CleanerProfileViewState extends State<_CleanerProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.ensureLoaded();
    });
  }

  @override
  void didUpdateWidget(covariant _CleanerProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.ensureLoaded();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = widget.controller.profile;
    final name = _valueOrDefault(profile?.name, 'Профиль');
    final description = _valueOrDash(profile?.description);
    final phone = _valueOrDash(profile?.phone);
    final email = _valueOrDash(profile?.email);

    return Stack(
      children: [
        const Positioned.fill(child: HomeBackground()),
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileSummaryCard(
                  name: name,
                  phone: '',
                  email: '',
                  subtitle: 'Команда Klinomania',
                ),
                const SizedBox(height: 18),
                if (widget.controller.isLoading && profile == null)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (widget.controller.loadError != null) ...[
                  Text(
                    widget.controller.loadError!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _CleanerInfoGroup(
                  children: [
                    _CleanerInfoTile(label: 'Имя', value: name),
                    const SizedBox(height: 12),
                    _CleanerInfoTile(
                      label: 'Опыт работы',
                      value: description,
                      showEditIcon: true,
                      onTap: () => _showEditFieldSheet(
                        context,
                        widget.controller,
                        ProfileInfoField(
                          type: ProfileInfoFieldType.description,
                          label: 'Опыт работы',
                          value: description,
                          isEditable: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CleanerInfoTile(
                      label: 'Номер телефона',
                      value: phone,
                      showEditIcon: false,
                    ),
                    const SizedBox(height: 12),
                    _CleanerInfoTile(label: 'Эл. почта', value: email),
                  ],
                ),
                const SizedBox(height: 18),
                _CleanerMenuButton(
                  icon: Icons.logout,
                  label: 'Выйти',
                  onTap: widget.onLogout,
                  isDestructive: true,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Удалить профиль',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _valueOrDash(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value;
  }

  String _valueOrDefault(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }
    return value;
  }
}

class _CleanerInfoTile extends StatelessWidget {
  const _CleanerInfoTile({
    required this.label,
    required this.value,
    this.showEditIcon = false,
    this.onTap,
  });

  final String label;
  final String value;
  final bool showEditIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: _profileBlockDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (showEditIcon)
              const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _CleanerInfoGroup extends StatelessWidget {
  const _CleanerInfoGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _profileSectionDecoration(),
      child: Column(children: children),
    );
  }
}

class _CleanerMenuButton extends StatelessWidget {
  const _CleanerMenuButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color textColor = isDestructive
        ? AppColors.danger
        : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: _profileBlockDecoration(),
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (!isDestructive)
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
