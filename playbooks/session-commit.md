---
name: session-commit
description: Use when the operator types `/session-commit` or asks to commit, save, or hand off the session for another agent instance to pick up.
---

# Session-end commit

Run this end to end without asking about the obvious steps. The goal is a commit the next agent session can pick up cold.

## 1. See what changed

```bash
git status --short -uall
```

If nothing changed, report "Nothing to commit." and stop. On a detached HEAD, stop and report the state.

Sort each path:
- Real work: stage it.
- Noise (`__pycache__/`, `*.pyc`, `.DS_Store`, `node_modules/`, build output, IDE state): skip it.
- Secrets or personal files (`.env`, credentials, private transcripts): skip it and tell the operator.
- Anything you did not expect (large binaries, unknown directories, someone else's work in progress): ask before staging.

If the repo keeps handoff notes (for example `MEMORY.md` or `HANDOFF.md`), update the ones that exist. Do not create new ones.

## 2. Stage named paths

Never `git add -A`, `git add .` or `git add <dir>/`. Bulk staging picks up files nobody meant to commit.

```bash
git add "path/one" "path/with spaces/two"
git diff --cached --stat
```

## 3. Scan the staged files for secrets

```bash
pat='AKIA[0-9A-Z]{16}|(^|[^A-Za-z0-9])sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}|xox[abprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
if command -v gitleaks >/dev/null; then gitleaks git --staged --redact -v --no-banner; else ! git diff --cached --name-only -z --diff-filter=ACMR | xargs -0 -r git grep --cached -nIE "$pat" -- | cut -d: -f1,2 | grep .; fi
```

Both forms print the file and line of a hit and never the secret itself. The fallback reads the staged content of added and changed files, so a commit that deletes a key passes. Its pattern is the key list from this repo's `scripts/check-docs.sh`; change the two together.

A nonzero exit means a hit. Unstage the file, do not commit, show the operator the file and line, and tell them to rotate the key.

## 4. Run the tests, if the project has them

Run the line for the marker you find in the project root. No marker means no tests to run.

- `pytest.ini`, or any `test_*.py` or `*_test.py` file: `python3 -m pytest -q`. Exit 5 means pytest collected no tests; treat that as no tests.
- `package.json` with a `test` script other than the `npm init` stub (`echo "Error: no test specified" && exit 1`): `npm test`
- `Cargo.toml`: `cargo test`
- `go.mod`: `go test ./...`

Exit 0 is a pass. On a failure, stop and report the end of the output. Do not commit, stash, auto-fix or use `--no-verify`. The operator can say "commit anyway".

## 5. Commit

```
<one-line summary, 72 characters or fewer>

<two or three lines: what changed and why>

Verified
- <test result, or "docs only, no tests">

Not in this commit
- <anything skipped that the next session should know about>

Co-Authored-By: <agent model> <noreply address>
```

Pass the message through a heredoc so its newlines survive, then check that the new hash is at HEAD:

```bash
git commit -F - <<'EOF'
<message>
EOF
git log --oneline -1
```

If the staged set spans unrelated topics, offer to split it. Never amend, `--no-verify` or `--force` without an explicit ask.

## 6. Push

Apply the push rule in the Git section of `OPERATOR.md`. When it says push:

```bash
git push -u origin HEAD
```

## 7. Report

```
Commit <hash>: <N> files, +<X>/-<Y>.
Staged: <paths>. Skipped: <paths and why>.
Tests: <result, or none>. Secret scan: clean.
Pushed <branch> to origin | Push held: <reason>, confirm?
Rung: TESTED | STAGED | VERIFIED | CONFIRMED
```
