# OSS File Reading Order

Reading paths through large open-source codebases. Simplest files first, hardest last.

Each repository has two things: a **complete listing** of every file it contains, ordered by
size, and a **short curated path** through the files that actually teach the architecture.

| Repository | Every file | Curated path | Files |
|---|---|---|---|
| github.com/llvm/llvm-project | [llvm/](llvm/README.md) | [llvm-reading-order.md](llvm-reading-order.md) | 188,312 |
| github.com/ClickHouse/ClickHouse | [clickhouse/](clickhouse/README.md) | [clickhouse-reading-order.md](clickhouse-reading-order.md) | 85,436 |

The same idea for the kernel lives in [`../linux-kernel/02-reading-order.md`](../linux-kernel/02-reading-order.md),
which is the format the curated paths follow.

## The complete listings

Every file in the repository, ranked by line count, split into tiers:

```
tier 0   1-20 lines        trivial
tier 1   21-50             very small
tier 2   51-100            small
tier 3   101-250           moderate
tier 4   251-500           substantial
tier 5   501-1000          large
tier 6   1001-2500         very large
tier 7   2501-5000         heavy
tier 8   5001-10000        very heavy
tier 9   10001 and up      hardest
```

Entry numbers run continuously across all tiers of a repository, so entry 1 is the smallest
file in the repo and the last entry is the largest. Binary files have no lines to count and
are listed separately, ordered by byte size.

Tiers are split into parts of 5,000 entries so that GitHub renders them. 66 parts in total.

## Two ways to use this

**You have an afternoon and want to understand the architecture.** Use the curated path. It
is ~60 files chosen because each one teaches what the next needs.

**You want to find something the right size to work on.** Use the complete listing. Open the
tier that matches the time you have and scan for a path in an area you care about.

## How these were built

Line counts come from `git grep -I -c ''` against the upstream default branch, so they
reflect the real repository, not a local checkout:

```
llvm-project   upstream/main     471f4bfee055   2026-10-23
ClickHouse     upstream/master   205bdad540d    2026-10-23
```

Line count is a measured proxy for effort, not for difficulty. Generated test data lands at
the "hardest" end while being unreadable rather than hard, and a 44-line file can carry the
idea everything else rests on. Each repository index says more about this.

## Regenerating

The counts go stale as the repositories move. To refresh, fetch the upstream ref and re-run
the line count; paths that stop resolving were moved, and `git log --follow -- <path>` finds
where they went.
