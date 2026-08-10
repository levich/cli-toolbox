# lsof

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `lsof`

## Что это

Список процессов, держащих файлы/сокеты.

## Зачем нужен

Ответы на «кто занял порт?» и «кто открыл файл?».

## Примеры

```bash
sudo lsof -i :8080
lsof /var/log/syslog
```

## Установка через CLI Toolbox

```bash
./install.sh --only lsof
```

Определение: [`catalog/tools/lsof.yaml`](../../catalog/tools/lsof.yaml).

## Ссылки

- [GitHub](https://github.com/lsof-org/lsof)
