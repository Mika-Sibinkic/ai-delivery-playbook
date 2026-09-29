# AI Delivery Playbook

If you want some of what I would call "secret sauce" regarding how I lead ops and core dev for Null Systems, then this is the right place to be. These are rules and common frameworks that I run AI coding agents under on client deployments (MIND PRIVACY AND CLIENT DATA, SO NO NO NO CLOUD MODEL USE EVEN ON REPO READS/FORKS).

## What this is

I'm a solo applied-AI consultant, so most of my delivery runs through AI coding agents (really only Claude Code at this point because I love it) working in client repositories, against client infrastructure and live + in-use production data. The whole thesis behind this repo is that an LLM under some sort of rules like these ones produces VERIFIED outcomes, and important artifacts along the way like audit trails and git history that second engineer or contractor can absolutely understand and then pick up from.

If you want it to, this repo can load into your agent. Okay Claude, take it away.....


- `OPERATOR.md` holds the global rules every session reads: the unit of work, the output contract, autonomy boundaries, the verification ladder, decision tiers, secrets and git discipline.
- `playbooks/` holds situational playbooks that load on demand when a decision of that kind comes up (an architecture call, a stage promotion, a client deliverable, a session-end commit).
- `templates/` holds the per-project rules file and the decision-record schema.

## Who it is for

- Anyone putting AI agents into real delivery work who wants to see a governance layer that is in use, not one being proposed.
- Teams that need repeatable deployment playbooks and want a concrete example of what "repeatable" means in practice: written down, versioned, measured against transcripts, revised after incidents.
- Me, as a public reference for how I manage AI output.

## The load-bearing ideas

- **Unit of work is a client outcome, not a task.** A named client has an outcome; the agent gets it to production, verifies it, keeps git and docs current, and does not ask permission for the steps in between.
- **Claims carry confidence tags.** `[VERIFIED]` (first-hand or official doc), `[LIKELY]`, `[UNVERIFIED]`. Error notifications and dashboards are claims, not facts.
- **A verification ladder with no skipped rungs.** `TESTED` → `STAGED` → `VERIFIED` → `CONFIRMED`. "All tests pass" is `TESTED`. It is never `VERIFIED`.
- **Decision tiers set who decides.** Tier 0 and 1: do it. Tier 2: write an audit-replayable decision record, then confirm. Tier 3 (money, production data, anything client-facing, anything sent under my name): hard stop.
- **Align, then execute.** Before any long run the agent states its read of the goal, what it will build, and what would make it stop. Then it proceeds without waiting.
- **Working systems stay.** Something running fine in production is not a candidate for improvement. Migrating it costs real delivery time to buy a property it already delivers.
- **Match scope.** A bug fix is not a refactor. A one-shot is not a helper.
- **Stage-gated ceremony.** Every repo declares `internal-solo`, `client-mvp` or `production`, and branching, CI and push rules follow from that line rather than from habit.

## How to adopt it

1. Copy `OPERATOR.md` to wherever your agent reads global instructions (for Claude Code, `~/.claude/CLAUDE.md`). Rewrite the operator-specific lines: who you are, what machines you run, which repos are production.
2. Copy `templates/project-CLAUDE.md` into each repo root as `CLAUDE.md` and set the `STAGE:` line honestly. Unset means `internal-solo`.
3. Install the files in `playbooks/` as on-demand skills, each with a one-line trigger describing when it fires. Do not paste them all into the global file; the global file stays short and the playbooks load when needed.
4. Keep `templates/decision-record.md` at `.context/decisions/` (or `docs/decisions/`) and write one record per Tier-2 choice.
5. Revise after every incident. If the rules were followed and the incident still happened, the rules need a new line. If they were not followed, that is a process miss, and the transcript will show where.

## Where this came from

These rules were not designed up front. They were written and rewritten over months of running Claude Code on real client deployments: a lending client's production system, on-prem boxes on client networks, internal automation, and the business-operations side of a consultancy (proposals, scope changes, handoff packets).

The failure modes named in the rules were measured from session transcripts rather than guessed. The shell-discipline section exists because losing the working directory between commands was the single most frequent error class across months of sessions. The subagent fan-out trigger has an explicit number in it because, without one, a four-part task was serialized every time it was tried. The rule against commented copy-paste blocks exists because a commented block once broke a remote-machine restart halfway through.

The public version strips client and prospect names, hostnames and network details, people's names other than mine, prices, and the dates of specific incidents. The lessons stay; the identifying details do not.

This repo itself was assembled with an AI agent from the private originals, under the same rules it documents.

## Layout

```
README.md
OPERATOR.md
playbooks/
  engineering-bar.md        five pillars every architecture decision is graded against
  decision-record.md        the audit-replayable record for Tier-2 choices
  stage-promotion.md        internal-solo → client-mvp → production, and what changes
  execution-substrate.md    choosing where background work runs, with a measured kill-test
  blocker-walkthrough.md    plain-English guidance form for non-technical handoffs
  client-deliverable.md     packaging anything that goes to a client
  session-commit.md         session-end commit and handoff procedure
templates/
  project-CLAUDE.md         per-repo rules file
  decision-record.md        blank decision record
LICENSE                     MIT
```

## License

MIT; She's all yours.
