# ripgrep

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `ripgrep`

## Что это

Рекурсивный поиск по содержимому файлов (`rg`), учитывает .gitignore.

## Зачем нужен

Обычно быстрее grep/ack на больших репозиториях.

## Примеры

```bash
rg 'TODO' .
rg -t py 'def main'
```

## Установка через CLI Toolbox

```bash
./install.sh --only ripgrep
./install.sh --update --only ripgrep
```

Определение пакета: [`catalog/tools/ripgrep.yaml`](../../catalog/tools/ripgrep.yaml).

## Ссылки

- [GitHub](https://github.com/BurntSushi/ripgrep)
