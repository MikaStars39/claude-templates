#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_HOME="${HOME}/.claude"

installed=0

for dir in skills agents commands; do
    src="${REPO_DIR}/${dir}"
    dst="${CLAUDE_HOME}/${dir}"
    [ -d "$src" ] || continue
    mkdir -p "$dst"
    for f in "${src}"/*.md; do
        [ -f "$f" ] || continue
        ln -sf "$f" "${dst}/$(basename "$f")"
        ((installed++)) || true
    done
done

echo "Installed ${installed} files as symlinks into ${CLAUDE_HOME}/"
echo ""
echo "Symlinked directories:"
for dir in skills agents commands; do
    count=$(find "${CLAUDE_HOME}/${dir}" -maxdepth 1 -name '*.md' -type l 2>/dev/null | wc -l)
    echo "  ~/.claude/${dir}/ — ${count} symlinks"
done
echo ""
echo "To uninstall, run: $0 --uninstall"
