# Lessons — nginx-cli

Durable failure modes. **Always re-check on product review.**

| ID | Mode | Prevention | Status |
|----|------|------------|--------|
| L-TYPE-N-01 | Empty argv becomes install-ensure (parent Type O leak) | `requirement-shell-cli-zero-arguments` Type N; TP-CLI-07 | open watch |
| L-ONLINE-01 | Online verbs reintroduced (self-update / SCRIPT_URL UX) | bootstrap-trim + TP-CLI-04/10 | open watch |
| L-UNIN-01 | Non-interactive uninstall succeeds without force | TP-LC-05 confirm fail-closed | open watch |
| L-INST-MODE-01 | Install leaves `0711`/`0700` (chmod +x after mktemp) so non-owners cannot run shell ship unit | absolute `chmod 0755` + heal on reinstall; TP-LC-09/10; local-self-management §2.3.1 | open watch |
| L-TRIM-01 | Backup / restore / print-sudoers verbs reintroduced as if still product law | bootstrap-chain (those surfaces absent); TP-CLI-04/13 | open watch |
| L-ORIGIN-01 | Dest notes/ACs claim this product *is* cli-template, or reverse-copy onto `src/cli-template` | bootstrap-chain 4.1.0; A frozen; this product is B | open watch |
| L-PUSH-VAULT-01 | Bare `git push` uses wrong active SSH vault when default face ≠ repository-user | Pre-git report + bound SSH transport; incident 20260810-001 | open watch |
| L-SETU-01 | `set -u` crash with unset HOME | TP-CLI-11 | open watch |
| L-STOR-01 | Shared world-writable storage | util_resolve_storage; TP-CLI-12 | open watch |
| L-F6-01 | F6 becomes NOPASSWD whole `nginx-cli` or drops unit `nginx`/`systemctl`/`journalctl` | three-layer Table A two families; PREV-F6-NOPASSWD-CLI; OPEN-UNIT-TOOLS; TP-NGX-15 | open watch |
| L-NGINX-CTL-01 | Invent or allowlist `nginx-ctl` | PREV-NGINX-CTL; TP-CLI-14 | open watch |
| L-INBOUND-01 | Inbound world-wx / `3773` copied from sudoer-cli | LPU F5 `2770`; PREV-WORLD-WX; TP-NGX-15 | open watch |
| L-HOOK-N-01 | Login hook uses `sudo -n` for `nginx-cli` | PREV-SUDO-N-CLI; TP-NGX-14 | open watch |

**Related-product only (do not re-apply as this product’s law):** L-DEPOSIT-01, L-SUDOERS-01..05, L-OVERWRITE-01 stay on folder-backup. Type O empty-argv / online-channel lessons stay on products that own those surfaces. Origin A is `cli-template` (frozen); this product is B.

**This product’s kept Type 0 surfaces:** output SSOT, no basename gate on entry, storage isolation, Type N empty argv. Domain surfaces live in `requirement-domain-nginx-cli.md`.
