#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_HOME="${HOME}/.claude"

removed=0

for dir in skills agents commands; do
    dst="${CLAUDE_HOME}/${dir}"
    [ -d "$dst" ] || continue
    for link in "${dst}"/*.md; do
        [ -L "$link" ] || continue
        target=$(readlink -f "$link" 2>/dev/null || true)
        if [[ "$target" == "${REPO_DIR}/"* ]]; then
            rm "$link"
            ((removed++))
        fi
    done
done

echo "Removed ${removed} symlinks from ${CLAUDE_HOME}/"
