**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 1.3.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-default-interaction`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the nginx-cli **main menu**.

**In one sentence:** On a real terminal, `nginx-cli` (no command) or `nginx-cli menu` opens a short front board; you pick a category, then a command. A wrong pick warns and reprints that board. Off a terminal, `menu` stops with an error.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Front board, then a category | `1` then `11` |
| Not this file | Who opens the menu vs who self-installs | `requirement-shell-cli-zero-arguments` |

| Includes | Excludes |
|----------|----------|
| Layered boards, `read -r`, warn-and-reprint | Flat 1–14 plus Exit 99; `help` as a row; testers as rows; hanging in CI |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open | Real terminal | `nginx-cli` or `nginx-cli menu` |
| Leave | Front only | `9`, `99`, `999`, `exit`, or an empty line |
| Go back | Any inner board | `0`, `q`, empty line, or `exit` |

## Under command line for normal user only

On Termux, Git Bash, or Windows cmd the front **MUST** omit row **7** (sudoers) and say that sudoers is not available for that class **before** the numbers. The host board **MUST** omit **21** and **22** and say that `setup` and `remove-lpu` are not available. Choosing a hidden number warns and stays. This class **MUST NOT** gain sudo, apt, or `setup` from the menu.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 When the menu runs

1. Interactive zero-cli-verb and the verbs `menu` / `main` call `app_cmd_menu`.  
2. If `TTY` is not `1`, `app_cmd_menu` **MUST** `out_die` with a message that contains `menu needs a terminal`. Exit **1**. **MUST NOT** print help.  
3. On a terminal, `--json` and `--quiet` are cleared for the walk and restored on the way out. Interactive `menu --json` still draws the menu.  
4. The header is `util_app_ident` (TTY: bold name, italic version) via `out_info`.  
5. A choice is current-shell `read -r`. **MUST NOT** capture `read`. **MUST NOT** use `_choice=$(prompt_ask`. Operand prompts inside a leaf stay `prompt_ask` (`PROMPT_ASK_VALUE`). An empty required operand prints `Next:` and returns to the front.  
6. An invalid choice is `out_warn` (stderr prefix `[WARN]`), names the token, reprints **that** board, and **MUST NOT** `out_die`.  
7. After a finished leaf, show the front board again.

### 2.2 Front board

| Number | Short | Long (English) |
|--------|-------|----------------|
| 1 | request-side | this login's nginx site requests |
| 2 | host-side | nginx-adm on this host (setup, remove, login hook) |
| 5 | language | display language for this menu |
| 7 | sudoers | passwordless sudo grant for this CLI |
| 8 | self-management | this CLI install, version, and about |
| 9 | *(plain line)* | `9. Exit` (the word Exit follows `APP_LANG`) |

Row 7 is omitted on the normal-user-only class, with the hidden message first. Front **6** is not a row. Category shorts and longs follow `APP_LANG`. Leaf shorts stay English verbs. `where-is-me`, `help`, `menu`, `main`, `fence-test`, and `test-json-format` stay off every numbered list.

`9`, `99`, `999`, `exit`, and an empty line leave the front. EOF leaves. `q` on the front is an unknown choice.

### 2.3 Inner boards

**1 request-side:** 11 request, 12 list-requests, 13 list-approved, 14 list-rejected, 15 approve, 16 reject, 17 map-set, 18 map-unset, 19 map-list, 110 conf-to-json, 111 json-to-conf.

**2 host-side:** 21 setup, 22 remove-lpu, 23 enable-login-approval. On the normal-user-only class hide 21 and 22. Typed alias `remove-nginx-adm` runs remove-lpu.

**7 sudoers:** 71 submit-sudoer-request only. **MUST NOT** add print-sudoers, generate, or remove-project-sudoers.

**8 self-management:** 81 install, 82 version (TTY runs `app_about`; argv `version` stays the one-liner `app_version`), 83 about, 87 self-install. Always say that version-check, self-update, and self-uninstall are not on this menu (local install only). **MUST NOT** route those three verbs. No rows 84, 85, 86.

**5 language:** numbers and save rules are `requirement-shell-cli-language`.

**0 / q / empty / EOF / exit** on an inner board returns to the front without running a leaf.

### 2.4 Row look

`out_menu_choice`: number plain, short bold, long italic light gray (`[3;37m`) on a TTY. Exit and Back are plain lines, not `out_menu_choice`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Off a terminal the named menu fails closed instead of waiting.  
- **Intentional:** Categories first; leaves keep English command names.  
- **Anti-fragile:** A bad number reprints the same board.  
- **Over-protect:** Online verbs stay unnamed as rows.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Flatten the tree back to 1–14 and Exit 99.  
2. Put help, testers, `menu`, or `where-is-me` on a numbered row.  
3. Route `version-check`, `self-update`, `self-uninstall`, `print-sudoers`, or `nginx-ctl`.  
4. Capture `read` or drive the board with `prompt_ask`.  
5. `out_die` on a bad menu number.  
6. Print help when `menu` is used off a terminal.

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | TTY front shows `1. request-side:`, `5. language:`, `8. self-management:`, `9. Exit` |
| AC-2 | Front does not show `1. remove-lpu:` or `99. Exit` |
| AC-3 | Choice `6` warns with `[WARN]`, names `6`, and reprints `9. Exit` |
| AC-4 | Off-TTY `menu` and `main` exit 1 with `menu needs a terminal` and are not Usage help |
| AC-5 | TTY `menu --json` still draws the front |
| AC-6 | Boards 11, 21, 71, 81, and 87 exist; 84 version-check is not a row |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | When empty argv opens this menu |
| `requirement-shell-cli-language` | Board 5 and translated chrome |
| `requirement-shell-cli-interface` | Verb table |
| `requirement-shell-output-requirements` | `out_warn` / `out_menu_choice` |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP-ID | Test | Status |
|-------|------|--------|
| **TP-CLI-17** | `tests/test_cli.sh` | have (off-TTY menu fail closed) |
| **TP-CLI-18** | `tests/test_cli.sh` | have (`--json menu` is an error off-TTY) |
| **TP-CLI-19** | `tests/test_cli.sh` | have (off-TTY `main` fail closed) |
| **TP-CLI-21** | `tests/test_cli.sh` | have (front rows) |
| **TP-CLI-22** | `tests/test_cli.sh` | have (TTY `--json` still the menu) |
| **TP-CLI-24** | `tests/test_cli.sh` | have (version header, italic long) |
| **TP-CLI-26** | `tests/test_cli.sh` | have (`[WARN]` reprint) |
| **TP-CLI-27** | `tests/test_cli.sh` | have (inner boards) |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-23 | Active 1.0.0 | Flat list, Exit 99 |
| 2026-09-13 | Active 1.2.0 | Invalid choice retries the flat list |
| 2026-10-04 | Active 1.3.0 | Layered front 1/2/5/7/8/9; warn not error; off-TTY menu fail closed |

---

**Last Updated**: 2026-10-04  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
