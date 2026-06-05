# Фича авторизации

## Назначение и скоуп
- Двухэтапный вход по номеру телефона и OTP-коду.
- После верификации извлекает признак `is_new_user` и запускает онбординг (сбор даты рождения, цели, оплаты, ежедневных трат).
- Управляет жизненным циклом сессии и выставляет токен в `ApiClient`, чтобы остальные фичи работали с авторизованным HTTP-клиентом.

## Структура каталогов
```text
lib/src/features/auth/
├── data/
│   ├── datasources/
│   │   ├── auth_local_data_source.dart
│   │   └── auth_remote_data_source.dart
│   ├── models/auth_session_model.dart
│   └── repositories/auth_repository_impl.dart
├── domain/
│   ├── entities/auth_session.dart
│   └── repositories/auth_repository.dart
└── presentation/
    ├── controllers/auth_controller.dart
    ├── pages/auth_page.dart
    └── widgets/*.dart (экраны отдельных шагов, заголовок, brand-элементы)
```

## Зависимости и DI
- `AuthRemoteDataSource` и `HomeRemoteDataSource` используют `ApiClient` (обёртка над `Dio`). Токен подставляется через `ApiClient.setAuthToken`.
- `AuthLocalDataSource` хранит JSON-сессию в `PreferencesStorage` по ключу `auth.session`.
- `AuthRepositoryImpl` агрегирует оба источника и реализует `AuthRepository`.
- `AuthController` требует `AuthRepository`, `ApiClient`, `ProfileRepository`. Флаг `useApi` позволяет в тестовых сборках пропустить вызовы API.
- Провайдеры настраиваются в `App` (`ChangeNotifierProvider<AuthController>`) и сразу вызывают `restoreSession()`.
- `PushNotificationService` и `NotificationPermissionController` подписаны на `AuthController.isAuthenticated` — при портировании важно прокинуть им экземпляр.

## Data layer
- `AuthRemoteDataSource`:
  - `requestOtp(phone)` → `POST /api/client/auth/request_code` — отправляет номер, ошибок не возвращает (ожидается `204`/`200`).
  - `requestOtpSms(phone)` → `POST /api/client/auth/request_code/sms` — fallback на SMS-канал.
  - `verifyOtp(phone, code)` → `POST /api/client/auth/verify_code`. Проверяет, что body не `null`, и собирает `AuthSessionModel`.
- `AuthLocalDataSource`:
  - `saveSession` сериализует `AuthSessionModel.toJsonString()`.
  - `loadSession` десериализует строку, а при `FormatException` очищает ключ.
  - `clearSession` просто удаляет значение.
- `AuthSessionModel` допускает snake_case/camelCase ключи (`access_token`, `phone_number` и пр.) и умеет конвертироваться в/из доменной сущности.

## Domain layer
- `AuthSession` содержит `accessToken`, `tokenType`, `phoneNumber`, `isNewUser`. Используется по всему приложению как source of truth.
- `AuthRepository` описывает операции: запрос кода, повторная отправка SMS, верификация, восстановление/очистка сессии.

## Presentation layer
- `AuthController` — `ChangeNotifier` с состоянием:
  - `AuthStep` (машина состояний: `welcome → phoneInput → otpInput → infoFill → authenticated`).
  - `isLoading`, `errorMessage`, `phoneNumber`, `session`.
  - Восстанавливает сессию при запуске (`restoreSession`) и, если она найдена, сразу переводит в `authenticated`.
  - При успешной верификации выставляет токен через `_apiClient.setAuthToken`, что автоматически авторизует остальные запросы.
  - Онбординг:
    - `completeInfoFill`, вызывают методы `ProfileRepository` (если `useApi == true`) и только после успешного ответа переходят к следующему шагу.
  - Обработчики `backTo*` возвращают пользователя на предыдущий шаг, очищая ввод, чтобы предотвратить рассинхрон.
  - `logout` чистит `AuthRepository`, `ProfileRepository`, сбрасывает токен в `ApiClient` и возвращает на ввод телефона.
  - `_mapError` вытаскивает сообщение из `DioException.response.data`.
- `AuthPage` слушает контроллер, показывает `AuthHeader` и через `AnimatedSwitcher` рендерит соответствующий виджет шага (`WelcomeStep`, `PhoneStep`, `OtpStep`, `InfoStep`). Каждый виджет принимает колбэки контроллера и локально валидирует ввод.

## Пользовательский поток
1. Пользователь видит экран welcome, нажимает «Начать».
2. `PhoneStep` валидирует непустой ввод и вызывает `AuthController.submitPhone` → API `request_code`.
3. После успешного ответа шаг переключается на `OtpStep`, где можно повторно отправить код (`submitPhone(phone)`) или запросить SMS (`requestSmsCode`).
4. `submitCode` вызывает `verifyOtp`. При успехе:
   - Сессия сохраняется локально.
   - В `ApiClient` выставляется токен.
   - Если `session.isNewUser == true`, запускается цепочка онбординга (`InfoFill`). Иначе вызывается `_finishOnboarding()` и контроллер переходит в `authenticated`.
5. Каждое онбординг-действие (кроме оплаты) вызывает методы `ProfileRepository`, поэтому при переносе нужно сохранить совместимость API профиля.
6. После завершения (или пропуска трат) контроллер ставит шаг `authenticated`, что разблокирует основной роутер и пуши.

## Интеграции
- `GoRouter` слушает `AuthController`: если `isAuthenticated` ложно, пользователь перенаправляется на `/auth`.
- `SubscriptionController`, `NotificationPermissionController`, `PushNotificationService` подписаны на изменения контроллера.
- UI из других фич вызывает `context.read<AuthController>().logout()` (профиль → «Выйти») — при переносе оставьте этот API.

## Перенос в другой проект — чек-лист
1. Реализовать аналоги `ApiClient` (с поддержкой `setAuthToken`) и `PreferencesStorage` (методы `setString`, `getString`, `remove`).
3. Настроить DI (Provider/любая альтернатива), чтобы `AuthController` был синглтоном на всё приложение.
4. Подключить маршрутизацию/гварды, которые реагируют на `AuthController.isAuthenticated`.
5. Протянуть `AuthController` в сервисы, зависящие от авторизации (пуши, пермишны, платёжные сценарии).
6. Мигрировать UI-виджеты шагов или заменить на собственные, сохранив контракты контроллера (`submitPhone`, `submitCode`, и т.д.).
7. Убедиться, что бекенд поддерживает описанные эндпоинты и формат ответа `verify_code`: поля `access_token`, `token_type`, `is_new_user`, `phone`.
