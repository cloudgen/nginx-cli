**file**: docs/requirements/requirement-incorrect-json-format.md  
**Status**: Active (Version 1.0.0)  
**Area**: architecture  
**Key**: `requirement-incorrect-json-format`  
**id**: RQ-INCORRECT-JSON-FORMAT  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **independent dest Fence** for **incorrect JSON format** on the nginx-cli dest. Dest `approve` / `reject` / login `approve` **MUST** fail closed when the waiting file is not dest-legal JSON, explain that in ordinary words, and **MUST NOT** ask yes or no for that file.

The dest fence **table** stays on `requirement-domain-nginx-cli` and **points** here. This file owns **what matches**. It is not who dest-approves.

Dest closed schema is dest-owned. An unknown key is a key **not** on that allowlist. Type 0 `submit_app` / `submit_version` are dest-owned on emit. Missing or non-string on add/update **is** this Fence. Dest **MUST NOT** fence because those values ≠ dest `APP_NAME` / dest `VERSION`.

### 1.1 Human-facing

**In one sentence:** If the waiting file is not dest-legal JSON, dest **explains** that and does **not** ask yes or no.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Dropped a JSON dest does not list | unknown key; missing `purpose` |
| Dest | Refuses without a yes/no | `nginx-cli approve` |
| Not this file | Who dest-approves, or the dest refuse **list** | `requirement-domain-nginx-cli` actor table |

| Includes | Excludes |
|----------|----------|
| Parse / dest-owned schema / basename action mismatch | Unix file owner of the waiting file |
| Type 0 `submit_app` / `submit_version` as dest-known strings | Dest fence because the submitting CLI is a sibling or an older version |
| Missing required field | Asking yes/no on a fenced file |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/var/nginx-cli/config-request` | Waiting dest JSON | Dest reviews these |
| `nginx-cli approve` | Dest review | Fence first |
| `nginx-cli test-json-format --file PATH` | Per-row tester | No dest elev; does not queue |
| `nginx-cli fence-test --file PATH` | List tester | Closed dest Fence list |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Leave `purpose` out | Dest refuses; no yes/no | `nginx-cli request example.com ./site.json` |
| Test a dest JSON | Check the file against this Fence without becoming nginx-adm and without putting it in the waiting folder | `nginx-cli test-json-format --file ./20260821-alice-example.com-1.json` |
| Stamp `submit_app` as another product | Dest format **MUST** accept it | (sibling submitter) |

---

## 2. Core Rules / Requirements (Mandatory)

**IJF-M1.** Dest inbound **Fence** is **incorrect JSON format**. Dest **MUST** fail closed when any of these hold:

| Fail | Why it is format |
|------|------------------|
| Missing, symlink, or not a regular file | Not a request artifact |
| Not one parseable JSON object | Not JSON format |
| `schema_version` ≠ `1` on add/update | Closed schema |
| Unknown key — key **not** on the dest-owned allowlist | Closed schema |
| Missing required field for that action | Closed schema |
| Field type / enum invalid | Closed schema |
| Basename not `yyyyMMdd-user-domain-n.json` | Artifact name is part of the request |
| Basename **domain** / **user** ≠ JSON `domain` / `username` when those JSON fields are present | Labels are part of the request |

**IJF-M2.** Dest **MUST NOT** treat these as this Fence: Unix file-ownership; who submitted; dest Type 0 self-scope; JSON `username` ≠ `nginx-adm`; `submit_app` ≠ dest `APP_NAME`; `submit_version` ≠ dest `VERSION`.

**IJF-M3.** When this Fence matches on dest **interactive** `approve` (no basename): dest **MUST** display a people/folder sentence (what happened / next). Dest **MUST NOT** ask yes or no for that file. Dest **MUST** then snapshot + archive into rejected + unlink inbound. Dest **MUST NOT** publish. Dest **MUST NOT** `chown` the request to nginx-adm. Standalone `approve` / `reject` with a basename **MUST** fail closed with the same sentence; that file **stays inbound**.

**IJF-M4.** User SSOT remains JSON `username`. Dest **MUST NOT** take the user from the filename as the only check when JSON has `username`.

**IJF-M5.** Type 0 `request` / `conf-to-json` **MUST NOT** plant a dest-written owner stamp. Dest **MUST NOT** dest-write `submit_app` / `submit_version`. Type 0 add/update **MUST** overwrite those two keys from live Config `APP_NAME` / `VERSION`.

**IJF-M6.** Dest **MUST NOT** add another dest inbound Fence unless the dest table on `requirement-domain-nginx-cli` is confirmed with a new **Fence** row and a new independent requirement.

**IJF-M7. Dest-owned allowlist (this dest).** Submitter-emitted keys dest **MUST** treat as known: `schema_version`, `purpose`, `username`, `service`, `action`, `kind`, `domain`, `site`, `submit_app`, `submit_version`. Required on add/update emit: all of those except `site` shape owned in domain law. `submit_app` / `submit_version` **MUST** be non-empty strings. Dest **MUST NOT** fence if their values ≠ dest identity. Remove: `purpose` required; `site` forbidden; other allowlisted keys optional and **MUST** be strings / valid enums when present.

**IJF-M8. Type 0 per-row tester.** Dest **MUST** ship Type 0 **test-purpose** `test-json-format` (stdin **xor** `--file PATH`; a positional path **MAY** stand in for `--file`). Dest `approve` / `reject` **MUST NOT** count as that verb. The tester **MUST NOT** require `sudo`, a sudoers fragment, or the waiting folder. Basename grammar applies **only** when the input basename already matches request-id grammar.

```sh
nginx-cli test-json-format --file ./20260821-alice-example.com-1.json
```

**IJF-M9. Closed-list tester.** The dest Fence **list** tester is Type 0 **test-purpose** `fence-test` (`stdin` xor `--file PATH` xor `--dir DIR`). Dual mention: `requirement-shell-cli-interface` **and** `requirement-domain-nginx-cli`. This file owns the per-row tester. **MUST NOT** treat dest review as either tester.

```sh
nginx-cli fence-test --file tests/fixtures/fence-test/pass/20260821-alice-example.com-1.json
```

### 2.1 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `nginx-cli` |
| **Dest verbs** | `approve` / `reject` |
| **Per-row tester** | `test-json-format` — `ngx_test_json_format` |
| **List tester** | `fence-test` — `ngx_fence_test` |
| **Helper** | `ngx_dest_json_fence` |
| **Dest table** | `requirement-domain-nginx-cli` §2.0 dest fence table |
| **Inbound owner** | stays the submitter (prevention PREV-CHOWN-REQ) |
| **Proof** | **TP-NGX-35..49** · **TP-CLI-15..16** |

### 2.2 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: One dest refuse reason has one file.  
- **CIAO Principle 5 – SSOT**: Dest table indexes; this file owns the meaning.  
- **CIAO Principle 1 – Caution**: Fail closed on a broken waiting file.  
- **CIAO Principle 21 – Dual policies**: Portable fence class; filled dest allowlist.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Broken inbound is not offered for yes or no.  
- **Intentional**: Format is this dest Fence; owner and sibling app/version are not.  
- **Anti-fragile**: Testers do not need dest elev or the waiting folder.  
- **Over-protect**: Protection Rule forbids extra dest Fences and dest-unknown submitter keys.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Ask yes/no on a file this Fence matches.  
2. Treat Unix owner, who submitted, or sibling `submit_app` / `submit_version` as this Fence.  
3. Dest-write `submit_app` / `submit_version`, or leave Type 0 add/update without those strings.  
4. Queue dest inbound JSON with keys dest does not list.  
5. Add a dest inbound Fence that dest tables do not name.  
6. Count dest `approve` / `reject` as `test-json-format` or `fence-test`.  
7. Require `sudo`, a sudoers fragment, or the waiting folder to run testers.  
8. `chown` inbound JSON to nginx-adm as part of this Fence.

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-class-software-dev.md` | Class MUST review dest Fences |
| `docs/requirements/requirement-domain-nginx-cli.md` | Dest table + dest JSON schema |
| `docs/requirements/requirement-shell-cli-interface.md` | Dual mention of testers |
| `docs/requirements/requirement-sudoer-json-file.md` | Compose sudoer JSON stamps |
| `src/nginx-cli` | `ngx_dest_json_fence` |

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-NGX-35** | `tests/test_domain.sh` | have |
| **TP-NGX-36** | `tests/test_domain.sh` | have |
| **TP-NGX-37** | `tests/test_domain.sh` | have |
| **TP-NGX-38** | `tests/test_domain.sh` | have |
| **TP-NGX-39** | `tests/test_domain.sh` | have |
| **TP-NGX-40** | `tests/test_domain.sh` | have |
| **TP-NGX-41** | `tests/test_domain.sh` | have |
| **TP-NGX-42** | `tests/test_domain.sh` | have |
| **TP-NGX-43** | `tests/test_domain.sh` | have |
| **TP-NGX-44** | `tests/test_domain.sh` | have |
| **TP-NGX-45** | `tests/test_domain.sh` | have |
| **TP-NGX-46** | `tests/test_domain.sh` | have |
| **TP-NGX-47** | `tests/test_domain.sh` | have |
| **TP-NGX-48** | `tests/test_domain.sh` | have |
| **TP-NGX-49** | `tests/test_domain.sh` | have |
| **TP-CLI-15** | `tests/test_cli.sh` | have |
| **TP-CLI-16** | `tests/test_cli.sh` | have |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-21 | Active 1.0.0 | Independent dest Fence; Type 0 `test-json-format` / `fence-test`; dest-owned `submit_app` / `submit_version` |
| 2026-08-22 | Active 1.0.0 | Proof TP-NGX-44..49 (xor, expect-match, JSON, no-queue, stdin) · TP-CLI-16 |

**Last Updated**: 2026-08-22  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
