---
name: execution-substrate
description: 'Use when choosing where background or long-running work will execute in a NEW project or a NEW pipeline: durable execution, job queues, retries, scheduled work, agent orchestration. Does not apply to existing systems that already work.'
---

# Choosing where background work runs

**Scope: new work only.** An existing pipeline that runs reliably is out of scope for this playbook, whatever the table below says. Working systems stay. Migrating something that works costs real delivery time and buys a property it already delivers in practice.

No vendor fact in this file carries a source link. Treat each one as [UNVERIFIED] and check the vendor's current docs before you rely on it.

## Where does the work run?

| Where the work runs | Use | Why |
|---|---|---|
| Next.js on Vercel | **Vercel Workflow** | no new infrastructure, Apache-2.0, official Postgres world as an exit. Pro tier for anything revenue-bearing. |
| A long-running process you control (container, VPS, mini-PC) | **DBOS Transact** | MIT library, no new server, checkpoints into Postgres you already run |
| Heavy or long-running compute, or the client needs a console | **Inngest** | comes with a hosted console |
| Connector glue, client-readable UI, low-stakes automation | **n8n** | clients can read the flows; licensing is clean for consulting on a client's own instance |

**DBOS recovers only when a process starts.** On pure serverless no process comes back, so nothing triggers recovery. Use it where a process restarts.

**n8n has no automatic crash recovery; you retry by hand from the failed node.** Plan around that where it matters for something new. Do not retrofit it as a grievance against a pipeline that is working.

## Before adopting anything, run the kill-test

Durability claims in vendor docs can fail under `SIGKILL`. Build the pipeline, have every step record one side effect, kill the process mid-step, restart, count. More than expected means work double-fired. Fewer means work was lost.
