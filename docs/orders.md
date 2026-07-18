# Orders API

## Клиентские заявки

Все endpoints клиентских заявок требуют Bearer token пользователя с ролью `client`.

### Создать заявку

`POST /api/v1/client/orders`

Request:

```json
{
  "service_id": "standard",
  "room_option_id": "room-2",
  "cleaning_option_id": "support",
  "extra_option_ids": ["fridge-inside"],
  "address": {"full_address": "Москва, ул. Примерная, 1"},
  "scheduled_at": "2026-07-10T10:00:00+03:00",
  "comment": "Позвонить за 15 минут"
}
```

Response `201`:

```json
{
  "data": {
    "id": "01J2QM1R7H7YV9JH1KACD6ZK3R",
    "status": "processing",
    "status_label": "В обработке",
    "scheduled_at": "2026-07-10T07:00:00Z",
    "total_price": 9100,
    "currency": "RUB",
    "service": {"id": "standard", "title": "Базовый минимум"}
  }
}
```

### История заявок клиента

`GET /api/v1/client/orders`

Response `200`:

```json
{
  "data": []
}
```

### Отменить заявку

`POST /api/v1/client/orders/{public_id}/cancel`

Клиент может отменить только свою заявку в статусе `processing` или `confirmed`.

## Заявки клинера

Все endpoints клинера требуют Bearer token пользователя с ролью `cleaner`.

### Доступные заявки

`GET /api/v1/cleaner/orders/available`

Возвращает подтверждённые заявки с незаполненной командой.

### Мои заявки

`GET /api/v1/cleaner/orders`

Возвращает заявки текущего клинера после подтверждения, в которых он состоит в команде: `team_formed`, `in_progress` и `completed`.

### История выполненных заявок

`GET /api/v1/cleaner/orders/history`

Возвращает завершенные заявки текущего клинера.

### Детали заявки

`GET /api/v1/cleaner/orders/{public_id}`

Возвращает детали заявки для клинера, включённого в её команду. В URL передаётся публичный ULID, а не внутренний числовой ID БД. Для остальных клинеров backend возвращает `403 forbidden`.

В ответе `data.line_items` содержит все зафиксированные строки цены, а `data.extra_options` — только дополнительные работы. Для отображения допуслуг приложение использует `extra_options`.

### Взять заявку

`POST /api/v1/cleaner/orders/{public_id}/accept`

В URL передаётся публичный ULID заявки из поля `public_id` (или `id` ответа создания заявки), например `01J2QM1R7H7YV9JH1KACD6ZK3R`. Внутренний числовой ID БД не используется.

Разрешено только для заявки в статусе `confirmed`, пока команда не заполнена.

После набора требуемого количества клинеров новый статус: `team_formed`.

### Начать работу

`POST /api/v1/cleaner/orders/{public_id}/start`

Разрешено только участнику сформированной команды.

Новый статус: `in_progress`.

### Завершить заявку

`POST /api/v1/cleaner/orders/{public_id}/complete`

Разрешено только клинеру, который выполняет заявку, и только из статуса `in_progress`.

Новый статус: `completed`.

## Статусы

- `processing` - заявка находится в обработке модератора.
- `confirmed` - заявка подтверждена и видна клинерам.
- `team_formed` - требуемая команда клинеров сформирована.
- `in_progress` - первый участник команды приступил к работе.
- `completed` - первый начавший работу участник завершил заявку.
- `cancelled` - клиент отменил заявку до формирования команды.
