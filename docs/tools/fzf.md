# fzf

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `fzf`

## Что это

Универсальный fuzzy-finder: поиск по файлам, истории команд, процессам.

## Зачем нужен

Ускоряет навигацию и выбор из длинных списков; хорошо стыкуется с vim/zsh.

## Примеры

```bash
fzf
# Ctrl-R после установки key-bindings — поиск по истории
kill -9 $(ps aux | fzf | awk '{print $2}')
```

## Установка через CLI Toolbox

```bash
./install.sh --only fzf
./install.sh --update --only fzf
```

Определение пакета: [`catalog/tools/fzf.yaml`](../../catalog/tools/fzf.yaml).

## Ссылки

- [GitHub](https://github.com/junegunn/fzf)
