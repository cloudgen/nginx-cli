# Requirements

Authoritative specialized product law for **nginx-cli** lives here.

**Current state (2026-09-13):** Specialized **software-development** product. Left genesis. **This product is B** (`nginx-cli`). **Origin A** is `cli-template` (frozen at `src/cli-template`). Do not reverse-copy B onto A. Registry is populated — see `index.md`. Numbered list: TTY empty argv and `menu`/`main`; off-TTY empty argv stays help; invalid choice retries this layer. Login hook is an independent REQ (`requirement-login-interactive-review-hook`). Shell-rc PATH / this-login profile: `requirement-shell-path-and-shell-support`.

## Product identity (summary)

| Field | Value |
|-------|--------|
| Product / `APP_NAME` | `nginx-cli` |
| Version SSOT | `1.10.1` (ship unit hard-assign) |
| Ship unit | `src/nginx-cli` |
| Origin A (frozen) | `src/cli-template` |
| Default install | `~/.local/bin/nginx-cli` |
| Install mode | **Local-only** |
| Domain surface | **Active** — `requirement-domain-nginx-cli.md` (file-based JSON dest **and** same-product submitter) |
| Privilege peers | `requirement-least-privilege-user` · `requirement-three-layer-privilege-model` · `requirement-privilege-prevention-set` · `requirement-sudoer-json-file` · `requirement-login-interactive-review-hook` |
| Shell-rc PATH | `requirement-shell-path-and-shell-support` |
| Prompt / temp REQs | **Not added** — interactive + storage already own those surfaces |

## Class requirement gate

| Class | Required class file |
|-------|---------------------|
| software-development | `requirement-class-software-dev.md` (**Active**) |
| genesis-template | N/A — this workspace is no longer genesis |

## Purpose

- **Plan** designs work by reading and updating these docs.  
- **Implement** delivers code that **traces** to these requirements.  
- **Review** verifies delivery against requirements and CIAO checklists.

## Layout

| Path | Role |
|------|------|
| `docs/requirements/index.md` | Registry of all requirements — keep in sync |
| `docs/requirements/requirement-*.md` | CIAO-style project requirements |

## Status values

Typical: `draft` · `Active` · `approved` · `in-progress` · `done` · `deprecated` · `superseded`

## Rules

1. Never invent paths — verify on disk.  
2. Class files only via class process; non-class via create-specific process.  
3. Never dump harness inventories into this versioned surface.  
4. Online install requirements stay **absent** unless product mode is explicitly changed.  
5. Domain SSOT is **one** Active file: `requirement-domain-nginx-cli.md`. Do not add a second domain SSOT.  
6. Dest law names this product `nginx-cli`. `cli-template` is origin A only — do not retarget notes back to A, and do not reverse-copy onto `src/cli-template`.  
7. Do **not** invent a product block that is not a row in `requirement-privilege-prevention-set.md`.  
8. Do **not** add `requirement-shell-prompt` or `requirement-shell-temp-file-system` while interactive / storage remain the owners.
