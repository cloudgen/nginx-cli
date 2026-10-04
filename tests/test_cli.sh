# =============================================================================
# tests/test_cli.sh — CLI surface (local-only; no network)
# =============================================================================
# Primary REQs: requirement-shell-cli-interface, requirement-shell-cli-zero-arguments,
# requirement-shell-cli-default-interaction, requirement-shell-output-requirements,
# requirement-shell-cli-storage
# TP family: TP-CLI-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

# Drop TTY color wraps so menu rows compare as plain "1. request-side:".
_cli_strip() {
    # ESC then [digits;m. tr drops ESC; sed drops the leftover color opener.
    printf '%s' "$1" | tr -d '\033' | sed 's/\[[0-9;]*m//g'
}

run_test_cli() {
    t_header "CLI surface (TP-CLI)"

    require_cmd sh
    require_cmd grep

    # TP-CLI-01 syntax
    sh -n "${SCRIPT}"
    assert_eq "TP-CLI-01 sh -n ship unit" 0 "$?"

    # TP-CLI-02 version human
    _out=$(sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-02 version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-02 version mentions app" "$_out" "${APP_NAME}"
    assert_contains "TP-CLI-02 version mentions VERSION" "$_out" "${PRODUCT_VERSION}"

    # TP-CLI-03 version json
    _out=$(sh "${SCRIPT}" --json version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-03 version --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-03 type version" "$_out" '"type":"version"'
    assert_contains "TP-CLI-03 app field" "$_out" "\"app\":\"${APP_NAME}\""
    assert_contains "TP-CLI-03 version field" "$_out" "\"version\":\"${PRODUCT_VERSION}\""

    # TP-CLI-04 help lists local lifecycle; not online; not trimmed parent domain
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 help exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 help install" "$_out" "install"
    assert_contains "TP-CLI-04 help uninstall" "$_out" "uninstall"
    assert_contains "TP-CLI-04 help where-is-me" "$_out" "where-is-me"
    assert_contains "TP-CLI-04 help setup" "$_out" "setup"
    assert_contains "TP-CLI-04 help request" "$_out" "request"
    assert_contains "TP-CLI-04 help approve" "$_out" "approve"
    assert_contains "TP-CLI-04 help submit-sudoer-request" "$_out" "submit-sudoer-request"
    assert_contains "TP-CLI-04 help conf-to-json" "$_out" "conf-to-json"
    assert_contains "TP-CLI-04 help json-to-conf" "$_out" "json-to-conf"
    assert_contains "TP-CLI-04 help lists BASHRC" "$_out" "BASHRC"
    assert_not_contains "TP-CLI-04 help does not list rc-test (ship Gap)" "$_out" "rc-test"
    assert_contains "TP-CLI-15 help fence-test" "$_out" "fence-test"
    assert_contains "TP-CLI-15 help test-json-format" "$_out" "test-json-format"
    assert_contains "TP-CLI-15 testers apart" "$_out" "Unit test (local test folder)"
    assert_contains "TP-CLI-16 help --dir" "$_out" "--dir DIR"
    assert_contains "TP-CLI-16 help --expect-match" "$_out" "--expect-match"
    assert_contains "TP-CLI-04 help --json" "$_out" "--json"
    assert_not_contains "TP-CLI-04 no backup verb" "$_out" "backup <"
    assert_not_contains "TP-CLI-04 no restore verb" "$_out" "restore <"
    assert_not_contains "TP-CLI-04 no print-sudoers" "$_out" "print-sudoers"
    assert_not_contains "TP-CLI-04 no self-update" "$_out" "self-update"
    assert_not_contains "TP-CLI-04 no self-uninstall" "$_out" "self-uninstall"
    assert_not_contains "TP-CLI-04 no version-check" "$_out" "version-check"
    assert_not_contains "TP-CLI-04 no SCRIPT_URL channel" "$_out" "SCRIPT_URL"
    assert_not_contains "TP-CLI-04 no CHECKSUM" "$_out" "CHECKSUM"
    assert_not_contains "TP-CLI-14 help has no nginx-ctl" "$_out" "nginx-ctl"

    # TP-CLI-05 help json
    _out=$(sh "${SCRIPT}" --json help 2>/dev/null)
    assert_eq "TP-CLI-05 help --json exit 0" 0 "$?"
    assert_contains "TP-CLI-05 help json success" "$_out" '"type":"success"'

    # TP-CLI-06 about json storage + nginx-adm domain fields; no backup fields
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-06 about --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-06 type about" "$_out" '"type":"about"'
    assert_contains "TP-CLI-06 effective_storage" "$_out" '"effective_storage"'
    assert_contains "TP-CLI-06 cache_used" "$_out" '"cache_used"'
    assert_contains "TP-CLI-06 cache_preferred" "$_out" '"cache_preferred"'
    assert_contains "TP-CLI-06 cache_fallback" "$_out" '"cache_fallback"'
    assert_contains "TP-CLI-06 cache_fallback_2" "$_out" '"cache_fallback_2"'
    assert_contains "TP-CLI-06 persistence_storage" "$_out" '"persistence_storage"'
    assert_contains "TP-CLI-06 storage_dir" "$_out" '"storage_dir"'
    assert_contains "TP-CLI-06 preferred path shape" "$_out" "/dev/shm/cache/cache-${APP_NAME}-"
    assert_contains "TP-CLI-06 nginx_adm_user" "$_out" '"nginx_adm_user"'
    assert_contains "TP-CLI-06 pending_count" "$_out" '"pending_count"'
    assert_contains "TP-CLI-06 sudoer_cli" "$_out" '"sudoer_cli"'
    assert_contains "TP-CLI-06 sudoer_adm" "$_out" '"sudoer_adm"'
    assert_contains "TP-CLI-06 sudoer_inbound" "$_out" '"sudoer_inbound"'
    assert_not_contains "TP-CLI-06 no backup_notation" "$_out" '"backup_notation"'
    assert_not_contains "TP-CLI-06 no deposit_dir" "$_out" '"deposit_dir"'
    assert_not_contains "TP-CLI-06 no restore_host_default" "$_out" '"restore_host_default"'
    assert_not_contains "TP-CLI-06 no CHECKSUM" "$_out" "CHECKSUM"
    assert_not_contains "TP-CLI-06 no SCRIPT_URL" "$_out" "SCRIPT_URL"
    ci_cleanup_env

    # TP-CLI-07 off-TTY empty argv = local self-install (not help, not the menu, not setup)
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-07 empty argv exit 0" 0 "$_ec"
    assert_contains "TP-CLI-07 empty argv starts self-install" "$_out" "Starting self-install"
    assert_file_exists "TP-CLI-07 empty argv placed user bin" "${CI_USER_BIN}/${APP_NAME}"
    assert_not_contains "TP-CLI-07 empty argv is not Usage help" "$_out" "Usage:"
    assert_not_contains "TP-CLI-07 empty argv is not the front menu" "$_out" "9. Exit"
    assert_not_contains "TP-CLI-07 empty argv does not run setup" "$_out" "nginx-adm"
    _mode=$(stat -c %a "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    assert_eq "TP-CLI-07 placed binary mode 0755" "755" "${_mode}"
    ci_cleanup_env

    # TP-CLI-08 unknown command fail-closed
    _err=$(sh "${SCRIPT}" no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-08 unknown exit 1" 1 "$_ec"
    assert_contains "TP-CLI-08 unknown error text" "$_err" "Unknown command"

    _err=$(sh "${SCRIPT}" --json no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-08 unknown --json exit 1" 1 "$_ec"
    assert_contains "TP-CLI-08 unknown --json type" "$_err" '"type":"out_error"'

    # TP-CLI-09 quiet suppresses version info
    _out=$(sh "${SCRIPT}" --quiet version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-09 quiet version exit 0" 0 "$_ec"
    _trim=$(printf '%s' "$_out" | tr -d ' \t\n\r')
    if [ -z "$_trim" ]; then
        t_pass "TP-CLI-09 quiet suppresses human version"
    else
        t_fail "TP-CLI-09 quiet expected empty stdout, got '$(_trunc "$_out")'"
    fi

    # TP-CLI-10 online verbs rejected
    _err=$(sh "${SCRIPT}" self-update 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 self-update exit 1" 1 "$?"
    assert_contains "TP-CLI-10 self-update unknown" "$_err" "Unknown command"

    _err=$(sh "${SCRIPT}" version-check 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 version-check exit 1" 1 "$?"

    # TP-CLI-11 set -u HOME unset still works for version
    _out=$(env -u HOME sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-11 env -u HOME version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-11 env -u HOME version text" "$_out" "${PRODUCT_VERSION}"

    # TP-CLI-12 cache tiers + persistence under temp HOME (no XDG tier, no exec from cache)
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-CLI-12 isolated about has app in storage" "$_out" "${APP_NAME}"
    _eff=$(printf '%s' "$_out" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    _pref=$(printf '%s' "$_out" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _fb=$(printf '%s' "$_out" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    _fb2=$(printf '%s' "$_out" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    _stor=$(printf '%s' "$_out" | sed -n 's/.*"storage_dir":"\([^"]*\)".*/\1/p' | head -n1)
    _pers=$(printf '%s' "$_out" | sed -n 's/.*"persistence_storage":"\([^"]*\)".*/\1/p' | head -n1)
    if [ -n "$_eff" ] && [ -d "$_eff" ]; then
        t_pass "TP-CLI-12 effective_storage directory exists"
    else
        t_fail "TP-CLI-12 effective_storage missing: '${_eff:-empty}'"
    fi
    assert_contains "TP-CLI-12 preferred is /dev/shm/cache" "${_pref}" "/dev/shm/cache/cache-${APP_NAME}-"
    assert_contains "TP-CLI-12 fallback is /tmp/cache" "${_fb}" "/tmp/cache/cache-${APP_NAME}-"
    assert_contains "TP-CLI-12 fallback 2 is home .cache leaf" "${_fb2}" "${CI_HOME}/.cache/cache-${APP_NAME}-"
    assert_eq "TP-CLI-12 storage_dir is 1st fallback" "${_fb}" "${_stor}"
    assert_eq "TP-CLI-12 persistence is home .local app" "${CI_HOME}/.local/${APP_NAME}" "${_pers}"
    assert_file_exists "TP-CLI-12 persistence directory exists" "${_pers}"
    _mode=$(stat -c %a "${_eff}" 2>/dev/null || echo "")
    assert_eq "TP-CLI-12 cache leaf mode 0700" "700" "${_mode}"
    assert_not_contains "TP-CLI-12 json has no CHECKSUM" "$_out" "CHECKSUM"
    assert_not_contains "TP-CLI-12 preferred is not XDG_CACHE_HOME" "${_pref}" "XDG_CACHE_HOME"
    _human=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-12 human cache used" "${_human}" "Cache folder used:"
    assert_contains "TP-CLI-12 human cache preferred" "${_human}" "Cache folder (preferred):"
    assert_contains "TP-CLI-12 human cache fallback" "${_human}" "Cache folder (1st fallback):"
    assert_contains "TP-CLI-12 human cache fallback 2" "${_human}" "Cache folder (2nd fallback):"
    assert_contains "TP-CLI-12 human persistence" "${_human}" "Persistence storage:"
    assert_not_contains "TP-CLI-12 human has no Storage (effective" "${_human}" "Storage (effective"
    _skip_err=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" NGINX_CLI_CACHE_SKIP=preferred sh "${SCRIPT}" --json about 2>&1 >/dev/null)
    _skip_out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" NGINX_CLI_CACHE_SKIP=preferred sh "${SCRIPT}" --json about 2>/dev/null)
    _skip_used=$(printf '%s' "${_skip_out}" | sed -n 's/.*"cache_used":"\([^"]*\)".*/\1/p' | head -n1)
    assert_contains "TP-CLI-12 skip preferred uses /tmp/cache" "${_skip_used}" "/tmp/cache/cache-${APP_NAME}-"
    assert_not_contains "TP-CLI-12 skip preferred is silent" "${_skip_err}" "Cannot create cache folder"
    assert_not_contains "TP-CLI-12 skip preferred no warn text" "${_skip_err}" "preferred"
    _gb=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" NGINX_CLI_CACHE_HOST=gitbash sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-CLI-12 gitbash preferred /tmp/cache" "${_gb}" '"cache_preferred":"/tmp/cache/cache-'"${APP_NAME}"'-'
    assert_contains "TP-CLI-12 gitbash fallback AppData" "${_gb}" "${CI_HOME}/AppData/Local/Temp/cache-${APP_NAME}-"
    assert_contains "TP-CLI-12 gitbash no 2nd fallback" "${_gb}" '"cache_fallback_2":""'
    _gbh=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" NGINX_CLI_CACHE_HOST=gitbash sh "${SCRIPT}" about 2>/dev/null)
    assert_not_contains "TP-CLI-12 gitbash human omits 2nd fallback" "${_gbh}" "2nd fallback"
    ci_cleanup_env

    # TP-CLI-13 trimmed parent domain / sudoers verbs fail closed
    for _verb in backup restore print-sudoers print-sudoers-install-script remove-project-sudoers self-uninstall; do
        _err=$(sh "${SCRIPT}" "${_verb}" 2>&1 >/dev/null)
        _ec=$?
        assert_eq "TP-CLI-13 ${_verb} exit 1" 1 "$_ec"
        assert_contains "TP-CLI-13 ${_verb} unknown" "$_err" "Unknown command"
    done

    # TP-CLI-14 invented peer command does not exist
    _err=$(sh "${SCRIPT}" nginx-ctl 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-14 nginx-ctl exit 1" 1 "$_ec"
    assert_contains "TP-CLI-14 nginx-ctl unknown" "$_err" "Unknown command"

    # TP-CLI-17 named menu/main off-TTY fail closed (not help)
    _out=$(sh "${SCRIPT}" menu 2>&1)
    _ec=$?
    assert_eq "TP-CLI-17 menu off-tty exit 1" 1 "$_ec"
    assert_contains "TP-CLI-17 menu off-tty needs a terminal" "$_out" "menu needs a terminal"
    assert_not_contains "TP-CLI-17 menu off-tty is not Usage help" "$_out" "Usage:"
    assert_not_contains "TP-CLI-17 menu off-tty is not the front menu" "$_out" "9. Exit"

    _out=$(sh "${SCRIPT}" --quiet menu 2>&1)
    _ec=$?
    assert_eq "TP-CLI-17 quiet menu off-tty exit 1" 1 "$_ec"
    assert_contains "TP-CLI-17 quiet menu off-tty needs a terminal" "$_out" "menu needs a terminal"

    # TP-CLI-18 menu --json off-TTY is an error, not JSON help
    _out=$(sh "${SCRIPT}" --json menu 2>&1)
    _ec=$?
    assert_eq "TP-CLI-18 menu --json off-tty exit 1" 1 "$_ec"
    assert_contains "TP-CLI-18 menu --json needs a terminal" "$_out" "menu needs a terminal"
    assert_contains "TP-CLI-18 menu --json type error" "$_out" '"type":"out_error"'
    assert_not_contains "TP-CLI-18 menu --json is not success help" "$_out" '"type":"success"'

    _out=$(sh "${SCRIPT}" menu --json 2>&1)
    assert_eq "TP-CLI-18 menu then --json exit 1" 1 "$?"
    assert_contains "TP-CLI-18 menu then --json needs a terminal" "$_out" "menu needs a terminal"
    assert_not_contains "TP-CLI-18 menu then --json is not success help" "$_out" '"type":"success"'

    # TP-CLI-19 main off-TTY fail closed (nginx id stays main, not a help test)
    _out=$(sh "${SCRIPT}" main 2>&1)
    _ec=$?
    assert_eq "TP-CLI-19 main off-tty exit 1" 1 "$_ec"
    assert_contains "TP-CLI-19 main off-tty needs a terminal" "$_out" "menu needs a terminal"
    assert_not_contains "TP-CLI-19 main off-tty is not Usage help" "$_out" "Usage:"

    # TP-CLI-20 help lists menu / main and the zero-cli-verb split
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-CLI-20 help lists menu" "$_out" "menu"
    assert_contains "TP-CLI-20 help lists main alias" "$_out" "Alias of menu"
    assert_contains "TP-CLI-20 help numbered-list heading" "$_out" "Numbered list"
    assert_contains "TP-CLI-20 help lists self-install" "$_out" "self-install"
    assert_contains "TP-CLI-20 help says switches are still no command" "$_out" "--debug"
    assert_not_contains "TP-CLI-20 help does not list self-update" "$_out" "self-update"
    assert_not_contains "TP-CLI-20 help does not list version-check" "$_out" "version-check"

    # TP-CLI-23 switches with no verb, and menu choice is read -r
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" --debug 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-23 off-tty --debug empty is self-install exit 0" 0 "$_ec"
    assert_contains "TP-CLI-23 off-tty --debug starts self-install" "$_out" "Starting self-install"
    assert_not_contains "TP-CLI-23 off-tty --debug is not the menu" "$_out" "9. Exit"
    assert_file_exists "TP-CLI-23 off-tty --debug placed user bin" "${CI_USER_BIN}/${APP_NAME}"
    rm -f "${CI_USER_BIN}/${APP_NAME}"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" --quiet 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-23 --quiet empty exit 0" 0 "$_ec"
    assert_file_exists "TP-CLI-23 --quiet empty placed user bin" "${CI_USER_BIN}/${APP_NAME}"
    assert_not_contains "TP-CLI-23 --quiet empty is not Usage" "$_out" "Usage:"
    rm -f "${CI_USER_BIN}/${APP_NAME}"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" --json 2>&1)
    _ec=$?
    assert_eq "TP-CLI-23 --json empty exit 0" 0 "$_ec"
    assert_file_exists "TP-CLI-23 --json empty placed user bin" "${CI_USER_BIN}/${APP_NAME}"
    assert_not_contains "TP-CLI-23 --json empty is not help success" "$_out" '"type":"success"'
    assert_not_contains "TP-CLI-23 --json empty is not the menu" "$_out" "9. Exit"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" --debug version 2>/dev/null)
    assert_contains "TP-CLI-23 --debug version stays version" "$_out" "${PRODUCT_VERSION}"
    assert_not_contains "TP-CLI-23 --debug version is not self-install" "$_out" "Starting self-install"
    assert_not_contains "TP-CLI-23 --debug version is not the menu" "$_out" "9. Exit"
    ci_cleanup_env

    _ship=$(cat "${SCRIPT}")
    assert_contains "TP-CLI-23 prompt_ask sets PROMPT_ASK_VALUE" "${_ship}" "PROMPT_ASK_VALUE"
    assert_contains "TP-CLI-23 menu uses read -r" "${_ship}" "read -r _choice"
    assert_not_contains "TP-CLI-23 menu does not capture prompt_ask" "${_ship}" '_choice=$(prompt_ask'
    assert_not_contains "TP-CLI-23 menu does not capture _mm_choice" "${_ship}" '_mm_choice=$(prompt_ask'
    assert_not_contains "TP-CLI-23 menu choice is not PROMPT_ASK_VALUE" "${_ship}" '_mm_choice="${PROMPT_ASK_VALUE}"'
    assert_contains "TP-CLI-24 util_app_ident present" "${_ship}" "util_app_ident()"
    assert_contains "TP-CLI-24 out_menu_choice present" "${_ship}" "out_menu_choice()"
    assert_contains "TP-CLI-26 menu invalid uses out_warn" "${_ship}" "ngx_menu_warn"
    assert_contains "TP-CLI-26 unknown menu choice text" "${_ship}" "Unknown menu choice"
    assert_not_contains "TP-CLI-26 menu invalid does not out_die" "${_ship}" 'out_die "That is not a menu choice'
    assert_not_contains "TP-CLI-26 menu invalid is not out_error" "${_ship}" 'out_error "Unknown menu choice'

    # TP-CLI-21 / 22 / 24 / 25 / 26 / 27 TTY layered menu (skip when no PTY helper)
    _pty_py="${TESTS_ROOT}/helpers/pty_feed.py"
    _pty_out=""
    _pty_ok=1
    if command -v python3 >/dev/null 2>&1 && [ -f "${_pty_py}" ]; then
        ci_isolated_env
        _pty_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='9
' python3 "${_pty_py}" sh "${SCRIPT}" menu 2>/dev/null)
        _pty_ok=$?
        _pty_out=$(_cli_strip "${_pty_raw}")
    fi
    if [ "${_pty_ok}" -eq 0 ] && [ -n "${_pty_out}" ] && printf '%s' "${_pty_out}" | grep -q "9. Exit"; then
        assert_contains "TP-CLI-21 TTY menu has Exit 9" "${_pty_out}" "9. Exit"
        assert_contains "TP-CLI-21 TTY front request-side" "${_pty_out}" "1. request-side:"
        assert_contains "TP-CLI-21 TTY front host-side" "${_pty_out}" "2. host-side:"
        assert_contains "TP-CLI-21 TTY front language" "${_pty_out}" "5. language:"
        assert_contains "TP-CLI-21 TTY front sudoers" "${_pty_out}" "7. sudoers:"
        assert_contains "TP-CLI-21 TTY front self-management" "${_pty_out}" "8. self-management:"
        assert_not_contains "TP-CLI-21 TTY front is not flat remove-lpu" "${_pty_out}" "1. remove-lpu:"
        assert_not_contains "TP-CLI-21 TTY front is not Exit 99" "${_pty_out}" "99. Exit"
        assert_not_contains "TP-CLI-21 TTY front omits install row" "${_pty_out}" "1. install:"
        assert_not_contains "TP-CLI-21 TTY front omits setup row" "${_pty_out}" "2. setup:"
        assert_not_contains "TP-CLI-21 TTY front omits help row" "${_pty_out}" "help:"
        assert_not_contains "TP-CLI-21 TTY front omits fence-test row" "${_pty_out}" "fence-test:"
        assert_not_contains "TP-CLI-21 TTY front omits test-json-format row" "${_pty_out}" "test-json-format:"
        assert_contains "TP-CLI-24 TTY menu header has VERSION" "${_pty_raw}" "${PRODUCT_VERSION}"
        assert_contains "TP-CLI-24 TTY menu gray-italic explain" "${_pty_raw}" "[3;37m"
        assert_contains "TP-CLI-24 TTY menu bold short" "${_pty_raw}" "[1m"
        _pty_json_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='9
' python3 "${_pty_py}" sh "${SCRIPT}" --json menu 2>/dev/null)
        _pty_json=$(_cli_strip "${_pty_json_raw}")
        assert_contains "TP-CLI-22 TTY menu --json still front menu" "${_pty_json}" "9. Exit"
        assert_contains "TP-CLI-22 TTY menu --json still request-side" "${_pty_json}" "1. request-side:"
        assert_not_contains "TP-CLI-22 TTY menu --json is not JSON help" "${_pty_json}" '"type":"success"'
        _pty_empty_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='9
' python3 "${_pty_py}" sh "${SCRIPT}" 2>/dev/null)
        _pty_empty=$(_cli_strip "${_pty_empty_raw}")
        assert_contains "TP-CLI-25 TTY empty argv has Exit 9" "${_pty_empty}" "9. Exit"
        assert_contains "TP-CLI-25 TTY empty argv request-side" "${_pty_empty}" "1. request-side:"
        assert_not_contains "TP-CLI-25 TTY empty argv is not Usage help" "${_pty_empty}" "Usage:"
        assert_not_contains "TP-CLI-25 TTY empty argv did not self-install" "${_pty_empty}" "Starting self-install"
        _pty_dbg_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='9
' python3 "${_pty_py}" sh "${SCRIPT}" --debug 2>/dev/null)
        _pty_dbg=$(_cli_strip "${_pty_dbg_raw}")
        assert_contains "TP-CLI-23 TTY --debug empty is the menu" "${_pty_dbg}" "9. Exit"
        assert_not_contains "TP-CLI-23 TTY --debug empty did not self-install" "${_pty_dbg}" "Starting self-install"
        _pty_force_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='9
' python3 "${_pty_py}" sh "${SCRIPT}" --force 2>/dev/null)
        _pty_force=$(_cli_strip "${_pty_force_raw}")
        assert_contains "TP-CLI-23 TTY --force empty is the menu" "${_pty_force}" "1. request-side:"
        assert_not_contains "TP-CLI-23 TTY --force empty did not install" "${_pty_force}" "Starting self-install"

        _pty_bad_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='6
9
' python3 "${_pty_py}" sh "${SCRIPT}" menu 2>/dev/null)
        _pty_bad=$(_cli_strip "${_pty_bad_raw}")
        assert_contains "TP-CLI-26 TTY unused 6 is WARN" "${_pty_bad}" "[WARN]"
        assert_contains "TP-CLI-26 TTY unused 6 names the pick" "${_pty_bad}" "Unknown menu choice '6'"
        assert_not_contains "TP-CLI-26 TTY unused 6 is not unknown argv" "${_pty_bad}" "Unknown command"
        _exit_n=$(printf '%s' "${_pty_bad}" | grep -c "9. Exit" || true)
        if [ "${_exit_n}" -ge 2 ]; then
            t_pass "TP-CLI-26 TTY unused 6 reprints this layer (${_exit_n} Exit rows)"
        else
            t_fail "TP-CLI-26 TTY unused 6 reprints this layer (Exit rows=${_exit_n}, want >=2)"
        fi
        _pty_name_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='not-a-command
9
' python3 "${_pty_py}" sh "${SCRIPT}" menu 2>/dev/null)
        _pty_name=$(_cli_strip "${_pty_name_raw}")
        assert_contains "TP-CLI-26 TTY unknown name is WARN" "${_pty_name}" "[WARN]"
        assert_contains "TP-CLI-26 TTY unknown name names the pick" "${_pty_name}" "Unknown menu choice 'not-a-command'"
        assert_not_contains "TP-CLI-26 TTY unknown name is not unknown argv" "${_pty_name}" "Unknown command"

        _req_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='1
0
9
' python3 "${_pty_py}" sh "${SCRIPT}" menu 2>/dev/null)
        _req=$(_cli_strip "${_req_raw}")
        assert_contains "TP-CLI-27 request board row 11" "${_req}" "11. request:"
        assert_contains "TP-CLI-27 request board row 111" "${_req}" "111. json-to-conf:"
        assert_contains "TP-CLI-27 request board back" "${_req}" "0. Back"
        _host_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='2
0
9
' python3 "${_pty_py}" sh "${SCRIPT}" menu 2>/dev/null)
        _host=$(_cli_strip "${_host_raw}")
        assert_contains "TP-CLI-27 host board setup" "${_host}" "21. setup:"
        assert_contains "TP-CLI-27 host board enable-login" "${_host}" "23. enable-login-approval:"
        _sudo_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='7
0
9
' python3 "${_pty_py}" sh "${SCRIPT}" menu 2>/dev/null)
        _sudo=$(_cli_strip "${_sudo_raw}")
        assert_contains "TP-CLI-27 sudoers board submit" "${_sudo}" "71. submit-sudoer-request:"
        assert_not_contains "TP-CLI-27 sudoers board has no print-sudoers" "${_sudo}" "print-sudoers"
        _self_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='8
0
9
' python3 "${_pty_py}" sh "${SCRIPT}" menu 2>/dev/null)
        _self=$(_cli_strip "${_self_raw}")
        assert_contains "TP-CLI-27 self board install" "${_self}" "81. install:"
        assert_contains "TP-CLI-27 self board self-install" "${_self}" "87. self-install:"
        assert_contains "TP-CLI-27 self board hides online verbs" "${_self}" "not on this menu"
        assert_not_contains "TP-CLI-27 self board has no version-check row" "${_self}" "84. version-check:"

        _langf="${CI_HOME}/.local/${APP_NAME}/language"
        _lang_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='5
52
9
' python3 "${_pty_py}" sh "${SCRIPT}" menu 2>/dev/null)
        _lang=$(_cli_strip "${_lang_raw}")
        assert_contains "TP-CLI-28 language board lists zh-Hans" "${_lang}" "52. 简体中文:"
        if [ -f "${_langf}" ] && [ "$(head -n 1 "${_langf}")" = "zh-Hans" ]; then
            t_pass "TP-CLI-28 pick 52 writes zh-Hans"
        else
            t_fail "TP-CLI-28 pick 52 writes zh-Hans (got '$(head -n 1 "${_langf}" 2>/dev/null)')"
        fi
        _lmode=$(stat -c %a "${_langf}" 2>/dev/null || echo "")
        assert_eq "TP-CLI-28 language file mode 0600" "600" "${_lmode}"
        assert_contains "TP-CLI-28 front redisplays in zh-Hans" "${_lang}" "9. 退出"
        rm -f "${_langf}"
        _res_raw=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" MENU_INPUT='5
50
0
9
' python3 "${_pty_py}" sh "${SCRIPT}" menu 2>/dev/null)
        _res=$(_cli_strip "${_res_raw}")
        assert_contains "TP-CLI-28 reserved 50 warns" "${_res}" "Unknown menu choice '50'"
        assert_file_missing "TP-CLI-28 reserved 50 does not write language" "${_langf}"
        printf '%s\n' "nope" > "${_langf}"
        chmod 600 "${_langf}"
        _unk=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" sh "${SCRIPT}" help 2>/dev/null)
        assert_contains "TP-CLI-28 unknown language line stays English" "${_unk}" "Usage:"
        assert_not_contains "TP-CLI-28 unknown language line is not Japanese heading" "${_unk}" "使い方"
        if [ "$(head -n 1 "${_langf}")" = "nope" ]; then
            t_pass "TP-CLI-28 unknown language line is not rewritten"
        else
            t_fail "TP-CLI-28 unknown language line is not rewritten"
        fi
        _ja=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" NGINX_CLI_LANG=ja sh "${SCRIPT}" help 2>/dev/null)
        assert_contains "TP-CLI-28 NGINX_CLI_LANG=ja usage heading" "${_ja}" "使い方:"
        ci_cleanup_env
    else
        t_skip "TP-CLI-21 TTY layered menu (no PTY)"
        t_skip "TP-CLI-22 TTY menu --json still menu (no PTY)"
        t_skip "TP-CLI-23 TTY --debug/--force menu (no PTY)"
        t_skip "TP-CLI-24 TTY menu default style (no PTY)"
        t_skip "TP-CLI-25 TTY empty argv menu (no PTY)"
        t_skip "TP-CLI-26 TTY invalid choice retry (no PTY)"
        t_skip "TP-CLI-27 TTY category boards (no PTY)"
        t_skip "TP-CLI-28 language file (no PTY)"
        ci_cleanup_env
    fi
}
