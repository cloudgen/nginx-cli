# Lessons — nginx-cli

Durable failure modes. **Always re-check on product review.**

| ID | Mode | Prevention | Status |
|----|------|------------|--------|
| L-TYPE-N-01 | Empty argv becomes install-ensure (parent Type O leak) | `requirement-shell-cli-zero-arguments` Type N; TP-CLI-07 (off-TTY help) · TP-CLI-25 (TTY list) | open watch |
| L-HYPHEN-USER-01 | Dest fence compared JSON `username` (`id -un`) to path-safe basename user; hyphenated logins failed submit | Compare via path-safe encoding; TP-NGX-54 | open watch |
| L-HUMAN-01 | Product README / REQ Purpose leads with Type 0 / Type 1 / euid as the only words | §1.1 Human-facing on every REQ; README Description uses people-and-folders voice | open watch |
| L-MAP-STALE-01 | `reviews/test-plan.md` / what-to-review stay on a prior VERSION while ship unit moved (empty argv = help after TTY list shipped) | Same-change maps when dispatcher empty-argv changes; TP-CLI-23..25 | open watch |
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
| L-HOOK-SUDO-01 | Login hook wraps password `sudo nginx-cli approve` so every nginx-adm TTY login prompts; JOB-PASSWD does not retire the prompt | OPEN-ADM-NOSUDO as-login emit (no sudo, no `sudo -n`); replace managed rc block on emit change; incident 20260823-001 | open watch |
| L-F6-STATUS-01 | Comment/help say NOPASSWD `systemctl` but Table A is only start/stop/reload/restart; operator `status` fails | Exact-verb wording; add `status` only after Table A change; incident 20260815-001 | open watch |
| L-F6-PASSWD-01 | `setup` `useradd` leaves nginx-adm without a password; hook / Family 1 then fail `sudo: a password is required` | JOB-PASSWD / `ngx_ensure_adm_password`; TP-NGX-34; do not `sudo -n` the CLI; incident 20260815-001 | open watch |
| L-SUBMIT-01 | Type 0 `submit-sudoer-request` writes `/etc` or `mkdir` sibling inbound | three-layer §2.5.3; PREV-T0-SUDOER-MKDIR; TP-NGX-16/19 | open watch |
| L-JSON-IN-01 | Dest inbound treated as nginx-text-only, or approve feeds raw JSON to `nginx -t` | PREV-JSON-BODY / PREV-JSON-GATE; domain 1.10.0; TP-NGX-25..28 | open watch |
| L-CONVERT-OUT-01 | Convert `--out` writes `/etc`, sites trees, or dest inbound | PREV-CONVERT-DEST / PREV-CONVERT-QUEUE; TP-NGX-23 | open watch |
| L-SH-GLOBAL-01 | Nested convert clobbers caller `_` temps or emits a second `--json` object | distinct names (`_jsfile` / `_payload`); `JSON=0` around subroutine convert; TP-NGX-29 | open watch |
| L-SUDOER-GRANT-01 | File-operand sudoer grant accepts a non-listed binary | allowlist path=`${GLOBAL_BIN}/nginx-cli` args=`request`; TP-NGX-18/32 | open watch |
| L-TEST-HOST-01 | Live `/etc/sudoers.d/nginx-cli-<login>` makes TP-NGX-02 skip Submit denied | Isolate `NGINX_CLI_SUBMIT_SUDOERS` + `NGINX_CLI_SUBMIT_PER_USER_DIR` | open watch |
| L-FENCE-TEST-01 | Count dest `approve` as `fence-test`, or testers need sudo / queue / GLOBAL_BIN Next | FC-M6; testers local folder; Next = running ship; TP-NGX-35..49 · TP-CLI-15/16 | open watch |
| L-COLLIDE-01 | `setup` treats existing `nginx-adm` as success without verifying UID/GID 1999 and expected home | Fail closed on foreign identity (`ngx_adm_collision_check`; dest values 1999); TP-NGX-51 | closed |
| L-F6-JSON-01 | `setup` copies `/etc/sudoers.d/nginx-adm` instead of queueing Family 1 JSON for sudoer-adm | three-layer 1.5.0; TP-NGX-52/53; ship 1.7.0 auto-queue | closed |

**Related-product only (do not re-apply as this product’s law):** L-DEPOSIT-01, L-SUDOERS-01..05, L-OVERWRITE-01 stay on folder-backup. Type O empty-argv / online-channel lessons stay on products that own those surfaces. Origin A is `cli-template` (frozen); this product is B.

**This product’s kept Type 0 surfaces:** output SSOT, no basename gate on entry, storage isolation, Type N empty argv (TTY numbered list / off-TTY help). Domain surfaces live in `requirement-domain-nginx-cli.md`.
