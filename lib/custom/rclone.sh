#!/usr/bin/env bash
# rclone

_rclone_install() {
  if have_cmd rclone && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "rclone уже установлен"
    return 0
  fi

  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_install_pkg "$pkg" && return 0
  fi

  download_pipe https://rclone.org/install.sh | run_as_root bash
}

_rclone_update() {
  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_update_pkg "$pkg" && return 0
  fi
  if have_cmd rclone; then
    rclone selfupdate 2>/dev/null || download_pipe https://rclone.org/install.sh | run_as_root bash
    return
  fi
  _rclone_install
}

case "${TB_ACTION:-install}" in
  update) _rclone_update ;;
  *)      _rclone_install ;;
esac
