---
name: execution-substrate
description: 'Use when choosing where background or long-running work will execute in a NEW project or a NEW pipeline: durable execution, job queues, retries, scheduled work, agent orchestration. Does not apply to existing systems that already work.'
---

# Choosing an execution substrate

**Scope: new work only.** An existing pipeline that runs reliably is out of scope for this playbook, regardless of what the table below says. Working systems stay. Migrating something that works costs real delivery time and buys a property it is already delivering in practice.

No vendor fact in this file carries a source link. Treat each one as [UNVERIFIED] and check the vendor's current docs before you rely on it.

## The question that decides it

**Is there a long-running process that comes back after a crash?**

| Where the work runs | Use | Why |
|---|---|---|
| Next.js on Vercel | **Vercel Workflow** | zero new infrastructure, Apache-2.0, generous free event volume, official Postgres world as an exit. Pro tier for anything revenue-bearing; the hobby tier's 1-day retention isn't a production posture. |
| A long-running process you control (container, VPS, mini-PC) | **DBOS Transact** | MIT library, no new server, checkpoints into Postgres you already run. Zero marginal cost per project. |
| Heavy or long-running compute, or the client needs a console | **Inngest** | comes with a hosted console; one flat monthly plan amortizes across the whole client book |
| Connector glue, client-readable UI, low-stakes automation | **n8n** | genuinely good at this; licensing is clean for consulting on a client's own instance |

**DBOS recovers only when a process starts.** On pure serverless no process comes back, so nothing triggers recovery. Use it where a process restarts.

**n8n has no automatic crash recovery; you retry by hand from the failed node.** Plan around that where it matters for something new. Do not retrofit it as a grievance against a pipeline that is working.

## Before adopting anything, run the kill-test

Durability claims in vendor docs can fail under `SIGKILL`. Build the pipeline, have every step record one side effect, kill the process mid-step, restart, count. More than expected means work double-fired. Fewer means work was lost.

## Setup burden: the real cost for a one-person shop

- DBOS: install, a Postgres URL, run. No server. (Gotcha [UNVERIFIED], version not recorded: it ignored the port in the URL passed to `setConfig` and defaulted to 5432.)
- Inngest: worker + HTTP endpoint + separate dev server + app registration. v4 moved triggers into the first argument of `createFunction`; v3 code throws on import.
- Vercel Workflow: not runnable standalone. `'use workflow'` / `'use step'` compile via SWC into two execution contexts, so it needs a framework or bundler plugin. Fine inside Next, not a drop-in for a worker.

## Ruled out, with reasons

- Temporal: the most correct engine available and the wrong shape for one person. No free tier, a paid floor sized for teams, and its own production checklist asks for "trained, experienced administrators" and warns shard count is immutable after build.
- Hatchet: free jumps straight to a mid-tier monthly plan with nothing between.
- Windmill: solves the internal-tools problem by handing you another server to own.
- AutoGen / AG2: AutoGen is officially in maintenance mode, frozen since Sept 2025. AG2 has announced it will move its own current framework to maintenance [UNVERIFIED]. Start nothing here.
- Cloudflare `@cloudflare/computer`: as of v0.1.0 (Aug 2026) its README said "NOT suitable for production"; from v0.6.0 (Oct 2026) the README calls the core suitable for production and marks parts such as `ContainerBackend` experimental. Its README describes a SQLite-backed virtual filesystem with pluggable command execution; it is not a workflow engine. Essentially no independent scrutiny yet [UNVERIFIED].
- Cloudflare OS (Aug 2026): an agentic workspace, not an orchestrator. Apache-2.0 and genuinely self-hostable, but early access with self-host docs still pending.
- Cloudflare Workflows: real, GA since April 2025 [UNVERIFIED], good. Adopting it means moving onto Workers, which is a bigger migration than the problem usually justifies.
