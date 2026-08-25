# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.7.0] - 2026-08-25

### Changed

- Type 1 `setup` auto-queues Family 1 JSON (`kind=login-hook-elev`, password `nginx-cli` verbs + leading `--json`) into sibling sudoer-cli inbound when dest exists; skip when missing. **MUST NOT** write `/etc/sudoers.d`. After sudoer-adm approve, dest is `/etc/sudoers.d/nginx-cli-nginx-adm`.
- Family 2 unit tools dest is `/etc/nginx-adm/sudoers`. `ngx_write_adm_sudoers` refuses any dest under `/etc/sudoers.d`.
- Type 0 `submit-sudoer-request` refuses `kind=login-hook-elev` (that grant is Type 1 setup only). Type 0 remains `type-2-switch` (`request` as nginx-adm).
- Login hook stays as-login `nginx-cli approve` (no sudo).

### Fixed

- `setup` fail-closed when `nginx-adm` or UID/GID **1999** is a foreign identity (`ngx_adm_collision_check`; L-COLLIDE-01). Does not rewrite a live foreign account.
- `useradd` / `groupadd` / `userdel` / `groupdel` also try `/usr/sbin` when root PATH is short.
- Type 1 `setup` / `remove-lpu` consume the main-process `TTY` flag (no live `[ -t 0 ]` retest).

### Law

- Three-layer **1.5.0** · sudoer-json-file **1.2.0** · LPU **1.3.0** · prevention **1.6.0** · domain **1.14.0** · default-interaction **1.0.0**.

### Tests

- TP-NGX-51 **have** (collision identity + `/usr/sbin` host-bin). TP-NGX-52 / TP-NGX-53 **have**. TP-CLI-17..22 **have** (`menu`/`main`). Live root inbound write is not in the fixture. Suite PASS=293 FAIL=0 SKIP=0.

## [1.6.1] - 2026-08-23

### Changed

- F6 `/etc/sudoers.d/nginx-adm` now includes a leading **`--json`** form of every Family 1 verb (`sudo nginx-cli --json list-requests`, `sudo nginx-cli --json approve …`). Still password-required. **MUST NOT** `--json *` (that would include `setup`).

### Law

- Three-layer **1.4.0** (Table A + complete fragment).

### Tests

- TP-NGX-15: `--json` prefix present; no `--json setup`; no NOPASSWD on the CLI path.

## [1.6.0] - 2026-08-23

### Added

- Type 0 **`menu`** (alias **`main`**): on a real terminal, a numbered list of live work commands (N=14, Exit **99**). Empty argv stays help. Off-TTY `menu` reuses help (JSON help with `--json`). Interactive `menu --json` still shows the list.

### Law

- `requirement-shell-cli-default-interaction` **1.0.0** (case 3). Interface **2.6.0**. Zero-arguments **1.1.1**. Interactive **1.1.1**. Modular **2.1.1**. Class residual **1.8.1**.

### Tests

- TP-CLI-17..22: off-TTY help / JSON help / `main` alias / help lists menu; TTY list + `--json` ignored (skip if no PTY).

## [1.5.2] - 2026-08-23

### Fixed

- Login hook is as-login `/usr/local/bin/nginx-cli approve` (**no** `sudo`). Interactive `nginx-adm` login no longer prompts for a sudo password (`INC-20260823-001`).
- `enable-login-approval` / `setup` **replace** a stale managed `.bashrc` block (a prior `sudo … approve` line is rewritten). Marker-present is no longer “already present” forever.
- **MUST NOT** wrap the hook in `sudo` or `sudo -n`. Family 1 password `sudo nginx-cli` is unchanged.

### Law

- Domain **1.13.0** · LPU **1.2.0** · three-layer **1.3.0** · prevention **1.5.0** (`PREV-HOOK-SUDO`).

### Tests

- TP-NGX-14: hook as-login (no `sudo`). TP-NGX-50: replace stale sudo-shaped managed block.

## [1.5.1] - 2026-08-22

### Tests

- Close dest Fence **`fence-test`** coverage vs portable **TP-FENCE-08..15** / sibling **TP-SR-FT**: xor `--file`/`--dir`, `--expect-match` without `--dir`, `--json` command field, testers do not queue, `test-json-format` refuses `--dir`, stdin, help `--dir` / `--expect-match` (**TP-NGX-44..49**, **TP-CLI-16**).
- Next on tester fail names the **running** ship unit, not `/usr/local/bin/nginx-cli`.

### Fixed

- CLI-interface notes VERSION SSOT and ship-unit header comments tracked live `VERSION`.
- Review plan / RTM / what-to-review still said 1.4.1 after the 1.5.0 dest Fence ship.

## [1.5.0] - 2026-08-21

### Added

- Type 0 **test-purpose** `fence-test` and `test-json-format` (local test folder; no sudo; does not queue). Help lists testers under **Unit test (local test folder)**.
- Dest-owned `submit_app` / `submit_version` on dest request JSON and compose sudoer JSON. Type 0 `request` / `conf-to-json` stamp live Config. Dest does **not** fence sibling app or version.
- Independent dest Fence law `requirement-incorrect-json-format`. Unknown dest JSON keys fail closed.
- Coding-style related requirement `requirement-shell-script-coding`.

### Tests

- TP-CLI-15, TP-NGX-35..43. Suite PASS=214 FAIL=0 SKIP=0.

## [1.4.1] - 2026-08-18

### Fixed

- `setup` now ensures Family 1 can authenticate: TTY `passwd nginx-adm` (operator types; never recorded) or a non-TTY warn. A locked `useradd` account made `sudo nginx-cli` print `sudo: a password is required` (INC-20260815-001).
- Help / `about` say how to set the password and that a logged-in `nginx-adm` may run day-to-day verbs **without** sudo.
- **MUST NOT** `chpasswd` or NOPASSWD the CLI.
- TP-NGX-02 isolates live host submit grants (`NGINX_CLI_SUBMIT_SUDOERS` and `NGINX_CLI_SUBMIT_PER_USER_DIR`) so a listed operator still sees **Submit denied**.

### Law

- LPU **1.1.0** · three-layer **1.2.0** (JOB-PASSWD) · prevention **1.4.0** (PREV-PASSWD / OPEN-ADM-NOSUDO) · domain **1.11.0**.

### Tests

- TP-NGX-34: setup calls passwd-ensure; help names `passwd nginx-adm`; no `chpasswd`.

## [1.4.0] - 2026-08-15

### Changed

- Dest inbound **is** dest request **JSON** (`yyyyMMdd-user-domain-n.json`). `request` accepts JSON or nginx-conf text (converts first). `approve` re-validates JSON and renders the text dual before `nginx -t` / publish.
- This ship unit is the file-based JSON dest **and** the Type 0 submitter (`request`). Compose `submit-sudoer-request` remains a sibling-dest submitter (sudoer JSON, not dest inbound).
- Convert stays Type 0: never queues, never writes `/etc` or sites trees.

### Law / molds

- Domain **1.10.0** dual-role table · interface **2.4.0** · class **1.7.0** · prevention **1.3.0** (PREV-JSON-BODY inverted). Dest-honest dual-role law lives in the domain REQ (portable molds are local harness, not the published git surface).

### Tests

- TP-NGX request/approve globs `*.json`; convert TP-NGX-21..24; dest JSON inbound TP-NGX-25..29; convert `--out` inbound / `/etc/sudoers.d`; grant allowlist TP-NGX-32; JSON inject TP-NGX-33.

### Fixed (review)

- Convert `--out` refuses `/etc/*` and dest queue dirs (not only sites-available).
- Nested convert no longer emits a second `--json` object on `request` / `approve`.
- Dest JSON site fields refuse `;` / `include` / `lua_` / `load_module` before queue or render.
- Sudoer file-operand grant is an allowlist (`${GLOBAL_BIN}/nginx-cli` + `request` only).
- Approve/reject archive the inbound inode basename (`.json`), not a suffix-less alias.

## [1.3.0] - 2026-08-15

### Added

- Type 0 **`conf-to-json`** / **`json-to-conf`**: convert dest nginx-conf text ↔ closed request JSON. stdin xor `--file`; stdout or `--out`. Never queues; never writes `/etc` or `sites-available`.
- Domain **1.8.0** JSON dual samples (redirect add, HTTPS+proxy update, remove).
- Molds: **LM-FILE-BASED-JSON-APPROVAL** 1.3.0 convert pair; **LM-NGINX-CONF-STRUCTURE** 1.2.0 JSON dual.
- Suite **TP-NGX-21..24**.

### Unchanged

- Dest inbound remains nginx text. Convert is a dual, not dest inbound JSON.

## [1.2.0] - 2026-08-15

### Added

- Type 0 **`submit-sudoer-request`** (folder-backup compose shape, dest-honest grant): detect sibling **sudoer-cli** + **sudoer-adm** + public inbound `/var/sudoer-cli/sudoer-request`; sibling allocates a JSON request. Does **not** write `/etc` and does **not** `mkdir` inbound.
- JSON grant SSOT `requirement-sudoer-json-file` **1.0.0**: grant is **`/usr/local/bin/nginx-cli request`** as **`nginx-adm`** only (no OS tools, no `approve`/`setup`).
- `about` reports `sudoer_cli` / `sudoer_adm` / `sudoer_inbound` / `sudoers_trust_tier`.
- Flags `--purpose`, `--update`, `--allow-test-local` (submit emit only; **no** `print-sudoers`).
- Listed submitter also accepts sibling dest `/etc/sudoers.d/nginx-cli-<login>`.
- Suite **TP-NGX-16..20**.

### Law

- Domain **1.7.0** · three-layer **1.1.0** · interface **2.2.0** · prevention **1.1.0** · class **1.6.0**.
- `print-sudoers` remains **absent**.

## [1.1.0] - 2026-08-15

### Changed

- Request trio moved off LPU home to **`/var/nginx-cli`** (`NGINX_QUEUE_ROOT`).
- Inbound mode **`2770`**, owner `nginx-adm:nginx-cli-submit` (group dropbox; not world-wx).
- Submitter file owner stays the invoker (`0640`); no `chown` to nginx-adm; no `sudo -u nginx-adm` deposit.
- Approve/reject **snapshot + unlink** (do not `mv` the live inbound name).
- Type 0 **must not** `mkdir` production inbound; `remove-lpu` backups and removes `/var/nginx-cli`.
- `user-domain-map` remains under `/etc/nginx-adm`.
- Domain law `requirement-domain-nginx-cli` **1.2.0** (named machine, samples, host stand-up). Suite **TP-NGX-13** (missing inbound).
- Approve/reject snapshot no longer clobbers the inbound path (unlink after publish). Interactive approve consumes `TTY` SSOT.
- Stay-honest: **no `nginx-ctl` command**.
- F6: **password** `sudo /usr/local/bin/nginx-cli` day-to-day verbs **and** restored `NOPASSWD` `/usr/sbin/nginx` + `systemctl`/`journalctl` for unit `nginx`.
- Dest product law retarget: registered REQs / `docs/requirements/README.md` name this product **nginx-cli 1.1.0** (`src/nginx-cli`). **cli-template** remains origin A only (frozen at `src/cli-template`); no reverse-copy onto A.
- Privilege split (sudoer-cli *shape*, dest values): `requirement-least-privilege-user`, `requirement-three-layer-privilege-model`, `requirement-privilege-prevention-set`. Domain 1.6.0 presents the machine and points. **No** `requirement-shell-prompt` / `requirement-shell-temp-file-system`. **No** copy of 3773 / JSON / NOPASSWD-CLI / `nginx-ctl`.
- Review/test plan: TP-CLI-14 (`nginx-ctl` unknown), TP-NGX-14 (hook not `sudo -n`), TP-NGX-15 (inbound `2770`, F6 two families).
- Dest forge identity: `cloudgen/nginx-cli` (not origin `cli-template`). SECURITY 1.1.0 + dest sudoers posture.

## [1.0.0] - 2026-08-13

### Added

- **nginx-cli** specialized from **cli-template** (origin frozen at `src/cli-template`).
- Type 1 `setup` / `remove-lpu` for **nginx-adm** (UID/GID 1999, home `/etc/nginx-adm`).
- Home queues: `user-domain-map`, `config-request`, `config-approved`, `config-rejected`.
- Config request workflow: `request`, `list-requests`, `list-approved`, `list-rejected`, `approve`, `reject`.
- Submit gate: root, nginx-adm, or `/etc/sudoers.d/nginx-cli-submit`.
- Interactive approval and `enable-login-approval` bashrc hook.
- Domain law `requirement-domain-nginx-cli.md` and glossary terms for the request workflow.
- Suite **TP-NGX-01..12** (fixture; no host user create).

### Inherited (from cli-template)

- Type 0 local self-managed CLI: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`.
- Empty argv **Type N** help.
- Suite **TP-CLI-*** and **TP-LC-***.

### Changed

- Identity SSOT: `APP_NAME=nginx-cli`, ship unit `src/nginx-cli`.
- Bootstrap chain: A = cli-template → B = nginx-cli.

## cli-template [1.0.0] (origin)

Type 0 template bootstrap origin. See `src/cli-template` and the [cli-template](https://github.com/cloudgen/cli-template) repository.
