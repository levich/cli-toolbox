# Документация CLI Toolbox

Набор описаний утилит и инструкция по установщику.

- [Установка и обновление](install.md)
- Каталог определений: [`catalog/tools/`](../catalog/tools/)
- Профили: [`catalog/profiles.yaml`](../catalog/profiles.yaml)

## Shell

| Утилита | Описание |
|---------|----------|
| [zsh](tools/zsh.md) | Интерактивная оболочка |
| [Oh My Zsh](tools/oh-my-zsh.md) | Фреймворк конфигурации zsh |
| [Powerlevel10k](tools/powerlevel10k.md) | Быстрая тема для zsh |
| [chezmoi](tools/chezmoi.md) | Менеджер dotfiles |
| [Nerd Fonts](tools/nerdfonts.md) | Шрифты с иконками |
| [tmux](tools/tmux.md) | Мультиплексор терминала |
| [atuin](tools/atuin.md) | Умная история shell |
| [tldr](tools/tldr.md) | Краткие примеры команд |
| [curl](tools/curl.md) | HTTP/URL клиент |

## CLI

| Утилита | Описание |
|---------|----------|
| [fzf](tools/fzf.md) | Fuzzy-finder |
| [eza](tools/eza.md) | Современная замена ls |
| [fastfetch](tools/fastfetch.md) | Информация о системе |
| [bat](tools/bat.md) | cat с подсветкой |
| [ripgrep](tools/ripgrep.md) | Быстрый поиск по коду |
| [fd](tools/fd.md) | Быстрый поиск файлов |
| [zoxide](tools/zoxide.md) | Умный cd |
| [jq](tools/jq.md) | JSON в CLI |
| [yq](tools/yq.md) | YAML в CLI |
| [duf](tools/duf.md) | Использование дисков |
| [ncdu](tools/ncdu.md) | Анализ места на диске |
| [micro](tools/micro.md) | Простой текстовый редактор |
| [btop](tools/btop.md) | Монитор ресурсов |
| [htop](tools/htop.md) | Монитор процессов |
| [mc](tools/mc.md) | Midnight Commander |
| [nnn](tools/nnn.md) | Лёгкий файловый менеджер |
| [iotop](tools/iotop.md) | Мониторинг I/O |
| [net-tools](tools/net-tools.md) | ifconfig, netstat |
| [iproute2](tools/iproute2.md) | ip, ss, tc |
| [nala](tools/nala.md) | Фронтенд apt (Debian/Ubuntu) |
| [iperf](tools/iperf.md) | Пропускная способность сети |
| [Bitwarden CLI](tools/bitwarden.md) | Менеджер паролей (bw) |
| [7-Zip](tools/7zip.md) | Архиватор 7z |
| [nvtop](tools/nvtop.md) | TUI-монитор GPU |
| [nvitop](tools/nvitop.md) | Монитор NVIDIA GPU |
| [delta](tools/delta.md) | Красивый git-diff |
| [difftastic](tools/difftastic.md) | Структурный diff (difft) |
| [xh](tools/xh.md) | HTTP-клиент |
| [rsync](tools/rsync.md) | Синхронизация файлов |
| [mtr](tools/mtr.md) | traceroute + ping |
| [asciinema](tools/asciinema.md) | Запись сессий |
| [rclone](tools/rclone.md) | Облачный rsync |
| [nmap](tools/nmap.md) | Сканер сети |
| [lsof](tools/lsof.md) | Открытые файлы/порты |
| [tcpdump](tools/tcpdump.md) | Захват трафика |
| [wget](tools/wget.md) | Загрузка файлов |
| [mdcat](tools/mdcat.md) | Markdown в терминале |
| [w3m](tools/w3m.md) | TUI-браузер |

## Dev

| Утилита | Описание |
|---------|----------|
| [git](tools/git.md) | Система контроля версий |
| [Python](tools/python.md) | Интерпретатор Python 3 |
| [pip](tools/pip.md) | Установщик пакетов Python |
| [Neovim](tools/neovim.md) | Редактор |
| [uv](tools/uv.md) | Менеджер Python-пакетов |
| [lazygit](tools/lazygit.md) | TUI для Git |
| [lazydocker](tools/lazydocker.md) | TUI для Docker |
| [topgrade](tools/topgrade.md) | Обновление всего ПО |
| [VS Code](tools/code.md) | Редактор кода |
| [Cursor](tools/cursor.md) | AI-редактор |
| [GitHub CLI](tools/gh.md) | gh |
| [dive](tools/dive.md) | Анализ Docker-образов |

## Desktop

| Утилита | Описание |
|---------|----------|
| [Alacritty](tools/alacritty.md) | GPU-терминал |
| [kitty](tools/kitty.md) | Feature-rich терминал |
| [DBeaver](tools/dbeaver.md) | GUI-клиент БД |
| [Postman](tools/postman.md) | HTTP/API клиент |
| [Insomnia](tools/insomnia.md) | HTTP/API клиент |
| [GNOME Tweaks](tools/gnome-tweaks.md) | Настройки GNOME |
| [Nerd Fonts](tools/nerdfonts.md) | Шрифты с иконками |

## Как добавить инструмент

1. Создайте `catalog/tools/<id>.yaml`.
2. При необходимости — `lib/custom/<id>.sh`.
3. Добавьте id в нужные профили в `catalog/profiles.yaml`.
4. Напишите `docs/tools/<id>.md` и строку в этой таблице.
