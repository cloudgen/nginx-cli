# Requirements index

**Product:** nginx-cli (POSIX `/bin/sh` CLI — Type 0 lifecycle + nginx-adm request/approve domain)  
**Workspace state:** Specialized product law (left genesis); **software-development** class; **this product is B = nginx-cli**; **bootstrap origin A = cli-template** (frozen at `src/cli-template`). Online / Type O, backup / restore / print-sudoers **intentionally absent**. Type 0 **`submit-sudoer-request`** is **present**.  
**Updated:** 2026-08-15

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack (posix-sh, local-only); multi-vault forge push identity §2.0.5a | class | Active (1.7.0) | `requirement-class-software-dev.md` | 2026-08-15 |
| requirement-bootstrap-chain | Bootstrap A = cli-template (frozen); this product is B = nginx-cli | architecture | Active (4.1.0) | `requirement-bootstrap-chain.md` | 2026-08-15 |
| requirement-project-folder | Project layout (`src/nginx-cli` + frozen `src/cli-template`); install bins; no durable backup deposit | architecture | Active (2.1.0) | `requirement-project-folder.md` | 2026-08-15 |
| requirement-shell-cli-interface | Shell CLI interface (Type 0 commands, flags, dispatch; domain pointer; `submit-sudoer-request`; convert) | shell | Active (2.4.0) | `requirement-shell-cli-interface.md` | 2026-08-15 |
| requirement-shell-cli-zero-arguments | Empty argv Type N help (local-only) | shell | Active (1.1.0) | `requirement-shell-cli-zero-arguments.md` | 2026-08-15 |
| requirement-shell-local-self-management | Local install / uninstall / where-is-me; **mode 0755** multi-user | shell | Active (1.4.0) | `requirement-shell-local-self-management.md` | 2026-08-15 |
| requirement-shell-output-requirements | Central `out_*` output SSOT | shell | Active (1.1.0) | `requirement-shell-output-requirements.md` | 2026-08-15 |
| requirement-shell-modular-function-design | Single-file modular prefixes (`out_`/`inst_`/`app_`/`ngx_`) | shell | Active (2.1.0) | `requirement-shell-modular-function-design.md` | 2026-08-15 |
| requirement-shell-idempotency | Re-run safety for install / uninstall | shell | Active (1.2.0) | `requirement-shell-idempotency.md` | 2026-08-15 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / confirm policy | shell | Active (1.1.0) | `requirement-shell-interactive-vs-noninteractive.md` | 2026-08-15 |
| requirement-shell-cli-storage | Scratch/cache resolve (no backup staging) | shell | Active (1.2.0) | `requirement-shell-cli-storage.md` | 2026-08-15 |
| requirement-three-layer-privilege-model | Type 0/1 map; F6 two families; **submit-sudoer-request** workflow; no print-sudoers | architecture | Active (1.2.0) | `requirement-three-layer-privilege-model.md` | 2026-08-15 |
| requirement-sudoer-json-file | JSON sudoer file: grant is **`nginx-cli request`** as `nginx-adm` only; no OS tools / F6 verbs | architecture | Active (1.0.0) | `requirement-sudoer-json-file.md` | 2026-08-15 |
| requirement-least-privilege-user | nginx-adm F1–F7; home `/etc/nginx-adm`; F5 `/var/nginx-cli/` inbound 2770 + F4 views | architecture | Active (1.1.0) | `requirement-least-privilege-user.md` | 2026-08-15 |
| requirement-privilege-prevention-set | Closed catalog; dest inbound is JSON; convert never dest/queue | architecture | Active (1.4.0) | `requirement-privilege-prevention-set.md` | 2026-08-15 |
| requirement-domain-nginx-cli | File-based JSON dest for nginx-conf **and** same-product submitter; convert dual; compose to sudoer-cli | domain | Active (1.11.0) | `requirement-domain-nginx-cli.md` | 2026-08-15 |

## Surfaces by design (this product)

| Surface | Status on nginx-cli |
|---------|---------------------|
| Online install / `SCRIPT_URL` / Type O empty-argv install-ensure | **Absent** |
| `version-check` / `self-update` / `self-uninstall` | **Absent** |
| Automatic companion `.sha256` channel integrity law | **Absent** |
| Folder archive backup / restore / retention | **Absent** |
| Domain SSOT (`requirement-domain-*`) | **Active** — `requirement-domain-nginx-cli.md` (one current Domain SSOT) |
| print-sudoers / sudoers-install-script / remove-draft | **Absent** (setup writes host fragments; no print verbs) |
| `submit-sudoer-request` | **Present** (Type 0 compose to sibling sudoer-cli; no `/etc` write) |
| `conf-to-json` / `json-to-conf` | **Present** (Type 0 convert dual; dest inbound is dest request JSON) |
| Type 1 `setup` / `remove-lpu` | **Present** (domain + LPU + three-layer) |
| `requirement-shell-prompt` / `requirement-shell-temp-file-system` | **Absent** — prompt bodies on interactive REQ; temp roots on storage REQ |

**Install mode:** **local-only** (`install` + `uninstall` + `where-is-me`). Not dual-mode.

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for nginx-cli.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files — never templates/skills as behavioral authority.  
4. This versioned surface lists **requirement rows only** — do not dump templates / skills / terminologies / incidents path inventories here.  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Class gate:** software-development requires exactly one Active `requirement-class-software-dev.md` (this registry includes it).  
7. **Domain SSOT:** exactly one Active file — `requirement-domain-nginx-cli.md`. Type 0 interface **points here** for domain verbs. LPU / three-layer / prevention are architecture peers, not a second domain SSOT.  
8. **Do not reintroduce** backup, restore, print-sudoers, or online install without explicit user order and registry update.  
9. **Prevention set:** `requirement-privilege-prevention-set.md` is the closed catalog of what this product **blocks** and what it **must not block**. Do **not** invent a wall that is not a row in that file.  
10. Do **not** add `requirement-shell-prompt` or `requirement-shell-temp-file-system` unless interactive / storage coverage is shown hollow.

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
