**file**: docs/requirements/requirement-shell-modular-function-design.md  
**Status**: Active (Version 2.2.0)  
**Area**: shell  
**Key**: `requirement-shell-modular-function-design`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **modular function organization** of the nginx-cli POSIX shell CLI.

**Core idea:** Modularity is achieved through **clear function boundaries, consistent prefixes, and full CIAO documentation** — **not** by splitting the installable CLI into multiple shipped files.

Ship unit remains a **single executable** at `src/nginx-cli`. Origin reference remains `src/cli-template`.

### 1.1 Human-facing

**In one sentence:** One file is the program; helpers are grouped by prefixes (`out_`, `inst_`, `app_`, `ngx_`), not split into many shipped files.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | One program file | `src/nginx-cli` |
| Domain helpers | `ngx_*` | request/approve |
| Not this file | What those helpers **must** do | `requirement-domain-nginx-cli` |

| Includes | Excludes |
|----------|----------|
| Prefix table; single executable | Multi-file install payload |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/nginx-cli` | ship unit | all prefixes |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Add a helper | Pick the prefix; do not ship a second binary | (edit `src/nginx-cli`) |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Overall architecture

| Rule | Meaning |
|------|---------|
| **Single executable** | One primary script file for the installable CLI |
| **Logical modules** | Functions grouped by **strict prefixes** |
| **Documented units** | Public helpers carry defensive headers and safe defaults |
| **Requirements extract policy** | Durable rules live in `requirement-*.md`; code comments encode intent and Protection Zones |

### 2.2 Official function prefix table

**All functions MUST use a defined prefix.** Bare names (`main`, `install`, `help`) as function names are forbidden.

| Prefix | Category | Purpose | Example functions |
|--------|----------|---------|-------------------|
| `out_` | Output system | All user-facing and machine-readable output | `out_text`, `out_info`, `out_json`, `out_die` |
| `inst_` | Installation lifecycle | Local install/uninstall detect and place/remove | `inst_local_install`, `inst_local_uninstall`, `inst_is_installed` |
| `util_` | General utilities | Path resolve, storage, CIAO pre-change `.bak` helper | `util_resolve_storage`, `util_get_install_bin_path`, `util_backup` |
| `app_` | Cross-cutting CLI surface | Entry, dispatch, about/help/version/where-is-me/menu | `app_main`, `app_about`, `app_help`, `app_version`, `app_where_is_me`, `app_main_menu`, `app_run_command` |
| `path_` | Shell PATH & environment | User-bin PATH + this-login profile. **Bodies:** `requirement-shell-path-and-shell-support` | `path_add_shell`, `path_add_bashrc`, `path_ensure_profile` |
| `prompt_` | Interactive prompts | TTY-safe confirmations | `prompt_yes_no`, `prompt_approve_choice` |
| `ngx_` | Domain business logic | nginx-adm setup + request workflow + sudoer compose + conf JSON dual | `ngx_setup`, `ngx_request_submit`, `ngx_approve_one`, `ngx_submit_sudoer_request`, `ngx_conf_to_json`, `ngx_json_to_conf` |

**Notes:**

- Domain prefix **`ngx_`** (path-safe form of `nginx-cli`).  
- **Do not** put generic about/help/main under a domain prefix.  
- Parent `fb_*` **MUST NOT** be reintroduced.  
- Online-only prefixes from grandparent (`ver_check` remote network path, download install family) **MUST NOT** be reintroduced unless product mode changes.  
- `util_backup` is the CIAO pre-change sibling `.bak` helper — **not** a folder-archive backup verb.

### 2.3 Function documentation standards

Every non-trivial function **MUST** include a defensive header with:

- One-line purpose  
- **GENERAL PURPOSE** paragraph  
- CIAO principles applied (as relevant)  
- Protection / DO NOT SIMPLIFY note for critical helpers  
- Last reviewed date when modified  

Product-source `ALIGNMENT` / “see” comments **MUST** cite only live `docs/requirements/requirement-*.md` paths registered in `index.md`.

### 2.4 Protection Zones

Critical sections (output SSOT, install place/remove, storage resolve) **MUST** remain CIAO-Lite Protection Zones and **MUST NOT** be simplified away without explicit user redesign order.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Ship unit** | `src/nginx-cli` |
| **Domain prefix** | **`ngx_`** |
| **Bootstrap role** | Specialized from cli-template; Type 0 prefixes retained |
| **Multi-file authoring** | Optional later only if pack still yields one installable artifact and this requirement is updated |

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Prefixes encode ownership.  
- **Principle 6 – Single Point of Entry**: `app_main` stays the dispatcher.  
- **Principle 7 – Reusable function protection**: DO NOT MODIFY markers on critical helpers.  
- **Principle 20 – Protect against AI & human modification**: Visible zones.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Single file; logical modules via prefixes.  
- Domain prefix is `ngx_` on this product; do not invent a second prefix.  
- Keep `out_*` intact.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Reintroduce `fb_*` or parent sudoers/backup helpers.  
2. Flatten prefixes into bare `main` / `install` function names.  
3. Strip Protection Zones from `out_*` or install helpers.  
4. Cite templates or skills as product-source authority.

**Violating this rule is a critical modular-design regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Ship unit is a single file at `src/nginx-cli` |
| AC-2 | No `fb_` functions exist |
| AC-3 | Dispatcher is `app_main` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Dispatch |
| `requirement-shell-output-requirements` | `out_*` |
| `requirement-shell-local-self-management` | `inst_*` |
| `requirement-shell-path-and-shell-support` | `path_*` bodies |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup prefixes including `fb_*` |
| 2026-08-13 | Active 2.0.0 | cli-template: no domain prefix |
| 2026-08-15 | Active 2.1.0 | AC-1 names this ship unit `src/nginx-cli`; `ngx_` remains domain prefix |
| 2026-08-23 | Active 2.1.1 | `app_main_menu` / `app_run_command` |
| 2026-09-09 | Active 2.2.0 | `path_*` bodies → `requirement-shell-path-and-shell-support` |

---

**Last Updated**: 2026-09-09  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
