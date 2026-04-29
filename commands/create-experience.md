Distill the current conversation into a concise, actionable lesson-learned document under `docs/experience/`, then update the index. This prevents repeating the same mistakes.

## Steps

1. **Analyze the conversation** — Identify:
   - What problem or mistake was encountered
   - Root cause (why it happened)
   - How it was resolved
   - What to do differently next time

2. **Pick a filename** — Use the pattern `<slug>-<YYYY-MM-DD>.md` where `<slug>` is a short kebab-case topic. Check that the file does not already exist.

3. **Write the experience file** — Create `docs/experience/<filename>`:

   ```markdown
   ---
   title: <Short descriptive title>
   date: <YYYY-MM-DD>
   ---

   ## Context
   <What we were trying to do and what went wrong — 1-3 sentences.>

   ## Root Cause
   <Why it happened — the underlying reason, not just symptoms.>

   ## Resolution
   <What we did to fix it — be specific about the approach.>

   ## Lesson
   <The takeaway rule or checklist item to prevent recurrence. Written as an actionable guideline that future-you can follow.>
   ```

   **Constraints:**
   - **Under 500 words total.** Be concise — every sentence should earn its place.
   - **English only.**
   - **Focus on WHY, not HOW.** The code diff is in git; the experience doc captures the reasoning that git cannot.
   - **Be specific.** "Be careful with X" is useless. "Always check Y before doing Z because W" is useful.
   - If the conversation involved a decision rather than a mistake, use `## Decision` and `## Rationale` instead of `## Root Cause` and `## Resolution`.

4. **Update the index** — Append a row to the table in `docs/experience/README.md`:

   ```
   | <YYYY-MM-DD> | [<filename>](<filename>) | <One-line summary of the lesson> |
   ```

5. **Confirm** — Show the user the filename and a one-line summary of what was captured.
