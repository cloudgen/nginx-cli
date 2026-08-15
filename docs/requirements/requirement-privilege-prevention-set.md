**file**: docs/requirements/requirement-privilege-prevention-set.md  
**Status**: Active (Version 1.0.0)  
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
| **PREV-PASSWD** | Write `/etc/passwd`, `/etc/group`, `/etc/shadow`, or `/etc/gshadow` | any type | Fail closed. Create/teardown the LPU with `useradd` / `userdel` only | LPU · three-layer |
| **PREV-SUDOERS-MAIN** | Write `/etc/sudoers` (the main file); Type 0 write `/etc/sudoers.d`; Type 1 write a **foreign** name under `/etc/sudoers.d` | Type 0 / foreign | Fail closed. This product **does** write product-owned names (`nginx-adm`, `nginx-cli-submit`) | three-layer · domain |
| **PREV-T0-USER** | Create or delete the LPU (`useradd` / `userdel`) | Type 0 | Fail closed; no account mutate | LPU · domain |
| **PREV-T0-QUEUE** | `mkdir` the production inbound / approved / rejected trio | Type 0 | Fail closed if the dir is missing | domain · LPU |
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
| **PREV-SUDO-N-CLI** | Bootstrap, login hook, or day-to-day `nginx-cli` documented or implemented as `sudo -n` | Type 1 / hook | Password `sudo` or a root login. Unit tools stay NOPASSWD | three-layer · domain |
| **PREV-T2** | A Type 2 execution euid for dest writes (`su` / `runuser` to the LPU) | design / code | Type 2 remains **Not used** | three-layer |
| **PREV-MAP-PUBLIC** | Put `user-domain-map` on the public queue root | setup / design | Map stays under LPU home | LPU · domain |
| **PREV-FIXTURE-VAR** | Write `/var/nginx-cli` from fixture mode | tests | Fixture queues stay under `/tmp` | domain |

#### 2.2.4 Request body

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-JSON-BODY** | Treat the request artifact as JSON | submit / approve | Body is `#` comments then nginx conf | domain |
| **PREV-SYMLINK-IN** | Inbound last component is a symlink; request dest is a symlink | submit / approve | Fail closed | domain |
| **PREV-NAME** | Caller-supplied dest basename | submit | Allocator owns `yyyyMMdd-user-domain-n` | domain |

#### 2.2.5 UX, hang, and test gates

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-EMPTY-INT** | Empty argv becoming `approve` | any uid | Empty argv is Type N help | CLI · zero-arguments · domain |
| **PREV-HELP** | Listing a verb in `help` that has no dispatcher arm; listing `print-sudoers` / `backup` / `nginx-ctl` | help | Must not list | CLI · domain |
| **PREV-HANG** | Prompt or hang when `TTY` is not `1`; login hook hanging `scp` / CI | `approve` / hook | Fail closed; hook skips when `PS1` unset | interactive · domain |
| **PREV-TEST-ROOTS** | Pointing production dest / queues at a fake root without fixture flags **and** `/tmp` paths | Type 0 / tests | Fail closed | domain |

### 2.3 What this product does **not** block (must remain open)

| ID | Must stay open | After / when | Why |
|----|----------------|--------------|-----|
| **OPEN-ELEV** | Run the Type 1 job the operator invoked | After password `sudo` **or** a root login | That elev **is** the approval. **MUST NOT** invent a second lock |
| **OPEN-SUDO** | The ship unit **MAY** invoke password `sudo` (outer **or** in-tool) | Mix model | “Avoid `sudo -n` on nginx-cli” is **not** “avoid `sudo`” |
| **OPEN-PASSWD-CLI** | nginx-adm **MUST** be able to `sudo /usr/local/bin/nginx-cli` day-to-day verbs **with a password** | After F6 | Dest F6 family 1 |
| **OPEN-UNIT-TOOLS** | nginx-adm **MUST** keep `NOPASSWD` `/usr/sbin/nginx` and unit `systemctl` / `journalctl` | After F6 | Dest F6 family 2. **MUST NOT** drop these when adding password `nginx-cli` |
| **OPEN-USERADD** | Type 1 `setup` / `remove-lpu` **MUST** call `useradd` / `userdel` | After euid 0 | Account create is a script job, not an F6 Cmnd |
| **OPEN-TOOLS** | Type 1 **MAY** run the OS tools the job needs (`mkdir`, `chmod`, `visudo -cf`, `install`, product-scoped `rm`, …) | After euid 0 | Table A is not a live-command catalog |
| **OPEN-UNLISTED** | A live tool that is **not** listed in Table A, Table B, or Table C is **not** forbidden | After euid 0 | No denylist ⇒ no extra restrict |
| **OPEN-BOOT-ANY** | **Any** host admin already euid 0 **MAY** run `setup` / `remove-lpu` | Bootstrap | F6 / LPU do not exist yet |
| **OPEN-ROOT-APPR** | A real root login **MAY** run `approve` / `reject` / map / hook | After euid 0 | Same Type 1 verbs as the F6 approver |
| **OPEN-ADM-APPR** | Login `nginx-adm` **MAY** run approve-family verbs | After setup | Actor table |
| **OPEN-LISTED-REQ** | A listed **and** grouped human **MAY** `request` mapped domains | After inbound exists | Actor table |
| **OPEN-CONFIRM** | The **only** extra gate after elev is TTY confirm or `--force` on **sensitive** undo-hard steps | After euid 0 | Confirm is not a new privilege class |
| **OPEN-NO-FLAG** | No env flag, Gap stub, or “not enabled” die on live `useradd` / F6 / hook after euid 0 | Type 1 `setup` | Nobody published that gate |
| **OPEN-NO-CI** | Continuous integration is **not** a product gate on `useradd` | Host vs suite | A suite that cannot enter a sudo password **MUST NOT** be rewritten as “create is forbidden” |
| **OPEN-NO-ISOL** | Test isolation (fixture dest roots, temp homes) is **not** a security wall on live `setup` | Host vs suite | Isolation is a test helper, not Type 1 law |
| **OPEN-TABLE-A** | Table A stays **two families**. It **MUST NOT** collapse to one NOPASSWD whole-binary line | emit | Sibling sudoer-cli shape is **not** this dest |
| **OPEN-TABLE-C** | Table C rows **MUST NOT** be copied into F6 | emit vs script | Wrong surface |
| **OPEN-ETC-USER** | Type 1 **MUST** put LPU home / map / hooks under `/etc/nginx-adm/` when free | After euid 0 | Prefer `/etc/{{username}}/`. There is **no** blanket “do not write `/etc`” |
| **OPEN-SUDOERS-D-EX** | Type 1 **MAY** write product-owned files under `/etc/sudoers.d/` (`nginx-adm`; create-if-absent `nginx-cli-submit`) | After euid 0 | Exception to the portable “do not write sudoers.d” default. Still **PREV-PASSWD**, **PREV-SUDOERS-MAIN** |
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
| **F6 file** | `/etc/sudoers.d/nginx-adm` = password `nginx-cli` day-to-day **plus** `NOPASSWD` unit tools |
| **Submit file** | `/etc/sudoers.d/nginx-cli-submit` (allowlist; Type 0 `request` as invoker) |
| **Usual bootstrap** | `sudo src/nginx-cli setup` or `sudo nginx-cli setup` (password `sudo` OK) |
| **Fixture** | `NGINX_CLI_FIXTURE=1` + homes/queues under `/tmp` |
| **Absent verbs** | `print-sudoers`, `nginx-ctl`, online self-update |
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
5. Write `/etc/passwd` or `/etc/sudoers` (main file), or invent a blanket “do not write `/etc`” that blocks `/etc/nginx-adm/` **or** this product’s Type 1 sudoers.d / sites-available writes.  
6. Use `--force` to skip Type 1 authz or to auto-approve.  
7. Document bootstrap or the login hook as `sudo -n nginx-cli`.  
8. Copy sudoer-cli prevention rows (3773 inbound, JSON schema, NOPASSWD whole CLI) as if they were this dest.

**Violating this rule is a critical privilege / invented-wall regression.**

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-04,10,13,14** | `tests/test_cli.sh` | have | no online / print-sudoers / backup / nginx-ctl |
| **TP-NGX-01,11,13,14,15** | `tests/test_domain.sh` | have | euid; no-TTY; no-mkdir; hook not `-n`; 2770 / F6 families |

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

**Last Updated**: 2026-08-15  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
