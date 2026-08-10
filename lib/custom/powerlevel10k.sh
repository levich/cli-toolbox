#!/usr/bin/env bash
# Powerlevel10k theme

P10K_DIR="${POWERLEVEL10K_DIR:-$HOME/.oh-my-zsh/custom/themes/powerlevel10k}"

_p10k_install() {
  have_cmd git || die "powerlevel10k требует git"
  if [[ -d "$P10K_DIR/.git" ]]; then
    log_ok "powerlevel10k уже в $P10K_DIR"
    return 0
  fi
  ensure_dir "$(dirname "$P10K_DIR")"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  log_info "Добавьте в ~/.zshrc: ZSH_THEME=\"powerlevel10k/powerlevel10k\""
}

_p10k_update() {
  if [[ ! -d "$P10K_DIR/.git" ]]; then
    _p10k_install
    return
  fi
  git -C "$P10K_DIR" pull --rebase --autostash
}

case "${TB_ACTION:-install}" in
  update) _p10k_update ;;
  *)      _p10k_install ;;
esac
