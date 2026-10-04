**file**: docs/requirements/requirement-shell-cli-storage.md  
**Status**: Active (Version 1.3.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-storage`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for nginx-cli **cache** and **persistence**.

Cache is a **per-login per-process** folder. Persistence is a small durable directory for this login, including the menu **language** leaf. Neither is a backup deposit and neither is an install bin.

**Out of scope:** Binary install paths (`USER_BIN` / `GLOBAL_BIN`). PATH shell-rc (`requirement-shell-path-and-shell-support`). Waiting nginx JSON under `/var/nginx-cli`.

### 1.1 Human-facing

**In one sentence:** Each run gets its own cache folder; the language choice is stored beside it, under this login, and is not deleted with the cache.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Cache for this process, plus a language file that stays | `nginx-cli about` |
| Not this file | Waiting nginx JSON | `/var/nginx-cli/config-request` |

| Includes | Excludes |
|----------|----------|
| Cache tiers, persistence directory, about labels | Durable backup deposit; `XDG_CACHE_HOME` as a tier; executing a binary from the cache |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/nginx-cli` | `util_resolve_storage` | cache folder used |
| `src/nginx-cli` | `util_resolve_persistent_storage` | `${HOME}/.local/nginx-cli` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| See the folders | about names used, preferred, fallbacks, and persistence | `nginx-cli about` |

## Under command line for normal user only

On Termux, Git Bash, or Windows cmd, cache **MUST** still be per-login per-process. **MUST NOT** write host `/var` waiting folders from Type 0 just because that class has no root. Git Bash uses the gitbash tier table below.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Cache leaf names

| Kind | Shape |
|------|--------|
| Volatile (preferred and Linux/Mac `/tmp` tier) | `cache-${APP_NAME}-${login}-$$` |
| Home tier | `cache-${APP_NAME}-$$` (no login segment) |

`login` is the sanitized `USERNAME`: any character outside `[A-Za-z0-9._-]` becomes `_`. Empty becomes `unknown`.

### 2.2 Tier order

Try preferred, then 1st fallback, then 2nd fallback when that host has one. A tier that cannot be created is **silent**. Only when every tier fails: `out_die` with exactly `Cannot create cache folder`.

| Host | Preferred | 1st fallback | 2nd fallback |
|------|-----------|--------------|--------------|
| Linux (default) | `/dev/shm/cache/cache-${APP_NAME}-${login}-$$` | `/tmp/cache/cache-${APP_NAME}-${login}-$$` | `${HOME}/.cache/cache-${APP_NAME}-$$` |
| Git Bash | `/tmp/cache/cache-${APP_NAME}-${login}-$$` | `${HOME}/AppData/Local/Temp/cache-${APP_NAME}-$$` | *(none — do not print a 2nd line)* |
| Mac | `/tmp/cache/cache-${APP_NAME}-${login}-$$` | `${HOME}/Library/Caches/cache-${APP_NAME}-$$` | `${HOME}/cache/cache-${APP_NAME}-$$` |

Host kind: `NGINX_CLI_CACHE_HOST=linux|gitbash|mac` wins when set to one of those three. Otherwise `MSYSTEM` or `uname` (`Darwin` = mac, `MINGW*`/`MSYS*` = gitbash, else linux).

`NGINX_CLI_CACHE_SKIP=preferred` skips the preferred tier with **no** warning.

Parents `/dev/shm/cache` and `/tmp/cache` **MUST** be created mode **1777** when this process can. The leaf **MUST** be mode **0700**.

**MUST NOT** use `XDG_CACHE_HOME` or a caller-supplied `STORAGE_DIR` as a tier. **MUST NOT** execute a binary from the cache folder.

### 2.3 Persistence

Path: `${HOME}/.local/${APP_NAME}`.

**MUST NOT** be `*/.local/bin`. Create it or `out_die` with `Cannot create persistence storage`. The language leaf is `${HOME}/.local/${APP_NAME}/language` (one line, mode **0600**). Owner of that leaf’s contents: `requirement-shell-cli-language`.

### 2.4 Wire and about

| Surface | Requirement |
|---------|-------------|
| `app_main` | `EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)`; `STORAGE_DIR` is the **1st fallback** path (not the used path); resolve persistence; export `EFFECTIVE_STORAGE_DIR`, `STORAGE_DIR`, `PERSISTENT_STORAGE_DIR`; `TMPDIR=${EFFECTIVE_STORAGE_DIR}` |
| Human about | Labels: **Cache folder used**, **Cache folder (preferred)**, **Cache folder (1st fallback)**, **Cache folder (2nd fallback)** only when that path is non-empty, **Persistence storage**. **MUST NOT** say `Storage (effective` or `Storage (fallback`. |
| JSON about | `cache_used`, `cache_preferred`, `cache_fallback`, `cache_fallback_2` (empty string when none), `persistence_storage`, and keep `effective_storage` (same as used) and `storage_dir` (same as 1st fallback) |

### 2.5 Implementation Notes (this project)

| Item | Live value |
|------|------------|
| **Product** | `nginx-cli` |
| **Resolver** | `util_resolve_storage` plus `util_preferred_cache_dir`, `util_fallback_cache_dir`, `util_fallback2_cache_dir`, `util_cache_try_dir` |
| **Persistence** | `util_resolve_persistent_storage` |
| **Not used for** | Durable `/var/backup`; running programs |

### 2.6 Why This Requirement Exists (CIAO)

- **Caution:** One process cannot read another process’s cache leaf.  
- **Intentional:** Host tables are explicit. A missing tier stays quiet.  
- **Anti-fragile:** Linux without `/dev/shm` still gets `/tmp/cache`, then the home leaf.  
- **Over-protect:** No shared world-writable leaf; parents of the volatile trees are sticky `1777`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Volatile first, home last.  
- Silence on a skipped tier. Loud only when nothing can be created.  
- Persistence is not the cache and not the install bin.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Drop `${login}` or `$$` from a volatile leaf.  
2. Warn when a tier is skipped.  
3. Treat `XDG_CACHE_HOME` or `STORAGE_DIR` as a tier.  
4. Label about lines `Storage (effective)` or `Storage (fallback)`.  
5. Execute a binary stored in the cache folder.  
6. Put the language file inside the cache folder.  
7. Treat `/var/backup` as a product storage path.

**Violating this rule is a critical storage isolation regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Linux preferred path contains `/dev/shm/cache/cache-nginx-cli-` |
| AC-2 | `NGINX_CLI_CACHE_SKIP=preferred` uses `/tmp/cache` and does not warn |
| AC-3 | Git Bash JSON `cache_fallback_2` is empty and human about omits the 2nd fallback line |
| AC-4 | Chosen leaf mode is `0700` |
| AC-5 | Persistence directory is `${HOME}/.local/nginx-cli` |
| AC-6 | JSON about has `cache_used`, `cache_preferred`, `cache_fallback`, `cache_fallback_2`, `persistence_storage`, `effective_storage`, `storage_dir` |
| AC-7 | Human about does not contain `Storage (effective` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-project-folder` | Path classes |
| `requirement-shell-cli-language` | Language leaf inside persistence |
| `requirement-shell-cli-interface` | About fields |
| `requirement-shell-local-self-management` | Install staging under `TMPDIR` |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP-ID | Test | Status |
|-------|------|--------|
| **TP-CLI-06** | `tests/test_cli.sh` | have (JSON cache fields; preferred shape; no CHECKSUM) |
| **TP-CLI-12** | `tests/test_cli.sh` | have (tiers, mode 0700, skip, gitbash, human labels) |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup staging |
| 2026-08-15 | Active 1.2.0 | Scratch resolver in `src/nginx-cli` |
| 2026-10-04 | Active 1.3.0 | Per-login per-process cache tiers; persistence; no XDG tier |

---

**Last Updated**: 2026-10-04  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
