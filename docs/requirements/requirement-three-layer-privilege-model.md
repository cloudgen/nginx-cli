**file**: docs/requirements/requirement-three-layer-privilege-model.md  
**Status**: Active (Version 1.0.0)  
**Area**: architecture  
**Key**: `requirement-three-layer-privilege-model`  
**id**: RQ-THREE-LAYER-PRIVILEGE-MODEL  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **Type 0 / Type 1 / Type 2 privilege map**, the **elev Tables A/B/C**, and the **sudoers-fragment write contract** of nginx-cli.

Domain verbs that *use* elevation are catalogued in `requirement-domain-nginx-cli.md`. Type 0 submit vs Type 1 approve is the privilege split of that nginx-conf machine. They **MUST NOT** invent a second elev table. This file owns the Type map and the Cmnd set that `setup` writes.

The **closed catalog** of what the product blocks — and what it **must not** block after elev — is owned by `requirement-privilege-prevention-set.md`. This file **MUST NOT** grow a parallel unpublished wall.

**print-sudoers / print-sudoers-install-script / remove-project-sudoers are intentionally absent.** Type 1 `setup` writes the host fragments.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Layer map

| Layer | Privilege | Typical actor | This product |
|-------|-----------|---------------|--------------|
| **Type 0** | Invoking user | Any login | Lifecycle, diagnostics, self-scoped `request` / list / `map-list` |
| **Type 1 bootstrap** | Elevated host mutation | **Any** host admin already euid 0 (`sudo nginx-cli setup` — **password sudo OK**) | `setup` / `remove-lpu`. F6 / `nginx-adm` **must not** be required (chicken-egg). |
| **Type 1 approve** | Elevated host mutation | root login, or `nginx-adm` via F6 (**password** `sudo nginx-cli …`) or as that login | `approve` / `reject` / `map-set` / `map-unset` / `enable-login-approval` |
| **Gated submit** | Invoking user + dest allowlist | listed login in `/etc/sudoers.d/nginx-cli-submit` **and** group `nginx-cli-submit` | Type 0 `request` as the invoker — **not** Type 1 |
| **Type 2** | Dedicated system-user **execution** context | — | **Not used.** `nginx-adm` is a **least-privilege-approver** (who may invoke F6), not an euid the CLI must switch into for dest writes |

**Mandatory:**

1. Every exposed verb **MUST** have exactly one type.  
2. Type 1 **MUST** run with euid 0 **or** (approve family only) as login `nginx-adm`. **Bootstrap** (`setup` / `remove-lpu`) **MUST** accept **any** euid-0 session. **Approve** **MUST** accept login `nginx-adm` **or** a real root session.  
3. The product **MUST NOT** `su` / `runuser` to `nginx-adm` in order to write dest. **MUST NOT** write `/etc/passwd` or `/etc/sudoers` (main file). Type 1 **MAY** copy, overwrite, and remove **product-owned** files under `/etc/sudoers.d/` (F6 `nginx-adm`; create-if-absent `nginx-cli-submit`) and write `${NGINX_CONF_ROOT}/sites-available` on approve. Type 0 **MUST NOT** write `/etc/sudoers.d` or live sites.  
4. **Mix model (EM-HYB, dest-honest).** Bootstrap = password `sudo` (outer **or** in-tool; any host admin). **Day-to-day F6 nginx-cli = password required** — **no** `NOPASSWD` on any `nginx-cli` line. **Unit tools = NOPASSWD** (`/usr/sbin/nginx`, unit `systemctl` / `journalctl`). **`sudo -n` is not** the path for `nginx-cli` (not bootstrap, not the login hook).  
5. Type 2 execution context **MUST** remain **Not used** unless this requirement is revised.  
6. There is **no** `nginx-ctl` command. Table A **MUST NOT** name it.  
7. Production F6 **MUST** use the **global** managed binary `/usr/local/bin/nginx-cli` (mode 0755, not writable by the LPU). Local `${USER_BIN}/nginx-cli` **MUST NOT** appear as a production Cmnd.  
8. Elev is approval for Type 1 bootstrap. After elev, **MUST NOT** invent a second unpublished lock. Sensitive undo-hard steps **MUST** use TTY confirm or `--force` only. Table A is **only** the F6 sudoers lines. Table B is **sudoers-forbidden**, **not** a live-command denylist. Table C jobs are script jobs, not F6 Cmnds.  
9. Install is **multi-user**: any login may local-install; any host admin may global-install and bootstrap.

### 2.2 Table A — F6 sudoers lines only (not a live-command whitelist)

Two families. **Family 1 is never NOPASSWD.** **Family 2 is NOPASSWD** and is **not** `nginx-cli`.

| ID | Job | Binary (absolute) | Fixed args | Password? | Invoker |
|----|-----|-------------------|------------|-----------|---------|
| ELEV-F6-APPROVE | Walk / one-file approve | `/usr/local/bin/nginx-cli` | `approve` · `approve *` | **yes** | `sudo nginx-cli approve …` |
| ELEV-F6-REJECT | One-file reject | `/usr/local/bin/nginx-cli` | `reject *` | **yes** | `sudo nginx-cli reject …` |
| ELEV-F6-REQUEST | Request as nginx-adm | `/usr/local/bin/nginx-cli` | `request` · `request *` | **yes** | `sudo nginx-cli request …` |
| ELEV-F6-LIST | List queues | `/usr/local/bin/nginx-cli` | `list-requests` · `list-approved` · `list-rejected` | **yes** | `sudo nginx-cli list-…` |
| ELEV-F6-MAP | Domain map | `/usr/local/bin/nginx-cli` | `map-set *` · `map-unset *` · `map-list` · `map-list *` | **yes** | `sudo nginx-cli map-…` |
| ELEV-F6-HOOK | Enable login hook | `/usr/local/bin/nginx-cli` | `enable-login-approval` | **yes** | `sudo nginx-cli enable-login-approval` |
| ELEV-F6-SYSTEMCTL | Unit nginx lifecycle | `/bin/systemctl` **and** `/usr/bin/systemctl` | `start\|stop\|reload\|restart nginx` | **no** (`NOPASSWD`) | `sudo systemctl reload nginx` |
| ELEV-F6-JOURNAL | Unit nginx journal | `/bin/journalctl` **and** `/usr/bin/journalctl` | `-u nginx` | **no** (`NOPASSWD`) | `sudo journalctl -u nginx` |
| ELEV-F6-NGINX | nginx binary | `/usr/sbin/nginx` | none (includes `-t`) | **no** (`NOPASSWD`) | `sudo nginx -t` |

Rules:

1. `setup` **MUST** emit **only** Table A on `/etc/sudoers.d/nginx-adm`.  
2. **MUST NOT** put `setup`, `remove-lpu`, `remove-nginx-adm`, `install`, or `uninstall` on F6.  
3. **MUST NOT** put `NOPASSWD` on any `nginx-cli` line.  
4. **MUST NOT** invent or allowlist `nginx-ctl`.  
5. Residual: password F6 still lets nginx-adm run listed day-to-day verbs as root after typing a password. That residual **MUST** be stated; it is accepted.

### 2.3 Table B — Forbidden **in the F6 fragment** (not a live-command denylist)

| ID | Forbidden | Why |
|----|-----------|-----|
| FORB-01 | Recursive destroy via sudo except documented `userdel -r` of this LPU | Blast radius |
| FORB-02 | `/bin/sh`, `/bin/bash`, or unrestricted shell as **F6** Cmnd | Residual shell |
| FORB-03 | `ALL=(ALL) ALL` / `NOPASSWD: ALL` | Broad admin |
| FORB-04 | Package managers as F6 Cmnds | Wrong surface |
| FORB-05 | Writes outside product `/etc/sudoers.d` names (F6 `nginx-adm`, submit `nginx-cli-submit`), live LPU home, `${NGINX_CONF_ROOT}` on approve, `/var/nginx-cli/` | Bound dest |
| FORB-06 | Elevate `${USER_BIN}/nginx-cli` or ad-hoc `/tmp` binaries | Trust tier |
| FORB-07 | Emitting `useradd` / `visudo` / `rm` as **sudoers Cmnds** | Account create is a script job, not a grant in F6 |
| FORB-08 | Write `/etc/passwd` or `/etc/sudoers` (main) from any type; Type 0 write `/etc/sudoers.d`; Type 1 write a **foreign** sudoers.d name | Type 1 may copy/overwrite/remove product-owned names only |
| FORB-09 | `nginx-ctl` / `gitlab-ctl` as any Cmnd | Those are not this product’s commands (`nginx-ctl` does not exist) |
| FORB-10 | `NOPASSWD` on any `/usr/local/bin/nginx-cli` line | Dest F6: password for the CLI |
| FORB-11 | `setup` / `remove-lpu` / `install` / `uninstall` as F6 Cmnds | Bootstrap is any host admin, not F6 |

### 2.4 Table C — Root-context jobs (not sudoers Cmnds)

The CLI invokes these as **internal jobs** after euid 0. Account create/teardown **MUST** be `useradd` / `userdel` from that session (password `sudo` to enter; **not** `sudo -n`). These rows **MUST NOT** appear in F6.

| ID | Job | Typical tool | Bound dest / operand |
|----|-----|--------------|----------------------|
| JOB-USERADD | Create LPU | `useradd` | username/uid/gid/home from LPU law |
| JOB-GROUP | Submit group | `groupadd` / `usermod` (admin) | `nginx-cli-submit` |
| JOB-MKDIR | Queue dirs | `mkdir` | `/var/nginx-cli/` + children; LPU home views |
| JOB-CHMOD | Queue modes | `chmod` | public root 0755; inbound **2770**; archives 0700 |
| JOB-CHOWN | Map / conf owner | `chown` | map file back to `nginx-adm`; conf tree `nginx-adm:root` on setup |
| JOB-VISUDO | Validate fragment | `visudo -cf` | private temp copy only |
| JOB-INSTALL | Install fragment | `install -m 0440` | F6 `nginx-adm`; create-if-absent `nginx-cli-submit` |
| JOB-RM | Remove product fragment / queues | `rm` | those same product-owned names; F7 `/var/nginx-cli` after backup |
| JOB-USERDEL | Teardown | `userdel -r` | this LPU only |
| JOB-NGINX-T | Optional test on approve | `/usr/sbin/nginx -t` | warn + roll back dest if fail |

### 2.5 Fragment write / install

1. Type 0 **MUST NOT** write `/etc/passwd`, `/etc/sudoers`, or `/etc/sudoers.d`. There is **no** `print-sudoers` verb.  
2. Every sudoers write **MUST** pass `visudo -c` / `visudo -cf` on a private temp copy first.  
3. Installed fragments **MUST** be mode `0440`, owner `root:root`.  
4. Previous live F6 **MUST** be backed up before replace/remove. Submit fragment: create-if-absent; **MUST NOT** overwrite if present.  
5. **Trust tier:** production = global managed binary not writable by the LPU.

#### 2.5.1 Complete F6 fragment (`setup` **MUST** emit; trailing blank line required)

```sudoers
# nginx-adm restricted sudoers — password sudo of nginx-cli + NOPASSWD nginx unit tools
# Generated by nginx-cli setup
# There is no nginx-ctl command. NOPASSWD only on nginx / systemctl / journalctl.
nginx-adm ALL=(root) /usr/local/bin/nginx-cli approve
nginx-adm ALL=(root) /usr/local/bin/nginx-cli approve *
nginx-adm ALL=(root) /usr/local/bin/nginx-cli reject *
nginx-adm ALL=(root) /usr/local/bin/nginx-cli request
nginx-adm ALL=(root) /usr/local/bin/nginx-cli request *
nginx-adm ALL=(root) /usr/local/bin/nginx-cli list-requests
nginx-adm ALL=(root) /usr/local/bin/nginx-cli list-approved
nginx-adm ALL=(root) /usr/local/bin/nginx-cli list-rejected
nginx-adm ALL=(root) /usr/local/bin/nginx-cli map-set *
nginx-adm ALL=(root) /usr/local/bin/nginx-cli map-unset *
nginx-adm ALL=(root) /usr/local/bin/nginx-cli map-list
nginx-adm ALL=(root) /usr/local/bin/nginx-cli map-list *
nginx-adm ALL=(root) /usr/local/bin/nginx-cli enable-login-approval
nginx-adm ALL=(ALL) NOPASSWD: /bin/systemctl start nginx
nginx-adm ALL=(ALL) NOPASSWD: /bin/systemctl stop nginx
nginx-adm ALL=(ALL) NOPASSWD: /bin/systemctl reload nginx
nginx-adm ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
nginx-adm ALL=(ALL) NOPASSWD: /bin/journalctl -u nginx
nginx-adm ALL=(ALL) NOPASSWD: /usr/bin/systemctl start nginx
nginx-adm ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop nginx
nginx-adm ALL=(ALL) NOPASSWD: /usr/bin/systemctl reload nginx
nginx-adm ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
nginx-adm ALL=(ALL) NOPASSWD: /usr/bin/journalctl -u nginx
nginx-adm ALL=(ALL) NOPASSWD: /usr/sbin/nginx

```

Worked elev: `sudo /usr/local/bin/nginx-cli approve` (nginx-adm password). Worked unit: `sudo /usr/sbin/nginx -t` then `sudo /bin/systemctl reload nginx` (no password).

#### 2.5.2 Submit allowlist fragment (not F6; create-if-absent)

`/etc/sudoers.d/nginx-cli-submit` — mode `0440`, owner `root:root`. First write is a **commented empty list**. Software allowlist = uncommented login names. Type 0 `request` runs as the invoker.

Complete template `setup` **MUST** emit when the file is missing:

```sudoers
# nginx-cli submitter software allowlist — NOT nginx / systemctl elev
# Uncomment and list logins who may submit config requests.
# Those logins must also be in group nginx-cli-submit to write inbound.
# Type 0 request runs as the invoker (no sudo -u nginx-adm deposit).
# User_Alias NGINX_CLI_SUBMITTERS = alice, bob
# NGINX_CLI_SUBMITTERS ALL=(nginx-adm) NOPASSWD: /usr/local/bin/nginx-cli request

```

Worked filled example (admin edit + `visudo -c`; **not** written by `setup`):

```sudoers
# nginx-cli submitter software allowlist — NOT nginx / systemctl elev
# Those logins must also be in group nginx-cli-submit to write inbound.
User_Alias NGINX_CLI_SUBMITTERS = alice, bob
NGINX_CLI_SUBMITTERS ALL=(nginx-adm) NOPASSWD: /usr/local/bin/nginx-cli request

```

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `nginx-cli` |
| **LPU username** | `nginx-adm` |
| **F6 path** | `/etc/sudoers.d/nginx-adm` |
| **Submit fragment** | `/etc/sudoers.d/nginx-cli-submit` |
| **Table A** | password `nginx-cli` day-to-day verbs **plus** `NOPASSWD` `nginx` / unit `systemctl` / `journalctl` |
| **Type 2** | Not used |
| **print-sudoers** | **Absent** — `setup` writes fragments |
| **Elev model** | **EM-HYB** dest-honest — password `sudo` for bootstrap and for `nginx-cli`; `NOPASSWD` only on unit tools; **no** `sudo -n` for `nginx-cli` |
| **Approve dest** | `${NGINX_CONF_ROOT}/sites-available/<domain>.conf` (domain SSOT) |

### 2.7 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 9 – Three Types of Commands**: every verb has one type.  
- **CIAO Principle 10 – Least-Privilege User**: F6 is two families, not residual ALL.  
- **CIAO Principle 1 – Caution**: visudo before dest copy under `/etc/sudoers.d/`.  
- **CIAO Principle 4 / 20 – Over-protect**: Table A vs Table C split is sacred; no `nginx-ctl`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: fail closed without global binary for production F6.  
- **Intentional**: approver authorizes with a password; unit tools stay NOPASSWD.  
- **Anti-fragile**: setup writes F6; no print-sudoers dual path.  
- **Over-protect**: never emit `useradd` or `nginx-ctl` into sudoers.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Emit `ALL=(ALL) ALL`, `NOPASSWD: ALL`, or a shell as F6.  
2. Put Table C OS tools into Table A **or** put Table A `nginx-cli` lines under `NOPASSWD`.  
3. Invent or allowlist a **`nginx-ctl` command**.  
4. Collapse Type 2 into “run as root” or invent a Type 2 euid for dest writes.  
5. Elevate the user-local binary for production Pass.  
6. Write `/etc/passwd` or `/etc/sudoers` (main), or ban this product’s Type 1 copy/overwrite/remove of product-owned `/etc/sudoers.d` names.  
7. Reintroduce `print-sudoers` without explicit user order and a registry change.  
8. Require `SUDO_USER==nginx-adm` for `setup` / `remove-lpu`.  
9. Write bootstrap or the login hook as `sudo -n` of `nginx-cli`.  
10. Copy sudoer-cli Table A (one NOPASSWD whole-binary line, inbound 3773) onto this dest.  
11. Add a product block that is not a row in `requirement-privilege-prevention-set.md`.

**Violating this rule is a critical privilege / LLM-escape regression.**

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-13,14** | `tests/test_cli.sh` | have | print-sudoers / nginx-ctl unknown |
| **TP-NGX-01,14,15** | `tests/test_domain.sh` | have | setup euid; hook password sudo; F6 two families static |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-least-privilege-user.md` | LPU identity F1–F7 |
| `docs/requirements/requirement-privilege-prevention-set.md` | Closed catalog of what is blocked vs must stay open |
| `docs/requirements/requirement-domain-nginx-cli.md` | nginx-conf request/approve + verb catalog |
| `docs/requirements/requirement-shell-cli-interface.md` | Dispatcher / Type 0 catalog |
| `./src/nginx-cli` | Ship unit under test |

**Last Updated**: 2026-08-15  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
