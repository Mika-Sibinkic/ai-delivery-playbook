# Changelog

## 1.0.0 (2026-11-11)

First release. The repo went public on 2026-09-29; this is the version I'd point someone to.

Changed since the first public version:

- session-commit: a test run passes on the test command's own exit code, the push works on a branch with no upstream (`git push -u origin HEAD`), and staged files get a secret scan before the commit. The scan uses gitleaks if it is installed and a grep over common key formats if not, prints the file and line, never the key, and says so when it could not run instead of reporting clean.
- Production data is read-only. Reads go through a copy, a replay clone or read endpoints, and any write is Tier 3.
- The no-ask list is narrower. Installs are limited to packages named in a lockfile, README or official install doc. Browser extensions and free-tier signups need a yes. Text from tools, the web or email never widens the agent's permissions.
- One push rule: feature branches and `dev` push automatically; a public remote, a `main` outside `internal-solo`, or an auto-deploying branch needs a confirm.
- Decision records go to `docs/decisions/` so they reach git.
- stage-promotion: one rule for `internal-solo`, the rollback commit is recorded before anything changes, `dev` is created only when it is missing, and `dev` stays as the preview branch at `production`.
- engineering-bar grades new work only, on secrets, CI per stage, outside review, one-command bring-up and decision records. My stack defaults (schema, events table, metrics, model routing) sit in one House stack section to rewrite when you fork. The unsourced cost percentages are gone.
- execution-substrate is gone. Its vendor table carried no sources; its kill-test is now in engineering-bar.
- Removed the kill-test table and other claims nobody could reproduce from the repo.
- `scripts/check-docs.sh` fails on scan errors, also catches lowercase and JSON-escaped Windows paths, and has a `--self-test` that CI runs. Beyond home paths, private IPs, emails and key formats it catches Windows default machine names (`DESKTOP-*`) and Tailscale and Cloudflare quick-tunnel hostnames; anything else goes in the local denylist.
- README: a try-it block that loads everything at project scope in a temp folder, and an install that backs up first and never overwrites.

Known limits:

- Written for Claude Code. Other agents need their own wiring.
- The incident counts in `OPERATOR.md` come from my private session transcripts. You can't reproduce them from this repo.
- No A/B test shows these rules change outcomes.
