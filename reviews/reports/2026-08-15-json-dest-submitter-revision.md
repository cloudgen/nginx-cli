# Product review: nginx-cli (JSON dest + dest-as-submitter revision)

**Date:** 2026-08-15  
**Reviewer:** grok-4.6 (local `/review` + checklist)  
**Product:** nginx-cli `VERSION=1.4.0`  
**Ship unit:** `./src/nginx-cli`  
**Scope:** revision (domain 1.10.0), tests (TP-NGX JSON inbound), living checklist  
**Method:** disk read + `/tmp/grok-1002/grok-review-2b13baba.md` + `sh tests/run.sh`  
**Baseline:** see suite line below

## Summary

The ship unit is the file-based JSON dest and the Type 0 dest submitter (`request`). Convert stays Type 0. `submit-sudoer-request` stays a sibling machine. Review found four fail-closed holes (convert `--out`, `--json` double object, unsanitized JSON→nginx fields, denylist-only sudoer grant) plus stale VERSION 1.2.0 on the living checklist. Those were fixed in the same change.

## Strengths

| Area | Notes |
|------|--------|
| Dual-role law | Domain §2.0.0 names dest + dest submitter + sibling compose |
| Convert honesty | Never queues; syntax gate on rendered text |
| Fixture suite | TP-NGX covers request/approve/reject without host useradd |

## Findings

### NGX-SEC-01 — Severity: P1 (high)
- **Status:** fixed  
- **Location:** `ngx_convert_refuse_dest_path`  
- **Description:** `--out` did not refuse `/etc/*` or dest queue dirs.  
- **Suggestion applied:** refuse `/etc`, `${NGINX_CONF_ROOT}`, `/var/nginx-cli`, fixture queue root. TP-NGX-23.

### NGX-OUT-01 — Severity: P1 (high)
- **Status:** fixed  
- **Location:** `ngx_request_submit` / `ngx_approve_one`  
- **Description:** nested convert emitted a second `--json` object.  
- **Suggestion applied:** `JSON=0` around subroutine convert. TP-NGX-29.

### NGX-SEC-02 — Severity: P1 (high)
- **Status:** fixed  
- **Location:** `ngx_json_to_conf` / `ngx_validate_request_json`  
- **Description:** site fields interpolated without refuse `;` / `include`.  
- **Suggestion applied:** `ngx_nginx_field_ok`. TP-NGX-33.

### NGX-SEC-03 — Severity: P1 (high)
- **Status:** fixed  
- **Location:** `ngx_sudoers_refuse_forbidden_grant`  
- **Description:** denylist-only; `/usr/bin/python3` + `request` accepted.  
- **Suggestion applied:** allowlist path + args. TP-NGX-32.

### NGX-DOC-01 — Severity: P2 (medium)
- **Status:** fixed  
- **Location:** `reviews/what-to-review.md`  
- **Description:** living checklist still said VERSION 1.2.0; no P14/P15 JSON dest rows.  
- **Suggestion applied:** VERSION 1.4.0; P14–P16; sudoer-json-file law row.

### NGX-TEST-01 — Severity: P2 (medium)
- **Status:** fixed  
- **Location:** `tests/test_domain.sh`  
- **Description:** no `request` of dest JSON; approve existence-only.  
- **Suggestion applied:** TP-NGX-25..29, 32, 33.

## Non-findings

| Check | Result |
|-------|--------|
| Second nginx submitter product | Not invented |
| print-sudoers | Still absent |
| Inbound 2770 / no 3773 | Held |
| Origin A frozen | Held |
| Companion `.sha256` | N/A — local-only, empty `SCRIPT_URL` |

## Priority remediation order

1. (done) Convert `--out` + JSON silence + field refuse + grant allowlist  
2. (done) Living checklist + tests  
3. Watch L-JSON-IN-01 / L-CONVERT-OUT-01 / L-SH-GLOBAL-01 / L-SUDOER-GRANT-01

## Related

| Artifact | Role |
|----------|------|
| `/tmp/grok-1002/grok-review-2b13baba.md` | Ephemeral `/review` notes |
| `reviews/what-to-review.md` | Living checklist |
| `docs/checklists/2026-08-15-checklist-file-based-json-approval-dest.md` | CL-FILE-BASED-JSON-APPROVAL run |

**Review status:** Findings fixed in this change
