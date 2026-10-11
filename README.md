# notes

One place for everything I learn and build. Plain Markdown, one folder per topic.

## Index

- [blog/](blog/) — posts. A note with `blog: ready` in its frontmatter is published to
  [msohail22.github.io](https://msohail22.github.io).
- [linux-kernel/](linux-kernel/) — notes from sending patches to the Linux kernel

## How a note becomes a post

Every note carries a frontmatter block:

```yaml
---
title: My first Linux kernel patch
date: 2026-10-07
topic: linux-kernel
tags: [kernel, checkpatch]
status: done        # seed | drafting | done
lane: none          # clickhouse | homelab | low-level-lab | problem-solving | none
blog: ready         # no | ready | published
source: https://...  # the PR, commit or contest this came from
---
```

`blog: ready` is the publish switch. The site reads this repo directly, so nothing is
copied and there is one source of truth. Anything without `blog: ready` stays unpublished.

## Conventions

- Relative Markdown links only. Never `[[wikilinks]]` — they break on GitHub and in the site build.
- One topic per folder, with a `README.md` index in each.
- `source:` is what makes a post an artifact instead of an update. Always fill it in.
