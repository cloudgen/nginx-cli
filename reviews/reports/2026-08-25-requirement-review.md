# Report: requirement review — nginx-cli 1.7.0

**Date:** 2026-08-25  
**Mode:** registry-only requirement review + authorized fix (collision, menu README, suite)  
**Status:** Approve with follow-ups

## Summary

Software-development class gate passes: exactly one Active `requirement-class-software-dev.md`. Registry `docs/requirements/index.md` lists **19** keys; disk has **19** `requirement-*.md` files; no orphans and no ghosts. Bootstrap direction is A = `cli-template` (frozen) → B = nginx-cli. New law `requirement-shell-cli-default-interaction` (case 3 `menu`/`main`) is registered and implemented. Dest Fence + coding-style related REQ remain present.

Dominant close this turn: LPU Collision (`ngx_adm_collision_check`, TP-NGX-51). README now has a live TTY numbered-list capture after Quick Installation.

## Registry inventory + foreign/orphan gate (Step −1)

- Registered on disk (in-scope default): 19 (class, bootstrap, project-folder, 9 shell including default-interaction, LPU, three-layer, prevention, sudoer-json-file, dest Fence, domain)
- On disk, **not** in registry (orphans): none
- In registry, missing on disk (ghosts): none
- Foreign candidates: none (cli-template named only as origin A)
- Scope this turn: registry-only

## Bootstrap / rewrite gate (Step 0)

- Risk: yes — bootstrap origin A is frozen at `src/cli-template`
- Direction: bootstrap = cli-template → specialized = nginx-cli; shared architecture = yes
- Edits applied this turn: authorized review+fix (collision identity, README menu capture, TP-NGX-51, maps)
- Reverse-direction evidence: none

## ID notation compliance (Step 0-ID)

- Policy: policy-harness-id-notation — Pass for DTV `TP-*` on reviewed files
- RQ hygiene: `RQ-SHELL-CLI-DEFAULT-INTERACTION` / `RQ-LEAST-PRIVILEGE-USER` stem-matched
- Pollution / foreign RQ: none on versioned requirements (no `docs/skills/` / `docs/templates/` path dumps)

## Least privilege / LLM escape (Step 0-LP)

- Policy: policy-least-privilege — Pass after collision close
- Type map: Type 0 / Type 1 / gated domain present
- LPU review: Pass (F1–F7 declared; collision implemented)
- LPA review: Pass (subject nginx-conf; dest inbound is dest request JSON)
- CL-LEAST-PRIVILEGE / CL-LLM-ESCAPE recommended: N/A this cycle (no new Type 2)

## Issues

### Issue 1 -- Severity: bug
- File: src/nginx-cli:ngx_create_adm_user
- Description: Existing `nginx-adm` returned success without UID/GID/home check (L-COLLIDE-01).
- Suggestion: `ngx_adm_collision_check` before heal/create.
- Lesson: L-COLLIDE-01
- Test: TP-NGX-51
- Status: closed

### Issue 2 -- Severity: suggestion
- File: src/nginx-cli:ngx_find_host_bin
- Description: `useradd`/`groupadd` only via `command -v` (short root PATH).
- Suggestion: also try `/usr/sbin`.
- Status: closed

### Issue 3 -- Severity: nit
- File: src/nginx-cli:ngx_require_root
- Description: Live `[ -t 0 ]` retest instead of consuming `TTY`.
- Suggestion: consume main-process `TTY`.
- Status: closed

### Issue 4 -- Severity: suggestion
- File: docs/requirements/*.md
- Description: **§1.1 Human-facing** is present on class, dest Fence, coding-style, sudoer-json-file, default-interaction, and LPU (this turn). Remaining registered REQs still lack the voice pack.
- Suggestion: add §1.1 on next law edit of each file (do not bulk-rewrite bootstrap law this commit).
- Status: open (follow-up)

## Coverage gaps

- automatic-checksum: N/A (local-only)
- dest Fence: independent REQ + Type 0 `fence-test` present
- dest approval question: owned by domain (one-off yes/no)
- coding-style related REQ: present
- menu case 3: dual-mention on interface + topic-owner REQ
- collision identity: TP-NGX-51 have

## Checklist

- A (class/registry/bootstrap): Pass
- B (template/coverage): Pass with Issue 4 residual §1.1
- B2 ID notation: Pass
- B3 least privilege: Pass
- C dual policy / non-expose: Pass after scrubbing bootstrap-chain workspace (no session login / `/home/<login>`)
- D naming: Pass
- E defensive: Pass (incidents / L-COLLIDE-01 closed)
- F process: Pass (no unauthorized weakening)
- G git-surface: Pass (no harness path dumps in requirements)

## Verdict

Approve with follow-ups (Issue 4 §1.1 on remaining REQs). Collision Gap closed. Do not reverse-copy onto `src/cli-template`.
