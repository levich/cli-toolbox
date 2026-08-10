# tmux

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `tmux`

## Что это

Мультиплексор терминала: сессии, окна и панели.

## Зачем нужен

Работать по SSH без потери сессии; держать несколько панелей в одном окне.

## Примеры

```bash
tmux new -s main
tmux attach -t main
# Ctrl-b d — detach
```

## Установка через CLI Toolbox

```bash
./install.sh --only tmux
```

Определение: [`catalog/tools/tmux.yaml`](../../catalog/tools/tmux.yaml).

## Ссылки

- [tmux wiki](https://github.com/tmux/tmux/wiki)
