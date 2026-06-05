import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/auth_session.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/widgets/cta_button.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../../domain/entities/profile_info_field.dart';
import '../../domain/entities/profile_menu_item.dart';
import '../controllers/profile_controller.dart';

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
              onEditField: (field) =>
                  _showEditFieldSheet(context, controller, field),
            );
          },
        );
      },
    );
  }
}

const List<String> _districtOptions = [
  'Центральный',
  'Северный',
  'Южный',
  'Восточный',
  'Западный',
];

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
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
  String? _selectedDistrict;

  bool get _isDistrict => widget.field.type == ProfileInfoFieldType.district;

  bool get _isDescription =>
      widget.field.type == ProfileInfoFieldType.description;

  @override
  void initState() {
    super.initState();
    final normalized = _normalizeValue(widget.field.value);
    if (_isDistrict) {
      _selectedDistrict = normalized.isEmpty ? null : normalized;
    } else {
      _textController = TextEditingController(text: normalized);
    }
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
              if (_isDistrict)
                DropdownButtonFormField<String>(
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
                  onChanged: isSaving
                      ? null
                      : (value) {
                          controller.clearUpdateError();
                          setState(() => _selectedDistrict = value);
                        },
                )
              else
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
                    color: Colors.redAccent,
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
                          district:
                              widget.field.type == ProfileInfoFieldType.district
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
    if (_isDistrict) {
      return _selectedDistrict ?? '';
    }
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
  const _ClientProfileView({
    required this.controller,
    required this.onLogout,
    required this.onEditField,
  });

  final ProfileController controller;
  final VoidCallback onLogout;
  final ValueChanged<ProfileInfoField> onEditField;

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
    final buttonTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(primary: const Color(0xFF6DD400)),
    );

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
                const _ProfileHeader(),
                const SizedBox(height: 20),
                if (controller.isLoading && controller.profile == null)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (controller.loadError != null) ...[
                  Text(
                    controller.loadError!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ...controller.infoFields.map(
                  (field) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProfileInfoTile(
                      field: field,
                      onEdit: field.isEditable
                          ? () => widget.onEditField(field)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Theme(
                  data: buttonTheme,
                  child: CTAButton(
                    label: 'Карта постоянного клиента',
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 24),
                ...controller.menuItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProfileMenuTile(
                      item: item,
                      onTap: () {
                        if (item.action == ProfileMenuAction.logout) {
                          widget.onLogout();
                        } else {
                          controller.onMenuItemSelected(item.action);
                        }
                      },
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
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
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.person_outline, color: AppColors.secondary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Профиль',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Личные данные клиента',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({required this.field, this.onEdit});

  final ProfileInfoField field;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  field.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (field.isEditable)
            IconButton(
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              splashRadius: 20,
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
        ],
      ),
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
    final name = _valueOrDash(profile?.name);
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
                const _CleanerProfileHeader(),
                const SizedBox(height: 20),
                const _CleanerAvatarCard(),
                // const SizedBox(height: 16),
                // const _CleanerBalanceTile(),
                const SizedBox(height: 16),
                if (widget.controller.isLoading && profile == null)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (widget.controller.loadError != null) ...[
                  Text(
                    widget.controller.loadError!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _CleanerInfoTile(
                  label: 'Имя',
                  value: name,
                  showEditIcon: true,
                  onTap: () => _showEditFieldSheet(
                    context,
                    widget.controller,
                    ProfileInfoField(
                      type: ProfileInfoFieldType.name,
                      label: 'Имя',
                      value: name,
                      isEditable: true,
                    ),
                  ),
                ),
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
                _CleanerInfoTile(
                  label: 'Эл. почта',
                  value: email,
                  showEditIcon: true,
                  onTap: () => _showEditFieldSheet(
                    context,
                    widget.controller,
                    ProfileInfoField(
                      type: ProfileInfoFieldType.email,
                      label: 'Эл. почта',
                      value: email,
                      isEditable: true,
                    ),
                  ),
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
    if (value == null || value.isEmpty) {
      return '-';
    }
    return value;
  }
}

class _CleanerProfileHeader extends StatelessWidget {
  const _CleanerProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_outline, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ваш профиль',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 0),
              Text(
                'Клинер Time2clean',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CleanerAvatarCard extends StatelessWidget {
  const _CleanerAvatarCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundImage: const AssetImage('assets/icons/logo.png'),
            backgroundColor: AppColors.surface,
          ),
        ],
      ),
    );
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
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

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({required this.item, this.onTap});

  final ProfileMenuItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDestructive = item.isDestructive;

    if (isDestructive) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            item.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFFFF4D61),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final iconData = _iconForAction(item.action);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(iconData, color: AppColors.secondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  IconData _iconForAction(ProfileMenuAction action) {
    switch (action) {
      case ProfileMenuAction.history:
        return Icons.history;
      case ProfileMenuAction.logout:
        return Icons.logout;
      case ProfileMenuAction.delete:
        return Icons.delete_outline;
    }
  }
}
