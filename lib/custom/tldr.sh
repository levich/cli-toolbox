#!/usr/bin/env bash
# tldr client — prefer tealdeer / tldr package, else npm/cargo

_tldr_install() {
  if have_cmd tldr && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "tldr уже установлен"
    return 0
  fi

  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    if pm_install_pkg "$pkg"; then
      return 0
    fi
  fi

  if have_cmd cargo; then
    cargo install tealdeer
    return
  fi

  if have_cmd npm; then
    npm install -g tldr
    return
  fi

  die "Не удалось установить tldr (нужен brew/apt/cargo/npm)"
}

_tldr_update() {
  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_update_pkg "$pkg" || true
  fi
  if have_cmd tldr; then
    tldr --update 2>/dev/null || true
  fi
}

case "${TB_ACTION:-install}" in
  update) _tldr_update ;;
  *)      _tldr_install ;;
esac
