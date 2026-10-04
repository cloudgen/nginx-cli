# nginx-cli - Nginx least-privilege admin CLI

![Version](https://img.shields.io/badge/Version-1.11.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/nginx-cli?style=flat-square)](https://github.com/cloudgen/nginx-cli)

**nginx-cli** is a command-line program you install on a Linux host so **your login** can request an nginx site file, and a dedicated **nginx-adm** account can approve or reject that request. It is a local checkout install — there is **no** online `curl | sh` channel.

| Who | What they do | Typical command |
|-----|----------------|-----------------|
| You (this login) | Install the program for yourself; convert nginx text ↔ JSON; drop a site request | `nginx-cli request example.com ./site.conf` |
| Host admin / nginx-adm | Create nginx-adm once; review waiting files; publish or reject | `sudo nginx-cli setup` then `nginx-cli approve` |
| Not this program | An online installer, a public release URL, or writing `/etc/sudoers.d` itself | (none — local checkout only) |

Install **location** is still **both**:
- **local** → `~/.local/bin/nginx-cli` (this login)
- **global** → `/usr/local/bin/nginx-cli` (root / `--global`)

On Termux, Git Bash, or Windows cmd, only **this login** is in play: help, local install, convert, and testers. Host setup (`setup` / `remove-lpu`) is a Linux-with-root job.

## Features

- **Install for yourself**: `install`, `self-install`, `uninstall`, `where-is-me`, `version`, `about`, `help` (copy from this checkout; no network)
- **Main menu**: on a real terminal, `nginx-cli` with no command (switches such as `--debug` still count as no command) or `menu` / `main` opens a short board: request-side, host-side, language, sudoers, self-management, Exit. A wrong number warns and reprints that board. A script with no command places this CLI (`self-install`). `menu` off a terminal stops with an error. Display language is menu row 5 (thirteen languages)
- **One-time host setup**: `setup` creates **nginx-adm** (UID/GID **1999**, home `/etc/nginx-adm`), the waiting folders, and a unit-tools sudoers file under `/etc/nginx-adm/sudoers`. It does **not** write `/etc/sudoers.d`. If sibling **sudoer-cli** is already set up, it queues a JSON grant for sudoer-adm to approve
- **Waiting folders** under `/var/nginx-cli`: `config-request` (`2770`, group `nginx-cli-submit`), `config-approved`, `config-rejected`; the user-to-domain map stays under nginx-adm home
- **Who may submit**: root, nginx-adm, or a login listed in `/etc/sudoers.d/nginx-cli-submit` **or** `/etc/sudoers.d/nginx-cli-<login>` **and** in group `nginx-cli-submit`
- **Ask sudoer-cli for a grant**: `submit-sudoer-request` queues JSON for sibling sudoer-cli (does not write `/etc`)
- **Convert without queueing**: `conf-to-json` / `json-to-conf` turn nginx `server` text ↔ request JSON
- **Check a file on disk**: `fence-test` / `test-json-format` test dest JSON rules against a local file (no sudo; does not queue)
- **Request names**: `yyyyMMdd-user-domain-n.json`; the waiting file is dest request JSON (`request` also accepts nginx-conf text and converts first)
- **Approve**: snapshot the waiting file, publish to `sites-available` / enable-dir symlink, then unlink the waiting file (do not `mv`)
- **Reject**: snapshot into the rejected archive, unlink the waiting file (no publish)
- **Review on login**: nginx-adm `.bashrc` runs `/usr/local/bin/nginx-cli-hook approve` (as that login, no sudo). Each waiting file is shown as YAML (the file on disk stays JSON)
- **CIAO / CIAO-Lite** defensive design (one output family for messages)

## Quick Installation

**Local (this login, day-to-day):**

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

**Host operator (needs root once):**

```sh
sudo nginx-cli setup
```

`setup` copies the program to `/usr/local/bin/nginx-cli` and, when missing, creates `/usr/local/bin/nginx-cli-hook` as a soft link to `/usr/local/bin/nginx-cli`. It also reviews nginx-adm’s login hook and replaces an old `/usr/local/bin/nginx-cli approve` (or `sudo … approve`) managed block with `/usr/local/bin/nginx-cli-hook approve`.

This product is **local-only** for its install channel (no default `SCRIPT_URL` online install). Bootstrap origin: [cloudgen/cli-template](https://github.com/cloudgen/cli-template).

After install, on a terminal:

```text
$ nginx-cli
[INFO] nginx-cli(1.11.0)
1. request-side: this login's nginx site requests
2. host-side: nginx-adm on this host (setup, remove, login hook)
5. language: display language for this menu
7. sudoers: passwordless sudo grant for this CLI
8. self-management: this CLI install, version, and about
9. Exit
```

Choose a number, or type the category name. `9` leaves. `0` on an inner board goes back. A number that is not on that board (for example `6` on the front) prints a warning, reprints that board, and waits again. On a terminal the name is bold and the explanation is italic.

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

**Submit privilege:** root, `nginx-adm`, or a login listed in `/etc/sudoers.d/nginx-cli-submit` (or a sibling-approved `/etc/sudoers.d/nginx-cli-<login>`) and in group `nginx-cli-submit`. Other users cannot `request`. Your login writes the waiting file as itself (no `sudo -u nginx-adm` deposit).

**Sudoers compose:** `nginx-cli submit-sudoer-request` queues a JSON grant via **sudoer-cli** into `/var/sudoer-cli/sudoer-request`. This CLI does not write `/etc`. Global install is the production trust tier; local-only emit needs `--allow-test-local`.

**Environment (selected):**

| Variable | Role |
|----------|------|
| `REPO_USER` / `REPO_NAME` | Repository identity |
| `SCRIPT_URL` | Online install channel (default **empty** — local only) |
| `USER_BIN` / `GLOBAL_BIN` | Install destinations |
| `NGINX_ADM_HOME` | Override nginx-adm home |
| `NGINX_QUEUE_ROOT` | Public queue root (default `/var/nginx-cli`) |
| `NGINX_CONF_ROOT` | Conf root (default `/etc/nginx`) |

## Examples

```sh
# Local install
sh src/nginx-cli install

# Create nginx-adm, waiting folders, and /etc/nginx-adm/sudoers (unit tools)
sudo nginx-cli setup
# TTY setup runs passwd nginx-adm. If it did not: sudo passwd nginx-adm
# If sudoer-cli is present, setup queues a JSON grant for sudoer-adm.

# Map a submitter's domain, then submit
sudo nginx-cli map-set alice example.com
# (alice listed in /etc/sudoers.d/nginx-cli-submit)
nginx-cli request example.com ./example.com.conf

# Approver login (or run explicitly). As nginx-adm, no sudo is required:
# the login hook runs /usr/local/bin/nginx-cli-hook approve (not sudo, not sudo -n).
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

- [cli-template](https://github.com/cloudgen/cli-template) — bootstrap origin (frozen starter CLI)
- [CIAO Defensive Programming](https://github.com/cloudgen/ciao)
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite)

## Contributing

Keep changes surgical. Honor **CIAO-Lite Protection Zones** in `src/nginx-cli`. Product behavior must stay consistent with live `docs/requirements/requirement-*.md`. Run `sh tests/run.sh` before proposing commits.

## License

MIT License — see [`LICENSE.md`](./LICENSE.md).

## Last Update

2026-10-04 — version **1.11.0** (layered main menu, menu language, per-process cache, local self-install for a script with no command).
