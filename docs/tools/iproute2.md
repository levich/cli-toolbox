# iproute2

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `iproute2`

## Что это

Набор современных сетевых утилит Linux: `ip`, `ss`, `tc` и др.

## Зачем нужен

Настройка интерфейсов, маршрутов и диагностика сокетов без устаревшего net-tools.

## Примеры

```bash
ip a
ip r
ss -tulpn
ip link set eth0 up
```

## Установка через CLI Toolbox

```bash
./install.sh --only iproute2
```

На macOS пропускается (`skip_on: macos`). Определение: [`catalog/tools/iproute2.yaml`](../../catalog/tools/iproute2.yaml).

## Ссылки

- [Linux Foundation wiki](https://wiki.linuxfoundation.org/networking/iproute2)
