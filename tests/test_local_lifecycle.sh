# =============================================================================
# tests/test_local_lifecycle.sh — local install / uninstall / where-is-me
# =============================================================================
# Primary REQs: requirement-shell-local-self-management, requirement-shell-idempotency,
# requirement-shell-interactive-vs-noninteractive,
# requirement-shell-path-and-shell-support (TP-LC-11..14, TP-LC-20..22)
# TP family: TP-LC-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_local_lifecycle() {
    t_header "Local lifecycle (TP-LC)"

    require_cmd sh

    ci_isolated_env

    # TP-LC-01 install places binary under USER_BIN
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-01 install exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-01 binary at USER_BIN" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-LC-01 install success text" "$_out" "Installed"

    # TP-LC-11 install creates ~/.bashrc with USER_BIN PATH
    assert_file_exists "TP-LC-11 created ~/.bashrc" "${CI_HOME}/.bashrc"
    _bashrc=$(cat "${CI_HOME}/.bashrc" 2>/dev/null || true)
    _path_line=$(ci_bashrc_path_line)
    assert_contains "TP-LC-11 bashrc has USER_BIN" "$_bashrc" "${CI_USER_BIN}"
    assert_contains "TP-LC-11 bashrc has VERSION" "$_bashrc" "${PRODUCT_VERSION}"
    assert_contains "TP-LC-11 bashrc exact export PATH" "$_bashrc" "${_path_line}"

    # TP-LC-12 install creates ~/.profile that sources ~/.bashrc
    assert_file_exists "TP-LC-12 created ~/.profile" "${CI_HOME}/.profile"
    _profile=$(cat "${CI_HOME}/.profile" 2>/dev/null || true)
    assert_contains "TP-LC-12 profile sources bashrc" "$_profile" '. "${HOME}/.bashrc"'

    # TP-LC-02 installed version works
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" version 2>/dev/null)
    assert_eq "TP-LC-02 installed version exit 0" 0 "$?"
    assert_contains "TP-LC-02 installed version" "$_out" "${PRODUCT_VERSION}"

    # TP-LC-03 idempotent reinstall without force
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-03 reinstall exit 0" 0 "$_ec"
    assert_contains "TP-LC-03 already installed" "$_out" "already installed"

    # TP-LC-13 re-run does not duplicate PATH lines
    _path_line=$(ci_bashrc_path_line)
    _path_hits=$(grep -cF "${_path_line}" "${CI_HOME}/.bashrc" 2>/dev/null || true)
    [ -z "${_path_hits}" ] && _path_hits=0
    assert_eq "TP-LC-13 bashrc PATH line once" "1" "${_path_hits}"

    # TP-LC-04 where-is-me
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" where-is-me 2>&1)
    _ec=$?
    assert_eq "TP-LC-04 where-is-me exit 0" 0 "$_ec"
    assert_contains "TP-LC-04 install path" "$_out" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-LC-04 installed yes" "$_out" "yes"

    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" --json where-is-me 2>/dev/null)
    assert_contains "TP-LC-04 json installed true" "$_out" '"installed":"true"'

    # TP-LC-05 uninstall --json without force fails closed
    _err=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" --json uninstall 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-LC-05 uninstall json no-force exit 1" 1 "$_ec"
    assert_file_exists "TP-LC-05 binary remains" "${CI_USER_BIN}/${APP_NAME}"

    # TP-LC-06 uninstall --force removes
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" uninstall --force 2>&1)
    _ec=$?
    assert_eq "TP-LC-06 uninstall --force exit 0" 0 "$_ec"
    assert_file_missing "TP-LC-06 binary removed" "${CI_USER_BIN}/${APP_NAME}"

    # TP-LC-07 uninstall when absent is success no-op
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" uninstall --force 2>&1)
    _ec=$?
    assert_eq "TP-LC-07 uninstall absent exit 0" 0 "$_ec"
    assert_contains "TP-LC-07 nothing to uninstall" "$_out" "not installed"

    # TP-LC-08 about after install shows installed
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install >/dev/null 2>&1
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" --json about 2>/dev/null)
    assert_contains "TP-LC-08 about installed true" "$_out" '"installed":"true"'

    # TP-LC-09 managed binary mode must be 0755 (shell ship unit multi-user runnable)
    _mode=$(stat -c '%a' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || stat -f '%OLp' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    case "${_mode}" in
        755|0755) assert_eq "TP-LC-09 install mode 0755" "0755" "0755" ;;
        *) assert_eq "TP-LC-09 install mode 0755" "0755" "${_mode}" ;;
    esac
    # Must be readable+executable (not 0711 execute-without-read)
    if [ -r "${CI_USER_BIN}/${APP_NAME}" ] && [ -x "${CI_USER_BIN}/${APP_NAME}" ]; then
        assert_eq "TP-LC-09 readable+executable" "1" "1"
    else
        assert_eq "TP-LC-09 readable+executable" "1" "0"
    fi

    # TP-LC-10 re-install without --force heals broken mode (0711 trap)
    chmod 0711 "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || chmod 711 "${CI_USER_BIN}/${APP_NAME}"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-10 heal reinstall exit 0" 0 "$_ec"
    assert_contains "TP-LC-10 already installed path" "$_out" "already installed"
    _mode=$(stat -c '%a' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || stat -f '%OLp' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    case "${_mode}" in
        755|0755) assert_eq "TP-LC-10 healed mode 0755" "0755" "0755" ;;
        *) assert_eq "TP-LC-10 healed mode 0755" "0755" "${_mode}" ;;
    esac

    # cleanup remaining binary
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" uninstall --force >/dev/null 2>&1 || true
    ci_cleanup_env

    # TP-LC-14 existing ~/.profile body is kept; ~/.bashrc is modified not replaced
    ci_isolated_env
    printf '%s\n' "# keep-me-profile" > "${CI_HOME}/.profile"
    printf '%s\n' "# keep-me-bashrc" > "${CI_HOME}/.bashrc"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-14 install with existing rc exit 0" 0 "$_ec"
    _profile=$(cat "${CI_HOME}/.profile" 2>/dev/null || true)
    _bashrc=$(cat "${CI_HOME}/.bashrc" 2>/dev/null || true)
    assert_contains "TP-LC-14 profile body kept" "$_profile" "keep-me-profile"
    assert_not_contains "TP-LC-14 profile not replaced with marker block" "$_profile" "BEGIN ${APP_NAME} profile"
    assert_contains "TP-LC-14 bashrc body kept" "$_bashrc" "keep-me-bashrc"
    assert_contains "TP-LC-14 bashrc still got PATH" "$_bashrc" "${CI_USER_BIN}"
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${CI_USER_BIN}/${APP_NAME}" uninstall --force >/dev/null 2>&1 || true
    ci_cleanup_env

    # TP-LC-20 BASHRC env: create the file in a random temp folder when missing
    ci_isolated_env
    ci_isolated_bashrc
    assert_file_missing "TP-LC-20 BASHRC absent before install" "${CI_BASHRC}"
    assert_file_missing "TP-LC-20 HOME/.bashrc absent before install" "${CI_HOME}/.bashrc"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" BASHRC="${CI_BASHRC}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-20 install exit 0" 0 "$_ec"
    assert_file_exists "TP-LC-20 created BASHRC in temp folder" "${CI_BASHRC}"
    assert_file_missing "TP-LC-20 did not write HOME/.bashrc" "${CI_HOME}/.bashrc"
    _bashrc=$(cat "${CI_BASHRC}" 2>/dev/null || true)
    _path_line=$(ci_bashrc_path_line)
    assert_contains "TP-LC-20 created header names VERSION" "$_bashrc" "Interactive rc created by ${APP_NAME} installer (${PRODUCT_VERSION})"
    assert_contains "TP-LC-20 created Added-by VERSION" "$_bashrc" "Added by ${APP_NAME} installer (${PRODUCT_VERSION})"
    assert_contains "TP-LC-20 created exact export PATH" "$_bashrc" "${_path_line}"
    assert_contains "TP-LC-20 reports created BASHRC" "$_out" "Created ${CI_BASHRC}"
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" BASHRC="${CI_BASHRC}" sh "${CI_USER_BIN}/${APP_NAME}" uninstall --force >/dev/null 2>&1 || true
    ci_cleanup_env

    # TP-LC-21 BASHRC env: modify a dongle .bashrc in that random temp folder
    ci_isolated_env
    ci_isolated_bashrc
    printf '%s\n' "# dongle-bashrc-keep" "alias dongle_probe=true" > "${CI_BASHRC}"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" BASHRC="${CI_BASHRC}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-21 install exit 0" 0 "$_ec"
    assert_file_missing "TP-LC-21 did not write HOME/.bashrc" "${CI_HOME}/.bashrc"
    _bashrc=$(cat "${CI_BASHRC}" 2>/dev/null || true)
    _path_line=$(ci_bashrc_path_line)
    assert_contains "TP-LC-21 dongle body kept" "$_bashrc" "dongle-bashrc-keep"
    assert_contains "TP-LC-21 dongle alias kept" "$_bashrc" "alias dongle_probe=true"
    assert_contains "TP-LC-21 dongle got Added-by VERSION" "$_bashrc" "Added by ${APP_NAME} installer (${PRODUCT_VERSION})"
    assert_contains "TP-LC-21 dongle exact export PATH" "$_bashrc" "${_path_line}"
    _path_hits=$(grep -cF "${_path_line}" "${CI_BASHRC}" 2>/dev/null || true)
    [ -z "${_path_hits}" ] && _path_hits=0
    assert_eq "TP-LC-21 PATH export once" "1" "${_path_hits}"
    assert_contains "TP-LC-21 reports PATH added" "$_out" "Added ${CI_USER_BIN} to PATH for bash"
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" BASHRC="${CI_BASHRC}" sh "${CI_USER_BIN}/${APP_NAME}" uninstall --force >/dev/null 2>&1 || true
    ci_cleanup_env

    # TP-LC-22 BASHRC env: already has current VERSION and exact export PATH → do nothing
    ci_isolated_env
    ci_isolated_bashrc
    _path_line=$(ci_bashrc_path_line)
    {
        printf '%s\n' "# dongle-already-good"
        printf '# Interactive rc created by %s installer (%s)\n' "${APP_NAME}" "${PRODUCT_VERSION}"
        printf '\n'
        printf '# Added by %s installer (%s)\n' "${APP_NAME}" "${PRODUCT_VERSION}"
        printf '%s\n' "${_path_line}"
    } > "${CI_BASHRC}"
    cp "${CI_BASHRC}" "${CI_BASHRC}.orig"
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" BASHRC="${CI_BASHRC}" sh "${SCRIPT}" install 2>&1)
    _ec=$?
    assert_eq "TP-LC-22 install exit 0" 0 "$_ec"
    if cmp -s "${CI_BASHRC}" "${CI_BASHRC}.orig"; then
        t_pass "TP-LC-22 bashrc bytes unchanged"
    else
        t_fail "TP-LC-22 bashrc bytes unchanged"
    fi
    _bashrc=$(cat "${CI_BASHRC}" 2>/dev/null || true)
    assert_contains "TP-LC-22 dongle body still there" "$_bashrc" "dongle-already-good"
    assert_contains "TP-LC-22 VERSION still present" "$_bashrc" "${PRODUCT_VERSION}"
    assert_contains "TP-LC-22 exact export PATH still present" "$_bashrc" "${_path_line}"
    _path_hits=$(grep -cF "${_path_line}" "${CI_BASHRC}" 2>/dev/null || true)
    [ -z "${_path_hits}" ] && _path_hits=0
    assert_eq "TP-LC-22 PATH export still once" "1" "${_path_hits}"
    assert_not_contains "TP-LC-22 no Created BASHRC" "$_out" "Created ${CI_BASHRC}"
    assert_not_contains "TP-LC-22 no Added PATH for bash" "$_out" "Added ${CI_USER_BIN} to PATH for bash"
    assert_file_missing "TP-LC-22 did not write HOME/.bashrc" "${CI_HOME}/.bashrc"
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" BASHRC="${CI_BASHRC}" sh "${CI_USER_BIN}/${APP_NAME}" uninstall --force >/dev/null 2>&1 || true
    ci_cleanup_env
}
