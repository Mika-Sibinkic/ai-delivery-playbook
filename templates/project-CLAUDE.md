STAGE: <internal-solo | client-mvp | production>

<!--
Copy this file to the root of a new repo as CLAUDE.md, replace the STAGE placeholder with one value and fill in the sections. Keep STAGE on line 1. Cap the file at 120 lines. It references ~/.claude/CLAUDE.md and never restates it.
-->

# PROJECT_NAME

## Stage

- `internal-solo`: only the operator sees or uses it. Push to main direct. CI optional.
- `client-mvp`: first client demo, handoff or shared collaborator. Dev branch + PR + CI required.
- `production`: paying user, public URL with real traffic, or revenue flowing. Feature branch → PR → CI → merge. Main = deployed.

A missing STAGE line, or the placeholder above, counts as unset: `internal-solo` ceremony, but a push to `main` still asks first. Changing the stage is Tier 2: write `docs/decisions/YYYY-MM-DD-stage-promotion.md`. Full policy is in the stage-promotion skill and the build-quality pillar of the engineering-bar skill.

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
