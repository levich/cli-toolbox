#!/usr/bin/env bash
# Insomnia

_insomnia_install() {
  if tool_is_installed && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "Insomnia уже установлена"
    return 0
  fi

  if [[ "$TB_IS_MACOS" -eq 1 ]]; then
    ensure_brew
    brew_noconfirm install --cask insomnia
    return
  fi

  if have_cmd flatpak; then
    flatpak install -y --noninteractive flathub rest.insomnia.Insomnia
    return
  fi

  if [[ "$TB_PM" == "apt" ]]; then
    log_warn "Insomnia: предпочтительно Flatpak. Пробую .deb с GitHub releases…"
    local tmp arch deb_url
    tmp="$(mktemp -d)"
    arch="$(dpkg --print-architecture)"
    deb_url="$(download_pipe https://api.github.com/repos/Kong/insomnia/releases/latest \
      | grep -oE "https://[^\"]+insomnia_[^\"]+_${arch}\.deb" | head -1 || true)"
    if [[ -n "$deb_url" ]]; then
      download "$deb_url" "$tmp/insomnia.deb"
      apt_noconfirm install "$tmp/insomnia.deb"
      rm -rf "$tmp"
      return
    fi
    rm -rf "$tmp"
  fi

  die "Установите Insomnia вручную: https://insomnia.rest/download"
}

_insomnia_update() {
  if [[ "$TB_IS_MACOS" -eq 1 ]]; then
    brew_noconfirm upgrade --cask insomnia 2>/dev/null || _insomnia_install
    return
  fi
  if have_cmd flatpak; then
    flatpak update -y --noninteractive rest.insomnia.Insomnia || true
    return
  fi
  _insomnia_install
}

case "${TB_ACTION:-install}" in
  update) _insomnia_update ;;
  *)      _insomnia_install ;;
esac
