# Requirements index

**Product:** nginx-cli (POSIX `/bin/sh` CLI — Type 0 lifecycle + nginx-adm request/approve domain)  
**Workspace state:** Specialized product law (left genesis); **software-development** class; **this product is B = nginx-cli**; **bootstrap origin A = cli-template** (frozen at `src/cli-template`). Online / Type O, backup / restore / print-sudoers **intentionally absent**. Type 0 **`submit-sudoer-request`** is **present**. Layered main menu (interactive zero-cli-verb and **`menu` / `main`**; off-TTY `menu` fails closed) is **present**. Non-interactive zero-cli-verb is local **`self-install`** (copy only, not a download). Menu language is **`requirement-shell-cli-language`**. Login hook is **`nginx-cli-hook`** (independent REQ; soft link → `/usr/local/bin/nginx-cli`). Shell-rc PATH / this-login profile: **`requirement-shell-path-and-shell-support`**.  
**Updated:** 2026-10-04

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack (posix-sh, local-only); dest Fence + coding-style pointers; dest Fences ship Type 0 **test-purpose** `fence-test`; layered menu + language pointers; login-hook pointer; PATH/shell-rc pointer | class | Active (1.8.4) | `requirement-class-software-dev.md` | 2026-10-04 |
| requirement-bootstrap-chain | Bootstrap A = cli-template (frozen); this product is B = nginx-cli | architecture | Active (4.1.1) | `requirement-bootstrap-chain.md` | 2026-10-04 |
| requirement-project-folder | Project layout (`src/nginx-cli` + frozen `src/cli-template`); install bins; per-process cache leaf; no durable backup deposit | architecture | Active (2.1.1) | `requirement-project-folder.md` | 2026-10-04 |
| requirement-shell-cli-interface | Shell CLI interface (lifecycle + local `self-install` + operational convert/submit + **test-purpose** `test-json-format` / `fence-test`; `menu`/`main`; setup; dual mention `enable-login-approval`; `BASHRC`; `rc-test` dual mention) | shell | Active (2.9.0) | `requirement-shell-cli-interface.md` | 2026-10-04 |
| requirement-shell-script-coding | Specialize-in home for POSIX writing lessons. Remaining mold rules apply (**PP-A-21**). **PP-A-19** / **PP-A-20**: nginx-adm is a sudoer; inbound owner stays submitter. | shell | Active (1.2.0) | `requirement-shell-script-coding.md` | 2026-08-22 |
| requirement-shell-cli-zero-arguments | Interactive zero-cli-verb = main menu; non-interactive = local `self-install` (not help, not `setup`) | shell | Active (1.3.0) | `requirement-shell-cli-zero-arguments.md` | 2026-10-04 |
| requirement-shell-cli-default-interaction | Layered TTY main menu (`menu` / `main` and interactive zero-cli-verb); off-TTY `menu` fails closed; invalid choice warns and reprints that board | shell | Active (1.3.0) | `requirement-shell-cli-default-interaction.md` | 2026-10-04 |
| requirement-shell-cli-language | Menu language: thirteen codes; persistence leaf `language`; menu chrome and selected headings | shell | Active (1.0.0) | `requirement-shell-cli-language.md` | 2026-10-04 |
| requirement-shell-local-self-management | Local `install` / `self-install` / uninstall / where-is-me; **mode 0755**; PATH companion **call site**; no online verbs | shell | Active (1.6.0) | `requirement-shell-local-self-management.md` | 2026-10-04 |
| requirement-shell-path-and-shell-support | Shell-rc PATH + this-login profile ensure (sibling unify, scoped uninstall, heal, `rc-test`) | shell | Active (1.0.0) | `requirement-shell-path-and-shell-support.md` | 2026-09-09 |
| requirement-shell-output-requirements | Central `out_*` output SSOT | shell | Active (1.1.0) | `requirement-shell-output-requirements.md` | 2026-08-15 |
| requirement-shell-modular-function-design | Single-file modular prefixes (`out_`/`inst_`/`app_`/`ngx_`); `path_*` bodies pointer | shell | Active (2.2.0) | `requirement-shell-modular-function-design.md` | 2026-09-09 |
| requirement-shell-idempotency | Re-run safety for install / uninstall; PATH / profile **bodies** pointer | shell | Active (1.3.0) | `requirement-shell-idempotency.md` | 2026-09-09 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / confirm policy | shell | Active (1.1.1) | `requirement-shell-interactive-vs-noninteractive.md` | 2026-08-23 |
| requirement-shell-cli-storage | Per-login per-process cache folder + persistence (no XDG tier; no backup deposit) | shell | Active (1.3.0) | `requirement-shell-cli-storage.md` | 2026-10-04 |
| requirement-three-layer-privilege-model | Type 0/1 map; Family 1 via sibling JSON; Family 2 `/etc/nginx-adm/sudoers`; **submit-sudoer-request**; setup MUST NOT write `/etc/sudoers.d` | architecture | Active (1.5.1) | `requirement-three-layer-privilege-model.md` | 2026-09-08 |
| requirement-sudoer-json-file | Two JSON kinds: Type 0 `type-2-switch` (`request` as nginx-adm); Type 1 setup `login-hook-elev` (Family 1 password + `--json`) | architecture | Active (1.2.0) | `requirement-sudoer-json-file.md` | 2026-08-23 |
| requirement-least-privilege-user | nginx-adm F1–F7; Family 2 `/etc/nginx-adm/sudoers`; Family 1 sibling dest; hook home only | architecture | Active (1.4.0) | `requirement-least-privilege-user.md` | 2026-09-08 |
| requirement-privilege-prevention-set | Closed catalog; setup MUST NOT write `/etc/sudoers.d`; **PREV-HOOK-SUDO** (labeled `-hook`); **PREV-EMPTY-INT** is menu or local self-install | architecture | Active (1.6.2) | `requirement-privilege-prevention-set.md` | 2026-10-04 |
| requirement-login-interactive-review-hook | Login hook: `/usr/local/bin/nginx-cli-hook` → `/usr/local/bin/nginx-cli`; setup reviews LPU rc and replaces old product-binary hook | architecture | Active (1.0.1) | `requirement-login-interactive-review-hook.md` | 2026-10-04 |
| requirement-incorrect-json-format | Dest **Fence**: incorrect JSON format; Type 0 **test-purpose** `test-json-format`; list tester `fence-test`; dest-owned `submit_app` / `submit_version` | architecture | Active (1.0.0) | `requirement-incorrect-json-format.md` | 2026-08-21 |
| requirement-domain-nginx-cli | File-based JSON dest for nginx-conf **and** same-product submitter; setup auto-queues Family 1 sudoer JSON; dest Fence; testers; login hook **points**; interactive review shows YAML | domain | Active (1.16.0) | `requirement-domain-nginx-cli.md` | 2026-09-08 |

## Surfaces by design (this product)

| Surface | Status on nginx-cli |
|---------|---------------------|
| Online install / `SCRIPT_URL` / Type O download | **Absent** |
| Local `self-install` (copy of the running script) | **Present** (non-interactive zero-cli-verb and menu 87) |
| `version-check` / `self-update` / `self-uninstall` | **Absent** |
| Automatic companion `.sha256` channel integrity law | **Absent** |
| Folder archive backup / restore / retention | **Absent** |
| Domain SSOT (`requirement-domain-*`) | **Active** — `requirement-domain-nginx-cli.md` (one current Domain SSOT) |
| print-sudoers / sudoers-install-script / remove-draft | **Absent** (setup writes Family 2 `/etc/nginx-adm/sudoers` and queues Family 1 JSON; no print verbs) |
| `submit-sudoer-request` | **Present** (Type 0 compose to sibling sudoer-cli; no `/etc` write) |
| `conf-to-json` / `json-to-conf` | **Present** (Type 0 convert dual; dest inbound is dest request JSON) |
| `menu` / `main` | **Present** (layered TTY menu; interactive zero-cli-verb is the same menu; off-TTY `menu` fails closed) |
| Menu language | **Present** — `requirement-shell-cli-language` |
| User-bin PATH / this-login `.profile` (`requirement-shell-path-and-shell-support`) | **Present** — topic-owner; login-hook stays independent |
| Type 0 `rc-test` | **Law with ship Gap** (dual-mentioned; not routed) |
| Type 1 `setup` / `remove-lpu` | **Present** (domain + LPU + three-layer) |
| `requirement-shell-prompt` / `requirement-shell-temp-file-system` | **Absent** — prompt bodies on interactive REQ; temp roots on storage REQ |

**Install mode:** **local-only** (`install` + `self-install` + `uninstall` + `where-is-me`). `self-install` is a local copy, not an online channel. Not dual-mode.

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for nginx-cli.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files — never templates/skills as behavioral authority.  
4. This versioned surface lists **requirement rows only** — do not dump templates / skills / terminologies / incidents path inventories here.  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Class gate:** software-development requires exactly one Active `requirement-class-software-dev.md` (this registry includes it).  
7. **Domain SSOT:** exactly one Active file — `requirement-domain-nginx-cli.md`. Type 0 interface **points here** for domain verbs. LPU / three-layer / prevention / **login-hook** are architecture peers, not a second domain SSOT. PATH / this-login profile is **`requirement-shell-path-and-shell-support`** (not the login-hook REQ).  
8. **Do not reintroduce** backup, restore, print-sudoers, or online install without explicit user order and registry update. Local `self-install` is the copy verb, not a download channel.  
9. **Prevention set:** `requirement-privilege-prevention-set.md` is the closed catalog of what this product **blocks** and what it **must not block**. Do **not** invent a wall that is not a row in that file.  
10. **Dest Fence:** dest **Fence** is incorrect JSON format (`requirement-incorrect-json-format`). Dest tables still print and point at that REQ. Dest Fences **MUST** ship Type 0 **test-purpose** `fence-test`. Help **MUST** list testers apart from operational verbs. **MUST NOT** invent an extra dest fence.  
11. Do **not** add `requirement-shell-prompt` or `requirement-shell-temp-file-system` unless interactive / storage coverage is shown hollow.

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
