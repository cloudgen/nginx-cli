# Review reports index — nginx-cli

| Date | Report | Scope | Verdict | Suite |
|------|--------|-------|---------|-------|
| 2026-08-13 | Bootstrap origin wording (historical hop-0 claim) | living | living | see `tests/run.sh` |
| 2026-08-15 | `docs/reviews/2026-08-15-requirement-review.md` | registry-only | Approve with follow-ups (RR-01..07) | see `tests/run.sh` |
| 2026-08-15 | RR-01..07 dest retarget | notes/ACs/README | Fixed — this product is B; A frozen | — |
| 2026-08-15 | `reviews/reports/2026-08-15-privilege-split.md` | privilege split + plan | Pass — TP-CLI-14, TP-NGX-14..15 | PASS=127 |
| 2026-08-15 | dest surface (SECURITY / README / remotes) | identity | Fixed — do not push dest onto cli-template | PASS=127 |
| 2026-08-15 | `reviews/reports/2026-08-15-json-dest-submitter-revision.md` | JSON dest + submitter revision | Fixed NGX-SEC-01..03, NGX-DOC-01, NGX-TEST-01 | see `tests/run.sh` |
| 2026-08-22 | `reviews/reports/2026-08-22-fence-test-coverage.md` | dest Fence + `fence-test` coverage | Sufficient with Gaps closed (TP-NGX-44..49 · TP-CLI-16) | see `tests/run.sh` |
| 2026-08-23 | `reviews/cli-routed-verb-table.md` | live command list + human-readable labels | full scan (26 live; `menu`/`main` implemented) | see `tests/run.sh` |
| 2026-08-23 | `reviews/reports/2026-08-23-sibling-setup-dns-cli-sudoer-cli.md` | Type 1 `setup` vs dns-cli + sudoer-cli | Pass (2026-08-25) — L-COLLIDE-01 closed; do not copy 3773 / NOPASSWD whole CLI / `sudo -n` hook | see `tests/run.sh` |
| 2026-08-25 | `reviews/reports/2026-08-25-requirement-review.md` | registry requirement review + collision / menu close | Approve with follow-ups — 19 REQs; TP-NGX-51 have; §1.1 residual on older REQs | see `tests/run.sh` |

Related products **selfmanaged** and **folder-backup** keep their own reviews. They are **not** this product’s law, origin, or evidence. Origin A **cli-template** is a frozen reference at `src/cli-template`.
