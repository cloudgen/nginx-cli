**file**: docs/requirements/requirement-shell-script-coding.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-script-coding`  
**id**: RQ-SHELL-SCRIPT-CODING  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **specialize-in home** for how the nginx-cli POSIX `/bin/sh` ship unit is written.

**Intention:** without this file, agents bring portable learned lessons **raw** and treat them as this product’s law. With this file, those lessons are **adopted here**, **pointed** at a peer requirement that already owns the slice, or **refused**.

This file is **not** a second copy of output, prefix, TTY, or dest JSON fence tables.

### 1.1 Human-facing

**In one sentence:** How this program is written lives here so agents do not paste portable style into `src/nginx-cli` as if it were already law.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | One POSIX script | `src/nginx-cli` |
| The other role | Peer files own slices | `out_*` on the output requirement |
| Not this file | Dest JSON fences, domain verbs | `requirement-incorrect-json-format` |

| Includes | Excludes |
|----------|----------|
| Shebang; headers; respect working code; no `\|\|{}` / `&&{}`; ALIGNMENT cites live requirements only | Duplicating `out_*`, prefix tables, TTY measure, dest Fence meaning |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/nginx-cli` | ship unit | the code this style governs |
| `docs/requirements/index.md` | registry | this row + peers |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Change a helper | Follow this file and the peers it points at. Do not import a portable lesson that this product did not adopt. | (edit `src/nginx-cli`) |

---

## Design-time verification

| Gate | Artifact | Phase |
|------|----------|-------|
| Style / writing law | **n/a** — review-time; no unique TP family | Design |
| Indirect smoke | `TP-CLI-01` (`sh -n`) | Proof |

---

## 2. Core Rules (Mandatory)

### 2.0 Specialize-in home (sacred)

1. **MUST** treat this file as the product home for portable POSIX writing lessons.  
2. **MUST NOT** apply a portable coding lesson as product law unless this file **adopts** it or a **pointed peer** already owns it.  
3. **MUST NOT** skip this file and “just follow the coding skill.”  
4. When a new lesson is learned and this product should keep it, **MUST** specialize it **here** (or move ownership to the correct peer) in the **same change**.  
5. **MUST NOT** duplicate full normative tables that live on peer requirements.

### 2.1 Interpreter and portability

6. **MUST** use `#!/bin/sh` on the ship unit.  
7. **MUST** stay in the POSIX `/bin/sh` subset that product tests pass (dash / bash-as-sh).  
8. **MUST NOT** add bashisms as default style.

### 2.2 Function headers and Protection Zones

9. Non-trivial functions **MUST** carry a defensive header.  
10. Critical sections (output printer, install place/remove, dest fence check) **MUST** remain Protection Zones.  
11. **MUST NOT** strip headers or Protection Zones to “clean up” working code.

### 2.3 Control flow and respect for working code

12. New or modified control flow **MUST** use explicit `if` / `then` / `else` / `fi`. **MUST NOT** use `command \|\| { … }` or `command && { … }` except already-stable one-liners inside Protection Zones.  
13. **MUST NOT** rewrite a working function for style. Touch it for a bug, a requirement violation, or an explicit redesign.

### 2.4 Product-source citation

14. Product-source `ALIGNMENT` / “see” comments **MUST** cite only live `docs/requirements/requirement-*.md` rows registered in `index.md`.  
15. **MUST NOT** paste template or skill basenames into the ship unit as behavioral authority.

### 2.5 Nounset defaults

16. Under `set -u`, every bare expansion on a live path **MUST** have a prior default or arity check.  
17. **MUST** default `HOME` (or the approved substitute) **before** any `${HOME}/…` path.

### 2.6 Elevation examples (writing)

18. **MUST NOT** paste `sudo -n` into the ship unit, help, or examples unless a live privilege requirement **names** the NOPASSWD grant. First-time `setup` uses password `sudo` or an already-root session.  
19. Type 0 **test-purpose** testers **MUST NOT** require `sudo`. If a tester wraps chmod/chown of a **local test folder**, it **MUST** skip sudo when this login already owns the path.

### 2.7 Pointed peers (do not duplicate)

| Slice | Owner | This file |
|-------|-------|-----------|
| `out_*` printer, JSON/quiet | `requirement-shell-output-requirements` | Point only |
| Function prefixes (`out_`, `inst_`, `app_`, `ngx_`) | `requirement-shell-modular-function-design` | Point only |
| Interactive vs non-interactive; `[ -t` **outside** functions | `requirement-shell-interactive-vs-noninteractive` | Point only |
| Re-run install/uninstall | `requirement-shell-idempotency` | Point only |
| Dest JSON Fence | `requirement-incorrect-json-format` | Point only |
| Scratch/cache roots | `requirement-shell-cli-storage` | Point only |

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Ship unit** | `src/nginx-cli` |
| **Primary language** | posix-sh (`#!/bin/sh`) |
| **Linter / formatter as law** | **none** — `shellcheck` optional for maintainers |
| **Domain prefix** | `ngx_` |
| **Adopted portable lessons** | POSIX shebang; full headers; Protection Zones; explicit `if`; respect working code; live-requirement ALIGNMENT; HOME-before-paths; no raw `sudo -n` on testers |
| **Refused portable lessons** | Online-install / `curl\|sh` Type O empty-argv; remote self-update; inbound `chown` to nginx-adm; inventing `nginx-ctl` |
| **In-tool sudo-command REQ** | **absent** — testers do not sudo; Type 1 password `sudo` re-exec stays on the three-layer requirement |

### 2.9 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: Writing style is chosen here, not assumed from a portable skill.  
- **CIAO Principle 5 – SSOT**: One home for specialized writing lessons; peers keep their slices.  
- **CIAO Principle 20 / CIAO-Lite O**: Protection Zones and “do not rewrite working code” stay product law.  
- **CIAO Principle 21 – Dual Policies**: Portable lessons stay in molds/skills; this file is complete product law.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Assume a missing coding-style file means portable lessons will leak in raw.  
- **Intentional**: Adopt, point, or refuse — never silent import.  
- **Anti-fragile**: POSIX subset + respect working code.  
- **Over-protect**: This file exists so the next agent cannot treat a coding skill as nginx-cli law.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Delete this file while the workspace remains software-development with a POSIX ship unit.  
2. Apply a portable writing lesson as product law without adopting it here or pointing at the owning peer.  
3. Duplicate full `out_*`, prefix, TTY, or dest Fence tables into this file.  
4. Rewrite working functions for style.  
5. Cite templates or skills as ship-unit ALIGNMENT.  
6. Paste `sudo -n` as default elev for nginx-cli dest verbs.  
7. Change the shebang away from `#!/bin/sh` without an explicit product-language change.  
8. Invent `requirement-shell-sudo-command` solely so testers can `sudo`.

**Violating any of these is a critical regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry |
| `docs/requirements/requirement-class-software-dev.md` | Class MUST + residual pointer |
| `docs/requirements/requirement-shell-modular-function-design.md` | Prefixes |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_*` |
| `docs/requirements/requirement-incorrect-json-format.md` | Dest Fence |
| `src/nginx-cli` | Ship unit |

**Last Updated**: 2026-08-21  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
