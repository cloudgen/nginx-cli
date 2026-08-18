**file**: docs/requirements/requirement-least-privilege-user.md  
**Status**: Active (Version 1.1.0)  
**Area**: architecture  
**Key**: `requirement-least-privilege-user`  
**id**: RQ-LEAST-PRIVILEGE-USER  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the dedicated **least-privilege-approver** account **nginx-adm**: identity, home vs affected folders, F4 views, create, and remove. That account is the **approver** in the nginx-conf request/approve machine owned by `requirement-domain-nginx-cli.md`. Elev Tables A/B/C and both product sudoers fragments live in `requirement-three-layer-privilege-model.md`. What create/teardown **blocks** vs what must stay open after elev is owned by `requirement-privilege-prevention-set.md`.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Role

1. The product **MUST** document exactly one LPU leaf for approval: a dedicated non-root account whose extra power is **invoking the global product binary with password `sudo`** plus **NOPASSWD** nginx unit tools (Table A).  
2. That account is a **least-privilege-approver**, **not** a Type 2 execution context. Day-to-day dest writes under `/etc/nginx/sites-available` happen because F6 re-enters the CLI as root (password). **MUST NOT** write `/etc/passwd` or `/etc/sudoers` (main). Type 1 **MAY** copy, overwrite, and remove F6 `/etc/sudoers.d/nginx-adm` and create-if-absent `/etc/sudoers.d/nginx-cli-submit`.  
3. Hierarchy: system-user → least-privilege-user → least-privilege-approver → this leaf (`nginx-adm`).  
4. Every least-privilege-approver leaf **MUST** name **at least one** approval subject. This leaf’s subject is **nginx-conf** (queued as `#` comments + nginx `server` block — **not** JSON). A leaf with no named subject is incomplete.

### 2.2 Mandatory field set (F1–F7)

Every product LPU leaf **MUST** declare:

| Field | Rule |
|-------|------|
| **F1 UID / F2 GID** | Fixed numeric pair **or** explicit distro-assigned. Collision on create **MUST** fail closed. |
| **Shell** | Default `/bin/bash` unless this file overrides. **MUST NOT** default to nologin when a login hook is product law. |
| **F3 System-user home** | Absolute path; selection reason `override` / `preferred-/etc` / `fallback-/home`. Bare home is **not** an affected folder. |
| **F4 Symlink map** | Table of link → target. This product: LPU-home queue **views** → public `/var/nginx-cli/` real dirs, plus sites-available / sites-enabled views. |
| **F5 Affected folders** | Paths **excluding** bare home. Public `/var/nginx-cli/` + three queue children + `${NGINX_CONF_ROOT}` ownership. |
| **F6 Sudoers file** | Installed path, mode/owner. **Cmnd ⊆ Table A** (three-layer). |
| **F7 Remove steps** | Ordered product teardown. Type 0 `uninstall` of the CLI is **not** F7. |

### 2.3 Home resolution

When creating a new LPU, resolve F3 as: override env (`NGINX_ADM_HOME`) if set → `/etc/nginx-adm` if available → `/home/nginx-adm`. An **operator-ordered home wins**. Do not silently ignore an override. Do not default a new home to `/home/nginx-adm` when `/etc/nginx-adm` is free.

### 2.4 Create vs remove

| Artifact | Create (Type 1 `setup`) | Remove (Type 1 `remove-lpu` / `remove-nginx-adm`) |
|----------|-------------------------|---------------------------------------------------|
| Account + home | `useradd` with F1–F3 (not a sudoers Cmnd) | After archive/reverse: `userdel -r` |
| Account password | After useradd: TTY `passwd nginx-adm` (operator types; product **MUST NOT** record it) or non-TTY warn with that command | removed with `userdel` |
| Submit group | `nginx-cli-submit` | `groupdel` if leftover after LPU groupdel |
| Public queues | mkdir `/var/nginx-cli/` + three children; modes in F5 | **backup then remove** the public root (do **not** rely on `userdel -r`) |
| Home queue / site views | F4 symlinks under live LPU home | removed with `userdel -r` |
| Home map subtree | `user-domain-map` under F3 (never public) | removed with `userdel -r` |
| F6 fragment | visudo + install `/etc/sudoers.d/nginx-adm` | backup then remove |
| Submit fragment | create-if-absent `/etc/sudoers.d/nginx-cli-submit` (do **not** overwrite if present) | backup then remove |
| Login hook | idempotent marker in LPU `.bashrc` only | stripped with home / `userdel -r` |
| Live site conf | not created here; ownership may be `nginx-adm:root` | restore `${NGINX_CONF_ROOT}` owner to `root:root` when owned by nginx-adm; **do not** delete site files |

F7 order **MUST** be: backup+remove both product sudoers fragments → backup+remove the public queue root (`/var/nginx-cli` when basename is `nginx-cli`; refuse any other basename) → restore `${NGINX_CONF_ROOT}` owner to `root:root` when owned by nginx-adm (content kept) → `userdel -r nginx-adm` → `groupdel` nginx-adm and `nginx-cli-submit` if leftover. Home deletion is **only** via `userdel -r`. Public queues **MUST NOT** rely on `userdel -r`.

### 2.5 Implementation Notes (this project)

| Property | Product value | Field |
|----------|---------------|-------|
| Username / group | `nginx-adm` / `nginx-adm` | — |
| UID | `1999` | F1 |
| GID | `1999` | F2 |
| Shell | `/bin/bash` | identity |
| System-user home | `/etc/nginx-adm` | F3 |
| Home selection | **preferred-/etc** (override `NGINX_ADM_HOME`; fallback `/home/nginx-adm`) | F3 |
| Home real subtree | `${F3}/user-domain-map` (never on the public queue root) | F3 |
| Symlinks (F4) | `${F3}/config-request` → `/var/nginx-cli/config-request`; same for `config-approved` / `config-rejected`; `${F3}/sites-available` → `${NGINX_CONF_ROOT}/sites-available`; same for `sites-enabled` | F4 |
| Affected (F5) | `/var/nginx-cli` mode **0755** owner `nginx-adm:nginx-adm`; `/var/nginx-cli/config-request` **2770** owner `nginx-adm:nginx-cli-submit` (group dropbox; **not** world `-wx` / **not** `3773`); `/var/nginx-cli/config-approved` **0700**; `/var/nginx-cli/config-rejected` **0700`; `${NGINX_CONF_ROOT}` (default `/etc/nginx`) recursive `nginx-adm:root` | F5 |
| Sudoers file (F6) | `/etc/sudoers.d/nginx-adm` mode `0440` `root:root` — **password** `nginx-cli` day-to-day verbs **plus** `NOPASSWD` unit tools (Table A) | F6 |
| Related fragment (not F6) | `/etc/sudoers.d/nginx-cli-submit` — submit allowlist; create-if-absent | — |
| Related group | `nginx-cli-submit` (inbound write); listing in submit sudoers **and** group membership are both required | — |
| Approval subject | nginx-conf (`#` comments + nginx `server` block) | LPA leaf |
| Login hook | `${F3}/.bashrc` only; marker managed by domain; command `sudo /usr/local/bin/nginx-cli approve` (**password**; **not** `sudo -n`) | F5 rc / domain SSOT |
| Remove | `sudo nginx-cli remove-lpu` (or `remove-nginx-adm`) — any host admin already euid 0 | F7 |

**Routing status:** `setup` / `remove-lpu` **are live** (useradd / F6 / submit fragment / hook / password-ensure / userdel) and **fail closed** without euid 0. Bootstrap is **any** host admin already root (`sudo nginx-cli setup`); **not** `sudo -n`; **not** limited to `nginx-adm` (that account is what setup creates). Probe with `id nginx-adm` before claiming the account exists. If the account already exists with the expected identity, setup **MUST** repair layout/ownership/sudoers only and **MUST NOT** destroy existing site conf. Re-run **MUST** still ensure a usable nginx-adm password (TTY `passwd` or warn) so `OPEN-PASSWD-CLI` is real.

Snippet text, request/approve verbs, and the review walk are owned by `requirement-domain-nginx-cli.md`. This file owns **where** the hook is installed (this LPU’s `.bashrc` only) and **F1–F7**.

**Collision:** if `getent passwd 1999` or `getent group 1999` or `getent passwd nginx-adm` exists and is **not** this identity, setup **MUST** exit non-zero.

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 10 – Least-Privilege User**: sized operator, not standing root.  
- **CIAO Principle 9 – Three Types of Commands**: approver ≠ Type 2 euid.  
- **CIAO Principle 1 – Caution**: fail closed on UID collision.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: never list bare home as affected; never default nologin when a login hook is law.  
- **Intentional**: override home is documented, not a silent fallback.  
- **Anti-fragile**: F7 removes `/var/nginx-cli` explicitly; site files stay.  
- **Over-protect**: Type 0 uninstall does not delete the LPU.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Claim F1–F7 complete while any field is hollow.  
2. List bare home inside F5.  
3. Default a new home to `/home/nginx-adm` when `/etc/nginx-adm` is free.  
4. Treat Type 0 `uninstall` as F7.  
5. Implement `nologin` as this leaf’s portable default shell.  
6. Install the review hook in any account other than this LPU.  
7. Claim a least-privilege-approver leaf complete with **zero** named approval subjects.  
8. Require the operator to be `nginx-adm` (or to use `sudo -n`) in order to run first-time `setup`.  
9. Put the inbound dropbox only under LPU home, or keep F4 as **none**. Type 0 submit is **`/var/nginx-cli/config-request`**.  
10. Hardcode `/etc/nginx-adm` as the **queue** path. Queue views use **live LPU home** (passwd field 6).  
11. Put `user-domain-map` on the public queue root.  
12. Rely on `userdel -r` to remove `/var/nginx-cli`.  
13. Mode inbound world-writable (`0777` or `3773` other `-wx`).  
14. Copy sudoer-cli F1–F7 (UID 1776, inbound 3773, NOPASSWD whole CLI, `sudo -n` hook) onto this leaf.  
15. Claim Family 1 / the login hook work after `setup` when nginx-adm has no usable password.  
16. Feed a password to `chpasswd`, `passwd --stdin`, or any command line / file / log.

**Violating this rule is a critical least-privilege documentation / identity regression.**

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-NGX-10,13,15,34** | `tests/test_domain.sh` | have | hook home; no Type 0 mkdir inbound; 2770 not 3773; setup passwd-ensure (no chpasswd) |
| **TP-CLI-13** | `tests/test_cli.sh` | have | print-sudoers / backup / restore unknown |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Elev Tables A/B/C + both fragments |
| `docs/requirements/requirement-privilege-prevention-set.md` | Closed catalog of what create/teardown blocks vs must stay open |
| `docs/requirements/requirement-domain-nginx-cli.md` | nginx-conf request/approve machine |
| `docs/requirements/requirement-shell-cli-interface.md` | Type map on the dispatcher |
| `./src/nginx-cli` | Ship unit |

**Last Updated**: 2026-08-15 (1.1.0 — setup must ensure nginx-adm password for Family 1)  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
