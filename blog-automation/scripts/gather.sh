#!/usr/bin/env bash
# Collect today's raw material into daily/<date>/. Read-only: touches no remote state.
set -euo pipefail

CF_HANDLE="${CF_HANDLE:-msohail22}"
DAY="${1:-$(date +%F)}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/daily/$DAY"
mkdir -p "$OUT"

# Tweet-only files: frontmatter is for us, nothing reads it at build time.
for f in prs codeforces low-level-lab opinions; do
  [ -f "$OUT/$f.md" ] || printf -- '---\nday: %s\nkind: %s\nstatus: draft\ntweeted: no\n---\n\n' "$DAY" "$f" > "$OUT/$f.md"
done

# learning-blog.md is different: the Astro site globs it, so even an untouched
# stub must satisfy the content schema or the whole build fails. `blog: no`
# keeps it off the site until it is a real post; add a `slug:` then.
if [ ! -f "$OUT/learning-blog.md" ]; then
  cat > "$OUT/learning-blog.md" <<EOF
---
title: ''
date: $DAY
topic: unsorted
tags: []
status: seed
lane: none
blog: no
---

EOF
fi

# ---- PRs: everything that changed state today -------------------------------
gh search prs --author=@me --json url,title,state,repository,updatedAt --limit 60 \
  | jq -r --arg d "$DAY" '
      [ .[] | select(.updatedAt | startswith($d)) ]
      | if length == 0 then "_no PR activity today_"
        else .[] | "- [\(.state)] \(.repository.nameWithOwner)#\(.url|split("/")|last) \(.title)\n  \(.url)"
        end' > "$OUT/.raw-prs.md"

# ---- Codeforces: accepted today, deduped by problem ------------------------
EPOCH_FROM=$(date -d "$DAY 00:00:00" +%s)
EPOCH_TO=$(date -d "$DAY 23:59:59" +%s)
curl -fsS "https://codeforces.com/api/user.status?handle=${CF_HANDLE}&from=1&count=200" \
  | jq -r --argjson a "$EPOCH_FROM" --argjson b "$EPOCH_TO" '
      if .status != "OK" then "_codeforces api error: \(.comment)_"
      else
        [ .result[]
          | select(.verdict == "OK")
          | select(.creationTimeSeconds >= $a and .creationTimeSeconds <= $b) ]
        | unique_by(.problem.contestId, .problem.index)
        | if length == 0 then "_no accepted submissions today_"
          else .[] | "- \(.problem.contestId)\(.problem.index) \(.problem.name) (\(.problem.rating // "unrated")) — https://codeforces.com/problemset/problem/\(.problem.contestId)/\(.problem.index)"
          end
      end' > "$OUT/.raw-codeforces.md"

echo "$OUT"
echo "--- PRs ---";        cat "$OUT/.raw-prs.md"
echo "--- Codeforces ---"; cat "$OUT/.raw-codeforces.md"
