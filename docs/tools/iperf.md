# iperf

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `iperf`

## Что это

`iperf3` — утилита для измерения пропускной способности TCP/UDP между двумя хостами (клиент и сервер).

## Зачем нужен

Проверка канала между серверами, диагностика сети, сравнение до/после изменений маршрутизации или лимитов.

## Примеры

```bash
# На сервере
iperf3 -s

# На клиенте
iperf3 -c 192.168.1.10
iperf3 -c 192.168.1.10 -t 30 -P 4
iperf3 -c 192.168.1.10 -u -b 100M
```

## Установка через CLI Toolbox

```bash
./install.sh --only iperf
./install.sh --profile admin
./install.sh --update --only iperf
```

В каталоге ставится пакет **iperf3** (команда `iperf3`). Определение: [`catalog/tools/iperf.yaml`](../../catalog/tools/iperf.yaml).

## Ссылки

- [iperf.fr](https://iperf.fr/) · [GitHub](https://github.com/esnet/iperf)
