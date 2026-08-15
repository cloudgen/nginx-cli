# Test plan — nginx-cli

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit:** `src/nginx-cli`  
**Product VERSION:** 1.4.0  
**Last plan update:** 2026-08-15  
**Last suite run:** PASS=189 FAIL=0 SKIP=0 (2026-08-15)

Status: **have** = automated today · **todo** = needed · **optional** · **n/a** · **skip** (environment)

---

## Baseline coverage

| Area | Status | Evidence |
|------|--------|----------|
| Syntax `sh -n` | have | TP-CLI-01 |
| version / help / about human + JSON | have | TP-CLI-02..06 |
| Type N empty argv = help | have | TP-CLI-07 |
| Unknown + quiet + set -u HOME | have | TP-CLI-08..11 |
| Storage isolation | have | TP-CLI-12 |
| No online verbs / no SCRIPT_URL UX | have | TP-CLI-04, TP-CLI-10 |
| Trimmed parent archive/print-sudoers verbs fail closed | have | TP-CLI-13 |
| Local install / idempotent / uninstall / mode 0755 | have | TP-LC-01..10 |
| Request workflow (fixture) | have | TP-NGX-01..13 |
| Dest F6 / inbound / no nginx-ctl | have | TP-CLI-14, TP-NGX-14..15 |
| submit-sudoer-request compose | have | TP-NGX-16..20 · TP-CLI-04/06 |
| Type 1 approve no-TTY fail-closed | have | TP-NGX-11 |
| Login hook password sudo (not `-n`) | have | TP-NGX-14 |
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
| TP-CLI-07 | empty argv Type N help | test_cli | requirement-shell-cli-zero-arguments | **have** |
| TP-CLI-08 | unknown fail-closed | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-09 | quiet suppresses version | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-10 | online verbs rejected | test_cli | requirement-bootstrap-chain | **have** |
| TP-CLI-11 | env -u HOME version | test_cli | class / defensive | **have** |
| TP-CLI-12 | storage isolation | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-13 | backup/restore/print-sudoers unknown | test_cli | requirement-bootstrap-chain · three-layer | **have** |
| TP-CLI-14 | `nginx-ctl` unknown; help does not list it | test_cli | prevention · three-layer · interface | **have** |

### TP-LC (local lifecycle)

Unchanged **have** TP-LC-01..10 against `src/nginx-cli`.

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
| TP-NGX-10 | login hook idempotent | test_domain | domain · LPU | **have** |
| TP-NGX-11 | interactive approve no-TTY fail-closed | test_domain | interactive · prevention | **have** |
| TP-NGX-12 | JSON list-approved | test_domain | output + domain | **have** |
| TP-NGX-13 | missing inbound fail-closed | test_domain | public queue Type 0 no-mkdir · prevention | **have** |
| TP-NGX-14 | hook is password `sudo … approve`, not `sudo -n` | test_domain | three-layer · prevention · domain | **have** |
| TP-NGX-15 | ship unit inbound `2770` not `3773`; F6 has unit NOPASSWD; no NOPASSWD on `/usr/local/bin/nginx-cli` | test_domain | LPU · three-layer · prevention | **have** |
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

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Do not reintroduce online TP-CURL/TP-CSUM or TP-FOLDER-BACKUP as Core without product-mode change.  
4. Live host `useradd` stays **skip** unless an explicit privileged gate is added.  
5. Do not mark dest F6 / inbound **have** from sudoer-cli (3773 / NOPASSWD whole CLI) shapes.
