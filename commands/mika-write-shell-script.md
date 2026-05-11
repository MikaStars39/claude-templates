# Write Shell Script

When writing a `.sh` script, pick one of two styles based on complexity. **Never mix styles.**

## Style A — Simple (few params, single command)

Use when the script has a single command invocation with ≤ ~15 flags and no logical grouping is needed.

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
WORKDIR="${REPO_ROOT}/outputs/run_name_${TIMESTAMP}"

python "${REPO_ROOT}/path/to/entry.py" \
  --flag-a value \
  --flag-b value \
  --flag-c value 2>&1 | tee "${WORKDIR}/run.log"
```

Rules:
- `set -euo pipefail` (strict mode).
- Variables at top, single `python` / command call, no functions.
- Use `${VAR:?msg}` for required env vars, `${VAR:-default}` for optional.
- No banner `echo`, no arg parsing, no `usage()`.

## Style B — Structured (many params with logical sections)

Use when the script has many flags that naturally group (model, data, optimizer, runtime, etc.).

```bash
#!/bin/bash
# One-line purpose comment
# Key context: model, dataset, method

set -ex

# ---- paths ----
PROJECT_DIR=${PROJECT_DIR:-"/default/path"}
SAVE_DIR="${SAVE_DIR:-/default/save}"
mkdir -p ${SAVE_DIR}

# ---- model ----
MODEL_ARGS=(
  --model-size 8b
  --hidden-size 4096
)

# ---- data ----
DATA_ARGS=(
  --data-path /path/to/data
  --batch-size 32
)

# ---- optimizer ----
OPT_ARGS=(
  --lr 1e-6
  --weight-decay 0.1
)

# ---- launch ----
python ${PROJECT_DIR}/train.py \
  ${MODEL_ARGS[@]} \
  ${DATA_ARGS[@]} \
  ${OPT_ARGS[@]} 2>&1 | tee ${SAVE_DIR}/output.log
```

Rules:
- `set -ex` (trace mode — useful for long training scripts).
- Group related flags into **named bash arrays** (`ARGS=(...)`) with `# ---- section ----` headers.
- Expand arrays at the final command: `${ARRAY[@]}`.
- Paths and environment setup at top, launch command at bottom.
- Brief header comment explaining what the script does — no ASCII art, no banners.

## When to use which style
**Default to Style A.** Only use Style B when the script exceeds ~50 lines. If you can write it flat with inline `${VAR:-default}` values, do that — don't introduce arrays, conditional arg building (`[[ -n ... ]] && ARGS+=(...)`), or section headers just because there are a few optional params. Inline defaults and a single command call are almost always enough.

## Universal Rules

1. **No `echo` banners**, no `usage()` functions, no arg parsing boilerplate.
2. Prefer env positional args over vars with defaults (`${VAR:-default}`).
3. `REPO_ROOT` or `PROJECT_DIR` at top so paths are portable.
4. End the pipeline with `2>&1 | tee <log_path>` when there's a main command.
5. Keep it flat — no functions, no sourced helper libs, unless the user explicitly asks.
6. No defensive programming for simple scripts: no arrays, no conditional `ARGS+=()`, no `[[ -n ... ]]` guards — just pass flags inline with defaults.
7. Ask the user which style they prefer if it's ambiguous. When in doubt, use Style A.
