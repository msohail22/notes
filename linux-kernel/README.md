# Linux Kernel Contribution Notes

My own notes from actually sending patches to the Linux kernel. Written as I go, so each
file records what I did not know before that patch.

Read in order. `01` is the full process. `03` only records what was new the second time.

| File | What it covers |
|---|---|
| [01-first-kernel-patch.md](01-first-kernel-patch.md) | The complete submission process end to end: checkpatch, configuring and building one file, `git commit -s`, `format-patch`, `get_maintainer.pl`, `send-email` setup with a Gmail App Password. Plus where open issues live (syzbot, regzbot, bugzilla, TODO files), kernel coding basics, and the rule for AI assistance (`Assisted-by:`). |
| [02-reading-order.md](02-reading-order.md) | A path through the kernel source, simplest to hardest — 62 files in 12 levels, from `fs/proc/cmdline.c` to `kernel/bpf/verifier.c`. One patch per level before moving on. |
| [03-second-kernel-patch.md](03-second-kernel-patch.md) | Finding work and avoiding wasted work: basing on `staging-testing` properly, surveying a driver by warning type, hunting dead code, measuring competition, the `---` notes-to-reviewer area, the traps that only appear the second time, and a pre-send checklist. |

## Patches sent

| # | Patch | Date | Status |
|---|---|---|---|
| 1 | `staging: rtl8723bs: remove comparisons to true/false in rtw_mlme_ext.c` | 2026-10-07 | sent, waiting |
| 2 | `staging: rtl8723bs: remove extern from recv and sta_info prototypes` | 2026-10-08 | sent, waiting |

Archive: <https://lore.kernel.org/linux-staging/>

## Next

Coccinelle — real defects instead of style. See `03` §9.
Remember the `Assisted-by:` tag this time (`03` §11).

## Setup note

These files live here and are symlinked into my kernel tree:

```sh
ln -s ~/Github/notes/linux-kernel ~/Github/linux/learnings
```

`.git/info/exclude` in the kernel clone contains `learnings` (**no trailing slash** — a
trailing slash only matches a directory, and this is a symlink). That keeps it invisible to
`git status` in the kernel tree while the files stay versioned here.
