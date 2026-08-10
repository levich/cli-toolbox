#!/usr/bin/env bash
# lazydocker

_lazydocker_install() {
  if have_cmd lazydocker && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "lazydocker уже установлен"
    return 0
  fi

  if [[ "$TB_PM" == "brew" ]] || [[ "$TB_IS_MACOS" -eq 1 ]]; then
    ensure_brew
    brew_noconfirm install lazydocker
    return
  fi

  download_pipe https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install.sh | bash
}

_lazydocker_update() {
  if [[ "$TB_PM" == "brew" ]] || [[ "$TB_IS_MACOS" -eq 1 ]]; then
    brew_noconfirm upgrade lazydocker 2>/dev/null || _lazydocker_install
    return
  fi
  TB_FORCE=1 _lazydocker_install
}

case "${TB_ACTION:-install}" in
  update) _lazydocker_update ;;
  *)      _lazydocker_install ;;
esac
