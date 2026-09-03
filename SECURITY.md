# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.8.0 (current) | Yes |
| 1.7.0 | Yes |
| 1.6.x | Best effort |
| 1.5.x | Best effort |
| 1.4.x | Best effort |

## Reporting a Vulnerability

Please **do not** open a public issue for security-sensitive reports when a private channel is available.

**Maintainer contact (email):** `wongcf22@gmail.com`

- Source of contact: product **author-email** SSOT in [`LICENSE.md`](./LICENSE.md) (Copyright line).  
- Prefer email (or private GitHub security advisories when enabled) for vulnerability details, reproduction steps, and impact.  
- Do not include exploit weaponization guides in public channels.

## Security Design Principles (CIAO)

This project follows **[CIAO](https://github.com/cloudgen/ciao)** / **[CIAO-Lite](https://github.com/cloudgen/ciao-lite)** defensive design. Security-relevant intent:

| Letter | Principle | Security application |
|--------|-----------|----------------------|
| **C** | **Caution** | Unknown commands fail closed; submit and non-TTY approve fail closed. |
| **I** | **Intentional** | Type 0 lifecycle plus dest nginx-adm request/approve; F6 two families. |
| **A** | **Anti-fragile** | Isolated scratch; inbound `2770` not world-wx; snapshot + unlink approve. |
| **O** | **Over-protect** | No `nginx-ctl`; no NOPASSWD on `nginx-cli`; no Type 0 mkdir inbound. |

Full principles: [CIAO](https://github.com/cloudgen/ciao) · [CIAO-Lite](https://github.com/cloudgen/ciao-lite).

This section is **design posture**, not a third-party certification claim.

## Scope notes

- Type 1 `setup` **MAY** write Family 2 unit tools to `/etc/nginx-adm/sudoers` (not under `/etc/sudoers.d`). Family 1 (password `nginx-cli` verbs + `--json`) is a sibling JSON grant (`kind=login-hook-elev`). Setup **MUST NOT** write `/etc/sudoers.d`. It does **not** write `/etc/sudoers` (main) or emit a `print-sudoers` verb.  
- Type 0 `submit-sudoer-request` hands a dest-honest JSON grant (`kind=type-2-switch`, `nginx-cli request` as `nginx-adm`) to sibling **sudoer-cli**. It **MUST NOT** queue `login-hook-elev`. It does **not** write `/etc` and does **not** `mkdir` the sibling inbound.  
- Public queues live under `/var/nginx-cli` (inbound `2770`, group `nginx-cli-submit`). `user-domain-map` stays under LPU home.  
- Type 0 `uninstall` removes only the managed binary — not the LPU or queues.  
- Local `~/.local/bin` install is user-rewritable; prefer global `/usr/local/bin/nginx-cli` on multi-user hosts (production F6 Cmnd).  
- Related docs: [`README.md`](./README.md), [`LICENSE.md`](./LICENSE.md).
