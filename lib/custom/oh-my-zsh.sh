#!/usr/bin/env bash
# Oh My Zsh — custom install/update
# Expects TB_ACTION=install|update

OMZ_DIR="${ZSH:-$HOME/.oh-my-zsh}"

_omz_install() {
  if [[ -d "$OMZ_DIR" ]]; then
    log_ok "Oh My Zsh уже в $OMZ_DIR"
    return 0
  fi
  have_cmd git || die "oh-my-zsh требует git"
  have_cmd zsh || log_warn "zsh ещё не установлен — поставьте профиль shell"

  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(download_pipe https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

_omz_update() {
  if [[ ! -d "$OMZ_DIR" ]]; then
    _omz_install
    return
  fi
  if [[ -x "$OMZ_DIR/tools/upgrade.sh" ]]; then
    "$OMZ_DIR/tools/upgrade.sh" || git -C "$OMZ_DIR" pull --rebase --autostash
  else
    git -C "$OMZ_DIR" pull --rebase --autostash
  fi
}

case "${TB_ACTION:-install}" in
  update) _omz_update ;;
  *)      _omz_install ;;
esac
