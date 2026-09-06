# Report: README human-readability + requirements / checklist / test coverage — nginx-cli 1.8.1

**Date:** 2026-09-06
**Mode:** review + authorized implement/fix
**Status:** follow-ups closed except Termux detect (honest Gap). Hyphenated-login fence bug closed (1.8.1).

## Summary

Product README Description led with Type 0 / Type 1 catalog speech. Several registered requirements lacked **§1.1 Human-facing**. Related shell REQs lacked a section **literally titled** **Under command line for normal user only**. Review maps still said empty argv stays help and VERSION **1.7.0** after ship unit **1.8.0** made TTY empty argv the numbered list. Suite already had **TP-CLI-23..25**; maps did not.

Fixes this turn: README voice pack; §1.1 on all **19** registered REQs; Under-command-line section on related shell/privilege/domain files; maps and DTV aligned to 1.8.0; filled checklists; this report.

## Requirement sufficient check

### Claim
- ID: C-full-product
- Text: Full specialized product including domain surface and claimed numbered list

### SSOT preflight
- Identity: aligned (`APP_NAME=nginx-cli`, VERSION **1.8.1**, Stars `cloudgen/nginx-cli`, empty `SCRIPT_URL`)
- Notes: class/interface/bootstrap residual version strings were stale **1.7.0** — retargeted this turn

### Registered law
- Registry rows: 19
- Files: match registry (no orphans, no ghosts)
- Domain requirements present: yes (`requirement-domain-nginx-cli`)

### Verdict
- **Sufficient with Gaps**
- One-line rationale: domain + lifecycle + dest Fence + numbered list are owned; Termux/Git Bash/Windows-cmd **detect** is law without a ship-unit probe (setup on that class still fails at `useradd`, not a dedicated message).

### Recommendations
- P0: closed this turn (README voice; §1.1; empty-argv honesty; TP-CLI-23..25 mapped)
- P1: optional ship-unit detect + operator-readable refuse for `setup` / `remove-lpu` on Termux/Git Bash/Windows cmd
- P2: none

## Issues

### Issue 1 -- Severity: bug
- File: README.md:8
- Description: Description and Features led with Type 0 / Type 1 / LPU / Family as the only words.
- Suggestion: Voice pack (who / folder / next command). Applied.
- Lesson: L-HUMAN-01
- Test: N/A (docs)
- Status: closed

### Issue 2 -- Severity: bug
- File: docs/requirements/requirement-shell-cli-default-interaction.md:12
- Description: §1.1 still said empty argv is help after 1.8.0 TTY list shipped.
- Suggestion: Align Human-facing, Implementation Notes, DTV with zero-arguments TTY split. Applied.
- Lesson: L-MAP-STALE-01
- Test: TP-CLI-25
- Status: closed

### Issue 3 -- Severity: bug
- File: reviews/test-plan.md:1
- Description: Maps at VERSION 1.7.0; TP-CLI-23..25 existed in suite, missing from plan.
- Suggestion: Record have rows; RTM + what-to-review + tests README. Applied.
- Lesson: L-MAP-STALE-01
- Test: TP-CLI-23, TP-CLI-24, TP-CLI-25
- Status: closed

### Issue 4 -- Severity: suggestion
- File: docs/requirements/requirement-class-software-dev.md:13
- Description: Only 6 of 19 REQs had §1.1 Human-facing; none had **Under command line for normal user only**.
- Suggestion: Add both. Applied (§1.1 all 19; Under-command-line on 14 related files). Output-only REQ skipped for that section (N/A).
- Lesson: L-HUMAN-01
- Test: N/A
- Status: closed

### Issue 5 -- Severity: suggestion
- File: src/nginx-cli
- Description: Ship unit does not detect Termux / Git Bash / Windows cmd. Law now says Type 1 unused on that class.
- Suggestion: Optional fail-closed `setup` / `remove-lpu` with Next: use a Linux host with root. Not implemented this turn.
- Lesson: L-HUMAN-01
- Test: todo (optional)
- Status: open

### Issue 6 -- Severity: bug
- File: src/nginx-cli:2562
- Description: Dest fence compared JSON `username` (`id -un`) to path-safe basename user. Login `sh-cli-template` failed submit.
- Suggestion: Compare via path-safe encoding. Applied in 1.8.1.
- Lesson: L-HYPHEN-USER-01
- Test: TP-NGX-54
- Status: closed

## Checklist
- Plan-and-requirements: `docs/checklists/2026-09-06-plan-and-requirements-human-readability.md`
- CLI default interaction: `docs/checklists/2026-09-06-checklist-cli-default-interaction-tty-empty-argv.md`
- Implementation CIAO: `docs/checklists/2026-09-06-implementation-ciao-human-readability.md`
