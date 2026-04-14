# Flink 2.2.0 Cluster — Ansible Deployment

## Архитектура кластера

```
┌─────────────────────────────────────────────────────────────┐
│                    lang33.delta.sbrf.ru                      │
│               JobManager  +  TaskManager                    │
│            REST API :8081   RPC :6123                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
       ┌───────────┬───────┴───────┬───────────┐
       │           │               │           │
  ┌────▼───┐  ┌───▼────┐  ┌──────▼──┐  ┌─────▼───┐
  │ lang34 │  │ lang35 │  │  lang36 │  │  lang37 │
  │   TM   │  │   TM   │  │   TM    │  │   TM    │
  └────────┘  └────────┘  └─────────┘  └─────────┘
```

**JM** = JobManager (координатор), **TM** = TaskManager (выполняет задачи)

## Структура проекта

```
flink-ansible/
├── ansible.cfg                    # глобальные настройки
├── inventories/
│   └── hosts.yml                  # хосты и группы
├── files/
│   └── flink-2.2.0.tar.gz        # ← ПОЛОЖИ СЮДА свой архив
├── roles/
│   └── flink-install/
│       ├── defaults/main.yml      # все параметры с дефолтами
│       ├── tasks/main.yml         # установка + конфиги
│       ├── templates/             # Jinja2-шаблоны конфигов
│       │   ├── flink-conf.yaml.j2
│       │   ├── masters.j2
│       │   └── workers.j2
│       └── handlers/main.yml
└── playbooks/
    ├── install.yml                # развертка
    ├── start.yml                  # запуск кластера
    ├── stop.yml                   # остановка кластера
    ├── config-update.yml          # обновление конфигов
    ├── status.yml                 # проверка состояния
    └── uninstall.yml              # полное удаление
```

## Быстрый старт

### 0. Подготовка

```bash
# Положи архив Flink в files/
cp /path/to/flink-2.2.0.tar.gz files/

# Проверь доступ ко всем хостам
ansible all -m ping
```

### 1. Установка

```bash
ansible-playbook playbooks/install.yml
```

### 2. Запуск кластера

```bash
ansible-playbook playbooks/start.yml
```

Web UI будет доступен по адресу: **http://lang33.delta.sbrf.ru:8081**

### 3. Проверка статуса

```bash
ansible-playbook playbooks/status.yml
```

### 4. Остановка кластера

```bash
ansible-playbook playbooks/stop.yml
```

### 5. Обновление конфигурации

```bash
# Только раскладка конфигов (без рестарта):
ansible-playbook playbooks/config-update.yml

# С rolling-рестартом:
ansible-playbook playbooks/config-update.yml -e restart=true

# С переопределением параметров:
ansible-playbook playbooks/config-update.yml \
  -e flink_taskmanager_memory=16384m \
  -e flink_taskmanager_slots=8 \
  -e restart=true
```

### 6. Удаление

```bash
ansible-playbook playbooks/uninstall.yml
```

## Настройка параметров

Все параметры в `roles/flink-install/defaults/main.yml`:

| Параметр | По умолчанию | Описание |
|---|---|---|
| `flink_jobmanager_memory` | `4096m` | Память JM |
| `flink_taskmanager_memory` | `8192m` | Память каждого TM |
| `flink_taskmanager_slots` | `4` | Слоты на TM |
| `flink_parallelism_default` | `20` | Параллелизм (slots × hosts) |
| `flink_extra_config` | `{}` | Любые доп. параметры flink-conf.yaml |

Пример переопределения через extra vars:

```bash
ansible-playbook playbooks/install.yml \
  -e '{"flink_extra_config": {"state.backend": "rocksdb", "state.checkpoints.dir": "file:///data/checkpoints"}}'
```

## Требования

- Ansible 2.9+
- Java 11+ на всех хостах
- SSH-доступ без пароля от `ivkochkozharov`
- sudo-доступ для создания `/opt/flink-ivkochkozharov` (только при установке)

## Важные замечания

1. **tar.gz архив**: проверь, какая папка внутри архива. Если она называется
   не `flink-2.2.0`, а иначе — поправь `--strip-components` в tasks/main.yml
   или используй альтернативный блок (закомментирован).

2. **JAVA_HOME**: если Java установлена нестандартно, добавь в `flink_extra_config`:
   ```yaml
   flink_extra_config:
     env.java.home: /path/to/java
   ```

3. **Firewall**: порты 6123 (RPC), 8081 (Web UI) и диапазон data-портов
   должны быть открыты между хостами.
