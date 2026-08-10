#!/usr/bin/env bash
# mdcat

_mdcat_install() {
  if have_cmd mdcat && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "mdcat уже установлен"
    return 0
  fi

  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_install_pkg "$pkg" && return 0
  fi

  if have_cmd cargo; then
    cargo install mdcat
    return
  fi

  die "Установите mdcat через brew/pacman или cargo install mdcat"
}

_mdcat_update() {
  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_update_pkg "$pkg" && return 0
  fi
  if have_cmd cargo; then
    cargo install mdcat
    return
  fi
  _mdcat_install
}

case "${TB_ACTION:-install}" in
  update) _mdcat_update ;;
  *)      _mdcat_install ;;
esac
