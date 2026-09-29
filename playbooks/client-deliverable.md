# Client deliverable

*Loads when: packaging something that goes to a client — an SOW, scope-change list, handoff packet, status report, proposal, or invoice-adjacent document.*

## Formatting default

The operator's words: "No prettiness. Just 12pt font, Calibri or Arial, and simple bullets with a 1.15 spacing."

- 12pt Calibri or Arial.
- 1.15 line spacing.
- Simple bullets, one level of nesting max.
- Bold for section headers only.
- No color, no cover page, no logos, no decorative rules. Tables only when the data is genuinely tabular.

Deviate only when asked for it in that request.

## Dual output — always both

The operator pastes AND attaches. Produce both from the same content, every time.

1. **Plain text in the response**, formatted to drop straight into an email body. No markdown they'd have to strip — no `**`, no `#`, no backticks.
2. **The file** — PDF or docx of the same content, matching the formatting default above. Generate files with `pandoc` (md → docx/pdf) or `python-docx`. Install what you need; that is inside the autonomy floor. If no format was named, produce docx and note PDF is one step away.

The two must not drift. Generate the file from the exact text you showed them.

## Humanize before it becomes a file

Run every draft through a de-AI editing pass. Strip AI-vocabulary patterns — "delve", "leverage", "robust", "seamless", "it's worth noting", "in today's landscape", em-dash pileups, tricolon padding. A deliverable that reads machine-written costs the operator credibility with the client.

## Content rules

- **Every commitment carries an owner and a date.** "We'll deliver the integration" is not a commitment. "Null Systems delivers the integration by Mar 14" is.
- **No capability claimed that isn't built and VERIFIED.** Not "should work", not "designed to" — you ran it and saw it work. If unverified, cut it or label it as planned scope with a date.
- Outcomes in the client's terms — hours saved, money, headcount — not implementation detail.
- Scope-change lists state what changed, why, and the delta in time and cost. Both directions: additions and removals.
- Assumptions and exclusions written down. What is NOT in scope is as load-bearing as what is.

## Before it goes out

- [ ] Plain text AND file, same content, no drift?
- [ ] 12pt Calibri/Arial, 1.15, simple bullets, nothing decorative?
- [ ] Humanizer pass done?
- [ ] Every commitment has an owner and a date?
- [ ] Every capability claim verified firsthand?
- [ ] Voice matches the operator's writing guide?

Publishing anything client-facing is Tier 3. Show the draft. Don't send it.
