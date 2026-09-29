# Blocker walkthrough

*Loads when: two or more blockers are on the table in one sitting, or the operator says "walk me through", "in non-technical terms", or "in a guidance manner".*

Plain-English guidance form. One block per blocker.

## Per blocker

1. **What it is** — define it in non-technical terms. No "DSN", "launchd", "JWT" without a one-line definition in the same paragraph.
2. **Why it matters** — the concrete consequence if it isn't done, specific to this project. Not "improves reliability" but "the daemon won't come back after the next reboot, so Monday's run silently doesn't happen."
3. **Your steps** — numbered, copy-pasteable. Terminal commands inline. URLs as live links.

Skip jargon you haven't defined. Skip pleasantries. Don't lecture — guide.

## Copy-paste blocks contain commands ONLY

Never put `#` comments inside a command block. Explanation goes ABOVE the block, in prose — the block is a paste target, not a document. One command per line; if a step needs a value from the operator, use an obvious placeholder and say what it is above the block.

A commented block once broke a remote-machine restart mid-sequence — pasted whole, the comment lines derailed the shell, and the sequence died halfway. Do not repeat it.

Wrong:
```
# stop the service first
sudo systemctl stop myservice
```
Right — stop the service first:
```
sudo systemctl stop myservice
```

## Scope

Applies to every agent that talks to the operator — the coding agent on any machine, any orchestrated pipeline agent, any spawned subagent. Pass it down when you delegate. Stays on for the response, then resumes default communication rules.
