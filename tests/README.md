# Tests — nginx-cli

## Run

```sh
./tests/run.sh
# or
sh tests/run.sh
```

Exit **0** when all assertions pass; **1** on failure; **2** if ship unit missing.

## Layout

| File | Focus | TP families |
|------|--------|-------------|
| `run.sh` | Entrypoint | — |
| `helpers.sh` | Asserts + isolated HOME | — |
| `helpers/pty_feed.py` | PTY feed for TTY `menu` tests | **TP-CLI-21..22** |
| `test_cli.sh` | CLI surface, Type N empty argv, `menu`/`main`, offline reject | **TP-CLI-*** |
| `test_local_lifecycle.sh` | install / uninstall / where-is-me | **TP-LC-*** |
| `test_domain.sh` | request/approve/reject fixture (no host useradd); dest Fence testers | **TP-NGX-*** |
| `fixtures/fence-test/pass/` | Dest-legal JSON (sibling `submit_app` dest-legal) | **TP-NGX-35/41/44/46/47/48/49** |
| `fixtures/fence-test/match/` | Dest Fence matches (missing purpose / unknown key) | **TP-NGX-37..40** |

## Isolation

- Temp `HOME` + `USER_BIN` + redirected `GLOBAL_BIN` for install tests  
- Domain fixture uses `NGINX_CLI_FIXTURE=1` + `NGINX_ADM_HOME` and `NGINX_QUEUE_ROOT` under `/tmp` (tests mkdir the public trio; Type 0 does not)  
- **No** public network  
- **No** live `useradd` / write to host `/etc/nginx`

## Ship unit under test

`src/nginx-cli`

## Maps

Product TP map: `reviews/test-plan.md`  
RTM: `reviews/requirement-test-matrix.md`
