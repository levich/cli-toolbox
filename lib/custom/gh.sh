#!/usr/bin/env bash
# GitHub CLI (gh)

_gh_install() {
  if have_cmd gh && [[ "${TB_FORCE:-0}" -ne 1 ]]; then
    log_ok "gh уже установлен"
    return 0
  fi

  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    if [[ "$TB_PM" == "apt" ]]; then
      # Official GitHub apt repo is more reliable on Ubuntu
      if ! have_cmd gh; then
        download_pipe https://cli.github.com/packages/githubcli-archive-keyring.gpg \
          | run_as_root dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
        run_as_root chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
          | run_as_root tee /etc/apt/sources.list.d/github-cli.list >/dev/null
        apt_noconfirm update -qq
        apt_noconfirm install gh
      fi
      return
    fi
    pm_install_pkg "$pkg" && return 0
  fi

  die "Установите gh вручную: https://cli.github.com/"
}

_gh_update() {
  local pkg
  pkg="$(tool_pkg_for_pm)"
  if [[ -n "$pkg" ]]; then
    pm_update_pkg "$pkg" && return 0
  fi
  _gh_install
}

case "${TB_ACTION:-install}" in
  update) _gh_update ;;
  *)      _gh_install ;;
esac
