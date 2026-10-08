# My Second Kernel Patch — extern cleanup (2026-10-08)

What I did: removed 17 redundant `extern` keywords from function prototypes in
`drivers/staging/rtl8723bs/include/rtw_recv.h` (8) and `include/sta_info.h` (9).
Sent to Greg KH. `Result: 250`.

Patch #1 taught me **the process**. Patch #2 taught me **how to find work, how to
avoid wasted work, and the traps that only appear the second time.**
This file only records what was NEW. For the base process see `01-first-kernel-patch.md`.

---

## 1. Base on the maintainer's tree properly (better than what I did in patch #1)

In patch #1 I based on Linus's `master` and then used
`git rebase --onto FETCH_HEAD HEAD~1` to move it. That works but it is backwards.
Do this instead — add the tree as a **real remote** once, then branch from it directly:

```sh
git remote add staging https://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging.git
git fetch staging
git branch -r | grep staging/          # see what exists
git checkout -b my-topic staging/staging-testing
```

| Branch | What it is |
|---|---|
| `staging/staging-testing` | where new patches land FIRST — **branch from this one** |
| `staging/staging-next` | survived testing, heading for the next release |
| `staging/staging-linus` | fixes going to Linus now — ignore |

**`staging-testing` gets REBASED by Greg.** So commit hashes change under me.
Consequences:
- `git log --all --grep=X` shows the SAME patch twice with different hashes. Not a duplicate.
  It is my old copy plus the rebased copy.
- Always `git fetch staging` and re-branch before starting new work. Never build on a stale copy.

Check I am actually based correctly:
```sh
git log --oneline -3                              # top commit should be Greg's, not mine
git log --oneline staging/staging-testing..HEAD   # should list ONLY my commits
```

---

## 2. Survey a whole driver for work — checkpatch aggregation

Patch #1: I grepped for one warning type I already knew about.
Patch #2: I counted **every** warning type across the **whole driver** first, then picked.

```sh
cd ~/Github/linux
./scripts/checkpatch.pl -f --strict --terse --show-types --no-tree \
    $(find drivers/staging/rtl8723bs -name '*.[ch]') > /tmp/cp.txt
grep -oE '(WARNING|CHECK|ERROR):[A-Z_]+' /tmp/cp.txt | sort | uniq -c | sort -rn
```

**`--show-types` is mandatory here.** Without it the output says only `CHECK:` with no
type name, and the `uniq -c` count is useless. I lost a run to this.

Result for rtl8723bs (2026-10, v7.3-rc6):
```
2023 CAMELCASE          994 LONG_LINE         687 SPACING
 431 OPEN_ENDED_LINE    389 LONG_LINE_COMMENT 241 UNNECESSARY_PARENTHESES
 185 MACRO_ARG_PRECEDENCE 162 BRACES          132 LINE_SPACING
  77 SPACE_BEFORE_TAB    38 BIT_MACRO          27 BLOCK_COMMENT_STYLE
  21 MULTIPLE_ASSIGNMENTS 17 AVOID_EXTERNS     14 LOGICAL_CONTINUATIONS
  12 ERROR:COMPLEX_MACRO
```

Then pick a **small, bounded** pile and see which files hold it:
```sh
grep 'UNNECESSARY_PARENTHESES' /tmp/cp.txt | cut -d: -f1 | sort | uniq -c | sort -rn
```
One file = one patch. If 164 of 241 hits are in one file, that file is one patch and
the rest are other patches.

---

## 3. The actual technical thing I learned: `extern` on functions vs variables

```c
extern u32 _rtw_init_sta_priv(struct sta_priv *pstapriv);   /* FUNCTION -> extern does NOTHING */
extern int rtw_mc2u_disable;                                 /* VARIABLE -> extern is REQUIRED  */
```

- A function **declaration** in a header is implicitly `extern` by the C language.
  Writing it adds nothing. Kernel style says remove it.
- A variable declaration needs `extern` to say "storage is allocated in some .c file,
  do not allocate it again here". **Delete it and the kernel fails to link.**
- Tell them apart by the parentheses: `name(...)` = function, `name;` = variable.

### The trap, and why checkpatch saves me
```sh
grep -c '^extern' drivers/staging/rtl8723bs/include/*.h | grep -v ':0$'
```
That gave **61** lines across 6 headers. checkpatch flagged only **17**.
The other 44 are variables (`drv_types.h`, `hal_pwr_seq.h`, `ieee80211.h`, `rtw_mlme_ext.h`
are all variable declarations).

**If I had grepped and deleted all 61, I would have broken the build.**
checkpatch's `AVOID_EXTERNS` only fires on function prototypes — it already did the sorting.

**Rule: work from checkpatch's exact line list, not from my own grep.**

---

## 4. Finding dead code — the unused-macro trick

A different and more valuable kind of patch than style: delete things nothing uses.
This found **806** macros defined in rtl8723bs headers and used nowhere.

```sh
cd drivers/staging/rtl8723bs
# every identifier in the driver, with a count
grep -rhoE '\b[A-Za-z_][A-Za-z_0-9]*\b' --include='*.[ch]' . | sort | uniq -c > /tmp/freq.txt
# every macro name defined in a header
grep -rhoE '^[[:space:]]*#[[:space:]]*define[[:space:]]+[A-Za-z_][A-Za-z_0-9]*' \
    --include='*.h' . | awk '{print $NF}' | sort -u > /tmp/macros.txt
# macros whose total count in the whole driver is 1 == only the definition line
awk 'NR==FNR{c[$2]=$1; next} c[$1]==1 {print $1}' /tmp/freq.txt /tmp/macros.txt
```

**This list is a starting point, NOT proof.** Before deleting each name:
```sh
cd ~/Github/linux
git grep -w THE_MACRO_NAME        # must hit ONLY the definition, in the WHOLE tree
```
A macro can be used by another subsystem, by assembly, or built by token pasting
(`FOO_##x`), which this script cannot see. One header = one patch.

---

## 5. Check competition BEFORE doing the work

rtl8723bs is in every "first kernel patch" tutorial, so everyone is in it.

```sh
# commits and distinct authors per staging driver, last 12 months
for d in drivers/staging/*/; do
  n=$(basename $d)
  c=$(git log --since='12 months ago' --oneline staging/staging-testing -- $d | wc -l)
  a=$(git log --since='12 months ago' --format='%an' staging/staging-testing -- $d | sort -u | wc -l)
  printf "%-16s %6s %6s\n" "$n" "$c" "$a"
done | sort -k2 -rn
```

Measured 2026-10:
```
DRIVER            COMMITS  AUTHORS   CHECKPATCH LEFT
rtl8723bs             651      189        ~5700
media                 142       70            -
greybus                64       38            49
sm750fb                52       27             1
most                   32       18             4
iio                    24       15            24
axis-fifo              22        7             0
octeon                 20        7             1
fbtft                  19       15            37
vme_user               14       10            38
nvec                   11        9             1
vc04_services          10        5             0
```

**The lesson: every quiet staging driver is quiet because it is FINISHED.**
`sm750fb` has 27 authors and 1 remaining complaint. `nvec` has 9 authors and 1.
rtl8723bs has 189 authors because it is the only staging driver with work left.

Moving directory does not reduce competition. I must change the **kind** of work:
1. Stay in rtl8723bs but take the piles nobody finishes (806 unused macros, 2023 camelCase).
   Low competition comes from work that takes effort, not from an empty room.
2. Run Coccinelle (section 9) — real defects, not style, and almost no beginner runs it.
3. Device tree `.txt` → `.yaml` conversion — 634 files left:
   `find Documentation/devicetree/bindings -name '*.txt' | wc -l`

### Also check nobody already sent MY patch
```sh
git log --oneline --all --grep='extern' -i -- drivers/staging/rtl8723bs/
git log --format='%h %ad %an %s' --date=short -6 staging/staging-testing -- <my files>
```
Then search the archive **in a browser** (lore blocks scripted fetches with Anubis):
```
https://lore.kernel.org/all/?q=rtl8723bs+extern
https://lore.kernel.org/all/?q=rtl8723bs+sta_info.h
```
I found `57b9f86e1ae1 "remove extern from function declarations in header files"` already in
history. **Partial cleanups are extremely common** — someone swept, did not finish, and my
17 lines survived. A pile with an old commit in it is not automatically a dead pile.

---

## 6. The `---` notes-to-reviewer area

In the generated `.patch` file, everything **below the lone `---` line and above the diffstat**
is read by humans and **thrown away by git when applied**. It never enters the history.
That is where I explain things to the reviewer.

Hand-editing the file works, but `git format-patch` regenerates from the commit and wipes it.
The repeatable way:
```sh
git notes add -m "my note text" HEAD
git format-patch -1 --notes             # emits the note under --- automatically
git config notes.rewriteRef refs/notes/commits   # keep notes across rebases
```
Notes live only in my clone. They never become part of the commit and never reach the tree.

### What I used it for: pre-existing warnings on lines I touched
checkpatch flagged 2 long lines in my patch:
```
124 cols: union recv_frame *_rtw_alloc_recvframe(...);  /* get a free ... */
```
But before my patch those lines were **131 and 130** columns. I made them 7 chars SHORTER
and they are still over 100.

**checkpatch warns on any line my patch touches, even if the problem pre-existed and I
improved it.** It cannot tell "pre-existing" from "newly introduced".

Correct response: do NOT fix it in this patch (that is a different change — moving the
trailing comments). Say so under `---` so the reviewer knows I did not just ignore the tool.
It is polish, not a requirement.

---

## 7. Traps I hit this time

### `0001-*.patch` matched TWO files — nearly re-sent my old patch
`git format-patch` numbers from `0001` **every time**, so the old patch file from patch #1
was still sitting in the repo root with the same prefix. The glob matched both. `--dry-run`
showed:
- two `Dry-OK` blocks — it was going to re-send my already-submitted bool patch
- the second email carried `In-Reply-To:` and `References:` pointing at the first —
  git threaded them as a **2-patch series** with no cover letter. Greg would likely drop both.

**Rules:**
- `rm` old `.patch` files before `git format-patch`.
- **Type the filename out. Never glob** in `git send-email`.
- `--dry-run` EVERY time. It caught this.

### A correct dry run has exactly
| Check | Correct |
|---|---|
| `Dry-OK` | appears **once** |
| `Subject:` | my patch's subject |
| `In-Reply-To:` / `References:` | **absent** (present = unwanted threading) |
| `Result:` after real send | `250` |

### `git commit -s` silently did nothing
I ran it, but closed the editor without saving — that **aborts** the commit with no loud error.
`git status` still showed ` M` and `git log -1` still showed someone else's commit.
**Always verify after committing:**
```sh
git status --short                    # empty == committed
git log -1                            # MY name, MY subject, Signed-off-by present
git log --oneline staging/staging-testing..HEAD   # exactly my commits, no more
```

### zsh does not word-split unquoted variables
```sh
files=$(find . -name '*.c')
checkpatch $files        # zsh: ONE argument with newlines -> silently wrong/empty results
checkpatch $(find . -name '*.c')   # command substitution IS split -> works
checkpatch ${=files}     # explicit split in zsh
```
This gave me a full table of fake "0 warnings" results before I noticed. In bash the first
form works, in zsh it does not. **A suspiciously clean result means check the tool, not the code.**

---

## 8. My verification checklist before sending (use every time)

```sh
git status --short                                   # empty
git log -1                                           # me, subject, Signed-off-by
git log --oneline staging/staging-testing..HEAD      # only my commits
git diff staging/staging-testing --stat              # expected line count, no extra files
git diff --check                                     # whitespace damage -> prints NOTHING
./scripts/checkpatch.pl --strict -g HEAD             # 0 errors; understand every warning
git log -1 --format='%s' | wc -c                     # subject <= 75 chars
git log -1 --format='%b' | awk 'length($0)>75'       # body lines <= 75 -> prints nothing
make drivers/staging/<driver>/                       # it BUILDS
./scripts/get_maintainer.pl --no-git-fallback -g HEAD
rm old-*.patch && git format-patch -1
git send-email --dry-run ... <exact-filename>.patch
```

`git diff --check` is new to me and worth keeping — it catches trailing whitespace and
space/tab damage that checkpatch may report less clearly.

---

## 9. Next: Coccinelle (real defects, not style)

76 bug-pattern scripts ship in `scripts/coccinelle/`. They find memory leaks, missing error
checks, wrong `sizeof`, bad API use. Almost no beginner runs them — this is the low-competition
work.

**On Arch it is NOT in the official repos. It is in the AUR** (written in OCaml, so it compiles
from source, 20–40 min):
```sh
yay -S coccinelle
spatch --version
```

Start with ONE script on ONE directory, not all 76 on the tree:
```sh
make coccicheck MODE=report J=$(nproc) \
     COCCI=scripts/coccinelle/api/memdup.cocci \
     M=drivers/staging/rtl8723bs
```
| Part | Meaning |
|---|---|
| `MODE=report` | print findings only, change nothing |
| `COCCI=` | one script instead of all 76 |
| `M=` | one directory |
| `J=$(nproc)` | all cores |

Then widen by dropping `COCCI=`, and save the output:
```sh
make coccicheck MODE=report J=$(nproc) M=drivers/staging/rtl8723bs > ~/cocci.txt 2>&1
```
**Coccinelle gives false positives.** A hit is a suggestion. Read the code and prove it myself
before changing anything.

---

## 10. My doubts + answers (patch #2)

| Doubt | Answer |
|---|---|
| `git pull origin master` or `fetch` + `merge`? | **Neither**, for patch work. `pull`/`merge` create a merge commit and maintainers reject those. Use `git fetch staging` then `git rebase`. Keep history linear. |
| How do I update `master` without leaving my branch? | `git fetch origin master:master` — fast-forwards it while I stay put. |
| `'staging/staging-testing' is not a commit` | I never added the remote. `git remote add staging <url>` then `git fetch staging`. |
| Why does `git log --all` show my patch twice? | Greg **rebases** `staging-testing`, so hashes change. One is my stale copy. |
| checkpatch complains about lines I made shorter? | It flags any line my patch touches, pre-existing or not. Do not fix it here; note it under `---`. |
| Is the `---` note required? | No. Polish. Skip it if it is costing more than it is worth. |
| Why did `uniq -c` on checkpatch show only `CHECK:`? | Missing `--show-types`. |
| Why did my per-driver loop report 0 warnings everywhere? | zsh did not split `$files`. See section 7. |
| 61 `extern` lines but checkpatch flagged 17? | The other 44 are **variables**, where `extern` is required. |
| Can I just regenerate the patch instead of hand-editing notes? | Yes: `git notes add` + `git format-patch --notes`. Plain `format-patch` always wipes hand edits. |
| `pacman -S coccinelle` → target not found | It is in the AUR, not the official repos. `yay -S coccinelle`. |
| Where is the low-competition work? | Not in a quieter directory — they are all finished. In a harder **kind** of work. See section 5. |
| What does `Result: 250` mean? | SMTP success. The mail server accepted it. Sent. |

---

## 11. What I got WRONG and must fix next time

**I did not add the `Assisted-by:` tag.** Claude found the issue, surveyed the driver, and
drafted my commit message — and my own rule in `01-first-kernel-patch.md` §6 says a tag is
required when an AI writes a meaningful part of the code **or the changelog**. The patch is
already sent, so I cannot change it. From the next patch:

```
Assisted-by: Claude:claude-opus-5-5
Signed-off-by: Mohammed Sohail <mohd.sohail.biz@gmail.com>
```

Only I ever add `Signed-off-by`. I am responsible for every line regardless of who drafted it.
Read `Documentation/process/coding-assistants.rst` again before patch #3.

---

## 12. Patch #2 scoreboard

| Thing | Result |
|---|---|
| Lines changed | 17 removed, 17 added, 2 files |
| checkpatch errors | 0 |
| checkpatch warnings | 2, both pre-existing long lines I made shorter |
| Whitespace damage | none (`git diff --check` clean) |
| Functional change | none |
| Subject length | 67 chars |
| Sent | `Result: 250`, no threading, correct recipients |
| Missing | `Assisted-by:` tag |

Next: wait weeks, do not resend. Then Coccinelle.
