#!/usr/bin/env bash
# DBeaver Community

_dbeaver_install() {
  if tool_is_installed && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "DBeaver уже установлен"
    return 0
  fi

  if [[ "$TB_IS_MACOS" -eq 1 ]]; then
    ensure_brew
    brew_noconfirm install --cask dbeaver-community
    return
  fi

  if have_cmd flatpak; then
    flatpak install -y --noninteractive flathub io.dbeaver.DBeaverCommunity
    return
  fi

  if [[ "$TB_PM" == "apt" ]]; then
    local tmp
    tmp="$(mktemp -d)"
    download "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" "$tmp/dbeaver.deb"
    apt_noconfirm install "$tmp/dbeaver.deb"
    rm -rf "$tmp"
    return
  fi

  if [[ "$TB_PM" == "dnf" || "$TB_PM" == "yum" ]]; then
    run_as_root "$TB_PM" install -y "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm"
    return
  fi

  die "Установите DBeaver вручную: https://dbeaver.io/download/"
}

_dbeaver_update() {
  if [[ "$TB_IS_MACOS" -eq 1 ]]; then
    brew_noconfirm upgrade --cask dbeaver-community 2>/dev/null || _dbeaver_install
    return
  fi
  if have_cmd flatpak; then
    flatpak update -y --noninteractive io.dbeaver.DBeaverCommunity || true
    return
  fi
  _dbeaver_install
}

case "${TB_ACTION:-install}" in
  update) _dbeaver_update ;;
  *)      _dbeaver_install ;;
esac
