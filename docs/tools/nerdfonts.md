# Nerd Fonts

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `nerdfonts`

## Что это

Набор патченных шрифтов с глифами для иконок в терминале и статус-барах. Toolbox ставит **MesloLGS Nerd Font** (рекомендация Powerlevel10k).

## Зачем нужен

Корректное отображение иконок в Powerlevel10k, eza, neovim-плагинах и прочих TUI.

## Примеры

```bash
# После установки выберите в настройках терминала:
# MesloLGS Nerd Font / MesloLGS NF
```

## Установка через CLI Toolbox

```bash
./install.sh --only nerdfonts
./install.sh --profile shell
```

- macOS: Homebrew cask `font-meslo-lg-nerd-font`
- Linux: загрузка в `~/.local/share/fonts/NerdFonts` + `fc-cache`

Определение: [`catalog/tools/nerdfonts.yaml`](../../catalog/tools/nerdfonts.yaml).

## Ссылки

- [nerdfonts.com](https://www.nerdfonts.com/)
- [GitHub](https://github.com/ryanoasis/nerd-fonts)
