# nginx-cli - Nginx least-privilege admin CLI

![Version](https://img.shields.io/badge/Version-1.1.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/nginx-cli?style=flat-square)](https://github.com/cloudgen/nginx-cli)

POSIX `/bin/sh` CLI specialized from **cli-template**: Type 0 local install plus Type 1 **nginx-adm** setup and a **config request / approve / reject** workflow. It does **not** provide an online `curl|sh` channel.

Install **location** is still **both**:
- **local** → `~/.local/bin/nginx-cli` (normal user)
- **global** → `/usr/local/bin/nginx-cli` (root / `--global`)

## Features

- **Self-management**: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`
- **nginx-adm LPU**: `setup` creates UID/GID **1999**, home `/etc/nginx-adm`, sites ownership, restricted sudoers
- **Request queues** under `/var/nginx-cli`: `config-request` (`2770`, group `nginx-cli-submit`), `config-approved`, `config-rejected`; **user-domain-map** stays under nginx-adm home
- **Submit gate**: only root, nginx-adm, or logins listed in `/etc/sudoers.d/nginx-cli-submit` **and** in group `nginx-cli-submit`
- **Request names**: `yyyyMMdd-user-domain-n` with `#` intention header + nginx conf body
- **Approve**: snapshot inbound, publish to `sites-available` / enable-dir symlink, unlink inbound (do not `mv`)
- **Reject**: snapshot inbound into rejected archive, unlink inbound (no publish)
- **Interactive approval** and optional nginx-adm `.bashrc` login hook
- **Type N empty argv**: no arguments shows help
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

## Usage

```sh
nginx-cli help
nginx-cli about
nginx-cli --json about

sudo nginx-cli setup
nginx-cli request example.com ./site.conf
nginx-cli list-requests
nginx-cli approve
nginx-cli reject 20260813-alice-example.com-1
sudo nginx-cli remove-lpu --force
```

**Submit privilege:** root, `nginx-adm`, or a login listed in `/etc/sudoers.d/nginx-cli-submit` and in group `nginx-cli-submit`. Other users cannot submit. Type 0 writes the public inbound as the invoker (no `sudo -u nginx-adm` deposit).

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

# Create nginx-adm and queues
sudo nginx-cli setup

# Map a submitter's domain, then submit
sudo nginx-cli map-set alice example.com
# (alice listed in /etc/sudoers.d/nginx-cli-submit)
nginx-cli request example.com ./example.com.conf

# Approver login (or run explicitly)
nginx-cli approve
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

2026-08-15 — version **1.1.0** (public `/var/nginx-cli` queues, group `2770`, snapshot approve).
