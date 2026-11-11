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

<!-- Source of truth: playbooks/decision-record.md. Change the schema there first. -->

## Context

<2-4 sentences on why this decision is being made>

## Decision

<the choice, plainly>

## Consequences

<what becomes easier, what becomes harder, what we are now committed to>
