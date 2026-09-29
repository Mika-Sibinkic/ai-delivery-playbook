# Project CLAUDE.md template

> Copy this file to the root of a new repo as `CLAUDE.md`. Keep the `STAGE:` declaration at the very top; every agent session reads it to grade branching, CI, and decision-tier behavior. Full policy in `playbooks/stage-promotion.md` and the Build-quality pillar of `playbooks/engineering-bar.md`. Cap the file at 120 lines; it references `OPERATOR.md` and never restates it.

---

STAGE: internal-solo
# Stage values (default when omitted = internal-solo):
#   internal-solo: only the operator sees/uses it. Push to main direct. CI optional.
#   client-mvp:    first client demo / handoff / shared collaborator. Dev branch + PR + CI required.
#   production:    paying user, public URL with real traffic, or revenue flowing. Feature branch → PR → CI → merge. Main = deployed.
#
# Stage transition is Tier-2 (audit-replayable decision record at .context/decisions/YYYY-MM-DD-stage-promotion.md).

---

# <Project name>

## What this project is

<2-3 sentences on the project's purpose and who uses it>

## Architecture summary

<lead with client-view flow, then 1-2 lines of backend support layer>

## Local bring-up

```bash
<one-command local dev environment>
```

## Stage-specific overrides

<If any engineering-bar pillar is overridden for this project, declare it loudly here with a reason and expiry date. Default-without-override is to apply the full bar. Flag overrides in MEMORY.md as candidates to rethink.>

## Critical paths

<files / modules that warrant extra care during edits>

## External services + secrets

<which services this project depends on, where the env vars live, residency notes>
