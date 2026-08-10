#!/usr/bin/env bash
# topgrade — fallback when not in distro repos

_topgrade_from_cargo() {
  if have_cmd cargo; then
    cargo install topgrade
    return
  fi
  return 1
}

_topgrade_install() {
  if have_cmd topgrade && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "topgrade уже установлен"
    return 0
  fi
  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_install_pkg "$pkg" && return 0
  fi
  if [[ "$TB_PM" == "brew" ]]; then
    brew_noconfirm install topgrade && return 0
  fi
  log_warn "Пробую установить topgrade через cargo…"
  _topgrade_from_cargo || die "Не удалось установить topgrade. Установите вручную: https://github.com/topgrade-rs/topgrade"
}

_topgrade_update() {
  if have_cmd topgrade; then
    local pkg
    pkg="$(tool_pkg_for_pm)"
    if [[ -n "$pkg" ]]; then
      pm_update_pkg "$pkg" && return 0
    fi
    if have_cmd cargo && [[ -x "${CARGO_HOME:-$HOME/.cargo}/bin/topgrade" ]]; then
      cargo install topgrade
      return
    fi
  fi
  _topgrade_install
}

case "${TB_ACTION:-install}" in
  update) _topgrade_update ;;
  *)      _topgrade_install ;;
esac
