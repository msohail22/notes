# ClickHouse — Every Source File, Simplest to Hardest

Every file you would actually read in `github.com/ClickHouse/ClickHouse`, ordered by line count.

| | Files |
|---|---|
| Text files in the repository | 79,725 |
| Excluded: test, benchmark or vendored directory | −42,127 |
| Excluded: documentation translation | −21,755 |
| Excluded: header says the file is generated | −1,333 |
| Excluded: data or generated file extension | −514 |
| Excluded: file name says generated | −3 |
| Excluded: content is a data table ([list](excluded-data-tables.md)) | −1 |
| **Listed here** | **13,992** |

Ref `upstream/master`, 2026-10-23. For a short curated path instead, see [../clickhouse-reading-order.md](../clickhouse-reading-order.md).

## What the order means

Files are ranked by line count, a measured proxy for effort rather than for
difficulty. A short file can still be the hard one. Use the tiers to pick something
the right size for the time you have, then judge the file yourself.

| Part | Tier | Lines | Files | Range |
|---|---|---|---|---|
| [tier-00-part-01.md](tier-00-part-01.md) | 0 — trivial | 1-20 | 1,862 | 1-20 |
| [tier-01-part-01.md](tier-01-part-01.md) | 1 — very small | 21-50 | 3,149 | 21-50 |
| [tier-02-part-01.md](tier-02-part-01.md) | 2 — small | 51-100 | 2,755 | 51-100 |
| [tier-03-part-01.md](tier-03-part-01.md) | 3 — moderate | 101-250 | 3,182 | 101-250 |
| [tier-04-part-01.md](tier-04-part-01.md) | 4 — substantial | 251-500 | 1,639 | 251-500 |
| [tier-05-part-01.md](tier-05-part-01.md) | 5 — large | 501-1000 | 834 | 501-1000 |
| [tier-06-part-01.md](tier-06-part-01.md) | 6 — very large | 1001-2500 | 448 | 1001-2459 |
| [tier-07-part-01.md](tier-07-part-01.md) | 7 — heavy | 2501-5000 | 100 | 2516-5000 |
| [tier-08-part-01.md](tier-08-part-01.md) | 8 — very heavy | 5001-10000 | 18 | 5019-9469 |
| [tier-09-part-01.md](tier-09-part-01.md) | 9 — hardest | 10001-and up | 5 | 10371-22603 |
