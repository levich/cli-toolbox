# tcpdump

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `tcpdump`

## Что это

Захват пакетов на интерфейсе.

## Зачем нужен

Быстрая сетевая диагностика без Wireshark.

## Примеры

```bash
sudo tcpdump -i any port 53 -nn
sudo tcpdump -w cap.pcap
```

## Установка через CLI Toolbox

```bash
./install.sh --only tcpdump
```

Определение: [`catalog/tools/tcpdump.yaml`](../../catalog/tools/tcpdump.yaml).

## Ссылки

- [tcpdump.org](https://www.tcpdump.org/)
