#!/usr/bin/env bash
# uv — https://docs.astral.sh/uv/

_uv_install() {
  if have_cmd uv && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "uv уже установлен: $(uv --version 2>/dev/null || true)"
    return 0
  fi
  if [[ "$TB_PM" == "brew" ]] && have_cmd brew; then
    brew_noconfirm install uv
    return
  fi
  download_pipe https://astral.sh/uv/install.sh | sh
}

_uv_update() {
  if have_cmd uv; then
    uv self update 2>/dev/null || _uv_install
  else
    _uv_install
  fi
}

case "${TB_ACTION:-install}" in
  update) _uv_update ;;
  *)      _uv_install ;;
esac
