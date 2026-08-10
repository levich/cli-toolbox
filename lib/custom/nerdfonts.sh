#!/usr/bin/env bash
# Nerd Fonts — MesloLGS (рекомендован Powerlevel10k)

NERD_FONT_NAME="MesloLGS Nerd Font"
NERD_RELEASE="v3.3.0"

_nerdfonts_linux_dir() {
  printf '%s' "${XDG_DATA_HOME:-$HOME/.local/share}/fonts/NerdFonts"
}

_nerdfonts_is_installed() {
  if [[ "$TB_IS_MACOS" -eq 1 ]]; then
    if [[ -d "$HOME/Library/Fonts" ]] && ls "$HOME/Library/Fonts"/MesloLGSNerdFont*.ttf >/dev/null 2>&1; then
      return 0
    fi
    if brew list --cask font-meslo-lg-nerd-font >/dev/null 2>&1; then
      return 0
    fi
    return 1
  fi
  local dir
  dir="$(_nerdfonts_linux_dir)"
  [[ -d "$dir" ]] && ls "$dir"/MesloLGSNerdFont*.ttf >/dev/null 2>&1
}

_nerdfonts_install() {
  if _nerdfonts_is_installed && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "Nerd Fonts (MesloLGS) уже установлены"
    return 0
  fi

  if [[ "$TB_IS_MACOS" -eq 1 ]]; then
    ensure_brew
    brew_noconfirm install --cask font-meslo-lg-nerd-font
    log_info "В терминале выберите шрифт: ${NERD_FONT_NAME}"
    return
  fi

  local dest tmp url
  dest="$(_nerdfonts_linux_dir)"
  ensure_dir "$dest"
  tmp="$(mktemp -d)"
  url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_RELEASE}/Meslo.zip"
  download "$url" "$tmp/Meslo.zip"
  if ! have_cmd unzip; then
    die "Для установки Nerd Fonts нужен unzip"
  fi
  unzip -o -q "$tmp/Meslo.zip" -d "$tmp/out"
  find "$tmp/out" -type f \( -name '*.ttf' -o -name '*.otf' \) -exec cp {} "$dest/" \;
  rm -rf "$tmp"
  if have_cmd fc-cache; then
    fc-cache -f "$dest" >/dev/null 2>&1 || true
  fi
  log_ok "Шрифты установлены в $dest"
  log_info "В терминале выберите шрифт: ${NERD_FONT_NAME}"
}

_nerdfonts_update() {
  TB_FORCE=1 _nerdfonts_install
}

case "${TB_ACTION:-install}" in
  update) _nerdfonts_update ;;
  *)      _nerdfonts_install ;;
esac
