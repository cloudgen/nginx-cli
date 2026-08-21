**file**: docs/requirements/requirement-domain-nginx-cli.md  
**Status**: Active (Version 1.12.0)  
**Area**: domain  
**Key**: `requirement-domain-nginx-cli`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **single Active domain SSOT** for **nginx-cli**. This ship unit **is** both:

1. A **file-based JSON approval dest** for subject **nginx-conf** (folder = state, JSON = checkable proposal; inbound files are dest request JSON).  
2. The Type 0 **submitter** for that same dest (`request`).  
3. A Type 0 compose **submitter** to sibling sudoer-cli (`submit-sudoer-request`) — a **different** machine (sudoer JSON, not nginx-conf JSON).

Specialized verbs, basename/samples, submit-when / verify, convert dual, list / approve / reject / publish, and the **login approval hook** live here. `setup` creates the host system.

This dest **specializes** **`LM-FILE-BASED-JSON-APPROVAL`** (JSON inbound) and **`LM-NGINX-CONF-STRUCTURE`** (artifact kinds + JSON dual). **Do not** invent a second nginx submitter ship unit. **Do not** collapse dest inbound JSON (nginx-conf) with compose sudoer JSON.

Privilege types and F6 / submit-fragment **Cmnds** plus the **`submit-sudoer-request` workflow** are owned by `requirement-three-layer-privilege-model.md`. The **JSON sudoer file body** is owned by `requirement-sudoer-json-file.md`. LPU identity (F1–F7) is owned by `requirement-least-privilege-user.md`. What Type 0 / Type 1 **block** vs what must stay open after elev is owned by `requirement-privilege-prevention-set.md`. Type 0 binary lifecycle remains owned by the shell-family requirements. **Do not** add a second Active domain SSOT. **Do not** add `requirement-shell-prompt` or `requirement-shell-temp-file-system` — prompt bodies stay on the interactive REQ; temp **roots** stay on the storage REQ; approve snapshots stay here.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.0 Named machine: nginx-conf file-based JSON approval

**Name:** nginx-conf file-based JSON approval (this dest).  
**State:** three public directories (inbound / approved / rejected). Folder = state.  
**Proposal:** a closed-schema **JSON** request file (nginx-conf dual). Nginx text is the **render dual** (`json-to-conf` / `conf-to-json`). CLI `--json` is **not** the request file.

This product **is** the dest **and** the Type 0 submitter (`request`). Do not invent a second nginx submitter ship unit.

#### 2.0.0 Dual role (this ship unit)

| Hat | Machine | Verbs | Queued body |
|-----|---------|-------|-------------|
| **Dest** | nginx-conf file-based JSON approval | `approve` / `reject` / list-* | dest request **JSON** in `/var/nginx-cli/config-request` |
| **Submitter (this dest)** | same machine | `request` | dest request **JSON** (nginx-conf **text** is a dual; `request` converts first) |
| **Submitter (sibling dest)** | sudoer-cli file-based JSON approval | `submit-sudoer-request` | sudoer JSON (`requirement-sudoer-json-file`) — **not** dest inbound |

Convert (`conf-to-json` / `json-to-conf`) is Type 0 dual only. It **MUST NOT** queue and **MUST NOT** write `${NGINX_CONF_ROOT}` / `/etc`.

| Role | Who | Type | May | Must not |
|------|-----|------|-----|----------|
| Submitter (person) | Invoking login | 0 | Submit self-scoped conf for mapped domains (or any domain if root / nginx-adm) | Approve; write live sites-available; `mkdir` inbound |
| Submitter path | This product `request` | 0 | Exclusive-create into inbound | Be a second sibling product |
| Subject | Domain in the basename | — | Appear in basename + map | Be a domain the submitter is not allowed |
| Allocator | This product `request` | 0 | Assign `yyyyMMdd-user-domain-n.json` | Take a caller-supplied dest basename |
| Approver | root, or nginx-adm after F6 / as that login | 1 | Snapshot, re-validate, publish or reject, unlink inbound | Submit on behalf of another human as a substitute for the map gate |

#### 2.0.1 Actor table (privilege SSOT)

OS identities (not machine roles). Every domain verb **MUST** match this table. §2.1 “Who” and §2.2.3 **MUST NOT** grant more than this table.

| Actor | How identified | `setup` / `remove-lpu` | `request` | `list-requests` / `list-approved` / `list-rejected` | `map-list` | `map-set` / `map-unset` | `approve` / `reject` / `enable-login-approval` | Write inbound FS | Sudoers fragment |
|-------|----------------|------------------------|-----------|-----------------------------------------------------|------------|-------------------------|------------------------------------------------|------------------|------------------|
| **root** | euid 0 | yes | yes, **any** domain | yes, **all** names | yes | yes | yes | yes | neither required |
| **nginx-adm** | login `nginx-adm` | no (needs root) | yes, **any** domain | yes, **all** names | yes | yes | yes (`sudo nginx-cli …`, **password required**) | yes (dir owner) | `/etc/sudoers.d/nginx-adm` — **password** `sudo` of `/usr/local/bin/nginx-cli` day-to-day verbs **plus** `NOPASSWD` `/usr/sbin/nginx` and `systemctl`/`journalctl` for unit `nginx` (**not** `setup`/`remove-lpu`; **no** `nginx-ctl`) |
| **Listed submitter** | (uncommented login in `/etc/sudoers.d/nginx-cli-submit` **or** per-user `/etc/sudoers.d/nginx-cli-<login>` present as a regular file) **and** member of group `nginx-cli-submit` | no | yes, **only** domains in that login’s `user-domain-map` (fail closed if map missing) | yes, **own** basename user only | yes | no | no | yes (group `2770`) | shared `/etc/sudoers.d/nginx-cli-submit` **or** sibling dest `/etc/sudoers.d/nginx-cli-<login>` (Type 0 `request` as invoker) |
| **Anyone else** | not root, not nginx-adm, not listed+grouped | no | no | no | no | no | no | no | — |

**MUST NOT:** treat group membership alone as submit; treat sudoers listing alone as inbound write; let a listed submitter approve, reject, map-set, or `setup`; use world-wx inbound so “anyone else” can drop files.

**Submit is allowed when all hold:**

1. Actor is root, or nginx-adm, or (listed via shared allowlist **or** per-user `/etc/sudoers.d/nginx-cli-<login>` **and** in group `nginx-cli-submit`).  
2. Public inbound **already exists** (Type 1 `setup` created it).  
3. Domain is path-safe; non-root/non-adm submitters have that domain in `user-domain-map`.  
4. Body is dest request **JSON** (or nginx-conf **text** that `request` converts first). JSON `username` **MUST** equal the invoker. JSON `domain` **MUST** equal the operand domain.

**Submit is not allowed when:** unlisted login; inbound missing; domain not mapped (for listed humans); world-wx inbound design; Type 0 `mkdir` to invent the trio.

**Verify at submit and again at approve:**

| Check | Submit | Approve / reject |
|-------|--------|------------------|
| Privilege | `ngx_require_submit` | `ngx_require_approve` |
| Regular file, not symlink | exclusive-create dest | snapshot source |
| Basename grammar | allocator owns `yyyyMMdd-user-domain-n.json` | parse date/user/domain/n (suffix `.json`) |
| Closed JSON schema | required (convert text first if needed) | re-validate snapshot JSON |
| Self-scope | JSON `username` = invoker | owner / username still match |
| Domain / map | JSON `domain` = operand; map gate for listed humans | domain from basename + JSON for publish dest |
| Syntax gate | n/a (text dual at approve) | `json-to-conf` then `nginx -t` on **rendered text** (never raw JSON) |
| Inbound last component not symlink | fail closed | fail closed |
| Dest Fence (incorrect JSON format) | fail closed | interactive: display, **do not** ask, archive rejected; basename `approve`/`reject`: fail closed, file stays inbound |

**Dest approval fencing conditions** (closed; dest table **MUST** print):

| Row | Kind | Owner |
|-----|------|--------|
| **Incorrect JSON format** | dest **Fence** | `requirement-incorrect-json-format` |
| Unix file-ownership of the waiting file | **MUST NOT** fence | this table only |
| Who submitted | **MUST NOT** fence | this table only |
| JSON `username` ≠ `nginx-adm` | **MUST NOT** fence | this table only |
| `submit_app` ≠ dest `APP_NAME` | **MUST NOT** fence | this table only |
| `submit_version` ≠ dest `VERSION` | **MUST NOT** fence | this table only |

This dest has **one** dest **Fence**. Type 0 **test-purpose** `fence-test` runs that list against a JSON **file location** in a **local test folder**. `test-json-format` is the per-row tester. Dual mention: this file **and** `requirement-shell-cli-interface`. Invocation:

```sh
nginx-cli fence-test --file tests/fixtures/fence-test/pass/20260821-alice-example.com-1.json
nginx-cli test-json-format --file ./20260821-alice-example.com-1.json
```

**Create the system on a host (Type 1 then day-to-day):**

```text
1. Install this CLI (Type 0): sh src/nginx-cli install   # or sudo … install
2. sudo nginx-cli setup
     → nginx-adm UID 1999, /etc/nginx-adm, /var/nginx-cli trio,
       group nginx-cli-submit, F4 views, sudoers, login hook
3. Admin: usermod -aG nginx-cli-submit <login>
          uncomment that login in /etc/sudoers.d/nginx-cli-submit; visudo -c
4. sudo nginx-cli map-set <login> <domain>
5. As <login>: nginx-cli request <domain> ./site.json
   # or nginx-cli request <domain> ./site.conf  (text dual; request converts)
6. As root or nginx-adm: nginx-cli approve
     (or nginx-cli approve <basename>)
```

This product **is** the approve dest. Do not invent a second submitter ship unit.

---

### 2.1 Specialized CLI subcommands

Every domain verb **MUST** map to exactly one privilege class. Domain functions use prefix **`ngx_`**.

| Command | Type | Who | Handler | Behavior |
|---------|------|-----|---------|----------|
| `setup` | Type 1 | root (internal `sudo` re-exec if needed) | `ngx_setup` | Idempotent create of nginx-adm (UID/GID/home/shell), submit group, public queue root, F4 home views, home map subtree, affected-folder ownership, home→sites symlinks, nginx-adm sudoers, submit-sudoers template, optional login hook |
| `remove-lpu` | Type 1 | root | `ngx_remove_lpu` | Reverse sudoers → backup+remove public queue root → reverse affected ownership (content kept) → `userdel -r` (+ groupdel of nginx-adm and submit group). Confirm unless `--force` |
| `remove-nginx-adm` | Type 1 | root | `ngx_remove_lpu` | Alias of `remove-lpu` |
| `request <domain> [file]` | gated submit | root **or** nginx-adm **or** listed submitter | `ngx_request_submit` | Exclusive-create dest request **JSON** into inbound (accept JSON or convert text dual). stdin if file is `-` or omitted and stdin is not a TTY |
| `list-requests` | gated list | root, nginx-adm, or submitter | `ngx_list_queue pending` | Approving / pending list |
| `list-approved` | gated list | same | `ngx_list_queue approved` | Approved archive list |
| `list-rejected` | gated list | same | `ngx_list_queue rejected` | Rejected archive list |
| `approve [basename]` | approver | root or nginx-adm | `ngx_approve_interactive` or `ngx_approve_one` | No operand + TTY → one-by-one; operand → single file. Non-TTY without operand **MUST** fail closed |
| `reject <basename>` | approver | root or nginx-adm | `ngx_reject_one` | Snapshot inbound, install snapshot into rejected archive, unlink inbound; no publish |
| `enable-login-approval` | approver | root or nginx-adm | `ngx_enable_login_approval` | Idempotent marked block in nginx-adm `.bashrc` |
| `map-set <user> <domain>` | approver | root or nginx-adm | `ngx_map_set` | Add domain line; **chown back** to nginx-adm |
| `map-unset <user> <domain>` | approver | root or nginx-adm | `ngx_map_unset` | Remove domain line; chown back |
| `map-list [user]` | gated list | root, nginx-adm, or submitter | `ngx_map_list` | Show map file(s) |
| `submit-sudoer-request [file]` | Type 0 compose | any login | `ngx_submit_sudoer_request` | Detect sudoer-cli + sudoer-adm + public inbound; sibling allocates a JSON grant request. **Does not** write `/etc` or `mkdir` inbound. Flags: `--purpose`, `--update`, `--allow-test-local`. Workflow: `requirement-three-layer-privilege-model` §2.5.3 · body: `requirement-sudoer-json-file` |
| `conf-to-json [file]` | Type 0 convert | any login | `ngx_conf_to_json` | Convert nginx-conf **text dual** to dest request JSON. stdin **xor** `--file`. stdout or `--out`. Never queue. Never write `${NGINX_CONF_ROOT}` / `/etc`. Flags: `--action add\|update`, `--purpose` |
| `json-to-conf [file]` | Type 0 convert | any login | `ngx_json_to_conf` | Convert dest request JSON to nginx-conf text. `remove` → `# Purpose:` only. stdin **xor** `--file`. stdout or `--out`. Never queue. Never write `${NGINX_CONF_ROOT}` / `/etc`. Syntax gate (`nginx -t` when present) on **rendered text** only |
| `test-json-format [file]` | Type 0 **test-purpose** | any login | `ngx_test_json_format` | Per-row dest JSON-format Fence. stdin **xor** `--file`. **MUST NOT** queue, dest-write, or require `sudo` / a sudoers fragment / the waiting folder |
| `fence-test [file]` | Type 0 **test-purpose** | any login | `ngx_fence_test` | Closed dest Fence list. stdin **xor** `--file PATH` **xor** `--dir DIR`. `--expect-match` with `--dir` succeeds only when every file matches a dest Fence. Same no-sudo / no-queue rules |

**MUST NOT** treat Type 0 `uninstall` as LPU remove. **MUST NOT** treat dest `approve` / `reject` as `fence-test`.

### 2.2 Specialized features

#### 2.2.1 nginx-adm create (setup)

`setup` **MUST** create the LPU, submit group, public trio, F4 views, home map, F6, submit fragment, and optional login hook **as specified** in `requirement-least-privilege-user.md` (F1–F7) and `requirement-three-layer-privilege-model.md` (Table A + both fragment samples). This section owns only **machine** facts that those files point back to:

1. Public inbound last component **MUST NOT** be a symlink. Type 0 **MUST NOT** `mkdir` production inbound or archives; missing inbound **MUST** fail closed.  
2. `user-domain-map` **MUST** stay under LPU home (never on the public queue root).  
3. If setup finds a **real** (non-symlink) home queue dir from a prior revision, it **MUST** migrate files into the public trio, then replace the home dir with the F4 view.  
4. Re-run **MUST NOT** destroy existing site conf. If the account already exists with the expected identity, repair layout/ownership/sudoers only.  
5. Complete F6 and submit-fragment text **MUST** match three-layer §2.5 — do not keep a second copy here.  
6. `setup` **MUST** leave Family 1 authenticatable: TTY `passwd nginx-adm` (operator types; never recorded) or a non-TTY warn with that command. **MUST NOT** `chpasswd` or script a secret. A locked nginx-adm password makes the login hook and `sudo nginx-cli` fail with `sudo: a password is required`.

#### 2.2.2 remove-lpu

F7 order is owned by `requirement-least-privilege-user.md` §2.4. Domain **MUST** dispatch `remove-lpu` / `remove-nginx-adm` to that order. Type 0 `uninstall` is **not** F7.

#### 2.2.3 Submit privilege

Privilege rows **MUST** follow the **actor table (§2.0.1)**. Submit-only summary:

| Actor | May submit? |
|-------|-------------|
| root | yes (any domain) |
| nginx-adm | yes (any domain) |
| Listed submitter (§2.0.1) | yes, **only** mapped domains |
| Anyone else | **no** |

Software allowlist **MUST** still be checked. World-create inbound (**`3773` other `-wx`**) is **forbidden** on this dest. Type 0 writes as the invoking login (no `sudo -u nginx-adm` re-exec to deposit). If inbound exists but is not writable, fail closed (join `nginx-cli-submit`).

#### 2.2.4 Request file (JSON dest inbound)

- Basename grammar: `yyyyMMdd-<user>-<domain>-<n>.json` with `n` = next integer for that date+user+domain counted in **all three** public queues. Prefix none; suffix **`.json`**; allocator = `request`.  
- Worked sample basename: `20260815-alice-example.com-1.json`  
- Queued body **MUST** be dest request **JSON** (§2.2.9 schema). `request` **MUST** accept JSON **or** nginx-conf text (first non-whitespace `{` vs `#`); text is converted before exclusive-create.  
- Deposit **MUST** be exclusive-create into the public inbound. Owner **MUST** remain the submitter; mode **`0640`**; group follows inbound setgid (`nginx-cli-submit`). **MUST NOT** `chown` the request to nginx-adm.

Complete **queued** sample (initial add) — same grant as the text dual below:

```json
{
  "schema_version": 1,
  "purpose": "Add HTTPS vhost redirect for example.com",
  "username": "alice",
  "service": "nginx-cli",
  "action": "add",
  "kind": "redirect",
  "domain": "example.com",
  "submit_app": "nginx-cli",
  "submit_version": "1.5.0",
  "site": {
    "listen": ["80"],
    "server_name": ["example.com"],
    "return": { "code": 301, "url": "https://$host$request_uri" }
  }
}
```

Complete **queued** sample (update):

```json
{
  "schema_version": 1,
  "purpose": "Send /api to the new upstream for example.com",
  "username": "alice",
  "service": "nginx-cli",
  "action": "update",
  "kind": "per-domain-https",
  "domain": "example.com",
  "submit_app": "nginx-cli",
  "submit_version": "1.5.0",
  "site": {
    "listen": ["443 ssl"],
    "server_name": ["example.com"],
    "ssl_certificate": "/etc/letsencrypt/live/example.com/fullchain.pem",
    "ssl_certificate_key": "/etc/letsencrypt/live/example.com/privkey.pem",
    "locations": [
      { "role": "proxy", "match": "/api/", "proxy_pass": "http://127.0.0.1:8081" }
    ]
  }
}
```

Paired **text duals** (what `json-to-conf` renders; also legal `request` input) are the dest §2.2.4 nginx `server` blocks with `#` intention headers (redirect add and HTTPS+proxy update). Full bodies are the convert samples in §2.2.9.

#### 2.2.5 Approve / reject

- **Authz:** Type 1 approve/reject is allowed only for **euid 0** or login **nginx-adm**. Listed submitters **MUST NOT** approve. Fixture mode may approve for tests only.  
- **Approve / reject I/O:** **MUST NOT** `mv` the live inbound name after validate. Copy the inbound inode to a private snapshot; require a regular non-symlink file; **re-validate** the snapshot; publish from the snapshot (approve only); install the snapshot into the `0700` archive; **unlink** the inbound name.  
- **Approve dest:** re-validate snapshot **JSON**; `action` `remove` **MUST** delete `${NGINX_CONF_ROOT}/sites-available/<domain>.conf` and the enable-dir symlink (no install). Otherwise **render** the text dual (`json-to-conf`) to a private temp, then copy that **text** to `${NGINX_CONF_ROOT}/sites-available/<domain>.conf`; `ln -sfn` into `sites-enabled/<domain>.conf`. Run `nginx -t` on the **rendered** dest (never raw JSON) when the binary exists (warn, do not leave a half-published file if test fails — roll back dest copy + symlink). Archive the **JSON** snapshot.  
- **Reject:** archive snapshot + unlink inbound. No dest write.  
- Interactive: consume `TTY` / `JSON` / `QUIET` (those flags are measured in the main process; helpers **MUST NOT** invent a second `[ -t` policy). No operand + TTY → one-by-one; operand → one file. `--json` / `--quiet` / non-TTY without basename **MUST** fail closed (no prompt). `--force` **MUST NOT** auto-accept. Actions: approve / reject / skip / quit via `prompt_*`. Empty inbound → success exit 0. Re-snapshot at decide time.  
- **List:** root and nginx-adm see all names. Other allowed submitters **MUST** see only files whose basename user equals their login.

#### 2.2.6 Login hook

Idempotent markers in `/etc/nginx-adm/.bashrc` only. The snippet **MUST** skip when `PS1` is unset (scp / non-interactive). Empty argv of this CLI **MUST** still be help (the hook calls `approve`, not bare `nginx-cli`). Interactive login **MUST** use **`sudo /usr/local/bin/nginx-cli approve`** (password prompt). **MUST NOT** use `sudo -n`. That sudo authenticates as **nginx-adm** — the account **MUST** have a usable password (`setup` JOB-PASSWD). Login `nginx-adm` **MAY** also run `nginx-cli approve` **without** sudo (`OPEN-ADM-NOSUDO`).

Complete snippet (setup **MUST** write this shape):

```sh
# >>> nginx-cli interactive approval (managed) >>>
if [ -n "${PS1-}" ]; then
    sudo /usr/local/bin/nginx-cli approve
fi
# <<< nginx-cli interactive approval (managed) <<<
```

#### 2.2.7 User-domain-map ownership

Any `map-set` / `map-unset` **MUST** `chown` the map file back to `nginx-adm:nginx-adm`.

#### 2.2.8 Test fixture (non-host)

When `NGINX_CLI_FIXTURE=1` **and** `NGINX_ADM_HOME` is under `/tmp` or `$TMPDIR`, domain map/publish **MAY** operate on those trees without a real OS account. Public queues **MUST** use `NGINX_QUEUE_ROOT` (or a fixture-derived sibling) that is **also** under `/tmp` or `$TMPDIR` — **MUST NOT** write `/var/nginx-cli` in fixture mode. Fixture **MUST NOT** `mkdir` a missing production inbound; tests create the fixture trio. `setup` / `remove-lpu` **MUST still** require real root and **MUST NOT** create host users in fixture mode.

#### 2.2.9 Convert + JSON dual (Type 0)

Dest inbound **is** dest request JSON. Convert is the Type 0 **dual** (text ↔ JSON) and **MUST NOT** queue. It is **not** the compose sudoer JSON (`requirement-sudoer-json-file`). CLI `--json` is **not** the request file.

**Input:** stdin **xor** `--file PATH` (or a single file operand). Missing file, symlink, or TTY-without-file **MUST** fail closed (`xor_input`).  
**Output:** stdout, or `--out PATH`. `--out` **MUST NOT** be under `/etc` or `${NGINX_CONF_ROOT}`.  
**MUST NOT** write inbound / approved / rejected. **MUST NOT** `mkdir` those dirs.

**Closed schema (add/update):** `schema_version` `1`; `purpose`; `username` (invoker at convert); `service` `nginx-cli`; `action` `add`\|`update`; `kind` exactly one of `per-domain-https` · `redirect` · `shared-cloudflare`; `domain`; `site` object; `submit_app`; `submit_version`. Unknown keys fail closed.  
**`submit_app` / `submit_version`:** Type 0 `request` / `conf-to-json` **MUST** overwrite them from live Config `APP_NAME` / `VERSION`. Dest **MUST NOT** dest-write them. Dest **MUST NOT** fence if values ≠ dest identity. Missing / non-string on add/update emit, testers, and convert **is** dest Fence `requirement-incorrect-json-format`. Dest review display **MUST** print `queued by {submit_app} {submit_version}` when those strings are present.  
**remove:** `purpose` required; `site` forbidden; `submit_app` / `submit_version` optional (strings when present).

**`site` (constrained — not a raw nginx string, not a full AST):**

| Key | When |
|-----|------|
| `listen` | string array; `redirect` → includes `80`; `per-domain-https` → includes `443 ssl` |
| `server_name` | includes `domain` (except shared redirect `_`) |
| `ssl_certificate` / `ssl_certificate_key` | required for `per-domain-https` |
| `root` | optional |
| `return` | `redirect` only: `{ "code": 301, "url": "…" }` |
| `locations` | optional array; each `role` is `root` · `proxy` · `acme` · `cloudflare-check` |

**Refuse:** `include` of arbitrary paths, `lua_*`, `load_module`, unknown `kind` / `role`, OS-tool paths as `proxy_pass`.

Worked JSON **add** (same grant as §2.2.4 add sample):

```json
{
  "schema_version": 1,
  "purpose": "Add HTTPS vhost redirect for example.com",
  "username": "alice",
  "service": "nginx-cli",
  "action": "add",
  "kind": "redirect",
  "domain": "example.com",
  "submit_app": "nginx-cli",
  "submit_version": "1.5.0",
  "site": {
    "listen": ["80"],
    "server_name": ["example.com"],
    "return": { "code": 301, "url": "https://$host$request_uri" }
  }
}
```

Worked JSON **update** (same grant as §2.2.4 update sample):

```json
{
  "schema_version": 1,
  "purpose": "Send /api to the new upstream for example.com",
  "username": "alice",
  "service": "nginx-cli",
  "action": "update",
  "kind": "per-domain-https",
  "domain": "example.com",
  "submit_app": "nginx-cli",
  "submit_version": "1.5.0",
  "site": {
    "listen": ["443 ssl"],
    "server_name": ["example.com"],
    "ssl_certificate": "/etc/letsencrypt/live/example.com/fullchain.pem",
    "ssl_certificate_key": "/etc/letsencrypt/live/example.com/privkey.pem",
    "locations": [
      { "role": "proxy", "match": "/api/", "proxy_pass": "http://127.0.0.1:8081" }
    ]
  }
}
```

Worked JSON **remove**:

```json
{
  "purpose": "Revoke my example.com site conf; I no longer operate that vhost."
}
```

`json-to-conf` of the add JSON **MUST** render a `server { listen 80; … return 301 … }` text dual (comments may use `Purpose` / `Intention`). Round-trip of dest §2.2.4 samples **MUST** preserve `kind`, `domain`, `listen`, `server_name`, and `return` or `proxy_pass`. Extra comments besides the purpose header **MAY** be dropped.

#### 2.2.10 Non-goals

- Online install channel  
- Managing Certbot certificates  
- Owning `/var/www` content as nginx-adm by default  
- Broad sudoers (`ALL`, shells, package managers)

### 2.3 Specialized project help items

`help` **MUST** list all domain verbs in §2.1 **in addition to** Type 0: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`.

`help` **MUST** state that `setup` / `remove-lpu` need root, that inbound is `/var/nginx-cli/config-request` (group `nginx-cli-submit`, mode `2770`, **JSON** request files), that other users cannot `request` unless listed (shared allowlist **or** per-user fragment) **and** in that group, and that **nginx-adm** elevates with **password** `sudo /usr/local/bin/nginx-cli` and may `NOPASSWD` `sudo` `/usr/sbin/nginx` and `systemctl`/`journalctl` for unit `nginx` (Table A in `requirement-three-layer-privilege-model.md`).

`help` **MUST** list `submit-sudoer-request [file]` as Type 0 compose into `/var/sudoer-cli/sudoer-request` (no `/etc` write; no inbound mkdir).

`help` **MUST** list `conf-to-json` and `json-to-conf` as Type 0 convert (no queue; no dest write).

`help` **MUST** list **test-purpose** verbs `test-json-format` and `fence-test` under a heading **apart** from operational inbound (`request` / `approve` / `reject` / `submit-sudoer-request` / convert). Testers **MUST NOT** be grouped as submit/review.

`help` **MUST NOT** advertise `backup`, `restore`, `print-sudoers`, `self-update`, or `self-uninstall`.

### 2.4 Specialized project about items

`about` **MUST** include (human + JSON when applicable):

| Field | Meaning |
|-------|---------|
| `nginx_adm_user` | Config username |
| `nginx_adm_exists` | `true`/`false` from `id` |
| `nginx_adm_home` | Resolved home |
| `nginx_conf_root` | Conf root |
| `pending_count` | Inbound file count when public inbound readable; else `unknown` |
| `nginx_queue_root` | Resolved public queue root |
| `nginx_submit_group` | Submit group name |
| `sudoer_cli` | Detected path or `not_found` |
| `sudoer_adm` | Detected login or `absent` |
| `sudoer_inbound` | Detected inbound dir or `not_found`; plus writable flag. Preferred: `/var/sudoer-cli/sudoer-request` |
| `sudoers_trust_tier` | `production` / `test_local` / `unmanaged` |

Type 0 diagnostics (install, storage, repo) **MUST** remain.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product / APP_NAME** | `nginx-cli` |
| **Ship unit** | `src/nginx-cli` |
| **Bootstrap origin** | `cli-template` (frozen at `src/cli-template`) |
| **Domain prefix** | `ngx_` |
| **VERSION** | `1.5.0` (domain law 1.12.0) |
| **Dest Fence** | `requirement-incorrect-json-format` |
| **Testers** | `fence-test` / `test-json-format` |
| **Convert verbs** | `conf-to-json` → `ngx_conf_to_json`; `json-to-conf` → `ngx_json_to_conf` |
| **Submit compose** | `submit-sudoer-request` → `ngx_submit_sudoer_request` |
| **Sibling inbound** | `/var/sudoer-cli/sudoer-request` |
| **JSON grant SSOT** | `requirement-sudoer-json-file` |
| **NGINX_ADM_USER** | `nginx-adm` |
| **UID/GID** | `1999` / `1999` |
| **Default home** | `/etc/nginx-adm` |
| **Queue root** | `/var/nginx-cli` (`NGINX_QUEUE_ROOT`) |
| **Submit group** | `nginx-cli-submit` |
| **Inbound mode** | `2770` (group dropbox; not world-wx) |
| **NGINX_CONF_ROOT** | `/etc/nginx` |
| **Submit fragment** | `/etc/sudoers.d/nginx-cli-submit` (software allowlist; not required for `sudo -u` deposit) |
| **LPU / F6 / prevention** | Peers: `requirement-least-privilege-user` · `requirement-three-layer-privilege-model` · `requirement-privilege-prevention-set` |
| **Install mode** | Local-only (`install` / `uninstall`); not dual-mode |

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 9 – Three Types of Commands**: Type 0 lifecycle vs Type 1 setup/remove vs gated day-to-day.  
- **CIAO Principle 10 – Least-Privilege User**: Dedicated nginx-adm; narrow sudoers; no standing root for site edits.  
- **CIAO Principle 1 – Caution**: Fail closed on submit and on non-TTY approve.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: Login hook and walk never hang CI.  
- **CIAO Principle 12 – Backup**: Sudoers backup before remove.  
- **CIAO Principle 21 – Dual policies**: Complete product values here; portable wording in cores.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Unknown submitters cannot write the inbound; never `mv` a group-writable inbound after validate; approve without TTY/basename fails.  
- **Intentional**: Public trio + home map + basename + dest JSON encode why a change exists. This ship unit is dest **and** submitter.  
- **Anti-fragile**: Idempotent setup + migrate old home queues; fixture mode for CI; F7 removes `/var/nginx-cli` explicitly.  
- **Over-protect**: Group `2770` not world-wx; Type 0 no-mkdir; do not collapse approve into “edit sites-enabled in place”; do not treat `uninstall` as LPU remove.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Allow unlisted non-root, non-nginx-adm users to submit, or grant any actor more than the §2.0.1 actor table.  
2. Leave an approved or rejected file in the inbound.  
3. Publish on reject.  
4. Skip chown-back on user-domain-map writes.  
5. Hang `approve` under `--json`, `--quiet`, or non-TTY with no basename.  
6. Write the login hook into a random human home instead of nginx-adm home.  
7. Add a second Active domain-requirements file.  
8. `mv` the live inbound path after validate (must snapshot + unlink).  
9. `chown` a submitted request to nginx-adm (owner stays the submitter).  
10. Write `/var/nginx-cli` from fixture mode.  
11. Duplicate F1–F7, Table A/B/C, or the prevention catalog in this file (those have peer owners).  
12. Add `requirement-shell-prompt` or `requirement-shell-temp-file-system` for this dest — interactive and storage already own those surfaces.  
13. Invent a second nginx submitter ship unit (this product **is** the dest submitter).  
14. Queue nginx-conf **text** as dest inbound, or treat compose sudoer JSON as dest inbound.

Privilege walls that used to live only here (`nginx-ctl`, NOPASSWD on `nginx-cli`, world-wx inbound, Type 0 mkdir inbound, F7 vs uninstall, nologin shell) are **owned** by `requirement-privilege-prevention-set.md` and **MUST NOT** be re-opened here as a second list.

**Violating this rule is a critical domain / privilege regression.**

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-NGX-01..15** | `tests/test_domain.sh` | have | fixture request/approve/reject/hook; hook not `sudo -n`; inbound 2770 / F6 static |
| **TP-NGX-16..20** | same | have | submit-sudoer-request compose (peer: three-layer + sudoer-json-file) |
| **TP-NGX-21..24** | same | have | conf-to-json / json-to-conf dual; xor; refuse dest write |
| **TP-NGX-25..33** | same | have | dest JSON request; inbound body; mismatch; published text; convert --out inbound; grant allowlist |
| **TP-NGX-35..43** | same | have | dest Fence testers; `submit_app` / `submit_version`; unknown keys; sibling stamp |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-least-privilege-user.md` | nginx-adm F1–F7 |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Type map + Tables A/B/C + fragment samples + submit workflow |
| `docs/requirements/requirement-sudoer-json-file.md` | JSON grant body for `submit-sudoer-request` |
| `docs/requirements/requirement-privilege-prevention-set.md` | Closed block / must-remain-open catalog |
| `docs/requirements/requirement-shell-cli-interface.md` | Type 0 catalog; dual mention of testers |
| `docs/requirements/requirement-incorrect-json-format.md` | Dest Fence meaning |
| `docs/requirements/requirement-bootstrap-chain.md` | Origin = cli-template; this product is B |
| `docs/requirements/requirement-shell-modular-function-design.md` | `ngx_` prefix |
| `./src/nginx-cli` | Implementation |

**Last Updated**: 2026-08-21 (1.12.0 — dest Fence table; Type 0 fence-test; dest-owned submit_app / submit_version)  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
