**file**: docs/requirements/requirement-privilege-prevention-set.md  
**Status**: Active (Version 1.6.0)  
**Area**: architecture  
**Key**: `requirement-privilege-prevention-set`  
**id**: RQ-PRIVILEGE-PREVENTION-SET  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **what this product blocks, stops, or prevents**, and for **what it must not block** after the operator has already elevated.

The Type 0 / Type 1 / Type 2 map and elev Tables A / B / C stay on `requirement-three-layer-privilege-model.md`. Least-privilege-approver identity (F1–F7) stays on `requirement-least-privilege-user.md`. nginx-conf request/approve verbs, basename, samples, queues, hook, and dest transform stay on `requirement-domain-nginx-cli.md`. This file **does not** replace those tables. It owns the **closed prevention catalog** and the **must-remain-open catalog**.

A wall that is not a §2.2 row is **not** product law.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Closed-list rule

1. A product **block** exists **only** when it has a row in §2.2.  
2. If an action is **not** listed in §2.2, the product **MUST NOT** stop it — unless this requirement is revised in the **same change** as the new block.  
3. Maintainers **MUST NOT** invent a wall that is not a §2.2 row. Invented walls include: an unpublished live-command whitelist; dropping Table A unit tools “for safety”; inventing a `nginx-ctl` command; putting `NOPASSWD` on `nginx-cli` because a sibling product did; a Gap stub on live `useradd` after euid 0; treating CI or fixture isolation as a security gate on `setup`.  
4. §2.3 is the **must-remain-open** catalog. Closing a §2.3 row **MUST** revise this file first.  
5. Table A is **only** the F6 sudoers lines. Table B is **only** what must not appear **in** the F6 fragment. Table C is **script jobs**. Those tables **MUST NOT** be reread as a live-command whitelist or denylist.  
6. **No published denylist ⇒ no extra restrict** on live tools a Type 1 job needs.

### 2.2 What this product blocks (closed catalog)

#### 2.2.1 Privilege actor

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-PASSWD** | Hand-edit `/etc/passwd`, `/etc/group`, `/etc/shadow`, or `/etc/gshadow`; `chpasswd`; `passwd --stdin`; any scripted secret | any type | Fail closed. Create/teardown the LPU with `useradd` / `userdel` only. Type 1 `setup` **MAY** invoke `passwd(1)` for **this** LPU so the operator types a password (JOB-PASSWD) | LPU · three-layer |
| **PREV-SUDOERS-MAIN** | Write `/etc/sudoers` (the main file); Type 0 **or Type 1 `setup`** write `/etc/sudoers.d` | Type 0 / Type 1 setup | Fail closed. Family 1 dest is sibling-approved `nginx-cli-nginx-adm`. Listed-submitter dest is `nginx-cli-<login>` | three-layer · domain |
| **PREV-T0-USER** | Create or delete the LPU (`useradd` / `userdel`) | Type 0 | Fail closed; no account mutate | LPU · domain |
| **PREV-T0-QUEUE** | `mkdir` the production inbound / approved / rejected trio | Type 0 | Fail closed if the dir is missing | domain · LPU |
| **PREV-T0-SUDOER-MKDIR** | `mkdir` sibling `/var/sudoer-cli/sudoer-request` (or its parent / F4 view) | Type 0 `submit-sudoer-request` | Fail closed if inbound missing | three-layer |
| **PREV-CONVERT-QUEUE** | `conf-to-json` / `json-to-conf` write dest inbound / approved / rejected | Type 0 convert | Fail closed. Convert never queues | domain |
| **PREV-CONVERT-DEST** | Convert write `${NGINX_CONF_ROOT}` or `/etc` | Type 0 convert | Fail closed | domain |
| **PREV-T1-EUID** | `setup` / `remove-lpu` without euid 0 | any login | Fail closed; tell the operator to run `sudo nginx-cli setup` (password `sudo`; **not** `sudo -n`) | three-layer · domain |
| **PREV-APPR-ACTOR** | `approve` / `reject` / `map-set` / `map-unset` / `enable-login-approval` when the actor is a listed submitter or anyone else | non-root, non-nginx-adm | Fail closed `authz` | domain |
| **PREV-SUBMIT-UNLISTED** | `request` when the actor is not root, not nginx-adm, and not (listed **and** grouped) | anyone else | Fail closed | domain |
| **PREV-SUBMIT-HALF** | Treat group membership alone, or sudoers listing alone, as submit | listed xor grouped | Fail closed | domain |
| **PREV-BEHALF** | Listed human submits a domain not in that login’s `user-domain-map` | Type 0 submit | Fail closed | domain |
| **PREV-FORCE-AUTHZ** | `--force` skipping Type 1 authz, or `--force` auto-approving the walk | Type 1 | Still fail `authz`; still prompt | domain |

#### 2.2.2 F6 fragment and dest writes

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-F6-ALL** | `ALL=(ALL) ALL` or `NOPASSWD: ALL` in F6 | emit / install | Must not emit | three-layer Table B |
| **PREV-F6-SHELL** | `/bin/sh`, `/bin/bash`, or an unrestricted shell as an F6 Cmnd | emit / install | Must not emit | three-layer Table B |
| **PREV-F6-CMND** | `useradd`, `visudo`, `rm`, or a package manager as an **F6 sudoers Cmnd** | emit / install | Must not emit. Account create is a Table C job | three-layer Table B |
| **PREV-F6-LOCAL** | Elevate `${USER_BIN}/nginx-cli` or an ad-hoc `/tmp` binary as production F6 | emit / install | Must not emit | three-layer |
| **PREV-F6-NOPASSWD-CLI** | `NOPASSWD` on any `/usr/local/bin/nginx-cli` line | emit / install / hook | Must not emit; hook **MUST NOT** use `sudo -n` | three-layer · domain |
| **PREV-F6-BOOT-CMND** | `setup` / `remove-lpu` / `install` / `uninstall` on F6 | emit / install | Must not emit | three-layer |
| **PREV-NGINX-CTL** | Invent or allowlist a **`nginx-ctl` command** | emit / help / law | That command **does not exist** | three-layer · domain |
| **PREV-GITLAB-CTL** | `gitlab-ctl` as an F6 Cmnd | emit / install | Must not emit | three-layer |
| **PREV-WORLD-WX** | Mode inbound world-writable (`0777` or `3773` other `-wx`) | setup / design | Forbidden on this dest; inbound is **2770** | LPU · domain |
| **PREV-MV-INBOUND** | `mv` the live inbound name after validate | approve / reject | Snapshot + unlink only | domain |
| **PREV-CHOWN-REQ** | `chown` a submitted request to nginx-adm | submit / approve | Owner stays the submitter | domain |
| **PREV-PUBLISH-REJECT** | Publish on reject | reject | Archive + unlink only | domain |
| **PREV-FOREIGN-SITE** | Type 0 write live `sites-available` / `sites-enabled` | Type 0 | Fail closed | domain |

#### 2.2.3 Identity, teardown, elev path

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-COLLIDE** | `setup` when UID, GID, or LPU name exists and is **not** this identity | Type 1 bootstrap | Exit non-zero; no partial create | LPU |
| **PREV-UNINST-F7** | Type 0 `uninstall` treated as LPU teardown | Type 0 | `uninstall` removes the **managed binary only** | LPU · local-self-management |
| **PREV-USERDEL-QUEUES** | Rely on `userdel -r` to remove `/var/nginx-cli` | F7 | F7 **MUST** backup+remove the public root first | LPU |
| **PREV-SUDO-N-CLI** | Bootstrap, login hook, or day-to-day `nginx-cli` documented or implemented as `sudo -n` | Type 1 / hook | Password `sudo` (Family 1 / bootstrap) or a root login; login hook is as-login (no sudo). Unit tools stay NOPASSWD | three-layer · domain |
| **PREV-HOOK-SUDO** | Login hook documented or implemented as `sudo … nginx-cli approve` (password or `-n`) | Type 1 / hook | As-login `${GLOBAL_BIN}/nginx-cli approve`. Family 1 stays password sudo for explicit sudo | domain · three-layer |
| **PREV-T2** | A Type 2 execution euid for dest writes (`su` / `runuser` to the LPU) | design / code | Type 2 remains **Not used** | three-layer |
| **PREV-MAP-PUBLIC** | Put `user-domain-map` on the public queue root | setup / design | Map stays under LPU home | LPU · domain |
| **PREV-FIXTURE-VAR** | Write `/var/nginx-cli` from fixture mode | tests | Fixture queues stay under `/tmp` | domain |

#### 2.2.4 Request body

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-JSON-BODY** | Treat dest inbound as nginx-text-only (no JSON envelope) | submit / approve | Queued body is dest request **JSON**; text is a dual | domain |
| **PREV-JSON-GATE** | Feed raw dest JSON to `nginx -t` | approve | Render text dual first | domain |
| **PREV-SYMLINK-IN** | Inbound last component is a symlink; request dest is a symlink | submit / approve | Fail closed | domain |
| **PREV-NAME** | Caller-supplied dest basename | submit | Allocator owns `yyyyMMdd-user-domain-n.json` | domain |

#### 2.2.5 UX, hang, and test gates

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-EMPTY-INT** | Empty argv becoming `approve` | any uid | Empty argv is Type N help | CLI · zero-arguments · domain |
| **PREV-HELP** | Listing a verb in `help` that has no dispatcher arm; listing `print-sudoers` / `backup` / `nginx-ctl` | help | Must not list. **Must** list `submit-sudoer-request`, `conf-to-json`, `json-to-conf` | CLI · domain |
| **PREV-SUBMIT-OS-TOOL** | Type 0 compose JSON that lists OS tools, `approve`, `setup`, or `kind=login-hook-elev` | Type 0 compose | Fail closed | sudoer-json-file |
| **PREV-HANG** | Prompt or hang when `TTY` is not `1`; login hook hanging `scp` / CI | `approve` / hook | Fail closed; hook skips when `PS1` unset | interactive · domain |
| **PREV-TEST-ROOTS** | Pointing production dest / queues at a fake root without fixture flags **and** `/tmp` paths | Type 0 / tests | Fail closed | domain |

### 2.3 What this product does **not** block (must remain open)

| ID | Must stay open | After / when | Why |
|----|----------------|--------------|-----|
| **OPEN-ELEV** | Run the Type 1 job the operator invoked | After password `sudo` **or** a root login | That elev **is** the approval. **MUST NOT** invent a second lock |
| **OPEN-SUDO** | The ship unit **MAY** invoke password `sudo` (outer **or** in-tool) | Mix model | “Avoid `sudo -n` on nginx-cli” is **not** “avoid `sudo`” |
| **OPEN-PASSWD-CLI** | nginx-adm **MUST** be able to `sudo /usr/local/bin/nginx-cli` day-to-day verbs **with a password** | After F6 | Dest F6 family 1. `setup` **MUST** TTY-`passwd` or warn; a locked account is a setup gap |
| **OPEN-ADM-NOSUDO** | Login `nginx-adm` **MAY** run day-to-day verbs **without** sudo | After setup | `ngx_can_approve` / `ngx_can_submit`. The login hook **MUST** use this path. Does not replace Family 1 |
| **OPEN-UNIT-TOOLS** | nginx-adm **MUST** keep `NOPASSWD` `/usr/sbin/nginx` and unit `systemctl` / `journalctl` | After F6 | Dest F6 family 2. **MUST NOT** drop these when adding password `nginx-cli` |
| **OPEN-USERADD** | Type 1 `setup` / `remove-lpu` **MUST** call `useradd` / `userdel` | After euid 0 | Account create is a script job, not an F6 Cmnd |
| **OPEN-TOOLS** | Type 1 **MAY** run the OS tools the job needs (`mkdir`, `chmod`, `visudo -cf`, `install`, product-scoped `rm`, …) | After euid 0 | Table A is not a live-command catalog |
| **OPEN-UNLISTED** | A live tool that is **not** listed in Table A, Table B, or Table C is **not** forbidden | After euid 0 | No denylist ⇒ no extra restrict |
| **OPEN-BOOT-ANY** | **Any** host admin already euid 0 **MAY** run `setup` / `remove-lpu` | Bootstrap | F6 / LPU do not exist yet |
| **OPEN-ROOT-APPR** | A real root login **MAY** run `approve` / `reject` / map / hook | After euid 0 | Same Type 1 verbs as the F6 approver |
| **OPEN-ADM-APPR** | Login `nginx-adm` **MAY** run approve-family verbs | After setup | Actor table |
| **OPEN-LISTED-REQ** | A listed **and** grouped human **MAY** `request` mapped domains | After inbound exists | Actor table. Listed = shared allowlist **or** per-user `/etc/sudoers.d/nginx-cli-<login>` |
| **OPEN-SUBMIT-SUDOER** | Any login **MAY** run Type 0 `submit-sudoer-request` | Sibling present | Compose; not nginx-conf `request` |
| **OPEN-CONVERT** | Any login **MAY** run Type 0 `conf-to-json` / `json-to-conf` | Always | Local dual only; not dest write |
| **OPEN-CONFIRM** | The **only** extra gate after elev is TTY confirm or `--force` on **sensitive** undo-hard steps | After euid 0 | Confirm is not a new privilege class |
| **OPEN-NO-FLAG** | No env flag, Gap stub, or “not enabled” die on live `useradd` / F6 / hook after euid 0 | Type 1 `setup` | Nobody published that gate |
| **OPEN-NO-CI** | Continuous integration is **not** a product gate on `useradd` | Host vs suite | A suite that cannot enter a sudo password **MUST NOT** be rewritten as “create is forbidden” |
| **OPEN-NO-ISOL** | Test isolation (fixture dest roots, temp homes) is **not** a security wall on live `setup` | Host vs suite | Isolation is a test helper, not Type 1 law |
| **OPEN-TABLE-A** | Table A stays **two families**. It **MUST NOT** collapse to one NOPASSWD whole-binary line | emit | Sibling sudoer-cli shape is **not** this dest |
| **OPEN-TABLE-C** | Table C rows **MUST NOT** be copied into F6 | emit vs script | Wrong surface |
| **OPEN-ETC-USER** | Type 1 **MUST** put LPU home / map / hooks under `/etc/nginx-adm/` when free | After euid 0 | Prefer `/etc/{{username}}/`. There is **no** blanket “do not write `/etc`” |
| **OPEN-SETUP-JSON** | Type 1 `setup` **MAY** write `login-hook-elev` JSON into sibling inbound when dest exists | After euid 0 | Not Type 0 `submit-sudoer-request`. **MUST NOT** `mkdir` inbound or write `/etc/sudoers.d` |
| **OPEN-SITES** | Type 1 approve **MAY** write `${NGINX_CONF_ROOT}/sites-available` and enable-dir symlinks | After authz | That is the dest of this machine |

### 2.4 Sensitive is not blocked

These steps are **hard to undo**. They stay **allowed** after elev. The extra gate is confirm or `--force` only.

| Step | Extra gate | Still allowed after elev? |
|------|------------|---------------------------|
| Type 0 `uninstall` (managed binary only) | TTY confirm; non-interactive requires `--force` | yes |
| Type 1 `remove-lpu` / `userdel -r` | TTY confirm unless `--force` | yes |

`--force` **MUST NOT** skip §2.2 authz rows (**PREV-FORCE-AUTHZ**).

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `nginx-cli` |
| **Ship unit** | `src/nginx-cli` |
| **LPU** | `nginx-adm` (UID/GID `1999`, create home `/etc/nginx-adm`; public queues `/var/nginx-cli/` inbound **2770**) |
| **Family 2 file** | `/etc/nginx-adm/sudoers` = NOPASSWD unit tools only |
| **Family 1 dest** | `/etc/sudoers.d/nginx-cli-nginx-adm` after sibling approve (JSON auto-queue) |
| **Listed-submitter dest** | `/etc/sudoers.d/nginx-cli-<login>` after sibling approve |
| **Usual bootstrap** | `sudo src/nginx-cli setup` or `sudo nginx-cli setup` (password `sudo` OK) |
| **Login hook** | `/usr/local/bin/nginx-cli approve` as-login (**no** `sudo`; **PREV-HOOK-SUDO**) |
| **Fixture** | `NGINX_CLI_FIXTURE=1` + homes/queues under `/tmp` |
| **Absent verbs** | `print-sudoers`, `nginx-ctl`, online self-update |
| **Present compose** | `submit-sudoer-request` (Type 0; no `/etc` write) |
| **Sensitive confirms** | `uninstall`; `remove-lpu` |

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: The block list is written down. Agents do not invent a second security story.  
- **CIAO Principle 9 – Three Types of Commands**: Type 0 stays Type 0; Type 1 after elev is not re-gated.  
- **CIAO Principle 10 – Least privilege**: Size the job **before** elev. After elev, least privilege is **not** “invent a command allowlist” or “drop unit tools.”  
- **CIAO Principle 1 – Caution**: Fail closed on the published rows; fail loud; do not silently skip `useradd`.  
- **CIAO Principle 4 / 20 – Over-protect**: Over-protect the **closed list** and the **must-remain-open** list — not an unpublished extra wall.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Only published rows stop an action. Unknown tools are not silently denied.  
- **Intentional**: Block vs open is a pair. One catalog without the other is incomplete.  
- **Anti-fragile**: Password `sudo` / root login works on a real host; CI not being able to type a password does not rewrite the product.  
- **Over-protect**: Adding a new block without revising this file is a privilege regression (the agent took the power to lock the operator out).

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Add a product block that is not a §2.2 row without revising this file in the same change.  
2. Close a §2.3 row (drop `NOPASSWD` unit tools; put `NOPASSWD` on `nginx-cli`; require `sudo -n` for `setup`; require the operator to already be the LPU; invent `nginx-ctl`; die “not enabled”).  
3. Put Table C OS tools into Table A **or** refuse to run those tools after euid 0 because they are not in Table A.  
4. Invent a Type 2 euid, or `su` / `runuser` to the LPU, in order to write dest.  
5. Write `/etc/passwd` or `/etc/sudoers` (main file) by hand, or invent a blanket “do not write `/etc`” that blocks `/etc/nginx-adm/` **or** Type 1 sites-available writes. Type 1 **MUST NOT** write `/etc/sudoers.d`. Type 1 **MAY** run `passwd nginx-adm`. **MUST NOT** `chpasswd` or put a password on a command line.  
6. Use `--force` to skip Type 1 authz or to auto-approve.  
7. Document bootstrap or the login hook as `sudo -n nginx-cli`.  
8. Copy sudoer-cli prevention rows (3773 inbound, JSON schema, NOPASSWD whole CLI) as if they were this dest.  
9. Wrap the nginx-adm login hook in password `sudo` or leave a stale `sudo … approve` managed block on re-run (`PREV-HOOK-SUDO`).

**Violating this rule is a critical privilege / invented-wall regression.**

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-04,10,13,14** | `tests/test_cli.sh` | have | no online / print-sudoers / backup / nginx-ctl; help lists submit-sudoer-request |
| **TP-NGX-01,11,13,14,15,34,50** | `tests/test_domain.sh` | have | euid; no-TTY; no-mkdir; hook as-login (no sudo); replace stale sudo block; 2770 / F6 families; passwd-ensure |
| **TP-NGX-52,53** | same | have | setup auto-queue Family 1 JSON; MUST NOT write `/etc/sudoers.d` |
| **TP-NGX-16,18,19** | same | have | compose fail-closed / refuse OS-tool / no Type 0 sibling mkdir |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Type map + Tables A/B/C |
| `docs/requirements/requirement-least-privilege-user.md` | F1–F7 identity |
| `docs/requirements/requirement-domain-nginx-cli.md` | nginx-conf request/approve |
| `docs/requirements/requirement-shell-cli-interface.md` | Dispatcher / Type 0 catalog |
| `./src/nginx-cli` | Ship unit |

**Last Updated**: 2026-08-23 (1.6.0 — setup MUST NOT write `/etc/sudoers.d`; Family 1 via sibling JSON)  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
