#!/usr/bin/env bash
# VS Code

_code_install() {
  if have_cmd code && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "VS Code уже установлен"
    return 0
  fi

  if [[ "$TB_IS_MACOS" -eq 1 ]]; then
    ensure_brew
    brew_noconfirm install --cask visual-studio-code
    return
  fi

  if [[ "$TB_PM" == "apt" ]]; then
    if ! have_cmd code; then
      download_pipe https://packages.microsoft.com/keys/microsoft.asc \
        | run_as_root gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/code stable main" \
        | run_as_root tee /etc/apt/sources.list.d/vscode.list >/dev/null
      apt_noconfirm update -qq
      apt_noconfirm install code
    fi
    return
  fi

  if [[ "$TB_PM" == "pacman" ]]; then
    log_warn "На Arch обычно ставят code из AUR (visual-studio-code-bin). Пробую code…"
    run_as_root pacman -Sy --noconfirm --needed code 2>/dev/null \
      || die "Установите VS Code из AUR: visual-studio-code-bin"
    return
  fi

  if [[ "$TB_PM" == "dnf" || "$TB_PM" == "yum" ]]; then
    run_as_root rpm --import https://packages.microsoft.com/keys/microsoft.asc
    cat <<'REPO' | run_as_root tee /etc/yum.repos.d/vscode.repo >/dev/null
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
REPO
    run_as_root "$TB_PM" install -y code
    return
  fi

  die "Автоустановка code не поддерживается для $TB_PM — см. https://code.visualstudio.com/"
}

_code_update() {
  if have_cmd code; then
    local pkg
    pkg="$(tool_pkg_for_pm)"
    if [[ -n "$pkg" && "$TB_PM" == "brew" ]]; then
      pm_update_pkg "$pkg"
      return
    fi
    if [[ "$TB_PM" == "apt" ]]; then
      pm_update_pkg code
      return
    fi
  fi
  _code_install
}

case "${TB_ACTION:-install}" in
  update) _code_update ;;
  *)      _code_install ;;
esac
