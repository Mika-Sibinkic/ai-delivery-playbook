---
name: session-commit
description: Use when the operator types `/session-commit` or asks to commit, save, or hand off the session for another agent instance to pick up.
---

# Session-end commit and handoff

Execute this procedure end-to-end without permission-asking for obvious steps. Be decisive. The goal is a clean handoff that the next agent instance can pick up cold.

## Step 0: confirm there's something worth committing

```bash
git status --short | wc -l
```

If 0: report "Nothing to commit." and stop.
If > 0: continue.

## Step 1: survey what's actually changed

```bash
git status --short -uall | grep -vE '__pycache__|\.pyc$|\.DS_Store|node_modules'
```

Categorize each entry into one of:
- Real work: staged candidate.
- Noise: `__pycache__/`, `*.pyc`, `.DS_Store`, `*.log` if not intentional, `node_modules/`, `.next/`, `dist/`, `build/`, IDE-state files. SKIP.
- Sync-collision duplicates: files matching `* 2.*` (the SPACE-2 pattern that file-sync tools leave behind). NEVER stage these.
- Personal / sensitive: `.env`, credentials, secrets, transcripts of private conversations, notes that look personal. SKIP and flag to the operator.
- Ambiguous: large binaries (>1MB), untracked dirs you didn't expect, files with names that suggest someone else's work-in-progress. ASK before staging.

## Step 2: pre-commit verification (when project markers exist)

Look for project markers and run the appropriate verification BEFORE staging. Only run if the marker is present in the touched paths' nearest project root.

Run the line whose marker is present: `pytest.ini`, `pyproject.toml` or `tests/test_*.py` (pytest); `package.json` with a `"test"` script (npm); `Cargo.toml` (cargo); `go.mod` (go).

```bash
set -o pipefail; python3 -m pytest tests/ -v 2>&1 | tail -30
set -o pipefail; npm test 2>&1 | tail -20
set -o pipefail; cargo test 2>&1 | tail -20
set -o pipefail; go test ./... 2>&1 | tail -20
```

Pass criterion: the line exits 0. Without `pipefail` the exit status is `tail`'s, which is 0 even when every test fails. If Python source files changed, also import each one; all must import.

If verification fails: STOP, report the failure, do not commit. The operator can override with "commit anyway".

If no markers exist: skip the tests (e.g., a docs-only commit). The secret scan below still runs.

**Secret scan, always.** It reads the staged set, so run it right after Step 4 stages and before Step 6 commits. It uses `gitleaks` if installed, otherwise a grep for common key shapes (AWS, OpenAI-style `sk-`, GitHub, Slack, private keys):

```bash
if command -v gitleaks >/dev/null; then gitleaks protect --staged; else ! git diff --cached | grep -nE 'AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{36}|xox[bp]-|BEGIN [A-Z ]*PRIVATE KEY'; fi
```

Nonzero exit means a hit. Stop, do not commit, show the operator the file and line, and tell them to rotate the key.

## Step 3: update handoff docs if they exist

Look for these files in the project tree (relative to git root) and update them if found:

- `checkpoint.md`: full state snapshot. If found, refresh "Last updated" date and append a short "what this commit changed" section near the top.
- `context.md`: append a new dated session entry summarizing this session's work.
- `HANDOFF.md`: only edit if the changes affect what's documented there (architecture, modules, deployment).
- `tests/test-log.md`: append today's test run if Step 2 was performed.
- `MEMORY.md`: only edit if there's a notable new pattern, project state, or correction worth recording across sessions.

If NONE of these exist and the work is non-trivial: offer to create `checkpoint.md` and `context.md` (don't force).

If only some exist: update only those, don't create the missing ones unilaterally.

## Step 4: stage explicit paths

**NEVER use `git add -A`, `git add .`, or `git add <directory>/`.** The operator's repos chronically contain sync-collision duplicates that bulk-staging would commit as garbage.

Stage each path explicitly, in a single multi-arg `git add` call:

```bash
git add "path/to/file1" "path/to/file2" "path/with spaces/file3" ...
```

Quote any path containing spaces. After staging:

```bash
git diff --cached --stat
```

Report the staged set. If anything looks wrong, unstage with `git restore --staged "<path>"`. Then run the Step 2 secret scan.

## Step 5: write the commit message

Use a HEREDOC with this structure:

```
[<scope-prefix>] <one-line summary, ≤72 chars>

<2-3 line "what changed and why" paragraph>

What landed
- <bullet 1>
- <bullet 2>

Verified
- <test results, smoke-run outputs, or "no verification, docs only">

NOT in this commit (intentionally)
- <anything skipped that the next session should know about>

<Optional sections: revert command, known issues, follow-ups>

Co-Authored-By: <agent model> <noreply address>
```

**Scope prefix conventions** (auto-pick based on the touched paths):
- `[<PROJECT>-HANDOFF]`: anything under a named project's directory when the session is a handoff
- `[<area>]` for non-handoff commits (e.g., `[fix]`, `[feat]`, `[docs]`)

If the operator said "commit and hand off", always use the `*-HANDOFF` prefix.

## Step 6: execute the commit

```bash
set -o pipefail; git commit -F - <<'EOF' 2>&1 | tail -8
<message body>
EOF
```

Then verify:

```bash
git log --oneline -3
```

Confirm the new commit hash appears at HEAD.

## Step 7: push, branch-aware

Push decision follows the branch, not the phrasing. Read the project `CLAUDE.md` `STAGE:` line first.

- Pushing to a public remote is publishing. Stop and confirm, whatever the branch.
- Feature / task branch (`<operator>/*`, `audit/*`, any non-canonical branch): push automatically. Do not ask. `-u origin HEAD` sets the upstream, so a new branch does not fail for lack of one:
  ```bash
  set -o pipefail; git push -u origin HEAD 2>&1 | tail -10
  ```
- `main` or `dev` on an `internal-solo` repo: push automatically, as `stage-promotion` says.
- `main` on a `client-mvp` or `production` repo, or any branch the project `CLAUDE.md` marks as auto-deploying to production: stop and confirm. This is Tier 3; it publishes.
- Unsure which is canonical → check the branch rule in that repo's `CLAUDE.md` before pushing.

For `main` or `dev`:
```bash
set -o pipefail; git push 2>&1 | tail -10
```

Never `--force` push without explicit instruction.

## Step 8: final report

One short paragraph in this shape:

```
Commit <hash> landed. <N> files, +<X>/-<Y> lines.
- Staged: <bullet list>
- Skipped (intentionally): <noise / personal / sync duplicates>
- Pre-commit checks: <pytest 37/37 / npm test passed / no checks, docs only>
- Handoff docs updated: <checkpoint.md, context.md / none found>

Pushed: <branch> -> origin   |   Push withheld: <branch> is a production branch, confirm?
```

## Edge cases and decisions

**Bare `/commit` with no other context.** Infer "session-end commit + handoff" intent. Update existing handoff docs but don't create new ones unilaterally; offer.

**Pre-commit failure.** Do NOT stash, do NOT auto-fix. Report the failure, show the relevant tail of output, ask how to proceed. Don't bypass with `--no-verify`.

**Pack corruption / `git fsck` hangs.** If `git status` and `git log -N` work but full-history operations hang, skip fsck and proceed with the commit. Note it in the report.

**Multiple unrelated change clusters.** If staged changes span multiple unrelated topics (e.g., a feature + a typo fix in another project), offer to split into multiple commits. Don't force it; ask.

**`main` or `dev` with no upstream.** Ask before running `git push -u origin <branch>`. Feature branches set their own upstream in Step 7.

**Detached HEAD or weird branch state.** STOP. Report the state. Don't commit on a detached HEAD without explicit instruction.

## Standing rules this procedure respects

These come from the operator's persistent feedback across sessions and override default git behavior:
- Explicit paths only, never `-A`; the sync-duplicate problem is chronic, not hypothetical.
- Verify before claiming success. Don't claim a feature works without firsthand evidence.
- Co-Authored-By line is mandatory on every commit.
- HEREDOC for commit messages, never `-m "..."` with embedded newlines.
- Never amend, never `--no-verify`, never `--force` without explicit ask.
- Push feature branches automatically; confirm only before a push to `main` on a `client-mvp` or `production` repo, or to a branch that auto-deploys.
