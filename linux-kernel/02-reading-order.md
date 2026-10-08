# Linux Kernel Reading Order — Simplest → Hardest

The kernel has ~90,000 files. Nobody reads all of them. This is a **path**: each level teaches
what the next level needs. Read a file, then `git log --oneline -- <file>` to see how it changes.

Tips:
- Use `nvim` + `scripts/clang-tools/gen_compile_commands.py` (after a build) to jump to definitions.
- Or browse online with links: **elixir.bootlin.com/linux/latest/source**
- Don't understand a macro? `git grep -n "define MACRO_NAME" include/`

---

## Level 0 — The rules (no code yet)
1. `README`
2. `Documentation/process/howto.rst`
3. `Documentation/process/coding-style.rst`
4. `Documentation/process/submitting-patches.rst`
5. `Documentation/dev-tools/checkpatch.rst`
6. `MAINTAINERS` (skim — learn the format, search for your driver)

## Level 1 — Tiny files (< 60 lines)
7. `fs/proc/cmdline.c` — what `cat /proc/cmdline` runs (24 lines)
8. `fs/proc/version.c` — `cat /proc/version` (27 lines)
9. `lib/bsearch.c` — binary search (36 lines)
10. `fs/proc/uptime.c` — `cat /proc/uptime` (45 lines)
11. `drivers/misc/dummy-irq.c` — smallest "real" driver (60 lines)

## Level 2 — Basic building blocks (headers everyone uses)
12. `include/linux/types.h` — `u8`, `u32`, `bool`, etc.
13. `include/linux/err.h` — `ERR_PTR`, `IS_ERR` error pointers
14. `include/linux/container_of.h` — the most important macro in the kernel
15. `include/linux/list.h` — kernel linked lists
16. `include/linux/kernel.h` — `ARRAY_SIZE`, `min/max`, etc.
17. `include/linux/compiler.h` — `likely()`, `READ_ONCE()` (skim)

## Level 3 — Simple library code (plain C, no hardware)
18. `lib/sort.c` — heap sort
19. `lib/kstrtox.c` — string → number
20. `lib/string.c` — `strlen`, `memcpy`, etc.
21. `lib/kfifo.c` — ring buffer
22. `lib/rbtree.c` + `include/linux/rbtree.h` — red-black tree
23. `lib/vsprintf.c` — how `printk("%pS")` works (long, skim)

## Level 4 — Example modules (written to teach)
24. `samples/kobject/kobject-example.c` — sysfs files
25. `samples/kfifo/` — using the fifo
26. `samples/workqueue/` — deferred work
27. `samples/timers/` — timers
28. Write your own "hello world" module and load it (`insmod`, `dmesg`)

## Level 5 — Simple real drivers
29. `drivers/net/dummy.c` — fake network card (200 lines)
30. `drivers/char/mem.c` — `/dev/null`, `/dev/zero`, `/dev/mem`
31. `drivers/char/misc.c` — the misc-device framework
32. `fs/ramfs/inode.c` — simplest filesystem (329 lines)
33. `drivers/staging/rtl8723bs/` — the driver I patched (messy = learn what NOT to do)

## Level 6 — How the kernel starts and stops
34. `init/main.c` — `start_kernel()`, the C entry point
35. `kernel/printk/printk.c` — logging (skim)
36. `kernel/panic.c` — what happens on a crash
37. `kernel/reboot.c`
38. `kernel/kthread.c` — kernel threads

## Level 7 — System calls & files
39. `kernel/sys.c` — simple syscalls (`getpid`, `uname`)
40. `fs/open.c` — `open()`
41. `fs/read_write.c` — `read()` / `write()`
42. `Documentation/process/adding-syscalls.rst`

## Level 8 — Processes & concurrency
43. `Documentation/kernel-hacking/hacking.rst`
44. `Documentation/kernel-hacking/locking.rst`
45. `kernel/locking/mutex.c`
46. `kernel/workqueue.c`
47. `kernel/time/timer.c`
48. `kernel/fork.c` — creating a process
49. `kernel/exit.c` — ending a process

## Level 9 — Memory
50. `Documentation/core-api/memory-allocation.rst`
51. `mm/slub.c` — `kmalloc` under the hood
52. `mm/mmap.c`
53. `mm/memory.c` — page faults
54. `mm/page_alloc.c` — physical page allocator (8000 lines)

## Level 10 — Networking
55. `net/core/skbuff.c` — packet buffers (`sk_buff`)
56. `net/ipv4/tcp.c`

## Level 11 — Hardest
57. `kernel/sched/core.c` — the scheduler (11,000 lines)
58. `fs/namei.c` — path lookup
59. `kernel/rcu/tree.c` — RCU (read `Documentation/RCU/` first)
60. `arch/x86/entry/entry_64.S` — assembly: syscall/interrupt entry
61. `arch/x86/kernel/head_64.S` — assembly: very first boot code
62. `kernel/bpf/verifier.c` — BPF verifier (21,000 lines)

---

**Rule:** at each level, try one patch in that area before moving on.
Level 1–5 → staging cleanups. Level 6+ → syzbot / bugzilla bugs (see `01-first-kernel-patch.md` §5).
