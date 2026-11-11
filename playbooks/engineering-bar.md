---
name: engineering-bar
description: Use when reviewing code, handling secrets or API keys, setting up CI, choosing where background work runs, or judging whether new work is ready to ship.
---

# Engineering bar

What an agent checks before it calls new work done. It grades new work only. A system that already runs fine stays as it is (Working systems stay, in `OPERATOR.md`): note the gap, do not fix it unasked. A client repo's own conventions win over anything here.

## 1. Secrets

- **No secrets in source**, including commented-out lines and `.env.example`. Anything that looks like a real key: stop, and have it rotated.
- **No secrets in the frontend.** It gets a server-issued, scoped, short-lived token or nothing. Third-party API calls go through a server-side route that reads env vars.
- **Authentication is not authorization.** Every protected route checks that the session is valid and that the actor may act on that specific resource.
- **Rotate on every personnel change.** When a contractor, intern or vendor leaves, rotate every key they could have touched. Verify with the curl-401 check: keep the old key in an env var, never inline, and `curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $OLD_KEY" <auth-check endpoint>` must return 401 or 403.
- **Spend caps wherever money flows out:** LLM providers, generative-media APIs, payment processors, autoscalers.

**Probe:** can a fresh engineer with read-only repo access find a working credential? If yes, fail.

## 2. CI per stage

CI follows the stage table in `stage-promotion`: required from `client-mvp` up. Where it is required, every push runs typecheck, lint and tests, and no green means no merge.

## 3. Review by someone other than the author

A human or a second LLM with an adversarial prompt reviews the change. Self-review doesn't count.

## 4. One-command bring-up

`docker compose up` or equivalent. The repo's `CLAUDE.md` declares a `STAGE:`, and its branching matches that stage.

**Probe:** can a fresh engineer clone the repo, run one command, get a working dev environment and deploy a trivial change to staging in under 60 minutes? If no, fail. No `STAGE:` while the repo has a client-facing URL or a shared collaborator: fail.

## 5. Decision records

Every Tier-2 decision is replayable from a record at `docs/decisions/YYYY-MM-DD-<slug>.md`. Rules, schema and template: `decision-record`.

**Probe:** pick any Tier-2 decision from the last 6 months. Are all schema fields present? Can a fresh engineer rerun its verification probe? Can the rollback run in under an hour? Any "no" = fail.

## Durable-execution claims: run the kill-test

Before new background work relies on any vendor's durability claim, test it. Build the pipeline, have every step record one side effect, `SIGKILL` the process mid-step, restart, and count. More side effects than expected means work double-fired. Fewer means work was lost.

## House stack (rewrite when you fork)

My defaults for greenfield repos I own. Never impose them on a client repo that has its own conventions.

- Relational schema with UUIDv7 primary keys, FK constraints and migrations in the repo. No schema changes from a dashboard.
- Typed contracts in the repo: OpenAPI for HTTP, SQL DDL for the database, JSON Schema for events.
- One insert-only `events` table (`actor`, `action`, `payload_jsonb` with PII scrubbed, `created_at`), so one audit query works across projects.
- Background work on a durable engine or a queue worker. 3 retries after the first attempt (1s, 4s, 16s), and an idempotency key on every external mutation.
- P50, P95 and P99 latency on every external-call wrapper, with alert thresholds set before launch.
- Cheap model first, escalate on a quality miss.
- No free or hobby tiers on revenue-bearing paths.

## When to override

A project `CLAUDE.md` may override any line here for a stated reason. Required:

1. The override is loud: top of the project `CLAUDE.md`, not buried.
2. The reason is named ("prototype only, no real users, hobby tier acceptable").
3. The expiry date is named (when the override gets reviewed).
4. `MEMORY.md` flags the override as a candidate to rethink.

## Provenance

Draws on ideas from the Google SRE book, AWS Well-Architected, the 12-factor app and Stripe's API docs; no section is cited. Revise after any incident. Bar followed and incident still happened means the bar needs a new line; bar not followed is a process miss.
