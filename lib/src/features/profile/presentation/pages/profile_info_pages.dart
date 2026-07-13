import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../controllers/profile_controller.dart';
import 'profile_legal_documents.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        final profile = controller.profile;
        return _ProfileInfoScaffold(
          title: 'Настройки',
          subtitle:
              'Отключение PUSH уведомлений может повлиять на работу приложения',
          children: [
            _SettingsSwitchTile(
              title: 'Push-уведомления',
              description: 'Напомним о заказах, статусах и важных изменениях.',
              value: profile?.pushNotificationsEnabled ?? false,
              onChanged: profile == null || controller.isSaving
                  ? null
                  : (value) => controller.updateProfile(
                      pushNotificationsEnabled: value,
                    ),
            ),
            const SizedBox(height: 12),
            _SettingsSwitchTile(
              title: 'Email-уведомления',
              description:
                  'Отправим чеки, подтверждения и спокойные напоминания.',
              value: profile?.emailMarketingEnabled ?? false,
              onChanged: profile == null || controller.isSaving
                  ? null
                  : (value) =>
                        controller.updateProfile(emailMarketingEnabled: value),
            ),
            if (controller.updateError != null) ...[
              const SizedBox(height: 12),
              Text(
                controller.updateError!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.danger),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _InfoParagraph extends StatelessWidget {
  const _InfoParagraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        height: 1.34,
      ),
    );
  }
}

class ProfileContactsPage extends StatelessWidget {
  const ProfileContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: const [
            _TextPageHeader(title: 'Контакты'),
            SizedBox(height: 22),
            _ContactTextBlock(
              label: 'Телефон',
              value: '+7 999 000-00-00',
              isAccent: true,
            ),
            SizedBox(height: 18),
            _ContactTextBlock(
              label: 'Email',
              value: 'hello@klinomania.ru',
              isAccent: true,
            ),
            SizedBox(height: 34),
            _ContactSectionTitle('График работы'),
            SizedBox(height: 20),
            _ContactTextBlock(
              label: 'Режим работы офиса:',
              value: 'Ежедневно 09:00-21:00',
            ),
            SizedBox(height: 18),
            _ContactTextBlock(
              label: 'Режим работы клининга:',
              value: 'Ежедневно 08:00-22:00',
            ),
            SizedBox(height: 34),
            _ContactSectionTitle('Юридическая информация'),
            SizedBox(height: 18),
            _LegalCompanyName('ООО "Клиномания"'),
            SizedBox(height: 18),
            _ContactTextBlock(
              label: 'Юридический адрес',
              value: 'Российская Федерация, Москва, ул. Чистая, 12, офис 5',
            ),
            SizedBox(height: 18),
            _ContactTextBlock(label: 'ИНН', value: '7700000000'),
            SizedBox(height: 18),
            _ContactTextBlock(label: 'ОГРН', value: '1247700000000'),
            SizedBox(height: 18),
            _ContactTextBlock(label: 'КПП', value: '770001001'),
          ],
        ),
      ),
    );
  }
}

class _TextPageHeader extends StatelessWidget {
  const _TextPageHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).maybePop(),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSectionTitle extends StatelessWidget {
  const _ContactSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.headlineSmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        height: 1.14,
      ),
    );
  }
}

class _ContactTextBlock extends StatelessWidget {
  const _ContactTextBlock({
    required this.label,
    required this.value,
    this.isAccent = false,
  });

  final String label;
  final String value;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isAccent ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _LegalCompanyName extends StatelessWidget {
  const _LegalCompanyName(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        height: 1.3,
      ),
    );
  }
}

class ProfileLegalPage extends StatelessWidget {
  const ProfileLegalPage({super.key});

  static void openDocument(BuildContext context, String title) {
    for (final document in profileLegalDocuments) {
      if (document.title == title) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _ProfileLegalDocumentPage(document: document),
          ),
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.disabled,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            const _TextPageHeader(title: 'Правовая информация'),
            const SizedBox(height: 22),
            for (
              var index = 0;
              index < profileLegalDocuments.length;
              index++
            ) ...[
              _LegalMenuTile(document: profileLegalDocuments[index]),
              if (index != profileLegalDocuments.length - 1)
                const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileLegalDocumentPage extends StatelessWidget {
  const _ProfileLegalDocumentPage({required this.document});

  final ProfileLegalDocumentContent document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            _TextPageHeader(title: document.title),
            const SizedBox(height: 22),
            _InfoParagraph(document.subtitle),
            const SizedBox(height: 24),
            SelectableText(
              document.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalMenuTile extends StatelessWidget {
  const _LegalMenuTile({required this.document});

  final ProfileLegalDocumentContent document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _ProfileLegalDocumentPage(document: document),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppStyle.inputRadius),
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    document.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
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
}

class _ProfileInfoScaffold extends StatelessWidget {
  const _ProfileInfoScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.disabled,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
          children: [
            const AppBackButton(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _InfoHeader(title: title, subtitle: subtitle),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoHeader extends StatelessWidget {
  const _InfoHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyle.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(AppStyle.inputRadius),
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: 'LovelaceText',
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppStyle.inputRadius),
    border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
  );
}
