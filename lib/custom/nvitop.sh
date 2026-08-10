#!/usr/bin/env bash
# nvitop — NVIDIA GPU monitor via pip/uv

_nvitop_install() {
  if have_cmd nvitop && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "nvitop уже установлен"
    return 0
  fi

  if have_cmd uv; then
    uv tool install nvitop
    return
  fi

  if have_cmd pipx; then
    pipx install nvitop
    return
  fi

  if have_cmd pip3; then
    pip3 install --user --upgrade nvitop
    return
  fi

  if have_cmd pip; then
    pip install --user --upgrade nvitop
    return
  fi

  die "Для nvitop нужны uv, pipx или pip"
}

_nvitop_update() {
  if have_cmd uv; then
    uv tool upgrade nvitop 2>/dev/null || uv tool install nvitop
    return
  fi
  if have_cmd pipx; then
    pipx upgrade nvitop || true
    return
  fi
  if have_cmd pip3; then
    pip3 install --user --upgrade nvitop
    return
  fi
  if have_cmd pip; then
    pip install --user --upgrade nvitop
    return
  fi
  _nvitop_install
}

case "${TB_ACTION:-install}" in
  update) _nvitop_update ;;
  *)      _nvitop_install ;;
esac
