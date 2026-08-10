#!/usr/bin/env bash
# asciinema

_asciinema_install() {
  if have_cmd asciinema && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "asciinema уже установлен"
    return 0
  fi

  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_install_pkg "$pkg" && return 0
  fi

  if have_cmd pipx; then
    pipx install asciinema
    return
  fi
  if have_cmd pip3; then
    pip3 install --user --upgrade asciinema
    return
  fi

  die "Установите asciinema через PM или pip"
}

_asciinema_update() {
  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_update_pkg "$pkg" && return 0
  fi
  if have_cmd pipx; then
    pipx upgrade asciinema || true
    return
  fi
  if have_cmd pip3; then
    pip3 install --user --upgrade asciinema
    return
  fi
  _asciinema_install
}

case "${TB_ACTION:-install}" in
  update) _asciinema_update ;;
  *)      _asciinema_install ;;
esac
