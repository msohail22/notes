# LLVM — Every Source File, Simplest to Hardest

Every file you would actually read in `github.com/llvm/llvm-project`, ordered by line count.

| | Files |
|---|---|
| Text files in the repository | 183,405 |
| Excluded: test, benchmark or vendored directory | −146,138 |
| Excluded: data or generated file extension | −1,135 |
| Excluded: header says the file is generated | −162 |
| Excluded: content is a data table ([list](excluded-data-tables.md)) | −12 |
| Excluded: file name says generated | −1 |
| **Listed here** | **35,957** |

Ref `upstream/main`, 2026-10-23. For a short curated path instead, see [../llvm-reading-order.md](../llvm-reading-order.md).

## What the order means

Files are ranked by line count, a measured proxy for effort rather than for
difficulty. A short file can still be the hard one. Use the tiers to pick something
the right size for the time you have, then judge the file yourself.

| Part | Tier | Lines | Files | Range |
|---|---|---|---|---|
| [tier-00-part-01.md](tier-00-part-01.md) | 0 — trivial | 1-20 | 4,997 | 1-20 |
| [tier-01-part-01.md](tier-01-part-01.md) | 1 — very small | 21-50 | 5,000 | 21-29 |
| [tier-01-part-02.md](tier-01-part-02.md) | 1 — very small | 21-50 | 5,000 | 29-48 |
| [tier-01-part-03.md](tier-01-part-03.md) | 1 — very small | 21-50 | 359 | 48-50 |
| [tier-02-part-01.md](tier-02-part-01.md) | 2 — small | 51-100 | 5,000 | 51-92 |
| [tier-02-part-02.md](tier-02-part-02.md) | 2 — small | 51-100 | 709 | 92-100 |
| [tier-03-part-01.md](tier-03-part-01.md) | 3 — moderate | 101-250 | 5,000 | 101-199 |
| [tier-03-part-02.md](tier-03-part-02.md) | 3 — moderate | 101-250 | 1,597 | 199-250 |
| [tier-04-part-01.md](tier-04-part-01.md) | 4 — substantial | 251-500 | 3,639 | 251-500 |
| [tier-05-part-01.md](tier-05-part-01.md) | 5 — large | 501-1000 | 2,339 | 501-1000 |
| [tier-06-part-01.md](tier-06-part-01.md) | 6 — very large | 1001-2500 | 1,602 | 1001-2500 |
| [tier-07-part-01.md](tier-07-part-01.md) | 7 — heavy | 2501-5000 | 466 | 2501-4995 |
| [tier-08-part-01.md](tier-08-part-01.md) | 8 — very heavy | 5001-10000 | 183 | 5002-9897 |
| [tier-09-part-01.md](tier-09-part-01.md) | 9 — hardest | 10001-and up | 66 | 10134-65834 |
