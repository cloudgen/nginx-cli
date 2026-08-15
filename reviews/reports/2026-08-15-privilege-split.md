# Report: privilege-split + review/test-plan — nginx-cli 1.1.0

**Date:** 2026-08-15  
**Mode:** product-surface (reviews/ + law + suite)  
**Status:** clean (suite green; dest-honest privilege split locked in)

## Summary

Revised the public review plan and test plan for the dest-honest LPU / three-layer / prevention split. Added TP-CLI-14 and TP-NGX-14..15 so F6 two families, inbound 2770, no `nginx-ctl`, and password hook are automated. Suite **PASS=127 FAIL=0 SKIP=0**. Lessons L-F6-01, L-NGINX-CTL-01, L-INBOUND-01, L-HOOK-N-01 added. Prompt/temp REQs remain absent.

## Lessons re-checked

| ID | Result |
|----|--------|
| L-TYPE-N-01 | still held (TP-CLI-07) |
| L-ONLINE-01 | still held (TP-CLI-04/10) |
| L-UNIN-01 | still held (TP-LC-05) |
| L-INST-MODE-01 | still held (TP-LC-09/10) |
| L-TRIM-01 | still held (TP-CLI-13) |
| L-ORIGIN-01 | dest notes name nginx-cli; A frozen |
| L-PUSH-VAULT-01 | apply at commit/push |
| L-SETU-01 | still held (TP-CLI-11) |
| L-STOR-01 | still held (TP-CLI-12) |

## Issues

None open from this pass.

### Closed this pass (were plan gaps)

| ID | Severity | Description | Test | Status |
|----|----------|-------------|------|--------|
| NGX-PLAN-01 | suggestion | Privilege peers not in test-plan / what-to-review TTY+F6 gates | TP-CLI-14, TP-NGX-14..15 | closed |
| NGX-PLAN-02 | suggestion | No automated lock against sudoer-cli F6/inbound copy | TP-NGX-15 | closed |

## Follow-up surface review (same day)

Closed dest-honesty findings: SECURITY 1.1.0 + dest sudoers posture; README snapshot/unlink + Stars `cloudgen/nginx-cli`; `docs/REPO_IDENTITY.md` dest remote (local docs layer). Push **must not** go to `cloudgen/cli-template`.

## Verdict

**Pass** for the privilege-split review plan. Live host `useradd` / visudo install remain **skip**.
