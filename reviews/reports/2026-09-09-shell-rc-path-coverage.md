# Requirement coverage review — shell-rc PATH / this-login profile

**Date:** 2026-09-09  
**Product:** nginx-cli `VERSION=1.10.0`  
**Claim:** After user-bin `install`, this login can run `nginx-cli` by name; SSH login can reach PATH; sibling CLIs share one PATH line; nginx-adm login-hook stays a different writer.  
**Reference:** sibling sshd-cli `requirement-shell-path-and-shell-support`

## Registry inventory (Step −1)

- Registered on disk: **21** / **21** (match)
- Orphans: none
- Ghosts: none
- Foreign candidates: none (notes name nginx-cli)
- Scope: registry + authorized new `requirement-shell-path-and-shell-support`

## Class / bootstrap

- Project nature: software-development — Active `requirement-class-software-dev.md` **1.8.3**
- Direction: cli-template (A, frozen) → nginx-cli (B). No reverse-copy.
- Install class: **non-online-installable** (local-only). Remove verb stays `uninstall`.

## Coverage vs sshd-cli catalog

| Feature | sshd-cli | nginx-cli after this change | Verdict |
|---------|----------|-----------------------------|---------|
| path-ensure | Claimed | Claimed on `requirement-shell-path-and-shell-support` | Pass |
| this-login profile-ensure | Claimed | Claimed | Pass |
| login-hook | Unused | Independent REQ (points, not unused theater) | Pass |
| rc-owner this-login | This-login writer | This-login writer | Pass |
| sibling unify (exact PATH line) | Claimed | Claimed + implemented | Pass |
| `BASHRC` env + TP-LC-20..22 | have | have | Pass |
| `rc-test` routed | Gap | Gap (dual-mentioned; help does not list it) | Honest Gap |
| Termux `pkg` | Separate REQ | Not claimed | N/A |
| `self-uninstall` | Online pair | Must not copy — `uninstall` | Pass |

## Implementation vs law

| Rule | Evidence |
|------|----------|
| Create `BASHRC` if missing | `path_add_bashrc`; **TP-LC-11**, **TP-LC-20** |
| Exact `export PATH=` not substring | `grep -qF "${path_line}"`; **TP-LC-11**, **TP-LC-13** |
| Honor `BASHRC` | **TP-LC-20..22** real `{{HOME}}/.bashrc` untouched |
| Profile create-if-absent / never overwrite | `path_ensure_profile`; **TP-LC-12**, **TP-LC-14** |
| Heal on already-installed user-bin | `inst_local_install` calls `path_add_shell` before no-op; **TP-LC-03**, **TP-LC-13** |
| Scoped uninstall comments | `inst_local_uninstall_cleanup_path` matches `# Added by nginx-cli installer` only |
| Dual mention | CLI-interface `install` / `uninstall` / `rc-test` + this REQ |
| Testers apart | dest testers remain under Unit test; `rc-test` not in help (**TP-CLI-04**) |

## Git-surface

No `docs/templates/` · `docs/skills/` · `docs/terminologies/` · `docs/incidents/` · `docs/checklists/` paths in the new REQ or `index.md` row.

## Suite

`./tests/run.sh` — **PASS=379 FAIL=0 SKIP=0** (2026-09-09)

## Verdict

**Approve with follow-up:** `rc-test` remains a documented ship Gap (same as sshd-cli). Do not treat the Gap as a fail of this change.
