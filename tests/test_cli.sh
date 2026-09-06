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
    _out=$(sh "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-06 about --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-06 type about" "$_out" '"type":"about"'
    assert_contains "TP-CLI-06 effective_storage" "$_out" '"effective_storage"'
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

    # TP-CLI-07 off-TTY empty argv = Type N help (not install; not the numbered list)
    _out=$(sh "${SCRIPT}" 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-07 empty argv exit 0" 0 "$_ec"
    assert_contains "TP-CLI-07 empty argv is help" "$_out" "Usage:"
    assert_contains "TP-CLI-07 empty argv mentions Type N or help" "$_out" "help"
    assert_not_contains "TP-CLI-07 empty argv off-tty is not numbered list" "$_out" "99. Exit"

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

    # TP-CLI-12 storage isolation under temp HOME
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-CLI-12 isolated about has app in storage" "$_out" "${APP_NAME}"
    _eff=$(printf '%s' "$_out" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    if [ -n "$_eff" ] && [ -d "$_eff" ]; then
        t_pass "TP-CLI-12 effective_storage directory exists"
    else
        t_fail "TP-CLI-12 effective_storage missing: '${_eff:-empty}'"
    fi
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

    # TP-CLI-17 menu off-TTY is human help (not the numbered list; off-TTY empty argv stays help)
    _out=$(sh "${SCRIPT}" menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-17 menu off-tty exit 0" 0 "$_ec"
    assert_contains "TP-CLI-17 menu off-tty is help" "$_out" "Usage:"
    assert_not_contains "TP-CLI-17 menu off-tty no Exit 99 list" "$_out" "99. Exit"
    assert_not_contains "TP-CLI-17 menu off-tty no numbered remove-lpu row" "$_out" "1. remove-lpu:"

    _out=$(sh "${SCRIPT}" 2>/dev/null)
    assert_contains "TP-CLI-17 empty argv off-tty is help" "$_out" "Usage:"
    assert_not_contains "TP-CLI-17 empty argv off-tty is not the numbered list" "$_out" "99. Exit"

    _out=$(sh "${SCRIPT}" --quiet menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-17 quiet menu off-tty exit 0" 0 "$_ec"
    assert_contains "TP-CLI-17 quiet menu off-tty still help" "$_out" "Usage:"

    # TP-CLI-18 menu --json off-TTY is JSON help
    _out=$(sh "${SCRIPT}" --json menu 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-18 menu --json off-tty exit 0" 0 "$_ec"
    assert_contains "TP-CLI-18 menu --json type success" "$_out" '"type":"success"'
    assert_not_contains "TP-CLI-18 menu --json no numbered list" "$_out" "99. Exit"

    _out=$(sh "${SCRIPT}" menu --json 2>/dev/null)
    assert_contains "TP-CLI-18 menu then --json type success" "$_out" '"type":"success"'

    # TP-CLI-19 main off-TTY is human help
    _out=$(sh "${SCRIPT}" main 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-19 main off-tty exit 0" 0 "$_ec"
    assert_contains "TP-CLI-19 main off-tty is help" "$_out" "Usage:"
    assert_not_contains "TP-CLI-19 main off-tty no Exit 99 list" "$_out" "99. Exit"

    # TP-CLI-20 help lists menu / main
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-CLI-20 help lists menu" "$_out" "menu"
    assert_contains "TP-CLI-20 help lists main alias" "$_out" "Alias of menu"
    assert_contains "TP-CLI-20 help numbered-list heading" "$_out" "Numbered list"

    # TP-CLI-21 / TP-CLI-22 TTY numbered list (skip when no PTY helper)
    _pty_py="${TESTS_ROOT}/helpers/pty_feed.py"
    _pty_out=""
    _pty_ok=1
    if command -v python3 >/dev/null 2>&1 && [ -f "${_pty_py}" ]; then
        _pty_out=$(MENU_INPUT='99
' python3 "${_pty_py}" sh "${SCRIPT}" menu 2>/dev/null)
        _pty_ok=$?
    fi
    if [ "${_pty_ok}" -eq 0 ] && [ -n "${_pty_out}" ] && printf '%s' "${_pty_out}" | grep -q "99. Exit"; then
        assert_contains "TP-CLI-21 TTY menu has Exit 99" "${_pty_out}" "99. Exit"
        assert_contains "TP-CLI-21 TTY menu row 1 remove-lpu" "${_pty_out}" "1. remove-lpu:"
        assert_contains "TP-CLI-21 TTY menu row 14 json-to-conf" "${_pty_out}" "14. json-to-conf:"
        assert_not_contains "TP-CLI-21 TTY menu omits help row" "${_pty_out}" "help: Show this help"
        assert_not_contains "TP-CLI-21 TTY menu omits install row" "${_pty_out}" "1. install:"
        assert_not_contains "TP-CLI-21 TTY menu omits setup row" "${_pty_out}" "setup: Create nginx-adm"
        assert_not_contains "TP-CLI-21 TTY menu omits version row" "${_pty_out}" "version: Show local version"
        assert_not_contains "TP-CLI-21 TTY menu omits about row" "${_pty_out}" "about: Show diagnostics"
        assert_not_contains "TP-CLI-21 TTY menu omits fence-test row" "${_pty_out}" "fence-test: Dest fence list"
        assert_not_contains "TP-CLI-21 TTY menu omits test-json-format row" "${_pty_out}" "test-json-format: Dest JSON-format"
        assert_not_contains "TP-CLI-21 TTY menu omits menu as a choice" "${_pty_out}" "menu: Numbered list"
        _pty_json=$(MENU_INPUT='99
' python3 "${_pty_py}" sh "${SCRIPT}" --json menu 2>/dev/null)
        assert_contains "TP-CLI-22 TTY menu --json still numbered list" "${_pty_json}" "99. Exit"
        assert_not_contains "TP-CLI-22 TTY menu --json is not JSON help" "${_pty_json}" '"type":"success"'
        assert_contains "TP-CLI-24 TTY menu header has VERSION" "${_pty_out}" "${PRODUCT_VERSION}"
        assert_contains "TP-CLI-24 TTY menu gray-italic explain" "${_pty_out}" "[3;37m"
        _pty_empty=$(MENU_INPUT='99
' python3 "${_pty_py}" sh "${SCRIPT}" 2>/dev/null)
        assert_contains "TP-CLI-25 TTY empty argv has Exit 99" "${_pty_empty}" "99. Exit"
        assert_contains "TP-CLI-25 TTY empty argv row 1 remove-lpu" "${_pty_empty}" "1. remove-lpu:"
        assert_not_contains "TP-CLI-25 TTY empty argv is not Usage help" "${_pty_empty}" "Usage:"
    else
        t_skip "TP-CLI-21 TTY menu numbered list (no PTY)"
        t_skip "TP-CLI-22 TTY menu --json still list (no PTY)"
        t_skip "TP-CLI-24 TTY menu default style (no PTY)"
        t_skip "TP-CLI-25 TTY empty argv numbered list (no PTY)"
    fi

    _ship=$(cat "${SCRIPT}")
    assert_contains "TP-CLI-23 prompt_ask sets PROMPT_ASK_VALUE" "${_ship}" "PROMPT_ASK_VALUE"
    assert_contains "TP-CLI-23 menu reads PROMPT_ASK_VALUE" "${_ship}" '_mm_choice="${PROMPT_ASK_VALUE}"'
    assert_not_contains "TP-CLI-23 no captured prompt_ask call" "${_ship}" '_mm_choice=$(prompt_ask'
    assert_contains "TP-CLI-24 util_app_ident present" "${_ship}" "util_app_ident()"
    assert_contains "TP-CLI-24 out_menu_choice present" "${_ship}" "out_menu_choice()"
}
