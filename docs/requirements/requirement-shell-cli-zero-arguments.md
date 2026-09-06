**file**: docs/requirements/requirement-shell-cli-zero-arguments.md  
**Status**: Active (Version 1.2.1)  
**Area**: shell  
**Key**: `requirement-shell-cli-zero-arguments`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **zero-argument (empty argv) dispatcher behavior** of the nginx-cli POSIX shell CLI.

### 1.0 Product type

| Field | Value for nginx-cli |
|-------|-------------------------|
| **Empty-argv type** | **Type N — Non-online-install** |
| **Rationale** | Product is **local-only**; no `curl \| sh` channel. Empty argv **never** install-ensures. On a real terminal it opens the numbered list; in a script it shows **help**. |

Type O (online-install empty-argv = install-ensure) does **not** apply.

### 1.1 Human-facing

**In one sentence:** On a real terminal, `nginx-cli` with no arguments opens the numbered list; in a script it shows help. It never installs.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Empty line on a real terminal | `nginx-cli` |
| A script / pipe | Empty line shows help | `nginx-cli </dev/null` |
| Not this file | What the numbered list contains | `requirement-shell-cli-default-interaction` |

| Includes | Excludes |
|----------|----------|
| TTY empty argv → numbered list; off-TTY empty argv → help | Empty-line install; empty-line approve |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/nginx-cli` | ship unit | dispatcher |
| `nginx-cli` (no args) | command | list or help by TTY |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the list | You are at a real terminal. A script must not hang waiting for a number. | `nginx-cli` |
| Read usage in CI | Off-TTY empty argv is help. | `nginx-cli` |

## Under command line for normal user only

On Termux, Git Bash, or Windows cmd, empty argv **MUST** still follow this split (TTY list / off-TTY help) and **MUST NOT** become install-ensure or host mutate. **Admin privilege** (`setup` / `remove-lpu`) stays unused on that class.

---

## 2. Core Rules (Mandatory)

### 2.1 Single meaning of empty argv

1. When **argv is empty** (`$# -eq 0` at entry to `app_main`) **and** `TTY=1`, the dispatcher **MUST** route to the numbered list (`app_main_menu`). Topic owner: `requirement-shell-cli-default-interaction`.  
2. When **argv is empty** **and** `TTY=0`, the dispatcher **MUST** route to **`help`** / usage (`app_help`). Empty argv **MUST NOT** perform install or dest `approve`.  
3. Explicit `nginx-cli help` remains a valid full-usage path (same content family as empty argv).  
4. Explicit `nginx-cli install` remains the only first-time local install path (plus documented force refresh).  
5. Script entry **MUST** always call `app_main "$@"` (no basename product-name gate that blocks dispatch).

### 2.2 Normative matrix

| Invocation | Behavior |
|------------|----------|
| `nginx-cli` (no args, `TTY=1`) | Numbered list |
| `nginx-cli` (no args, `TTY=0`) | Show help; exit 0 |
| `nginx-cli help` | Show help; exit 0 |
| `nginx-cli install` | Local install ensure |
| Flags only (e.g. `--json` with no command) | **MUST** still resolve to help (or fail with clear usage if product chooses fail-closed) — default: **help** after flag parse with no command token |

### 2.3 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `nginx-cli` |
| **Type** | **Type N** |
| **Default COMMAND** | `help` |
| **Contrast Type O** | Type O install-ensure is **not** this origin’s empty-argv law |

### 2.4 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Empty argv meaning is explicit and not left as “whatever the parent did.”  
- **Principle 1 – Caution**: Avoid surprise install on bare invocation for an ops CLI.  
- **Principle 16 – Interactive**: Help is the safe human default for local tools.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: No silent ensure on empty argv.  
- **Intentional**: Type N declared in law.  
- **Anti-fragile**: Help works offline.  
- **Over-protect**: Do not reintroduce Type O without reclassifying product install mode.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Change empty argv to install-ensure while the product remains local-only.  
2. Copy Type O empty-argv law wholesale without updating this file and install mode.  
3. Make bare invocation run domain `backup`.  
4. Change empty argv to dest `approve` or to install-ensure. Interactive empty argv **MUST** stay the numbered list; non-interactive empty argv **MUST** stay help.

**Violating this rule is a critical dispatcher regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Off-TTY empty argv shows help and does not install; TTY empty argv is the numbered list |
| AC-2 | Type N is the declared empty-argv type |
| AC-3 | `install` remains an explicit command |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Dispatcher command table |
| `requirement-shell-cli-default-interaction` | Numbered list is TTY empty argv and `menu`/`main`; this file owns the TTY vs off-TTY split |
| `requirement-shell-local-self-management` | Explicit install |
| `requirement-bootstrap-chain` | Trim of Type O from parent |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | have (off-TTY empty argv = help) |
| **TP-CLI-25** | `tests/test_cli.sh` | have (TTY empty argv = numbered list; skip if no PTY) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Type N for local-only folder-backup |
| 2026-08-15 | Active 1.1.0 | Notes/examples name this product nginx-cli |
| 2026-08-23 | Active 1.1.1 | Empty argv stays help when `menu`/`main` is added |
| 2026-09-03 | Active 1.2.0 | TTY empty argv = numbered list; off-TTY help |
| 2026-09-06 | Active 1.2.1 | Human-facing + AC-1 match TTY split; TP-CLI-25 |

---

**Last Updated**: 2026-09-06  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
