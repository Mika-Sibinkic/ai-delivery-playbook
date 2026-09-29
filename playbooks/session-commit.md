# Session-end commit and handoff

*Loads when: the operator types `/commit` or asks to commit, save, or hand off the session for another agent instance to pick up.*

Execute this procedure end-to-end without permission-asking for obvious steps. Be decisive. The goal is a clean handoff that the next agent instance can pick up cold.

## Step 0 — confirm there's something worth committing

```bash
git status --short | wc -l
```

If 0: report "Nothing to commit." and stop.
If > 0: continue.

## Step 1 — survey what's actually changed

```bash
git status --short | grep -vE '__pycache__|\.pyc$|\.DS_Store|node_modules' | head -40
```

Categorize each entry into one of:
- **Real work** — staged candidate.
- **Noise** — `__pycache__/`, `*.pyc`, `.DS_Store`, `*.log` if not intentional, `node_modules/`, `.next/`, `dist/`, `build/`, IDE-state files. SKIP.
- **Sync-collision duplicates** — files matching `*  2.*` (the SPACE-2 pattern that file-sync tools leave behind). NEVER stage these.
- **Personal / sensitive** — `.env`, credentials, secrets, transcripts of private conversations, notes that look personal. SKIP and flag to the operator.
- **Ambiguous** — large binaries (>1MB), untracked dirs you didn't expect, files with names that suggest someone else's work-in-progress. ASK before staging.

## Step 2 — pre-commit verification (when project markers exist)

Look for project markers and run the appropriate verification BEFORE staging. Only run if the marker is present in the touched paths' nearest project root.

| Marker | Run | Pass criterion |
|---|---|---|
| `pytest.ini`, `pyproject.toml`, `tests/test_*.py` | `python3 -m pytest tests/ -v 2>&1 \| tail -30` | All pass |
| `package.json` with `"test"` script | `npm test 2>&1 \| tail -20` | Exit 0 |
| `Cargo.toml` | `cargo test 2>&1 \| tail -20` | Exit 0 |
| `go.mod` | `go test ./... 2>&1 \| tail -20` | Exit 0 |
| Modified Python source files | Quick import sweep on each file | All import |

If verification fails: STOP, report the failure, do not commit. The operator can override with "commit anyway".

If no markers exist: skip this step (e.g., a docs-only commit).

## Step 3 — update handoff docs if they exist

Look for these files in the project tree (relative to git root) and update them if found:

- `checkpoint.md` — full state snapshot. If found, refresh "Last updated" date and append a short "what this commit changed" section near the top.
- `context.md` — append a new dated session entry summarizing this session's work.
- `HANDOFF.md` — only edit if the changes affect what's documented there (architecture, modules, deployment).
- `tests/test-log.md` — append today's test run if Step 2 was performed.
- `MEMORY.md` — only edit if there's a notable new pattern, project state, or correction worth recording across sessions.

If NONE of these exist and the work is non-trivial: offer to create `checkpoint.md` and `context.md` (don't force).

If only some exist: update only those, don't create the missing ones unilaterally.

## Step 4 — stage explicit paths

**NEVER use `git add -A`, `git add .`, or `git add <directory>/`.** The operator's repos chronically contain sync-collision duplicates that bulk-staging would commit as garbage.

Stage each path explicitly, in a single multi-arg `git add` call:

```bash
git add "path/to/file1" "path/to/file2" "path/with spaces/file3" ...
```

Quote any path containing spaces. After staging:

```bash
git diff --cached --stat
```

Report the staged set. If anything looks wrong, unstage with `git restore --staged "<path>"`.

## Step 5 — write the commit message

Use a HEREDOC with this structure:

```
[<scope-prefix>] <one-line summary, ≤72 chars>

<2-3 line "what changed and why" paragraph>

What landed
- <bullet 1>
- <bullet 2>

Verified
- <test results, smoke-run outputs, or "no verification — docs only">

NOT in this commit (intentionally)
- <anything skipped that the next session should know about>

<Optional sections: revert command, known issues, follow-ups>

Co-Authored-By: <agent model> <noreply address>
```

**Scope prefix conventions** (auto-pick based on the touched paths):
- `[<PROJECT>-HANDOFF]` — anything under a named project's directory when the session is a handoff
- `[<area>]` for non-handoff commits (e.g., `[fix]`, `[feat]`, `[docs]`)

If the operator said "commit and hand off" — always use the `*-HANDOFF` prefix.

## Step 6 — execute the commit

```bash
git commit -m "$(cat <<'EOF'
<message body>
EOF
)" 2>&1 | tail -8
```

Then verify:

```bash
git log --oneline -3
```

Confirm the new commit hash appears at HEAD.

## Step 7 — push, branch-aware

Push decision follows the branch, not the phrasing. Read the project `CLAUDE.md` `STAGE:` line first.

- **Feature / task branch** (`<operator>/*`, `audit/*`, any non-canonical branch): **push automatically. Do not ask.**
- **`dev`** on an `internal-solo` repo: push automatically.
- **`main`, or any branch the project `CLAUDE.md` marks as auto-deploying to production**: **stop and confirm.** This is Tier 3 — it publishes.
- Unsure which is canonical → check the worktree conventions for that repo before pushing.

When pushing:
```bash
git push 2>&1 | tail -10
```

Never `--force` push without explicit instruction.

## Step 8 — final report

One short paragraph in this shape:

```
Commit <hash> landed. <N> files, +<X>/-<Y> lines.
- Staged: <bullet list>
- Skipped (intentionally): <noise / personal / sync duplicates>
- Pre-commit checks: <pytest 37/37 / npm test passed / no checks — docs only>
- Handoff docs updated: <checkpoint.md, context.md / none found>

Pushed: <branch> -> origin   |   Push withheld: <branch> is a production branch, confirm?
```

## Edge cases and decisions

**Bare `/commit` with no other context.** Infer "session-end commit + handoff" intent. Update existing handoff docs but don't create new ones unilaterally — offer.

**Pre-commit failure.** Do NOT stash, do NOT auto-fix. Report the failure, show the relevant tail of output, ask how to proceed. Don't bypass with `--no-verify`.

**Pack corruption / `git fsck` hangs.** If `git status` and `git log -N` work but full-history operations hang, that's the known sync-collision-ref issue. Skip fsck, proceed with the commit. Note it in the report.

**Multiple unrelated change clusters.** If staged changes span multiple unrelated topics (e.g., a feature + a typo fix in another project), offer to split into multiple commits. Don't force it — ask.

**No existing remote tracking.** If `git push` would fail because no upstream is set, ask before running `git push -u origin <branch>`.

**Detached HEAD or weird branch state.** STOP. Report the state. Don't commit on a detached HEAD without explicit instruction.

## Standing rules this procedure respects

These come from the operator's persistent feedback across sessions and override default git behavior:
- Explicit paths only, never `-A` — the sync-duplicate problem is chronic, not hypothetical.
- Verify before claiming success. Don't claim a feature works without firsthand evidence.
- Co-Authored-By line is mandatory on every commit.
- HEREDOC for commit messages, never `-m "..."` with embedded newlines.
- Never amend, never `--no-verify`, never `--force` without explicit ask.
- Push feature branches automatically; confirm only before a push to a production branch.
