# Review report — cache, main menu, language, local self-install

**Date:** 2026-10-04  
**Product:** nginx-cli  
**Ship unit:** `src/nginx-cli` **1.11.0**  
**Suite:** `sh tests/run.sh` → **PASS=473 FAIL=0 SKIP=0**

## What changed

| Topic | Shipped behavior |
|-------|------------------|
| Cache | Per-login per-process leaf. Linux preferred `/dev/shm/cache/cache-nginx-cli-<login>-$$`, then `/tmp/cache/...`, then `${HOME}/.cache/cache-nginx-cli-$$`. Git Bash has no 2nd fallback. Silent tier miss. Parents 1777 when this process can. Leaf 0700. |
| Persistence | `${HOME}/.local/nginx-cli`, including `language` mode 0600. |
| About | Labels Cache folder used / preferred / 1st fallback / 2nd fallback (omit when empty) and Persistence storage. JSON keeps `effective_storage` and `storage_dir`. |
| Zero-cli-verb | Interactive (TTY, not `--quiet`, not `--json`), including `--debug` with no command, opens the main menu. Otherwise local `self-install` (copy only, no download, no `setup`). |
| Named menu | `menu` / `main` off a terminal exit 1 with `menu needs a terminal`. |
| Menu | Front 1 request-side, 2 host-side, 5 language, 7 sudoers, 8 self-management, 9 Exit. Inner 11–111, 21–23, 71, 81/82/83/87. Invalid choice is `[WARN]` and reprints that board. Choice is `read -r`. |
| Language | Thirteen codes. `NGINX_CLI_LANG` overrides. Unknown file line stays and means English. Menu chrome, Usage heading, empty-argv sentence, about title, and cache labels follow the language. The rest of help stays English. |
| Still absent | `self-update`, `self-uninstall`, `version-check`, `print-sudoers`, `nginx-ctl`, `SCRIPT_URL` channel. |

## Law and proof

Requirements updated in the same change: storage 1.3.0, zero-arguments 1.3.0, default-interaction 1.3.0, language 1.0.0 (new), local self-management 1.6.0, interface 2.9.0, plus pointer rows in class, bootstrap, project-folder, prevention, and the login-hook empty-argv sentence. Registry `docs/requirements/index.md` lists **22** Active files.

Tests: TP-CLI-06, 07, 12, 17–28. Filled checklist for this run is under `docs/checklists/` (not versioned). This report is the tracked proof.

## Limits

Host class detection hides sudoers and host mutate rows. This Linux run shows row 7. Full help body is not translated. `rc-test` remains a ship Gap.
