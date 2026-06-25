# Перенос Yandex geo suggest

Документ описывает текущую реализацию подсказок адресов Яндекса и адресной книги в приложении. Для переноса 1в1 нужно переносить не только HTTP-запрос к Яндексу, но и экран добавления адреса, правила выбора подсказки, локальное сохранение адресов и DI-wiring.

## Что делает фича

- Пользователь открывает экран адресов профиля: `/profile/addresses`.
- При добавлении или редактировании адреса вводит `Город, улица, дом`.
- После 3 символов запускается debounce на 350 мс.
- Через `FetchAddressSuggestionsUseCase` вызывается Яндекс Suggest API.
- Пользователь обязан выбрать адрес из списка подсказок. Ручной текст без выбранной подсказки не сохраняется.
- Дополнительно вводятся квартира/офис, этаж, подъезд, домофон или включается режим `Частный дом или отдельное здание`.
- Адрес сохраняется локально в `SharedPreferences` списком JSON-строк.
- Первый добавленный адрес автоматически становится выбранным.
- Выбранный адрес показывается в storefront header и используется в корзине как адрес доставки.

## Внешний API

Реализация находится в `lib/src/features/profile/data/services/address_suggest_service.dart`.

Базовый URL:

```text
https://suggest-maps.yandex.ru
```

Endpoint:

```text
GET /v1/suggest
```

Параметры запроса:

```dart
{
  'apikey': apiKey,
  'text': 'Иркутская область, $query',
  'lang': 'ru',
  'results': 5,
  'highlight': 0,
  'countries': 'ru',
  'types': 'house',
  'print_address': 1,
}
```

Важные детали:

- API key берется из `String.fromEnvironment('YANDEX_SUGGEST_API_KEY')`.
- Если ключ пустой, сервис сразу возвращает пустой список и не делает HTTP-запрос.
- Поиск принудительно ограничен префиксом `Иркутская область`.
- Тип подсказок ограничен `house`, то есть нужен адрес с домом.
- В UI подсказки запрашиваются только для trimmed query длиной от 3 символов.
- Ошибки запроса в форме глушатся: список подсказок очищается, пользователь не видит отдельную ошибку API.

Ожидаемый ответ Яндекса читается из `results`. Для каждого элемента используются поля:

```json
{
  "title": { "text": "Иркутск, улица Ленина, 1" },
  "subtitle": { "text": "Иркутск" },
  "address": { "formatted_address": "Иркутск, улица Ленина, 1" }
}
```

Маппинг:

- `title` = `json['title']['text']` или пустая строка.
- `subtitle` = `json['subtitle']['text']` или пустая строка.
- `address` = `json['address']['formatted_address']`; если его нет, используется `title`.
- Пустые `address` отфильтровываются.

## Файлы для переноса

### Обязательная suggest-цепочка

- `lib/src/features/profile/domain/entities/address_suggestion.dart`
- `lib/src/features/profile/data/models/address_suggestion_model.dart`
- `lib/src/features/profile/data/services/address_suggest_service.dart`
- `lib/src/features/profile/domain/repositories/profile_address_suggestions_repository.dart`
- `lib/src/features/profile/data/repositories/profile_address_suggestions_repository_impl.dart`
- `lib/src/features/profile/domain/use_cases/fetch_address_suggestions.dart`

### Адресная книга и локальное сохранение

- `lib/src/features/profile/domain/entities/delivery_address.dart`
- `lib/src/features/profile/data/models/delivery_address_model.dart`
- `lib/src/features/profile/data/services/profile_addresses_storage_service.dart`
- `lib/src/features/profile/domain/repositories/profile_addresses_repository.dart`
- `lib/src/features/profile/data/repositories/profile_addresses_repository_impl.dart`
- `lib/src/features/profile/domain/use_cases/fetch_delivery_addresses.dart`
- `lib/src/features/profile/domain/use_cases/save_delivery_addresses.dart`
- `lib/src/features/profile/presentation/controllers/profile_addresses_controller.dart`

### UI

- `lib/src/features/profile/presentation/pages/profile_addresses_screen.dart`
- `lib/src/features/profile/presentation/pages/profile_address_form_screen.dart`
- `lib/src/features/profile/presentation/widgets/profile_addresses_header.dart`
- `lib/src/features/profile/presentation/widgets/profile_addresses_list.dart`

Опционально, если в новом проекте нужно так же показывать выбранный адрес в витрине и корзине:

- `lib/src/shared/widgets/storefront_search_header.dart`
- `lib/src/features/cart/presentation/widgets/cart_delivery_section.dart`

### Интеграция приложения

- `lib/app/app_dependencies_scope.dart`
- `lib/app/app_router.dart`

Из `app_dependencies_scope.dart` нужно перенести:

- чтение `YANDEX_SUGGEST_API_KEY`;
- provider для `ProfileAddressesStorageService`;
- provider для `AddressSuggestService`;
- `ProxyProvider` для `ProfileAddressesRepository`;
- `ProxyProvider` для `ProfileAddressSuggestionsRepository`;
- use cases `FetchDeliveryAddressesUseCase`, `SaveDeliveryAddressesUseCase`, `FetchAddressSuggestionsUseCase`;
- `ChangeNotifierProvider<ProfileAddressesController>`.

Из `app_router.dart` нужно перенести маршрут:

```dart
GoRoute(
  path: 'addresses',
  builder: (context, state) {
    return const ProfileAddressesScreen();
  },
)
```

В текущем приложении он вложен в профиль и открывается как `/profile/addresses`.

## Зависимости

В `pubspec.yaml` для этой фичи нужны:

```yaml
dependencies:
  dio: ^5.7.0
  provider: ^6.1.2
  shared_preferences: ^2.3.2
  equatable: ^2.0.5
  go_router: ^14.2.0
  flutter_svg: ^2.0.9
```

`flutter_svg` нужен из-за текущего UI формы/экрана адресов, а не из-за самого suggest API.

Также UI зависит от локальных компонентов и темы проекта:

- `lib/src/core/theme/app_colors.dart`
- `lib/src/shared/widgets/app_button.dart`
- возможно `lib/src/shared/widgets/app_text_field.dart`, если переносится storefront header.

Если в другом проекте уже есть собственная тема и кнопки, проще адаптировать UI-импорты, но бизнес-логику оставить без изменений.

## Конфиг запуска

Ключ передается через dart define:

```bash
flutter run --dart-define=YANDEX_SUGGEST_API_KEY=your_key
```

Для сборок:

```bash
flutter build apk --dart-define=YANDEX_SUGGEST_API_KEY=your_key
flutter build ios --dart-define=YANDEX_SUGGEST_API_KEY=your_key
```

Если ключ не передан, подсказки будут всегда пустыми. Это штатное поведение текущей реализации.

## Правила UI и валидации

Файл с основной логикой: `lib/src/features/profile/presentation/pages/profile_address_form_screen.dart`.

Нужно сохранить следующие правила:

- `_suggestDebounce` = `Timer(Duration(milliseconds: 350))`.
- `_suggestRequestId` инкрементируется на каждый запрос и при выборе подсказки, чтобы старые ответы не перетирали актуальное состояние.
- При любом ручном изменении адреса `_selectedAddressSuggestion` сбрасывается.
- Кнопка `Сохранить` disabled, пока нет выбранной подсказки.
- `_hasSelectedAddressSuggestion` проверяет, что текст поля равен `suggestion.address.trim()`.
- Submit без выбранной подсказки показывает `Выберите адрес из подсказки`.
- Submit с пустым адресом показывает `Укажите город, улицу и дом`.
- Для нечастного дома обязательно поле `Кв/Офис`; иначе ошибка `Укажите квартиру или офис`.
- При включении частного дома очищаются квартира, этаж, подъезд и домофон.
- При редактировании существующий адрес считается выбранной подсказкой, если address непустой.

## Данные адреса

`DeliveryAddress` хранит:

- `id`
- `title`
- `address`
- `cityId`
- `details`
- `apartmentOrOffice`
- `floor`
- `entrance`
- `intercom`
- `isPrivateHouse`
- `isSelected`

Регионы доставки зашиты в `deliveryRegionOptions`:

```dart
const deliveryRegionOptions = <DeliveryRegionOption>[
  DeliveryRegionOption(cityId: 1, title: 'Иркутск'),
  DeliveryRegionOption(cityId: 2, title: 'Ангарск'),
  DeliveryRegionOption(cityId: 3, title: 'Пригород Иркутска'),
];

const defaultDeliveryRegionCityId = 1;
```

Важно: выбранный регион доставки не меняет запрос в Яндекс. Запрос всегда получает префикс `Иркутская область`. `cityId` сохраняется отдельно как бизнес-поле.

## Локальное хранение

Сервис `SharedPrefsProfileAddressesStorageService` использует ключ:

```dart
static const _addressesKey = 'profile_delivery_addresses';
```

Формат хранения: `StringList`, где каждый элемент - `jsonEncode(address.toJson())`.

JSON-ключи:

```json
{
  "id": "...",
  "title": "...",
  "address": "...",
  "city_id": "1",
  "details": "...",
  "apartment_or_office": "...",
  "floor": "...",
  "entrance": "...",
  "intercom": "...",
  "is_private_house": false,
  "is_selected": true
}
```

`city_id` при сохранении пишется строкой, но при чтении поддерживаются и `int`, и `String`.

## Тесты для переноса

Минимально перенести и прогнать:

- `test/src/features/profile/data/services/address_suggest_service_test.dart`
- `test/src/features/profile/data/models/address_suggestion_model_test.dart`
- `test/src/features/profile/data/models/delivery_address_model_test.dart`
- `test/src/features/profile/presentation/controllers/profile_addresses_controller_test.dart`

Команды:

```bash
flutter test test/src/features/profile/data/services/address_suggest_service_test.dart
flutter test test/src/features/profile/data/models/address_suggestion_model_test.dart
flutter test test/src/features/profile/data/models/delivery_address_model_test.dart
flutter test test/src/features/profile/presentation/controllers/profile_addresses_controller_test.dart
```

## Порядок переноса

1. Добавить зависимости в `pubspec.yaml` и выполнить `flutter pub get`.
2. Перенести domain/data файлы suggest-цепочки.
3. Перенести domain/data/controller файлы адресной книги.
4. Подключить `SharedPreferences`/локальный storage проекта к `SharedPrefsProfileAddressesStorageService`.
5. Подключить `YandexAddressSuggestService` через отдельный `Dio` с baseUrl `https://suggest-maps.yandex.ru`.
6. Пробросить `YANDEX_SUGGEST_API_KEY` через `--dart-define`.
7. Зарегистрировать repositories/use cases/controller в DI.
8. Перенести экран списка адресов и экран формы адреса.
9. Добавить маршрут `/profile/addresses` или аналогичный маршрут нового проекта.
10. Подключить выбранный адрес туда, где он должен отображаться или использоваться в заказе.
11. Перенести тесты и прогнать focused suite.

## Быстрый чеклист 1в1

- [ ] В запросе остается `text: 'Иркутская область, $query'`.
- [ ] В запросе остается `types: 'house'`.
- [ ] В запросе остается `results: 5`.
- [ ] Пустой `YANDEX_SUGGEST_API_KEY` возвращает пустой список.
- [ ] UI не дает сохранить адрес без выбора подсказки.
- [ ] Debounce равен 350 мс.
- [ ] Старые ответы suggest не перетирают новые.
- [ ] Первый адрес становится выбранным.
- [ ] Адреса сохраняются в `profile_delivery_addresses`.
- [ ] `city_id` совместим со строкой и числом при чтении.
