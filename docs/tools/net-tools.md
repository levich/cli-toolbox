# net-tools

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `net-tools`

## Что это

Пакет классических сетевых утилит: `ifconfig`, `netstat`, `route`.

## Зачем нужен

Совместимость со старыми инструкциями и скриптами (на новых системах часто предпочитают iproute2).

## Примеры

```bash
ifconfig
netstat -tulpn
```

## Установка через CLI Toolbox

```bash
./install.sh --only net-tools
./install.sh --update --only net-tools
```

Определение пакета: [`catalog/tools/net-tools.yaml`](../../catalog/tools/net-tools.yaml).

## Ссылки

- [Wikipedia](https://en.wikipedia.org/wiki/Net-tools)
