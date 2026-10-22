# OSS File Reading Order

Reading paths through large open-source codebases. Simplest files first, hardest last.

| File | Repository | Files in repo |
|---|---|---|
| [llvm-reading-order.md](llvm-reading-order.md) | github.com/llvm/llvm-project | ~188,000 |
| [clickhouse-reading-order.md](clickhouse-reading-order.md) | github.com/ClickHouse/ClickHouse | ~85,000 |

The same idea for the kernel lives in [`../linux-kernel/02-reading-order.md`](../linux-kernel/02-reading-order.md),
which is the format these follow.

## How these are built

Each level teaches what the next level needs. Line counts come from the upstream default
branch and set expectations only — a 100-line file can be harder than a 1000-line one.

Every path was checked against the upstream ref on 2026-10-23, so nothing here points at a
file that has been moved or deleted. When a path stops resolving, the repository moved it;
`git log --follow -- <path>` finds where.

## How to use one

Read a file, then `git log --oneline -- <file>` to see how it changed. At each level, land one
patch in that area before moving on. Each file ends with a shortcut: the smallest set of
levels that makes the rest of the codebase legible, for when you do not want the whole path.
