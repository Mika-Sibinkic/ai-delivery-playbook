---
name: stage-promotion
description: Use when a client demo is scheduled, a second human or contractor joins a project, a repo starts taking real users or revenue, or before pushing directly to main.
---

# Stage-gated branching policy

Branching workflow is graded by repo stage, not applied uniformly. A solo scratch repo does not need feature branches and PRs. A repo with paying users needs both. Every project `CLAUDE.md` declares a stage at the top. The allowed values are `internal-solo`, `client-mvp` and `production`:

```
STAGE: internal-solo
```

Default when unset = `internal-solo` (assumes nothing external until told otherwise). Pushing `main` without asking still needs the line written down; see the push rule in `OPERATOR.md`.

## Stages

| Stage | Trigger | Branching rule | CI gate |
|-------|---------|----------------|---------|
| `internal-solo` | Only the operator sees/uses it. No client demo, no external user, no shared infra. | Push to `main` direct; a repo may declare `dev` canonical in its own `CLAUDE.md`, and that line wins. Branch only for risky or throwaway experiments. | Optional. Lint/typecheck nice-to-have. |
| `client-mvp` | Any of: first client demo scheduled, first second human will touch it, MVP handoff packet being prepared, shared workspace with a forward-deployed engineer or contractor. | Dev branch required for non-trivial changes. PR-to-main reviewed by a human or a code-reviewer agent before merge. | Required. Lint + typecheck + tests must pass before merge to main. |
| `production` | Paying user, public URL with real traffic, or revenue flowing through it. | Feature branches → PR → review → CI green → merge to main. Main = deployed. No direct push. | Required + deploy gate. CI failure blocks merge. Hotfix branches off main. |

## Promotion

Any forward step is a **Tier-2 decision** and triggers an audit-replayable decision record. The promoting agent:

1. Records the rollback commit (`git rev-parse HEAD` before any change) and writes `docs/decisions/YYYY-MM-DD-stage-promotion.md` with it, using the schema in `decision-record`
2. Creates `dev` off current `main` (`git branch dev && git push -u origin dev`)
3. Wires minimum CI (lint + typecheck + test) if not already present
4. Updates project `CLAUDE.md` `STAGE:` line

## Demotion

`client-mvp` → `internal-solo` is also Tier 2. Only allowed if client engagement is formally closed and all client-facing artifacts archived.

## Pre-push grading hook

Before any `git push origin main` on a workspace whose declared (or defaulted) stage is `client-mvp` or `production`, stop and route the change through the stage's branching rule. Direct push to main is a failure mode at those stages.
