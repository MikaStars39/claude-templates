---
name: cmp
description: "Auto commit-merge-push: classify all uncommitted changes by type (feat/doc/fix/refactor/perf/test/chore), commit each on its own branch, merge to main, and push."
user_invocable: true
---

# CMP — Auto Commit, Merge & Push

You are executing the `/cmp` command. Your job is to take ALL uncommitted changes in the working tree, **classify them into granular commit groups**, commit each group on its own branch, merge all branches into main, and push.

## Procedure

### Step 1 — Gather changes

Run these in parallel:
- `git status` (see all changed/untracked files)
- `git diff` (unstaged changes)
- `git diff --cached` (staged changes)
- `git log --oneline -10` (recent commit style reference)
- `git branch` (confirm current branch)

If there are no changes at all, tell the user and stop.

### Step 2 — Classify every changed file

Read the diffs and assign each file to exactly ONE category:

| Prefix | Scope |
|--------|-------|
| `feat`    | New feature or significant new functionality |
| `doc`     | Documentation only (*.md, docs/, docstrings, comments-only) |
| `fix`     | Bug fix, error correction |
| `refactor`| Code restructuring without behavior change |
| `perf`    | Performance improvement |
| `test`    | Test files only |
| `chore`   | Build, CI, config, tooling, dependencies |

Rules:
- If a file touches both code and docs, classify by the **primary intent** of the change.
- If only one category has changes, that's fine — just one branch/commit.
- Present the classification to the user in a table and **ask for confirmation** before proceeding. The user may want to adjust categories or the commit message.

### Step 3 — For each category (sequentially)

For each non-empty category, run these steps **in order**:

1. Make sure you are on `main`: `git checkout main`
2. Create and switch to a new branch: `git checkout -b <prefix>/<short-description>`
   - Branch name example: `feat/add-retry-logic`, `doc/update-eval-guide`, `fix/score-off-by-one`
3. Stage ONLY the files belonging to this category: `git add <file1> <file2> ...`
4. Commit with a message following the project's conventional style:
   ```
   [<prefix>] <concise summary>
   ```
   Example: `[feat] add retry logic for failed API calls`
5. Switch back to main: `git checkout main`
6. Merge the branch: `git merge <branch-name>`
7. Delete the branch: `git branch -d <branch-name>`

**IMPORTANT**: Process categories one at a time. Do NOT try to create multiple branches in parallel — git can only be on one branch at a time. After merging each branch, verify you are back on main before starting the next category.

### Step 4 — Push

After ALL categories are merged into main:
```
git push
```

### Step 5 — Verify

Run `git status` and `git log --oneline -<N>` (where N = number of categories merged) to confirm everything is clean and all commits are present.

Report the result to the user: how many commits were created, their messages, and that push succeeded.

## Safety Rules

- **NEVER commit directly on main.** Always branch first.
- **NEVER force push.** If push fails, stop and tell the user.
- **NEVER mix categories** in a single commit.
- If the working tree has merge conflicts or is in a dirty state that prevents branching, stop and tell the user.
- If any step fails, stop immediately, report the error, and do NOT continue to the next category. Let the user decide how to recover.
- Do not include files that look like secrets (.env, credentials, tokens).
- Add `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>` to each commit message.
