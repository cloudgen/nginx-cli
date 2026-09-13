**file**: docs/requirements/requirement-login-interactive-review-hook.md  
**Status**: Active (Version 1.0.0)  
**Area**: architecture  
**Key**: `requirement-login-interactive-review-hook`  
**id**: RQ-LOGIN-INTERACTIVE-REVIEW-HOOK  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **independent owner** of the nginx-adm **login-time review hook**: the labeled global name, the marker-guarded `.bashrc` snippet, `.profile` create-if-absent, and Type 1 `setup` / `enable-login-approval` **review-and-replace** of an old hook.

The **new hook** is the soft link **`/usr/local/bin/nginx-cli-hook`** pointing at **`/usr/local/bin/nginx-cli`**. Interactive login as nginx-adm **MUST** run **`/usr/local/bin/nginx-cli-hook approve`** as that login (**no** `sudo`; **no** `sudo -n`).

Domain SSOT (`requirement-domain-nginx-cli`) **points** here. It still owns the dest `approve` / `reject` walk (YAML display, snapshot, publish). LPU law owns **which home** is hooked (nginx-adm only). Family 1 JSON (`login-hook-elev`) stays on `requirement-sudoer-json-file`. This file **MUST NOT** remain only a paragraph on the domain SSOT.

### 1.1 Human-facing

**In one sentence:** After `sudo nginx-cli setup`, logging in as nginx-adm on a real terminal starts review through the labeled name `/usr/local/bin/nginx-cli-hook` (a soft link to `/usr/local/bin/nginx-cli`); an old doorbell that still calls `/usr/local/bin/nginx-cli approve` is replaced.

| Box | Meaning | Example |
|-----|---------|---------|
| You / host admin | Run setup; it plants and heals the doorbell on nginx-adm | `sudo nginx-cli setup` |
| nginx-adm | Login on a TTY; review starts without sudo | `/usr/local/bin/nginx-cli-hook approve` |
| Not this file | How approve publishes a site, or Family 1 password sudo | `requirement-domain-nginx-cli` · `requirement-sudoer-json-file` |

| Includes | Excludes |
|----------|----------|
| Labeled symlink `/usr/local/bin/nginx-cli-hook` → `/usr/local/bin/nginx-cli` | Overwriting a hook name a host admin already retargeted |
| Marker snippet in nginx-adm `.bashrc`; `.profile` create-if-absent | Alice’s or root’s rc |
| Setup review of an **old** product-binary hook and replace with the new hook | Dest inbound walk; Family 1 JSON body |
| As-login `approve` (no sudo) | Wrapping the hook in `sudo` or `sudo -n` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/usr/local/bin/nginx-cli-hook` | labeled hook name | soft link to `/usr/local/bin/nginx-cli` |
| `/etc/nginx-adm/.bashrc` | login snippet | starts review once per TTY session |
| `nginx-cli setup` | host create (root) | install binary, ensure symlink, review/replace LPU hook |
| `nginx-cli enable-login-approval` | plant/heal verb | same snippet heal without full setup |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| First-time host setup | Copies the CLI to `/usr/local/bin/nginx-cli`, creates the labeled hook name if missing, and writes the snippet on nginx-adm. | `sudo nginx-cli setup` |
| Re-run setup on an old host | If nginx-adm still has `/usr/local/bin/nginx-cli approve` (or `sudo … approve`) in the managed block, setup **replaces** it with `/usr/local/bin/nginx-cli-hook approve`. Already-new is left alone. | `sudo nginx-cli setup` |
| Refresh only the snippet | Same replace rules, without recreating the account. | `sudo nginx-cli enable-login-approval` |

## Under command line for normal user only

On Termux, Git Bash, or Windows cmd, **MUST NOT** plant a login hook, **MUST NOT** create `/usr/local/bin/nginx-cli-hook`, and **MUST NOT** recommend `sudo` / `sudo -n` review. **Admin privilege** (`setup` / `enable-login-approval` host write) stays unused. POSIX Linux with a root login is **not** that class.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 New hook = labeled soft link

| Name | Path | Rule |
|------|------|------|
| **Product binary** | `/usr/local/bin/nginx-cli` | Day-to-day CLI and Type 2 switch path. Family 1 `login-hook-elev` `commands[].path` stays this path. |
| **New hook (labeled name)** | `/usr/local/bin/nginx-cli-hook` | What `.bashrc` **MUST** call. |
| **Soft link** | `/usr/local/bin/nginx-cli-hook` → `/usr/local/bin/nginx-cli` | Type 1 `setup` **MUST** create this when the hook name is **missing**. Equivalent: `ln -s nginx-cli /usr/local/bin/nginx-cli-hook` in the same directory. |

1. Type 1 `setup` **MUST** copy/install the ship unit to `/usr/local/bin/nginx-cli` **then** ensure the labeled hook name.  
2. If `/usr/local/bin/nginx-cli-hook` **already exists** (file or symlink), setup **MUST NOT** overwrite it — a host admin **MAY** retarget that doorbell at another similar program.  
3. Fixture mode (`NGINX_CLI_FIXTURE=1`) and a `GLOBAL_BIN` under `/tmp` or `/dev/shm` **MUST NOT** write live `/usr/local/bin`.  
4. Type 0 `uninstall` and Type 1 `remove-lpu` **MUST NOT** unlink `/usr/local/bin/nginx-cli-hook`. Sibling products **MUST** use the same `{{APP_NAME}}-hook` pattern — **MUST NOT** share one literal filename across products.  
5. The snippet **MUST** call the labeled name, **not** `/usr/local/bin/nginx-cli approve`.

### 2.2 Old hook vs new hook (setup **MUST** review)

Type 1 `setup` **MUST** review the LPU account’s login hook (`${NGINX_ADM_HOME}/.bashrc`, and `.profile` when that file contains the managed block). `enable-login-approval` **MUST** apply the same review.

| Finding | MUST |
|---------|------|
| Rc still runs `/usr/local/bin/nginx-cli approve` (old product-binary hook) | Replace with `/usr/local/bin/nginx-cli-hook approve` |
| Rc still runs `sudo … /usr/local/bin/nginx-cli approve` or `sudo -n … approve` | Replace with as-login `/usr/local/bin/nginx-cli-hook approve` (**no** sudo) |
| Rc already runs `/usr/local/bin/nginx-cli-hook approve` (new hook) | **MUST NOT** rewrite |
| Managed markers missing | Append the complete new-hook snippet once |
| `.profile` sources `.bashrc` and still has an old hook copy | Strip the profile copy; **MUST NOT** plant a second snippet there |
| Dedicated home missing (tests / not yet created) | `enable-login-approval` fail closed; `setup` creates the account first then reviews |
| Any other user’s rc | **MUST NOT** inspect or write |

Old hosts keep working because as-login `nginx-cli approve` still starts review; that run is **not** required to rewrite rc. **Setup** is the required healer. **MUST NOT** hang. **MUST NOT** `exit` the login shell from the snippet.

### 2.3 Install table (rc files)

| File | When to write |
|------|----------------|
| Interactive rc (`${NGINX_ADM_HOME}/.bashrc`) | **Always** (create if missing) |
| Login rc (`${NGINX_ADM_HOME}/.profile`) | **Only if** it does **not** exist. Present → **MUST NOT** overwrite. |
| Other users’ rc | **Never** |

After every create or rewrite of those files, owner **MUST** be nginx-adm (writer euid **MUST NOT** remain the owner). `chown` failure is fail closed when the account exists.

### 2.4 Snippet guards (sacred)

| Guard | Rule |
|-------|------|
| **Identity** | `id -un` equals `nginx-adm` |
| **Interactive** | `PS1` set; `$-` contains `i`; `[ -t 0 ]` and `[ -t 1 ]` **in the snippet** (not the CLI `TTY` SSOT) |
| **scp / CI** | Skip when `SSH_ORIGINAL_COMMAND` is set |
| **Session** | Set `NGINX_CLI_HOOK_RAN=1` **before** calling approve; second source is a no-op |
| **Binary** | `/usr/local/bin/nginx-cli-hook approve` — **as-login**. **MUST NOT** copy live `$GLOBAL_BIN`. **MUST NOT** wrap `sudo` or `sudo -n` (`OPEN-ADM-NOSUDO` / `PREV-HOOK-SUDO`) |
| **Approve fail** | Warning on stderr; login **continues** (`exit` forbidden) |
| **Idempotent file** | Begin/end markers; do not append twice |
| **Empty argv** | Hook **MUST** call explicit `approve`. Empty argv of this CLI stays the numbered list on a TTY and help off-TTY |
| **Tokens** | **MUST NOT** appear in rc |
| **Family 1 JSON** | Needs `kind=login-hook-elev` for **password** `sudo nginx-cli <verb>` after dest approve. That grant **MUST NOT** wrap the login hook in sudo. Body: `requirement-sudoer-json-file`. Queue: `requirement-three-layer-privilege-model` |

Dest `approve` (inbound walk) **MUST NOT** be required to rewrite rc. Plant/heal verbs are `setup` and `enable-login-approval`.

### 2.5 Complete snippet sample (normative)

Setup **MUST** write this shape (markers + as-login labeled name):

```sh
# >>> nginx-cli interactive approval (managed) >>>
if [ -z "${NGINX_CLI_HOOK_RAN:-}" ] \
    && [ -n "${PS1:-}" ] \
    && [ -t 0 ] && [ -t 1 ] \
    && case "$-" in *i*) true ;; *) false ;; esac \
    && [ "$(id -un)" = "nginx-adm" ] \
    && [ -z "${SSH_ORIGINAL_COMMAND:-}" ]; then
    NGINX_CLI_HOOK_RAN=1
    export NGINX_CLI_HOOK_RAN
    if ! /usr/local/bin/nginx-cli-hook approve; then
        printf '%s\n' "nginx-cli: login review hook skipped (approve failed)" >&2
    fi
fi
# <<< nginx-cli interactive approval (managed) <<<
```

### 2.6 Complete `.profile` create sample (only when absent)

```sh
# BEGIN nginx-cli profile source-bashrc
# Created so a bash login shell sources interactive rc (hook lives in .bashrc).
if [ -n "${BASH_VERSION:-}" ]; then
    if [ -f "${HOME}/.bashrc" ]; then
        . "${HOME}/.bashrc"
    fi
fi
# END nginx-cli profile source-bashrc
```

### 2.7 Specialized CLI subcommands (dual mention)

| Command | Type | Who | Handler | Behavior |
|---------|------|-----|---------|----------|
| `setup` | Type 1 | root | `ngx_setup` | Dual mention with domain / LPU. **This file** owns: install global binary; create `/usr/local/bin/nginx-cli-hook` → `/usr/local/bin/nginx-cli` when missing; **review** nginx-adm login hook and **replace** an old hook with the new hook. |
| `enable-login-approval` | approver | root or nginx-adm | `ngx_enable_login_approval` | Topic owner. Idempotent marked block in nginx-adm `.bashrc`; replace inner command when it differs from §2.5; create `.profile` if absent. |

**Invocation samples:**

```text
sudo nginx-cli setup
sudo nginx-cli enable-login-approval
nginx-cli enable-login-approval
nginx-cli --json enable-login-approval
```

The review verb the snippet starts is dest `approve` (owned by `requirement-domain-nginx-cli`).

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product / APP_NAME** | `nginx-cli` |
| **Approver** | `nginx-adm` |
| **Review verb** | `approve` |
| **Hook ran var** | `NGINX_CLI_HOOK_RAN` |
| **Markers** | `# >>> nginx-cli interactive approval (managed) >>>` / `# <<< nginx-cli interactive approval (managed) <<<` |
| **New hook (labeled)** | `/usr/local/bin/nginx-cli-hook` |
| **Soft-link target** | `/usr/local/bin/nginx-cli` |
| **Create (when missing)** | `ln -s /usr/local/bin/nginx-cli /usr/local/bin/nginx-cli-hook` (or relative `nginx-cli` in the same dir) |
| **Snippet argv** | `/usr/local/bin/nginx-cli-hook approve` as-login |
| **Old hook (replace)** | `/usr/local/bin/nginx-cli approve` · `sudo /usr/local/bin/nginx-cli approve` · `sudo -n … approve` |
| **Rc home** | live nginx-adm home (preferred `/etc/nginx-adm`; override `NGINX_ADM_HOME`) |
| **Plant verbs** | Type 1 `setup` **MUST** review; `enable-login-approval` **MUST** heal |
| **Dest `approve` walk** | Domain SSOT — **MUST NOT** be the only healer |
| **Fixture** | skip live `/usr/local/bin`; fixture home under `/tmp` **MAY** receive the snippet |
| **Ship unit** | `src/nginx-cli` — `ngx_ensure_login_hook_symlink` · `ngx_enable_login_approval` · `ngx_login_hook_block` |
| **VERSION** | ship unit `1.10.1`; this law **1.0.0** |

### 2.9 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 5 – SSOT**: Snippet + labeled symlink have one owner; domain **points**.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: Guards skip scp / CI; fail warns; login continues.  
- **CIAO Principle 10 – Least privilege**: Hook is as-login on one LPU; no sudo wrap.  
- **CIAO Principle 1 – Caution**: Do not overwrite a retargeted hook name; do not rewrite an already-new snippet.  
- **CIAO Principle 21 – Dual policies**: Sibling CLIs reuse `/usr/local/bin/{{APP_NAME}}-hook` → `/usr/local/bin/{{APP_NAME}}`; this dest fills `nginx-cli`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Identity + TTY + session + scp guards; no `exit` from the login shell.  
- **Intentional**: Labeled doorbell (`nginx-cli-hook`) is not the Type 2 switch path (`nginx-cli`).  
- **Anti-fragile**: Re-run setup heals an old product-binary or `sudo` managed block.  
- **Over-protect**: Fixture never `ln`s live `/usr/local/bin`; F7 does not unlink the global hook name.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Leave the snippet only on dest domain SSOT (this file **MUST** own it).  
2. Call `/usr/local/bin/nginx-cli approve` from the snippet instead of `/usr/local/bin/nginx-cli-hook approve`.  
3. After Type 1 `setup` or `enable-login-approval`, leave nginx-adm rc calling the old product-binary hook.  
4. Rewrite rc that already uses the labeled hook, or inspect another user’s rc.  
5. Overwrite an existing `/usr/local/bin/nginx-cli-hook` name, or create that live name from fixture / test-mode.  
6. Wrap the hook in `sudo` or `sudo -n`.  
7. Hijack empty argv as the review verb.  
8. Overwrite an existing `.profile` body.  
9. Plant the hook in a random human home instead of nginx-adm home.  
10. Hang scp / CI / non-TTY, or `exit` on approve fail.  
11. Put a token in `.bashrc` or `.profile`.  
12. Leave rc owned by the writer after create/`mktemp`+`mv`.  
13. Treat rc heal as the `login-hook-elev` grant.  
14. Invent a second hook alias so sibling apps cannot copy `/usr/local/bin/{{APP_NAME}}-hook`.  
15. Unlink `/usr/local/bin/nginx-cli-hook` from F7 or Type 0 `uninstall`.  
16. Plant a `USER_BIN` PATH line in nginx-adm rc, or re-own this-login path-ensure (`requirement-shell-path-and-shell-support`).

**Violating this rule is a critical login-hook / privilege regression.**

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-NGX-10** | `tests/test_domain.sh` | have | hook inserted once (markers) |
| **TP-NGX-14** | same | have | as-login `/usr/local/bin/nginx-cli-hook approve`; not product-binary; not sudo |
| **TP-NGX-50** | same | have | replace stale `sudo … approve`; second run already present |
| **TP-HOOK-02** | same | have | missing `.profile` created and sources `.bashrc` |
| **TP-HOOK-03** | same | have | existing `.profile` unchanged |
| **TP-HOOK-08** | same | have | old `/usr/local/bin/nginx-cli approve` becomes `-hook`; setup ensure-symlink |
| **TP-HOOK-09** | same | have | Type 1 `setup` reviews LPU hook (`ngx_enable_login_approval`); already-new not rewritten |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-domain-nginx-cli.md` | Dest `approve` walk; domain **points** here for the snippet |
| `docs/requirements/requirement-least-privilege-user.md` | Which home is hooked (nginx-adm F3) |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Family 1 auto-queue; `OPEN-ADM-NOSUDO` |
| `docs/requirements/requirement-sudoer-json-file.md` | `login-hook-elev` body (path stays `/usr/local/bin/nginx-cli`) |
| `docs/requirements/requirement-privilege-prevention-set.md` | **PREV-HOOK-SUDO** |
| `docs/requirements/requirement-shell-cli-interface.md` | Dual mention of `enable-login-approval` |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | No hang; consume `TTY` in CLI helpers |
| `docs/requirements/requirement-shell-path-and-shell-support.md` | This-login PATH / `.profile`; **MUST NOT** plant PATH in nginx-adm rc |
| `./src/nginx-cli` | Implementation |

**Last Updated**: 2026-09-08 (1.0.0 — independent owner; labeled symlink; setup replaces old hook)  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
