# uv

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `uv`

## Что это

Менеджер Python-пакетов и виртуальных окружений от Astral (авторы Ruff).

## Зачем нужен

На порядки быстрее pip/venv; единый инструмент для проектов и tool-изоляции.

## Примеры

```bash
uv python install 3.12
uv venv
uv pip install requests
uvx ruff check .
```

## Установка через CLI Toolbox

```bash
./install.sh --only uv
./install.sh --update --only uv
```

Определение пакета: [`catalog/tools/uv.yaml`](../../catalog/tools/uv.yaml).

## Ссылки

- [docs.astral.sh/uv](https://docs.astral.sh/uv/)
