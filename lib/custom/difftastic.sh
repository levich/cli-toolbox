#!/usr/bin/env bash
# difftastic (difft)

_difft_install() {
  if have_cmd difft && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "difftastic уже установлен"
    return 0
  fi

  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_install_pkg "$pkg" && return 0
  fi

  if have_cmd cargo; then
    cargo install difftastic
    return
  fi

  die "Установите difftastic через brew/pacman или cargo install difftastic"
}

_difft_update() {
  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_update_pkg "$pkg" && return 0
  fi
  if have_cmd cargo; then
    cargo install difftastic
    return
  fi
  _difft_install
}

case "${TB_ACTION:-install}" in
  update) _difft_update ;;
  *)      _difft_install ;;
esac
