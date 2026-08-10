#!/usr/bin/env bash
# shellcheck disable=SC2034

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="${ROOT_DIR}/lib"
CATALOG_DIR="${ROOT_DIR}/catalog"
TOOLS_DIR="${CATALOG_DIR}/tools"
CUSTOM_DIR="${LIB_DIR}/custom"

# Colors (disabled if not a TTY)
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_RED=$'\033[31m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'
  C_CYAN=$'\033[36m'
else
  C_RESET= C_BOLD= C_DIM= C_RED= C_GREEN= C_YELLOW= C_BLUE= C_CYAN=
fi

log_info()  { printf '%s==>%s %s\n' "${C_BLUE}" "${C_RESET}" "$*"; }
log_ok()    { printf '%s[ok]%s %s\n' "${C_GREEN}" "${C_RESET}" "$*"; }
log_warn()  { printf '%s[warn]%s %s\n' "${C_YELLOW}" "${C_RESET}" "$*" >&2; }
log_error() { printf '%s[error]%s %s\n' "${C_RED}" "${C_RESET}" "$*" >&2; }
log_skip()  { printf '%s[skip]%s %s\n' "${C_DIM}" "${C_RESET}" "$*"; }
log_dry()   { printf '%s[dry-run]%s %s\n' "${C_CYAN}" "${C_RESET}" "$*"; }

die() {
  log_error "$*"
  exit 1
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# Join array elements with comma (bash 3.2 compatible via nameref-like eval)
join_by() {
  local IFS="$1"
  shift
  printf '%s' "$*"
}

# Check if needle is in comma-separated or space-separated haystack
list_contains() {
  local needle="$1"
  local haystack="$2"
  local item
  # shellcheck disable=SC2086
  for item in ${haystack//,/ }; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

# Trim whitespace
trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

run_as_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif have_cmd sudo; then
    sudo "$@"
  else
    die "Нужны права root (sudo) для: $*"
  fi
}

ensure_dir() {
  mkdir -p "$1"
}

download() {
  local url="$1"
  local dest="$2"
  if have_cmd curl; then
    curl -fsSL "$url" -o "$dest"
  elif have_cmd wget; then
    wget -qO "$dest" "$url"
  else
    die "Нужен curl или wget"
  fi
}

download_pipe() {
  local url="$1"
  if have_cmd curl; then
    curl -fsSL "$url"
  elif have_cmd wget; then
    wget -qO- "$url"
  else
    die "Нужен curl или wget"
  fi
}
