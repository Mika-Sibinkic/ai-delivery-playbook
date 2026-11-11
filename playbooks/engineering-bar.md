---
name: engineering-bar
description: Use when reviewing code, handling secrets or API keys, designing a database schema, choosing a hosting, queue or CI platform, or judging whether something is production-ready.
---

# Engineering bar

Five pillars. Every architectural and implementation decision is graded against all five, in every project, unless a project-level `CLAUDE.md` explicitly overrides a pillar.

## 1. Security

Grading question: *"would a security-minded practitioner roast this in public?"*

- **No secrets in source**, including commented-out lines and `.env.example`. Anything resembling a real key triggers an immediate stop-and-rotate.
- **No secrets in the frontend.** Frontend gets a server-issued, scoped, short-lived token or nothing. Direct API-key-in-React is ship-blocking.
- **No direct frontend ↔ database.** Always a first-party backend in between. Database row-level security is defense-in-depth, not the only barrier.
- **Rotate on every personnel change.** Contractor, intern, or vendor leaves → every key they could have touched gets rotated. Verify with the curl-401 check: keep the old key in an env var, never inline, and `curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $OLD_KEY" <auth-check endpoint>` must return 401 or 403.
- **Server-side proxy + env vars only** for third-party API calls. Move keys to env, create a proxy route, rotate the originals.
- **Authentication ≠ Authorization.** Every protected route checks BOTH a valid session AND that the actor is permitted to act on the specific resource. Policy is per resource as well as per route.
- **Spend caps wherever money flows out the door.** Generative-media APIs, LLM providers, payment processors, any infra autoscaler.

**Probe:** can a fresh engineer with read-only repo access find a working credential? If yes, fail.

## 2. Compliance

Every system keeps an audit trail. It answers "who did what when, with what input, producing what output" without a code change.

- **Append-only event log** per service. Every state-changing action writes an event row with `actor`, `action`, `payload_jsonb` (PII scrubbed), `created_at`. Use the same insert-only `events` table with those four columns in every project, so one audit query works everywhere.
- **PII scrubbing at the log boundary**, not the storage boundary. Logs reach stdout, error trackers and third parties already redacted. Emails lower-cased and hash-able for cross-system join without revealing the address.
- **ToS-respecting external signal ingestion.** No closed-source verbatim, no credentials in pulled content, no client-private data leaking back into the system. Ingestion probes auto-reject material containing credentials, internal hostnames, or client-private payloads.
- **Data residency declared, not assumed.** US/EU split called out per service in the env doc.
- **Retention policy declared per data class.** For example: customer uploads until the refund window closes plus a buffer; order metadata for as long as tax law requires; logs for 30 days. Match the contract.

**Probe:** can the system produce a complete audit trail for any single customer order from a SQL query over the events table alone, without grepping logs? If no, fail.

## 3. Build quality

The code embodies the same care the product is sold on. Shortcuts that work locally and fail in production do not ship.

- **Normalized relational DB schema.** UUIDv7 PKs, FK constraints, indexes on every query path, migration files in repo, no ALTER from a dashboard.
- **Typed contracts in repo.** OpenAPI YAML for HTTP, SQL DDL for DB, JSON Schema for events. The contract is the source of truth; code generates from it where possible.
- **CI/CD per the stage table in `stage-promotion`: required from `client-mvp` up.** Where required, every push runs typecheck + lint + test, every merge to main deploys (to staging at `client-mvp`; at `production`, main is what is deployed), and no green = no merge.
- **Version control for everything.** Code, infra (terraform/pulumi), prompts (yes, prompts), workflow-engine flow definitions, env var schemas.
- **Tests at the boundary that matters most.** Unit for pure logic, integration for DB + external APIs, e2e for the critical-path money flow (for example checkout → payment → confirmation email).
- **Code review by a human OR a second LLM with an adversarial prompt.** Self-review doesn't count. Use a code-reviewer agent for solo work.
- **One-command local bring-up.** `docker compose up` or equivalent. New engineer is productive in under 30 minutes.

**Probe:** can a fresh engineer clone the repo, run one command, hit a working dev environment, and deploy a trivial change to staging in under 60 minutes? If no, fail. **Additionally:** does the repo's `CLAUDE.md` declare a `STAGE:`, and does its branching pattern match the declared stage (see `stage-promotion`)? No STAGE declared while the repo has a client-facing URL or a shared collaborator: fail.

## 4. Throughput

Size for the load at year-1 success.

- **Durable execution for background work.** A durable workflow engine or a self-hosted queue-mode worker. Jobs must survive process restart, deploy and crash; cron and fire-and-forget HTTP do not.
- **Retries with exponential backoff + cap.** 3 retries after the first attempt (1s, 4s, 16s), then stop.
- **Idempotency keys on every retryable operation and every external mutation.** Payment provider, send-email, file delivery: each call gets a stable key derived from the order id so retries don't double-charge or double-deliver.
- **Queue depth + latency metrics surfaced.** P50, P95, P99 for every external-call wrapper. Set alert thresholds before launch.
- **No silent failures.** Every retry exhaustion fires an error-tracker event AND writes an `events` row AND triggers the customer-facing failure path.
- **Caching where the workload allows.** Identical generation prompts → cached output. Reduces spend in proportion to the duplicate-request rate.
- **Smart routing.** Cheap model first, escalate on quality miss. Premium tier gets the premium model directly. Match cost to revenue.
- **Reject hobby-plan offerings for production.** Free-tier execution caps, 5-concurrent limits, 10-second function timeouts, no-SLA platforms: all disqualifying for revenue-bearing paths.

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

## Provenance

Draws on ideas from the Google SRE book, AWS Well-Architected, the 12-factor app and Stripe's API docs; no section is cited and no cost was measured. Refresh quarterly, on any major model-vendor release, and after any incident. Bar followed and incident still happened means the bar needs a new rule; bar not followed is a process miss.
