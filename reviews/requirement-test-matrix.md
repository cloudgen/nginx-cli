# Requirement ↔ test matrix — nginx-cli

**Updated:** 2026-08-25  
**Product VERSION:** 1.7.0  
**Suite:** `tests/run.sh`

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + stack residual; no online package |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-10, TP-CLI-13 | Origin cli-template; no online/archive verbs |
| requirement-project-folder | architecture | TP-LC-01 | src/nginx-cli + user bin |
| requirement-shell-cli-interface | shell | TP-CLI-* (incl. **15** / **16** / **17..22**) | Commands, flags, dispatch; test-purpose `fence-test`; help testers apart; `menu`/`main` |
| requirement-shell-script-coding | shell | TP-CLI-01 | Specialize-in home; `sh -n` |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07, TP-CLI-17 | Type N help; empty argv not the numbered list |
| requirement-shell-cli-default-interaction | shell | TP-CLI-17..22 | Case 3 `menu`/`main`; TTY list; off-TTY help |
| requirement-shell-local-self-management | shell | TP-LC-* (incl. **09/10** mode) | install/uninstall/where-is-me; **0755** |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09 | JSON / quiet / errors |
| requirement-shell-modular-function-design | shell | (indirect) | `ngx_*` domain prefix |
| requirement-shell-idempotency | shell | TP-LC-03,07 | Re-install / uninstall absent |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05, TP-NGX-11, TP-CLI-17, TP-CLI-18 | Uninstall confirm; approve no-TTY; `menu` off-TTY |
| requirement-shell-cli-storage | shell | TP-CLI-12 | Isolation |
| requirement-three-layer-privilege-model | architecture | TP-CLI-13, TP-CLI-14, TP-NGX-01,14,15,16,17,19,34,50, **52**, **53** | F6 two families; submit-sudoer-request; no print-sudoers; no nginx-ctl; JOB-PASSWD; hook as-login; setup JSON auto-queue |
| requirement-sudoer-json-file | architecture | TP-NGX-18,20, **52**, **53** | two kinds; Type 0 request-only; setup auto-queue Family 1 (**have**) |
| requirement-incorrect-json-format | architecture | **TP-NGX-35..49**, **TP-CLI-15..16** | Dest Fence; testers; xor / stdin / no-queue; dest-owned `submit_app` / `submit_version` |
| requirement-least-privilege-user | architecture | TP-NGX-10,13,14,15,34,50, **51**, **52**, **53** | Fixture trees; inbound 2770; hook home as-login; replace stale sudo block; passwd-ensure; Family 1 JSON auto-queue; collision identity (**have**) |
| requirement-privilege-prevention-set | architecture | TP-CLI-04,10,13,14, TP-NGX-01,11,13,14,15,16,18,19,23,32,33,34,50, **52**, **53** | Closed walls; inbound 2770; password CLI; hook as-login; compose no-mkdir; convert --out; JSON inject; setup no sudoers.d |
| requirement-domain-nginx-cli | domain | TP-NGX-01..50 | Fixture request/approve/reject/hook + JSON dest inbound + submit-sudoer-request + convert dual + dest Fence testers + replace stale hook |

**Absent by design (no TP Core):** online-install, remote self-management, automatic channel checksum, folder-archive backup/restore, print-sudoers emit.
