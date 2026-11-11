# AI Delivery Playbook

Global rules, on-demand skills and templates for Claude Code, for anyone running AI coding agents on real client work.

If you want some of what I would call "secret sauce" regarding how I lead ops and core dev for Null Systems, then this is the right place to be. These are rules and common frameworks that I run AI coding agents under on client deployments. The repo holds no client data and is safe to load into any agent; in client work, client data and message bodies stay off hosted models unless the client has approved it.

## What this is

I'm an applied-AI consultant and part of a team, so most of my delivery runs through AI coding agents (really only Claude Code at this point because I love it) working in client repositories, against client infrastructure and live + in-use production data. The whole thesis behind this repo is that an LLM under some sort of rules like these ones produces VERIFIED outcomes, and important artifacts along the way like audit trails and git history that a second engineer or contractor can absolutely understand and then pick up from.

If you want it to, this repo can load into your agent.

## Who it is for

- Anyone putting AI agents into real delivery work who wants to see a governance layer that is in use.
- Teams that need repeatable deployment playbooks and want a concrete example of what "repeatable" means in practice: written down, and rewritten when an incident showed a gap.
- Me, as a public reference for how I manage AI output.

## The load-bearing ideas

- **Unit of work is a client outcome.** Get it to production, verify it, keep git and docs current. (top of `OPERATOR.md`)
- **Claims carry confidence tags:** `[VERIFIED]`, `[LIKELY]`, `[UNVERIFIED]`. ([Output contract](OPERATOR.md#output-contract))
- **No skipped rungs:** `TESTED` → `STAGED` → `VERIFIED` → `CONFIRMED`. ([Verification ladder](OPERATOR.md#verification-ladder))
- **Decision tiers set who decides,** from "do it" to hard stop. ([Decision tiers](OPERATOR.md#decision-tiers))
- **Align, then execute:** state the read, the build and the stop condition, then go. ([Autonomy](OPERATOR.md#autonomy-align-then-execute))
- **Working systems stay, and scope matches the ask.** ([Output contract](OPERATOR.md#output-contract))
- **The `STAGE:` line sets branch and CI ceremony.** ([Git and worktrees](OPERATOR.md#git-and-worktrees), `playbooks/stage-promotion.md`)

## What it looks like

Synthetic example, written for this README.

```text
Read: add a CSV export to the invoices page · Building: one endpoint, one button, one test · Stopping if: the client wants a scheduled export

[VERIFIED] CSV export is STAGED: deployed to preview, and the downloaded file has the expected rows. Not VERIFIED until it is seen working on production.
```

## How to adopt it

Clone it once. Each block below starts from the folder you cloned into.

```bash
git clone https://github.com/Mika-Sibinkic/ai-delivery-playbook.git
```

1. Load `OPERATOR.md` into your global `~/.claude/CLAUDE.md`. Either merge it in by hand, or back up your file and import it:

   ```bash
   cd ai-delivery-playbook
   mkdir -p ~/.claude
   touch ~/.claude/CLAUDE.md
   cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak
   echo "@$PWD/OPERATOR.md" >> ~/.claude/CLAUDE.md
   ```

   The import points at the clone, so leave it where it is. Then rewrite the parts that describe me: the opening paragraph (who the operator is, the unit of work, the machines), **Git and worktrees**, **Output aimed at the operator's machine** and **Documents and client communication**.
2. Copy `templates/project-CLAUDE.md` into each repo root as `CLAUDE.md` and set the `STAGE:` line honestly. Unset means `internal-solo`. If the repo already has a `CLAUDE.md`, merge the two.
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

### Try it in a scratch repo

This leaves your global config alone. Everything loads at project scope in a new temp folder. Approve the external import when Claude Code asks.

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

## Limits

- Written for Claude Code. `CLAUDE.md`, `@` imports and skills folders are Claude Code features; other agents need their own wiring.
- `OPERATOR.md` is my set of defaults. Rewrite the operator-specific sections before you rely on it.
- The counts in `OPERATOR.md` come from my private session transcripts. Nothing in this repo lets you reproduce them.
- The kill-test in `playbooks/execution-substrate.md` is one run, and its code and output are not published.
- No A/B test shows these rules change outcomes.

## Where this came from

I wrote and rewrote these rules over months of running Claude Code on real client deployments: a lending client's production system, on-prem boxes on client networks, internal automation, and the business-operations side of a consultancy (proposals, scope changes, handoff packets).

The failure modes named in the rules come from my session transcripts. The shell-discipline section exists because losing the working directory between commands was the single most frequent error class across months of sessions. The subagent fan-out trigger has an explicit number in it because, without one, a four-part task was serialized every time it was tried. The rule against commented copy-paste blocks exists because a commented block once broke a remote-machine restart halfway through.

The public version strips client and prospect names, hostnames and network details, people's names other than mine, prices, and the dates of specific incidents.

This repo itself was assembled with an AI agent from the private originals, under the same rules it documents.

## Layout

```
README.md
OPERATOR.md                 global rules every session reads
playbooks/
  engineering-bar.md        the pillars every architecture decision is graded against
  decision-record.md        the audit-replayable record for Tier-2 choices
  stage-promotion.md        internal-solo → client-mvp → production, and what changes
  execution-substrate.md    choosing where background work runs
  blocker-walkthrough.md    plain-English guidance form for non-technical handoffs
  client-deliverable.md     packaging anything that goes to a client
  session-commit.md         session-end commit and handoff procedure
templates/
  project-CLAUDE.md         per-repo rules file
  decision-record.md        blank decision record
scripts/
  check-docs.sh             paths resolve, playbooks load as skills, nothing private ships
.github/workflows/
  docs.yml                  runs scripts/check-docs.sh
LICENSE                     MIT
```

## Contributing

Issues are welcome. I won't merge rules that only fit one operator's setup.

Before a PR, run the same check CI runs. It needs only bash and git:

```bash
scripts/check-docs.sh
```

It prints `check-docs: ok` and exits 0, or names each file and line that failed and exits 1.

## License

MIT; she's all yours.
