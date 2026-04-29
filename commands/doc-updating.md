Update or create README.md in directories affected by recent code changes.

## Steps

1. **Identify affected directories** — parse the user's argument or run `git diff --name-only HEAD~1` to find changed files. Group by directory.

2. **For each directory**, launch `doc-readme-sync` agent:

   Prompt: "Directory `<path>` had these changes: `<file list>`. Read the code changes (`git diff` or file contents). If README.md exists, update it with a concise note on what changed and why. If no README.md exists, create one covering: purpose (one sentence), key files, design intent, known pitfalls. Never restate code — only document what the code doesn't tell you. Keep it under 300 words."

3. **Preview** — show the user which READMEs will be updated/created and a summary of planned changes. Ask for confirmation before writing.

4. **Apply** — write the changes and report what was done.
