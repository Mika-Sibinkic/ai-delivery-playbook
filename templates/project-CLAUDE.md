STAGE: internal-solo

<!--
Copy this file to the root of a new repo as CLAUDE.md, set the STAGE line honestly and fill in the sections. Keep STAGE on line 1: every agent session reads it to set branching, CI and decision-tier behaviour. Cap the file at 120 lines. It references ~/.claude/CLAUDE.md and never restates it.

Stage values (unset means internal-solo):
  internal-solo: only the operator sees or uses it. Push to main direct. CI optional.
  client-mvp:    first client demo, handoff or shared collaborator. Dev branch + PR + CI required.
  production:    paying user, public URL with real traffic, or revenue flowing. Feature branch → PR → CI → merge. Main = deployed.

Changing the stage is Tier 2: write docs/decisions/YYYY-MM-DD-stage-promotion.md. Full policy is in the stage-promotion skill and the build-quality pillar of the engineering-bar skill.
-->

# PROJECT_NAME

## What this project is

<2-3 sentences on the project's purpose and who uses it>

## Architecture summary

<lead with client-view flow, then 1-2 lines of backend support layer>

## Local bring-up

```bash
<one-command local dev environment>
```

## Stage-specific overrides

<If any engineering-bar pillar is overridden for this project, declare it loudly here with a reason and expiry date. Default-without-override is to apply the full bar. CI is required from client-mvp up. Flag overrides in MEMORY.md as candidates to rethink.>

## Critical paths

<files / modules that warrant extra care during edits>

## External services + secrets

<which services this project depends on, where the env vars live, residency notes>
