# nginx-cli - Nginx least-privilege admin CLI

![Version](https://img.shields.io/badge/Version-1.7.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/nginx-cli?style=flat-square)](https://github.com/cloudgen/nginx-cli)

POSIX `/bin/sh` CLI specialized from **cli-template**: Type 0 local install plus Type 1 **nginx-adm** setup and a **config request / approve / reject** workflow. It does **not** provide an online `curl|sh` channel.

Install **location** is still **both**:
- **local** → `~/.local/bin/nginx-cli` (normal user)
- **global** → `/usr/local/bin/nginx-cli` (root / `--global`)

## Features

- **Self-management**: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`
- **Numbered list**: on a real terminal, `menu` (or `main`) lists live work commands; typing only `nginx-cli` still shows help
- **nginx-adm LPU**: `setup` creates UID/GID **1999**, home `/etc/nginx-adm`, sites ownership, Family 2 `/etc/nginx-adm/sudoers`, and queues Family 1 JSON when sudoer-cli exists (does **not** write `/etc/sudoers.d`)
- **Request queues** under `/var/nginx-cli`: `config-request` (`2770`, group `nginx-cli-submit`), `config-approved`, `config-rejected`; **user-domain-map** stays under nginx-adm home
- **Submit gate**: only root, nginx-adm, or logins listed in `/etc/sudoers.d/nginx-cli-submit` **or** `/etc/sudoers.d/nginx-cli-<login>` **and** in group `nginx-cli-submit`
- **`submit-sudoer-request`**: Type 0 compose to sibling **sudoer-cli** (JSON grant; no `/etc` write)
- **`conf-to-json` / `json-to-conf`**: Type 0 convert dest nginx-conf text ↔ request JSON (does not queue; dest inbound is dest request JSON)
- **Unit testers**: `fence-test` / `test-json-format` check dest JSON fences against a local file (no sudo; does not queue)
- **Request names**: `yyyyMMdd-user-domain-n.json`; queued body is dest request JSON (`request` also accepts nginx-conf text and converts first)
- **Approve**: snapshot inbound, publish to `sites-available` / enable-dir symlink, unlink inbound (do not `mv`)
- **Reject**: snapshot inbound into rejected archive, unlink inbound (no publish)
- **Interactive approval** and optional nginx-adm `.bashrc` login hook
- **Type N empty argv**: no arguments shows help; `menu` / `main` opens the numbered list on a real terminal
- **CIAO / CIAO-Lite** defensive design (`out_*` output SSOT)

## Quick Installation

**Local (Type 0 day-to-day):**

```sh
# From this repository checkout
sh src/nginx-cli install
# or force refresh after updates
sh src/nginx-cli install --force

# Ensure ~/.local/bin is on PATH, then:
nginx-cli version
```

**Global (multi-user hosts):**

```sh
sudo sh src/nginx-cli install
```

**Host operator (Type 1):**

```sh
sudo nginx-cli setup
```

This product is **local-only** for its install channel (no default `SCRIPT_URL` online install). Bootstrap origin: [cloudgen/cli-template](https://github.com/cloudgen/cli-template).

After install, on a terminal (`nginx-cli menu`; empty argv still shows help):

```text
$ nginx-cli menu
[INFO] nginx-cli — numbered list of live work commands
  1. remove-lpu: Remove nginx-adm (confirm or --force)
  2. request: Submit dest JSON (or nginx-conf text dual)
  3. list-requests: Approving / pending list
  4. list-approved: Approved archive
  5. list-rejected: Rejected archive
  6. approve: Interactive one-by-one, or approve one file
  7. reject: Reject one pending request
  8. enable-login-approval: Add or refresh as-login approve in nginx-adm ~/.bashrc (no sudo)
  9. map-set: Add user-domain-map entry (chown nginx-adm)
  10. map-unset: Remove map entry
  11. map-list: Show user-domain-map
  12. submit-sudoer-request: Queue JSON grant via sudoer-cli (needs --allow-test-local unless global install)
  13. conf-to-json: nginx-conf text → dest request JSON
  14. json-to-conf: dest request JSON → nginx-conf text
  99. Exit
```

Choose a number, or type the command name. `99` exits.

## Usage

```sh
nginx-cli help
nginx-cli menu
nginx-cli about
nginx-cli --json about

sudo nginx-cli setup
nginx-cli request example.com ./site.conf
nginx-cli submit-sudoer-request
nginx-cli list-requests
nginx-cli approve
nginx-cli reject 20260813-alice-example.com-1
sudo nginx-cli remove-lpu --force
```

**Submit privilege:** root, `nginx-adm`, or a login listed in `/etc/sudoers.d/nginx-cli-submit` (or a sibling-approved `/etc/sudoers.d/nginx-cli-<login>`) and in group `nginx-cli-submit`. Other users cannot `request`. Type 0 writes the public inbound as the invoker (no `sudo -u nginx-adm` deposit).

**Sudoers compose:** `nginx-cli submit-sudoer-request` queues a JSON grant via **sudoer-cli** into `/var/sudoer-cli/sudoer-request`. This CLI does not write `/etc`. Global install is the production trust tier; local-only emit needs `--allow-test-local`.

**Environment (selected):**

| Variable | Role |
|----------|------|
| `REPO_USER` / `REPO_NAME` | Repository identity |
| `SCRIPT_URL` | Online install channel (default **empty** — local only) |
| `USER_BIN` / `GLOBAL_BIN` | Install destinations |
| `NGINX_ADM_HOME` | Override LPU home |
| `NGINX_QUEUE_ROOT` | Public queue root (default `/var/nginx-cli`) |
| `NGINX_CONF_ROOT` | Conf root (default `/etc/nginx`) |

## Examples

```sh
# Local install
sh src/nginx-cli install

# Create nginx-adm, queues, Family 2 /etc/nginx-adm/sudoers
sudo nginx-cli setup
# TTY setup runs passwd nginx-adm. If it did not: sudo passwd nginx-adm
# If sudoer-cli is present, setup queues Family 1 JSON for sudoer-adm.

# Map a submitter's domain, then submit
sudo nginx-cli map-set alice example.com
# (alice listed in /etc/sudoers.d/nginx-cli-submit)
nginx-cli request example.com ./example.com.conf

# Approver login (or run explicitly). As nginx-adm, no sudo is required:
# the login hook runs nginx-cli approve (not sudo, not sudo -n).
nginx-cli approve
# sudo nginx-cli approve needs the nginx-adm account password (not NOPASSWD).
```

Request files must start with `#` comments describing intention / objectives / update, then a normal nginx `server` block.

## Platform Compatibility

| Platform | Status |
|----------|--------|
| Linux, `/bin/sh` (dash/bash) | Supported |
| `useradd` / `userdel` / `visudo` | Required for `setup` / `remove-lpu` |
| macOS / BSD | Not primary |

## Related Projects

- [cli-template](https://github.com/cloudgen/cli-template) — bootstrap origin (Type 0 template)
- [CIAO Defensive Programming](https://github.com/cloudgen/ciao)
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite)

## Contributing

Keep changes surgical. Honor **CIAO-Lite Protection Zones** in `src/nginx-cli`. Product behavior must stay consistent with live `docs/requirements/requirement-*.md`. Run `sh tests/run.sh` before proposing commits.

## License

MIT License — see [`LICENSE.md`](./LICENSE.md).

## Last Update

2026-08-25 — version **1.7.0** (`setup` auto-queues Family 1 JSON; collision identity fail-closed; numbered list on `menu`/`main`).
