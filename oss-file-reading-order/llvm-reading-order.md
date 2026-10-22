# LLVM Reading Order — Simplest → Hardest

`llvm-project` has ~188,000 files. Nobody reads all of them. This is a **path**: each level
teaches what the next level needs. Read a file, then `git log --oneline -- <file>` to see how
it changes.

Line counts are from `upstream/main` on 2026-10-23 and are there to set expectations, not to
rank quality. A 100-line file can be harder than a 1000-line one.

Tips:
- Build with `cmake -G Ninja -DLLVM_ENABLE_PROJECTS="clang" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`,
  then `nvim` jumps to definitions through `compile_commands.json`.
- Or browse online: **github.com/llvm/llvm-project**
- See the IR for any C file: `clang -S -emit-llvm -O0 x.c -o -`
- Watch one pass work: `opt -passes=mem2reg -S x.ll`
- Don't understand a term? `llvm/docs/Lexicon.md` first, not a search engine.

---

## Level 0 — The rules (no code yet)
1. `README.md` — what the monorepo contains (27 lines)
2. `CONTRIBUTING.md` — where contributions start (20 lines)
3. `llvm/docs/MyFirstTypoFix.md` — a whole first patch, start to finish (467)
4. `llvm/docs/Contributing.md` — the process (210)
5. `llvm/docs/Lexicon.md` — the vocabulary; skim, return often (330)
6. `llvm/docs/GettingStarted.md` — building it (1109)
7. `llvm/docs/CodingStandards.md` — the house style (1854)

## Level 1 — See the IR before reading the code
8. `llvm/docs/LangRef.md` — **skim only**: skip to "Instruction Reference" (28,579)
9. `llvm/examples/ModuleMaker/ModuleMaker.cpp` — build a module by hand (69)
10. `llvm/examples/HowToUseLLJIT/HowToUseLLJIT.cpp` — compile and run IR (101)
11. `llvm/examples/Fibonacci/fibonacci.cpp` — emit a real function (148)

## Level 2 — The containers everything is built from
12. `llvm/include/llvm/Support/Casting.h` — `dyn_cast`, `isa`; used on every page (896)
13. `llvm/include/llvm/ADT/ArrayRef.h` — borrowed arrays (576)
14. `llvm/include/llvm/ADT/StringRef.h` — borrowed strings (967)
15. `llvm/include/llvm/ADT/Twine.h` — lazy string concatenation (553)
16. `llvm/include/llvm/ADT/SmallVector.h` — the workhorse container (1433)
17. `llvm/include/llvm/ADT/DenseMap.h` — the workhorse map (1397)
18. `llvm/include/llvm/ADT/STLExtras.h` — skim; the utility drawer (2739)

## Level 3 — Support library (plain C++, no IR yet)
19. `llvm/lib/Support/ErrorHandling.cpp` — how LLVM dies (373)
20. `llvm/lib/Support/raw_ostream.cpp` — all output goes through this (1040)
21. `llvm/lib/Support/CommandLine.cpp` — why every tool has the same flags (2980)
22. `llvm/lib/Support/APInt.cpp` — arbitrary-precision integers; constant folding needs it (3273)

## Level 4 — The IR object model
23. `llvm/lib/IR/Use.cpp` — the def-use edge, in 44 lines. Read it twice.
24. `llvm/lib/IR/LLVMContext.cpp` — what owns the types and constants (405)
25. `llvm/lib/IR/Value.cpp` — the base of everything in IR (1349)
26. `llvm/lib/IR/BasicBlock.cpp` — straight-line code (1060)
27. `llvm/lib/IR/Type.cpp` — the type system (1128)
28. `llvm/lib/IR/Module.cpp` — the compilation unit (1051)
29. `llvm/lib/IR/Function.cpp` — functions and arguments (1235)
30. `llvm/lib/IR/Instruction.cpp` — the instruction base class (1564)
31. `llvm/lib/IR/IRBuilder.cpp` — how passes create instructions (1437)

## Level 5 — Write a pass
32. `llvm/docs/WritingAnLLVMNewPMPass.md` — the new pass manager (281)
33. `llvm/lib/IR/PassManager.cpp` — smaller than you expect (188)
34. `llvm/lib/Transforms/Utils/Mem2Reg.cpp` — stack slots → SSA registers (116)
35. `llvm/lib/Transforms/Scalar/DCE.cpp` — dead code elimination (147)
36. `llvm/lib/Transforms/Scalar/SCCP.cpp` — the pass shell; the work is in `Utils/SCCPSolver` (139)
37. `llvm/lib/Transforms/Scalar/ADCE.cpp` — aggressive DCE; needs post-dominators (614)
38. Write your own pass, run it with `opt -passes=...`, and diff the IR

## Level 6 — A front end, end to end
39. `llvm/examples/Kaleidoscope/Chapter2/toy.cpp` — parser, no codegen yet (446)
40. `llvm/examples/Kaleidoscope/Chapter3/toy.cpp` — the same language, now emitting IR
41. Chapters 4–7 in order — optimisation, control flow, then mutable variables

## Level 7 — Analysis: what passes ask before they act
42. `llvm/lib/Analysis/LoopInfo.cpp` — finding loops (1359)
43. `llvm/lib/Analysis/AliasAnalysis.cpp` — "can these two pointers overlap?" (1024)
44. `llvm/include/llvm/IR/PatternMatch.h` — the matching DSL InstCombine is written in (3351)
45. `llvm/lib/IR/Constants.cpp` — constant folding (3821)

## Level 8 — Real optimisation passes (long, but readable by now)
46. `llvm/lib/Transforms/Scalar/GVN.cpp` — global value numbering (4445)
47. `llvm/lib/Transforms/InstCombine/InstructionCombining.cpp` — peephole driver (6439)
48. `llvm/lib/Transforms/Utils/SimplifyCFG.cpp` — control-flow cleanup (9458)
49. `llvm/lib/Passes/PassBuilder.cpp` — how `-O2` is actually assembled (3017)

## Level 9 — The back end
50. `llvm/lib/MC/MCStreamer.cpp` — emitting assembly and objects (1808)
51. `llvm/lib/CodeGen/MachineFunction.cpp` — IR after instruction selection (1729)
52. `llvm/lib/CodeGen/RegAllocGreedy.cpp` — register allocation (3124)
53. `llvm/utils/TableGen/Common/CodeGenDAGPatterns.cpp` — where `.td` files become matchers (4995)

## Level 10 — Hardest
54. `llvm/lib/IR/Verifier.cpp` — every invariant of the IR, in one file (8543)
55. `llvm/lib/Analysis/ValueTracking.cpp` — known bits, ranges, the basis of most folds (11,142)
56. `llvm/lib/CodeGen/SelectionDAG/SelectionDAG.cpp` — IR → machine instructions (15,572)
57. `clang/lib/Sema/SemaExpr.cpp` — C++ expression semantics (22,479)
58. `llvm/lib/Target/X86/X86ISelLowering.cpp` — one target's lowering (65,834)

## Side path — MLIR, if you want it
59. `mlir/docs/Tutorials/Toy/Ch-1.md` — the language (131)
60. `mlir/docs/Tutorials/Toy/Ch-2.md` — dialects and operations (726)

---

**Rule:** at each level, land one patch in that area before moving on.
Level 0–3 → documentation and `ADT` cleanups. Level 4+ → `good first issue` on
github.com/llvm/llvm-project/issues, or a missing fold in InstCombine.

**Shortcut if you only want one thing:** read Level 2, then Level 4, then file 34
(`Mem2Reg.cpp`). That is the smallest set that makes the rest of LLVM legible.
