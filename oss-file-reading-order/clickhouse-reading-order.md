# ClickHouse Reading Order — Simplest → Hardest

`ClickHouse` has ~85,000 files. Nobody reads all of them. This is a **path**: each level
teaches what the next level needs. Read a file, then `git log --oneline -- <file>` to see how
it changes.

Line counts are from `upstream/master` on 2026-10-23 and are there to set expectations, not to
rank quality.

Tips:
- The development docs are no longer in the repo. They live at
  **clickhouse.com/docs/development/**
- Build once with `cmake -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`, then `nvim` can jump
  to definitions.
- Read a struct's real size with `.claude/tools/cppexpr.sh -i Core/Block.h 'OUT(sizeof(DB::Block))'`
- Trace one query end to end: `clickhouse-client --send_logs_level=trace -q "SELECT 1"`
- Every error code in a file maps to `src/Common/ErrorCodes.cpp`.

---

## Level 0 — The rules (no code yet)
1. `README.md` — what ClickHouse is (86 lines)
2. `CONTRIBUTING.md` — the CLA and where the docs went (35)
3. clickhouse.com/docs/development/developer-instruction — prerequisites and setup
4. clickhouse.com/docs/development/style — the C++ style guide; Allman braces, enforced by CI
5. clickhouse.com/docs/development/architecture — read this before any source file
6. clickhouse.com/docs/development/tests — how to run a stateless test
7. VLDB 2024 paper, `vldb.org/pvldb/vol17/p3731-schulze.pdf` — the design, 12 pages

## Level 1 — Tiny files that show the shape of the code
8. `src/Core/Types.h` — the scalar types (54)
9. `src/Processors/ISource.h` — the smallest processor interface (61)
10. `src/Storages/StorageNull.h` — a complete table engine that does nothing (77)
11. `src/DataTypes/DataTypesNumber.h` — how a type is registered (99)
12. `src/Functions/toTypeName.cpp` — the simplest real function (112)
13. `src/Functions/abs.cpp` — a numeric function (123)
14. `src/Functions/isNull.cpp` — nullability handling (139)

## Level 2 — Memory and errors (the two things every file touches)
15. `src/Common/Exception.h` — how ClickHouse throws (408)
16. `src/Common/ErrorCodes.cpp` — every error the server can produce (949)
17. `src/Common/StringUtils.h` — small string helpers (477)
18. `src/Common/PODArray.h` — the container columns are built on (808)
19. `src/IO/ReadBuffer.h` — all input flows through this (272)
20. `src/IO/WriteBuffer.h` — all output flows through this (247)

## Level 3 — Columns and blocks (the data model)
21. `src/Core/Block.h` — a batch of columns; the unit of work (231)
22. `src/Columns/ColumnString.h` — strings, offsets and all (333)
23. `src/Columns/ColumnVector.h` — numeric columns (384)
24. `src/DataTypes/IDataType.h` — type behaviour, separate from storage (737)
25. `src/Core/Field.h` — a single dynamic value (1003)
26. `src/Columns/IColumn.h` — the column interface; dense, read slowly (1138)
27. `src/Core/Block.cpp` — the implementation (1245)

## Level 4 — Functions and aggregates
28. `src/Functions/IFunction.h` — the function interface (849)
29. `src/Functions/empty.cpp` — a function over strings (279)
30. `src/Functions/repeat.cpp` — a function that allocates (316)
31. `src/AggregateFunctions/AggregateFunctionCount.h` — simplest aggregate (169)
32. `src/AggregateFunctions/AggregateFunctionSum.h` — state, merge, serialise (704)
33. `src/AggregateFunctions/IAggregateFunction.h` — the interface (1146)
34. `src/Functions/FunctionsLogical.cpp` — short-circuiting, ternary logic (1048)

## Level 5 — Parsing
35. `src/Parsers/IAST.h` — the AST node base (561)
36. `src/Parsers/ParserQuery.cpp` — the top-level parser; small on purpose (204)
37. `src/Parsers/ExpressionListParsers.cpp` — recursive descent, precedence (4703)

## Level 6 — Pipeline execution
38. `src/Processors/ISimpleTransform.h` — one in, one out (58)
39. `src/Processors/Chunk.h` — what moves between processors (185)
40. `src/Processors/IProcessor.h` — the state machine; read the comment at the top (451)
41. `src/Processors/QueryPlan/IQueryPlanStep.h` — a plan node (268)
42. `src/Processors/Executors/PullingPipelineExecutor.cpp` — pulling results out (144)
43. `src/Processors/QueryPlan/QueryPlan.cpp` — the plan itself (1491)
44. `src/QueryPipeline/QueryPipelineBuilder.cpp` — plan → running pipeline (1097)

## Level 7 — Storage engines
45. `src/Storages/IStorage.h` — the table interface (936)
46. `src/Storages/StorageMemory.cpp` — a complete, simple engine (992)
47. `src/Storages/StorageFile.cpp` — reading files as tables (3846)
48. `src/Storages/MergeTree/IMergeTreeDataPart.h` — what a "part" is (1082)

## Level 8 — The server around the query
49. `programs/main.cpp` — one binary, many tools (442)
50. `src/Processors/Executors/Runtime/V1/ExecutingGraph.cpp` — scheduling processors
51. `src/Server/TCPHandler.cpp` — the native protocol, per connection (3605)
52. `src/Client/ClientBase.cpp` — the other side of that protocol (5538)
53. `src/Interpreters/InterpreterSelectQuery.cpp` — the older SELECT path (3849)

## Level 9 — Hard but worth it
54. `src/Common/ThreadPool.cpp` — the thread pool everything schedules on (1379)
55. `src/IO/ReadHelpers.h` — parsing primitives, performance-critical (2251)
56. `src/Common/ZooKeeper/ZooKeeper.cpp` — coordination for replication (2308)
57. `src/Storages/MergeTree/MergeTreeDataSelectExecutor.cpp` — index → ranges to read (3478)
58. `src/Interpreters/Aggregator.cpp` — hash tables, spilling, two-level (6284)

## Level 10 — Hardest
59. `src/Analyzer/Resolve/QueryAnalyzer.cpp` — name and type resolution (8197)
60. `src/Interpreters/Context.cpp` — the global state everything reaches for (10,371)
61. `src/Storages/StorageReplicatedMergeTree.cpp` — replication, in one file (12,351)
62. `src/Core/Settings.cpp` — every setting, with its history (12,583)
63. `src/Storages/MergeTree/MergeTreeData.cpp` — parts, merges, mutations, TTL (15,799)

---

**Rule:** at each level, land one patch in that area before moving on.
Level 1–4 → a new function, or a missing test. Level 5+ → an open issue with
`good first issue` or a reproducible bug report.

**Shortcut if you only want one thing:** read Level 3, then Level 6, then file 46
(`StorageMemory.cpp`). Columns in, processors move them, a storage produces them —
that is ClickHouse in three ideas.
