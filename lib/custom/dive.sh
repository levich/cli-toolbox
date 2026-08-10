#!/usr/bin/env bash
# dive — Docker image explorer

_dive_install() {
  if have_cmd dive && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "dive уже установлен"
    return 0
  fi

  if [[ "$TB_PM" == "brew" ]] || [[ "$TB_IS_MACOS" -eq 1 ]]; then
    ensure_brew
    brew_noconfirm install dive
    return
  fi

  if [[ "$TB_PM" == "apt" ]]; then
    local tmp ver arch deb
    tmp="$(mktemp -d)"
    ver="$(download_pipe https://api.github.com/repos/wagoodman/dive/releases/latest \
      | grep -oE '"tag_name":\s*"v[^"]+"' | head -1 | sed 's/.*"v//;s/"//')"
    arch="$(dpkg --print-architecture)"
    if [[ -n "$ver" ]]; then
      deb="https://github.com/wagoodman/dive/releases/download/v${ver}/dive_${ver}_linux_${arch}.deb"
      download "$deb" "$tmp/dive.deb" 2>/dev/null || true
      if [[ -f "$tmp/dive.deb" ]]; then
        apt_noconfirm install "$tmp/dive.deb"
        rm -rf "$tmp"
        return
      fi
    fi
    rm -rf "$tmp"
  fi

  die "Установите dive вручную: https://github.com/wagoodman/dive"
}

_dive_update() {
  if [[ "$TB_PM" == "brew" ]] || [[ "$TB_IS_MACOS" -eq 1 ]]; then
    brew_noconfirm upgrade dive 2>/dev/null || _dive_install
    return
  fi
  TB_FORCE=1 _dive_install
}

case "${TB_ACTION:-install}" in
  update) _dive_update ;;
  *)      _dive_install ;;
esac
