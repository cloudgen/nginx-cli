**file**: docs/requirements/requirement-three-layer-privilege-model.md  
**Status**: Active (Version 1.5.0)  
**Area**: architecture  
**Key**: `requirement-three-layer-privilege-model`  
**id**: RQ-THREE-LAYER-PRIVILEGE-MODEL  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **Type 0 / Type 1 / Type 2 privilege map**, the **elev Tables A/B/C**, the **sudoers-fragment write contract**, and the **`submit-sudoer-request` compose workflow** of nginx-cli.

Domain verbs that *use* elevation are catalogued in `requirement-domain-nginx-cli.md`. Type 0 nginx-conf `request` vs Type 1 approve is the privilege split of that machine. They **MUST NOT** invent a second elev table. This file owns the Type map, the Cmnd set that `setup` writes, and how Type 0 hands a grant to sibling **sudoer-cli**.

The **JSON sudoer file body** (command identity, samples) is **not** owned here — it is `requirement-sudoer-json-file.md`.

The **closed catalog** of what the product blocks — and what it **must not** block after elev — is owned by `requirement-privilege-prevention-set.md`. This file **MUST NOT** grow a parallel unpublished wall.

**print-sudoers / print-sudoers-install-script / remove-project-sudoers are intentionally absent.** Type 1 `setup` writes the host F6 / shared-allowlist fragments. Type 0 `submit-sudoer-request` queues a **per-user** grant via the sibling; it does **not** write `/etc`.

### 1.1 Human-facing

**In one sentence:** Your login can submit a request; only root or nginx-adm can change the computer (create nginx-adm, publish a site). This program does not switch into nginx-adm to write files.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Submit, convert, ask sudoer-cli for a grant | `nginx-cli request example.com ./site.conf` |
| Host admin / nginx-adm | Create nginx-adm; publish or reject | `sudo nginx-cli setup` |
| Not this file | Waiting JSON shape | `requirement-domain-nginx-cli` |

| Includes | Excludes |
|----------|----------|
| Who may run what; sudoers families; `submit-sudoer-request` | Dest Fence match; nginx-conf samples |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/nginx-cli` | ship unit | `setup` / `submit-sudoer-request` |
| `/etc/nginx-adm/sudoers` | unit-tools fragment | nginx start/stop/reload without a password |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| First-time host | Needs a root login. Does not write `/etc/sudoers.d`. | `sudo nginx-cli setup` |

## Under command line for normal user only

On Termux, Git Bash, or Windows cmd, **admin privilege** and **dedicated system user privilege** **MUST** stay unused: no `setup` / `remove-lpu`, no `useradd`, no in-tool `sudo`, no `/etc` dest. POSIX Linux with a root login is **not** that class.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Layer map

| Layer | Privilege | Typical actor | This product |
|-------|-----------|---------------|--------------|
| **Type 0** | Invoking user | Any login | Lifecycle, diagnostics, self-scoped `request` / list / `map-list`, **`submit-sudoer-request`** (sibling compose; no `/etc` write) |
| **Type 1 bootstrap** | Elevated host mutation | **Any** host admin already euid 0 (`sudo nginx-cli setup` — **password sudo OK**) | `setup` / `remove-lpu`. F6 / `nginx-adm` **must not** be required (chicken-egg). |
| **Type 1 approve** | Elevated host mutation | root login, or `nginx-adm` via F6 (**password** `sudo nginx-cli …`) or as that login | `approve` / `reject` / `map-set` / `map-unset` / `enable-login-approval` |
| **Gated submit** | Invoking user + dest allowlist | listed login in `/etc/sudoers.d/nginx-cli-submit` **and** group `nginx-cli-submit` | Type 0 `request` as the invoker — **not** Type 1 |
| **Type 2** | Dedicated system-user **execution** context | — | **Not used.** `nginx-adm` is a **least-privilege-approver** (who may invoke F6), not an euid the CLI must switch into for dest writes |

**Mandatory:**

1. Every exposed verb **MUST** have exactly one type.  
2. Type 1 **MUST** run with euid 0 **or** (approve family only) as login `nginx-adm`. **Bootstrap** (`setup` / `remove-lpu`) **MUST** accept **any** euid-0 session. **Approve** **MUST** accept login `nginx-adm` **or** a real root session.  
3. The product **MUST NOT** `su` / `runuser` to `nginx-adm` in order to write dest. **MUST NOT** write `/etc/passwd` or `/etc/sudoers` (main file). Type 1 **MUST NOT** write `/etc/sudoers.d/` (Family 1 dest is sibling-approved `/etc/sudoers.d/nginx-cli-nginx-adm`; listed-submitter dest is `/etc/sudoers.d/nginx-cli-<login>`). Type 1 **MAY** write Family 2 unit-tools **only** to `/etc/nginx-adm/sudoers` (not under `/etc/sudoers.d/`) and write `${NGINX_CONF_ROOT}/sites-available` on approve. Type 0 **MUST NOT** write `/etc/sudoers.d` or live sites.  
4. **Mix model (EM-HYB, dest-honest).** Bootstrap = password `sudo` (outer **or** in-tool; any host admin). **Day-to-day F6 nginx-cli = password required** — **no** `NOPASSWD` on any `nginx-cli` line. **Unit tools = NOPASSWD** (`/usr/sbin/nginx`, unit `systemctl` / `journalctl`). **`sudo -n` is not** the path for `nginx-cli` (not bootstrap, not the login hook). The **login hook** is as-login `/usr/local/bin/nginx-cli-hook approve` (**no** `sudo`; `OPEN-ADM-NOSUDO` / `PREV-HOOK-SUDO`). Type 1 `setup` **MUST** leave Family 1 authenticatable: TTY `passwd nginx-adm` (operator types; never recorded) or a non-TTY warn with that command. A locked/empty nginx-adm password makes `sudo nginx-cli` print `sudo: a password is required` — that is a setup gap, not a reason to NOPASSWD the CLI, and **not** a reason to wrap the login hook in sudo.  
5. Type 2 execution context **MUST** remain **Not used** unless this requirement is revised.  
6. There is **no** `nginx-ctl` command. Table A **MUST NOT** name it.  
7. Production F6 **MUST** use the **global** managed binary `/usr/local/bin/nginx-cli` (mode 0755, not writable by the LPU). Local `${USER_BIN}/nginx-cli` **MUST NOT** appear as a production Cmnd.  
8. Elev is approval for Type 1 bootstrap. After elev, **MUST NOT** invent a second unpublished lock. Sensitive undo-hard steps **MUST** use TTY confirm or `--force` only. Table A is **only** the F6 sudoers lines. Table B is **sudoers-forbidden**, **not** a live-command denylist. Table C jobs are script jobs, not F6 Cmnds.  
9. Install is **multi-user**: any login may local-install; any host admin may global-install and bootstrap.

### 2.2 Table A — F6 sudoers lines only (not a live-command whitelist)

Two families. **Family 1 is never NOPASSWD.** **Family 2 is NOPASSWD** and is **not** `nginx-cli`.

| ID | Job | Binary (absolute) | Fixed args | Password? | Invoker |
|----|-----|-------------------|------------|-----------|---------|
| ELEV-F6-APPROVE | Walk / one-file approve | `/usr/local/bin/nginx-cli` | `approve` · `approve *` · `--json approve` · `--json approve *` | **yes** | `sudo nginx-cli approve …` · `sudo nginx-cli --json approve …` |
| ELEV-F6-REJECT | One-file reject | `/usr/local/bin/nginx-cli` | `reject *` · `--json reject *` | **yes** | `sudo nginx-cli reject …` · `sudo nginx-cli --json reject …` |
| ELEV-F6-REQUEST | Request as nginx-adm | `/usr/local/bin/nginx-cli` | `request` · `request *` · `--json request` · `--json request *` | **yes** | `sudo nginx-cli request …` · `sudo nginx-cli --json request …` |
| ELEV-F6-LIST | List queues | `/usr/local/bin/nginx-cli` | each of `list-requests` / `list-approved` / `list-rejected` and `… *`, plus the same with leading `--json` | **yes** | `sudo nginx-cli list-…` · `sudo nginx-cli --json list-…` |
| ELEV-F6-MAP | Domain map | `/usr/local/bin/nginx-cli` | `map-set *` · `map-unset *` · `map-list` · `map-list *` · same with leading `--json` | **yes** | `sudo nginx-cli map-…` · `sudo nginx-cli --json map-…` |
| ELEV-F6-HOOK | Enable login hook | `/usr/local/bin/nginx-cli` | `enable-login-approval` · `enable-login-approval *` · `--json enable-login-approval` · `--json enable-login-approval *` | **yes** | `sudo nginx-cli enable-login-approval` · `sudo nginx-cli --json enable-login-approval` |
| ELEV-F6-SYSTEMCTL | Unit nginx lifecycle | `/bin/systemctl` **and** `/usr/bin/systemctl` | `start\|stop\|reload\|restart nginx` | **no** (`NOPASSWD`) | `sudo systemctl reload nginx` |
| ELEV-F6-JOURNAL | Unit nginx journal | `/bin/journalctl` **and** `/usr/bin/journalctl` | `-u nginx` | **no** (`NOPASSWD`) | `sudo journalctl -u nginx` |
| ELEV-F6-NGINX | nginx binary | `/usr/sbin/nginx` | none (includes `-t`) | **no** (`NOPASSWD`) | `sudo nginx -t` |

Rules:

1. Family 1 Table A `nginx-cli` lines **MUST** be the dest of sibling-approved `login-hook-elev` JSON (`/etc/sudoers.d/nginx-cli-nginx-adm`). `setup` **MUST NOT** copy that fragment into `/etc/sudoers.d/`.  
2. **MUST NOT** put `setup`, `remove-lpu`, `remove-nginx-adm`, `install`, or `uninstall` on Family 1 or Family 2.  
3. **MUST NOT** put `NOPASSWD` on any `nginx-cli` line.  
4. **MUST NOT** invent or allowlist `nginx-ctl`.  
5. Residual: password F6 still lets nginx-adm run listed day-to-day verbs as root after typing a password. That residual **MUST** be stated; it is accepted.  
6. Login `nginx-adm` **MAY** run the same day-to-day verbs **without** sudo (`ngx_can_approve`). F6 `sudo nginx-cli` is the root re-entry. Both paths are dest-honest. The login hook is as-login (no sudo). Family 1 `sudo nginx-cli` still **needs** a usable nginx-adm password.  
7. Family 1 **MUST** emit each listed argv **and** the same argv with a leading `--json`. sudoers matches argv exactly (`nginx-cli --json list-requests` is not `list-requests`). Trailing `--json` is covered by `verb *`. **MUST NOT** emit `--json *` (that would include `setup` / `remove-lpu`). **MUST NOT** put `NOPASSWD` on those `--json` lines.

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
| FORB-12 | `--json *` or `--json setup` / `--json remove-lpu` as F6 Cmnds | Leading `--json` is only a prefix on listed Family 1 verbs |

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
| JOB-PASSWD | Set LPU password so Family 1 authenticates | `passwd nginx-adm` | TTY; operator types; product **MUST NOT** record or `chpasswd` |

### 2.5 Fragment write / install

**Three dests (sacred):**

| Dest | Who writes | What |
|------|------------|------|
| `/var/sudoer-cli/sudoer-request/*.json` | Type 1 `setup` (`login-hook-elev`) or Type 0 `submit-sudoer-request` (`type-2-switch`) | File-based JSON proposal |
| `/etc/sudoers.d/nginx-cli-nginx-adm` | Sibling dest after **sudoer-adm** approve | Family 1 password `nginx-cli` verbs + `--json` |
| `/etc/sudoers.d/nginx-cli-<login>` | Sibling dest after **sudoer-adm** approve | Listed-submitter `nginx-cli request` as `nginx-adm` |
| `/etc/nginx-adm/sudoers` | Type 1 `setup` (this product) | Family 2 **only**: NOPASSWD `nginx` / unit `systemctl` / `journalctl` |

1. Type 0 **MUST NOT** write `/etc/passwd`, `/etc/sudoers`, or `/etc/sudoers.d`. There is **no** `print-sudoers` verb.  
2. Type 1 `setup` **MUST NOT** write `/etc/sudoers.d/nginx-adm` or `/etc/sudoers.d/nginx-cli-submit`.  
3. Every **unit-tools** sudoers write **MUST** pass `visudo -c` on a private temp copy first; dest `/etc/nginx-adm/sudoers` mode `0440` `root:root`.  
4. Previous live unit-tools file **MUST** be backed up before replace/remove. **MUST NOT** unlink sibling dest `/etc/sudoers.d/nginx-cli-*` on `remove-lpu` (sudoer-adm owns those).  
5. **Trust tier:** production = global managed binary not writable by the LPU.

#### 2.5.0 Setup auto-queue (Family 1 JSON)

After account / queues / hook / password-ensure, `setup` **MUST**:

1. Detect sibling `sudoer-cli` + `sudoer-adm` + writable `/var/sudoer-cli/sudoer-request`.  
2. If present: write `kind=login-hook-elev` JSON (body: `requirement-sudoer-json-file`) into inbound using dest request-id grammar. Action **update** when `/etc/sudoers.d/nginx-cli-nginx-adm` exists; else **add**. **MUST NOT** `mkdir` inbound. **MUST NOT** `chown` inbound. **MUST NOT** call dest Type 0 `add-sudoer-request`. Dest Type 0 self-scope **MUST NOT** apply.  
3. If sibling missing: **skip** (setup still succeeds). Next: `sudo sudoer-cli setup`. **MUST NOT** fall back to writing `/etc/sudoers.d`.  
4. `--json setup` **MUST** include `login_hook_sudoer` = `submitted` \| `skipped` \| `failed`.

This is **not** Type 0 `submit-sudoer-request`.

#### 2.5.1 Complete Family 2 unit-tools fragment (`setup` **MAY** emit at `/etc/nginx-adm/sudoers`; trailing blank line required)

```sudoers
# nginx-adm Family 2 — NOPASSWD nginx unit tools only (not under /etc/sudoers.d)
# Generated by nginx-cli setup
# Family 1 nginx-cli verbs are a sibling dest JSON grant, not this file.
# There is no nginx-ctl command.
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

Worked Family 1 elev (after sibling dest approve): `sudo /usr/local/bin/nginx-cli approve` (nginx-adm password — `setup` **MUST** have run `passwd nginx-adm` or warned). Worked JSON elev: `sudo /usr/local/bin/nginx-cli --json list-requests`. Worked as-login: `nginx-cli approve` while `id -un` is `nginx-adm` (no sudo). Worked hook: `/usr/local/bin/nginx-cli-hook approve` from that login (no sudo). Worked unit: `sudo /usr/sbin/nginx -t` then `sudo /bin/systemctl reload nginx` (no password) after Family 2 file is in effect.

#### 2.5.2 Listed-submitter dest (not written by `setup`)

`setup` **MUST NOT** create `/etc/sudoers.d/nginx-cli-submit`. Listed submitters queue `type-2-switch` JSON via Type 0 `submit-sudoer-request`. After sudoer-adm approve the dest is `/etc/sudoers.d/nginx-cli-<login>`.

Worked dest text (sibling dest; **not** `setup`):

```sudoers
alice ALL=(nginx-adm) NOPASSWD: /usr/local/bin/nginx-cli request
```

#### 2.5.3 `submit-sudoer-request` (Type 0) product rules

**Purpose:** This product is a **Type 0 sudoers-grant submitter** for its **listed-submitter** grant. When the sibling approval CLI and approver account are present, it hands a self-scoped JSON sudoer file to that CLI so the CLI **allocates a JSON request** in the sibling’s **public inbound**. This product remains Type 0 on this verb: it **MUST NOT** write `/etc`, **MUST NOT** `mkdir` the production inbound, **MUST NOT** approve or reject, and **MUST NOT** choose the queued dest basename.

JSON **body** is owned by `requirement-sudoer-json-file.md` (grant = `nginx-cli request` as `nginx-adm` only).

**Roles (this verb):**

| Role | Who | May | Must not |
|------|-----|-----|----------|
| **Submitter** | Invoking login via this CLI | Detect approval CLI + inbound; emit or pass a self-scoped grant; invoke sibling submit | `mkdir` inbound; write `/etc`; pick dest basename; approve |
| **Allocator** | Sibling approval CLI (`sudoer-cli`) | Allocate `request_id`; exclusive-create JSON in inbound; `chmod 0640` | Trust a caller-supplied dest basename |
| **Approver** | Sibling LPU (`sudoer-adm`) | Move inbound → accepted/declined; install dest | This product’s Type 0 path |

**Inbound detect (mandatory order — first existing directory wins):**

| Priority | Candidate | When |
|----------|-----------|------|
| 1 | `SUDOER_QUEUE_INBOUND` | Set **and** is an existing directory (tests / explicit override) |
| 2 | `/var/sudoer-cli/sudoer-request` | **Preferred production public inbound** (must already exist) |
| 3 | `{{sudoer-adm-home}}/sudoer-request` | F4 **view** (symlink to the public real dir) |
| 4 | Legacy only: `{{sudoer-adm-home}}/sudoer-approving`, `/etc/sudoer-adm/sudoer-approving`, `/home/sudoer-adm/sudoer-approving` | Transitional hosts; **not** the preferred real dir |

Core rules **MUST NOT** treat a home-only `sudoer-approving` directory as the preferred real inbound.

**Normative rules:**

1. **MUST** detect the approval CLI (`sudoer-cli`): env `SUDOER_CLI` if executable, else global bin, else user bin, else `PATH`. Missing → fail closed with install hint.  
2. **MUST** detect the approver login (`sudoer-adm`, override `SUDOER_ADM_USER`) via `id`. Missing → fail closed with setup hint (`sudo sudoer-cli setup`).  
3. **MUST** detect inbound using the table above. Missing → fail closed with setup hint. Not writable for exclusive create → fail closed.  
4. **MUST NOT** `mkdir` (or `mkdir -p`) the production inbound, its public parent, or any F4 view.  
5. **MUST NOT** treat this product’s nginx-conf inbound (`/var/nginx-cli/config-request`) as the sudoer inbound.  
6. **MUST** report detections on `about` (human + JSON): approval CLI path or `not_found`; approver or `absent`; inbound path or `not_found`; writable flag. About inbound **SHOULD** name the preferred public path when reporting `not_found`.  
7. Default input is the JSON grant from `requirement-sudoer-json-file.md` (same trust-tier gate as below). Optional file operand submits that file instead (refuse symlink / missing / forbidden grant).  
8. **MUST** invoke the detected approval CLI `add-sudoer-request` (or `update-sudoer-request` with `--update`) with `--service` equal to this product’s `APP_NAME` and a purpose string (`--purpose` or product default). That sibling call **is** what creates the queued **JSON** file.  
9. **MUST NOT** invent or pass a dest basename for the queued file. `request_id` is whatever the sibling allocator returns.  
10. When pointing the sibling at a queue root, **MUST** use the **parent of the real public inbound** (or leave the sibling on its public default). **MUST NOT** export a home directory that still uses the legacy `sudoer-approving` child as if it were the public queue root.  
11. **MUST NOT** write `/etc/sudoers.d` or `/etc/passwd` from this verb.  
12. Product `--json` status **SHOULD** include `request_id`, `action`, `service`, `sudoer_cli`, `sudoer_adm`, `inbound`. That status object is **not** the queued request file.

**Trust tier (emit of the default grant):**

| Tier | Meaning | Default emit |
|------|---------|--------------|
| `production` | Readable+executable `${GLOBAL_BIN}/nginx-cli` | Allowed |
| `test_local` / `unmanaged` | Only user-bin or neither | Fail closed unless `--allow-test-local` or `ALLOW_TEST_LOCAL_SUDOERS=1` |

After sibling approve, dest install is **`/etc/sudoers.d/nginx-cli-<user>`** (per-user). Dest **listed submitter** for nginx-conf `request` is then: uncommented login in `/etc/sudoers.d/nginx-cli-submit` **or** that per-user fragment present (regular file, not symlink). Group `nginx-cli-submit` is still required to write inbound.

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `nginx-cli` |
| **LPU username** | `nginx-adm` |
| **Family 2 dest** | `/etc/nginx-adm/sudoers` (Type 1 `setup` writes this; not under `/etc/sudoers.d`) |
| **Family 1 dest** | `/etc/sudoers.d/nginx-cli-nginx-adm` after sibling approve of `login-hook-elev` |
| **Submit fragment** | `/etc/sudoers.d/nginx-cli-submit` or `/etc/sudoers.d/nginx-cli-<login>` (sibling dest; `setup` does not write them) |
| **Table A** | password `nginx-cli` day-to-day verbs **plus** `NOPASSWD` `nginx` / unit `systemctl` / `journalctl` |
| **Type 2** | Not used |
| **print-sudoers** | **Absent** — `setup` writes Family 2; Family 1 and listed-submitter dests are sibling JSON; compose uses `submit-sudoer-request` |
| **Submit verb** | `submit-sudoer-request` → `ngx_submit_sudoer_request` |
| **Sibling approval CLI** | `sudoer-cli` (`SUDOER_CLI` override) |
| **Sibling approver** | `sudoer-adm` (`SUDOER_ADM_USER` override) |
| **Preferred public inbound** | `/var/sudoer-cli/sudoer-request` |
| **JSON body SSOT** | `requirement-sudoer-json-file` |
| **Elev model** | **EM-HYB** dest-honest — password `sudo` for bootstrap and for F6 `nginx-cli`; `NOPASSWD` only on unit tools; **no** `sudo -n` for `nginx-cli` |
| **Approve dest** | `${NGINX_CONF_ROOT}/sites-available/<domain>.conf` (domain SSOT) |

### 2.7 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 9 – Three Types of Commands**: every verb has one type.  
- **CIAO Principle 10 – Least-Privilege User**: F6 is two families, not residual ALL.  
- **CIAO Principle 1 – Caution**: visudo before dest copy of Family 2 under `/etc/nginx-adm/sudoers`.  
- **CIAO Principle 4 / 20 – Over-protect**: Table A vs Table C split is sacred; no `nginx-ctl`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: fail closed without global binary for production F6.  
- **Intentional**: approver authorizes with a password; unit tools stay NOPASSWD.  
- **Anti-fragile**: setup writes Family 2 and queues Family 1 JSON; compose submit fails closed when sibling missing; no print-sudoers dual path.  
- **Over-protect**: never emit `useradd` or `nginx-ctl` into sudoers; Type 0 compose never writes `/etc`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Emit `ALL=(ALL) ALL`, `NOPASSWD: ALL`, or a shell as F6.  
2. Put Table C OS tools into Table A **or** put Table A `nginx-cli` lines under `NOPASSWD`.  
3. Invent or allowlist a **`nginx-ctl` command**.  
4. Collapse Type 2 into “run as root” or invent a Type 2 euid for dest writes.  
5. Elevate the user-local binary for production Pass.  
6. Write `/etc/passwd` or `/etc/sudoers` (main), or ban this product’s Type 1 copy/overwrite/remove of product-owned `/etc/sudoers.d` names.  
7. Reintroduce `print-sudoers` without explicit user order and a registry change (compose submit is **not** print-sudoers).  
8. Require `SUDO_USER==nginx-adm` for `setup` / `remove-lpu`.  
9. Write bootstrap or the login hook as `sudo -n` of `nginx-cli`.  
10. Copy sudoer-cli Table A (one NOPASSWD whole-binary line, inbound 3773) onto this dest.  
11. Add a product block that is not a row in `requirement-privilege-prevention-set.md`.  
12. Leave Family 1 claiming to work when nginx-adm has no usable password.  
13. Script a password (`chpasswd`, `passwd --stdin`, hardcoded secret).  
14. Wrap the login hook in password `sudo` / `sudo -n`, or leave a stale `sudo … approve` managed block on re-run.  
15. Omit leading `--json` on Family 1 JSON argv, or emit `--json *` / `--json setup` as a Cmnd.  
16. Copy `/etc/sudoers.d/nginx-adm` from `setup`, or skip sibling JSON auto-queue by writing sudoers.d as a fallback.

**Violating this rule is a critical privilege / LLM-escape regression.**

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-13,14** | `tests/test_cli.sh` | have | print-sudoers / nginx-ctl unknown |
| **TP-NGX-01,14,15,34,50** | `tests/test_domain.sh` | have | setup euid; hook as-login (no sudo); replace stale sudo block; F6 two families static; passwd-ensure; Family 1 `--json` prefix |
| **TP-NGX-52,53** | `tests/test_domain.sh` | have | setup auto-queue JSON; MUST NOT write `/etc/sudoers.d` |
| **TP-NGX-16,17,19** | `tests/test_domain.sh` | have | submit-sudoer-request detect / stub / no Type 0 mkdir |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-least-privilege-user.md` | LPU identity F1–F7 |
| `docs/requirements/requirement-privilege-prevention-set.md` | Closed catalog of what is blocked vs must stay open |
| `docs/requirements/requirement-sudoer-json-file.md` | JSON grant body (`nginx-cli request` as `nginx-adm`) |
| `docs/requirements/requirement-domain-nginx-cli.md` | nginx-conf request/approve + verb catalog |
| `docs/requirements/requirement-shell-cli-interface.md` | Dispatcher / Type 0 catalog |
| `./src/nginx-cli` | Ship unit under test |

**Last Updated**: 2026-08-23 (1.5.0 — setup auto-queues Family 1 JSON; **MUST NOT** write `/etc/sudoers.d`)  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
