#!/usr/bin/env bash
# xh — friendly HTTP client

_xh_install() {
  if have_cmd xh && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "xh уже установлен"
    return 0
  fi

  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_install_pkg "$pkg" && return 0
  fi

  if [[ "$TB_IS_LINUX" -eq 1 ]]; then
    local dest="$HOME/.local/bin" tmp arch url
    ensure_dir "$dest"
    tmp="$(mktemp -d)"
    arch="x86_64-unknown-linux-musl"
    if [[ "$TB_ARCH" == "aarch64" || "$TB_ARCH" == "arm64" ]]; then
      arch="aarch64-unknown-linux-musl"
    fi
    url="$(download_pipe https://api.github.com/repos/ducaale/xh/releases/latest \
      | grep -oE "https://[^\"]+xh-[^\"]+${arch}\\.tar\\.gz" | head -1 || true)"
    if [[ -n "$url" ]]; then
      download "$url" "$tmp/xh.tar.gz"
      tar -xzf "$tmp/xh.tar.gz" -C "$tmp"
      find "$tmp" -type f -name xh -exec install -m 755 {} "$dest/xh" \;
      rm -rf "$tmp"
      log_ok "xh → $dest/xh"
      return 0
    fi
    rm -rf "$tmp"
  fi

  if have_cmd cargo; then
    cargo install xh
    return
  fi

  die "Установите xh вручную: https://github.com/ducaale/xh"
}

_xh_update() {
  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_update_pkg "$pkg" && return 0
  fi
  TB_FORCE=1 _xh_install
}

case "${TB_ACTION:-install}" in
  update) _xh_update ;;
  *)      _xh_install ;;
esac
