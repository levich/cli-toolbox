#!/usr/bin/env bash
# Bitwarden CLI (bw)

_bw_install_bin() {
  local dest="$HOME/.local/bin"
  ensure_dir "$dest"
  local tmp platform url
  tmp="$(mktemp -d)"

  if [[ "$TB_IS_MACOS" -eq 1 ]]; then
    platform="macos"
  else
    platform="linux"
  fi

  # Official redirect download (x64 native zip). arm64: prefer brew/npm.
  if [[ "$TB_ARCH" == "arm64" || "$TB_ARCH" == "aarch64" ]]; then
    if have_cmd npm; then
      npm install -g @bitwarden/cli
      rm -rf "$tmp"
      return
    fi
    if [[ "$TB_IS_MACOS" -eq 1 ]]; then
      ensure_brew
      brew_noconfirm install bitwarden-cli
      rm -rf "$tmp"
      return
    fi
    log_warn "На arm64 предпочтителен npm: npm install -g @bitwarden/cli"
  fi

  url="https://vault.bitwarden.com/download/?app=cli&platform=${platform}"
  download "$url" "$tmp/bw.zip"
  if have_cmd unzip; then
    unzip -o -q "$tmp/bw.zip" -d "$tmp"
  else
    die "Для установки Bitwarden CLI нужен unzip"
  fi
  local bin
  bin="$(find "$tmp" -type f -name bw | head -1)"
  [[ -n "$bin" ]] || die "В архиве Bitwarden CLI не найден бинарник bw"
  install -m 755 "$bin" "$dest/bw"
  rm -rf "$tmp"
  log_ok "bw установлен в $dest/bw (добавьте ~/.local/bin в PATH при необходимости)"
}

_bw_install() {
  if have_cmd bw && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "Bitwarden CLI уже установлен: $(bw --version 2>/dev/null | head -1 || true)"
    return 0
  fi

  if [[ "$TB_PM" == "brew" ]] || [[ "$TB_IS_MACOS" -eq 1 ]]; then
    ensure_brew
    brew_noconfirm install bitwarden-cli
    return
  fi

  if have_cmd snap; then
    run_as_root snap install bw
    return
  fi

  _bw_install_bin
}

_bw_update() {
  if [[ "$TB_PM" == "brew" ]] || [[ "$TB_IS_MACOS" -eq 1 ]]; then
    if have_cmd brew; then
      brew_noconfirm upgrade bitwarden-cli 2>/dev/null || _bw_install
      return
    fi
  fi
  if have_cmd snap; then
    run_as_root snap refresh bw || true
    return
  fi
  if have_cmd npm && npm list -g @bitwarden/cli >/dev/null 2>&1; then
    npm update -g @bitwarden/cli
    return
  fi
  # Re-download binary
  TB_FORCE=1 _bw_install_bin
}

case "${TB_ACTION:-install}" in
  update) _bw_update ;;
  *)      _bw_install ;;
esac
