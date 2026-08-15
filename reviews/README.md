# Reviews — nginx-cli

Public product review surface (peer of `tests/`).

| File | Role |
|------|------|
| `what-to-review.md` | Living review plan / checklist |
| `test-plan.md` | TP-* status map |
| `requirement-test-matrix.md` | Requirement → TP families |
| `lessons.md` | Durable failure modes to re-check |
| `index.md` | Report index |
| `reports/` | Dated review run reports |

**Ship unit:** `src/nginx-cli` (**VERSION 1.4.0**)  
**Origin A (frozen):** `src/cli-template` — do not reverse-copy  
**Suite:** `./tests/run.sh`  
**Last suite baseline:** see `test-plan.md`

**Review focus:** Type 0 local lifecycle plus nginx-adm file-based JSON dest **and** same-product submitter (`request`) plus Type 0 `submit-sudoer-request`. Dest inbound is dest request JSON. No backup/restore/print-sudoers surface.
