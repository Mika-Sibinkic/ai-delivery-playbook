# Tier-2 decision record

*Loads when: making an architecture call, swapping a vendor or platform, changing pricing logic, reshaping a client deliverable, promoting a repo stage, or when asked why a past choice was made.*

One record per Tier-2 choice. File it at `docs/decisions/YYYY-MM-DD-<slug>.md` in the repo, so it reaches git. Use `.context/decisions/` only if your setup commits `.context/`. Tier 0/1 are graded against the engineering bar but generate no standalone record.

## Rules

- **Every factual claim carries a confidence tag.** `[VERIFIED]` = first-hand observation or official docs URL in the last 90 days. `[LIKELY]` = strong indirect signal but no first-hand verification. `[UNVERIFIED]` = stated assumption pending validation.
- **The corroborating signal is NAMED.** A named practitioner source, official docs URL, RFC number, benchmark report, internal probe result. Vague references ("best practice says...") are disqualifying; say WHOSE practice.
- **The rollback commit SHA is declared**, plus the sequence of steps to revert. If the rollback isn't named, the decision cannot be made.
- Mirrors variant-promotion mechanics: alternative scored, winner promoted, secondary metrics checked for regression, rollback recorded.

**Probe:** all schema fields present? Can a fresh engineer reproduce the verification probe? Is the rollback executable in under an hour? Any "no" = fail.

## Template

The schema is embedded here so this file works on its own as an installed skill. A blank copy also ships in the repo at `templates/decision-record.md`.

```yaml
---
choice: <name>
tier: 2
date: <ISO-8601>
status: proposed | accepted | superseded | rolled-back
alternatives_considered:
  - name: <alt 1>
    reject_reason: <why>
  - name: <alt 2>
    reject_reason: <why>
corroborating_signals:
  - <named source / docs URL / RFC / benchmark URL>
  - ...
confidence:
  primary_claim: VERIFIED | LIKELY | UNVERIFIED
  cost_estimate: VERIFIED | LIKELY | UNVERIFIED
verification_probe: |
  <how an auditor reproduces the decision validity check>
rollback:
  commit_sha: <hash>
  steps:
    - <step 1>
    - <step 2>
superseded_by: <path to newer decision record, if applicable>
---

## Context
<2-4 sentences on why this decision is being made>

## Decision
<the choice, plainly>

## Consequences
<what becomes easier, what becomes harder, what we are now committed to>
```
