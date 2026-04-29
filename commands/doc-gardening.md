Fix stale code references in markdown docs — broken paths, renamed functions, dead cross-links.

## Steps

1. Launch `doc-ref-audit` agent:

   Prompt: "Scan all markdown files for stale code references (file paths, function names, CLI args, cross-links). Verify each against the codebase. Auto-fix high-confidence issues, flag the rest."

2. Present the agent's report to the user.

3. Ask: "Want me to apply the flagged fixes?"
