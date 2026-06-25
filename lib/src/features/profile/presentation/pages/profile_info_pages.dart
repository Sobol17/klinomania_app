import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_back_button.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;

  @override
  Widget build(BuildContext context) {
    return _ProfileInfoScaffold(
      title: 'Настройки',
      subtitle:
          'Отключение PUSH уведомлений может повлиять на работу приложения',
      children: [
        _SettingsSwitchTile(
          title: 'Push-уведомления',
          description: 'Напомним о заказах, статусах и важных изменениях.',
          value: _pushEnabled,
          onChanged: (value) => setState(() => _pushEnabled = value),
        ),
        const SizedBox(height: 12),
        _SettingsSwitchTile(
          title: 'Email-уведомления',
          description: 'Отправим чеки, подтверждения и спокойные напоминания.',
          value: _emailEnabled,
          onChanged: (value) => setState(() => _emailEnabled = value),
        ),
      ],
    );
  }
}

class ProfileAboutPage extends StatelessWidget {
  const ProfileAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: const [
            _AboutHeader(),
            SizedBox(height: 22),
            _AboutParagraph(
              'Клиномания — сервис бережного клининга для тех, кто любит ощущение свежести дома, но не хочет тратить время на бытовые заботы. Мы помогаем быстро выбрать подходящий тариф, добавить нужные опции и заказать уборку в удобное время.',
            ),
            SizedBox(height: 18),
            _AboutParagraph(
              'Наша цель — сделать чистоту привычной и спокойной частью жизни. Без лишних звонков, сложных согласований и случайного результата: только понятные условия, аккуратная работа и забота о деталях.',
            ),
            SizedBox(height: 22),
            _AboutIntroTitle('Мы подходим и вам, если вам важны:'),
            SizedBox(height: 12),
            _AboutAccentParagraph(
              title: 'ЭКСПЕРТНОСТЬ, ',
              body:
                  'когда вы понимаете, что дом требует внимательного ухода, правильных средств и аккуратной работы с поверхностями.',
            ),
            SizedBox(height: 12),
            _AboutAccentParagraph(
              title: 'СЕРВИС, ',
              body:
                  'когда вы хотите легко выбрать услугу, получить понятную стоимость и быть уверенными в результате.',
            ),
            SizedBox(height: 12),
            _AboutAccentParagraph(
              title: 'ЗАБОТА, ',
              body:
                  'когда важно, чтобы к вашему дому относились бережно, спокойно и без спешки.',
            ),
            SizedBox(height: 12),
            _AboutAccentParagraph(
              title: 'СЧАСТЬЕ, ',
              body:
                  'когда после уборки хочется просто открыть дверь, вдохнуть свежий воздух и отдыхать.',
            ),
            SizedBox(height: 24),
            _AboutIntroTitle('Как нам это удается?'),
            SizedBox(height: 16),
            _AboutNumberedBlock(
              title: '1. Понятные тарифы',
              body:
                  'В приложении собраны основные сценарии уборки: от базового поддержания чистоты до роскошного максимума с расширенным набором работ. Вы видите состав услуги заранее и выбираете только то, что нужно.',
            ),
            _AboutNumberedBlock(
              title: '2. Аккуратная команда',
              body:
                  'Мы делаем ставку на внимательность, вежливость и стабильное качество. Клинеры работают по понятным чек-листам и уделяют внимание деталям, которые создают ощущение настоящей чистоты.',
            ),
            _AboutNumberedBlock(
              title: '3. Удобное оформление',
              body:
                  'Вы выбираете размер квартиры, дополнительные опции, дату и время. Все важное находится в одном сценарии, поэтому заказ можно оформить без лишних действий.',
            ),
            _AboutNumberedBlock(
              title: '4. Бережные средства',
              body:
                  'Мы используем профессиональный подход к поверхностям, текстилю, сантехнике и кухне. Для каждого типа загрязнения подбирается аккуратный и безопасный способ обработки.',
            ),
            _AboutNumberedBlock(
              title: '5. Свежесть без визуального шума',
              body:
                  'После уборки дом должен выглядеть спокойно: чистые поверхности, свежий воздух, порядок на видимых местах и ощущение, что все подготовлено для отдыха.',
            ),
            _AboutNumberedBlock(
              title: '6. Поддержка на связи',
              body:
                  'Если нужно уточнить детали, изменить заказ или передать комментарий клинеру, команда поможет разобраться и подскажет лучший вариант.',
            ),
            _AboutNumberedBlock(
              title: '7. Ответственность за результат',
              body:
                  'Мы ценим доверие клиентов и внимательно относимся к обратной связи. Если возникнут вопросы по качеству, мы разберем ситуацию и найдем решение.',
              hasBottomGap: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader();

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
          Text(
            'О нас',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutIntroTitle extends StatelessWidget {
  const _AboutIntroTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        height: 1.35,
      ),
    );
  }
}

class _AboutParagraph extends StatelessWidget {
  const _AboutParagraph(this.text);

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

class _AboutAccentParagraph extends StatelessWidget {
  const _AboutAccentParagraph({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyLarge?.copyWith(
      color: AppColors.textPrimary,
      height: 1.34,
    );
    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(
            text: title,
            style: style?.copyWith(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: body),
        ],
      ),
    );
  }
}

class _AboutNumberedBlock extends StatelessWidget {
  const _AboutNumberedBlock({
    required this.title,
    required this.body,
    this.hasBottomGap = true,
  });

  final String title;
  final String body;
  final bool hasBottomGap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: hasBottomGap ? 20 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              height: 1.34,
            ),
          ),
        ],
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

  static const List<_LegalDocument> _documents = [
    _LegalDocument(
      title: 'Пользовательское соглашение',
      subtitle: 'Правила использования приложения и оформления заказов.',
      paragraphs: [
        _LegalParagraph(
          title: '1. Общие положения',
          body:
              'Настоящее пользовательское соглашение определяет порядок использования мобильного приложения Клиномания, выбора услуг клининга и оформления заказов.',
        ),
        _LegalParagraph(
          title: '2. Оформление заказа',
          body:
              'Пользователь выбирает тариф, дополнительные опции, дату и время уборки. Перед подтверждением заказа пользователь проверяет адрес, контактные данные и итоговые условия услуги.',
        ),
        _LegalParagraph(
          title: '3. Ответственность сторон',
          body:
              'Клиномания стремится обеспечить аккуратное выполнение услуг и своевременную коммуникацию. Пользователь обязуется предоставить достоверную информацию, доступ в помещение и условия для выполнения уборки.',
        ),
        _LegalParagraph(
          title: '4. Изменение условий',
          body:
              'Условия заказа могут быть уточнены до начала уборки, если меняется объем работ, адрес, время или перечень дополнительных опций.',
        ),
      ],
    ),
    _LegalDocument(
      title: 'Политика конфиденциальности',
      subtitle: 'Как мы бережно работаем с персональными данными.',
      paragraphs: [
        _LegalParagraph(
          title: '1. Какие данные используются',
          body:
              'Для работы сервиса могут использоваться имя, номер телефона, email, адрес уборки, история заказов и комментарии, которые пользователь оставляет при оформлении услуги.',
        ),
        _LegalParagraph(
          title: '2. Зачем нужны данные',
          body:
              'Данные помогают оформить заказ, связаться с пользователем, передать клинеру важные детали и улучшать качество сервиса.',
        ),
        _LegalParagraph(
          title: '3. Хранение и защита',
          body:
              'Мы используем данные только в рамках работы сервиса и не передаем их третьим лицам без необходимости исполнения заказа или требования закона.',
        ),
        _LegalParagraph(
          title: '4. Управление данными',
          body:
              'Пользователь может обновить личные данные в профиле или обратиться в поддержку, если нужно уточнить, изменить или удалить информацию.',
        ),
      ],
    ),
    _LegalDocument(
      title: 'Правила оказания услуг',
      subtitle: 'Что важно знать перед уборкой.',
      paragraphs: [
        _LegalParagraph(
          title: '1. Подготовка к уборке',
          body:
              'Перед приходом клинера рекомендуется убрать ценные и хрупкие предметы, обеспечить доступ к воде, электричеству и помещениям, которые нужно убрать.',
        ),
        _LegalParagraph(
          title: '2. Объем работ',
          body:
              'Состав уборки зависит от выбранного тарифа и дополнительных опций. Работы, не входящие в выбранный пакет, могут быть согласованы отдельно.',
        ),
        _LegalParagraph(
          title: '3. Комментарии к заказу',
          body:
              'Если дома есть деликатные поверхности, животные, сложные загрязнения или зоны с особым приоритетом, это лучше указать при оформлении заказа.',
        ),
        _LegalParagraph(
          title: '4. Приемка результата',
          body:
              'После уборки пользователь может проверить результат и передать обратную связь. Если возникают вопросы по качеству, команда поддержки поможет найти решение.',
        ),
      ],
    ),
  ];

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
            for (var index = 0; index < _documents.length; index++) ...[
              _LegalMenuTile(document: _documents[index]),
              if (index != _documents.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileLegalDocumentPage extends StatelessWidget {
  const _ProfileLegalDocumentPage({required this.document});

  final _LegalDocument document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            _TextPageHeader(title: document.title),
            const SizedBox(height: 22),
            _AboutParagraph(document.subtitle),
            const SizedBox(height: 24),
            for (var index = 0; index < document.paragraphs.length; index++)
              _AboutNumberedBlock(
                title: document.paragraphs[index].title,
                body: document.paragraphs[index].body,
                hasBottomGap: index != document.paragraphs.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _LegalMenuTile extends StatelessWidget {
  const _LegalMenuTile({required this.document});

  final _LegalDocument document;

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

class _LegalDocument {
  const _LegalDocument({
    required this.title,
    required this.subtitle,
    required this.paragraphs,
  });

  final String title;
  final String subtitle;
  final List<_LegalParagraph> paragraphs;
}

class _LegalParagraph {
  const _LegalParagraph({required this.title, required this.body});

  final String title;
  final String body;
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
  final ValueChanged<bool> onChanged;

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
