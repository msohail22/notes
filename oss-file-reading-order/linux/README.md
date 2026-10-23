# Linux — Every Source File, Simplest to Hardest

Every file you would actually read in `github.com/torvalds/linux`, ordered by line count.

| | Files |
|---|---|
| Text files in the repository | 96,559 |
| Excluded: data or generated file extension | −13,861 |
| Excluded: test, benchmark or vendored directory | −9,518 |
| Excluded: content is a data table ([list](excluded-data-tables.md)) | −873 |
| Excluded: documentation translation | −617 |
| Excluded: header says the file is generated | −588 |
| Excluded: file name says generated | −4 |
| **Listed here** | **71,098** |

Ref `origin/master`, 2026-10-23. For a short curated path instead, see [../linux-kernel/02-reading-order.md](../linux-kernel/02-reading-order.md).

## What the order means

Files are ranked by line count, a measured proxy for effort rather than for
difficulty. A short file can still be the hard one. Use the tiers to pick something
the right size for the time you have, then judge the file yourself.

| Part | Tier | Lines | Files | Range |
|---|---|---|---|---|
| [tier-00-part-01.md](tier-00-part-01.md) | 0 — trivial | 1-20 | 5,000 | 1-13 |
| [tier-00-part-02.md](tier-00-part-02.md) | 0 — trivial | 1-20 | 3,590 | 13-20 |
| [tier-01-part-01.md](tier-01-part-01.md) | 1 — very small | 21-50 | 5,000 | 21-34 |
| [tier-01-part-02.md](tier-01-part-02.md) | 1 — very small | 21-50 | 4,790 | 34-50 |
| [tier-02-part-01.md](tier-02-part-01.md) | 2 — small | 51-100 | 5,000 | 51-73 |
| [tier-02-part-02.md](tier-02-part-02.md) | 2 — small | 51-100 | 4,873 | 73-100 |
| [tier-03-part-01.md](tier-03-part-01.md) | 3 — moderate | 101-250 | 5,000 | 101-139 |
| [tier-03-part-02.md](tier-03-part-02.md) | 3 — moderate | 101-250 | 5,000 | 139-187 |
| [tier-03-part-03.md](tier-03-part-03.md) | 3 — moderate | 101-250 | 5,000 | 187-250 |
| [tier-03-part-04.md](tier-03-part-04.md) | 3 — moderate | 101-250 | 40 | 250-250 |
| [tier-04-part-01.md](tier-04-part-01.md) | 4 — substantial | 251-500 | 5,000 | 251-335 |
| [tier-04-part-02.md](tier-04-part-02.md) | 4 — substantial | 251-500 | 5,000 | 335-455 |
| [tier-04-part-03.md](tier-04-part-03.md) | 4 — substantial | 251-500 | 1,419 | 455-500 |
| [tier-05-part-01.md](tier-05-part-01.md) | 5 — large | 501-1000 | 5,000 | 501-735 |
| [tier-05-part-02.md](tier-05-part-02.md) | 5 — large | 501-1000 | 3,338 | 735-1000 |
| [tier-06-part-01.md](tier-06-part-01.md) | 6 — very large | 1001-2500 | 5,000 | 1001-1958 |
| [tier-06-part-02.md](tier-06-part-02.md) | 6 — very large | 1001-2500 | 1,096 | 1958-2500 |
| [tier-07-part-01.md](tier-07-part-01.md) | 7 — heavy | 2501-5000 | 1,500 | 2501-4998 |
| [tier-08-part-01.md](tier-08-part-01.md) | 8 — very heavy | 5001-10000 | 376 | 5006-9956 |
| [tier-09-part-01.md](tier-09-part-01.md) | 9 — hardest | 10001-and up | 76 | 10010-30386 |
