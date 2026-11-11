---
name: engineering-bar
description: Use when reviewing code, handling secrets or API keys, designing a database schema, choosing a hosting, queue or CI platform, or judging whether something is production-ready.
---

# Engineering bar

Five pillars. Every architectural and implementation decision is graded against all five, in every project, unless a project-level `CLAUDE.md` explicitly overrides a pillar.

## 1. Security

Grading question: *"would a security-minded practitioner roast this in public?"*

- **No secrets in source.** Ever. Even commented out. Even in `.env.example`. Anything resembling a real key triggers an immediate stop-and-rotate.
- **No secrets in the frontend.** Frontend gets a server-issued, scoped, short-lived token or nothing. Direct API-key-in-React is ship-blocking.
- **No direct frontend ↔ database.** Always a first-party backend in between. Database row-level security is defense-in-depth, not the only barrier.
- **Rotate on every personnel change.** Contractor, intern, or vendor leaves → every key they could have touched gets rotated. Verify with the curl-401 check: keep the old key in an env var, never inline, and `curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $OLD_KEY" <auth-check endpoint>` must return 401 or 403.
- **Server-side proxy + env vars only** for third-party API calls. Move keys to env, create a proxy route, rotate the originals.
- **Authentication ≠ Authorization.** Every protected route checks BOTH a valid session AND that the actor is permitted to act on the specific resource. Policy is per resource as well as per route.
- **Spend caps wherever money flows out the door.** Generative-media APIs, LLM providers, payment processors, any infra autoscaler. Even a tiny cap is better than no cap.

**Probe:** can a fresh engineer with read-only repo access find a working credential? If yes, fail.

## 2. Compliance

Audit trails are not optional. The system answers "who did what when, with what input, producing what output" without a code change.

- **Append-only event log** per service. Every state-changing action writes an event row with `actor`, `action`, `payload_jsonb` (PII scrubbed), `created_at`. Use the same insert-only `events` table with those four columns in every project, so one audit query works everywhere.
- **PII scrubbing at the log boundary**, not the storage boundary. Logs reach stdout, error trackers and third parties already redacted. Emails lower-cased and hash-able for cross-system join without revealing the address.
- **ToS-respecting external signal ingestion.** No closed-source verbatim, no credentials in pulled content, no client-private data leaking back into the system. Ingestion probes auto-reject material containing credentials, internal hostnames, or client-private payloads.
- **Data residency declared, not assumed.** US/EU split called out per service in the env doc.
- **Retention policy declared per data class.** For example: customer uploads until the refund window closes plus a buffer; order metadata for as long as tax law requires; logs for 30 days. Match the contract.

**Probe:** can the system produce a complete audit trail for any single customer order from a SQL query over the events table alone, without grepping logs? If no, fail.

## 3. Build quality

The code embodies the same care the product is sold on. Vibe-coded shortcuts that work locally and crater in production are the enemy.

- **Normalized relational DB schema.** UUIDv7 PKs, FK constraints, indexes on every query path, migration files in repo, no ALTER from a dashboard.
- **Typed contracts in repo.** OpenAPI YAML for HTTP, SQL DDL for DB, JSON Schema for events. The contract is the source of truth; code generates from it where possible.
- **CI/CD per the stage table in `stage-promotion`: required from `client-mvp` up.** Where required, every push runs typecheck + lint + test, every merge to main deploys to staging, and no green = no merge.
- **Version control for everything.** Code, infra (terraform/pulumi), prompts (yes, prompts), workflow-engine flow definitions, env var schemas.
- **Tests at the boundary that matters most.** Unit for pure logic, integration for DB + external APIs, e2e for the critical-path money flow (for example payment → upload → render → deliver).
- **Code review by a human OR a second LLM with an adversarial prompt.** Self-review doesn't count. Use a code-reviewer agent for solo work.
- **One-command local bring-up.** `docker compose up` or equivalent. New engineer is productive in under 30 minutes.

**Probe:** can a fresh engineer clone the repo, run one command, hit a working dev environment, and deploy a trivial change to staging in under 60 minutes? If no, fail. **Additionally:** does the repo's `CLAUDE.md` declare a `STAGE:`, and does its branching pattern match the declared stage (see `stage-promotion`)? No STAGE declared while the repo has a client-facing URL or a shared collaborator: fail.

## 4. Throughput

Designed for the load it'll see at year-1 success, not day 1. Hobby-tier infrastructure is not allowed for revenue-generating services. A business on a hobby plan is stuck the moment it needs to process anything real.

- **Durable execution for background work.** A durable workflow engine or a self-hosted queue-mode worker. Not a starter-tier automation tool, not naked cron, not fire-and-forget HTTP. Jobs survive process restart, deploy, crash.
- **Retries with exponential backoff + cap.** 3 retries after the first attempt (1s, 4s, 16s), then stop. Idempotency keys on every retryable operation.
- **Idempotency keys on every external mutation.** Payment provider, send-email, render-video: every external call gets a stable key derived from the order id so retries don't double-charge or double-deliver.
- **Queue depth + latency metrics surfaced.** P50, P95, P99 for every external-call wrapper. Alert thresholds set before launch, not after the outage.
- **No silent failures.** Every retry exhaustion fires an error-tracker event AND writes an `events` row AND triggers the customer-facing failure path.
- **Caching where the workload allows.** Identical generation prompts → cached output. Identical template renders → cached video. Reduces spend in proportion to the duplicate-request rate.
- **Smart routing.** Cheap model first, escalate on quality miss. Premium tier gets the premium model directly. Match cost to revenue.
- **Reject hobby-plan offerings for production.** Free-tier execution caps, 5-concurrent limits, 10-second function timeouts, no-SLA platforms: all disqualifying for revenue-bearing paths. Free tier is for demos and side projects.

**Probe:** at projected year-1 peak concurrency, does any single platform's free/starter tier have a hard cap below 5× projected load? If yes, that platform fails throughput for that workload.

## 5. Audit-replayable decisions

Every Tier-2 decision is replayable from a record in the repo at `docs/decisions/YYYY-MM-DD-<slug>.md`. Rules, schema and template: `decision-record`.

**Probe:** pick any Tier-2 decision from the last 6 months. Are all schema fields present? Can a fresh engineer reproduce the verification probe? Is the rollback executable in under an hour? Any "no" = fail.

## When to override

A project-level `CLAUDE.md` may override any pillar for a stated reason. Required:

1. The override is loud: top of the project `CLAUDE.md`, not buried.
2. The reason is named ("prototype only, no real users, hobby tier acceptable").
3. The expiry date is named (when the override gets reviewed).
4. `MEMORY.md` flags the override as a candidate to rethink.

Default-without-override is to apply the bar.

## Provenance

Codified from a curated feed of practitioner signals (a few dozen records, roughly ten high-conviction), cross-referenced against the Google SRE book, AWS Well-Architected, the 12-factor app, and Stripe's API design principles. Cost: a few minutes per Tier-2 record, one paid tier per service above hobby, about half an hour of one-time CI setup. Refresh quarterly, on any major model-vendor release, and after any incident. Bar followed and incident still happened means the bar needs a new rule; bar not followed is a process miss.
