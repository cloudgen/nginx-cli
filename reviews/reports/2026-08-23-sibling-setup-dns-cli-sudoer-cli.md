# Report: sibling `setup` comparison — nginx-cli 1.6.0

**Date:** 2026-08-23  
**Mode:** dest-honest review of Type 1 `setup` vs sibling **sudoer-cli 1.17.0** (`lpu_setup`) and **dns-cli 1.12.0** (`lpu_setup`)  
**Status:** collision closed 2026-08-25 (L-COLLIDE-01 / TP-NGX-51 **have**)  
**Lessons loaded:** `reviews/lessons.md` (L-F6-01, L-INBOUND-01, L-HOOK-N-01, L-HOOK-SUDO-01, L-F6-PASSWD-01 re-checked)

## Summary

`nginx-cli setup` (`ngx_setup`) is a Type 1 host-admin create of **nginx-adm** plus public queues, F6, submit template, as-login hook, and password-ensure. Sibling `setup` commands are **not** this dest’s law. Several sibling shapes are **explicitly forbidden** here (inbound `3773`, NOPASSWD whole CLI, `sudo -n` hook, UID 1776).

Compared to sudoer-cli, nginx-cli is dest-honest on F5/F6/hook and **stronger** on Family 1 password. Compared to dns-cli, nginx-cli is dest-honest on Type 1 LPA (password sudo of the CLI, not Type 2 switch) and must **not** copy vault/trio/`print-sudoers`/login-hook-elev.

One **bug vs this product’s own LPU collision rule**: `ngx_create_adm_user` returns success if `nginx-adm` already exists, without checking UID 1999 / GID 1999 / expected home. sudoer-cli `lpu_collision_check` does that check. This dest’s law already requires fail-closed.

**Verdict: Pass** after 2026-08-25 (`ngx_adm_collision_check`). Do **not** copy sibling F6/inbound/hook shapes.

## Comparison (setup only)

| Surface | sudoer-cli `lpu_setup` | dns-cli `lpu_setup` | nginx-cli `ngx_setup` | Dest-honest for nginx-cli |
|---------|------------------------|---------------------|------------------------|---------------------------|
| Handler | `lpu_setup` after `sr_require_type1_bootstrap` (must already be euid 0) | `lpu_setup` after `lpu_require_elev` (TTY password-sudo re-exec) | `ngx_setup` after `ngx_require_root` (TTY password-sudo re-exec; fixture fail-closed) | Keep nginx-cli re-exec; **MUST NOT** require `sudo -n` |
| Account | `sudoer-adm` UID/GID **1776**, home `/etc/sudoer-adm`, `useradd -M` | `dns-adm`, **no pinned UID** on host `useradd`; test stub UID 1701; **`passwd -l`** | `nginx-adm` UID/GID **1999**, home preferred `/etc/nginx-adm`, `useradd -m` | Keep 1999; **MUST NOT** lock the password |
| Collision | `lpu_collision_check` — wrong UID/GID/home → die | name-in-use fail on create; no pinned-UID matrix | UID-in-use die **only on create**; existing `nginx-adm` → “already exists” **no identity check** | **Fix** to match this dest’s Collision paragraph |
| Global binary | **Copies** running ship unit to `GLOBAL_BIN` during setup | Fail-closed writing F6 unless global binary exists (or `--force`) | Does **not** install the binary; F6 points at `GLOBAL_BIN` | Keep Type 0 `install` separate; **MAY** warn if global binary missing |
| F5 inbound | `/var/sudoer-cli/sudoer-request` **3773** world `-wx` | `/var/dns-cli/dns-request` **3773** | `/var/nginx-cli/config-request` **2770** group `nginx-cli-submit` | **MUST NOT** copy 3773 (L-INBOUND-01) |
| F4 views | home → public trio (migrate dir → symlink) | inbound symlink if missing | trio + sites-available/enabled | Keep nginx sites links |
| Extra F5 | — | `~/.local/vaults/dns-cli` mode 0700 | `${NGINX_CONF_ROOT}` `nginx-adm:root`; `user-domain-map` | Keep nginx; **MUST NOT** copy vault |
| F6 | `/etc/sudoers.d/sudoer-adm`: `sudoer-adm ALL=(root) NOPASSWD: /usr/local/bin/sudoer-cli` | `/etc/dns-adm/sudoers` (not sudoers.d): `%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli` | `/etc/sudoers.d/nginx-adm`: **password** `nginx-cli` verbs + **NOPASSWD** nginx unit tools | **MUST NOT** copy NOPASSWD whole CLI or Type 2 `%sudo ALL=(lpu)` (L-F6-01) |
| Related fragment | none (grants via dest inbound) | setup **MUST NOT** write `/etc/sudoers.d`; queues `login-hook-elev` JSON for sibling dest | create-if-absent `/etc/sudoers.d/nginx-cli-submit` | Keep submit template; **MUST NOT** queue hook JSON as sudoer grant |
| Login hook | `.bashrc` + `.profile`; `sudo -n $GLOBAL_BIN/sudoer-cli interactive` | `.bashrc` + `.profile`; `sudo -n $GLOBAL_BIN/dns-cli interactive` | `.bashrc` **only**; `/usr/local/bin/nginx-cli approve` **as-login, no sudo** | **MUST NOT** wrap sudo/`sudo -n` (L-HOOK-SUDO-01) |
| Password | no JOB-PASSWD | **locks** account (`passwd -l`) | TTY `passwd nginx-adm` or warn (never record) | Keep JOB-PASSWD; **MUST NOT** lock |
| `print-sudoers` | live Type 0 | live Type 0 | **absent** (unknown) | Keep trimmed |
| visudo | yes before install 0440 | yes (non-test) | yes before cp 0440 | Keep |
| useradd PATH | `command -v` then `/usr/sbin` | `command -v` | `command -v` only | **MAY** adopt `/usr/sbin` fallback |

## Sacred: do not copy onto nginx-cli

These sibling rows stay **sibling-only**. This dest’s prevention catalog already names them:

| Sibling shape | Why nginx-cli refuses |
|---------------|------------------------|
| Inbound **3773** | Group dropbox **2770**; PREV-WORLD-WX; L-INBOUND-01 |
| NOPASSWD whole `nginx-cli` | Family 1 is password; PREV-F6-NOPASSWD-CLI; L-F6-01 |
| Hook `sudo -n … interactive` | OPEN-ADM-NOSUDO as-login `approve`; L-HOOK-N-01 / L-HOOK-SUDO-01 |
| `%sudo ALL=(lpu) NOPASSWD: binary` | nginx-adm is an LPA, not a Type 2 switch |
| `passwd -l` | Family 1 needs a usable password; L-F6-PASSWD-01 |
| Setup copies/installs the CLI binary | Type 0 `install` owns place; setup is LPU |
| Setup queues `login-hook-elev` into sudoer-cli inbound | This dest’s hook is as-login; grant is not that kind |
| `print-sudoers` | Trimmed (L-TRIM-01) |
| UID 1776 / unpinned UID | This dest is **1999** |

## Issues

### Issue 1 -- Severity: bug
- File: `src/nginx-cli:2977`
- Description: `ngx_create_adm_user` returns 0 as soon as `getent passwd nginx-adm` (or `id`) succeeds. It does not verify UID 1999, GID 1999, or expected home. UID collision is checked only on the **create** path. `requirement-least-privilege-user` Collision: if `getent passwd 1999` / `getent group 1999` / `getent passwd nginx-adm` exists and is **not** this identity, setup **MUST** exit non-zero. Sibling sudoer-cli `lpu_collision_check` already implements that matrix.
- Suggestion: Before heal/create, fail closed when the name exists with the wrong uid/gid/home, or when UID/GID 1999 belong to another name. Do not rewrite a live foreign identity.
- Lesson: L-COLLIDE-01
- Test: TP-NGX-51 (have, 2026-08-25)
- Status: closed

### Issue 2 -- Severity: suggestion
- File: `src/nginx-cli:3008`
- Description: `groupadd` / `useradd` are resolved with `command -v` only. sudoer-cli `lpu_find_bin` also tries `/usr/sbin/<tool>`, which is where those binaries live when root’s PATH is short.
- Suggestion: Resolve `useradd`/`groupadd`/`userdel`/`groupdel` the same way (command -v, then `/usr/sbin`).
- Test: optional static grep / fixture
- Status: open

### Issue 3 -- Severity: suggestion
- File: `src/nginx-cli:2900`
- Description: `ngx_write_adm_sudoers` always writes Cmnds for `${GLOBAL_BIN}/nginx-cli` even when that path is missing. dns-cli refuses F6 unless the global binary exists (unless `--force`). sudoer-cli **installs** the binary during setup — do not copy that; Type 0 `install` owns place here.
- Suggestion: Warn (or fail closed in production) when `${GLOBAL_BIN}/nginx-cli` is not executable, with Next: `sudo nginx-cli install` then re-run setup. Do not auto-copy the ship unit inside `setup`.
- Test: TP optional
- Status: open

### Issue 4 -- Severity: nit
- File: `src/nginx-cli:1619`
- Description: `ngx_require_root` retests `[ -t 0 ]` / `[ -t 1 ]` instead of consuming `TTY`. Interactive law: measure once outside functions. This is the false fail-closed class (command substitution). sudoer-cli bootstrap only checks euid 0 (no re-exec, no TTY retest).
- Suggestion: Gate the password-sudo re-exec on `TTY` / `JSON` / `QUIET` already set in the main process.
- Lesson: related to CL-SHELL-TTY-PRIVILEGE-TRAPS
- Status: open

## Re-checked lessons (no new copy)

| ID | Sibling temptation | nginx-cli status |
|----|--------------------|------------------|
| L-F6-01 | sudoer-cli NOPASSWD whole binary; dns-cli `%sudo ALL=(dns-adm)` | still two families; TP-NGX-15 |
| L-INBOUND-01 | both siblings 3773 | still 2770; TP-NGX-15 |
| L-HOOK-N-01 / L-HOOK-SUDO-01 | both siblings `sudo -n … interactive` | still as-login `approve`; TP-NGX-14/50 |
| L-F6-PASSWD-01 | dns-cli `passwd -l` | still TTY passwd / warn; TP-NGX-34 |
| L-TRIM-01 | both siblings `print-sudoers` | still unknown; TP-CLI-13 |

## Test-plan deltas

| TP-ID | Intent | Status |
|-------|--------|--------|
| TP-NGX-51 | setup fail-closed when `nginx-adm` or UID/GID 1999 is a foreign identity | **have** (2026-08-25) |

## Operator-readable errors

`ngx_require_root` names who and Next (`sudo nginx-cli setup`). Collision fatals today only cover “UID already used by NAME”. After Issue 1, the die line must stay people/folder (who owns 1999, Next: `getent passwd 1999`).

## Verdict

**Pass** (2026-08-25) — Issue 1 closed with dest-honest collision identity. Do **not** “align” nginx-cli setup to sudoer-cli or dns-cli F6/inbound/hook.
