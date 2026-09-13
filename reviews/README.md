# Reviews — nginx-cli

Public product review surface (peer of `tests/`).

| File | Role |
|------|------|
| `what-to-review.md` | Living review plan / checklist |
| `test-plan.md` | TP-* status map |
| `requirement-test-matrix.md` | Requirement → TP families |
| `cli-routed-verb-table.md` | Live command list (verb / handler / privilege / date / `command: what it does`) |
| `lessons.md` | Durable failure modes to re-check |
| `index.md` | Report index |
| `reports/` | Dated review run reports |

**Ship unit:** `src/nginx-cli` (**VERSION 1.10.1**)  
**Origin A (frozen):** `src/cli-template` — do not reverse-copy  
**Suite:** `./tests/run.sh`  
**Last suite baseline:** see `test-plan.md`

**Review focus:** Local lifecycle plus nginx-adm file-based JSON dest **and** same-product submitter (`request`) plus `submit-sudoer-request` plus testers `fence-test` / `test-json-format` plus numbered list (`menu` / `main` and TTY empty argv). Dest inbound is dest request JSON. No backup/restore/print-sudoers surface. Off-TTY empty argv stays help.
