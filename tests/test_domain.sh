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
    # Isolate live host grants (/etc/sudoers.d/nginx-cli-submit and nginx-cli-<login>).
    _err=$(NGINX_CLI_SUBMIT_SUDOERS="/tmp/nginx-cli-no-submit-sudoers" \
        NGINX_CLI_SUBMIT_PER_USER_DIR="/tmp/nginx-cli-no-per-user" \
        sh "${SCRIPT}" request example.com 2>&1 >/dev/null)
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
    assert_contains "TP-NGX-03 header error" "$_err" "Purpose"

    # TP-NGX-04 map-set + request deposits basename
    _out=$(ngx_fx map-set testhost example.com 2>&1)
    assert_eq "TP-NGX-04 map-set exit 0" 0 "$?"
    assert_file_exists "TP-NGX-04 map file" "${_home}/user-domain-map/testhost"

    _out=$(ngx_fx request example.com "${_req}" 2>&1)
    _ec=$?
    assert_eq "TP-NGX-04 request exit 0" 0 "$_ec"
    _day=$(date +%Y%m%d)
    _base=""
    for _f in "${_q}/config-request/${_day}-"*-example.com-1.json; do
        [ -f "${_f}" ] || continue
        _base=$(basename -- "${_f}")
    done
    if [ -n "${_base}" ]; then
        t_pass "TP-NGX-04 inbox basename ${_base}"
    else
        t_fail "TP-NGX-04 expected inbox file ${_day}-*-example.com-1.json"
    fi

    # TP-NGX-05 list-requests shows pending
    _out=$(ngx_fx list-requests 2>&1)
    assert_eq "TP-NGX-05 list-requests exit 0" 0 "$?"
    assert_contains "TP-NGX-05 lists basename" "$_out" "example.com-1"

    # TP-NGX-06 second request same day increments n
    ngx_fx request example.com "${_req}" >/dev/null 2>&1
    _n2=0
    [ -f "${_q}/config-request/${_base%1.json}2.json" ] && _n2=1
    for _f in "${_q}/config-request/${_day}-"*-example.com-2.json; do
        [ -f "${_f}" ] && _n2=1
    done
    assert_eq "TP-NGX-06 second daily seq exists" 1 "${_n2}"

    # TP-NGX-07 approve publishes + archives
    _out=$(ngx_fx approve "${_base}" 2>&1)
    _ec=$?
    assert_eq "TP-NGX-07 approve exit 0" 0 "$_ec"
    assert_file_exists "TP-NGX-07 sites-available" "${_conf}/sites-available/example.com.conf"
    assert_contains "TP-NGX-07 published text dual" "$(cat "${_conf}/sites-available/example.com.conf")" "server {"
    assert_not_contains "TP-NGX-07 published not raw JSON" "$(cat "${_conf}/sites-available/example.com.conf")" "schema_version"
    assert_file_exists "TP-NGX-07 sites-enabled link" "${_conf}/sites-enabled/example.com.conf"
    assert_file_exists "TP-NGX-07 approved archive" "${_q}/config-approved/${_base}"
    assert_file_missing "TP-NGX-07 left inbox" "${_q}/config-request/${_base}"

    # TP-NGX-08 reject moves to rejected, no extra dest
    _base2=""
    for _f in "${_q}/config-request/${_day}-"*-example.com-2.json; do
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
    assert_contains "TP-NGX-14 hook calls approve" "$(cat "${_home}/.bashrc")" "approve"
    assert_contains "TP-NGX-14 hook is as-login hook symlink" "$(cat "${_home}/.bashrc")" "/usr/local/bin/nginx-cli-hook approve"
    assert_not_contains "TP-NGX-14 hook not product binary without -hook" "$(cat "${_home}/.bashrc")" "/usr/local/bin/nginx-cli approve"
    assert_not_contains "TP-NGX-14 hook not sudo" "$(cat "${_home}/.bashrc")" "sudo"
    assert_file_exists "TP-HOOK-02 profile created" "${_home}/.profile"
    assert_contains "TP-HOOK-02 profile sources bashrc" "$(cat "${_home}/.profile")" '.bashrc'

    # TP-NGX-50 replace a stale sudo-shaped managed block
    {
        printf '%s\n' "# >>> nginx-cli interactive approval (managed) >>>"
        printf 'if [ -n "${PS1-}" ]; then\n'
        printf '    sudo /usr/local/bin/nginx-cli approve\n'
        printf 'fi\n'
        printf '%s\n' "# <<< nginx-cli interactive approval (managed) <<<"
    } > "${_home}/.bashrc"
    _out=$(ngx_fx enable-login-approval 2>&1)
    _hits=$(grep -c "interactive approval (managed)" "${_home}/.bashrc" || true)
    assert_eq "TP-NGX-50 still one managed pair" 2 "${_hits}"
    assert_contains "TP-NGX-50 reports replaced" "${_out}" "Replaced"
    assert_contains "TP-NGX-50 hook calls approve via -hook" "$(cat "${_home}/.bashrc")" "/usr/local/bin/nginx-cli-hook approve"
    assert_not_contains "TP-NGX-50 hook not sudo" "$(cat "${_home}/.bashrc")" "sudo"
    assert_not_contains "TP-NGX-50 old product-binary line gone" "$(cat "${_home}/.bashrc")" "/usr/local/bin/nginx-cli approve"
    _out=$(ngx_fx enable-login-approval 2>&1)
    assert_contains "TP-NGX-50 second run already present" "${_out}" "already present"

    printf '%s\n' "# keep-me-profile" > "${_home}/.profile"
    ngx_fx enable-login-approval >/dev/null 2>&1
    assert_contains "TP-HOOK-03 existing profile kept" "$(cat "${_home}/.profile")" "keep-me-profile"
    assert_not_contains "TP-HOOK-03 existing profile not rewritten" "$(cat "${_home}/.profile")" "BEGIN nginx-cli profile"

    {
        printf '%s\n' "# >>> nginx-cli interactive approval (managed) >>>"
        printf 'if [ -n "${PS1-}" ]; then\n'
        printf '    /usr/local/bin/nginx-cli approve\n'
        printf 'fi\n'
        printf '%s\n' "# <<< nginx-cli interactive approval (managed) <<<"
    } > "${_home}/.bashrc"
    _out=$(ngx_fx enable-login-approval 2>&1)
    assert_contains "TP-HOOK-08 reports replaced" "${_out}" "Replaced"
    assert_contains "TP-HOOK-08 new hook path" "$(cat "${_home}/.bashrc")" "/usr/local/bin/nginx-cli-hook approve"
    assert_not_contains "TP-HOOK-08 old binary path gone" "$(cat "${_home}/.bashrc")" "/usr/local/bin/nginx-cli approve"
    _setup_fn=$(sed -n '/^ngx_setup() {/,/^}/p' "${SCRIPT}")
    assert_contains "TP-HOOK-08 setup copies global binary" "${_setup_fn}" "inst_local_install"
    assert_contains "TP-HOOK-08 setup ensures hook symlink" "${_setup_fn}" "ngx_ensure_login_hook_symlink"

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
    assert_contains "TP-NGX-15 F6 --json approve" "$(cat "${SCRIPT}")" '--json %s\n'
    assert_contains "TP-NGX-15 F6 --json argv helper" "$(cat "${SCRIPT}")" "ngx_f6_cli_argv"
    assert_contains "TP-NGX-15 F6 --json list-requests argv" "$(cat "${SCRIPT}")" '"list-requests"'
    assert_not_contains "TP-NGX-15 F6 no --json setup" "$(cat "${SCRIPT}")" '--json setup'
    assert_not_contains "TP-NGX-15 F6 no --json star-all argv" "$(cat "${SCRIPT}")" 'ngx_f6_cli_argv "${NGINX_ADM_USER}" "${_cli}" "--json *"'
    assert_contains "TP-NGX-53 Family 2 dest is /etc/nginx-adm/sudoers" "$(cat "${SCRIPT}")" 'NGINX_ADM_SUDOERS:=/etc/nginx-adm/sudoers'
    assert_not_contains "TP-NGX-53 default dest not sudoers.d/nginx-adm" "$(cat "${SCRIPT}")" 'NGINX_ADM_SUDOERS:=/etc/sudoers.d/nginx-adm'
    assert_contains "TP-NGX-53 refuse sudoers.d Family 2 dest" "$(cat "${SCRIPT}")" 'Family 2 dest must not be under /etc/sudoers.d'
    _setup_fn=$(sed -n '/^ngx_setup() {/,/^}/p' "${SCRIPT}")
    _coll=$(sed -n '/^ngx_adm_collision_check() {/,/^}/p' "${SCRIPT}")
    _pent=$(sed -n '/^ngx_passwd_ent() {/,/^}/p' "${SCRIPT}")
    _gent=$(sed -n '/^ngx_group_ent() {/,/^}/p' "${SCRIPT}")
    assert_contains "TP-NGX-51 collision probes passwd UID" "${_coll}" 'ngx_passwd_ent "${NGINX_ADM_UID}"'
    assert_contains "TP-NGX-51 collision probes passwd name" "${_coll}" 'ngx_passwd_ent "${NGINX_ADM_USER}"'
    assert_contains "TP-NGX-51 collision probes group GID" "${_coll}" 'ngx_group_ent "${NGINX_ADM_GID}"'
    assert_contains "TP-NGX-51 passwd_ent uses getent passwd" "${_pent}" 'getent passwd "${_key}"'
    assert_contains "TP-NGX-51 group_ent uses getent group" "${_gent}" 'getent group "${_key}"'
    assert_contains "TP-NGX-51 refuse rewrite live identity" "${_coll}" "Will not rewrite a live identity"
    assert_contains "TP-NGX-51 collision Next getent passwd UID" "${_coll}" 'Next: getent passwd ${NGINX_ADM_UID}'
    _create=$(sed -n '/^ngx_create_adm_user() {/,/^}/p' "${SCRIPT}")
    assert_contains "TP-NGX-51 create calls collision check" "${_create}" "ngx_adm_collision_check"
    assert_contains "TP-NGX-51 useradd tries /usr/sbin" "$(sed -n '/^ngx_find_host_bin() {/,/^}/p' "${SCRIPT}")" "/usr/sbin/"
    _reqfn=$(sed -n '/^ngx_require_root() {/,/^}/p' "${SCRIPT}")
    assert_contains "TP-NGX-51 require_root consumes TTY" "${_reqfn}" 'TTY'
    assert_not_contains "TP-NGX-51 require_root no live [ -t 0 ]" "${_reqfn}" '[ ! -t 0 ]'

    assert_contains "TP-NGX-52 setup auto-queues Family 1 JSON" "${_setup_fn}" "ngx_submit_login_hook_sudoer_request"
    assert_not_contains "TP-NGX-53 setup does not write submit sudoers.d template" "${_setup_fn}" "ngx_write_submit_sudoers_template"
    assert_not_contains "TP-NGX-53 no submit sudoers.d writer in ship unit" "$(cat "${SCRIPT}")" "ngx_write_submit_sudoers_template"
    assert_contains "TP-NGX-52 login-hook-elev kind in ship unit" "$(cat "${SCRIPT}")" '"kind":"login-hook-elev"'
    assert_contains "TP-NGX-52 skip when sibling missing" "$(cat "${SCRIPT}")" 'Family 1 sudoer JSON skipped'

    # TP-NGX-34 Family 1 needs a real nginx-adm password (no chpasswd / no scripted secret)
    assert_contains "TP-NGX-34 setup calls passwd-ensure" "$(cat "${SCRIPT}")" "ngx_ensure_adm_password"
    assert_contains "TP-NGX-34 setup invokes passwd LPU" "$(cat "${SCRIPT}")" 'passwd "${NGINX_ADM_USER}"'
    assert_contains "TP-NGX-34 help names passwd nginx-adm" "$(sh "${SCRIPT}" help 2>&1)" "passwd nginx-adm"
    assert_not_contains "TP-NGX-34 no chpasswd" "$(cat "${SCRIPT}")" "chpasswd"
    assert_not_contains "TP-NGX-34 no passwd --stdin" "$(cat "${SCRIPT}")" "passwd --stdin"

    # TP-NGX-16 submit fail-closed when sudoer-cli missing
    _err=$(HOME="${_fx}/home16" SUDOER_CLI="${_fx}/no-such-sudoer-cli" \
        sh "${SCRIPT}" submit-sudoer-request --allow-test-local 2>&1 >/dev/null)
    _ec16=$?
    assert_eq "TP-NGX-16 submit missing cli exit 1" 1 "${_ec16}"
    assert_contains "TP-NGX-16 missing sudoer-cli" "${_err}" "sudoer-cli not found"

    # TP-NGX-17 / 20 submit via stub sudoer-cli into writable inbound
    _stub_dir="${_fx}/stub-sudoer"
    mkdir -p "${_stub_dir}/bin" "${_stub_dir}/sudoer-request" "${_fx}/home17"
    cat > "${_stub_dir}/bin/sudoer-cli" <<'STUB'
#!/bin/sh
_file=""
_svc=""
while [ $# -gt 0 ]; do
    case "$1" in
        --json) ;;
        --file) _file="$2"; shift ;;
        --purpose) shift ;;
        --service) _svc="$2"; shift ;;
        add-sudoer-request|update-sudoer-request) ;;
        *) ;;
    esac
    shift
done
[ -n "${_file}" ] && [ -f "${_file}" ] || exit 1
_id="sudoer-20260815-${_svc:-nginx-cli}-stub-add-1.json"
_in="${SUDOER_QUEUE_INBOUND:-}"
[ -d "${_in}" ] || _in="${LPU_HOME:-}/sudoer-request"
[ -d "${_in}" ] || exit 1
cp "${_file}" "${_in}/${_id}" || exit 1
printf 'request_id=%s\n' "${_id}"
exit 0
STUB
    chmod 0755 "${_stub_dir}/bin/sudoer-cli"
    _out=$(HOME="${_fx}/home17" \
        SUDOER_CLI="${_stub_dir}/bin/sudoer-cli" \
        SUDOER_ADM_USER="$(id -un)" \
        SUDOER_QUEUE_INBOUND="${_stub_dir}/sudoer-request" \
        sh "${SCRIPT}" submit-sudoer-request --allow-test-local 2>&1)
    _ec17=$?
    assert_eq "TP-NGX-17 submit stub exit 0" 0 "${_ec17}"
    assert_contains "TP-NGX-17 request_id" "${_out}" "request_id="
    _njson=$(find "${_stub_dir}/sudoer-request" -type f | wc -l | tr -d ' ')
    assert_eq "TP-NGX-17 inbound has file" 1 "${_njson}"
    _grant=$(cat "${_stub_dir}/sudoer-request"/sudoer-*.json 2>/dev/null || true)
    assert_contains "TP-NGX-20 grant path is global nginx-cli" "${_grant}" '"/usr/local/bin/nginx-cli"'
    assert_contains "TP-NGX-20 grant args request" "${_grant}" '"request"'
    assert_contains "TP-NGX-20 grant service nginx-cli" "${_grant}" '"service": "nginx-cli"'
    assert_contains "TP-NGX-20 type-2-switch kind" "${_grant}" '"kind": "type-2-switch"'
    assert_not_contains "TP-NGX-20 no mkdir path" "${_grant}" "/usr/bin/mkdir"
    assert_not_contains "TP-NGX-20 no approve verb" "${_grant}" '"approve"'

    # TP-NGX-18 refuse OS-tool and dest-forbidden grant files
    mkdir -p "${_fx}/home18"
    _badgrant="${_fx}/home18/bad-os-tool.json"
    printf '%s\n' '{"commands":[{"path":"/usr/bin/mkdir","args":["-p","/var/nginx-cli"]}]}' >"${_badgrant}"
    _err=$(HOME="${_fx}/home18" sh "${SCRIPT}" submit-sudoer-request --allow-test-local "${_badgrant}" 2>&1 >/dev/null)
    _ec18=$?
    assert_eq "TP-NGX-18 refuse OS-tool grant exit 1" 1 "${_ec18}"
    assert_contains "TP-NGX-18 refuse OS-tool message" "${_err}" "path must be"
    _badappr="${_fx}/home18/bad-approve.json"
    printf '%s\n' '{"commands":[{"path":"/usr/local/bin/nginx-cli","args":["approve"]}]}' >"${_badappr}"
    _err=$(HOME="${_fx}/home18" sh "${SCRIPT}" submit-sudoer-request --allow-test-local "${_badappr}" 2>&1 >/dev/null)
    assert_eq "TP-NGX-18 refuse approve grant exit 1" 1 "$?"
    assert_contains "TP-NGX-18 refuse approve message" "${_err}" "args must be"
    _badhook="${_fx}/home18/bad-hook.json"
    printf '%s\n' '{"kind":"login-hook-elev","commands":[{"path":"/usr/local/bin/nginx-cli","args":["approve"]}]}' >"${_badhook}"
    _err=$(HOME="${_fx}/home18" sh "${SCRIPT}" submit-sudoer-request --allow-test-local "${_badhook}" 2>&1 >/dev/null)
    assert_eq "TP-NGX-52 Type 0 refuses login-hook-elev exit 1" 1 "$?"
    assert_contains "TP-NGX-52 Type 0 refuses login-hook-elev message" "${_err}" "login-hook-elev"

    # TP-NGX-19 about prefers public inbound; Type 0 must not mkdir
    _pub19="${_fx}/var-sudoer-cli"
    mkdir -p "${_pub19}/sudoer-request" "${_fx}/home19/sudoer-approving"
    _j19=$(HOME="${_fx}/home19" \
        SUDOER_PUBLIC_ROOT="${_pub19}" \
        SUDOER_ADM_USER="$(id -un)" \
        SUDOER_QUEUE_INBOUND="" \
        sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-NGX-19 about prefers public inbound" "${_j19}" "${_pub19}/sudoer-request"
    assert_not_contains "TP-NGX-19 not leftover approving" "${_j19}" "${_fx}/home19/sudoer-approving"
    _missing19="${_fx}/var-sudoer-cli-absent"
    _j19b=$(HOME="${_fx}/home19" \
        SUDOER_PUBLIC_ROOT="${_missing19}" \
        SUDOER_ADM_USER="no-such-sudoer-adm-ngx19" \
        SUDOER_QUEUE_INBOUND="" \
        sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-NGX-19 missing public is not_found" "${_j19b}" '"sudoer_inbound":"not_found"'
    assert_file_missing "TP-NGX-19 no Type 0 mkdir public inbound" "${_missing19}/sudoer-request"
    assert_file_missing "TP-NGX-19 no Type 0 mkdir public parent" "${_missing19}"

    # TP-NGX-21 conf-to-json of dest add sample
    _cadd="${_fx}/add.conf"
    printf '%s\n' "# Intention: add HTTPS vhost for example.com" \
        "# Objective: terminate TLS and serve the site" \
        "# Update: initial add" \
        "" \
        "server {" \
        "    listen 80;" \
        "    server_name example.com;" \
        "    return 301 https://\$host\$request_uri;" \
        "}" >"${_cadd}"
    _out=$(sh "${SCRIPT}" conf-to-json --file "${_cadd}" 2>&1)
    _ec21=$?
    assert_eq "TP-NGX-21 conf-to-json exit 0" 0 "${_ec21}"
    assert_contains "TP-NGX-21 kind redirect" "${_out}" '"kind": "redirect"'
    assert_contains "TP-NGX-21 domain example.com" "${_out}" '"domain": "example.com"'
    assert_contains "TP-NGX-21 listen 80" "${_out}" '"80"'
    assert_contains "TP-NGX-21 return 301" "${_out}" '"code": 301'

    # TP-NGX-22 json-to-conf of dest add JSON
    _jadd="${_fx}/add.json"
    printf '%s\n' '{' \
        '  "schema_version": 1,' \
        '  "purpose": "Add HTTPS vhost redirect for example.com",' \
        '  "username": "alice",' \
        '  "service": "nginx-cli",' \
        '  "action": "add",' \
        '  "kind": "redirect",' \
        '  "domain": "example.com",' \
        '  "submit_app": "nginx-cli",' \
        '  "submit_version": "1.5.0",' \
        '  "site": {' \
        '    "listen": ["80"],' \
        '    "server_name": ["example.com"],' \
        '    "return": { "code": 301, "url": "https://$host$request_uri" }' \
        '  }' \
        '}' >"${_jadd}"
    _out=$(sh "${SCRIPT}" json-to-conf --file "${_jadd}" 2>&1)
    assert_eq "TP-NGX-22 json-to-conf exit 0" 0 "$?"
    assert_contains "TP-NGX-22 listen 80" "${_out}" "listen 80;"
    assert_contains "TP-NGX-22 server_name" "${_out}" "server_name example.com;"
    assert_contains "TP-NGX-22 return 301" "${_out}" "return 301"

    # TP-NGX-23 xor / refuse include / refuse dest --out
    _err=$(sh "${SCRIPT}" conf-to-json --file "${_fx}/no-such-file.conf" 2>&1 >/dev/null)
    assert_eq "TP-NGX-23 missing file exit 1" 1 "$?"
    _badinc="${_fx}/inc.conf"
    printf '%s\n' "# Purpose: x" "server {" "    include /tmp/x;" "}" >"${_badinc}"
    _err=$(sh "${SCRIPT}" conf-to-json --file "${_badinc}" 2>&1 >/dev/null)
    assert_eq "TP-NGX-23 include refuse exit 1" 1 "$?"
    assert_contains "TP-NGX-23 include message" "${_err}" "include"
    _err=$(sh "${SCRIPT}" json-to-conf --file "${_jadd}" --out /etc/nginx/sites-available/x.conf 2>&1 >/dev/null)
    assert_eq "TP-NGX-23 dest --out exit 1" 1 "$?"
    assert_contains "TP-NGX-23 dest --out message" "${_err}" "refuses"
    _err=$(sh "${SCRIPT}" json-to-conf --file "${_jadd}" --out /etc/sudoers.d/x 2>&1 >/dev/null)
    assert_eq "TP-NGX-23 --out /etc/sudoers.d exit 1" 1 "$?"
    _err=$(NGINX_CLI_FIXTURE=1 NGINX_ADM_HOME="${_home}" NGINX_QUEUE_ROOT="${_q}" \
        NGINX_CONF_ROOT="${_conf}" \
        sh "${SCRIPT}" json-to-conf --file "${_jadd}" --out "${_q}/config-request/caller.json" 2>&1 >/dev/null)
    assert_eq "TP-NGX-23 --out inbound exit 1" 1 "$?"
    assert_file_missing "TP-NGX-23 inbound not written by convert" "${_q}/config-request/caller.json"

    # TP-NGX-24 remove JSON → purpose comments only
    _jrm="${_fx}/rm.json"
    printf '%s\n' '{ "purpose": "Revoke my example.com site conf." }' >"${_jrm}"
    _out=$(sh "${SCRIPT}" json-to-conf --file "${_jrm}" 2>&1)
    assert_eq "TP-NGX-24 remove exit 0" 0 "$?"
    assert_contains "TP-NGX-24 purpose comment" "${_out}" "# Purpose:"
    assert_not_contains "TP-NGX-24 no server block" "${_out}" "server {"

    # TP-NGX-25 dest JSON request + inbound body + --json single object
    _me=$(id -un)
    _jme="${_fx}/me.json"
    sed "s/alice/${_me}/g" "${_jadd}" > "${_jme}"
    _err=$(ngx_fx request other.example "${_jme}" 2>&1 >/dev/null)
    assert_eq "TP-NGX-27 domain mismatch exit 1" 1 "$?"
    assert_contains "TP-NGX-27 domain mismatch" "${_err}" "JSON"
    _err=$(ngx_fx request example.com "${_jadd}" 2>&1 >/dev/null)
    assert_eq "TP-NGX-27 username mismatch exit 1" 1 "$?"
    _out=$(ngx_fx --json request example.com "${_jme}" 2>/dev/null)
    assert_eq "TP-NGX-25 json request exit 0" 0 "$?"
    _ntype=$(printf '%s\n' "${_out}" | grep -c '"type":' || true)
    assert_eq "TP-NGX-29 --json request one object" 1 "${_ntype}"
    _jbase=""
    for _f in "${_q}/config-request/${_day}-"*-example.com-*.json; do
        [ -f "${_f}" ] || continue
        _jbase=$(basename -- "${_f}")
    done
    if [ -n "${_jbase}" ]; then
        t_pass "TP-NGX-25 JSON inbound ${_jbase}"
        assert_contains "TP-NGX-26 inbound is dest JSON" "$(cat "${_q}/config-request/${_jbase}")" '"schema_version": 1'
        assert_contains "TP-NGX-26 inbound kind" "$(cat "${_q}/config-request/${_jbase}")" '"kind": "redirect"'
        ngx_fx approve "${_jbase%.json}" >/dev/null 2>&1
        assert_file_exists "TP-NGX-25 approve alias archived" "${_q}/config-approved/${_jbase}"
        assert_file_missing "TP-NGX-25 alias left inbox" "${_q}/config-request/${_jbase}"
        assert_contains "TP-NGX-28 published server block" "$(cat "${_conf}/sites-available/example.com.conf")" "server {"
        assert_not_contains "TP-NGX-28 published not JSON" "$(cat "${_conf}/sites-available/example.com.conf")" "schema_version"
    else
        t_fail "TP-NGX-25 expected JSON inbound file"
    fi

    _inj="${_fx}/inject.json"
    sed "s|https://\$host\$request_uri|; include /tmp/evil;|" "${_jme}" > "${_inj}"
    _err=$(ngx_fx request example.com "${_inj}" 2>&1 >/dev/null)
    assert_eq "TP-NGX-33 include inject exit 1" 1 "$?"

    _badpy="${_fx}/home18/bad-python.json"
    printf '%s\n' '{"commands":[{"path":"/usr/bin/python3","args":["request"]}]}' >"${_badpy}"
    _err=$(HOME="${_fx}/home18" sh "${SCRIPT}" submit-sudoer-request --allow-test-local "${_badpy}" 2>&1 >/dev/null)
    assert_eq "TP-NGX-32 non-listed binary exit 1" 1 "$?"
    assert_contains "TP-NGX-32 path must be nginx-cli" "${_err}" "path must be"

    _pass="${TESTS_ROOT}/fixtures/fence-test/pass"
    _match="${TESTS_ROOT}/fixtures/fence-test/match"

    _out=$(sh "${SCRIPT}" fence-test --file "${_pass}/20260821-alice-example.com-1.json" 2>&1)
    assert_eq "TP-NGX-35 fence-test pass exit 0" 0 "$?"
    assert_contains "TP-NGX-35 no dest fence" "${_out}" "No dest fence matched"

    _out=$(sh "${SCRIPT}" test-json-format --file "${_pass}/20260821-alice-example.com-1.json" 2>&1)
    assert_eq "TP-NGX-36 test-json-format sibling stamp exit 0" 0 "$?"
    assert_contains "TP-NGX-36 dest-legal" "${_out}" "dest-legal"

    _err=$(sh "${SCRIPT}" fence-test --file "${_match}/missing-purpose.json" 2>&1 >/dev/null)
    assert_eq "TP-NGX-37 missing purpose exit 1" 1 "$?"
    assert_contains "TP-NGX-37 purpose message" "${_err}" "purpose"

    _err=$(sh "${SCRIPT}" fence-test --file "${_match}/unknown-key.json" 2>&1 >/dev/null)
    assert_eq "TP-NGX-38 unknown key exit 1" 1 "$?"
    assert_contains "TP-NGX-38 unknown key message" "${_err}" "does not list"

    _err=$(sh "${SCRIPT}" fence-test --dir "${_match}" 2>&1 >/dev/null)
    assert_eq "TP-NGX-39 dir match fail-closed" 1 "$?"

    _out=$(sh "${SCRIPT}" fence-test --dir "${_match}" --expect-match 2>&1)
    assert_eq "TP-NGX-40 expect-match exit 0" 0 "$?"
    assert_contains "TP-NGX-40 all matched" "${_out}" "all matched"

    _out=$(sh "${SCRIPT}" fence-test --dir "${_pass}" 2>&1)
    assert_eq "TP-NGX-41 pass dir exit 0" 0 "$?"

    _nostamp="${_fx}/nostamp.json"
    printf '%s\n' '{' \
        '  "schema_version": 1,' \
        '  "purpose": "Add HTTPS vhost redirect for example.com",' \
        '  "username": "alice",' \
        '  "service": "nginx-cli",' \
        '  "action": "add",' \
        '  "kind": "redirect",' \
        '  "domain": "example.com",' \
        '  "site": { "listen": ["80"], "server_name": ["example.com"] }' \
        '}' >"${_nostamp}"
    _err=$(sh "${SCRIPT}" test-json-format --file "${_nostamp}" 2>&1 >/dev/null)
    assert_eq "TP-NGX-42 missing stamp tester exit 1" 1 "$?"
    assert_contains "TP-NGX-42 stamp message" "${_err}" "submit_app"

    _out=$(ngx_fx request example.com "${_jme}" 2>&1)
    assert_eq "TP-NGX-43 request stamps exit 0" 0 "$?"
    _stamped=""
    for _f in "${_q}/config-request/${_day}-"*-example.com-*.json; do
        [ -f "${_f}" ] || continue
        _stamped=$(cat "${_f}")
    done
    assert_contains "TP-NGX-43 inbound submit_app" "${_stamped}" '"submit_app"'
    assert_contains "TP-NGX-43 inbound submit_version" "${_stamped}" '"submit_version"'

    _err=$(sh "${SCRIPT}" fence-test --file "${_pass}/20260821-alice-example.com-1.json" --dir "${_pass}" 2>&1 >/dev/null)
    assert_eq "TP-NGX-44 xor file+dir exit 1" 1 "$?"
    assert_contains "TP-NGX-44 xor message" "${_err}" "not both"
    assert_contains "TP-NGX-44 Next running ship" "${_err}" "${SCRIPT}"
    assert_not_contains "TP-NGX-44 Next not GLOBAL_BIN" "${_err}" "/usr/local/bin/nginx-cli"

    _err=$(sh "${SCRIPT}" fence-test --expect-match --file "${_pass}/20260821-alice-example.com-1.json" 2>&1 >/dev/null)
    assert_eq "TP-NGX-45 expect-match needs dir exit 1" 1 "$?"
    assert_contains "TP-NGX-45 expect-match message" "${_err}" "--expect-match"

    _out=$(sh "${SCRIPT}" --json fence-test --file "${_pass}/20260821-alice-example.com-1.json" 2>/dev/null)
    assert_eq "TP-NGX-46 json fence-test exit 0" 0 "$?"
    assert_contains "TP-NGX-46 command field" "${_out}" '"command":"fence-test"'

    _before=$(find "${_q}/config-request" -type f 2>/dev/null | wc -l | tr -d ' ')
    sh "${SCRIPT}" fence-test --file "${_pass}/20260821-alice-example.com-1.json" >/dev/null 2>&1
    sh "${SCRIPT}" test-json-format --file "${_pass}/20260821-alice-example.com-1.json" >/dev/null 2>&1
    _after=$(find "${_q}/config-request" -type f 2>/dev/null | wc -l | tr -d ' ')
    assert_eq "TP-NGX-47 testers do not queue" "${_before}" "${_after}"

    _err=$(sh "${SCRIPT}" test-json-format --dir "${_pass}" 2>&1 >/dev/null)
    assert_eq "TP-NGX-48 test-json-format --dir exit 1" 1 "$?"
    assert_contains "TP-NGX-48 not --dir" "${_err}" "not --dir"
    _out=$(sh "${SCRIPT}" test-json-format "${_pass}/20260821-alice-example.com-1.json" 2>&1)
    assert_eq "TP-NGX-48 positional file exit 0" 0 "$?"

    _out=$(sh "${SCRIPT}" fence-test < "${_pass}/20260821-alice-example.com-1.json" 2>&1)
    assert_eq "TP-NGX-49 stdin fence-test exit 0" 0 "$?"
    assert_contains "TP-NGX-49 stdin no dest fence" "${_out}" "No dest fence matched"

    rm -rf "${_fx}"
}
