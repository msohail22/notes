# ClickHouse — Every File, Simplest to Hardest

All 85,436 files in `github.com/ClickHouse/ClickHouse`, ordered by line count.

- 79,725 text files, listed below across 23 parts
- 5,711 binary files, in [binary-files.md](binary-files.md)
- Ref: `upstream/master` as of 2026-10-23

For a short path through the important files instead, see [../clickhouse-reading-order.md](../clickhouse-reading-order.md).

## What the order means, and what it does not

Files are ranked by line count. That is a measured proxy for effort, not for difficulty.
Two things it gets wrong, and you should expect both:

- **Generated data ranks as "hardest".** The last entries here are test inputs and model
  data, not code. `libc/test/src/math/exhaustive/sin.wc` is a million lines of numbers.
  Skip them.
- **A short file can be the hard one.** `llvm/lib/IR/Use.cpp` is 44 lines and encodes the
  def-use edge the whole IR rests on.

Use the tiers to pick something the right size for the time you have, then judge the file
yourself. For a path that is curated rather than measured, use the short reading order
linked above.

| Part | Tier | Lines | Files | Range |
|---|---|---|---|---|
| [tier-00-part-01.md](tier-00-part-01.md) | 0 — trivial | 1-20 | 5,000 | 1-3 |
| [tier-00-part-02.md](tier-00-part-02.md) | 0 — trivial | 1-20 | 5,000 | 3-6 |
| [tier-00-part-03.md](tier-00-part-03.md) | 0 — trivial | 1-20 | 5,000 | 6-10 |
| [tier-00-part-04.md](tier-00-part-04.md) | 0 — trivial | 1-20 | 5,000 | 10-16 |
| [tier-00-part-05.md](tier-00-part-05.md) | 0 — trivial | 1-20 | 3,565 | 16-20 |
| [tier-01-part-01.md](tier-01-part-01.md) | 1 — very small | 21-50 | 5,000 | 21-28 |
| [tier-01-part-02.md](tier-01-part-02.md) | 1 — very small | 21-50 | 5,000 | 28-35 |
| [tier-01-part-03.md](tier-01-part-03.md) | 1 — very small | 21-50 | 5,000 | 35-43 |
| [tier-01-part-04.md](tier-01-part-04.md) | 1 — very small | 21-50 | 3,936 | 43-50 |
| [tier-02-part-01.md](tier-02-part-01.md) | 2 — small | 51-100 | 5,000 | 51-61 |
| [tier-02-part-02.md](tier-02-part-02.md) | 2 — small | 51-100 | 5,000 | 61-76 |
| [tier-02-part-03.md](tier-02-part-03.md) | 2 — small | 51-100 | 5,000 | 76-97 |
| [tier-02-part-04.md](tier-02-part-04.md) | 2 — small | 51-100 | 804 | 97-100 |
| [tier-03-part-01.md](tier-03-part-01.md) | 3 — moderate | 101-250 | 5,000 | 101-134 |
| [tier-03-part-02.md](tier-03-part-02.md) | 3 — moderate | 101-250 | 5,000 | 134-198 |
| [tier-03-part-03.md](tier-03-part-03.md) | 3 — moderate | 101-250 | 2,459 | 198-250 |
| [tier-04-part-01.md](tier-04-part-01.md) | 4 — substantial | 251-500 | 5,000 | 251-474 |
| [tier-04-part-02.md](tier-04-part-02.md) | 4 — substantial | 251-500 | 299 | 475-500 |
| [tier-05-part-01.md](tier-05-part-01.md) | 5 — large | 501-1000 | 2,217 | 501-1000 |
| [tier-06-part-01.md](tier-06-part-01.md) | 6 — very large | 1001-2500 | 1,096 | 1001-2498 |
| [tier-07-part-01.md](tier-07-part-01.md) | 7 — heavy | 2501-5000 | 234 | 2502-5000 |
| [tier-08-part-01.md](tier-08-part-01.md) | 8 — very heavy | 5001-10000 | 91 | 5019-9806 |
| [tier-09-part-01.md](tier-09-part-01.md) | 9 — hardest | 10001-and up | 24 | 10371-174005 |
