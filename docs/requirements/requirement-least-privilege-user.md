**file**: docs/requirements/requirement-least-privilege-user.md  
**Status**: Active (Version 1.4.0)  
**Area**: architecture  
**Key**: `requirement-least-privilege-user`  
**id**: RQ-LEAST-PRIVILEGE-USER  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the dedicated **least-privilege-approver** account **nginx-adm**: identity, home vs affected folders, F4 views, create, and remove. That account is the **approver** in the nginx-conf request/approve machine owned by `requirement-domain-nginx-cli.md`. Elev Tables A/B/C and both product sudoers fragments live in `requirement-three-layer-privilege-model.md`. What create/teardown **blocks** vs what must stay open after elev is owned by `requirement-privilege-prevention-set.md`.

### 1.1 Human-facing

**In one sentence:** `setup` creates the dedicated **nginx-adm** account (UID/GID **1999**) that reviews waiting nginx site files; if that name or those numbers already belong to someone else, setup stops.

| Box | Meaning | Example |
|-----|---------|---------|
| You / host admin | Create or remove nginx-adm | `sudo nginx-cli setup` |
| nginx-adm | Reviews waiting requests | `nginx-cli approve` |
| Not this file | How approve/reject works | `requirement-domain-nginx-cli` |

| Includes | Excludes |
|----------|----------|
| Account identity, home, queue views, teardown | Sudoers verb tables; dest JSON fence match |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/nginx-cli` | ship unit | `setup` / `remove-lpu` |
| `/etc/nginx-adm` | preferred home | this account’s files |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| First-time host setup | Creates nginx-adm. If UID 1999 is already another login, it **must not** steal it. | `sudo nginx-cli setup` then `getent passwd 1999` if setup dies |

## Under command line for normal user only

On Termux, Git Bash, or Windows cmd, **admin privilege** is unused: **MUST NOT** run `setup` / `remove-lpu` / `useradd`. nginx-adm as a dedicated account is a Linux-with-root job. This class stays at **this login**.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Role

1. The product **MUST** document exactly one LPU leaf for approval: a dedicated non-root account whose extra power is **invoking the global product binary with password `sudo`** plus **NOPASSWD** nginx unit tools (Table A).  
2. That account is a **least-privilege-approver**, **not** a Type 2 execution context. Day-to-day dest writes under `/etc/nginx/sites-available` happen because Family 1 (sibling-approved) re-enters the CLI as root (password), or as-login without sudo. **MUST NOT** write `/etc/passwd` or `/etc/sudoers` (main). Type 1 **MUST NOT** write `/etc/sudoers.d/`. Type 1 **MAY** write Family 2 unit tools to `/etc/nginx-adm/sudoers`.  
3. Hierarchy: system-user → least-privilege-user → least-privilege-approver → this leaf (`nginx-adm`).  
4. Every least-privilege-approver leaf **MUST** name **at least one** approval subject. This leaf’s subject is **nginx-conf** (queued as dest request JSON; approve renders nginx `server` block text). A leaf with no named subject is incomplete.

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
| Family 2 unit-tools file | visudo + install `/etc/nginx-adm/sudoers` (not under `/etc/sudoers.d`) | backup then remove that file |
| Family 1 JSON | Auto-queue `login-hook-elev` into sibling inbound when dest exists | **MUST NOT** unlink `/etc/sudoers.d/nginx-cli-*` (sibling dest) |
| Login hook | idempotent marker in LPU `.bashrc` only | stripped with home / `userdel -r` |
| Live site conf | not created here; ownership may be `nginx-adm:root` | restore `${NGINX_CONF_ROOT}` owner to `root:root` when owned by nginx-adm; **do not** delete site files |

F7 order **MUST** be: backup+remove `/etc/nginx-adm/sudoers` → backup+remove the public queue root (`/var/nginx-cli` when basename is `nginx-cli`; refuse any other basename) → restore `${NGINX_CONF_ROOT}` owner to `root:root` when owned by nginx-adm (content kept) → `userdel -r nginx-adm` → `groupdel` nginx-adm and `nginx-cli-submit` if leftover. **MUST NOT** delete sibling dest `/etc/sudoers.d/nginx-cli-*`. Home deletion is **only** via `userdel -r`. Public queues **MUST NOT** rely on `userdel -r`.

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
| Family 2 file | `/etc/nginx-adm/sudoers` mode `0440` `root:root` — **NOPASSWD** unit tools only | F6 unit |
| Family 1 dest | After sibling approve: `/etc/sudoers.d/nginx-cli-nginx-adm` (JSON `login-hook-elev`; password `nginx-cli` verbs). `setup` **MUST NOT** write it | sibling dest |
| Listed-submitter dest | After sibling approve: `/etc/sudoers.d/nginx-cli-<login>` | sibling dest |
| Related group | `nginx-cli-submit` (inbound write); listing in submit sudoers **and** group membership are both required | — |
| Approval subject | nginx-conf (`#` comments + nginx `server` block) | LPA leaf |
| Login hook | `${F3}/.bashrc` (and `.profile` create-if-absent); command `/usr/local/bin/nginx-cli-hook approve` (as-login; **not** `sudo`; **not** `sudo -n`). Snippet + labeled symlink + setup review/replace: `requirement-login-interactive-review-hook` | F5 rc / hook REQ |
| Remove | `sudo nginx-cli remove-lpu` (or `remove-nginx-adm`) — any host admin already euid 0 | F7 |

**Routing status:** `setup` / `remove-lpu` **are live** (useradd / queues / hook / password-ensure / userdel / Family 2 file / Family 1 JSON auto-queue). Family 1 dest `/etc/sudoers.d/nginx-cli-nginx-adm` is sibling-approved, not copied by `setup`. Bootstrap is **any** host admin already root (`sudo nginx-cli setup`); **not** `sudo -n`. Re-run **MUST** still ensure a usable nginx-adm password. Missing sibling dest → skip JSON queue (setup still succeeds).

Snippet text, labeled symlink `/usr/local/bin/nginx-cli-hook` → `/usr/local/bin/nginx-cli`, and setup review of an old hook are owned by `requirement-login-interactive-review-hook.md`. Request/approve verbs and the dest review walk are owned by `requirement-domain-nginx-cli.md`. This file owns **where** the hook is installed (this LPU’s `.bashrc` only) and **F1–F7**.

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
15. Claim Family 1 works after `setup` when nginx-adm has no usable password.  
16. Feed a password to `chpasswd`, `passwd --stdin`, or any command line / file / log.  
17. Wrap the login hook in `sudo` or `sudo -n`, or leave a stale `sudo … approve` / old product-binary managed block in place on re-run (heal owner: `requirement-login-interactive-review-hook`).  
18. Write `/etc/sudoers.d/nginx-adm` or `/etc/sudoers.d/nginx-cli-submit` from `setup`.

**Violating this rule is a critical least-privilege documentation / identity regression.**

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-NGX-10,13,14,15,34,50** | `tests/test_domain.sh` | have | hook home; as-login (no sudo); replace stale sudo block; 2770 not 3773; setup passwd-ensure (no chpasswd). Hook snippet: `requirement-login-interactive-review-hook` |
| **TP-NGX-51** | `tests/test_domain.sh` | have | collision identity: foreign UID/GID/name/home fail-closed; `/usr/sbin` host-bin |
| **TP-NGX-52,53** | `tests/test_domain.sh` | have | Family 1 JSON auto-queue; Family 2 dest not under `/etc/sudoers.d` |
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
| `docs/requirements/requirement-login-interactive-review-hook.md` | Labeled symlink + snippet; setup reviews/replaces old hook on this home |
| `docs/requirements/requirement-shell-cli-interface.md` | Type map on the dispatcher |
| `./src/nginx-cli` | Ship unit |

**Last Updated**: 2026-09-08 (1.4.0 — login-hook snippet owner is `requirement-login-interactive-review-hook`; this file still owns which home)  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
