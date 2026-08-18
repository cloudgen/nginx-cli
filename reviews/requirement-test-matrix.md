# Requirement ↔ test matrix — nginx-cli

**Updated:** 2026-08-15  
**Product VERSION:** 1.4.1  
**Suite:** `tests/run.sh`

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + stack residual; no online package |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-10, TP-CLI-13 | Origin cli-template; no online/archive verbs |
| requirement-project-folder | architecture | TP-LC-01 | src/nginx-cli + user bin |
| requirement-shell-cli-interface | shell | TP-CLI-* | Commands, flags, dispatch |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07 | Type N help |
| requirement-shell-local-self-management | shell | TP-LC-* (incl. **09/10** mode) | install/uninstall/where-is-me; **0755** |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09 | JSON / quiet / errors |
| requirement-shell-modular-function-design | shell | (indirect) | `ngx_*` domain prefix |
| requirement-shell-idempotency | shell | TP-LC-03,07 | Re-install / uninstall absent |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05, TP-NGX-11 | Uninstall confirm; approve no-TTY |
| requirement-shell-cli-storage | shell | TP-CLI-12 | Isolation |
| requirement-three-layer-privilege-model | architecture | TP-CLI-13, TP-CLI-14, TP-NGX-01,14,15,16,17,19,34 | F6 two families; submit-sudoer-request; no print-sudoers; no nginx-ctl; JOB-PASSWD |
| requirement-sudoer-json-file | architecture | TP-NGX-18,20 | grant is nginx-cli request as nginx-adm only |
| requirement-least-privilege-user | architecture | TP-NGX-10,13,15,34 | Fixture trees; inbound 2770; hook home; passwd-ensure |
| requirement-privilege-prevention-set | architecture | TP-CLI-04,10,13,14, TP-NGX-01,11,13,14,15,16,18,19,23,32,33,34 | Closed walls; inbound 2770; password CLI; compose no-mkdir; convert --out; JSON inject |
| requirement-domain-nginx-cli | domain | TP-NGX-01..34 | Fixture request/approve/reject/hook + JSON dest inbound + submit-sudoer-request + convert dual |

**Absent by design (no TP Core):** online-install, remote self-management, automatic channel checksum, folder-archive backup/restore, print-sudoers emit.
