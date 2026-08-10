# chezmoi

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `chezmoi`

## Что это

Менеджер dotfiles: хранит конфиги в git-репозитории и применяет их на машинах (шаблоны, секреты, различия ОС).

## Зачем нужен

Одинаковые настройки shell, редакторов и CLI-утилит на нескольких машинах без ручного копирования файлов.

## Примеры

```bash
chezmoi init
chezmoi add ~/.zshrc
chezmoi apply
chezmoi update
```

Если репозиторий уже есть на GitHub:

```bash
chezmoi init --apply https://github.com/<user>/dotfiles.git
```

## Установка через CLI Toolbox

```bash
./install.sh --only chezmoi
./install.sh --update --only chezmoi
```

Toolbox ставит только бинарник; `init` / `apply` — отдельно, чтобы не перезаписать локальные конфиги.

Определение пакета: [`catalog/tools/chezmoi.yaml`](../../catalog/tools/chezmoi.yaml).

## Ссылки

- [chezmoi.io](https://www.chezmoi.io/)
- [GitHub](https://github.com/twpayne/chezmoi)
