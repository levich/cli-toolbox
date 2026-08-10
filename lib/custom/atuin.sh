#!/usr/bin/env bash
# atuin — shell history

_atuin_install() {
  if have_cmd atuin && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "atuin уже установлен"
    return 0
  fi

  if [[ "$TB_PM" == "brew" ]] || [[ "$TB_IS_MACOS" -eq 1 ]]; then
    ensure_brew
    brew_noconfirm install atuin
    return
  fi

  download_pipe https://setup.atuin.sh | sh
}

_atuin_update() {
  if [[ "$TB_PM" == "brew" ]] || [[ "$TB_IS_MACOS" -eq 1 ]]; then
    brew_noconfirm upgrade atuin 2>/dev/null || _atuin_install
    return
  fi
  if have_cmd atuin; then
    # re-run installer is typical upgrade path
    download_pipe https://setup.atuin.sh | sh
    return
  fi
  _atuin_install
}

case "${TB_ACTION:-install}" in
  update) _atuin_update ;;
  *)      _atuin_install ;;
esac
