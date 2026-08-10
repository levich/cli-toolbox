#!/usr/bin/env bash
# Alacritty — PM first, else cargo

_alacritty_install() {
  if tool_is_installed && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "Alacritty уже установлен"
    return 0
  fi

  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_install_pkg "$pkg" && return 0
  fi

  if [[ "$TB_PM" == "apt" ]]; then
    # Often missing or old on Debian — try cargo
    if have_cmd cargo; then
      cargo install alacritty
      return
    fi
  fi

  die "Не удалось установить Alacritty через $TB_PM. См. https://alacritty.org/"
}

_alacritty_update() {
  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_update_pkg "$pkg" && return 0
  fi
  if have_cmd cargo && [[ -x "${CARGO_HOME:-$HOME/.cargo}/bin/alacritty" ]]; then
    cargo install alacritty
    return
  fi
  _alacritty_install
}

case "${TB_ACTION:-install}" in
  update) _alacritty_update ;;
  *)      _alacritty_install ;;
esac
