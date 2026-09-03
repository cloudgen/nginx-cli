**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 1.1.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-default-interaction`  
**id**: RQ-SHELL-CLI-DEFAULT-INTERACTION  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for nginx-cli’s optional **TTY numbered list of live work commands**. The product **claims** that list. Look **MUST** be default CLI main menu style: header **nginx-cli**(*version*) then `command: what it does` with gray italic descriptions on a TTY. The zero-argument requirement assigns **interactive** empty argv to this list and keeps off-TTY empty argv as help. `menu` / `main` are the same handler.

### 1.1 Human-facing

**In one sentence:** On a real terminal, type `nginx-cli` (or `nginx-cli menu` / `main`) to get a numbered list of live work commands; a script still gets help.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the numbered list, pick a number or a command name | `nginx-cli menu` then `6` or `approve` |
| Automation / pipes | The list does not appear; you get help (JSON help with `--json`) | `nginx-cli menu </dev/null` |
| Not this file | What bare `nginx-cli` does | `requirement-shell-cli-zero-arguments` — help |

| Includes | Excludes |
|----------|----------|
| Numbered 1…N live work commands; last extra row Exit **99**; `menu` / `main` as the opener | `help` as a row; install / uninstall / where-is-me / setup / version / about; testers; `menu`/`main` as a choice; hanging in CI |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/nginx-cli` | ship unit | live `menu` / `main` |
| `nginx-cli menu` | command | numbered list on a real terminal |
| `nginx-cli` (no args) | command | help — unchanged |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Want the numbered list | Empty argv is already help. The list is a separate command. On a real terminal `--json` does not hide the list. In a script you get help so the process does not wait. | `nginx-cli menu` |
| Leave the list | Exit is **99** (fourteen command rows). Unused numbers 15–98 are omitted. | `99` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Claim and case (mandatory)

| Field | Value |
|-------|--------|
| **Claims a default function** | **yes** (user-ordered numbered list) |
| **Zero-argument requirement present** | **yes** — `requirement-shell-cli-zero-arguments` |
| **Online-installable** | **no** (local-only) |
| **Case** | **3** |

1. Empty argv **MUST** follow `requirement-shell-cli-zero-arguments`: **TTY=1** this numbered list; **TTY=0** help; never install.  
2. The numbered list **MUST** also be routed-verb **`menu`**. **`main` MUST** be the same handler (alias).  
3. **MUST NOT** draw the list off-TTY.  
4. **MUST NOT** list `menu` / `main` as a numbered choice on its own list.  
5. Choice **MUST** be current-shell `prompt_ask` then `PROMPT_ASK_VALUE`. **MUST NOT** `_choice=$(prompt_ask …)`.  
6. Look **MUST** use `util_app_ident` + `out_menu_choice` (TTY explain italic + light gray).

### 2.2 `menu` / `main` mode check (case 3)

Measure interactive capability **once in the main process, outside functions**. Helpers **MUST** consume `TTY`.

| Invocation | `--json` | MUST | MUST NOT |
|------------|----------|------|----------|
| Interactive (`TTY=1`) `nginx-cli menu` (or `main`) | **Ignore** (even if `JSON=1`) | Show the numbered list (§2.3); read a number or a command name | Treat `--json` as JSON help; hang |
| Non-interactive (`TTY=0`) `nginx-cli menu` (or `main`) | **Follow** | **Help**: human help when `JSON=0`; JSON help when `JSON=1` | Draw the list; hang; silent return |

`--quiet` without a TTY is still the help path. That help path **MUST NOT** swallow help (do not return empty because `QUIET=1`). Non-interactive help **MUST** reuse `app_help` (no second JSON help catalog).

### 2.3 Numbered list (sacred)

1. Print a **numbered list** at the beginning of the interactive menu path.  
2. Each numbered command row is one live **operational** command that is **not** excluded below, numbered **1 … N**, in dispatcher order.  
3. The printed line **MUST** be that command’s human-readable value: **`command: what it does`** (same wording as help’s one-liner).  
4. **MUST NOT** list: `help`; gap / forbidden / help-only names; **`menu` / `main` itself**; **install / setup**; **self-managed** (`install`, `uninstall`, `where-is-me`); **diagnostics** (`version`, `about`); **any test-purpose** verb (`test-json-format`, `fence-test`). Those stay on `help` (testers **apart** from operational).  
5. **MUST NOT** list the `remove-nginx-adm` alias as a second numbered row (`remove-lpu` is the live row; the alias **MAY** be accepted as typed input for that row).  
6. Last extra row is **Exit** (not a command token). Exit number **MUST** be the smallest all-nines number **strictly greater** than **N**.  
7. Accept a **number** or the **verb token**; run the matching handler. Exit number (or `exit` / `quit`) returns 0.  
8. Extra fields: on TTY, prompt **one field at a time**; if a required field is empty, print `Next: nginx-cli <verb> …` and return — **MUST NOT** hang off-TTY.

### 2.4 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Scripts never hang on the list; empty argv stays help.  
- **CIAO Principle 2 – Intentional**: Case 3 is explicit; `menu` / `main` is the named opener.  
- **CIAO Principle 6 – Single Point of Entry**: Dispatcher routes `menu` / `main`; handlers stay `app_*`.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: TTY list; off-TTY help; interactive ignores `--json`.  
- **CIAO Principle 17 – Help**: Non-interactive `menu` reuses `app_help`.  
- **CIAO Principle 5 – Single Source of Output**: List and prompts go through `out_*` / `prompt_*`.  
- **CIAO Principle 21 – Dual Policies**: Portable case table; Implementation Notes name this product.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: No menu in pipes or CI.  
- **Intentional**: Case 3; labels from the kept command list / help one-liners.  
- **Anti-fragile**: Empty argv law unchanged if this file is later dropped.  
- **Over-protect**: Exclusions (install/setup, testers, `help`, `menu` itself) and Exit **99** are sacred.

---

### 2.1 Implementation Notes (this project)

| Item | Value for nginx-cli |
|------|---------------------|
| **Product / binary** | `nginx-cli` |
| **Claimed** | yes |
| **Case** | **3** |
| **Empty-argv owner** | `requirement-shell-cli-zero-arguments` (help) |
| **Menu verbs** | `menu` (primary); `main` (alias) |
| **Handler** | `app_main_menu` (`app_*`) |
| **Ship-unit status** | **Implemented** — dispatcher accepts `menu` / `main` |
| **N** | **14** |
| **Exit** | **99** |
| **Prompt helper** | `prompt_ask` (consume `TTY`; `INTERACTIVE=1` for the menu walk) |

**Complete invocation samples (topic-owner — dual mention):**

```text
nginx-cli menu
nginx-cli main
nginx-cli menu --json
nginx-cli --json menu
```

On a real terminal those four show the numbered list. In a pipe / CI, `nginx-cli menu` shows human help; `nginx-cli --json menu` shows JSON help.

**Normative numbered list (labels = human-readable):**

```text
1. remove-lpu: Remove nginx-adm (confirm or --force)
2. request: Submit dest JSON (or nginx-conf text dual)
3. list-requests: Approving / pending list
4. list-approved: Approved archive
5. list-rejected: Rejected archive
6. approve: Interactive one-by-one, or approve one file
7. reject: Reject one pending request
8. enable-login-approval: Add or refresh as-login approve in nginx-adm ~/.bashrc (no sudo)
9. map-set: Add user-domain-map entry (chown nginx-adm)
10. map-unset: Remove map entry
11. map-list: Show user-domain-map
12. submit-sudoer-request: Queue JSON grant via sudoer-cli (needs --allow-test-local unless global install)
13. conf-to-json: nginx-conf text → dest request JSON
14. json-to-conf: dest request JSON → nginx-conf text
99. Exit
```

**Required fields when chosen from the list (TTY one-at-a-time):**

| Verb | Fields (in order) |
|------|-------------------|
| `request` | Domain; file path |
| `reject` | Request basename |
| `map-set` | Submitter login; domain |
| `map-unset` | Submitter login; domain |
| `conf-to-json` | File path; purpose (optional) |
| `json-to-conf` | File path |

Other listed verbs run with no extra operands (`approve` with no basename stays the TTY one-by-one walk).

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Invent menu labels instead of `command: what it does` from help / the kept command list.  
2. Put `help`, not-live names, `menu`/`main` itself, install/setup, self-managed verbs, version, about, or testers on the numbered list.  
3. Number Exit as **15** (N+1). Exit **MUST** be **99**.  
4. Draw the list in non-interactive mode.  
5. Swallow help under `--quiet` on the non-interactive `menu`/`main` help path.  
6. Invent a second JSON help object instead of calling `app_help`.  
7. Override empty argv with this list (case 3).  
8. Treat interactive `nginx-cli menu --json` as JSON help.  
9. Ignore `--json` on non-interactive `menu`/`main`.  
10. Claim the list is live while the dispatcher still rejects `menu` / `main`.

**Violating this rule is a critical CLI-surface regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Case **3** recorded; empty argv remains help |
| AC-2 | Dispatcher accepts `menu` and `main` as the same handler |
| AC-3 | Interactive `menu` prints the §2.1 list (N=14, Exit 99) |
| AC-4 | Interactive `menu --json` still prints that list |
| AC-5 | Non-interactive `menu` is human help (`app_help`) |
| AC-6 | Non-interactive `menu --json` is JSON help |
| AC-7 | Numbered choices omit help, install, uninstall, where-is-me, setup, version, about, testers, menu, main |
| AC-8 | Help lists `menu` (alias `main`) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | **Owns empty argv** (help) — this file does not |
| `requirement-shell-cli-interface` | Dual mention: `menu` / `main` on the command table |
| `requirement-shell-interactive-vs-noninteractive` | `TTY` measure; no hang |
| `requirement-shell-output-requirements` | `out_*` |
| `requirement-shell-modular-function-design` | `app_main_menu` prefix |
| `requirement-domain-nginx-cli` | Domain verbs the list may run |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-07** | `tests/test_cli.sh` | have | empty argv still help |
| **TP-CLI-17** | `tests/test_cli.sh` | have | `menu` off-TTY human help; not the numbered list |
| **TP-CLI-18** | `tests/test_cli.sh` | have | `menu --json` off-TTY JSON help |
| **TP-CLI-19** | `tests/test_cli.sh` | have | `main` off-TTY human help |
| **TP-CLI-20** | `tests/test_cli.sh` | have | help lists `menu` / `main` |
| **TP-CLI-21** | `tests/test_cli.sh` | have | TTY `menu` numbered list, Exit 99, exclusions (skip if no PTY) |
| **TP-CLI-22** | `tests/test_cli.sh` | have | TTY `menu --json` still the list (skip if no PTY) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-23 | Active 1.0.0 | Case 3; `menu`/`main`; N=14; Exit 99 |

---

**Last Updated**: 2026-08-23  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
