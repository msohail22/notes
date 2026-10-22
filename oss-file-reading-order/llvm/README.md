# LLVM — Every File, Simplest to Hardest

All 188,312 files in `github.com/llvm/llvm-project`, ordered by line count.

- 183,405 text files, listed below across 43 parts
- 4,907 binary files, in [binary-files.md](binary-files.md)
- Ref: `upstream/main` as of 2026-10-23

For a short path through the important files instead, see [../llvm-reading-order.md](../llvm-reading-order.md).

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
| [tier-00-part-01.md](tier-00-part-01.md) | 0 — trivial | 1-20 | 5,000 | 1-4 |
| [tier-00-part-02.md](tier-00-part-02.md) | 0 — trivial | 1-20 | 5,000 | 4-7 |
| [tier-00-part-03.md](tier-00-part-03.md) | 0 — trivial | 1-20 | 5,000 | 7-10 |
| [tier-00-part-04.md](tier-00-part-04.md) | 0 — trivial | 1-20 | 5,000 | 10-13 |
| [tier-00-part-05.md](tier-00-part-05.md) | 0 — trivial | 1-20 | 5,000 | 13-15 |
| [tier-00-part-06.md](tier-00-part-06.md) | 0 — trivial | 1-20 | 5,000 | 15-18 |
| [tier-00-part-07.md](tier-00-part-07.md) | 0 — trivial | 1-20 | 5,000 | 18-20 |
| [tier-00-part-08.md](tier-00-part-08.md) | 0 — trivial | 1-20 | 1,538 | 20-20 |
| [tier-01-part-01.md](tier-01-part-01.md) | 1 — very small | 21-50 | 5,000 | 21-23 |
| [tier-01-part-02.md](tier-01-part-02.md) | 1 — very small | 21-50 | 5,000 | 23-25 |
| [tier-01-part-03.md](tier-01-part-03.md) | 1 — very small | 21-50 | 5,000 | 25-28 |
| [tier-01-part-04.md](tier-01-part-04.md) | 1 — very small | 21-50 | 5,000 | 28-30 |
| [tier-01-part-05.md](tier-01-part-05.md) | 1 — very small | 21-50 | 5,000 | 30-33 |
| [tier-01-part-06.md](tier-01-part-06.md) | 1 — very small | 21-50 | 5,000 | 33-36 |
| [tier-01-part-07.md](tier-01-part-07.md) | 1 — very small | 21-50 | 5,000 | 36-39 |
| [tier-01-part-08.md](tier-01-part-08.md) | 1 — very small | 21-50 | 5,000 | 39-43 |
| [tier-01-part-09.md](tier-01-part-09.md) | 1 — very small | 21-50 | 5,000 | 43-47 |
| [tier-01-part-10.md](tier-01-part-10.md) | 1 — very small | 21-50 | 3,748 | 47-50 |
| [tier-02-part-01.md](tier-02-part-01.md) | 2 — small | 51-100 | 5,000 | 51-55 |
| [tier-02-part-02.md](tier-02-part-02.md) | 2 — small | 51-100 | 5,000 | 55-61 |
| [tier-02-part-03.md](tier-02-part-03.md) | 2 — small | 51-100 | 5,000 | 61-66 |
| [tier-02-part-04.md](tier-02-part-04.md) | 2 — small | 51-100 | 5,000 | 66-73 |
| [tier-02-part-05.md](tier-02-part-05.md) | 2 — small | 51-100 | 5,000 | 73-80 |
| [tier-02-part-06.md](tier-02-part-06.md) | 2 — small | 51-100 | 5,000 | 80-89 |
| [tier-02-part-07.md](tier-02-part-07.md) | 2 — small | 51-100 | 5,000 | 89-99 |
| [tier-02-part-08.md](tier-02-part-08.md) | 2 — small | 51-100 | 819 | 99-100 |
| [tier-03-part-01.md](tier-03-part-01.md) | 3 — moderate | 101-250 | 5,000 | 101-112 |
| [tier-03-part-02.md](tier-03-part-02.md) | 3 — moderate | 101-250 | 5,000 | 112-127 |
| [tier-03-part-03.md](tier-03-part-03.md) | 3 — moderate | 101-250 | 5,000 | 127-144 |
| [tier-03-part-04.md](tier-03-part-04.md) | 3 — moderate | 101-250 | 5,000 | 144-167 |
| [tier-03-part-05.md](tier-03-part-05.md) | 3 — moderate | 101-250 | 5,000 | 167-196 |
| [tier-03-part-06.md](tier-03-part-06.md) | 3 — moderate | 101-250 | 5,000 | 196-234 |
| [tier-03-part-07.md](tier-03-part-07.md) | 3 — moderate | 101-250 | 1,902 | 234-250 |
| [tier-04-part-01.md](tier-04-part-01.md) | 4 — substantial | 251-500 | 5,000 | 251-310 |
| [tier-04-part-02.md](tier-04-part-02.md) | 4 — substantial | 251-500 | 5,000 | 310-395 |
| [tier-04-part-03.md](tier-04-part-03.md) | 4 — substantial | 251-500 | 4,020 | 395-500 |
| [tier-05-part-01.md](tier-05-part-01.md) | 5 — large | 501-1000 | 5,000 | 501-729 |
| [tier-05-part-02.md](tier-05-part-02.md) | 5 — large | 501-1000 | 3,230 | 729-1000 |
| [tier-06-part-01.md](tier-06-part-01.md) | 6 — very large | 1001-2500 | 5,000 | 1001-2249 |
| [tier-06-part-02.md](tier-06-part-02.md) | 6 — very large | 1001-2500 | 433 | 2250-2500 |
| [tier-07-part-01.md](tier-07-part-01.md) | 7 — heavy | 2501-5000 | 1,651 | 2501-5000 |
| [tier-08-part-01.md](tier-08-part-01.md) | 8 — very heavy | 5001-10000 | 654 | 5002-9945 |
| [tier-09-part-01.md](tier-09-part-01.md) | 9 — hardest | 10001-and up | 410 | 10015-1091085 |
