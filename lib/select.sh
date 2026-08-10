#!/usr/bin/env bash
# Resolve which tools to install: profiles, --only, --exclude, interactive.

# Output: space-separated sorted unique tool ids on stdout via SELECTED_TOOLS
SELECTED_TOOLS=""

_add_to_selected() {
  local id="$1"
  if [[ -z "$id" ]]; then
    return
  fi
  if [[ -z "$SELECTED_TOOLS" ]]; then
    SELECTED_TOOLS="$id"
    return
  fi
  if list_contains "$id" "${SELECTED_TOOLS// /,}"; then
    return
  fi
  SELECTED_TOOLS+=" $id"
}

_remove_from_selected() {
  local id="$1"
  local out="" t
  for t in $SELECTED_TOOLS; do
    if [[ "$t" == "$id" ]]; then
      continue
    fi
    if [[ -n "$out" ]]; then
      out+=" $t"
    else
      out="$t"
    fi
  done
  SELECTED_TOOLS="$out"
}

resolve_selection() {
  SELECTED_TOOLS=""
  local profiles="${TB_PROFILES:-}"
  local only="${TB_ONLY:-}"
  local exclude="${TB_EXCLUDE:-}"

  load_profiles

  if [[ -n "$only" ]]; then
    local id
    for id in ${only//,/ }; do
      id="$(trim "$id")"
      if [[ -z "$id" ]]; then
        continue
      fi
      if [[ ! -f "${TOOLS_DIR}/${id}.yaml" ]]; then
        log_warn "Неизвестный инструмент: $id"
        continue
      fi
      _add_to_selected "$id"
    done
  elif [[ -n "$profiles" ]]; then
    local p tools tid
    for p in ${profiles//,/ }; do
      p="$(trim "$p")"
      if [[ -z "$p" ]]; then
        continue
      fi
      if [[ "$p" == "all" ]]; then
        for tid in $(list_all_tool_ids); do
          _add_to_selected "$tid"
        done
        continue
      fi
      tools="$(get_profile_tools "$p")"
      if [[ -z "$tools" ]]; then
        log_warn "Неизвестный профиль: $p"
        continue
      fi
      for tid in ${tools//,/ }; do
        _add_to_selected "$tid"
      done
    done
  else
    # default: all
    local tid
    for tid in $(list_all_tool_ids); do
      _add_to_selected "$tid"
    done
  fi

  if [[ -n "$exclude" ]]; then
    local id
    for id in ${exclude//,/ }; do
      id="$(trim "$id")"
      _remove_from_selected "$id"
    done
  fi

  if [[ "${TB_INTERACTIVE:-0}" -eq 1 ]]; then
    interactive_select
  fi
}

interactive_select() {
  local candidates=()
  local t
  # shellcheck disable=SC2206
  candidates=($SELECTED_TOOLS)
  if [[ ${#candidates[@]} -eq 0 ]]; then
    log_warn "Нечего выбирать"
    return
  fi

  if have_cmd fzf; then
    local picked
    picked="$(
      printf '%s\n' "${candidates[@]}" \
        | fzf --multi --height=80% --reverse \
            --prompt='Выберите инструменты (TAB): ' \
            --preview "cat '${TOOLS_DIR}/{}.yaml' 2>/dev/null || true" \
            --preview-window=right:50%
    )" || true
    SELECTED_TOOLS=""
    while IFS= read -r t; do
      if [[ -z "$t" ]]; then
        continue
      fi
      _add_to_selected "$t"
    done <<< "$picked"
    return
  fi

  # Fallback: numbered menu
  echo
  log_info "Интерактивный выбор (введите номера через пробел, Enter = все показанные)"
  local i=1
  declare -a map=()
  for t in "${candidates[@]}"; do
    local status="—"
    load_tool_file "${TOOLS_DIR}/${t}.yaml"
    if tool_is_installed; then
      status="installed"
    else
      status="missing"
    fi
    printf '  %2d) %-16s [%s] %s\n' "$i" "$t" "$status" "$TOOL_SUMMARY"
    map[$i]="$t"
    i=$((i + 1))
  done
  printf '\nНомера (или Enter): '
  local answer
  read -r answer || true
  if [[ -z "$(trim "${answer:-}")" ]]; then
    return
  fi
  SELECTED_TOOLS=""
  local n
  for n in $answer; do
    if [[ -n "${map[$n]:-}" ]]; then
      _add_to_selected "${map[$n]}"
    fi
  done
}

print_tool_list() {
  local tid status compat
  local filter="${1:-all}" # all | installed | missing
  local count=0
  printf '%-18s %-10s %-12s %s\n' "ID" "STATUS" "COMPAT" "SUMMARY"
  printf '%-18s %-10s %-12s %s\n' "------------------" "----------" "------------" "-------"
  for tid in $(list_all_tool_ids); do
    load_tool_file "${TOOLS_DIR}/${tid}.yaml"
    if tool_is_installed; then
      status="installed"
    else
      status="missing"
    fi
    if [[ "$filter" == "installed" && "$status" != "installed" ]]; then
      continue
    fi
    if [[ "$filter" == "missing" && "$status" != "missing" ]]; then
      continue
    fi
    if tool_compatible; then
      compat="yes"
    else
      compat="skip"
    fi
    printf '%-18s %-10s %-12s %s\n' "$tid" "$status" "$compat" "$TOOL_SUMMARY"
    count=$((count + 1))
  done
  echo
  printf 'Всего: %s\n' "$count"
}

# Print only installed tool ids (one per line), optionally limited to SELECTED_TOOLS if set
print_installed_ids() {
  local tid scope="${1:-}"
  local count=0
  local candidates=""
  if [[ -n "$scope" ]]; then
    candidates="$scope"
  else
    candidates="$(list_all_tool_ids | tr '\n' ' ')"
  fi
  for tid in $candidates; do
    [[ -f "${TOOLS_DIR}/${tid}.yaml" ]] || continue
    load_tool_file "${TOOLS_DIR}/${tid}.yaml"
    if tool_is_installed; then
      printf '%s\n' "$tid"
      count=$((count + 1))
    fi
  done
  echo
  printf 'Установлено: %s\n' "$count" >&2
}

# Topological-ish order: tools with needs first (simple one-pass)
order_selected() {
  local ordered="" pending="$SELECTED_TOOLS"
  local guard=0
  local t needs_ok need

  while [[ -n "$pending" && "$guard" -lt 100 ]]; do
    guard=$((guard + 1))
    local next="" progressed=0
    for t in $pending; do
      load_tool_file "${TOOLS_DIR}/${t}.yaml"
      needs_ok=1
      if [[ -n "$TOOL_NEEDS" ]]; then
        for need in ${TOOL_NEEDS//,/ }; do
          if ! list_contains "$need" "${ordered// /,}" && list_contains "$need" "${SELECTED_TOOLS// /,}"; then
            # need is in selection but not yet ordered
            if list_contains "$need" "${pending// /,}"; then
              needs_ok=0
              break
            fi
          fi
        done
      fi
      if [[ "$needs_ok" -eq 1 ]]; then
        if [[ -n "$ordered" ]]; then
          ordered+=" $t"
        else
          ordered="$t"
        fi
        progressed=1
      else
        if [[ -n "$next" ]]; then
          next+=" $t"
        else
          next="$t"
        fi
      fi
    done
    pending="$next"
    if [[ "$progressed" -eq 0 ]]; then
      break
    fi
  done
  # append leftovers
  for t in $pending; do
    if [[ -n "$ordered" ]]; then
      ordered+=" $t"
    else
      ordered="$t"
    fi
  done
  SELECTED_TOOLS="$ordered"
}
