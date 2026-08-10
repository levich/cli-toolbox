#!/usr/bin/env bash
# Postman

_postman_install() {
  if tool_is_installed && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "Postman уже установлен"
    return 0
  fi

  if [[ "$TB_IS_MACOS" -eq 1 ]]; then
    ensure_brew
    brew_noconfirm install --cask postman
    return
  fi

  if have_cmd flatpak; then
    flatpak install -y --noninteractive flathub com.getpostman.Postman
    return
  fi

  if [[ "$TB_IS_LINUX" -eq 1 ]]; then
    local dest="$HOME/.local/share/Postman"
    ensure_dir "$HOME/.local/share"
    local tmp
    tmp="$(mktemp -d)"
    download "https://dl.pstmn.io/download/latest/linux64" "$tmp/postman.tar.gz"
    tar -xzf "$tmp/postman.tar.gz" -C "$HOME/.local/share"
    ensure_dir "$HOME/.local/bin"
    ln -sfn "$HOME/.local/share/Postman/Postman" "$HOME/.local/bin/postman"
    rm -rf "$tmp"
    log_ok "Postman в $dest"
    return
  fi

  die "Установите Postman вручную: https://www.postman.com/downloads/"
}

_postman_update() {
  if [[ "$TB_IS_MACOS" -eq 1 ]]; then
    brew_noconfirm upgrade --cask postman 2>/dev/null || _postman_install
    return
  fi
  if have_cmd flatpak; then
    flatpak update -y --noninteractive com.getpostman.Postman || true
    return
  fi
  _postman_install
}

case "${TB_ACTION:-install}" in
  update) _postman_update ;;
  *)      _postman_install ;;
esac
