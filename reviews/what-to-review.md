# What to review — nginx-cli

**Living checklist** (review plan). Product: **nginx-cli** local self-managed Type 0 CLI plus nginx-adm request/approve domain.  
**Class:** software-development · **one** Active domain SSOT · **local-only** install channel.  
**Origin A:** `cli-template` (frozen at `src/cli-template`) — do not reverse-copy.  
**Always load first:** `reviews/lessons.md`

**Last plan update:** 2026-08-22  
**Ship unit VERSION:** 1.5.1  
**Suite baseline:** see `reviews/test-plan.md`

---

## Pre-flight

| # | Check | Notes |
|---|--------|--------|
| P1 | Read `docs/requirements/index.md` | Class + architecture + shell + one domain SSOT |
| P2 | Confirm ship unit `src/nginx-cli` | `APP_NAME` / `VERSION` hard-assign (**1.5.1**) |
| P3 | Confirm origin A remains `src/cli-template` | Frozen; no reverse-copy from B |
| P4 | Load `reviews/lessons.md` and re-check open L-* that still apply | Skip L-SUDOERS / restore lessons as parent-only |
| P5 | Run `./tests/run.sh` | Record PASS/FAIL/SKIP in report |
| P6 | Confirm install **channel** still local-only | No SCRIPT_URL product UX |
| P7 | Confirm trimmed verbs stay unknown | backup / restore / print-sudoers |
| P13 | Confirm `submit-sudoer-request` is present | Type 0 compose; no `/etc` write; no inbound mkdir |
| P14 | Dest inbound is dest request **JSON** | `request` is dest submitter; text dual converted first; approve renders before `nginx -t` |
| P15 | Convert never queues / never dest-writes | `--out` refuses `/etc`, sites trees, and queue dirs |
| P16 | Sudoer JSON grant is allowlisted | path = `/usr/local/bin/nginx-cli`, args = `request` only |
| P8 | Confirm dest notes name this product nginx-cli | cli-template only as origin A |
| P9 | F6 two families still dest-honest | password `nginx-cli`; NOPASSWD unit tools only; no `nginx-ctl` |
| P10 | Inbound still `2770` not `3773` | group `nginx-cli-submit`; dest allowlist |
| P11 | Type 1 TTY traps | approve no-TTY fail-closed; hook not `sudo -n`; setup no hang |
| P12 | Prevention catalog vs invented walls | no unpublished denylist; OPEN-UNIT-TOOLS / OPEN-PASSWD-CLI |
| P17 | Type 0 **test-purpose** `fence-test` / `test-json-format` | local test folder; no sudo; does not queue; help **Unit test** heading; xor `--file`/`--dir`; `--expect-match` only with `--dir` |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | posix-sh, local-only residual; this product nginx-cli |
| Bootstrap chain | `requirement-bootstrap-chain.md` | A = cli-template frozen; B = this product |
| Project folder | `requirement-project-folder.md` | `src/nginx-cli`, bins; frozen A; no `/var/backup` |
| CLI interface | `requirement-shell-cli-interface.md` | Type 0 commands, flags, dispatch; domain pointer |
| Empty argv Type N | `requirement-shell-cli-zero-arguments.md` | Empty = help |
| Local self-management | `requirement-shell-local-self-management.md` | install/uninstall; mode 0755 |
| Output SSOT | `requirement-shell-output-requirements.md` | `out_*`; JSON errors |
| Modular design | `requirement-shell-modular-function-design.md` | Type 0 prefixes + `ngx_` |
| Idempotency | `requirement-shell-idempotency.md` | Re-install |
| Storage | `requirement-shell-cli-storage.md` | Isolation |
| Domain | `requirement-domain-nginx-cli.md` | JSON dest **and** same-product submitter; dest Fence table; Type 0 `fence-test`; convert dual; no second nginx submitter |
| Dest Fence | `requirement-incorrect-json-format.md` | incorrect JSON format only; testers; dest-owned `submit_app` / `submit_version` |
| Coding style | `requirement-shell-script-coding.md` | specialize-in home; no skill-as-law |
| Sudoer JSON file | `requirement-sudoer-json-file.md` | grant is `nginx-cli request` as nginx-adm only |
| LPU | `requirement-least-privilege-user.md` | F1–F7; 1999; inbound 2770; not 1776/3773 |
| Three-layer | `requirement-three-layer-privilege-model.md` | Table A two families; no nginx-ctl; no print-sudoers |
| Prevention | `requirement-privilege-prevention-set.md` | OPEN-UNIT-TOOLS + OPEN-PASSWD-CLI; PREV-JSON-* / PREV-CONVERT-*; no invented walls |

**Do not review as this product’s law:** folder-archive backup, restore dest whitelist, print-sudoers emit (those remain on sibling **folder-backup**).
