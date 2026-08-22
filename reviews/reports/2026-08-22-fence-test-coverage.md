# Requirement sufficient check: dest Fence + fence-test coverage

**Date:** 2026-08-22  
**Reviewer:** council  
**Product:** nginx-cli `VERSION=1.5.1` (`src/nginx-cli`)  
**Skills:** `SK-REQUIREMENT-SUFFICIENT-CHECK` · `SK-ADD-TESTS`  
**Claim:** **C-feature** — Type 0 **test-purpose** `fence-test` (FC-M6) and dest Fence **incorrect JSON format**  
**Edits this turn:** tests TP-NGX-44..49 · TP-CLI-16; review maps; VERSION honesty 1.5.1

---

## Requirement sufficient check

### Claim
- ID: **C-feature**
- Text: Dest ships Type 0 **test-purpose** `fence-test` / `test-json-format` against a local test folder; dest Fence is incorrect JSON format only; testers do not queue or need sudo.

### SSOT preflight
- Identity: **aligned** (`APP_NAME=nginx-cli`, `REPO_USER=cloudgen`)
- Notes: Implementation notes VERSION drift vs ship unit **closed** this turn (1.5.1).

### Registered law
- Registry rows: **18** · Files: **18** · Domain present: **yes**
- Independent dest Fence REQ: **yes** (`requirement-incorrect-json-format` 1.0.0)
- `fence-test` dual mention: CLI-interface **and** domain SSOT **and** Fence REQ

### Live surfaces (summary)
- Lifecycle: install / uninstall / where-is-me / version / about / help
- Domain operational: setup, remove-lpu, request, list-*, approve, reject, map-*, enable-login-approval, submit-sudoer-request, conf-to-json, json-to-conf
- Test-purpose: `test-json-format`, `fence-test` (dispatcher + help **Unit test (local test folder)**)
- Help-only: none

### Ownership matrix

| Surface | Class | Owner | Status |
|---------|-------|-------|--------|
| Dest JSON fail-closed | dest Fence | `requirement-incorrect-json-format` | **ok** |
| Type 0 `fence-test` | test-purpose | CLI + domain + Fence REQ | **ok** |
| Type 0 `test-json-format` | test-purpose | Fence REQ (per-row) + dual mention | **ok** |
| Help tester heading apart | CLI | `app_help` | **ok** (TP-CLI-15) |
| xor `--file` / `--dir` | test-purpose | CLI flags + `ngx_fence_test` | **ok** (TP-NGX-44 this turn) |
| `--expect-match` only with `--dir` | test-purpose | CLI flags | **ok** (TP-NGX-45 this turn) |
| Testers do not queue | test-purpose | IJF-M8/M9 | **ok** (TP-NGX-47 this turn) |
| `submit_app` / `submit_version` dest-owned | dest stamp | IJF-M5/M7 | **ok** (TP-NGX-35 sibling stamp; TP-NGX-42/43) |
| Dest `approve` as tester | forbidden | IJF-M9 | **ok** (not routed as tester) |

### Artifact filename + content

| Kind | Filename grammar | Sample basename | Content structure | Sample body | Paired convert | Status |
|------|------------------|-----------------|-------------------|-------------|----------------|--------|
| Dest request JSON | yes | yes | yes (incl. stamps) | yes | yes | **ok** |
| fence-test corpus | pass/match folders | yes | n/a | yes | n/a | **ok** |

### TTY measurement (Step 3d)
- In scope: **N/A** (testers are file checks; stdin is data-source)

### Named workflow machine (Step 3e)
- In scope: **yes**
- Named machine + roles + submit-when + verify: **yes**
- Dest fencing conditions closed (incorrect JSON format only): **yes**
- Independent REQ per dest Fence: **yes**
- Type 0 `fence-test`: **yes**
- Named law tables printed: **yes**
- Human-intro on this claim’s REQs: **yes** (§1.1 on Fence REQ)

### TTY approver path (Step 3f)
- In scope: **N/A** for this C-feature

### LPU / LPA operator (Step 3g)
- In scope: **N/A** for this C-feature

### Dual mention (Step 3h)
- In scope: **yes**
- `fence-test` on CLI REQ + topic-owner: **yes**
- Invocation sample on topic-owner: **yes**
- Help not counted as second mention: **yes**

### Coding-style related REQ (Step 3i)
- In scope for software-dev: **yes** · File present: **yes** (`requirement-shell-script-coding`)

### Honesty / consistency
- 2026-08-21 C-feature verdict **Not sufficient** is **superseded**: 1.5.0 shipped testers + Fence REQ.
- Remaining suite Gaps vs portable **TP-FENCE-13/14** and sibling **TP-SR-FT-06/07** **closed** this turn.
- Nested `site` keys are allowlisted as dest-legal field names (P2, not a dest Fence hole).

### Verdict
- **Sufficient with Gaps** → after this turn’s tests: **Sufficient** for C-feature fence-test
- One-line rationale: dest Fence law, dual mention, dispatcher, help heading, corpus, and FC-M6 xor/stdin/no-queue/`Next` are now proven.

### Recommendations
- **P0:** none
- **P1:** none for this claim
- **P2:** tighten unknown-key scan so `listen`/`server_name` are dest-legal only under `site`; optional `not-object.json` match fixture

---

## What changed this turn

| Item | Action |
|------|--------|
| `tests/test_domain.sh` | TP-NGX-44..49 |
| `tests/test_cli.sh` | TP-CLI-16 |
| `reviews/test-plan.md` · RTM · what-to-review · lessons | maps + P17 + L-FENCE-TEST-01 |
| Ship unit header + CLI notes | VERSION 1.5.1 honesty |
| `CHANGELOG.md` / README badge | 1.5.1 |
