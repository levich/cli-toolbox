# rsync

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `rsync`

## Что это

Инкрементальная синхронизация файлов по сети и локально.

## Зачем нужен

Деплои, бэкапы, копирование больших деревьев.

## Примеры

```bash
rsync -avh --progress src/ dst/
rsync -avhn src/ user@host:dst/
```

## Установка через CLI Toolbox

```bash
./install.sh --only rsync
```

Определение: [`catalog/tools/rsync.yaml`](../../catalog/tools/rsync.yaml).

## Ссылки

- [rsync.samba.org](https://rsync.samba.org/)
