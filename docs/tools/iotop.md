# iotop

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `iotop`

## Что это

Показывает процессы с наибольшей нагрузкой на диск (нужен root).

## Зачем нужен

Диагностика «кто пишет на диск».

## Примеры

```bash
sudo iotop
sudo iotop -o
```

## Установка через CLI Toolbox

```bash
./install.sh --only iotop
./install.sh --update --only iotop
```

Определение пакета: [`catalog/tools/iotop.yaml`](../../catalog/tools/iotop.yaml).

## Ссылки

- [man iotop](https://man7.org/linux/man-pages/man8/iotop.8.html)
