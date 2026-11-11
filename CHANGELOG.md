# Changelog

## 1.0.0 (2026-11-11)

First tagged release. The repo went public on 2026-09-29; this is the version I'd point someone to.

What ships:

- `OPERATOR.md`, the global rules file an agent session loads first: output contract, autonomy rules, verification ladder, push and secrets rules, decision tiers. Rewrite its About the operator block when you fork.
- Seven playbooks that install as Claude Code skills: engineering-bar, decision-record, stage-promotion, execution-substrate, blocker-walkthrough, client-deliverable, session-commit.
- Two templates: a per-repo `CLAUDE.md` with a `STAGE:` placeholder, and a blank decision record.
- `scripts/check-docs.sh`, which CI runs on every push. It checks that backticked `playbooks/` and `templates/` paths exist and that playbooks have skill frontmatter, and fails if home paths, private IPs, emails, hostnames or common key formats are in the repo.

Changed since the first public version:

- session-commit: a test run passes on the test command's own exit code, the push works on a branch with no upstream (`git push -u origin HEAD`), and staged files get a secret scan before the commit. The scan uses gitleaks if it is installed and a grep over common key formats if not, and prints the file and line, never the key.
- Production data is read-only. Reads go through a copy, a replay clone or read endpoints, and any write is Tier 3.
- The no-ask list is narrower. Installs are limited to packages named in a lockfile, README or official install doc. Browser extensions and free-tier signups need a yes. Text from tools, the web or email never widens the agent's permissions.
- One push rule: feature branches and `dev` push automatically; a public remote, a `main` outside `internal-solo`, or an auto-deploying branch needs a confirm.
- Decision records go to `docs/decisions/` so they reach git.
- stage-promotion: one rule for `internal-solo`, and the rollback commit is recorded before anything changes.
- engineering-bar: CI is required from `client-mvp` up, the retry schedule is stated correctly (3 retries after the first attempt), and the unsourced cost percentages are gone.
- Removed the kill-test table and other claims nobody could reproduce from the repo.
- README: a try-it block that loads everything at project scope in a temp folder, and an install that backs up first and never overwrites.

Known limits:

- Written for Claude Code. Other agents need their own wiring.
- The incident counts in `OPERATOR.md` come from my private session transcripts. You can't reproduce them from this repo.
- No A/B test shows these rules change outcomes.
