# AI Delivery Playbook

Global rules, on-demand skills and templates for Claude Code, for anyone running AI coding agents on real client work.

These rules and frameworks are derived from the ones I run AI coding agents under on client deployments. The repo holds no client data or credentials. `scripts/check-docs.sh` scans it for home paths, private IPs, emails, common key formats, Windows default machine names (`DESKTOP-*`), and Tailscale and Cloudflare quick-tunnel hostnames.

## What this is

I run Null Systems, an applied-AI consultancy. Most of my delivery runs through AI coding agents (really only Claude Code at this point because I love it), working in client repositories and against client infrastructure.

The thesis: an agent under these rules leaves work verified on real infrastructure, plus an audit trail and git history a second engineer or contractor can pick up. Nothing has measured that yet (see Limits).

Read `OPERATOR.md` before you load this repo into your agent: it lets the agent push feature branches, install packages and restart local services without asking.

## Try it in a scratch repo

Clone it once. Each block below starts from the folder where you ran `git clone`.

```bash
git clone https://github.com/Mika-Sibinkic/ai-delivery-playbook.git
```

This block leaves your global config alone. Everything loads at project scope in a new temp folder. Approve the external import when Claude Code asks.

```bash
cd ai-delivery-playbook
p="$PWD"
cd "$(mktemp -d)"
git init -q
echo "@$p/OPERATOR.md" > CLAUDE.md
for f in "$p"/playbooks/*.md; do mkdir -p ".claude/skills/$(basename "$f" .md)" && cp "$f" ".claude/skills/$(basename "$f" .md)/SKILL.md"; done
claude
```

A first prompt to try:

```text
Give me your alignment preamble for adding a hello-world script with one test, then build it and report which rung of the verification ladder it reached.
```

## Core ideas

- **A confidence tag and a ladder rung are separate grades.** A tag (`[VERIFIED]`, `[LIKELY]`, `[UNVERIFIED]`) grades how sure a claim is. A rung (`TESTED` → `STAGED` → `VERIFIED` → `CONFIRMED`) grades how far the system got. So `[VERIFIED] … is STAGED` is a sure claim about work nobody has yet seen working against real infra. ([Output contract](OPERATOR.md#output-contract), [Verification ladder](OPERATOR.md#verification-ladder))
- **Decision tiers set who decides,** from "do it" to hard stop. ([Decision tiers](OPERATOR.md#decision-tiers))
- **The `STAGE:` line sets branch and CI ceremony.** ([Git and worktrees](OPERATOR.md#git-and-worktrees), `playbooks/stage-promotion.md`)
- **Production data is read-only, and client data reaches a hosted model only with the client's written approval.** The agent reads production through copies, replay clones or read endpoints, and any write is a hard stop. ([Secrets and client data](OPERATOR.md#secrets-and-client-data))

The rest is in `OPERATOR.md`.

## How to adopt it

1. Copy `OPERATOR.md` to `~/.claude/OPERATOR.md` and import it from your global `~/.claude/CLAUDE.md`, or merge it in by hand:

   ```bash
   cd ai-delivery-playbook
   mkdir -p ~/.claude
   touch ~/.claude/CLAUDE.md
   [ -e ~/.claude/CLAUDE.md.bak ] || cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak
   [ -e ~/.claude/OPERATOR.md ] || cp OPERATOR.md ~/.claude/OPERATOR.md
   grep -qxF "@$HOME/.claude/OPERATOR.md" ~/.claude/CLAUDE.md || echo "@$HOME/.claude/OPERATOR.md" >> ~/.claude/CLAUDE.md
   ```

   It is safe to rerun: the first backup and your copy are kept, and the import is added once. The copy is yours to edit. Rewrite its **About the operator** block before you rely on it.
2. Copy `templates/project-CLAUDE.md` into each repo root as `CLAUDE.md` and replace the `STAGE:` placeholder with the repo's stage. Until you do, it counts as unset: `internal-solo` ceremony, but a push to `main` asks first. If the repo already has a `CLAUDE.md`, merge the two.
3. Install the playbooks as on-demand skills. The global file stays short and the playbooks load when a decision of that kind comes up. A skill you already have under the same name is left alone.

   ```bash
   cd ai-delivery-playbook
   for f in playbooks/*.md; do
     d="$HOME/.claude/skills/$(basename "$f" .md)"
     [ -e "$d" ] || { mkdir -p "$d" && cp "$f" "$d/SKILL.md"; }
   done
   ls ~/.claude/skills/*/SKILL.md
   ```

4. For each Tier-2 choice, copy `templates/decision-record.md` to `docs/decisions/YYYY-MM-DD-<slug>.md` and fill it in.
5. Revise after every incident. If the rules were followed and the incident still happened, the rules need a new line. If they were not followed, that is a process miss, and the transcript will show where.

Steps 1 and 3 never overwrite your copies. To take an update, `git pull` the clone and merge the changes into `~/.claude` by hand.

## Limits

- Written for Claude Code. `CLAUDE.md`, `@` imports and skills folders are Claude Code features; other agents need their own wiring.
- `OPERATOR.md` is my set of defaults. Rewrite its About the operator block before you rely on it.
- The fan-out rule spends more tokens per task. On API billing, raise the trigger or remove the section.
- The counts in `OPERATOR.md` come from my private session transcripts. Nothing in this repo lets you reproduce them.
- No A/B test shows these rules change outcomes.
- No recorded agent run ships here. The try-it block above is how you see one.

## Where this came from

I wrote and rewrote these rules over months of running Claude Code on real client deployments: a lending client's production system, on-prem boxes on client networks, internal automation, and the business-operations side of a consultancy (proposals, scope changes, handoff packets).

The failure modes named in the rules come from my session transcripts. The shell-discipline section exists because losing the working directory between commands was the single most frequent error class across months of sessions. The subagent fan-out trigger has an explicit number in it because, without one, a four-part task was serialized every time it was tried. The rule against commented copy-paste blocks exists because a commented block once broke a remote-machine restart halfway through.

The public version strips client and prospect names, hostnames and network details, people's names other than mine, prices, and the dates of specific incidents. A few rules were tightened for general use, so the set here does not match my private one line for line.

This repo itself was assembled with an AI agent from the private originals, under the private versions of these rules.

## Layout

```
README.md
OPERATOR.md                 global rules every session reads
playbooks/
  engineering-bar.md        what new work must pass before it is called done
  decision-record.md        the audit-replayable record for Tier-2 choices
  stage-promotion.md        internal-solo → client-mvp → production, and what changes
  blocker-walkthrough.md    plain-English guidance form for non-technical handoffs
  client-deliverable.md     packaging anything that goes to a client
  session-commit.md         session-end commit and handoff procedure
templates/
  project-CLAUDE.md         per-repo rules file
  decision-record.md        blank decision record
scripts/
  check-docs.sh             the docs and leak check CI runs
.github/workflows/
  docs.yml                  runs scripts/check-docs.sh and its self-test
LICENSE                     MIT
```

## Contributing

Issues are welcome. I won't merge rules that only fit one operator's setup.

Before a PR, run the same check CI runs. It needs bash and a git checkout; a ZIP download has no `.git`, so it exits 2.

```bash
scripts/check-docs.sh
scripts/check-docs.sh --self-test
```

The first prints `check-docs: ok` and exits 0, or names each file that failed (with the line, except for frontmatter) and exits 1. The second plants one sample per pattern and fails if any sample gets through. The scan catches only the shapes listed at the top of this README. To also catch client names, other hostnames or person names without committing them, list them one per line in `.git/info/check-docs-denylist`.

## License

MIT; she's all yours.
