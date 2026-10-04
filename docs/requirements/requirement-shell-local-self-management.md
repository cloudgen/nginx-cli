**file**: docs/requirements/requirement-shell-local-self-management.md  
**Status**: Active (Version 1.6.0)  
**Area**: shell  
**Key**: `requirement-shell-local-self-management`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **local self-managed lifecycle** of the nginx-cli POSIX shell CLI: **`install`**, **`uninstall`**, and **`where-is-me`**, plus the local diagnostics package contract for **`version`**, **`about`**, and **`help`** (wiring owned with CLI interface).

**Install mode:** **local-only**. Online channel install, remote version-check, self-update, and self-uninstall are **out of scope** (intentionally absent).

PATH / this-login profile **bodies**, sibling unify, `BASHRC`, and `rc-test` live on `requirement-shell-path-and-shell-support`. This file owns the **call site**: user-bin `install` **MUST** run path-ensure (including already-installed no-op); `uninstall` **MUST** call scoped rc cleanup after binary remove.

### 1.1 Human-facing

**In one sentence:** Copy this program into `~/.local/bin` (or `/usr/local/bin` as root), and remove that copy later. There is no online installer.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Install for yourself | `sh src/nginx-cli install` |
| Root | Global install | `sudo sh src/nginx-cli install` |
| Not this file | Create nginx-adm | `requirement-least-privilege-user` (`setup`) |

| Includes | Excludes |
|----------|----------|
| `install` / `uninstall` / `where-is-me`; mode **0755**; companion **call site** | `curl \| sh`; `self-update`; `self-uninstall`; PATH/profile **bodies** |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/nginx-cli` | ship unit | running copy |
| `~/.local/bin/nginx-cli` | local dest | this login |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Put it on PATH | Copies the running file. Re-run with `--force` after you edit source. | `sh src/nginx-cli install` |

## Under command line for normal user only

On Termux, Git Bash, or Windows cmd, **local** `install` / `uninstall` / `where-is-me` for **this login** remain allowed. **MUST NOT** grow an online `curl | sh` path or in-tool `sudo` on that class.

---

## 2. Core Rules (Mandatory)

### 2.1 Local lifecycle command pair

| Feature | Command | Meaning |
|---------|---------|---------|
| Local install | **`install`** | Copy **running** ship unit → privilege-correct bin; **no** network |
| Local uninstall | **`uninstall`** | Remove **managed** binary only; confirm / `--force` |
| Local refresh | **`install --force`** | Replace managed binary from **this** running ship unit |
| Where-is-me | **`where-is-me`** | Report running path + managed install path + installed flag |

**Local place verbs:** `install` (named) and `self-install` (zero-cli-verb and menu 87). Both copy the running ship unit. No network.

**Forbidden primary verbs for this product:** `self-uninstall`, `self-update`, `version-check`.

### 2.2 Local diagnostics (required companions)

| Feature | Command | Network |
|---------|---------|---------|
| **Local version** | `version` | **MUST NOT** fetch remote |
| About | `about` | Local diagnostics only; **no** `SCRIPT_URL` install one-liner as product UX |
| Help | `help` | Lists local lifecycle commands only |

### 2.3 Local install rules

1. Source **MUST** be the currently executing ship unit when resolvable — **not** a URL.  
2. Target **MUST** be root → `${GLOBAL_BIN}/${APP_NAME}`; non-root → `${USER_BIN}/${APP_NAME}` unless **`--global`** / `FORCE_GLOBAL=1` is set.  
3. Defaults: `GLOBAL_BIN=/usr/local/bin`; `USER_BIN=${HOME}/.local/bin`.  
4. Create target bin dir when missing; fail loud if not writable.  
5. Atomic place: stage → set mode → `mv` onto final path (or equivalent `install -m`).  
6. Idempotent: already installed + force off → success no-op **for content**; mode **MUST** still be healed to the required mode when the installer can write the target (see §2.3.1). User-bin **MUST** still run PATH/profile companion before that no-op (`requirement-shell-path-and-shell-support`).  
6a. User-bin `install` **MUST** call `path_add_shell` (this-login PATH + missing `.profile`). Root/global place **MUST NOT** edit this-login rc.  
7. **MUST NOT** require network for install.  
8. **`install --global`** (or `FORCE_GLOBAL=1`): target **`${GLOBAL_BIN}/${APP_NAME}`**; if not writable, fail with clear root/sudo guidance.  
9. Global install **SHOULD** be used on multi-user hosts when a shared CLI is desired. Local install remains correct for Type 0 day-to-day use.

### 2.3.1 Installed binary mode (multi-user runnable) — mandatory

This product ships as a **POSIX shell script** (interpreted). Execution by any non-owner requires the **read** bit for that class, not execute alone.

| Rule | Requirement |
|------|-------------|
| **Final mode** | Managed install **MUST** set absolute mode **`0755`** (`rwxr-xr-x`) on the installed binary |
| **Forbidden weak form** | **MUST NOT** rely on `chmod +x` alone after `mktemp`/`cp` — `0600 \| 0111 = 0711` yields `rwx--x--x`, which **breaks** non-owner runs of shell scripts |
| **Global multi-user** | After root/global install to `${GLOBAL_BIN}`, **any** host user (including root and unprivileged accounts) **MUST** be able to execute `${GLOBAL_BIN}/${APP_NAME}` (subject only to path/exec mount policy) |
| **User-bin** | Local install **MUST** also use **`0755`** so the owner always has a normal runnable script (and heal survives umask / prior bad modes) |
| **Not world-writable** | Mode **MUST NOT** grant group/other write (`o+w` / `g+w` forbidden for the managed binary) |
| **Mode heal** | If the managed path already exists and force is off, install **MUST** still attempt `chmod 0755` on that path when permitted (fix broken `0700`/`0711` installs without requiring `--force`) |
| **Verify** | After place (and after heal), the installer **SHOULD** confirm the path is readable and executable by the installing process; fail loud if place left a non-executable file |

**Rationale (CIAO):** Global install is the production trust path for elevation. A root-owned `0711` ship unit looks “installed” (`-x`) but denies normal users — anti-fragile install must leave a **usable multi-user CLI**, not merely an owner-only script.

### 2.4 Local uninstall rules

1. User command name **MUST** be **`uninstall`** only.  
2. Target **MUST** be the managed binary only.  
3. Absent → success no-op.  
4. Interactive confirm unless `--force`; non-interactive/json/quiet without force → **fail closed** (`confirm_required`).  
5. **MUST NOT** delete home trees, unrelated binaries, or invent a sudoers/backup cleanup path.  
6. After user-bin binary remove, **MUST** call `inst_local_uninstall_cleanup_path`. **What** may be edited in rc is `requirement-shell-path-and-shell-support` (this product’s comments only; shared PATH only if `USER_BIN` empty; never delete `.profile`).

### 2.5 Where-is-me rules

1. Report absolute running path when resolvable.  
2. Report expected managed install path and whether installed.  
3. Honest degradation when `$0` is not a file path.  
4. JSON at least: `running_path`, `install_path`, `installed`.  
5. Output via `out_*` / `out_json` only.

### 2.6 Config variables (local)

| Variable | Role | Default / note |
|----------|------|----------------|
| `APP_NAME` | Binary basename SSOT | hard-assign `nginx-cli` |
| `VERSION` | Local version SSOT | hard-assign in ship unit (`1.11.0`) |
| `GLOBAL_BIN` | System-wide bin | `/usr/local/bin` |
| `USER_BIN` | Per-user bin | `${HOME}/.local/bin` |
| `FORCE` | Replace / skip confirm | `0` |
| `FORCE_GLOBAL` | Force install/operate on global path | `0` (`install --global`) |
| `SCRIPT_URL` / `REPO_*` / `CHECKSUM` | **Not** install source | Must not appear as required install UX |

### 2.7 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product / binary** | `nginx-cli` |
| **Ship unit** | `src/nginx-cli` |
| **Origin A (frozen)** | `src/cli-template` — Type 0 lifecycle inherited; do not reverse-copy |
| **Primary install path story** | Type 0 day-to-day: `${HOME}/.local/bin/nginx-cli`; multi-user: `/usr/local/bin/nginx-cli` |
| **Handlers** | `inst_local_install`, `inst_local_uninstall`, `app_where_is_me`, `app_version` |
| **Detect** | `inst_is_installed` / privilege-correct path helpers |
| **Online package** | **Absent by design** (bootstrap trim) |

### 2.8 Why This Requirement Exists (CIAO)

- **Principle 9 – Command types**: Type 0 local lifecycle only for place/remove.  
- **Principle 10 – Least privilege**: User bin without root when possible.  
- **Principle 3 – Anti-fragile**: Works offline / air-gapped.  
- **Principle 16 – Interactive**: Uninstall confirm contract.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: No network in install path.  
- **Intentional**: Local verbs only (`install`/`uninstall`).  
- **Anti-fragile**: Idempotent place/remove.  
- **Over-protect**: Do not reintroduce online lifecycle under new names.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Replace local `uninstall` with online `self-uninstall` as the primary remove verb.  
2. Require `SCRIPT_URL` for install.  
3. Turn non-interactive zero-cli-verb into a network installer, or into `setup`. Local `self-install` (copy only) is allowed. Interactive zero-cli-verb stays the menu.  
4. Delete user data or unrelated paths during uninstall.  
5. Fetch remote version inside `version`.  
6. Install the managed binary with execute-only group/other bits (`0711` / `chmod +x` after `0600` stage) — **must** keep absolute **`0755`** so global install remains multi-user runnable for a shell ship unit.  
7. Re-own PATH / profile bodies here instead of `requirement-shell-path-and-shell-support`.  
8. Skip path-ensure because the binary is already placed.

**Violating this rule is a critical install-mode regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | `install` copies ship unit to user or global bin without network |
| AC-2 | `uninstall` removes managed binary only with confirm/`--force` contract |
| AC-3 | `where-is-me` reports paths + installed flag |
| AC-4 | `version` is local-only |
| AC-5 | No Active online self-management requirement required for lifecycle |
| AC-6 | Installed managed binary mode is **`0755`** (not `0711` / owner-only) after install |
| AC-7 | Global install is executable by a non-owner account (shell script remains readable) |
| AC-8 | Re-running `install` without `--force` heals a broken mode (`0700`/`0711` → `0755`) when writable |
| AC-9 | User-bin `install` (including already-installed) runs PATH/profile companion; `uninstall` calls scoped rc cleanup |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Command table + flags |
| `requirement-shell-cli-zero-arguments` | Interactive menu; non-interactive local `self-install` |
| `requirement-project-folder` | Path defaults |
| `requirement-shell-idempotency` | Already installed / uninstalled |
| `requirement-shell-path-and-shell-support` | PATH / profile bodies; sibling unify; `rc-test` |
| `requirement-bootstrap-chain` | Why online package is absent |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-LC-01..08** | `tests/test_local_lifecycle.sh` | have |
| **TP-LC-09** mode `0755` after install | `tests/test_local_lifecycle.sh` | have |
| **TP-LC-10** mode heal without `--force` | `tests/test_local_lifecycle.sh` | have |
| **TP-LC-11..14**, **TP-LC-20..22** rc / `BASHRC` | `tests/test_local_lifecycle.sh` | have — **primary owner:** `requirement-shell-path-and-shell-support` |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Local-only lifecycle for folder-backup |
| 2026-08-09 | Active 1.2.0 | §2.3.1 mode **0755** multi-user; ban `chmod +x`→`0711` trap; AC-6..8; TP-LC-09/10 |
| 2026-08-15 | Active 1.4.0 | Notes/`APP_NAME`/`VERSION` name this product nginx-cli 1.1.0 |
| 2026-09-09 | Active 1.5.0 | PATH/profile companion **call site**; bodies → `requirement-shell-path-and-shell-support` |

---

**Last Updated**: 2026-09-09  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
