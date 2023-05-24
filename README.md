# vk.sh

Набор утилит для работы с vk api в shell-скриптах. Библиотека реализована на чистом POSIX-shell.

## 📖 Содержание
- [Пример](#example)
- [Реализовано](#todo)
- [Документация](#docs)
  - [Начало работы](#getting-started)
  - [Установка](#installation)
  - [Модули](#modules)
    - [Модуль `vk_api.sh`](#vk_api_module)
      - [`vk_api`](#vk_api)
      - [`vk_bots_long_poll`](#vk_bots_long_poll)
    - [Модуль `utils.sh`](#utils)
      - [`export_json`](#export_json)
    - [Модуль `filters.sh`](#filters)
      - [`on_event`](#on_event)


<a name="example"></a>
## 🚀 Пример
```sh
vk_bots_long_poll | while read -r event; do (
    on_event "message_new" && (
        export_json "$(echo "$event" | jq -rc '{message: .object.message}')"
        vk_api messages.send             \
            --peer_id "$message_peer_id" \
            --random_id 0                \
            --message "Hello, world!" 
    )
) & done
```

<a name="todo"></a>
## ✅ Реализовано 
- [x] [API](https://vk.com/dev/methods)
- [x] [Bots Long Poll API](https://vk.com/dev/bots_longpoll)
- [ ] [User Long Poll API](https://vk.com/dev/using_longpoll)
- [ ] [Callback API](https://vk.com/dev/callback_api)

<a name="docs"></a>
## 📖 Документация 

<a name="installation"></a>
### ⚙️ Установка
```sh
git clone https://github.com/bulatovv/vk.sh.git
```

Также требуется установить следующие зависимости:
+ `curl`
+ `jq`



<a name="getting-started"></a>
### 🏁 Начало работы 

Перед началом использования необходимо установить переменные среды:

- `VK_TOKEN` - токен доступа к API ВКонтакте
- `VERSION` - версия API ВКонтакте
- `GROUP_ID` - только для работы с BotsLongPoll, идентификатор группы ВКонтакте

```sh
VK_TOKEN="your_token"
VERSION="5.131"
GROUP_ID="your_group_id"
```

Затем подключить необходимые модули:
```sh
. vk.sh/vk_api.sh
. vk.sh/utils.sh
. vk.sh/filters.sh
```
<a name="modules"></a>
### 📦 Модули 

<a name="vk_api_module"></a>
#### 🔨 Модуль `vk_api.sh` 
Содержит функции для работы с API ВКонтакте.

<a name="vk_api"></a>
##### `vk_api`

Выполняить запрос к API ВКонтакте.

```sh
vk_api METHOD_NAME --ARG VALUE # or
vk_api METHOD_NAME --ARG=VALUE # or
vk_api METHOD_NAME ARG=VALUE
```


Пример:

```
vk_api users.get user_ids=1
```

<a name="vk_bots_long_poll"></a>
##### `vk_bots_long_poll`
Слушать события BotsLongPoll сервера.


Пример:
```sh
vk_bots_long_poll | while read -r event; do
    echo "$event"
done
```
<a name="utils"></a>
#### 🔨 Модуль `utils.sh` 
Содержит вспомогательные функции.
<a name="export_json"></a>
##### `export_json`

Экспортировать переменные из json-строки в текущую среду.
Формат:
```json
{ "key": "value" }, // export key=value
{ "key": { "subkey": "value" } } // export key_subkey=value
{ "key": [ "value1", "value2" ] } // export key_0=value1; export key_1=value2
```
Полезно для получения данных из событий long poll сервера, чтобы не парсить json-строку вручную.
Пример:
```sh
vk_bots_long_poll | while read -r event; do
    export_json "$event"
    echo "$object_message_text"
done
```

<a name="filters"></a>
#### 🔨 Модуль `filters.sh` 
Содержит функции для фильтрации событий long poll сервера.  

Фильтры возвращают exit-code `0` в случае успеха и `1` в случае неудачи.
Можно использовать их в условных конструкциях и с операторами `&&` и `||`.
> **Note**
> Встроенные фильтры завязаны на использование переменной среды `event` для получения текущего события

<a name="on_event"></a>
##### `on_event`
Проверить, является ли событие событием с указанным типом.  

Пример:
```sh
vk_bots_long_poll | while read -r event; do
    on_event "message_new" && (
        echo "New message!"
    )
done
```
