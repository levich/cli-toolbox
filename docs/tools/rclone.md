# rclone

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `rclone`

## Что это

Синхронизация с облаками (S3, GDrive, B2 и др.).

## Зачем нужен

Бэкапы и перенос данных как rsync, но для object storage.

## Примеры

```bash
rclone config
rclone copy /data remote:bucket -P
```

## Установка через CLI Toolbox

```bash
./install.sh --only rclone
```

Определение: [`catalog/tools/rclone.yaml`](../../catalog/tools/rclone.yaml).

## Ссылки

- [rclone.org](https://rclone.org/)
