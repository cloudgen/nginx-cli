# CLI routed-verb table — nginx-cli

**Product:** nginx-cli  
**Ship unit:** `src/nginx-cli`  
**Dispatcher:** `app_main`  
**Scan date:** 2026-08-23  
**Mode:** full (no previous table)  
**Copied:** 0 · **Re-checked:** 26 live + 9 not-yet-wired  

Inventory is from the dispatcher, not from help. Human-readable is `command: what it does` (explain from `app_help`).

## Live

| verb | handler | privilege | last modified date | human-readable |
|------|---------|-----------|--------------------|----------------|
| version | `app_version` | you | missing | `version: Show local version` |
| about | `app_about` | you | 2026-08-13 | `about: Show diagnostics (includes nginx-adm fields)` |
| help | `app_help` | you | 2026-08-23 | `help: Show this help` |
| install | `inst_local_install` | you | 2026-08-09 | `install: Install nginx-cli (root→global, user→~/.local/bin)` |
| uninstall | `inst_local_uninstall` | you | 2026-08-03 | `uninstall: Remove managed binary (confirm or --force)` |
| where-is-me | `app_where_is_me` | you | 2026-08-03 | `where-is-me: Show running and install paths` |
| setup | `ngx_setup` | change-the-computer | missing | `setup: Create nginx-adm (UID 1999), queues, /etc/nginx-adm/sudoers, Family 1 JSON` |
| remove-lpu | `ngx_remove_lpu` | change-the-computer | missing | `remove-lpu: Remove nginx-adm (confirm or --force)` |
| remove-nginx-adm | `ngx_remove_lpu` | change-the-computer | missing | `remove-nginx-adm: Alias of remove-lpu` |
| request | `ngx_request_submit` | you (submit allowlist) | missing | `request: Submit dest JSON (or nginx-conf text dual)` |
| list-requests | `ngx_list_queue` | you (submit allowlist) | missing | `list-requests: Approving / pending list` |
| list-approved | `ngx_list_queue` | you (submit allowlist) | missing | `list-approved: Approved archive` |
| list-rejected | `ngx_list_queue` | you (submit allowlist) | missing | `list-rejected: Rejected archive` |
| approve | `ngx_approve_interactive` | change-the-computer | missing | `approve: Interactive one-by-one, or approve one file` |
| reject | `ngx_reject_one` | change-the-computer | missing | `reject: Reject one pending request` |
| enable-login-approval | `ngx_enable_login_approval` | change-the-computer | missing | `enable-login-approval: Add or refresh as-login approve in nginx-adm ~/.bashrc (no sudo)` |
| map-set | `ngx_map_set` | change-the-computer | missing | `map-set: Add user-domain-map entry (chown nginx-adm)` |
| map-unset | `ngx_map_unset` | change-the-computer | missing | `map-unset: Remove map entry` |
| map-list | `ngx_map_list` | you (submit allowlist) | missing | `map-list: Show user-domain-map` |
| submit-sudoer-request | `ngx_submit_sudoer_request` | you | 2026-08-15 | `submit-sudoer-request: Queue JSON grant via sudoer-cli (needs --allow-test-local unless global install)` |
| conf-to-json | `ngx_conf_to_json` | you | missing | `conf-to-json: nginx-conf text → dest request JSON` |
| json-to-conf | `ngx_json_to_conf` | you | missing | `json-to-conf: dest request JSON → nginx-conf text` |
| test-json-format | `ngx_test_json_format` | you | missing | `test-json-format: Dest JSON-format fence against a local JSON file (no sudo; does not queue)` |
| fence-test | `ngx_fence_test` | you | missing | `fence-test: Dest fence list against a local JSON file (no sudo; does not queue)` |
| menu | `app_main_menu` | you | 2026-08-23 | `menu: Numbered list of live work commands (alias: main)` |
| main | `app_main_menu` | you | 2026-08-23 | `main: Alias of menu` |

## Not-yet-wired

| verb | handler | privilege | last modified date | human-readable | status |
|------|---------|-----------|--------------------|----------------|--------|
| backup | — | — | — | — | forbidden |
| restore | — | — | — | — | forbidden |
| print-sudoers | — | — | — | — | forbidden |
| print-sudoers-install-script | — | — | — | — | forbidden |
| remove-project-sudoers | — | — | — | — | forbidden |
| self-update | — | — | — | — | forbidden |
| self-uninstall | — | — | — | — | forbidden |
| version-check | — | — | — | — | forbidden |
| nginx-ctl | — | — | — | — | forbidden |

**Honesty:** live rows are dispatcher tokens. `missing` dates mean the handler comment block has no `Last updated:` / `Last reviewed:` (section-level dates are not copied onto every `ngx_*` helper). Forbidden rows stay so the next scan re-checks they did not return.

**Main menu (case 3):** empty argv stays help. Numbered choices are the live operational rows that are not install/setup, self-managed, diagnostics, test-purpose, `help`, or `menu`/`main`. That is **N=14** (remove-lpu through json-to-conf in live order, omitting the `remove-nginx-adm` alias). Exit number **99**.
