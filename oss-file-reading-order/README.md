# OSS File Reading Order

Reading paths through large open-source codebases. Simplest files first, hardest last.

Each repository has two things: a **complete listing** of every file it contains, ordered by
size, and a **short curated path** through the files that actually teach the architecture.

| Repository | Every source file | Curated path | In repo | Listed |
|---|---|---|---|---|
| github.com/llvm/llvm-project | [llvm/](llvm/README.md) | [llvm-reading-order.md](llvm-reading-order.md) | 188,312 | 35,957 |
| github.com/ClickHouse/ClickHouse | [clickhouse/](clickhouse/README.md) | [clickhouse-reading-order.md](clickhouse-reading-order.md) | 85,436 | 13,992 |
| github.com/torvalds/linux | [linux/](linux/README.md) | [../linux-kernel/02-reading-order.md](../linux-kernel/02-reading-order.md) | 96,710 | 71,098 |

The kernel's curated path lives in [`../linux-kernel/02-reading-order.md`](../linux-kernel/02-reading-order.md).
That file is the format the other curated paths follow.

## The complete listings

Every **source** file, ranked by line count, split into tiers. Tests, vendored third-party
code, documentation translations and generated files are excluded — they are four fifths of
both repositories and none of them teach you the codebase. Each repository index shows the
exact counts removed by each rule.

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

Entry numbers run continuously across all tiers, so entry 1 is the smallest source file in
the repository and the last entry is the largest.

Tiers are split into parts of 5,000 entries so that GitHub renders them. 44 parts in total.

## Two ways to use this

**You have an afternoon and want to understand the architecture.** Use the curated path. It
is ~60 files chosen because each one teaches what the next needs.

**You want to find something the right size to work on.** Use the complete listing. Open the
tier that matches the time you have and scan for a path in an area you care about.

## How these were built

Line counts come from `git grep -I -c ''` against the upstream default branch, so they
reflect the real repository, not a local checkout:

```
llvm-project   upstream/main    471f4bfee055   2026-10-23
ClickHouse     upstream/master  205bdad540d    2026-10-23
linux          origin/master    864c07de0c7d   2026-10-23
```

Exclusions are path rules, file-name rules and two content checks. One flags a file when at
least half of its evenly sampled lines are numeric or string literals rather than code. The
other flags a header that is at least 85% `#define` lines or enum constants, which is how
generated register, pin and enum tables look. Both are heuristics, so every file they remove
is listed in full under each repository, and a false positive is visible rather than silent.

The separation is sharp in practice: real source files score zero on the first check, while
data files score 0.55 and above.

Line count is a measured proxy for effort, not for difficulty. A 44-line file can carry the
idea everything else rests on.

## Regenerating

The counts go stale as the repositories move. To refresh, fetch the upstream ref and re-run
the line count; paths that stop resolving were moved, and `git log --follow -- <path>` finds
where they went.
