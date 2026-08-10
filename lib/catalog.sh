#!/usr/bin/env bash
# Minimal YAML subset parser for tool definitions.
# Supported:
#   key: value
#   key: [a, b, c]
#   packages:
#     brew: name
# Nested maps only under known section keys (packages).

# Globals filled by load_tool_file / iterate
TOOL_ID=""
TOOL_NAME=""
TOOL_SUMMARY=""
TOOL_CATEGORY=""
TOOL_PROFILES=""
TOOL_CHECK=""
TOOL_CUSTOM=""
TOOL_SKIP_ON=""
TOOL_PLATFORMS=""
TOOL_REQUIRES_DESKTOP=0
TOOL_PKG_BREW=""
TOOL_PKG_APT=""
TOOL_PKG_PACMAN=""
TOOL_PKG_APK=""
TOOL_PKG_DNF=""
TOOL_PKG_YUM=""
TOOL_PKG_ZYPPER=""
TOOL_NEEDS=""
TOOL_DOCS_URL=""
TOOL_TIPS=""

_catalog_reset_tool() {
  TOOL_ID=""
  TOOL_NAME=""
  TOOL_SUMMARY=""
  TOOL_CATEGORY=""
  TOOL_PROFILES=""
  TOOL_CHECK=""
  TOOL_CUSTOM=""
  TOOL_SKIP_ON=""
  TOOL_PLATFORMS=""
  TOOL_REQUIRES_DESKTOP=0
  TOOL_PKG_BREW=""
  TOOL_PKG_APT=""
  TOOL_PKG_PACMAN=""
  TOOL_PKG_APK=""
  TOOL_PKG_DNF=""
  TOOL_PKG_YUM=""
  TOOL_PKG_ZYPPER=""
  TOOL_NEEDS=""
  TOOL_DOCS_URL=""
  TOOL_TIPS=""
}

_parse_yaml_list() {
  local raw="$1"
  raw="$(trim "$raw")"
  raw="${raw#[}"
  raw="${raw%]}"
  local out="" item
  IFS=',' read -r -a _items <<< "$raw"
  for item in "${_items[@]}"; do
    item="$(trim "$item")"
    item="${item#\'}"
    item="${item%\'}"
    item="${item#\"}"
    item="${item%\"}"
    if [[ -z "$item" ]]; then
      continue
    fi
    if [[ -n "$out" ]]; then
      out+=",$item"
    else
      out="$item"
    fi
  done
  printf '%s' "$out"
}

_unquote() {
  local v
  v="$(trim "$1")"
  # Strip only matching wrapping quotes around the whole value
  if [[ "$v" == \"*\" && ${#v} -ge 2 ]]; then
    v="${v#\"}"
    v="${v%\"}"
  elif [[ "$v" == \'*\' && ${#v} -ge 2 ]]; then
    v="${v#\'}"
    v="${v%\'}"
  fi
  # strip inline comments (space + #), but not inside the value naively if starts with http
  if [[ "$v" == *" #"* ]]; then
    v="${v%% #*}"
    v="$(trim "$v")"
  fi
  printf '%s' "$v"
}

load_tool_file() {
  local file="$1"
  _catalog_reset_tool
  local section="" line key val indent

  while IFS= read -r line || [[ -n "$line" ]]; do
    # skip empty / comments
    if [[ -z "$(trim "$line")" ]]; then
      continue
    fi
    if [[ "$(trim "$line")" == \#* ]]; then
      continue
    fi

    # detect indentation (packages subsection)
    if [[ "$line" =~ ^[[:space:]] ]]; then
      indent=1
    else
      indent=0
      section=""
    fi

    # list item under tips:
    if [[ "$indent" -eq 1 && "$section" == "tips" ]] \
      && [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(.+)$ ]]; then
      val="$(_unquote "${BASH_REMATCH[1]}")"
      if [[ -n "$val" ]]; then
        if [[ -n "$TOOL_TIPS" ]]; then
          TOOL_TIPS+=$'\n'"$val"
        else
          TOOL_TIPS="$val"
        fi
      fi
      continue
    fi

    # key: value or key:
    if [[ "$line" =~ ^[[:space:]]*([A-Za-z0-9_]+)[[:space:]]*:[[:space:]]*(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      val="$(trim "${BASH_REMATCH[2]}")"

      if [[ "$indent" -eq 0 ]]; then
        case "$key" in
          id)       TOOL_ID="$(_unquote "$val")" ;;
          name)     TOOL_NAME="$(_unquote "$val")" ;;
          summary)  TOOL_SUMMARY="$(_unquote "$val")" ;;
          category) TOOL_CATEGORY="$(_unquote "$val")" ;;
          check)    TOOL_CHECK="$(_unquote "$val")" ;;
          custom)   TOOL_CUSTOM="$(_unquote "$val")" ;;
          docs_url) TOOL_DOCS_URL="$(_unquote "$val")" ;;
          profiles)
            if [[ "$val" == \[* ]]; then
              TOOL_PROFILES="$(_parse_yaml_list "$val")"
            fi
            ;;
          skip_on)
            if [[ "$val" == \[* ]]; then
              TOOL_SKIP_ON="$(_parse_yaml_list "$val")"
            fi
            ;;
          platforms)
            if [[ "$val" == \[* ]]; then
              TOOL_PLATFORMS="$(_parse_yaml_list "$val")"
            fi
            ;;
          needs)
            if [[ "$val" == \[* ]]; then
              TOOL_NEEDS="$(_parse_yaml_list "$val")"
            fi
            ;;
          requires_desktop)
            case "$(_unquote "$val")" in
              true|yes|1) TOOL_REQUIRES_DESKTOP=1 ;;
              *) TOOL_REQUIRES_DESKTOP=0 ;;
            esac
            ;;
          packages)
            section="packages"
            ;;
          tips)
            section="tips"
            ;;
        esac
      elif [[ "$section" == "packages" ]]; then
        val="$(_unquote "$val")"
        case "$key" in
          brew)   TOOL_PKG_BREW="$val" ;;
          apt)    TOOL_PKG_APT="$val" ;;
          pacman) TOOL_PKG_PACMAN="$val" ;;
          apk)    TOOL_PKG_APK="$val" ;;
          dnf)    TOOL_PKG_DNF="$val" ;;
          yum)    TOOL_PKG_YUM="$val" ;;
          zypper) TOOL_PKG_ZYPPER="$val" ;;
        esac
      fi
    fi
  done < "$file"

  # defaults
  if [[ -z "$TOOL_ID" ]]; then
    TOOL_ID="$(basename "$file" .yaml)"
  fi
  if [[ -z "$TOOL_NAME" ]]; then
    TOOL_NAME="$TOOL_ID"
  fi
  if [[ -z "$TOOL_CHECK" ]]; then
    TOOL_CHECK="$TOOL_ID"
  fi
  if [[ -z "$TOOL_CATEGORY" ]]; then
    TOOL_CATEGORY="cli"
  fi
}

# List all tool ids (sorted)
list_all_tool_ids() {
  local f
  for f in "$TOOLS_DIR"/*.yaml; do
    [[ -f "$f" ]] || continue
    basename "$f" .yaml
  done | sort
}

# Load profiles.yaml into PROFILE_<name> variables as comma lists
# Also sets PROFILE_NAMES
load_profiles() {
  PROFILE_NAMES=""
  local file="${CATALOG_DIR}/profiles.yaml"
  [[ -f "$file" ]] || die "Не найден $file"

  local line key val name
  name=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -z "$(trim "$line")" ]]; then
      continue
    fi
    if [[ "$(trim "$line")" == \#* ]]; then
      continue
    fi

    if [[ "$line" =~ ^([A-Za-z0-9_]+)[[:space:]]*:[[:space:]]*$ ]]; then
      name="${BASH_REMATCH[1]}"
      if [[ -n "$PROFILE_NAMES" ]]; then
        PROFILE_NAMES+=",$name"
      else
        PROFILE_NAMES="$name"
      fi
      eval "PROFILE_${name}=\"\""
    elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(.+)$ ]]; then
      val="$(_unquote "${BASH_REMATCH[1]}")"
      if [[ -z "$name" ]]; then
        continue
      fi
      local cur
      eval "cur=\"\${PROFILE_${name}:-}\""
      if [[ -n "$cur" ]]; then
        eval "PROFILE_${name}=\"\${cur},${val}\""
      else
        eval "PROFILE_${name}=\"${val}\""
      fi
    elif [[ "$line" =~ ^([A-Za-z0-9_]+)[[:space:]]*:[[:space:]]*\[(.*)\][[:space:]]*$ ]]; then
      name="${BASH_REMATCH[1]}"
      val="$(_parse_yaml_list "[${BASH_REMATCH[2]}]")"
      if [[ -n "$PROFILE_NAMES" ]]; then
        PROFILE_NAMES+=",$name"
      else
        PROFILE_NAMES="$name"
      fi
      eval "PROFILE_${name}=\"${val}\""
    fi
  done < "$file"
}

get_profile_tools() {
  local name="$1"
  eval "printf '%s' \"\${PROFILE_${name}:-}\""
}

tool_pkg_for_pm() {
  case "$TB_PM" in
    brew)   printf '%s' "$TOOL_PKG_BREW" ;;
    apt)    printf '%s' "$TOOL_PKG_APT" ;;
    pacman) printf '%s' "$TOOL_PKG_PACMAN" ;;
    apk)    printf '%s' "$TOOL_PKG_APK" ;;
    dnf)    printf '%s' "${TOOL_PKG_DNF:-$TOOL_PKG_YUM}" ;;
    yum)    printf '%s' "${TOOL_PKG_YUM:-$TOOL_PKG_DNF}" ;;
    zypper) printf '%s' "$TOOL_PKG_ZYPPER" ;;
    *)      printf '' ;;
  esac
}
