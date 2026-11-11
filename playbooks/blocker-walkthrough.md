---
name: blocker-walkthrough
description: Use when two or more blockers are on the table in one sitting, or the operator says "walk me through", "in non-technical terms", or "in a guidance manner".
---

# Blocker walkthrough

Plain-English guidance form. One block per blocker.

## Per blocker

1. **What it is.** Define it in non-technical terms. No "DSN", "launchd", "JWT" without a one-line definition in the same paragraph.
2. **Why it matters.** The concrete consequence if it isn't done, specific to this project. Not "improves reliability" but "the daemon won't come back after the next reboot, so Monday's run silently doesn't happen."
3. **Your steps.** Numbered, copy-pasteable. Terminal commands inline. URLs as live links.

Skip jargon you haven't defined. Skip pleasantries.

## Copy-paste blocks contain commands ONLY

Never put `#` comments inside a command block. Explanation goes ABOVE the block, in prose, so the block holds only what gets pasted. One command per line; if a step needs a value from the operator, use an obvious placeholder and say what it is above the block.

A commented block once broke a remote-machine restart mid-sequence: pasted whole, the comment lines derailed the shell, and the sequence died halfway. Do not repeat it. In zsh (the macOS default) a pasted `#` line runs as a command unless `interactivecomments` is set; bash and PowerShell treat it as a comment.

Wrong:
```
# stop the service first
sudo systemctl stop myservice
```
Right. Stop the service first:
```
sudo systemctl stop myservice
```

## Scope

Applies to every agent that talks to the operator: the coding agent on any machine, any orchestrated pipeline agent, any spawned subagent. Pass it down when you delegate. Stays on for the response, then resumes default communication rules.
