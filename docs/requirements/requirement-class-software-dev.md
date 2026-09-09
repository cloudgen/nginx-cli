**file**: docs/requirements/requirement-class-software-dev.md  
**Status**: Active (Version 1.8.3 – dest Fence + fence-test + coding-style + menu + login-hook pointer + PATH/shell-rc pointer)  
**Area**: class  
**Key**: `requirement-class-software-dev`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Declare this workspace as a **software-development** project class and hold the **residual collection** of software-engineering stack facts **not already owned** by more specific Active peer requirements: primary language, toolchain policy, package/test tooling, and runtime OS family.

This file is **class law + residual SSOT**, not a second copy of Type 0 lifecycle, output, or storage tables (those stay on peer requirements).

### 1.1 Human-facing

**In one sentence:** This workspace is a shippable POSIX CLI; class facts live here, dest JSON fences and writing style live on pointed peers.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Work in this product tree | `src/nginx-cli` |
| Dest | nginx-adm reviews waiting JSON | `/var/nginx-cli/config-request` |
| Not this file | Fence meaning, writing-style body | `requirement-incorrect-json-format` · `requirement-shell-script-coding` |

| Includes | Excludes |
|----------|----------|
| Class membership; residual stack; pointers | Dest Fence match rules; POSIX writing body |

| Surface | What you open | What for |
|---------|---------------|----------|
| `docs/requirements/index.md` | registry | live law list |
| `src/nginx-cli` | ship unit | product |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Ask what class this is | software-development | (read this file) |

---

## 2. Core Rules (Mandatory)

### 2.0 Project class membership

1. **MUST** treat this workspace as **software-development** (shippable software), not genesis-template and not server-maintenance.  
2. **MUST** use basename **`requirement-class-software-dev.md`** as the sole Active class-law file for this class.  
3. **MUST NOT** register an Active `requirement-class-server-maintenance.md` while class is software-development.  
4. **MUST** retain portable harness knowledge; specialized product knowledge lives in this and peer `requirement-*.md` files.  
5. **MUST** apply software-development SSOT/gate posture when claimed (identity, ship unit, precommit when git is used — as applicable).  
5a. When git is used on a **multi-vault host**, **MUST** treat forge push identity as **product repository-user SSOT** (Config `REPO_USER` / project-repository owner), not ambient default SSH face: agents **MUST** run a pre-git report and bind SSH transport (activate or one-shot identity) before push. Host vault basenames are **not** product law.  
6. **MUST NOT** invent hollow product docs solely to look specialized; collect real values or defer explicitly.

### 2.1 Residual collection principle (SSOT hygiene)

7. **MUST** treat this file as the **default home** for software-stack facts **not owned** by another Active requirement.  
8. **MUST NOT** duplicate full normative tables that already live in a more specific Active requirement. Prefer a **one-line pointer** to the peer requirement key.  
9. When a new specialized requirement **takes ownership** of a topic previously only listed here, **MUST** update this file in the **same change**: remove or shrink the residual entry and point to the new owner.  
10. **MUST NOT** leave contradictory stack facts across this file and peer requirements.

### 2.2 Programming language(s)

11. **MUST** declare at least one **primary programming language** for the ship unit.  
12. **SHOULD** list secondary languages only when they are real product law.  
13. **MUST** state whether the product is primarily: interpreted, compiled, polyglot, or package-multi-language.  
14. **MUST NOT** freeze a marketing product name as if it were the language name.

### 2.3 Compilers, interpreters, and toolchains

15. **MUST** declare the **target toolchain class** used to build or run the product.  
16. **MUST** state version policy as one of: unconstrained · minimum version · range · pinned.  
17. **SHOULD** record whether cross-compilation is in scope.  
18. **MUST** fail closed in CI/docs claims: do not claim “supports all compilers” without tests or explicit unconstrained policy.

### 2.4 Project / package / build tools

19. **MUST** declare the **primary project or package tool** used for dependencies and builds.  
20. **MUST** declare how dependencies are resolved when the ecosystem supports lockfiles.  
21. **SHOULD** name the test runner and linter/formatter **classes** when they are project law.  
22. **MUST NOT** require a secret token or private registry password in this file.

### 2.5 Runtime and platform (residual)

23. **MUST** declare the intended **primary runtime/OS family** when not fully owned by another architecture requirement.  
24. **SHOULD** declare minimum CPU/arch support only when it is real product law.  
25. **MUST** separate **developer machine** toolchain requirements from **end-user runtime** requirements when they differ.

### 2.6 No-hardcode / dual policy (class file)

26. **MUST NOT** hard-code a single product/app brand, one org’s production hostname, or personal owner identity as universal core law.  
27. **MUST** put live product name, repo slug, and concrete stack choices in **Implementation Notes** after collection — complete when Status is Active.  
28. **MUST NOT** store secrets, PATs, or toy credentials in this file.

### 2.7 Implementation Notes (this project)

| Field | Value (nginx-cli) |
|-------|---------------------|
| **Project display name** | `nginx-cli` |
| **Project class** | software-development |
| **Class requirement basename** | `requirement-class-software-dev.md` |
| **Primary language(s)** | `posix-sh` (`/bin/sh`) |
| **Language role** | primary only — single-file shell ship unit under `src/` |
| **Execution model** | **interpreted** — no compile step |
| **Toolchain / interpreter** | POSIX `/bin/sh` (dash/bash-as-sh compatible subset); no compiler |
| **Toolchain version policy** | **unconstrained** among POSIX sh implementations that pass product tests when present |
| **Cross-compile in scope?** | no |
| **Primary project/package tool** | **none** — no language module system; ship unit is the source |
| **Lockfile policy** | not used |
| **Test runner** | POSIX shell suite under `tests/` when present (`tests/run.sh` pattern) |
| **Linter/formatter** | none as project law (shellcheck optional for maintainers) |
| **Primary runtime / OS family** | POSIX Linux (and compatible UNIX where `/bin/sh` + `mktemp` + `date` exist) |
| **Architectures supported** | any arch with POSIX sh and the external tools the script invokes |
| **Git surface** | used when product is published |
| **Ship unit / install** | yes — `src/nginx-cli` → `${USER_BIN}/nginx-cli` (default `~/.local/bin/nginx-cli`); **local-only** install (no online channel) |
| **Product version SSOT** | `VERSION="1.10.0"` hard-assign in `src/nginx-cli` |
| **Bootstrap origin** | `cli-template` (frozen at `src/cli-template`) — this product is B. No live parent hop. |

**Residual ownership table:**

| Topic | Owner | Notes |
|-------|-------|--------|
| Project class membership | **this file** | Fixed |
| Primary language + toolchain policy | **this file** | posix-sh, unconstrained |
| Package/build tool + lockfile | **this file** | none / not used |
| Bootstrap lineage / keep-trim | `requirement-bootstrap-chain` | A = cli-template (frozen); this product is B |
| Project layout / ship path | `requirement-project-folder` | `src/` + bin targets |
| Type 0 CLI surface / flags / dispatch | `requirement-shell-cli-interface` | Do not duplicate |
| Empty argv Type N | `requirement-shell-cli-zero-arguments` | TTY numbered list; off-TTY help; never install |
| Numbered TTY list (`menu`/`main`) | `requirement-shell-cli-default-interaction` | Same list as TTY empty argv |
| Local self-managed lifecycle | `requirement-shell-local-self-management` | install / uninstall / where-is-me; PATH companion **call site** |
| PATH / this-login profile / shell-rc sibling unify | `requirement-shell-path-and-shell-support` | Do not duplicate; login-hook stays a peer |
| Output SSOT (`out_*`) | `requirement-shell-output-requirements` | Do not duplicate |
| Scratch/cache storage resolve | `requirement-shell-cli-storage` | Do not duplicate |
| Idempotency / re-run safety | `requirement-shell-idempotency` | Do not duplicate |
| Interactive vs non-interactive | `requirement-shell-interactive-vs-noninteractive` | Do not duplicate |
| Modular prefixes / single-file layout | `requirement-shell-modular-function-design` | Do not duplicate |
| Privilege / Type map / F6 Cmnds / submit-sudoer-request workflow | `requirement-three-layer-privilege-model` | two families; no print-sudoers verb; Type 0 compose |
| JSON sudoer file (grant body) | `requirement-sudoer-json-file` | `nginx-cli request` as `nginx-adm` only |
| LPU identity F1–F7 | `requirement-least-privilege-user` | nginx-adm 1999; inbound 2770 |
| Prevention catalog | `requirement-privilege-prevention-set` | closed block / must-remain-open |
| Folder archive backup / restore / retention | **intentionally absent** | Not this product’s domain (sibling folder-backup) |
| Domain surface (`requirement-domain-*`) | `requirement-domain-nginx-cli` | file-based JSON dest **and** same-product submitter (`request`); compose to sudoer-cli |
| Login-hook snippet + labeled symlink | `requirement-login-interactive-review-hook` | `/usr/local/bin/nginx-cli-hook` → `/usr/local/bin/nginx-cli`; setup replaces old hook; domain **points** |
| Dest Fence: incorrect JSON format | `requirement-incorrect-json-format` | Independent Fence REQ; dest table still prints; Type 0 `test-json-format`; list tester `fence-test` |
| Coding-style related REQ | `requirement-shell-script-coding` | Specialize-in home; remaining mold rules apply (**PP-A-21**) |
| Prompt helper bodies / temp leaves | **intentionally absent as extra REQs** | interactive + storage |
| Online install / remote self-management / companion checksum | **intentionally absent** | Not this product’s channel |

---

## 3. Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: Class and stack choices are explicit, not assumed from folder names.  
- **CIAO Principle 5 – SSOT**: Residual stack facts have one home until specialized requirements take ownership.  
- **CIAO Principle 1 – Caution**: Toolchain policies are declared; agents do not invent compilers or online install.  
- **CIAO Principle 21 – Dual Policies**: Portable core; filled Implementation Notes.  
- **CIAO Principle 4 (O) + Principle 20**: Protection Rule against dual stack SSOTs and wrong-class pollution.

---

## 4. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Assume toolchain and package tools are missing until declared and verified.  
- **Intentional**: Residual collection is deliberate — not a dump of every possible tool.  
- **Anti-fragile**: Unconstrained POSIX sh policy survives multi-env runs when tests pass.  
- **Over-protect**: Protection rule prevents dual stack SSOTs and genesis/class confusion.

---

## 5. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Delete this file while the workspace remains **software-development** with other Active product requirements.  
2. Rename the specialized basename away from `requirement-class-software-dev.md` without an explicit class-model change.  
3. Hard-code secrets, personal owner identity, or production host FQDNs into core rules as universal law.  
4. Duplicate full peer requirement bodies into this residual section.  
5. Leave Implementation Notes as hollow stubs when Status claims Active.  
6. Reintroduce Active **online-install** / remote **self-update** / **self-uninstall** / channel **checksum** law without explicit user order (product is **local-only** by design).  
7. Treat this file as server-maintenance allowlist law, or register an Active server-maintenance class file in parallel.  
8. Invent a second primary language SSOT that contradicts peer modular/CLI requirements.

**Violating any of these is considered a critical regression.**

---

## 6. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Active registered `requirement-class-software-dev.md` matches software-development class |
| AC-2 | Primary language + toolchain policy + package tool declared in Implementation Notes (complete) |
| AC-3 | Residual ownership table honest: no silent dual SSOT with peer REQs |
| AC-4 | Core rules remain free of frozen secret/host hardcodes |
| AC-5 | No class file conflict with `requirement-class-server-maintenance` |
| AC-6 | Ship unit identity (posix-sh single-file, local install) consistent with peer shell REQs |
| AC-7 | Online install package **absent** from Active registry by design |

---

## 7. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-bootstrap-chain` | Origin A = cli-template; this product is B |
| `requirement-domain-nginx-cli` | Domain SSOT (nginx-conf request/approve) |
| `requirement-login-interactive-review-hook` | Labeled symlink + snippet; setup reviews/replaces old hook |
| `requirement-incorrect-json-format` | Dest Fence |
| `requirement-shell-script-coding` | Coding-style related REQ |
| `requirement-least-privilege-user` | nginx-adm F1–F7 |
| `requirement-three-layer-privilege-model` | Type map + Tables A/B/C + submit workflow |
| `requirement-sudoer-json-file` | JSON sudoer file body |
| `requirement-privilege-prevention-set` | Closed prevention catalog |
| `requirement-project-folder` | Layout and install locations |
| `requirement-shell-cli-interface` | Command surface, flags, dispatch |
| `requirement-shell-cli-zero-arguments` | Type N empty argv |
| `requirement-shell-cli-default-interaction` | Numbered list on `menu`/`main` |
| `requirement-shell-local-self-management` | Local install lifecycle |
| `requirement-shell-path-and-shell-support` | PATH / this-login profile / sibling unify |
| `requirement-shell-output-requirements` | `out_*` SSOT |
| `requirement-shell-cli-storage` | Scratch/cache resolve |
| `requirement-shell-idempotency` | Re-run safety |
| `requirement-shell-interactive-vs-noninteractive` | Mode policy |
| `requirement-shell-modular-function-design` | Prefixes / single-file modularity |
| `docs/requirements/index.md` | Registry SSOT |

---

## 8. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Specialized class law for folder-backup (left genesis; bootstrap trim from selfmanaged) |
| 2026-08-13 | Active 1.1.0 | Retarget to cli-template; drop domain/privilege residual owners |
| 2026-08-13 | Active 1.2.0 | Bootstrap origin = selfmanaged; folder-backup hop retired (no longer maintain bootstrap from it) |
| 2026-08-13 | Active 1.3.0 | This product is hop 0; selfmanaged is not origin |
| 2026-08-15 | Active 1.4.0 | Notes retarget to nginx-cli 1.1.0; domain residual owner; drop skill-name catalog from §2.0.5a |
| 2026-08-15 | Active 1.5.0 | Residual owners: LPU / three-layer / prevention; no prompt/temp REQs |
| 2026-08-15 | Active 1.6.0 | Residual owner: JSON sudoer file; VERSION 1.2.0 |
| 2026-08-15 | Active 1.7.0 | Domain residual: JSON dest + same-product submitter |
| 2026-08-21 | Active 1.8.0 | Dest Fence pointer; Type 0 fence-test; coding-style pointer |
| 2026-08-23 | Active 1.8.1 | Residual pointer: `menu`/`main` on `requirement-shell-cli-default-interaction` |
| 2026-09-08 | Active 1.8.2 | Residual pointer: login-hook snippet on `requirement-login-interactive-review-hook` |

---

**Last Updated**: 2026-09-09 (1.8.3 — PATH/shell-rc residual pointer)  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
