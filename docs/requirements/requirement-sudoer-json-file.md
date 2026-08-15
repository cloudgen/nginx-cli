**file**: docs/requirements/requirement-sudoer-json-file.md  
**Status**: Active (Version 1.0.0)  
**Area**: architecture  
**Key**: `requirement-sudoer-json-file`  
**id**: RQ-SUDOER-JSON-FILE  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for the **JSON-type sudoer file**: the machine encoding of this product’s **listed-submitter** grant (the body a Type 0 `submit-sudoer-request` hands to the sibling allocator).

The grant **MUST** name only the project command **`{{PRJ_NAME}}`**. It **MUST NOT** allowlist other shell or OS tools (`cp`, `mkdir`, `install`, `chmod`, `tar`, `rm`, shells, `systemctl`, `nginx`, …). Extra tools increase design complexity and weaken security.

This file does **not** own:

| Concern | Owner |
|---------|--------|
| Type 0/1/2 map, F6 Table A, Type 1 `setup` write of host fragments, submit **workflow** (detect / no inbound `mkdir` / no `/etc` write) | `requirement-three-layer-privilege-model` |
| Domain verb catalog / help / about / nginx-conf request body | `requirement-domain-nginx-cli` |
| Closed prevention catalog | `requirement-privilege-prevention-set` |

Queued **basename** allocation remains sibling-owned. This requirement owns **command identity and JSON body shape**.

**print-sudoers is not this product’s emit path.** Default submit input is this JSON grant written to a temp file.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 What a JSON sudoer file is

1. A JSON sudoer file is a **closed-schema object** that states: who may elevate, which **product** the grant is for, add vs update, and a **commands** list.  
2. It is **not** `sudoers(5)` text. It is **not** this product’s `--json` CLI status. It is **not** an nginx-conf request file.  
3. Sibling approval software **MAY** convert a text dual into this JSON. Conversion **MUST NOT** invent OS-tool commands that this requirement forbids.  
4. If both a text fragment and a JSON sudoer file represent the **same** grant, they **MUST** be equivalent: both elevate **`{{PRJ_NAME}} request`** only (runas the dest LPU). A text file that allowlists `mkdir`/`cp`/`systemctl`/`nginx` **MUST NOT** be treated as a valid dual.

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
| **Not F6** | This grant is **not** the nginx-adm F6 table. F6 stays on `requirement-three-layer-privilege-model`. This JSON **MUST NOT** grant `approve`, `reject`, `map-set`, `map-unset`, `enable-login-approval`, `setup`, `remove-lpu`, `install`, or `uninstall` |

**Why OS-tool grants are forbidden:** extra sudoers lines are extra ways to be wrong. After sudoer-adm approves this grant, dest Type 0 `request` still runs as the invoker. The grant is the **listed-submitter** ticket (sibling dest `/etc/sudoers.d/{{PRJ_NAME}}-{{username}}`), not a catalog of root helpers.

### 2.3 Arguments — dest-honest listed-submitter verb

1. `commands[].args` **MUST** be exactly `["request"]`.  
2. `commands[].runas` **MUST** be the dest LPU username (`nginx-adm` on this product).  
3. `commands[].tags` **MAY** include `NOPASSWD` so the sibling dest fragment matches the existing submit-allowlist line shape. This **MUST NOT** be copied onto F6 (F6 `nginx-cli` lines stay password-required).  
4. **MUST NOT** put domain names, inbound paths, host HOME, or request basenames in `args`.  
5. **MUST NOT** grant `{{PRJ_NAME}}` with **no** verb (whole CLI as the LPU or as root).  
6. Extra flags the CLI accepts (`--json`, `--force`, `--quiet`) **MUST NOT** be frozen as the only legal operands in the JSON.

### 2.4 Closed schema (normative)

| Field | Type | Required | Rule |
|-------|------|----------|------|
| `schema_version` | integer | yes | `1` for this requirement |
| `purpose` | string | yes | Human purpose; no secrets |
| `username` | string | yes | Target login (submitter); not `ALL` |
| `service` | string | yes | **MUST** equal `{{PRJ_NAME}}` |
| `action` | string | yes | `add` or `update` only |
| `commands` | array | yes | Non-empty; every element obeys §2.2–2.3 |
| `commands[].runas` | string | yes | dest LPU (`nginx-adm`) |
| `commands[].tags` | array | yes | `NOPASSWD` **MAY** appear (submit-allowlist shape; **not** F6) |
| `commands[].path` | string | yes | Absolute `{{GLOBAL_BIN}}/{{PRJ_NAME}}` only |
| `commands[].args` | array of strings | yes | `["request"]` only |

**MUST NOT** add undeclared privilege fields (extra binaries, `env_keep` shells, `ALL`). Unknown sibling metadata **MUST NOT** widen `commands`.

### 2.5 Filename grammar (queued artifact — sibling allocator)

This product **MUST NOT** invent the dest basename. Sibling grammar (informative for pairing):

```text
sudoer-{{YYYYMMDD}}-{{PRJ_NAME}}-{{username}}-{{action}}-{{n}}.json
```

**Worked sample basename (add):** `sudoer-20260815-nginx-cli-alice-add-1.json`  
**Worked sample basename (update):** `sudoer-20260815-nginx-cli-alice-update-1.json`  
**Worked dest after sibling approve:** `/etc/sudoers.d/nginx-cli-alice`

### 2.6 Complete sample bodies (same grant; add vs update)

Normative **add** JSON (this project’s filled values — see §2.8):

```json
{
  "schema_version": 1,
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
  ]
}
```

Normative **update** JSON (same commands; `action` only changes):

```json
{
  "schema_version": 1,
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
  ]
}
```

Equivalent **text dual** of the same grant:

```text
# Purpose: Allow alice to submit nginx-cli config requests as nginx-adm.
alice ALL=(nginx-adm) NOPASSWD: /usr/local/bin/nginx-cli request
```

**Withdrawn (forbidden) encodings** — do not copy into a JSON sudoer file:

```json
{ "path": "/usr/sbin/nginx", "args": ["-t"] }
```

```json
{ "path": "/usr/local/bin/nginx-cli", "args": ["approve"] }
```

Those shapes are **non-compliant**. Unit-tool and F6 approve grants stay on `requirement-three-layer-privilege-model` (Type 1 `setup` / Table A). OS-tool complexity is a security defect.

### 2.7 Submit / emit honesty

1. When `submit-sudoer-request` builds or accepts a JSON sudoer file, the body **MUST** satisfy §2.2–2.4.  
2. **MUST** fail closed if an input file’s `commands` contain a forbidden path, OS-tool basename, or a dest-forbidden verb (`approve`, `reject`, `setup`, `remove-lpu`, `install`, `uninstall`, `map-set`, `map-unset`, `enable-login-approval`).  
3. **MUST NOT** “fix” a forbidden file by submitting it anyway.  
4. Trust-tier gates (production vs test_local) remain on `requirement-three-layer-privilege-model`. This requirement does not weaken those gates.

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **`{{PRJ_NAME}}` / `APP_NAME`** | `nginx-cli` |
| **`{{GLOBAL_BIN}}`** | `/usr/local/bin` |
| **Elevated path** | `/usr/local/bin/nginx-cli` |
| **Allowed args** | `request` |
| **runas** | `nginx-adm` |
| **Forbidden paths (examples)** | `/usr/sbin/nginx`, `/bin/systemctl`, `/usr/bin/systemctl`, `/usr/bin/mkdir`, `/bin/mkdir`, `/usr/bin/cp`, `/bin/sh` |
| **Forbidden args (examples)** | `approve`, `reject`, `setup`, `remove-lpu`, `install`, `uninstall` |
| **Ship unit** | `src/nginx-cli` |
| **Submit verb** | `submit-sudoer-request` → `ngx_submit_sudoer_request` |
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
- **Over-protect:** Verb-bound `request` only; no bare-binary grant; no `USER_BIN` path; no `approve`.  
- **Stay-honest:** This dest does **not** copy folder-backup `backup`/`restore` or sudoer-cli `webservice` unit-tool grants.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Put `cp`, `mkdir`, `install`, `chmod`, `tar`, `rm`, `systemctl`, `journalctl`, `nginx`, or a shell in a JSON sudoer file `commands` list.  
2. Grant `approve`, `reject`, `setup`, `remove-lpu`, `install`, `uninstall`, or map verbs in this JSON.  
3. Elevate `{{USER_BIN}}/{{PRJ_NAME}}` in this JSON.  
4. Grant `{{PRJ_NAME}}` with no verb (whole CLI as root or as the LPU).  
5. Copy folder-backup `backup`/`restore` or sudoer-cli `webservice` samples as this dest’s grant.  
6. Duplicate submit/install workflow law here (that stays on the privilege peer).  
7. Store secrets in the JSON body.  
8. Reintroduce `print-sudoers` as the body SSOT.  
9. Cite templates or skills as product-source authority for this grant.

**Violating this rule is a critical privilege / complexity-as-insecurity regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Every `commands[].path` is `/usr/local/bin/nginx-cli` |
| AC-2 | `service` equals `nginx-cli` |
| AC-3 | `args` are only `request`; `runas` is `nginx-adm` |
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

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-15 | Active 1.0.0 | JSON sudoer file SSOT; grant is `nginx-cli request` as `nginx-adm`; OS-tool and F6 verbs forbidden |

---

**Last Updated**: 2026-08-15  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
