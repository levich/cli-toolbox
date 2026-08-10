# jq

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `jq`

## Что это

Процессор JSON для пайплайнов shell.

## Зачем нужен

Парсинг API-ответов и конфигов без Python/Node однострочников.

## Примеры

```bash
echo '{"a":1}' | jq .a
jq -r '.name' package.json
```

## Установка через CLI Toolbox

```bash
./install.sh --only jq
./install.sh --update --only jq
```

Определение пакета: [`catalog/tools/jq.yaml`](../../catalog/tools/jq.yaml).

## Ссылки

- [jqlang.org](https://jqlang.github.io/jq/)
