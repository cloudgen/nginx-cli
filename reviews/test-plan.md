# Test plan — nginx-cli

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit:** `src/nginx-cli`  
**Product VERSION:** 1.10.0  
**Last plan update:** 2026-09-09  
**Last suite run:** PASS=379 FAIL=0 SKIP=0 (2026-09-09)

Status: **have** = automated today · **todo** = needed · **optional** · **n/a** · **skip** (environment)

---

## Baseline coverage

| Area | Status | Evidence |
|------|--------|----------|
| Syntax `sh -n` | have | TP-CLI-01 |
| version / help / about human + JSON | have | TP-CLI-02..06 |
| Type N off-TTY empty argv = help; TTY empty argv = numbered list | have | TP-CLI-07, TP-CLI-25 |
| `menu`/`main` off-TTY help; TTY numbered list; default style; no `$()` of `prompt_ask` | have | TP-CLI-17..24 |
| Unknown + quiet + set -u HOME | have | TP-CLI-08..11 |
| Storage isolation | have | TP-CLI-12 |
| No online verbs / no SCRIPT_URL UX | have | TP-CLI-04, TP-CLI-10 |
| Trimmed parent archive/print-sudoers verbs fail closed | have | TP-CLI-13 |
| Local install / idempotent / uninstall / mode 0755 | have | TP-LC-01..10 |
| User-bin PATH / this-login `.profile` / `BASHRC` fixture | have | TP-LC-11..14 · TP-LC-20..22 |
| Request workflow (fixture) | have | TP-NGX-01..13 |
| Dest F6 / inbound / no nginx-ctl | have | TP-CLI-14, TP-NGX-14..15 |
| submit-sudoer-request compose | have | TP-NGX-16..20 · TP-CLI-04/06 |
| Type 1 approve no-TTY fail-closed | have | TP-NGX-11 |
| Login hook as-login (not `sudo`, not `-n`); labeled `-hook` symlink; setup replaces old hook | have | TP-NGX-14, TP-NGX-50, TP-HOOK-08, TP-HOOK-09 |
| Live `setup` useradd on host | skip | Requires root; negative non-root covered |
| Live F6 visudo install | skip | Requires root; static writer covered by TP-NGX-15 |
| Online curl / companion checksum | n/a | Local-only product |

---

## TP rows

### TP-CLI (CLI surface)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CLI-01 | `sh -n` ship unit | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-CLI-02 | version human | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-03 | version JSON | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-04 | help Type 0 + domain verbs + submit-sudoer-request; no online/archive verbs | test_cli | requirement-shell-cli-interface · domain | **have** |
| TP-CLI-05 | help JSON short | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-06 | about JSON storage + nginx-adm + sudoer-cli fields | test_cli | requirement-shell-cli-storage · domain | **have** |
| TP-CLI-07 | off-TTY empty argv Type N help (not install; not the list) | test_cli | requirement-shell-cli-zero-arguments | **have** |
| TP-CLI-08 | unknown fail-closed | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-09 | quiet suppresses version | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-10 | online verbs rejected | test_cli | requirement-bootstrap-chain | **have** |
| TP-CLI-11 | env -u HOME version | test_cli | class / defensive | **have** |
| TP-CLI-12 | storage isolation | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-13 | backup/restore/print-sudoers unknown | test_cli | requirement-bootstrap-chain · three-layer | **have** |
| TP-CLI-14 | `nginx-ctl` unknown; help does not list it | test_cli | prevention · three-layer · interface | **have** |
| TP-CLI-15 | Help lists `fence-test` / `test-json-format` under Unit test heading | test_cli | interface · dest Fence | **have** |
| TP-CLI-16 | Help documents `--dir` / `--expect-match` tester flags | test_cli | interface · dest Fence | **have** |
| TP-CLI-17 | `menu` off-TTY human help; not numbered list; off-TTY empty argv still help | test_cli | default-interaction · zero-arguments | **have** |
| TP-CLI-18 | `menu --json` off-TTY JSON help | test_cli | default-interaction | **have** |
| TP-CLI-19 | `main` off-TTY human help | test_cli | default-interaction | **have** |
| TP-CLI-20 | Help lists `menu` / `main` | test_cli | interface · default-interaction | **have** |
| TP-CLI-21 | TTY `menu` numbered list N=14 Exit 99; exclusions | test_cli | default-interaction | **have** (skip if no PTY) |
| TP-CLI-22 | TTY `menu --json` still the list | test_cli | default-interaction | **have** (skip if no PTY) |
| TP-CLI-23 | Menu choice reads `PROMPT_ASK_VALUE` (no `$()` of `prompt_ask`) | test_cli | default-interaction | **have** |
| TP-CLI-24 | TTY menu header has VERSION; gray-italic explain | test_cli | default-interaction | **have** (skip if no PTY) |
| TP-CLI-25 | TTY empty argv numbered list (not Usage help) | test_cli | zero-arguments · default-interaction | **have** (skip if no PTY) |

### TP-LC (local lifecycle)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-LC-01..10 | install / uninstall / where-is-me / mode 0755 | test_local_lifecycle | requirement-shell-local-self-management | **have** |
| TP-LC-11 | install creates `~/.bashrc` with USER_BIN PATH | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-12 | install creates `~/.profile` sourcing bashrc | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-13 | reinstall does not duplicate PATH | test_local_lifecycle | requirement-shell-path-and-shell-support · requirement-shell-idempotency | **have** |
| TP-LC-14 | existing `~/.profile` body kept | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-20 | `BASHRC` env: create rc in a random temp folder when missing | test_local_lifecycle | requirement-shell-path-and-shell-support · requirement-shell-idempotency | **have** |
| TP-LC-21 | `BASHRC` env: modify a dongle `.bashrc` in that temp folder | test_local_lifecycle | requirement-shell-path-and-shell-support | **have** |
| TP-LC-22 | `BASHRC` env: already-correct VERSION + exact `export PATH=` is a no-op | test_local_lifecycle | requirement-shell-path-and-shell-support · requirement-shell-idempotency | **have** |

### TP-NGX (domain request workflow)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-NGX-01 | non-root setup fail-closed (no sudo hang) | test_domain | domain · three-layer · prevention | **have** |
| TP-NGX-02 | request denied without privilege | test_domain | domain submit gate | **have** |
| TP-NGX-03 | request text dual needs purpose (convert fail-closed) | test_domain | domain | **have** |
| TP-NGX-04 | fixture submit basename | test_domain | domain | **have** |
| TP-NGX-05 | list-requests | test_domain | domain | **have** |
| TP-NGX-06 | daily sequence increment | test_domain | basename law | **have** |
| TP-NGX-07 | approve publish + archive | test_domain | domain | **have** |
| TP-NGX-08 | reject archive only | test_domain | domain | **have** |
| TP-NGX-09 | list-approved / list-rejected | test_domain | domain | **have** |
| TP-NGX-10 | login hook idempotent | test_domain | login-hook · LPU | **have** |
| TP-NGX-11 | interactive approve no-TTY fail-closed | test_domain | interactive · prevention | **have** |
| TP-NGX-12 | JSON list-approved | test_domain | output + domain | **have** |
| TP-NGX-13 | missing inbound fail-closed | test_domain | public queue Type 0 no-mkdir · prevention | **have** |
| TP-NGX-14 | hook is as-login `/usr/local/bin/nginx-cli-hook approve`, not product-binary, not `sudo` / `sudo -n` | test_domain | login-hook · three-layer · prevention | **have** |
| TP-NGX-15 | ship unit inbound `2770` not `3773`; F6 has unit NOPASSWD; no NOPASSWD on `/usr/local/bin/nginx-cli`; Family 1 leading `--json`; no `--json setup` | test_domain | LPU · three-layer · prevention | **have** |
| TP-NGX-16 | submit-sudoer-request fail-closed when sudoer-cli missing | test_domain | three-layer §2.5.3 | **have** |
| TP-NGX-17 | submit via stub sudoer-cli into writable inbound | test_domain | three-layer §2.5.3 | **have** |
| TP-NGX-18 | refuse OS-tool / approve grant file | test_domain | requirement-sudoer-json-file | **have** |
| TP-NGX-19 | about prefers public inbound; Type 0 does not mkdir | test_domain | three-layer §2.5.3 | **have** |
| TP-NGX-20 | default JSON grant is `/usr/local/bin/nginx-cli` `request` only | test_domain | requirement-sudoer-json-file | **have** |
| TP-NGX-21 | conf-to-json dest add sample → kind redirect | test_domain | domain §2.2.9 | **have** |
| TP-NGX-22 | json-to-conf dest add JSON → listen 80 | test_domain | domain §2.2.9 | **have** |
| TP-NGX-23 | convert xor / refuse include / refuse dest --out / inbound --out | test_domain | prevention PREV-CONVERT-* | **have** |
| TP-NGX-24 | remove JSON → purpose comments only | test_domain | domain §2.2.9 | **have** |
| TP-NGX-25 | `request` of dest JSON; approve alias archives `.json` name | test_domain | domain JSON dest | **have** |
| TP-NGX-26 | inbound body is dest request JSON | test_domain | domain §2.2.4 | **have** |
| TP-NGX-27 | JSON domain / username mismatch fail-closed | test_domain | domain verify | **have** |
| TP-NGX-28 | approve publishes rendered `server {` text, not raw JSON | test_domain | PREV-JSON-GATE | **have** |
| TP-NGX-29 | `--json request` emits one status object | test_domain | output + convert silence | **have** |
| TP-NGX-32 | sudoer grant non-listed binary refuse | test_domain | sudoer-json-file allowlist | **have** |
| TP-NGX-33 | JSON `include` inject fail-closed | test_domain | domain §2.2.9 refuse | **have** |
| TP-NGX-34 | setup passwd-ensure; help names `passwd nginx-adm`; no `chpasswd` | test_domain | LPU · three-layer JOB-PASSWD · OPEN-PASSWD-CLI | **have** |
| TP-NGX-35 | `fence-test --file` pass corpus (sibling `submit_app` dest-legal) | test_domain | dest Fence · domain | **have** |
| TP-NGX-36 | `test-json-format` sibling stamp dest-legal | test_domain | dest Fence | **have** |
| TP-NGX-37 | `fence-test` missing purpose is Fence | test_domain | dest Fence | **have** |
| TP-NGX-38 | `fence-test` unknown key is Fence | test_domain | dest Fence | **have** |
| TP-NGX-39 | `fence-test --dir` match corpus fail-closed | test_domain | dest Fence FC-M6 | **have** |
| TP-NGX-40 | `fence-test --dir --expect-match` | test_domain | dest Fence | **have** |
| TP-NGX-41 | `fence-test --dir` pass corpus | test_domain | dest Fence | **have** |
| TP-NGX-42 | tester missing `submit_app` fail-closed | test_domain | dest-owned stamp | **have** |
| TP-NGX-43 | `request` stamps live `submit_app` / `submit_version` | test_domain | domain §2.2.9 | **have** |
| TP-NGX-44 | `fence-test` xor `--file` and `--dir`; Next uses running ship unit | test_domain | dest Fence FC-M6 · TP-FENCE-13 | **have** |
| TP-NGX-45 | `--expect-match` without `--dir` fail-closed | test_domain | dest Fence · TP-FENCE-14 | **have** |
| TP-NGX-46 | `--json fence-test --file` dest-legal command field | test_domain | dest Fence · TP-FENCE-09 | **have** |
| TP-NGX-47 | Testers do not queue dest inbound | test_domain | dest Fence · TP-FENCE-08/09 | **have** |
| TP-NGX-48 | `test-json-format` refuses `--dir`; positional path stands in for `--file` | test_domain | dest Fence · TP-FENCE-08 | **have** |
| TP-NGX-49 | `fence-test` stdin dest-legal | test_domain | dest Fence · TP-FENCE-09 | **have** |
| TP-NGX-50 | replace stale `sudo … approve` managed hook | test_domain | domain §2.2.6 · PREV-HOOK-SUDO | **have** |
| TP-NGX-51 | setup fail-closed when `nginx-adm` or UID/GID 1999 is a foreign identity | test_domain | LPU Collision · L-COLLIDE-01 | **have** |
| TP-NGX-52 | `setup` auto-queues `login-hook-elev` JSON when sibling inbound exists; skip when missing | test_domain | three-layer §2.5.0 · sudoer-json-file | **have** |
| TP-NGX-53 | `setup` does not write `/etc/sudoers.d/nginx-adm` or `nginx-cli-submit` | test_domain | PREV-SUDOERS-MAIN · LPU 1.3.0 | **have** |
| TP-NGX-54 | JSON username is invoker; basename user is path-safe (hyphen → underscore) | test_domain | domain submit verify | **have** |
| TP-NGX-55 | Interactive / login-hook review shows YAML (not a JSON object dump) | test_domain | domain §2.2.5 | **have** |
| TP-HOOK-02 | missing `.profile` created and sources `.bashrc` | test_domain | login-hook | **have** |
| TP-HOOK-03 | existing `.profile` unchanged | test_domain | login-hook | **have** |
| TP-HOOK-08 | old `/usr/local/bin/nginx-cli approve` becomes `-hook`; setup ensure-symlink | test_domain | login-hook | **have** |
| TP-HOOK-09 | Type 1 `setup` reviews LPU hook (`ngx_enable_login_approval`); already-new not rewritten | test_domain | login-hook | **have** |

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Do not reintroduce online TP-CURL/TP-CSUM or TP-FOLDER-BACKUP as Core without product-mode change.  
4. Live host `useradd` stays **skip** unless an explicit privileged gate is added.  
5. Do not mark dest F6 / inbound **have** from sudoer-cli (3773 / NOPASSWD whole CLI) shapes.
