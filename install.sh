#!/usr/bin/env bash
# CLI Toolbox — установщик и обновлятор утилит
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${ROOT_DIR}/lib/common.sh"
# shellcheck source=lib/detect.sh
source "${ROOT_DIR}/lib/detect.sh"
# shellcheck source=lib/catalog.sh
source "${ROOT_DIR}/lib/catalog.sh"
# shellcheck source=lib/package.sh
source "${ROOT_DIR}/lib/package.sh"
# shellcheck source=lib/select.sh
source "${ROOT_DIR}/lib/select.sh"
# shellcheck source=lib/tips.sh
source "${ROOT_DIR}/lib/tips.sh"

TB_PROFILES=""
TB_ONLY=""
TB_EXCLUDE=""
TB_INTERACTIVE=0
TB_UPDATE=0
TB_REMOVE=0
TB_YES=0
TB_LIST=0
TB_INSTALLED=0
TB_INSTALLED_PLAIN=0
TB_DRY_RUN=0
TB_FORCE=0
TB_HELP=0
TB_SHOW_TIPS=1
TB_SAVE_TIPS=""
TB_TIPS_ONLY=0
TB_SAVE_TIPS_SET=0

usage() {
  cat <<'EOF'
CLI Toolbox — установщик утилит

Использование:
  ./install.sh [опции]

Опции:
  --profile LIST     shell,cli,dev,desktop,admin,all (через запятую)
  --only LIST        Только указанные id (через запятую)
  --exclude LIST     Исключить id
  --interactive, -i  Интерактивный выбор (fzf или меню)
  --update           Обновить (или доустановить) выбранные
  --remove           Удалить выбранные утилиты
  --yes, -y          Не спрашивать подтверждение при --remove
  --list             Показать каталог и статус
  --installed        Показать только установленные утилиты
  --installed-ids    Только id установленных (по одному на строку)
  --dry-run          Показать действия без выполнения
  --force            Переустановить даже если уже есть
  --tips-only        Только показать рекомендации (без установки)
  --save-tips [FILE] Сохранить рекомендации в файл (по умолчанию cli-toolbox-tips.md)
  --no-tips          Не показывать рекомендации после установки
  -h, --help         Справка

Примеры:
  ./install.sh --only bat,fzf
  ./install.sh --remove --only bat,fzf
  ./install.sh --remove --profile cli --yes
  ./install.sh --remove --interactive
  ./install.sh --installed
  ./install.sh --update --profile cli
  ./install.sh --list

Документация: docs/install.md
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        TB_PROFILES="${2:-}"
        shift 2
        ;;
      --profile=*)
        TB_PROFILES="${1#*=}"
        shift
        ;;
      --only)
        TB_ONLY="${2:-}"
        shift 2
        ;;
      --only=*)
        TB_ONLY="${1#*=}"
        shift
        ;;
      --exclude)
        TB_EXCLUDE="${2:-}"
        shift 2
        ;;
      --exclude=*)
        TB_EXCLUDE="${1#*=}"
        shift
        ;;
      --interactive|-i)
        TB_INTERACTIVE=1
        shift
        ;;
      --update)
        TB_UPDATE=1
        shift
        ;;
      --remove|--uninstall)
        TB_REMOVE=1
        shift
        ;;
      --yes|-y)
        TB_YES=1
        shift
        ;;
      --list)
        TB_LIST=1
        shift
        ;;
      --installed)
        TB_INSTALLED=1
        shift
        ;;
      --installed-ids)
        TB_INSTALLED=1
        TB_INSTALLED_PLAIN=1
        shift
        ;;
      --dry-run)
        TB_DRY_RUN=1
        shift
        ;;
      --force)
        TB_FORCE=1
        shift
        ;;
      --tips-only)
        TB_TIPS_ONLY=1
        shift
        ;;
      --no-tips)
        TB_SHOW_TIPS=0
        shift
        ;;
      --save-tips)
        TB_SAVE_TIPS_SET=1
        if [[ $# -ge 2 && "${2:0:1}" != "-" ]]; then
          TB_SAVE_TIPS="$2"
          shift 2
        else
          TB_SAVE_TIPS="cli-toolbox-tips.md"
          shift
        fi
        ;;
      --save-tips=*)
        TB_SAVE_TIPS_SET=1
        TB_SAVE_TIPS="${1#*=}"
        if [[ -z "$TB_SAVE_TIPS" ]]; then
          TB_SAVE_TIPS="cli-toolbox-tips.md"
        fi
        shift
        ;;
      -h|--help)
        TB_HELP=1
        shift
        ;;
      *)
        die "Неизвестный аргумент: $1 (см. --help)"
        ;;
    esac
  done
}

emit_tips_for_selection() {
  local tools="$1"
  if [[ -z "$tools" ]]; then
    return 0
  fi
  if [[ "$TB_SHOW_TIPS" -eq 1 || "$TB_TIPS_ONLY" -eq 1 ]]; then
    tips_print_report "$tools"
  fi
  if [[ "$TB_SAVE_TIPS_SET" -eq 1 ]]; then
    tips_save_report "$tools" "$TB_SAVE_TIPS"
  fi
}

main() {
  parse_args "$@"

  if [[ "$TB_HELP" -eq 1 ]]; then
    usage
    exit 0
  fi

  detect_platform
  log_info "Платформа: $(platform_summary)"

  if [[ "$TB_LIST" -eq 1 ]]; then
    print_tool_list all
    exit 0
  fi

  if [[ "$TB_INSTALLED" -eq 1 ]]; then
    # Optional scope via --profile / --only / --exclude
    if [[ -n "$TB_PROFILES" || -n "$TB_ONLY" || -n "$TB_EXCLUDE" ]]; then
      resolve_selection
      if [[ "$TB_INSTALLED_PLAIN" -eq 1 ]]; then
        print_installed_ids "$SELECTED_TOOLS"
      else
        local tid status compat count=0
        printf '%-18s %-10s %-12s %s\n' "ID" "STATUS" "COMPAT" "SUMMARY"
        printf '%-18s %-10s %-12s %s\n' "------------------" "----------" "------------" "-------"
        for tid in $SELECTED_TOOLS; do
          load_tool_file "${TOOLS_DIR}/${tid}.yaml"
          if ! tool_is_installed; then
            continue
          fi
          if tool_compatible; then
            compat="yes"
          else
            compat="skip"
          fi
          printf '%-18s %-10s %-12s %s\n' "$tid" "installed" "$compat" "$TOOL_SUMMARY"
          count=$((count + 1))
        done
        echo
        printf 'Установлено: %s\n' "$count"
      fi
    else
      if [[ "$TB_INSTALLED_PLAIN" -eq 1 ]]; then
        print_installed_ids
      else
        print_tool_list installed
      fi
    fi
    exit 0
  fi

  if [[ "$TB_TIPS_ONLY" -ne 1 ]]; then
    if [[ "$TB_PM" == "unknown" ]]; then
      die "Не удалось определить package manager. Установите brew/apt/pacman/apk/dnf."
    fi
    if [[ "$TB_IS_MACOS" -eq 1 ]]; then
      ensure_brew || true
    fi
  fi

  if [[ "$TB_REMOVE" -eq 1 ]]; then
    if [[ -z "$TB_ONLY" && -z "$TB_PROFILES" && "$TB_INTERACTIVE" -ne 1 ]]; then
      die "Для --remove укажите --only, --profile или --interactive (защита от удаления всего)"
    fi
    if [[ "$TB_UPDATE" -eq 1 ]]; then
      die "Нельзя совмещать --remove и --update"
    fi
  fi

  resolve_selection
  order_selected

  if [[ -z "$SELECTED_TOOLS" ]]; then
    log_warn "Список инструментов пуст"
    exit 0
  fi

  log_info "Выбрано: $SELECTED_TOOLS"

  if [[ "$TB_TIPS_ONLY" -eq 1 ]]; then
    # tips-only always shows unless --no-tips, and respects --save-tips
    if [[ "$TB_SHOW_TIPS" -eq 0 && "$TB_SAVE_TIPS_SET" -eq 0 ]]; then
      die "Укажите вывод: уберите --no-tips или добавьте --save-tips"
    fi
    if [[ "$TB_SHOW_TIPS" -eq 0 ]]; then
      tips_save_report "$SELECTED_TOOLS" "$TB_SAVE_TIPS"
    else
      emit_tips_for_selection "$SELECTED_TOOLS"
    fi
    exit 0
  fi

  if [[ "$TB_REMOVE" -eq 1 ]]; then
    # Keep only tools that are currently installed
    local to_remove="" tid
    for tid in $SELECTED_TOOLS; do
      load_tool_file "${TOOLS_DIR}/${tid}.yaml"
      if tool_is_installed; then
        if [[ -z "$to_remove" ]]; then
          to_remove="$tid"
        else
          to_remove+=" $tid"
        fi
      else
        log_skip "$tid (не установлен)"
      fi
    done
    SELECTED_TOOLS="$to_remove"

    if [[ -z "$SELECTED_TOOLS" ]]; then
      log_warn "Нечего удалять"
      exit 0
    fi

    log_info "К удалению: $SELECTED_TOOLS"
    if [[ "$TB_YES" -ne 1 && "$TB_DRY_RUN" -ne 1 ]]; then
      printf 'Удалить перечисленные утилиты? [y/N] '
      local answer
      read -r answer || true
      case "$answer" in
        y|Y|yes|YES) ;;
        *)
          log_warn "Отменено"
          exit 0
          ;;
      esac
    fi

    echo
    local ok=0 fail=0 rc
    for tid in $SELECTED_TOOLS; do
      load_tool_file "${TOOLS_DIR}/${tid}.yaml"
      set +e
      remove_current_tool
      rc=$?
      set -e
      if [[ "$rc" -eq 0 ]]; then
        ok=$((ok + 1))
      else
        log_error "Ошибка удаления $tid"
        fail=$((fail + 1))
      fi
    done
    echo
    log_info "Удаление завершено: успешно=$ok, ошибок=$fail"
    [[ "$fail" -eq 0 ]]
    exit $?
  fi

  echo

  local tid ok=0 fail=0 rc
  local tipped=""
  for tid in $SELECTED_TOOLS; do
    load_tool_file "${TOOLS_DIR}/${tid}.yaml"
    set +e
    if [[ "$TB_UPDATE" -eq 1 ]]; then
      update_current_tool
      rc=$?
    else
      install_current_tool
      rc=$?
    fi
    set -e
    if [[ "$rc" -eq 0 ]]; then
      ok=$((ok + 1))
      if [[ -z "$tipped" ]]; then
        tipped="$tid"
      else
        tipped+=" $tid"
      fi
    else
      if [[ "$TB_UPDATE" -eq 1 ]]; then
        log_error "Ошибка обновления $tid"
      else
        log_error "Ошибка установки $tid"
      fi
      fail=$((fail + 1))
    fi
  done

  echo
  log_info "Готово: успешно=$ok, ошибок=$fail"

  if [[ -n "$tipped" ]]; then
    emit_tips_for_selection "$tipped"
  fi

  [[ "$fail" -eq 0 ]]
}

main "$@"
