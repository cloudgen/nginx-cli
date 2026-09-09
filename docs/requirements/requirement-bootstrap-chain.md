**file**: docs/requirements/requirement-bootstrap-chain.md  
**Status**: Active (Version 4.1.0)  
**Area**: architecture  
**Key**: `requirement-bootstrap-chain`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Declare the **bootstrap chain** for this product: **A = cli-template** (frozen at `src/cli-template`) → **B = nginx-cli** (this ship unit `src/nginx-cli`). Direction is **A → B only**. Do not reverse-copy nginx-cli onto the frozen origin.

**This product does not point to selfmanaged or folder-backup as origin.** Those names are retired hops / related products only. Historical copy sources stay in status history.

**Direction is sacred:** ancestor → descendant only. Never reverse-copy this product onto frozen origin A (`src/cli-template`).

### 1.1 Human-facing

**In one sentence:** This product grew from a frozen starter (`cli-template`). Fixes go into `src/nginx-cli`, never back onto that starter.

| Box | Meaning | Example |
|-----|---------|---------|
| This product (B) | `src/nginx-cli` | edit here |
| Origin (A) | `src/cli-template` | read-only reference |
| Not this file | Domain verbs | `requirement-domain-nginx-cli` |

| Includes | Excludes |
|----------|----------|
| A → B only; no online/archive verbs from parent | Reverse-copy; treating folder-backup as origin |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/cli-template` | frozen origin | compare architecture |
| `src/nginx-cli` | this product | ship |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Share a fix | Copy from origin into this product if needed; **never** the reverse | (edit `src/nginx-cli`) |

---

## 2. Core Rules (Mandatory)

### 2.1 Direction

1. This product **is** hop **B** (`nginx-cli`, ship unit `src/nginx-cli`). Origin **A** is `cli-template` (frozen reference at `src/cli-template`). This product has **no** live parent hop to maintain.  
2. Every future edge **MUST** be **A → B** or **this product → descendant** only. Never reverse-copy B onto A.  
3. Plans **MUST NOT** copy this ship unit onto `src/cli-template` to “share fixes.”  
4. Detected reverse-copy **MUST** be treated as critical pollution (restore origin A; rebuild the descendant).  
5. Agents **MUST NOT** treat `selfmanaged` or `folder-backup` as this product’s live origin, nor run “maintain bootstrap from …” those products as standing work.  
6. Dest product law **MUST** name this product `nginx-cli`. `cli-template` appears only as origin A / frozen reference — never as this workspace’s product, ship unit, `APP_NAME`, or workspace path.

### 2.2 Chain declaration (this product)

| Field | Value |
|-------|--------|
| **Root / hop 0 (origin A)** | `cli-template` — Type 0 template; frozen reference at `src/cli-template` |
| **Immediate origin** | `cli-template` |
| **Leaf (this product B)** | `nginx-cli` |
| **Specialize mode** | Inherit Type 0 local-only architecture; **add** nginx-adm domain on B |
| **This ship unit** | `src/nginx-cli` |
| **This channel ownership** | **None** — local-only install by design |
| **This domain** | **nginx-adm setup + config request/approve** — see `requirement-domain-nginx-cli.md` |
| **Retired names (not live hops)** | `selfmanaged`, `folder-backup` — related products / historical copy sources. **Do not** name them as origin. |

### 2.3 Architecture contracts (this product keeps; inherited from A)

These are **this product’s** structural contracts, inherited from origin A. They are **not** “inherited from selfmanaged” as live law. Do not reverse-copy later B-only domain into A.

| Layer | This product (from A) |
|-------|-------------|
| Runtime | POSIX `/bin/sh`, `set -u`, explicit errors |
| Output SSOT | `out_*` family |
| Modular prefixes | `out_`, `inst_`, `util_`, `app_`, `path_`, `prompt_` |
| Domain prefix | **`ngx_`** on B (this product); origin A has none |
| Entry / dispatch | Single `app_main`; always call `app_main "$@"` at end |
| Global flags | `--quiet` / `--json` / `--debug` / `--force` / `--global` |
| Integrity companion | **Absent** (no product channel digest law) |
| Online lifecycle | **Absent** (`version-check`, `self-update`, `self-uninstall`, Type O, `SCRIPT_URL` UX) |
| Local lifecycle | **Present** — `install` / `uninstall` / `where-is-me` |
| Empty argv | **Type N** help (not Type O install-ensure) |
| Backup / restore / sudoers emit | **Absent** — never this product’s domain |
| Type 0 `submit-sudoer-request` | **Present** on B — sibling compose; not print-sudoers |

### 2.4 Surface matrix (normative for this product)

| Surface | Decision | Notes for nginx-cli |
|---------|----------|------------------------|
| `out_*` output SSOT | **Keep** | This origin’s family |
| Modular single-file design | **Keep** | Ship unit under `src/` |
| Global flags + `app_main` | **Keep** | Same contracts; no domain flags |
| Storage resolve | **Keep** | Scratch only |
| Idempotency / interactive modes | **Keep** | Lifecycle only |
| Online channel | **Absent** | Not install source; not help/about product UX |
| Type O empty argv | **Absent** | Empty argv = Type N help |
| Domain backup + restore | **Absent** | Not this product’s domain |
| Sudoers print / install-script / remove-draft | **Absent** | Not this product’s domain |
| `submit-sudoer-request` | **Present** | Type 0 compose to sibling sudoer-cli |
| Local `install` / `uninstall` / `where-is-me` | **Keep** | Local self-managed package |
| Domain / out Protection Zones | **Keep spirit** | Do not simplify `out_*` |

### 2.5 Identity (this product)

| Concern | Value |
|---------|---------|
| `APP_NAME` | `nginx-cli` |
| `VERSION` | `1.10.0` (product version SSOT in ship unit) |
| Primary install story | Local copy from running ship unit → `${USER_BIN}` (default `~/.local/bin`) |
| README one-liner | **No** `curl \| sh` channel claim |

### 2.6 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product** | `nginx-cli` |
| **Workspace** | RAM-drive first: `/dev/shm/nginx-cli` when present, else `{{PROJECTS_ROOT}}/nginx-cli` |
| **Ship unit** | `src/nginx-cli` |
| **Origin A (frozen)** | `cli-template` at `src/cli-template` — do not reverse-copy B onto A |
| **Role** | Specialized product B. Not hop 0. Not a child of selfmanaged or folder-backup. |
| **Related (not origin)** | `selfmanaged`, `folder-backup` — do not overwrite; do not maintain this product from them |

### 2.7 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: This product is B. Origin A is named once and frozen. Parent hops are not implied.  
- **Principle 4 / 20 – Over-protect**: Reverse-copy onto `src/cli-template` is a critical pollution class. Dest law must not claim this product *is* cli-template.  
- **Principle 21 – Dual policies**: Identity lives in Implementation Notes and ship-unit Config.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not invent extra host verbs beyond Active domain law.  
- **Intentional:** Type 0 inherited from A; domain SSOT on B is `requirement-domain-nginx-cli.md`.  
- **Anti-fragile:** Frozen origin A stays intact so this product and later descendants can specialize from it.  
- **Over-protect:** Registry lists online / archive / print-sudoers as absent by design. Domain is **present**.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Name `selfmanaged` or `folder-backup` as this product’s live origin or immediate parent.  
2. Reverse-copy this product (or any descendant) onto `src/cli-template`.  
3. Reintroduce `backup`, `restore`, or print-sudoers verbs without new Active requirements and explicit user order.  
4. Claim this product *is* `cli-template`, or name `src/cli-template` as this ship unit.  
5. Reintroduce online install / Type O / `SCRIPT_URL` UX without explicit user order.  
6. Drop Type 0 lifecycle while this product still inherits Type 0 from origin A.  
7. Re-add a live parent hop, or add a second Active domain SSOT, without explicit user order.

**Violating this rule is a critical bootstrap-direction regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Chain names **cli-template** as origin A (frozen); this product is **nginx-cli** (B); no live parent hop |
| AC-2 | This ship unit is `src/nginx-cli`; origin reference remains `src/cli-template` (do not reverse-copy) |
| AC-3 | Help does not list backup / restore / print-sudoers |
| AC-4 | Unknown domain verbs fail closed |
| AC-5 | Empty argv is Type N help |
| AC-6 | Product maps and class law do **not** name selfmanaged or folder-backup as origin |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-class-software-dev` | Class gate |
| `requirement-least-privilege-user` | Dest LPU (not origin A) |
| `requirement-three-layer-privilege-model` | Dest Type map / F6 |
| `requirement-privilege-prevention-set` | Dest closed walls |
| `requirement-shell-cli-interface` | Type 0 verb catalog |
| `requirement-shell-local-self-management` | Local install package |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-04,10,13** | `tests/test_cli.sh` | have | no online verbs; backup/restore/sudoers unknown |
| **TP-CLI-07** | `tests/test_cli.sh` | have | Type N empty argv |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup: selfmanaged → folder-backup (trim online) |
| 2026-08-13 | Active 2.0.0 | specialize hop; trim backup/restore/sudoers; identity **cli-template** (not host-OS setup) |
| 2026-08-13 | Active 3.0.0 | Retired live hop folder-backup; briefly named selfmanaged → cli-template |
| 2026-08-13 | Active 4.0.0 | **This product is hop 0.** No live parent. selfmanaged and folder-backup are not origins. |
| 2026-08-15 | Active 4.1.0 | Honesty: this product is B = nginx-cli; A = cli-template frozen. Dest notes no longer claim hop 0 / cli-template identity. |

---

**Last Updated**: 2026-08-15  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
