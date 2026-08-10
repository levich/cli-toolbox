#!/usr/bin/env bash
# Package manager install / update / check helpers.

tool_is_installed() {
  local check="${TOOL_CHECK:-$TOOL_ID}"
  case "$TOOL_ID" in
    oh-my-zsh)
      if [[ -d "${ZSH:-$HOME/.oh-my-zsh}" ]]; then
        return 0
      fi
      return 1
      ;;
    powerlevel10k)
      if [[ -d "${POWERLEVEL10K_DIR:-$HOME/.oh-my-zsh/custom/themes/powerlevel10k}" ]] \
        || [[ -d "$HOME/powerlevel10k" ]] \
        || [[ -d /usr/local/share/powerlevel10k ]]; then
        return 0
      fi
      return 1
      ;;
    gnome-tweaks)
      if have_cmd gnome-tweaks || have_cmd gnome-tweak-tool; then
        return 0
      fi
      return 1
      ;;
    net-tools)
      if have_cmd ifconfig || have_cmd netstat; then
        return 0
      fi
      return 1
      ;;
    code)
      if have_cmd code || have_cmd code-insiders; then
        return 0
      fi
      return 1
      ;;
    cursor)
      if have_cmd cursor || [[ -d "/Applications/Cursor.app" ]] || [[ -x "$HOME/.local/bin/cursor" ]]; then
        return 0
      fi
      return 1
      ;;
    postman)
      if have_cmd postman || [[ -d "/Applications/Postman.app" ]] || [[ -d "$HOME/.local/share/Postman" ]]; then
        return 0
      fi
      return 1
      ;;
    insomnia)
      if have_cmd insomnia || [[ -d "/Applications/Insomnia.app" ]]; then
        return 0
      fi
      return 1
      ;;
    dbeaver)
      if have_cmd dbeaver || have_cmd dbeaver-ce || [[ -d "/Applications/DBeaver.app" ]]; then
        return 0
      fi
      return 1
      ;;
    alacritty)
      if have_cmd alacritty || [[ -d "/Applications/Alacritty.app" ]]; then
        return 0
      fi
      return 1
      ;;
    kitty)
      if have_cmd kitty || [[ -d "/Applications/kitty.app" ]]; then
        return 0
      fi
      return 1
      ;;
    python)
      if have_cmd python3 || have_cmd python; then
        return 0
      fi
      return 1
      ;;
    pip)
      if have_cmd pip3 || have_cmd pip; then
        return 0
      fi
      return 1
      ;;
    iproute2)
      if have_cmd ip || have_cmd ss; then
        return 0
      fi
      return 1
      ;;
    7zip)
      if have_cmd 7z || have_cmd 7zz || have_cmd 7za; then
        return 0
      fi
      return 1
      ;;
    nerdfonts)
      if [[ "${TB_IS_MACOS:-0}" -eq 1 ]]; then
        if [[ -d "$HOME/Library/Fonts" ]] && ls "$HOME/Library/Fonts"/MesloLGSNerdFont*.ttf >/dev/null 2>&1; then
          return 0
        fi
        if have_cmd brew && brew list --cask font-meslo-lg-nerd-font >/dev/null 2>&1; then
          return 0
        fi
        return 1
      fi
      if ls "${XDG_DATA_HOME:-$HOME/.local/share}/fonts/NerdFonts"/MesloLGSNerdFont*.ttf >/dev/null 2>&1; then
        return 0
      fi
      return 1
      ;;
    fd)
      if have_cmd fd || have_cmd fdfind; then
        return 0
      fi
      return 1
      ;;
  esac
  have_cmd "$check"
}

tool_compatible() {
  if [[ -n "$TOOL_PLATFORMS" ]]; then
    local ok=0
    local p
    for p in ${TOOL_PLATFORMS//,/ }; do
      case "$p" in
        macos)
          if [[ "$TB_IS_MACOS" -eq 1 ]]; then ok=1; fi
          ;;
        linux)
          if [[ "$TB_IS_LINUX" -eq 1 ]]; then ok=1; fi
          ;;
        wsl)
          if [[ "$TB_IS_WSL" -eq 1 ]]; then ok=1; fi
          ;;
        debian|ubuntu)
          if [[ "${TB_DISTRO_FAMILY:-}" == "debian" || "$TB_DISTRO" == "$p" ]]; then ok=1; fi
          ;;
        alpine|arch|alt|fedora)
          if [[ "$TB_DISTRO" == "$p" || "${TB_DISTRO_FAMILY:-}" == "$p" ]]; then ok=1; fi
          ;;
        *)
          if [[ "$TB_DISTRO" == "$p" || "$TB_OS" == "$p" ]]; then ok=1; fi
          ;;
      esac
    done
    if [[ "$ok" -ne 1 ]]; then
      return 1
    fi
  fi

  if [[ -n "$TOOL_SKIP_ON" ]]; then
    local s
    for s in ${TOOL_SKIP_ON//,/ }; do
      case "$s" in
        macos)
          if [[ "$TB_IS_MACOS" -eq 1 ]]; then return 1; fi
          ;;
        linux)
          if [[ "$TB_IS_LINUX" -eq 1 ]]; then return 1; fi
          ;;
        wsl)
          if [[ "$TB_IS_WSL" -eq 1 ]]; then return 1; fi
          ;;
        *)
          if [[ "$TB_DISTRO" == "$s" || "${TB_DISTRO_FAMILY:-}" == "$s" ]]; then return 1; fi
          ;;
      esac
    done
  fi

  if [[ "$TOOL_REQUIRES_DESKTOP" -eq 1 ]]; then
    if [[ "$TB_IS_WSL" -eq 1 ]]; then
      return 1
    fi
    if [[ "$TB_IS_LINUX" -eq 1 ]]; then
      if [[ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
        return 1
      fi
    fi
  fi

  return 0
}

# Non-interactive wrappers for package managers
brew_noconfirm() {
  NONINTERACTIVE=1 HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ENV_HINTS=1 brew "$@"
}

apt_noconfirm() {
  # env keeps DEBIAN_FRONTEND under sudo env_reset
  run_as_root env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a \
    apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold "$@"
}

pm_install_pkg() {
  local pkg="$1"
  if [[ -z "$pkg" ]]; then
    return 1
  fi
  if [[ "${TB_DRY_RUN:-0}" -eq 1 ]]; then
    log_dry "$TB_PM install $pkg"
    return 0
  fi
  case "$TB_PM" in
    brew)
      ensure_brew
      if brew_noconfirm list --formula "$pkg" >/dev/null 2>&1 \
        || brew_noconfirm list --cask "$pkg" >/dev/null 2>&1; then
        log_ok "$pkg уже установлен (brew)"
        return 0
      fi
      if brew_noconfirm info --cask "$pkg" >/dev/null 2>&1; then
        brew_noconfirm install --cask "$pkg"
      else
        brew_noconfirm install "$pkg"
      fi
      ;;
    apt)
      apt_noconfirm update -qq
      apt_noconfirm install --no-install-recommends "$pkg"
      ;;
    pacman)
      run_as_root pacman -Sy --noconfirm --needed "$pkg"
      ;;
    apk)
      run_as_root apk add --no-cache --no-interactive "$pkg" 2>/dev/null \
        || run_as_root apk add --no-cache "$pkg"
      ;;
    dnf)
      run_as_root dnf install -y --assumeyes --setopt=install_weak_deps=False "$pkg"
      ;;
    yum)
      run_as_root yum install -y "$pkg"
      ;;
    zypper)
      run_as_root zypper --non-interactive install -y "$pkg"
      ;;
    *)
      log_error "Неизвестный package manager: $TB_PM"
      return 1
      ;;
  esac
}

pm_update_pkg() {
  local pkg="$1"
  if [[ -z "$pkg" ]]; then
    return 1
  fi
  if [[ "${TB_DRY_RUN:-0}" -eq 1 ]]; then
    log_dry "$TB_PM upgrade $pkg"
    return 0
  fi
  case "$TB_PM" in
    brew)
      ensure_brew
      if brew_noconfirm list --cask "$pkg" >/dev/null 2>&1; then
        brew_noconfirm upgrade --cask "$pkg" || true
      else
        brew_noconfirm upgrade "$pkg" || true
      fi
      ;;
    apt)
      apt_noconfirm update -qq
      apt_noconfirm install --only-upgrade "$pkg"
      ;;
    pacman)
      run_as_root pacman -Sy --noconfirm "$pkg"
      ;;
    apk)
      run_as_root apk add --no-cache --no-interactive -u "$pkg" 2>/dev/null \
        || run_as_root apk add --no-cache -u "$pkg"
      ;;
    dnf)
      run_as_root dnf upgrade -y --assumeyes "$pkg"
      ;;
    yum)
      run_as_root yum update -y "$pkg"
      ;;
    zypper)
      run_as_root zypper --non-interactive update -y "$pkg"
      ;;
    *)
      return 1
      ;;
  esac
}

pm_remove_pkg() {
  local pkg="$1"
  if [[ -z "$pkg" ]]; then
    return 1
  fi
  if [[ "${TB_DRY_RUN:-0}" -eq 1 ]]; then
    log_dry "$TB_PM remove $pkg"
    return 0
  fi
  case "$TB_PM" in
    brew)
      ensure_brew
      if brew_noconfirm list --cask "$pkg" >/dev/null 2>&1; then
        brew_noconfirm uninstall --cask --force "$pkg" || true
      elif brew_noconfirm list --formula "$pkg" >/dev/null 2>&1; then
        brew_noconfirm uninstall --force "$pkg" || true
      else
        log_ok "$pkg не найден в brew"
      fi
      ;;
    apt)
      apt_noconfirm remove --purge "$pkg" || apt_noconfirm remove "$pkg"
      ;;
    pacman)
      run_as_root pacman -Rns --noconfirm "$pkg" || run_as_root pacman -R --noconfirm "$pkg"
      ;;
    apk)
      run_as_root apk del --no-interactive "$pkg" 2>/dev/null \
        || run_as_root apk del "$pkg"
      ;;
    dnf)
      run_as_root dnf remove -y --assumeyes "$pkg"
      ;;
    yum)
      run_as_root yum remove -y "$pkg"
      ;;
    zypper)
      run_as_root zypper --non-interactive remove -y "$pkg"
      ;;
    *)
      log_error "Неизвестный package manager: $TB_PM"
      return 1
      ;;
  esac
}

run_custom_script() {
  local mode="$1" # install | update | remove
  local script="${CUSTOM_DIR}/${TOOL_CUSTOM:-$TOOL_ID}.sh"
  if [[ -n "${TOOL_CUSTOM:-}" ]]; then
    if [[ "$TOOL_CUSTOM" == /* ]]; then
      script="$TOOL_CUSTOM"
    elif [[ "$TOOL_CUSTOM" == custom/* ]]; then
      script="${LIB_DIR}/${TOOL_CUSTOM}"
    elif [[ "$TOOL_CUSTOM" == *.sh ]]; then
      script="${CUSTOM_DIR}/${TOOL_CUSTOM}"
    else
      script="${CUSTOM_DIR}/${TOOL_CUSTOM}.sh"
    fi
  fi

  if [[ ! -f "$script" ]]; then
    log_error "Кастомный скрипт не найден: $script"
    return 1
  fi

  if [[ "${TB_DRY_RUN:-0}" -eq 1 ]]; then
    log_dry "custom $mode $script"
    return 0
  fi

  # shellcheck disable=SC1090
  TB_ACTION="$mode" source "$script"
}

custom_script_path() {
  local script="${CUSTOM_DIR}/${TOOL_CUSTOM:-$TOOL_ID}.sh"
  if [[ -n "${TOOL_CUSTOM:-}" ]]; then
    if [[ "$TOOL_CUSTOM" == /* ]]; then
      script="$TOOL_CUSTOM"
    elif [[ "$TOOL_CUSTOM" == custom/* ]]; then
      script="${LIB_DIR}/${TOOL_CUSTOM}"
    elif [[ "$TOOL_CUSTOM" == *.sh ]]; then
      script="${CUSTOM_DIR}/${TOOL_CUSTOM}"
    else
      script="${CUSTOM_DIR}/${TOOL_CUSTOM}.sh"
    fi
  fi
  printf '%s' "$script"
}

custom_supports_remove() {
  local script
  script="$(custom_script_path)"
  [[ -f "$script" ]] || return 1
  grep -qE '^[[:space:]]*remove\)' "$script"
}

remove_current_tool() {
  if ! tool_is_installed; then
    log_ok "${TOOL_ID} не установлен"
    return 0
  fi

  log_info "Удаляю ${TOOL_NAME}..."

  # 1) Custom remove handler, if present
  if [[ -n "${TOOL_CUSTOM:-}" ]] || [[ -f "${CUSTOM_DIR}/${TOOL_ID}.sh" ]]; then
    if [[ -z "${TOOL_CUSTOM:-}" ]]; then
      TOOL_CUSTOM="$TOOL_ID"
    fi
    if custom_supports_remove; then
      run_custom_script remove
      return $?
    fi
  fi

  # 2) Package manager uninstall
  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_remove_pkg "$pkg"
    # Continue to cleanup leftovers for hybrid installs
  fi

  if [[ "${TB_DRY_RUN:-0}" -eq 1 ]]; then
    log_dry "cleanup $TOOL_ID"
    return 0
  fi

  # 3) Best-effort cleanup for known custom installs
  case "$TOOL_ID" in
    oh-my-zsh)
      rm -rf "${ZSH:-$HOME/.oh-my-zsh}"
      ;;
    powerlevel10k)
      rm -rf "${POWERLEVEL10K_DIR:-$HOME/.oh-my-zsh/custom/themes/powerlevel10k}"
      rm -rf "$HOME/powerlevel10k"
      ;;
    nerdfonts)
      if [[ "${TB_IS_MACOS:-0}" -eq 1 ]]; then
        brew_noconfirm uninstall --cask font-meslo-lg-nerd-font 2>/dev/null || true
        rm -f "$HOME/Library/Fonts"/MesloLGSNerdFont*.ttf 2>/dev/null || true
      else
        rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/fonts/NerdFonts" 2>/dev/null || true
        if have_cmd fc-cache; then fc-cache -f >/dev/null 2>&1 || true; fi
      fi
      ;;
    nvitop)
      if have_cmd uv; then uv tool uninstall nvitop 2>/dev/null || true; fi
      if have_cmd pipx; then pipx uninstall nvitop 2>/dev/null || true; fi
      if have_cmd pip3; then pip3 uninstall -y nvitop 2>/dev/null || true; fi
      ;;
    uv)
      rm -f "$HOME/.local/bin/uv" "$HOME/.cargo/bin/uv" 2>/dev/null || true
      ;;
    bitwarden)
      if have_cmd snap; then run_as_root snap remove bw 2>/dev/null || true; fi
      if have_cmd npm; then npm uninstall -g @bitwarden/cli 2>/dev/null || true; fi
      rm -f "$HOME/.local/bin/bw" 2>/dev/null || true
      ;;
    cursor)
      rm -f "$HOME/.local/bin/cursor" "$HOME/.local/bin/cursor.AppImage" 2>/dev/null || true
      if [[ "${TB_IS_MACOS:-0}" -eq 1 ]]; then
        brew_noconfirm uninstall --cask cursor 2>/dev/null || true
      fi
      ;;
    postman)
      if have_cmd flatpak; then flatpak uninstall -y --noninteractive com.getpostman.Postman 2>/dev/null || true; fi
      rm -rf "$HOME/.local/share/Postman" "$HOME/.local/bin/postman" 2>/dev/null || true
      if [[ "${TB_IS_MACOS:-0}" -eq 1 ]]; then
        brew_noconfirm uninstall --cask postman 2>/dev/null || true
      fi
      ;;
    insomnia)
      if have_cmd flatpak; then flatpak uninstall -y --noninteractive rest.insomnia.Insomnia 2>/dev/null || true; fi
      if [[ "${TB_IS_MACOS:-0}" -eq 1 ]]; then
        brew_noconfirm uninstall --cask insomnia 2>/dev/null || true
      fi
      ;;
    dbeaver)
      if have_cmd flatpak; then flatpak uninstall -y --noninteractive io.dbeaver.DBeaverCommunity 2>/dev/null || true; fi
      if [[ "${TB_IS_MACOS:-0}" -eq 1 ]]; then
        brew_noconfirm uninstall --cask dbeaver-community 2>/dev/null || true
      fi
      ;;
    code)
      if [[ "${TB_IS_MACOS:-0}" -eq 1 ]]; then
        brew_noconfirm uninstall --cask visual-studio-code 2>/dev/null || true
      elif [[ "$TB_PM" == "apt" ]]; then
        apt_noconfirm remove --purge code 2>/dev/null || true
      fi
      ;;
    atuin)
      rm -f "$HOME/.atuin/bin/atuin" "$HOME/.local/bin/atuin" 2>/dev/null || true
      ;;
    lazydocker)
      rm -f "$HOME/.local/bin/lazydocker" 2>/dev/null || true
      ;;
    xh|mdcat|difftastic|topgrade|alacritty)
      rm -f "$HOME/.local/bin/${TOOL_CHECK:-$TOOL_ID}" "$HOME/.cargo/bin/${TOOL_CHECK:-$TOOL_ID}" 2>/dev/null || true
      if [[ "$TOOL_ID" == "difftastic" ]]; then
        rm -f "$HOME/.cargo/bin/difft" 2>/dev/null || true
      fi
      ;;
    rclone)
      run_as_root rm -f /usr/bin/rclone /usr/local/bin/rclone 2>/dev/null || true
      rm -f "$HOME/.local/bin/rclone" 2>/dev/null || true
      ;;
    asciinema)
      if have_cmd pipx; then pipx uninstall asciinema 2>/dev/null || true; fi
      if have_cmd pip3; then pip3 uninstall -y asciinema 2>/dev/null || true; fi
      ;;
    tldr)
      if have_cmd npm; then npm uninstall -g tldr 2>/dev/null || true; fi
      rm -f "$HOME/.cargo/bin/tldr" 2>/dev/null || true
      ;;
    dive)
      rm -f "$HOME/.local/bin/dive" 2>/dev/null || true
      if [[ "$TB_PM" == "apt" ]]; then apt_noconfirm remove --purge dive 2>/dev/null || true; fi
      ;;
    *)
      if [[ -z "$pkg" ]]; then
        log_warn "$TOOL_ID: автоматическое удаление не настроено — удалите вручную"
        return 1
      fi
      ;;
  esac
  return 0
}

install_current_tool() {
  if ! tool_compatible; then
    log_skip "$TOOL_ID (несовместим с $(platform_summary))"
    return 0
  fi

  if tool_is_installed && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "$TOOL_ID уже установлен"
    return 0
  fi

  log_info "Устанавливаю ${TOOL_NAME}..."

  if [[ -n "${TOOL_CUSTOM:-}" ]]; then
    run_custom_script install
    return $?
  fi

  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_install_pkg "$pkg"
    return $?
  fi

  if [[ -f "${CUSTOM_DIR}/${TOOL_ID}.sh" ]]; then
    TOOL_CUSTOM="$TOOL_ID"
    run_custom_script install
    return $?
  fi

  log_skip "$TOOL_ID: нет пакета для $TB_PM и нет custom-скрипта"
  return 0
}

update_current_tool() {
  if ! tool_compatible; then
    log_skip "$TOOL_ID (несовместим)"
    return 0
  fi

  if ! tool_is_installed; then
    log_info "$TOOL_ID не установлен — ставлю"
    install_current_tool
    return $?
  fi

  log_info "Обновляю ${TOOL_NAME}..."

  if [[ -n "${TOOL_CUSTOM:-}" ]] || [[ -f "${CUSTOM_DIR}/${TOOL_ID}.sh" ]]; then
    if [[ -z "${TOOL_CUSTOM:-}" ]]; then
      TOOL_CUSTOM="$TOOL_ID"
    fi
    run_custom_script update
    return $?
  fi

  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_update_pkg "$pkg"
    return $?
  fi

  log_skip "$TOOL_ID: нечего обновлять через $TB_PM"
  return 0
}
