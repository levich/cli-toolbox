#!/usr/bin/env bash
# Cursor editor

_cursor_install() {
  if tool_is_installed && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "Cursor уже установлен"
    return 0
  fi

  if [[ "$TB_IS_MACOS" -eq 1 ]]; then
    ensure_brew
    if brew_noconfirm info --cask cursor >/dev/null 2>&1; then
      brew_noconfirm install --cask cursor
      return
    fi
  fi

  if [[ "$TB_IS_LINUX" -eq 1 ]]; then
    log_info "Скачиваю Cursor AppImage…"
    local dest="$HOME/.local/bin"
    ensure_dir "$dest"
    local url="https://downloader.cursor.sh/linux/appImage/x64"
    if [[ "$TB_ARCH" == "aarch64" || "$TB_ARCH" == "arm64" ]]; then
      url="https://downloader.cursor.sh/linux/appImage/arm64"
    fi
    download "$url" "$dest/cursor.AppImage"
    chmod +x "$dest/cursor.AppImage"
    ln -sfn "$dest/cursor.AppImage" "$dest/cursor"
    log_ok "Cursor установлен в $dest/cursor (добавьте ~/.local/bin в PATH)"
    return
  fi

  die "Установите Cursor вручную: https://cursor.com/"
}

_cursor_update() {
  if [[ "$TB_IS_MACOS" -eq 1 ]] && have_cmd brew; then
    brew_noconfirm upgrade --cask cursor 2>/dev/null || _cursor_install
    return
  fi
  _cursor_install
}

case "${TB_ACTION:-install}" in
  update) _cursor_update ;;
  *)      _cursor_install ;;
esac
