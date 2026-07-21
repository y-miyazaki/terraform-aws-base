#!/usr/bin/env bash
# Cursor CLI status line (/statusline configured)
# stdin: StatusLinePayload JSON — see statusline skill

set -euo pipefail

JQ=/usr/bin/jq
GIT=/usr/local/bin/git

input=$(cat)

MODEL=$(printf '%s' "$input" | "$JQ" -r '.model.display_name // "Unknown"')
DIR=$(printf '%s' "$input" | "$JQ" -r '.workspace.current_dir // .cwd // "."')
PCT=$(printf '%s' "$input" | "$JQ" -r '.context_window.used_percentage // 0' | cut -d. -f1)

BRANCH=""
if "$GIT" -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$("$GIT" -C "$DIR" branch --show-current 2> /dev/null || true)
fi

# Line 1: model + git branch (cyan / yellow — distinct from built-in footer)
if [ -n "$BRANCH" ]; then
    printf '\033[36m%s\033[0m  \033[33m🌿 %s\033[0m\n' "$MODEL" "$BRANCH"
else
    printf '\033[36m%s\033[0m\n' "$MODEL"
fi

# Line 2: context percentage
if [ "$PCT" -ge 90 ]; then
    printf '\033[31mctx %s%%\033[0m\n' "$PCT"
elif [ "$PCT" -ge 75 ]; then
    printf '\033[33mctx %s%%\033[0m\n' "$PCT"
else
    printf '\033[32mctx %s%%\033[0m\n' "$PCT"
fi
