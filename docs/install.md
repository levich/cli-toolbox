# Установка и обновление

CLI Toolbox ставит и обновляет утилиты из расширяемого каталога [`catalog/tools/`](../catalog/tools/).

## Поддерживаемые платформы

| Платформа | Package manager |
|-----------|-----------------|
| macOS | Homebrew (ставится автоматически при необходимости) |
| Ubuntu / Debian / Mint / Pop!_OS / WSL | apt |
| Alpine | apk |
| Arch / Manjaro | pacman |
| Fedora / RHEL / Rocky / Alma | dnf (или yum) |
| ALT Linux | apt |
| openSUSE | zypper |

**Windows:** только через [WSL](https://learn.microsoft.com/windows/wsl/) (как Linux). Native Windows не поддерживается.

## Быстрый старт

```bash
git clone <url-репозитория> cli-toolbox
cd cli-toolbox
./install.sh --list                 # каталог и статус
./install.sh --profile cli,dev      # профили
./install.sh --interactive          # ручной выбор
```

## Опции

```text
./install.sh [опции]

  --profile LIST     shell,cli,dev,desktop,admin,all (через запятую)
  --only LIST        только указанные id
  --exclude LIST     исключить id
  --interactive, -i  выбор через fzf или нумерованное меню
  --update           обновить выбранные (или доустановить)
  --list             показать каталог
  --installed        только установленные утилиты
  --installed-ids    только id установленных (по одному на строку)
  --remove           удалить выбранные утилиты
  --yes, -y          не спрашивать подтверждение при удалении
  --dry-run          не выполнять, только показать
  --force            переустановить даже если уже есть
  --tips-only        только рекомендации (без установки)
  --save-tips [FILE] сохранить рекомендации (по умолчанию cli-toolbox-tips.md)
  --no-tips          не печатать рекомендации после установки
  -h, --help         справка
```

## Профили

Определены в [`catalog/profiles.yaml`](../catalog/profiles.yaml):

| Профиль | Назначение |
|---------|------------|
| `shell` | zsh, Oh My Zsh, Powerlevel10k |
| `cli` | повседневные CLI-утилиты |
| `dev` | git, neovim, uv, lazygit, редакторы… |
| `desktop` | терминалы, IDE, Postman, DBeaver… |
| `admin` | администрирование серверов (мониторинг, сеть, диски, редакторы, без GUI) |
| `all` | весь каталог |

По умолчанию (без `--profile` и `--only`) ставится **всё совместимое** с текущей ОС.

## Список установленных

```bash
./install.sh --installed                 # таблица установленных из всего каталога
./install.sh --installed --profile admin # только из профиля admin
./install.sh --installed-ids             # только id (удобно для скриптов)
./install.sh --list                      # весь каталог: installed/missing
```

## Удаление

```bash
./install.sh --remove --only bat,fzf      # с подтверждением
./install.sh --remove --only micro -y     # без вопроса
./install.sh --remove --profile cli --yes
./install.sh --remove --interactive
./install.sh --dry-run --remove --only htop
```

Для `--remove` обязательно укажите `--only`, `--profile` или `--interactive` (защита от удаления всего каталога).

## Рекомендации после установки

После успешной установки или обновления установщик печатает:

- ссылку на локальную страницу `docs/tools/<id>.md`
- официальную документацию (`docs_url` из каталога)
- советы по настройке (`tips` из YAML)

```bash
./install.sh --profile shell                  # показать tips в терминале
./install.sh --profile admin --save-tips      # + файл cli-toolbox-tips.md
./install.sh --save-tips ~/my-tips.md --only zoxide,fzf
./install.sh --tips-only --profile shell      # только рекомендации
./install.sh --no-tips --profile cli          # установка без tips
```

Поля в каталоге:

```yaml
docs_url: https://example.com/docs
tips:
  - Добавьте в ~/.zshrc: …
  - См. man-страницу утилиты
```

## Порядок выбора набора

1. База: `--only` **или** `--profile` **или** все инструменты.
2. Вычитание `--exclude`.
3. При `--interactive` — ручная правка списка.

Несовместимые пакеты (например `nala` вне Debian/Ubuntu, `gnome-tweaks` без GUI) пропускаются с пометкой `[skip]`.

## Обновление

```bash
./install.sh --update
./install.sh --update --profile cli
./install.sh --update --only bat,fzf
```

- Пакеты PM: `brew upgrade` / `apt install --only-upgrade` / `pacman` / `apk` / `dnf`…
- Кастомные (Oh My Zsh, uv, Cursor…): idempotent-скрипты в `lib/custom/`.

## Расширение каталога

Минимальный YAML:

```yaml
id: mytool
name: mytool
summary: Краткое описание
category: cli
profiles: [cli]
check: mytool
packages:
  brew: mytool
  apt: mytool
  pacman: mytool
  apk: mytool
  dnf: mytool
docs_url: https://example.com
tips:
  - Как настроить после установки
```

Опционально:

```yaml
custom: mytool          # lib/custom/mytool.sh
needs: [git]
platforms: [debian, ubuntu]
skip_on: [macos]
requires_desktop: true
```

Кастомный скрипт получает `TB_ACTION=install|update` и функции из `lib/` (через `source`).

После добавления YAML обновления установщика не требуются — достаточно положить файл в `catalog/tools/`.
