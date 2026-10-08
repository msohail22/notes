# My First Linux Kernel Patch — Notes (2026-10-07)

What I did: fixed 3 checkpatch warnings in `drivers/staging/rtl8723bs/core/rtw_mlme_ext.c`
(`x == true` → `x`, `x == false` → `!x`), built it, committed it, and emailed it to the maintainer.

---

## 1. The whole flow in one picture

```
find a warning → fix it → check it → build it → commit → rebase on maintainer tree
→ make patch file → checkpatch the patch → find maintainer → test email to self → send
```

---

## 2. Every step + the commands I ran

### Step 1 — Pick where to work
- **`drivers/staging/`** = code that's not good enough yet. Maintainer (Greg KH) **wants** beginner cleanups here.
- Outside staging, pure style cleanups usually get **rejected**.

```sh
ls drivers/staging/                 # list staging drivers
ls drivers/staging/*/TODO           # each driver's "things to fix" list
```

### Step 2 — Find warnings with checkpatch
```sh
# count every kind of warning in a driver
./scripts/checkpatch.pl -f --terse --no-summary drivers/staging/rtl8723bs/core/*.c 2>/dev/null \
  | cut -d: -f3- | sort | uniq -c | sort -rn

# show only ONE kind, with file + line numbers
./scripts/checkpatch.pl -f --terse --show-types drivers/staging/rtl8723bs/core/*.c 2>/dev/null | grep "comparison to"
```

| Flag | Meaning |
|---|---|
| `-f` | check a whole **file** (default expects a **patch**) |
| `--terse` | one line per problem: `file:line: TYPE: message` |
| `--no-summary` | hide the "total: ..." line |
| `--show-types` | show the internal name (e.g. `BOOL_COMPARISON`) |
| `--types X` | show only warning type X |
| `--list-types` | list every check name |

| Pipe piece | Meaning |
|---|---|
| `\|` | send output of left command into right command |
| `2>/dev/null` | throw away error output (stream 2 = stderr) |
| `cut -d: -f3-` | split on `:`, keep field 3 onwards (drops file + line) |
| `sort \| uniq -c` | group identical lines and count them |
| `sort -rn` | sort by number, biggest first |

### Step 3 — Fix it
```c
if (true == x)    →   if (x)
if (false == x)   →   if (!x)
```
**Always check the variable's type** before changing. `x == true` and `x` are different if `x` can be `2`.
```sh
grep -rn "bwmode_updated;" drivers/staging/rtl8723bs/include/   # find declaration → u8
grep -rn "bwmode_updated =" drivers/staging/rtl8723bs/          # only ever true/false → safe
```

### Step 4 — Check the fix
```sh
./scripts/checkpatch.pl -f --terse --types BOOL_COMPARISON drivers/staging/rtl8723bs/core/rtw_mlme_ext.c
git diff                            # only my 3 lines changed?
```

### Step 5 — Configure + build
```sh
make defconfig                              # create .config with defaults for x86_64
./scripts/config -e STAGING -e MMC -m RTL8723BS   # turn on staging, MMC, my driver (as module)
make olddefconfig                           # fill in anything missing — ALWAYS run after scripts/config
grep -E "CONFIG_MMC=|CONFIG_RTL8723BS" .config    # check: =y and =m
make -j$(nproc) drivers/staging/rtl8723bs/core/rtw_mlme_ext.o   # build only my file
```
Success = `CC [M]  drivers/.../rtw_mlme_ext.o` with no `error:` / `warning:`.

### Step 6 — Commit
```sh
git checkout -b rtl8723bs-bool-cmp
git add drivers/staging/rtl8723bs/core/rtw_mlme_ext.c
git commit -s                       # -s adds Signed-off-by (required)
git show                            # check it
git commit --amend                  # fix the last commit if needed
```
Commit message shape:
```
staging: rtl8723bs: remove comparisons to true/false in rtw_mlme_ext.c

<what checkpatch said + what I changed>

<why it's safe>

Assisted-by: Claude:claude-opus-5-5      ← if an AI helped (see section 6)
Signed-off-by: Mohammed Sohail <mohd.sohail.biz@gmail.com>
```
Get the prefix from history: `git log --oneline -10 -- drivers/staging/rtl8723bs/`

### Step 7 — Rebase on the maintainer's tree (staging-next)
Linus's `master` is NOT where staging patches land. Greg's `staging-next` is.
```sh
git fetch https://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging.git staging-next
git grep -n "true == pmlmeinfo" FETCH_HEAD -- drivers/staging/rtl8723bs/   # still unfixed there?
git rebase --onto FETCH_HEAD HEAD~1      # move my 1 commit on top of staging-next
```
Then rebuild. Also search **lore.kernel.org/linux-staging/** so nobody already sent the same fix.

### Step 8 — Make the patch + final checks
```sh
git format-patch -1                         # → 0001-....patch (the email)
./scripts/checkpatch.pl 0001-*.patch        # want 0 errors, 0 warnings
./scripts/get_maintainer.pl 0001-*.patch    # who to send to
```
- `maintainer:` → `--to`
- mailing lists → `--cc`
- `commit_signer` / `authored` people → optional

### Step 9 — Email setup (one time)
```sh
sudo pacman -S perl-authen-sasl perl-io-socket-ssl
git config --global sendemail.smtpServer smtp.gmail.com
git config --global sendemail.smtpServerPort 587
git config --global sendemail.smtpEncryption tls
git config --global sendemail.smtpUser mohd.sohail.biz@gmail.com
git config --global sendemail.confirm auto
```
Password = Gmail **App Password** (myaccount.google.com/apppasswords), no spaces. NOT normal password.

### Step 10 — Send
```sh
git send-email --to=mohd.sohail.biz@gmail.com 0001-*.patch      # test to myself first
git send-email --dry-run --to="Greg Kroah-Hartman <gregkh@linuxfoundation.org>" \
  --cc=linux-staging@lists.linux.dev --cc=linux-kernel@vger.kernel.org 0001-*.patch
# same command without --dry-run = real send (PUBLIC + PERMANENT)
```
After: wait 2+ weeks, don't resend. Feedback → fix → `git format-patch -1 -v2` → reply-all.

---

## 3. My doubts + answers

| Doubt | Answer |
|---|---|
| What's `.pl`? | A **Perl** script. checkpatch is Perl. |
| What's `python-ply`? | Python parsing library. checkpatch calls `scripts/spdxcheck.py` (Python) to check license lines; it needs `ply` + `gitpython`. |
| Why does a Perl script need Python? | checkpatch runs the Python script for one check (`scripts/checkpatch.pl:1190`). Kernel scripts mix languages. |
| What's a Traceback? | Python crash report. Read **bottom line first** = the actual error. |
| Why errors show despite the pipe? | Errors go to **stderr**, pipe only carries **stdout**. Hide with `2>/dev/null`. |
| Why no output after Ctrl+C? | `sort` waits for ALL input before printing. I killed it too early. |
| CHECK vs WARNING vs ERROR? | ERROR = wrong. WARNING = probably wrong. CHECK = picky (shows in staging / `--strict`). |
| `grep: .config: No such file`? | `.config` doesn't exist yet → run `make defconfig` first. |
| What does `make defconfig` do? | Writes `.config` (thousands of `CONFIG_X=y/m/n` lines) from `arch/x86/configs/x86_64_defconfig` + defaults in all `Kconfig` files. |
| Why did my driver not get enabled? | Its `Kconfig` says `depends on WLAN && MMC && CFG80211`; `MMC` was off → silently dropped. |
| How to debug a missing option? | `cat` its `Kconfig`, check every `depends on` in `.config`, enable missing ones, `make olddefconfig`. |
| Why did make ask 100 questions? | I skipped `make olddefconfig` after changing config. |
| `bc: command not found`, Error 127? | Build needs `bc` calculator. `sudo pacman -S bc`. 127 = command not found. Look at the **first** error only. |
| CamelCase CHECK on my patch? | It's on an existing name I didn't create. Ignore. One patch = one fix. |
| SMTP `server=localhost` error? | send-email not configured. Do Step 9. |
| `5.7.8 Username and Password not accepted`? | Used wrong password. Use Gmail **App Password**. |
| `Result: 250`? | Email server said OK. |

---

## 4. How to find MORE issues myself

### Easy (style) — staging only
```sh
./scripts/checkpatch.pl -f --terse --show-types drivers/staging/<driver>/*.c 2>/dev/null
cat drivers/staging/*/TODO              # what the maintainer actually wants
git grep -n "FIXME\|TODO\|XXX" -- drivers/staging/
```
Good first types: `BOOL_COMPARISON`, `UNNECESSARY_PARENTHESES`, `BRACES`, `UNNECESSARY_ELSE`,
`NEEDLESS_IF` (kfree(NULL)), `SPACE_BEFORE_TAB`, `SPLIT_STRING`.
Skip as beginner: line length, alignment, anything touching timing (`msleep`, `udelay`).

### Medium — compiler & checker warnings (real bugs, any subsystem)
```sh
make W=1 drivers/staging/rtl8723bs/             # extra compiler warnings
make C=1 drivers/staging/rtl8723bs/             # sparse checker (pacman -S sparse)
make coccicheck MODE=report M=drivers/staging/  # Coccinelle bug patterns (pacman -S coccinelle)
make includecheck                               # duplicate #includes
make checkstack                                 # functions using too much stack
./scripts/checkkconfigsymbols.py                # Kconfig symbols that don't exist
./scripts/kernel-doc -none drivers/staging/rtl8723bs/core/*.c   # broken doc comments
```

### Real bugs (harder, matter most) — see section 5.

### Learn from others
```sh
git log --oneline --grep="checkpatch" -- drivers/staging/ | head   # past cleanups
git log --oneline --grep="Fixes:" -- drivers/staging/ | head       # past real bug fixes
git show <commit-id>                                               # see exact change + message
```

---

## 5. Where the OPEN ISSUES are (and how to read them)

| Where | What | How to use it |
|---|---|---|
| `drivers/**/TODO` files | Maintainer wish-lists | `find . -name TODO -not -path './.git/*'` then `cat` |
| `Documentation/gpu/todo.rst` | DRM/GPU beginner-friendly tasks (with difficulty levels!) | Read it, pick a "Starter" item |
| **syzbot** — syzkaller.appspot.com/upstream | Crashes found by a fuzzer, with reproducers | Pick one with a C reproducer, in a subsystem you know |
| **bugzilla.kernel.org** | User-reported bugs | Filter by component; many are stale, check if still valid |
| **regzbot** — linux-regtracking.leemhuis.info/regzbot/mainline | Regressions (things that broke recently) — high value | Read the linked lore thread |
| **lore.kernel.org** | All mailing list archives; bugs reported on lists | Search e.g. `rtl8723bs` or `kernel test robot` |
| **kernel test robot** emails (on lore) | Build warnings/errors from Intel's 0-day bot | Search lore for `lkp@intel.com` + a subsystem |
| kernelnewbies.org/KernelJanitors/Todo | Classic janitor task list | Good ideas, some outdated |
| Reviewing patches on lists | Not an "issue", but maintainers love reviewers | Read patches, reply with `Reviewed-by:` when confident |

How to read a bug report: **1)** crash message / title **2)** the stack trace (top = where it died)
**3)** the reproducer **4)** kernel version / commit **5)** reply thread (maybe already fixed).
Use `scripts/decode_stacktrace.sh` and `scripts/faddr2line` to turn addresses into file:line.

---

## 6. Using AI help — the kernel's rule (IMPORTANT)
Read: `Documentation/process/generated-content.rst`, `Documentation/process/coding-assistants.rst`,
`Documentation/process/submitting-patches.rst` ("Using Assisted-by").

- If an AI wrote a **meaningful** part (code **or the changelog**), add a tag:
  `Assisted-by: Claude:claude-opus-5-5` (above `Signed-off-by`).
- **Only I** add `Signed-off-by`. AI must never. I am responsible for every line.
- If in doubt → be transparent and add the tag.

---

## 7. Scripts worth reading / running myself

| Script | What it does |
|---|---|
| `scripts/checkpatch.pl` | Style checker (read `--help`, `--list-types`) |
| `scripts/get_maintainer.pl` | Who to email for a file/patch |
| `scripts/config` | Edit `.config` from command line |
| `scripts/spdxcheck.py` | License-line checker |
| `scripts/coccicheck` + `scripts/coccinelle/` | Bug-pattern scripts (`.cocci` files are readable!) |
| `scripts/kernel-doc` | Checks/generates docs from code comments |
| `scripts/decode_stacktrace.sh` | Crash addresses → file:line |
| `scripts/faddr2line` | One address → file:line |
| `scripts/bloat-o-meter` | Compare size of two builds |
| `scripts/checkstack.pl` | Find stack-hungry functions |
| `scripts/checkkconfigsymbols.py` | Find bad Kconfig symbols |
| `scripts/ver_linux` | Show versions of my build tools |
| `scripts/clang-tools/gen_compile_commands.py` | Makes `compile_commands.json` → nvim jump-to-definition works |
| `make help` | Lists ALL make targets |

Docs to read (in order):
1. `Documentation/process/howto.rst`
2. `Documentation/process/coding-style.rst`
3. `Documentation/process/submitting-patches.rst`
4. `Documentation/process/submit-checklist.rst`
5. `Documentation/dev-tools/checkpatch.rst` (explains every warning)
6. `Documentation/process/development-process.rst` (1.Intro → 8.Conclusion)
7. `Documentation/process/deprecated.rst` (APIs NOT to use)
8. `Documentation/process/email-clients.rst`

---

## 8. Writing GOOD kernel code — the basics

**Style**
- Tabs = 8 wide. Lines ≤ 100 (aim 80). `snake_case`, no CamelCase.
- Braces: function `{` on its own line; `if (x) {` on same line.
- Short local names (`i`, `tmp`), descriptive global names.
- Functions short and doing one thing.

**Errors**
- Return `0` on success, negative error code on failure (`-ENOMEM`, `-EINVAL`).
- Clean up with `goto` labels in reverse order (`goto err_free;`) — normal in kernel.
- Pointers that can be errors: `IS_ERR(p)`, `PTR_ERR(p)`, `ERR_PTR(-E...)` (`include/linux/err.h`).
- Always check return values of `kmalloc`, etc.

**Memory**
- `kmalloc/kzalloc/kfree` (not malloc). `GFP_KERNEL` normally, `GFP_ATOMIC` if you can't sleep.
- `kfree(NULL)` is safe — no `if` needed.
- Prefer `sizeof(*p)` over `sizeof(struct foo)`.
- In drivers prefer `devm_*` (auto-freed when device goes away).

**Safety**
- No floating point. Small stack (≈8–16 KB total) — no big arrays on stack.
- Can't sleep while holding a spinlock or in interrupt context.
- Data from userspace: only via `copy_from_user()` / `copy_to_user()`. Never trust it.
- Use `strscpy()`, not `strcpy`/`strncpy`. Use `size_add/size_mul` / `struct_size()` for sizes.
- Don't use `volatile` (read `volatile-considered-harmful.rst`).

**Common helpers to know**
- `include/linux/list.h` (linked lists), `container_of()`, `ARRAY_SIZE()`, `min()/max()`,
  `pr_info()/dev_err()` for printing (not printk with raw levels).

**Patch habits**
- One logical change per patch. Builds at every patch. Explain **why**.
- Never break userspace. Never change behavior in a "cleanup".
- Test what you can; say honestly what you didn't test.

---

## 9. Finding OLD bugs nobody is fixing (syzbot method)

1. Open **syzkaller.appspot.com/upstream** (all open fuzzer bugs, ~1,600).
2. Columns that matter:
   - **Repro**: `C` = there's a C program that triggers it → you can test your fix. Want this.
   - **Last**: last time it crashed. Small (< 30d) = still real.
   - **Reported**: when found. Big (> 1 year) = nobody fixed it.
   - **Discussions**: `PATCH [800d]` = someone tried 800 days ago and it stalled. Empty = nobody even replied.
3. Pick titles starting with `WARNING`, `KASAN`, `UBSAN` in a **driver** (usb, input, media, comedi).
   Skip as a beginner: `rcu stall`, `task hung`, `deadlock`, `KCSAN`, `lost connection`, and filesystems (jfs, ocfs2, gfs2, btrfs).
4. Open the bug → read the crash → open the C repro → read the stalled PATCH on lore (why did it die?).
5. Check it's still broken in the tree: `git log --oneline -- <file>` (did a fix land recently?).
6. Test fixes WITHOUT your own machine: reply to the syzbot email with `#syz test` + your patch
   (syzbot runs the repro on your patch). Docs: github.com/google/syzkaller/blob/master/docs/syzbot.md
7. Run it locally: build kernel + QEMU, run the C repro inside the VM.

Other places:
- **bugzilla.kernel.org** → Search → Status NEW/ASSIGNED, sort by "Changed" oldest first.
- **regzbot** (linux-regtracking.leemhuis.info/regzbot/mainline) → regressions, high value.
- `Documentation/gpu/todo.rst` → `grep -B20 "Level: Starter"` for easy GPU tasks.
- `find . -name TODO -not -path './.git/*'` → maintainer wish-lists.
