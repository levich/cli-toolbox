#!/usr/bin/env bash
# Post-install tips: print and optionally save to a markdown file.

TIPS_REPORT=""

tips_reset_report() {
  TIPS_REPORT=""
}

tips_append_current_tool() {
  local local_doc tip_line section
  local_doc="docs/tools/${TOOL_ID}.md"

  section="## ${TOOL_NAME} (\`${TOOL_ID}\`)"$'\n\n'
  section+="${TOOL_SUMMARY}"$'\n\n'
  section+="### Документация"$'\n\n'
  section+="- Локально: [\`${local_doc}\`](${local_doc})"$'\n'
  if [[ -n "${TOOL_DOCS_URL:-}" ]]; then
    section+="- Официально: ${TOOL_DOCS_URL}"$'\n'
  fi
  section+=$'\n'

  section+="### Рекомендации по настройке"$'\n\n'
  if [[ -n "${TOOL_TIPS:-}" ]]; then
    while IFS= read -r tip_line || [[ -n "$tip_line" ]]; do
      if [[ -z "$tip_line" ]]; then
        continue
      fi
      section+="- ${tip_line}"$'\n'
    done <<< "$TOOL_TIPS"
  else
    section+="- Специальных шагов не требуется; см. локальную и официальную документацию."$'\n'
  fi
  section+=$'\n'

  TIPS_REPORT+="$section"
}

tips_build_report() {
  local tools="$1"
  local tid header
  tips_reset_report

  header="# Рекомендации CLI Toolbox"$'\n\n'
  header+="Сгенерировано: $(date '+%Y-%m-%d %H:%M:%S')"$'\n\n'
  header+="Платформа: $(platform_summary)"$'\n\n'
  header+="Инструменты: ${tools}"$'\n\n'
  header+="---"$'\n\n'

  for tid in $tools; do
    if [[ ! -f "${TOOLS_DIR}/${tid}.yaml" ]]; then
      continue
    fi
    load_tool_file "${TOOLS_DIR}/${tid}.yaml"
    tips_append_current_tool
  done

  printf '%s' "${header}${TIPS_REPORT}"
}

tips_print_report() {
  local tools="$1"
  local report
  report="$(tips_build_report "$tools")"
  echo
  log_info "Рекомендации по настройке и документация"
  echo
  printf '%s\n' "$report"
}

tips_save_report() {
  local tools="$1"
  local path="$2"
  local report dir
  report="$(tips_build_report "$tools")"
  dir="$(dirname "$path")"
  if [[ "$dir" != "." && -n "$dir" ]]; then
    ensure_dir "$dir"
  fi
  printf '%s' "$report" > "$path"
  log_ok "Рекомендации сохранены: $path"
}
