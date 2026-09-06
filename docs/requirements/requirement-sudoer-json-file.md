**file**: docs/requirements/requirement-sudoer-json-file.md  
**Status**: Active (Version 1.2.0)  
**Area**: architecture  
**Key**: `requirement-sudoer-json-file`  
**id**: RQ-SUDOER-JSON-FILE  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for the **JSON-type sudoer file**: the machine encoding of **two** elevation grants that share one closed schema and are split by field **`kind`**.

| `kind` | Who (`username`) | `commands[].runas` | Args | Who queues |
|--------|------------------|--------------------|------|------------|
| **`type-2-switch`** | Invoking login | `nginx-adm` | `["request"]` | Type 0 `submit-sudoer-request`. **No sudo.** |
| **`login-hook-elev`** | LPU `nginx-adm` | `root` | Family 1 day-to-day verbs **and** the same verbs with a leading `--json` | Type 1 `setup` **automatically** when sibling `sudoer-cli` + `sudoer-adm` + inbound exist. Type 0 submit **MUST** refuse this kind |

Both grants **MUST** name only the project command **`nginx-cli`**. They **MUST NOT** allowlist other shell or OS tools. They **MUST NOT** grant `setup` / `remove-lpu` / `install` / `uninstall`. Extra tools increase design complexity and weaken security.

**Dest-honest vs dns-cli:** sibling dest uses the same `kind` enum. This dest’s login hook is **as-login** `/usr/local/bin/nginx-cli-hook approve` (**no** `sudo`, **no** `sudo -n`). The `login-hook-elev` JSON is **Family 1** (password `sudo nginx-cli <verb>` after dest approve). **MUST NOT** copy dns-cli `args: ["interactive"]` or `NOPASSWD` on this kind. **MUST NOT** wrap the login hook in sudo because this JSON exists.

This file does **not** own:

| Concern | Owner |
|---------|--------|
| Type 0/1/2 map, Table A/B/C, setup auto-queue **workflow** (detect / no inbound `mkdir` / no `/etc/sudoers.d` write) | `requirement-three-layer-privilege-model` |
| Domain verb catalog / help / about / nginx-conf request body | `requirement-domain-nginx-cli` |
| Closed prevention catalog | `requirement-privilege-prevention-set` |

Queued **basename** allocation remains sibling-owned. This requirement owns **command identity, `kind`, and JSON body shape**.

**print-sudoers is not this product’s emit path.** Type 0 default input is the `type-2-switch` JSON. Type 1 `setup` writes `login-hook-elev` into sibling inbound (not `/etc/sudoers.d`).

### 1.1 Human-facing

**In one sentence:** Host admin `setup` drops a JSON grant for nginx-adm into `/var/sudoer-cli/sudoer-request`; sudoer-adm approves it into `/etc/sudoers.d/nginx-cli-nginx-adm`. You queue your own `request` ticket with `nginx-cli submit-sudoer-request`.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Queue a submitter ticket as yourself | `nginx-cli submit-sudoer-request` |
| sudoer-adm | Approves waiting JSON | sibling dest inbound |
| Not this file | nginx-conf waiting files | `/var/nginx-cli/config-request` |

| Includes | Excludes |
|----------|----------|
| Two JSON kinds; Family 1 `--json` argv; no `/etc/sudoers.d` from setup | dns-cli `interactive` + NOPASSWD; OS-tool grants; Type 0 queue of Family 1 |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/var/sudoer-cli/sudoer-request` | sibling inbound | waiting JSON |
| `nginx-cli setup` | command | auto-queue Family 1 when dest exists |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| First-time host | Create nginx-adm; if sudoer-cli is already set up, a Family 1 grant waits for sudoer-adm. Login hook still runs `nginx-cli approve` with no sudo. | `sudo nginx-cli setup` then, as sudoer-adm, review inbound |

## Under command line for normal user only

On Termux, Git Bash, or Windows cmd, Type 1 auto-queue of Family 1 JSON **MUST** stay unused (`setup` unused). Type 0 `submit-sudoer-request` **MAY** still queue a submitter grant when sibling inbound already exists; it **MUST NOT** `mkdir` that inbound.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 What a JSON sudoer file is

1. A JSON sudoer file is a **closed-schema object** that states: who may elevate, which **product** the grant is for, add vs update, and a **commands** list.  
2. It is **not** `sudoers(5)` text. It is **not** this product’s `--json` CLI status. It is **not** an nginx-conf request file.  
3. Sibling approval software **MAY** convert a text dual into this JSON. Conversion **MUST NOT** invent OS-tool commands that this requirement forbids.  
4. If both a text fragment and a JSON sudoer file represent the **same** grant, they **MUST** be equivalent **for that `kind`**. A text file that allowlists `mkdir`/`cp`/`systemctl`/`nginx` **MUST NOT** be treated as a valid dual.

### 2.2 Command identity — `{{PRJ_NAME}}` only (sacred)

**`{{PRJ_NAME}}`** is the product command (the ship-unit basename). It is the **only** elevated program this JSON may grant.

| Rule | Detail |
|------|--------|
| **Identity** | Every `commands[].path` **MUST** be the **managed global** product command: `{{GLOBAL_BIN}}/{{PRJ_NAME}}` |
| **Basename** | `basename(path)` **MUST** equal `{{PRJ_NAME}}` |
| **One program** | The grant **MUST NOT** list any other executable |
| **No local binary** | **MUST NOT** elevate `{{USER_BIN}}/{{PRJ_NAME}}` (user-rewritable; not production-secure) |
| **No OS tools** | **MUST NOT** list `cp`, `mkdir`, `install`, `chmod`, `tar`, `rm`, `ln`, `mv`, `chown`, `dd`, `systemctl`, `journalctl`, `nginx`, or any shell (`sh`, `bash`, `dash`) — including `/bin/*` and `/usr/bin/*` twins |
| **No ALL** | **MUST NOT** use `ALL`, `NOPASSWD: ALL`, or an empty/unrestricted command set |
| **Not unit tools** | This JSON **MUST NOT** grant `systemctl`, `journalctl`, or `nginx`. Family 2 stays a Type 1 unit-tools file **not** under `/etc/sudoers.d/` |
| **Not bootstrap** | **MUST NOT** grant `setup`, `remove-lpu`, `install`, or `uninstall` |

**Why OS-tool grants are forbidden:** extra sudoers lines are extra ways to be wrong. After sudoer-adm approves this grant, dest Type 0 `request` still runs as the invoker. The grant is the **listed-submitter** ticket (sibling dest `/etc/sudoers.d/{{PRJ_NAME}}-{{username}}`), not a catalog of root helpers.

### 2.3 Arguments — by kind (sacred)

| `kind` | `commands[].runas` | `commands[].tags` | `commands[].args` |
|--------|--------------------|-------------------|-------------------|
| **`type-2-switch`** | `nginx-adm` | `NOPASSWD` **MAY** (submit-allowlist shape) | **exactly** `["request"]` |
| **`login-hook-elev`** | `root` | **MUST** be empty (Family 1 is **password**; **MUST NOT** `NOPASSWD`) | Family 1 verbs from Table A: each of `approve`, `reject *`, `request`, `request *`, `list-requests`, `list-requests *`, `list-approved`, `list-approved *`, `list-rejected`, `list-rejected *`, `map-set *`, `map-unset *`, `map-list`, `map-list *`, `enable-login-approval`, `enable-login-approval *` **and** the same argv with a leading `--json`. Operand `"*"` is a sudoers one-operand wildcard. |

1. **MUST NOT** put domain names, inbound paths, host HOME, or request basenames in `args`.  
2. **MUST NOT** grant `{{PRJ_NAME}}` with **no** verb (whole CLI as the LPU or as root).  
3. **`type-2-switch` MUST NOT** grant `approve`, `reject`, `map-*`, `enable-login-approval`.  
4. **`login-hook-elev` MUST NOT** grant `interactive` (that verb is not this dest). **MUST NOT** freeze `--force` / `--quiet` after the verb.  
5. Type 0 `submit-sudoer-request` **MUST** refuse `kind=login-hook-elev` and any body whose `username` ≠ `id -un`.

### 2.4 Closed schema (normative)

| Field | Type | Required | Rule |
|-------|------|----------|------|
| `schema_version` | integer | yes | `1` for this requirement |
| `kind` | string | yes on emit | `type-2-switch` or `login-hook-elev`. Missing on Type 0 input: treat as `type-2-switch` **only if** `runas` is `nginx-adm` and `args` is `["request"]`; else fail closed |
| `purpose` | string | yes | Human purpose; no secrets |
| `username` | string | yes | `type-2-switch`: invoking login (self-scope). `login-hook-elev`: `nginx-adm`. Never `ALL` |
| `service` | string | yes | **MUST** equal `{{PRJ_NAME}}` |
| `action` | string | yes | `add` or `update` only |
| `commands` | array | yes | Non-empty; every element obeys §2.2–2.3 |
| `commands[].runas` | string | yes | Per kind. **MUST NOT** be `ALL` |
| `commands[].tags` | array | yes | Per kind. `login-hook-elev` **MUST** be `[]` |
| `commands[].path` | string | yes | Absolute `{{GLOBAL_BIN}}/{{PRJ_NAME}}` only |
| `commands[].args` | array of strings | yes | Per kind |
| `submit_app` | string | yes (add/update) | Live Config `APP_NAME` of **this** submitter. Sibling dest **MUST NOT** fence if ≠ `sudoer-cli` |
| `submit_version` | string | yes (add/update) | Live Config `VERSION` of **this** submitter. Sibling dest **MUST NOT** fence if ≠ sibling dest version |

Type 0 `submit-sudoer-request` **MUST** overwrite `submit_app` / `submit_version` from live Config. Dest **MUST NOT** dest-write those keys.

**MUST NOT** add undeclared privilege fields (extra binaries, `env_keep` shells, `ALL`). Unknown sibling metadata **MUST NOT** widen `commands`.

### 2.5 Filename grammar (queued artifact — sibling allocator)

This product **MUST NOT** invent the dest basename. Sibling grammar (informative for pairing):

```text
sudoer-{{YYYYMMDD}}-{{PRJ_NAME}}-{{username}}-{{action}}-{{n}}.json
```

**Worked sample basename (`type-2-switch` add):** `sudoer-20260823-nginx-cli-alice-add-1.json`  
**Worked sample basename (`login-hook-elev` add):** `sudoer-20260823-nginx-cli-nginx-adm-add-1.json`  
**Worked dest after sibling approve (`type-2-switch`):** `/etc/sudoers.d/nginx-cli-alice`  
**Worked dest after sibling approve (`login-hook-elev`):** `/etc/sudoers.d/nginx-cli-nginx-adm`

### 2.6 Complete sample bodies (same grant; add vs update)

Normative **add** JSON (this project’s filled values — see §2.8):

```json
{
  "schema_version": 1,
  "kind": "type-2-switch",
  "purpose": "Allow alice to submit nginx-cli config requests as nginx-adm.",
  "username": "alice",
  "service": "nginx-cli",
  "action": "add",
  "commands": [
    {
      "runas": "nginx-adm",
      "tags": ["NOPASSWD"],
      "path": "/usr/local/bin/nginx-cli",
      "args": ["request"]
    }
  ],
  "submit_app": "nginx-cli",
  "submit_version": "1.7.0"
}
```

Normative **update** JSON (same commands; `action` only changes):

```json
{
  "schema_version": 1,
  "kind": "type-2-switch",
  "purpose": "Allow alice to submit nginx-cli config requests as nginx-adm.",
  "username": "alice",
  "service": "nginx-cli",
  "action": "update",
  "commands": [
    {
      "runas": "nginx-adm",
      "tags": ["NOPASSWD"],
      "path": "/usr/local/bin/nginx-cli",
      "args": ["request"]
    }
  ],
  "submit_app": "nginx-cli",
  "submit_version": "1.7.0"
}
```

Equivalent **text dual** of the **`type-2-switch`** grant:

```text
# Purpose: Allow alice to submit nginx-cli config requests as nginx-adm.
alice ALL=(nginx-adm) NOPASSWD: /usr/local/bin/nginx-cli request
```

Normative **`login-hook-elev` add** JSON (Family 1; **no** `NOPASSWD`; login hook stays as-login):

```json
{
  "schema_version": 1,
  "kind": "login-hook-elev",
  "purpose": "Allow nginx-adm to sudo /usr/local/bin/nginx-cli day-to-day verbs with a password. Login hook stays as-login approve without sudo.",
  "username": "nginx-adm",
  "service": "nginx-cli",
  "action": "add",
  "commands": [
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["approve"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "approve"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["approve", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "approve", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["reject", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "reject", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["request"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "request"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["request", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "request", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["list-requests"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "list-requests"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["list-requests", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "list-requests", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["list-approved"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "list-approved"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["list-approved", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "list-approved", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["list-rejected"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "list-rejected"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["list-rejected", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "list-rejected", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["map-set", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "map-set", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["map-unset", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "map-unset", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["map-list"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "map-list"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["map-list", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "map-list", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["enable-login-approval"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "enable-login-approval"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["enable-login-approval", "*"]},
    {"runas": "root", "tags": [], "path": "/usr/local/bin/nginx-cli", "args": ["--json", "enable-login-approval", "*"]}
  ],
  "submit_app": "nginx-cli",
  "submit_version": "1.7.0"
}
```

Normative **`login-hook-elev` update** JSON: same object; `"action": "update"` only.

Equivalent **text dual** of **`login-hook-elev`** (password; **no** `NOPASSWD:`):

```text
nginx-adm ALL=(root) /usr/local/bin/nginx-cli approve
nginx-adm ALL=(root) /usr/local/bin/nginx-cli --json approve
nginx-adm ALL=(root) /usr/local/bin/nginx-cli approve *
nginx-adm ALL=(root) /usr/local/bin/nginx-cli --json approve *
```

(same Family 1 argv set as Table A Family 1; unit tools are **not** in this dual.)

**Withdrawn (forbidden) encodings** — do not copy into a JSON sudoer file:

```json
{ "path": "/usr/sbin/nginx", "args": ["-t"] }
```

```json
{ "kind": "login-hook-elev", "commands": [{"runas": "root", "tags": ["NOPASSWD"], "path": "/usr/local/bin/nginx-cli", "args": ["interactive"]}] }
```

```json
{ "kind": "type-2-switch", "commands": [{"runas": "nginx-adm", "args": ["approve"]}] }
```

OS-tool complexity is a security defect. dns-cli `interactive` + `NOPASSWD` is **not** this dest. `approve` belongs **only** on `login-hook-elev`, never on Type 0 `type-2-switch`.

### 2.7 Submit / emit honesty

1. When `submit-sudoer-request` builds or accepts a JSON sudoer file, the body **MUST** satisfy §2.2–2.4 **and** be `kind=type-2-switch`.  
2. Type 0 **MUST** fail closed if an input file’s `commands` contain a forbidden path, OS-tool basename, `kind=login-hook-elev`, `runas` root, or Family 1 verbs (`approve`, `reject`, `map-*`, `enable-login-approval`).  
3. Type 0 **MUST** fail closed if `username` ≠ `id -un`.  
4. **MUST NOT** “fix” a forbidden file by submitting it anyway.  
5. Type 1 `setup` auto-queue of `login-hook-elev` is **not** this Type 0 verb (workflow on `requirement-three-layer-privilege-model`).  
6. Trust-tier gates (production vs test_local) remain on `requirement-three-layer-privilege-model`. This requirement does not weaken those gates.

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **`{{PRJ_NAME}}` / `APP_NAME`** | `nginx-cli` |
| **`{{GLOBAL_BIN}}`** | `/usr/local/bin` |
| **Elevated path** | `/usr/local/bin/nginx-cli` |
| **Kinds** | `type-2-switch` · `login-hook-elev` |
| **Allowed args (`type-2-switch`)** | `request` |
| **Allowed args (`login-hook-elev`)** | Family 1 Table A verbs + leading `--json` (complete sample in §2.6) |
| **runas** | `type-2-switch`: `nginx-adm`. `login-hook-elev`: `root` |
| **Forbidden paths (examples)** | `/usr/sbin/nginx`, `/bin/systemctl`, `/usr/bin/systemctl`, `/usr/bin/mkdir`, `/bin/mkdir`, `/usr/bin/cp`, `/bin/sh` |
| **Forbidden on Type 0** | `approve`, `reject`, `setup`, `remove-lpu`, `install`, `uninstall`, `kind=login-hook-elev` |
| **Ship unit** | `src/nginx-cli` — Type 1 `setup` auto-queues `login-hook-elev`; Type 0 `submit-sudoer-request` is `type-2-switch` only |
| **Submit verb** | `submit-sudoer-request` → `ngx_submit_sudoer_request` (`type-2-switch` only) |
| **Setup auto-queue** | Type 1 `setup` writes `login-hook-elev` into `/var/sudoer-cli/sudoer-request` when sibling exists |
| **Service field** | `nginx-cli` |
| **Worked user in samples** | `alice` (illustrative login; live emit uses `id -un`) |
| **Privilege / workflow peer** | `requirement-three-layer-privilege-model` |
| **print-sudoers** | **Absent** — default submit input is this JSON grant |

### 2.9 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 10 – Least privilege**: the compose grant is one managed binary and one verb — not a catalog of root `cp`/`mkdir`/`nginx`.  
- **CIAO Principle 1 – Caution**: Extra sudoers lines are extra ways to be wrong.  
- **CIAO Principle 2 – Intentional**: The JSON file means “this user may be a listed nginx-cli submitter,” not “this user is nginx-adm.”  
- **CIAO Principle 9 – Type 0 / 1 / 2**: JSON is the Type 0 compose **proposal**. Sibling sudoer-adm still must approve. Dest Type 0 `request` still runs as the invoker.  
- **CIAO Principle 21 – Dual policies**: Core rules use `{{PRJ_NAME}}` / `{{GLOBAL_BIN}}`; this section fills `nginx-cli` and `/usr/local/bin`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Refuse OS-tool JSON and F6 verbs even if a sibling product used them.  
- **Intentional:** `service` and `path` basename are the same name: `{{PRJ_NAME}}`.  
- **Anti-fragile:** Domain names and inbound paths stay in Config; changing `NGINX_QUEUE_ROOT` must not require a new sudoers JSON.  
- **Over-protect:** Type 0 is verb-bound `request` only. Family 1 `approve` is **only** on `login-hook-elev`, password tags empty, never Type 0.  
- **Stay-honest:** This dest does **not** copy folder-backup `backup`/`restore` or sudoer-cli `webservice` unit-tool grants.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Put `cp`, `mkdir`, `install`, `chmod`, `tar`, `rm`, `systemctl`, `journalctl`, `nginx`, or a shell in a JSON sudoer file `commands` list.  
2. Grant `approve` / map verbs on **Type 0** `type-2-switch`, or `NOPASSWD` / `interactive` on `login-hook-elev`.  
3. Elevate `{{USER_BIN}}/{{PRJ_NAME}}` in this JSON.  
4. Grant `{{PRJ_NAME}}` with no verb (whole CLI as root or as the LPU).  
5. Copy folder-backup `backup`/`restore` or sudoer-cli `webservice` samples as this dest’s grant.  
6. Duplicate submit/install workflow law here (that stays on the privilege peer).  
7. Store secrets in the JSON body.  
8. Reintroduce `print-sudoers` as the body SSOT.  
9. Cite templates or skills as product-source authority for this grant.  
10. Collapse the two kinds, drop `kind`, let Type 0 queue `login-hook-elev`, or write `/etc/sudoers.d` from `setup` as a fallback.  
11. Copy dns-cli `NOPASSWD` + `args: ["interactive"]` onto this dest’s `login-hook-elev`.

**Violating this rule is a critical privilege / complexity-as-insecurity regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Every `commands[].path` is `/usr/local/bin/nginx-cli` |
| AC-2 | `service` equals `nginx-cli` |
| AC-3 | `type-2-switch` `args` are only `request`; `runas` is `nginx-adm` |
| AC-3b | `login-hook-elev` `username` is `nginx-adm`; `runas` is `root`; `tags` is `[]`; args include `--json` prefixes; no `interactive`; no `NOPASSWD` |
| AC-3c | Type 0 submit of `login-hook-elev` fails closed |
| AC-3d | `setup` auto-queues `login-hook-elev` when sibling exists; skips when missing; **MUST NOT** write `/etc/sudoers.d` |
| AC-4 | No `mkdir` / `cp` / `install` / `chmod` / `tar` / `rm` / `systemctl` / `nginx` / shell basename appears in `path` or `args` |
| AC-5 | No domain, inbound path, or request basename in the JSON grant |
| AC-6 | Add and update samples exist and differ only by `action` |
| AC-7 | Submit of a file that violates AC-1–AC-5 fails closed |
| AC-8 | Text dual of this grant lists only `nginx-cli request` as `nginx-adm` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-three-layer-privilege-model` | Privilege layers; submit workflow; trust tiers; F6 is **not** this grant |
| `requirement-domain-nginx-cli` | `submit-sudoer-request` surface; defers JSON **body** here |
| `requirement-privilege-prevention-set` | Closed walls; must not block Type 0 compose submit |
| `requirement-shell-cli-interface` | Verb routing |
| `requirement-project-folder` | Global bin / ship unit |
| `requirement-class-software-dev` | Residual points JSON sudoer file here |
| `docs/requirements/index.md` | Registry |
| `./src/nginx-cli` | Implementation under test |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-NGX-16** | `tests/test_domain.sh` | have | submit fail-closed when sudoer-cli missing |
| **TP-NGX-17** | same | have | stub inbound submit |
| **TP-NGX-18** | same | have | refuse OS-tool / approve grant file |
| **TP-NGX-20** | same | have | default JSON grant is `/usr/local/bin/nginx-cli` `request` only |
| **TP-NGX-52** | same | have | `setup` auto-queues `login-hook-elev` when sibling inbound exists; skip when missing; Type 0 refuses that kind |
| **TP-NGX-53** | same | have | `setup` **MUST NOT** copy `/etc/sudoers.d/nginx-adm` / `nginx-cli-submit`; Family 2 dest is `/etc/nginx-adm/sudoers` |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-15 | Active 1.0.0 | JSON sudoer file SSOT; grant is `nginx-cli request` as `nginx-adm`; OS-tool and F6 verbs forbidden |
| 2026-08-23 | Active 1.2.0 | Two kinds; Type 1 `setup` auto-queues Family 1 as `login-hook-elev` (password, `--json`); **MUST NOT** write `/etc/sudoers.d` |

---

**Last Updated**: 2026-08-23  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
