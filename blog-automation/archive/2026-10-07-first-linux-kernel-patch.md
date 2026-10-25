---
title: My first Linux kernel patch
slug: first-linux-kernel-patch
date: 2026-10-07
topic: linux-kernel
tags: [kernel, checkpatch, git-send-email]
status: done
lane: none
blog: ready
source: https://github.com/msohail22/notes/blob/main/linux-kernel/01-first-kernel-patch.md
summary: What it actually takes to get three checkpatch warnings fixed, built and emailed to a kernel maintainer.
---

I fixed three `checkpatch` warnings in `drivers/staging/rtl8723bs/core/rtw_mlme_ext.c`,
built the file, committed it, and emailed it to the maintainer. The code change was
trivial — `x == true` becomes `x`, and `x == false` becomes `!x`. Everything around the
code change was not.

These are the notes I wish I had before I started.

## The whole thing in one picture

<figure>
<svg viewBox="0 0 680 110" role="img" aria-label="Pipeline: find a warning, fix it, check it, build it, commit, format the patch, send the email.">
  <style>
    .kp-track { stroke: currentColor; stroke-width: 1; opacity: .15; }
    .kp-draw {
      stroke: currentColor; stroke-width: 1.5; fill: none;
      stroke-dasharray: 560; stroke-dashoffset: 560;
      animation: kp-draw 7s linear infinite;
    }
    /* The boxes stay fully opaque so the connecting line never shows through
       them; only the stroke and the label pulse. */
    .kp-step rect {
      fill: var(--paper, #fff); stroke: currentColor; stroke-width: 1; stroke-opacity: .3;
      animation: kp-stroke 7s linear infinite; animation-delay: inherit;
    }
    .kp-step text {
      fill: currentColor; fill-opacity: .45; font-size: 12px; text-anchor: middle;
      animation: kp-text 7s linear infinite; animation-delay: inherit;
    }
    @keyframes kp-draw {
      0%        { stroke-dashoffset: 560; }
      80%, 100% { stroke-dashoffset: 0; }
    }
    @keyframes kp-stroke {
      0%, 6%    { stroke-opacity: .3; }
      11%, 19%  { stroke-opacity: 1; }
      25%, 100% { stroke-opacity: .3; }
    }
    @keyframes kp-text {
      0%, 6%    { fill-opacity: .45; }
      11%, 19%  { fill-opacity: 1; }
      25%, 100% { fill-opacity: .45; }
    }
  </style>
  <line class="kp-track" x1="20" y1="44" x2="660" y2="44" />
  <line class="kp-draw"  x1="20" y1="44" x2="660" y2="44" />
  <g class="kp-step" style="animation-delay: 0s">
    <rect x="20" y="28" width="74" height="32" rx="3" /><text x="57" y="48">find</text>
  </g>
  <g class="kp-step" style="animation-delay: .85s">
    <rect x="114" y="28" width="74" height="32" rx="3" /><text x="151" y="48">fix</text>
  </g>
  <g class="kp-step" style="animation-delay: 1.7s">
    <rect x="208" y="28" width="74" height="32" rx="3" /><text x="245" y="48">checkpatch</text>
  </g>
  <g class="kp-step" style="animation-delay: 2.55s">
    <rect x="302" y="28" width="74" height="32" rx="3" /><text x="339" y="48">build</text>
  </g>
  <g class="kp-step" style="animation-delay: 3.4s">
    <rect x="396" y="28" width="74" height="32" rx="3" /><text x="433" y="48">commit -s</text>
  </g>
  <g class="kp-step" style="animation-delay: 4.25s">
    <rect x="490" y="28" width="74" height="32" rx="3" /><text x="527" y="48">format</text>
  </g>
  <g class="kp-step" style="animation-delay: 5.1s">
    <rect x="584" y="28" width="74" height="32" rx="3" /><text x="621" y="48">send</text>
  </g>
  <text x="340" y="88" style="fill: currentColor; font-size: 11px; text-anchor: middle; opacity: .5">
    one patch, one fix, one email
  </text>
</svg>
</figure>

## Where a beginner is actually welcome

`drivers/staging/` holds code that is not good enough yet. Greg Kroah-Hartman maintains it
and **wants** cleanups there. Outside staging, a pure style cleanup is usually rejected.
That single fact decides where you start.

```sh
ls drivers/staging/              # the drivers
ls drivers/staging/*/TODO        # what each one still needs
```

## Finding a warning

`checkpatch.pl` is a Perl script. By default it expects a patch, so `-f` is what you want
when you are reading a file.

```sh
# count every kind of warning in one driver
./scripts/checkpatch.pl -f --terse --no-summary drivers/staging/rtl8723bs/core/*.c 2>/dev/null \
  | cut -d: -f3- | sort | uniq -c | sort -rn

# show just one kind, with line numbers
./scripts/checkpatch.pl -f --terse --show-types drivers/staging/rtl8723bs/core/*.c 2>/dev/null \
  | grep "comparison to"
```

Two things bit me here. Errors go to stderr, so the pipe carried nothing until I added
`2>/dev/null`. And `sort` waits for all of its input before it prints anything, so
pressing Ctrl+C early looks like the command produced nothing.

## The severity levels are not equal

| Level | Means |
|---|---|
| `ERROR` | Wrong. |
| `WARNING` | Probably wrong. |
| `CHECK` | Picky. Shows up in staging and under `--strict`. |

A `CHECK` on a name you did not create is not yours to fix. One patch fixes one thing.

## Building only what you touched

You do not build the kernel. You build the file.

```sh
make defconfig        # writes .config
make olddefconfig     # after any config change, or make asks you 100 questions
make drivers/staging/rtl8723bs/core/rtw_mlme_ext.o
```

My driver silently refused to build at first. Its `Kconfig` said
`depends on WLAN && MMC && CFG80211`, and `MMC` was off, so the whole driver was dropped
without a word. The way to debug that is to read the `Kconfig`, check every `depends on`
line against `.config`, turn on what is missing, and run `make olddefconfig`.

## Signing and sending

`git commit -s` adds the `Signed-off-by:` line. Without it the patch is not acceptable.

```sh
git config --global sendemail.smtpServer smtp.gmail.com
git config --global sendemail.smtpServerPort 587
git config --global sendemail.smtpEncryption tls
```

The password is a Gmail **App Password**, not your account password, and it goes in
without spaces. `5.7.8 Username and Password not accepted` means you used the wrong one.

Then find who to mail, and mail yourself first:

```sh
./scripts/get_maintainer.pl 0001-*.patch
git send-email --to=your.own@address 0001-*.patch        # test on yourself
git send-email --dry-run --to="Greg Kroah-Hartman <gregkh@linuxfoundation.org>" \
  --cc=linux-staging@lists.linux.dev --cc=linux-kernel@vger.kernel.org 0001-*.patch
```

Drop `--dry-run` and it is public and permanent. `Result: 250` means the server accepted it.
