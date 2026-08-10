#!/usr/bin/env bash
# Detect OS, WSL, and package manager.
# Sets: TB_OS, TB_DISTRO, TB_PM, TB_IS_WSL, TB_IS_MACOS, TB_IS_LINUX, TB_ARCH

detect_platform() {
  TB_IS_WSL=0
  TB_IS_MACOS=0
  TB_IS_LINUX=0
  TB_OS="unknown"
  TB_DISTRO="unknown"
  TB_PM="unknown"
  TB_ARCH="$(uname -m)"

  local uname_s
  uname_s="$(uname -s)"

  case "$uname_s" in
    Darwin)
      TB_IS_MACOS=1
      TB_OS="macos"
      TB_DISTRO="macos"
      ;;
    Linux)
      TB_IS_LINUX=1
      TB_OS="linux"
      if [[ -f /proc/version ]] && grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
        TB_IS_WSL=1
      fi
      _detect_linux_distro
      ;;
    *)
      TB_OS="$(printf '%s' "$uname_s" | tr '[:upper:]' '[:lower:]')"
      ;;
  esac

  _detect_package_manager
}

_detect_linux_distro() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    TB_DISTRO="$(printf '%s' "${ID:-unknown}" | tr '[:upper:]' '[:lower:]')"
    # Normalize ID_LIKE hints
    local like
    like="$(printf '%s' "${ID_LIKE:-}" | tr '[:upper:]' '[:lower:]')"
    case "$TB_DISTRO" in
      ubuntu|debian|linuxmint|pop|elementary|raspbian|kali)
        TB_DISTRO_FAMILY="debian"
        ;;
      alpine)
        TB_DISTRO_FAMILY="alpine"
        ;;
      arch|manjaro|endeavouros|garuda|artix)
        TB_DISTRO_FAMILY="arch"
        ;;
      fedora|rhel|centos|rocky|almalinux|nobara)
        TB_DISTRO_FAMILY="rhel"
        ;;
      altlinux|alt)
        TB_DISTRO="alt"
        TB_DISTRO_FAMILY="alt"
        ;;
      opensuse*|sles)
        TB_DISTRO_FAMILY="suse"
        ;;
      *)
        if list_contains "debian" "$like" || list_contains "ubuntu" "$like"; then
          TB_DISTRO_FAMILY="debian"
        elif list_contains "arch" "$like"; then
          TB_DISTRO_FAMILY="arch"
        elif list_contains "rhel" "$like" || list_contains "fedora" "$like"; then
          TB_DISTRO_FAMILY="rhel"
        elif list_contains "suse" "$like"; then
          TB_DISTRO_FAMILY="suse"
        else
          TB_DISTRO_FAMILY="unknown"
        fi
        ;;
    esac
  elif [[ -f /etc/alpine-release ]]; then
    TB_DISTRO="alpine"
    TB_DISTRO_FAMILY="alpine"
  elif [[ -f /etc/arch-release ]]; then
    TB_DISTRO="arch"
    TB_DISTRO_FAMILY="arch"
  else
    TB_DISTRO="unknown"
    TB_DISTRO_FAMILY="unknown"
  fi
}

_detect_package_manager() {
  if [[ "$TB_IS_MACOS" -eq 1 ]]; then
    TB_PM="brew"
    return
  fi

  case "${TB_DISTRO_FAMILY:-unknown}" in
    debian)
      if have_cmd apt-get || have_cmd apt; then
        TB_PM="apt"
      fi
      ;;
    alpine)
      TB_PM="apk"
      ;;
    arch)
      TB_PM="pacman"
      ;;
    rhel)
      if have_cmd dnf; then
        TB_PM="dnf"
      elif have_cmd yum; then
        TB_PM="yum"
      fi
      ;;
    alt)
      if have_cmd apt-get || have_cmd apt; then
        TB_PM="apt"
      fi
      ;;
    suse)
      TB_PM="zypper"
      ;;
  esac

  # Fallback: probe available managers
  if [[ "$TB_PM" == "unknown" ]]; then
    if have_cmd brew; then
      TB_PM="brew"
    elif have_cmd apt-get || have_cmd apt; then
      TB_PM="apt"
    elif have_cmd pacman; then
      TB_PM="pacman"
    elif have_cmd apk; then
      TB_PM="apk"
    elif have_cmd dnf; then
      TB_PM="dnf"
    elif have_cmd yum; then
      TB_PM="yum"
    elif have_cmd zypper; then
      TB_PM="zypper"
    fi
  fi
}

ensure_brew() {
  if have_cmd brew; then
    return 0
  fi
  if [[ "$TB_IS_MACOS" -ne 1 ]]; then
    return 1
  fi
  log_info "Homebrew не найден — устанавливаю…"
  if [[ "${TB_DRY_RUN:-0}" -eq 1 ]]; then
    log_dry "install Homebrew"
    return 0
  fi
  NONINTERACTIVE=1 /bin/bash -c "$(download_pipe https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon path
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  have_cmd brew || die "Не удалось установить Homebrew"
}

platform_summary() {
  local wsl=""
  if [[ "$TB_IS_WSL" -eq 1 ]]; then
    wsl=" (WSL)"
  fi
  printf '%s / %s / pm=%s%s' "$TB_OS" "$TB_DISTRO" "$TB_PM" "$wsl"
}
