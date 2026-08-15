# =============================================================================
# tests/test_domain.sh — nginx-cli request workflow (fixture; no host user)
# =============================================================================
# Primary REQ: requirement-domain-nginx-cli
# TP family: TP-NGX-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_domain() {
    t_header "Domain request workflow (TP-NGX)"

    require_cmd sh
    require_cmd date

    # TP-NGX-01 non-root setup fails closed (no sudo hang)
    _err=$(sh "${SCRIPT}" setup 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-NGX-01 setup without root exit 1" 1 "$_ec"
    assert_contains "TP-NGX-01 setup requires root" "$_err" "root"

    # TP-NGX-02 request without privilege / fixture denied
    _err=$(sh "${SCRIPT}" request example.com 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-NGX-02 request denied exit 1" 1 "$_ec"
    assert_contains "TP-NGX-02 submit denied" "$_err" "Submit denied"

    # Isolated fixture tree
    _fx=$(mktemp -d "${TMPDIR:-/tmp}/ngx-fx.XXXXXX")
    _home="${_fx}/adm"
    _q="${_fx}/nginx-cli-queue"
    _conf="${_fx}/nginx"
    mkdir -p "${_home}" "${_conf}/sites-available" "${_conf}/sites-enabled"
    _req="${_fx}/site.conf"
    printf '%s\n' "# Intention: add HTTPS vhost for example.com" \
        "# Objective: terminate TLS and serve the site" \
        "# Update: initial add" \
        "" \
        "server { listen 80; server_name example.com; }" > "${_req}"

    _bad="${_fx}/bad.conf"
    printf '%s\n' "server { listen 80; }" > "${_bad}"

    ngx_fx() {
        NGINX_CLI_FIXTURE=1 \
        NGINX_ADM_HOME="${_home}" \
        NGINX_QUEUE_ROOT="${_q}" \
        NGINX_CONF_ROOT="${_conf}" \
        sh "${SCRIPT}" "$@"
    }

    # TP-NGX-13 missing inbound fail-closed (Type 0 must not mkdir)
    _err=$(ngx_fx request example.com "${_req}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-NGX-13 missing inbound exit 1" 1 "$_ec"
    assert_contains "TP-NGX-13 inbound missing" "$_err" "Inbound missing"

    mkdir -p "${_q}/config-request" "${_q}/config-approved" "${_q}/config-rejected"
    chmod 2770 "${_q}/config-request"
    chmod 0700 "${_q}/config-approved" "${_q}/config-rejected"

    # TP-NGX-03 request without header fails
    _err=$(ngx_fx request example.com "${_bad}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-NGX-03 bad header exit 1" 1 "$_ec"
    assert_contains "TP-NGX-03 header error" "$_err" "comments"

    # TP-NGX-04 map-set + request deposits basename
    _out=$(ngx_fx map-set testhost example.com 2>&1)
    assert_eq "TP-NGX-04 map-set exit 0" 0 "$?"
    assert_file_exists "TP-NGX-04 map file" "${_home}/user-domain-map/testhost"

    _out=$(ngx_fx request example.com "${_req}" 2>&1)
    _ec=$?
    assert_eq "TP-NGX-04 request exit 0" 0 "$_ec"
    _day=$(date +%Y%m%d)
    _base=""
    for _f in "${_q}/config-request/${_day}-"*-example.com-1; do
        [ -f "${_f}" ] || continue
        _base=$(basename -- "${_f}")
    done
    if [ -n "${_base}" ]; then
        t_pass "TP-NGX-04 inbox basename ${_base}"
    else
        t_fail "TP-NGX-04 expected inbox file ${_day}-*-example.com-1"
    fi

    # TP-NGX-05 list-requests shows pending
    _out=$(ngx_fx list-requests 2>&1)
    assert_eq "TP-NGX-05 list-requests exit 0" 0 "$?"
    assert_contains "TP-NGX-05 lists basename" "$_out" "example.com-1"

    # TP-NGX-06 second request same day increments n
    ngx_fx request example.com "${_req}" >/dev/null 2>&1
    _n2=0
    [ -f "${_q}/config-request/${_base%1}2" ] && _n2=1
    for _f in "${_q}/config-request/${_day}-"*-example.com-2; do
        [ -f "${_f}" ] && _n2=1
    done
    assert_eq "TP-NGX-06 second daily seq exists" 1 "${_n2}"

    # TP-NGX-07 approve publishes + archives
    _out=$(ngx_fx approve "${_base}" 2>&1)
    _ec=$?
    assert_eq "TP-NGX-07 approve exit 0" 0 "$_ec"
    assert_file_exists "TP-NGX-07 sites-available" "${_conf}/sites-available/example.com.conf"
    assert_file_exists "TP-NGX-07 sites-enabled link" "${_conf}/sites-enabled/example.com.conf"
    assert_file_exists "TP-NGX-07 approved archive" "${_q}/config-approved/${_base}"
    assert_file_missing "TP-NGX-07 left inbox" "${_q}/config-request/${_base}"

    # TP-NGX-08 reject moves to rejected, no extra dest
    _base2=""
    for _f in "${_q}/config-request/${_day}-"*-example.com-2; do
        [ -f "${_f}" ] || continue
        _base2=$(basename -- "${_f}")
    done
    if [ -z "${_base2}" ]; then
        t_fail "TP-NGX-08 missing second pending file"
    else
        ngx_fx reject "${_base2}" >/dev/null 2>&1
        assert_file_exists "TP-NGX-08 rejected archive" "${_q}/config-rejected/${_base2}"
        assert_file_missing "TP-NGX-08 still pending" "${_q}/config-request/${_base2}"
    fi

    # TP-NGX-09 list-approved / list-rejected
    _out=$(ngx_fx list-approved 2>&1)
    assert_contains "TP-NGX-09 list-approved" "$_out" "example.com-1"
    _out=$(ngx_fx list-rejected 2>&1)
    assert_contains "TP-NGX-09 list-rejected" "$_out" "example.com-2"

    # TP-NGX-10 login hook idempotent
    ngx_fx enable-login-approval >/dev/null 2>&1
    assert_file_exists "TP-NGX-10 bashrc" "${_home}/.bashrc"
    _out=$(ngx_fx enable-login-approval 2>&1)
    _hits=$(grep -c "interactive approval (managed)" "${_home}/.bashrc" || true)
    assert_eq "TP-NGX-10 hook inserted once (two marker lines)" 2 "${_hits}"
    assert_contains "TP-NGX-14 hook uses password sudo approve" "$(cat "${_home}/.bashrc")" "sudo "
    assert_contains "TP-NGX-14 hook calls approve" "$(cat "${_home}/.bashrc")" "approve"
    assert_not_contains "TP-NGX-14 hook not sudo -n" "$(cat "${_home}/.bashrc")" "sudo -n"

    # TP-NGX-11 approve without basename non-tty fail-closed
    _err=$(ngx_fx approve 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-NGX-11 interactive approve no-tty exit 1" 1 "$_ec"
    assert_contains "TP-NGX-11 needs TTY" "$_err" "TTY"

    # TP-NGX-12 JSON list
    _out=$(NGINX_CLI_FIXTURE=1 NGINX_ADM_HOME="${_home}" NGINX_QUEUE_ROOT="${_q}" \
        NGINX_CONF_ROOT="${_conf}" \
        sh "${SCRIPT}" --json list-approved 2>/dev/null)
    assert_contains "TP-NGX-12 json list type" "$_out" '"type":"list"'
    assert_contains "TP-NGX-12 json queue" "$_out" '"queue":"approved"'

    # TP-NGX-15 dest F6 / inbound modes in ship unit (static; no host write)
    assert_contains "TP-NGX-15 inbound chmod 2770" "$(cat "${SCRIPT}")" "chmod 2770"
    assert_not_contains "TP-NGX-15 no inbound 3773" "$(cat "${SCRIPT}")" "3773"
    assert_contains "TP-NGX-15 NOPASSWD unit nginx" "$(cat "${SCRIPT}")" "NOPASSWD: %s"
    assert_not_contains "TP-NGX-15 no NOPASSWD on nginx-cli path" "$(cat "${SCRIPT}")" "NOPASSWD: /usr/local/bin/nginx-cli"

    rm -rf "${_fx}"
}
