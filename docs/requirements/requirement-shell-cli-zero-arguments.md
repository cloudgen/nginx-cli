**file**: docs/requirements/requirement-shell-cli-zero-arguments.md  
**Status**: Active (Version 1.3.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-zero-arguments`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **zero-cli-verb** behavior: no command token after switches.

**In one sentence:** On a real terminal, `nginx-cli` with no command opens the main menu (a switch such as `--debug` is still no command). A pipe, `--quiet`, or `--json` with no command places this CLI (`self-install`, local copy). It does not print help and it does not run `setup`.

| Box | Meaning | Example |
|-----|---------|---------|
| You, at a terminal | Main menu | `nginx-cli` or `nginx-cli --debug` |
| A script / CI | Place the program | `nginx-cli` with no TTY |
| Not this file | What the menu lists | `requirement-shell-cli-default-interaction` |

| Includes | Excludes |
|----------|----------|
| Interactive menu; non-interactive local `self-install` | Online `curl \| sh`; `setup`; help as the empty-argv page; empty-line `approve` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the menu | Real terminal, no command | `nginx-cli` |
| Place the CLI from a script | No TTY, or `--quiet` / `--json`, no command | `nginx-cli` |
| Read usage | Named help, not empty argv | `nginx-cli help` |

## Under command line for normal user only

On Termux, Git Bash, or Windows cmd, the same split applies. Non-interactive zero-cli-verb **MUST** still be local `self-install` and **MUST NOT** run `setup` or `remove-lpu`.

---

## 2. Core Rules (Mandatory)

### 2.1 What “no command” means

1. `app_main` **MUST** start with `COMMAND=""`. **MUST NOT** use `: "${COMMAND:=help}"` after that clear (`:=` treats empty as unset).  
2. Both paths use `ngx_zero_cli_verb`: `$# -eq 0` before the flag loop, and an empty `COMMAND` after switches are parsed.  
3. `--debug`, `--force`, `--global`, and the other flags are **not** a verb.  
4. Interactive means `TTY=1` and `JSON=0` and `QUIET=0`. That path calls the main menu.  
5. Anything else with no verb calls `inst_self_install` (local copy). `--quiet` and `--json` set non-interactive. Off-TTY `--debug` with no verb is `self-install`.  
6. Explicit `help` stays help. Named `menu` / `main` are not this split: off a terminal they fail closed (`requirement-shell-cli-default-interaction`).

### 2.2 self-install (local copy)

1. Copies the **running** ship unit only. **MUST NOT** download. `SCRIPT_URL` stays empty. **MUST NOT** run `setup` or start nginx.  
2. Root → `${GLOBAL_BIN}`; non-root → `${USER_BIN}`. Mode **0755**.  
3. Human start line (when not JSON): `Starting self-install of ${APP_NAME} ${VERSION}...`.  
4. Already installed and not `--force`: success, no second copy. If the target is `${USER_BIN}/${APP_NAME}`, still run the user-bin PATH companion. **MUST NOT** call `inst_local_install` on that no-op path.  
5. First install **MAY** call `inst_local_install` after the starting line.  
6. **MUST NOT** print help.

`install` remains the named local place verb. `self-install` is the zero-cli-verb and menu-87 place verb. `self-update`, `self-uninstall`, and `version-check` stay **absent**.

### 2.3 Summary

| Situation | Route |
|-----------|--------|
| TTY, no `--quiet`, no `--json`, no verb | Main menu |
| No TTY, or `--quiet`, or `--json`, no verb | `self-install` |
| `help` | Help |
| `menu` / `main` off a terminal | Fail closed, exit 1 |

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** A script must not hang on a menu, and must not run `setup`.  
- **Intentional:** One function owns both empty paths.  
- **Anti-fragile:** `--debug` on a terminal still opens the menu.  
- **Over-protect:** No network installer under the name `self-install`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Send non-interactive zero-cli-verb to help.  
2. Send interactive zero-cli-verb to `self-install` or to `setup`.  
3. Download a script (`curl | sh`) for `self-install`.  
4. Turn zero-cli-verb into `approve`.  
5. Restore `: "${COMMAND:=help}"` inside `app_main`.

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Off-TTY empty argv exits 0, places the user binary (isolated), and does not print `Usage:` or `9. Exit` |
| AC-2 | TTY empty argv is the main menu |
| AC-3 | TTY `--debug` / `--force` with no verb is the menu; off-TTY `--debug`, `--quiet`, and `--json` with no verb are `self-install` |
| AC-4 | `--debug version` stays the one-line version |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-default-interaction` | Menu tree |
| `requirement-shell-local-self-management` | `install` and local `self-install` |
| `requirement-shell-cli-interface` | Command table |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP-ID | Test | Status |
|-------|------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | have (off-TTY empty argv = self-install) |
| **TP-CLI-23** | `tests/test_cli.sh` | have (switch-only split) |
| **TP-CLI-25** | `tests/test_cli.sh` | have (TTY empty argv = menu; skip if no PTY) |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Type N help for a local-only product |
| 2026-09-03 | Active 1.2.0 | TTY empty argv = numbered list; off-TTY help |
| 2026-10-04 | Active 1.3.0 | Interactive zero-cli-verb = menu; non-interactive = local self-install |

---

**Last Updated**: 2026-10-04  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
