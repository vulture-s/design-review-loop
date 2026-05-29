---
name: design-review-loop
description: "Activate when the user wants the CLI agent to hand visual/design work to a web-sandboxed design agent and bring the result back. Triggers: handover to claude design, design review loop, visual audit checklist, follow-up modification list, design deliverable return, mock screens, paradigm decision, hand current state to design, design round-trip, ingest design output, dispatch to implementer."
allowedTools: [Read, Write, Edit, Bash, Glob, Grep]
---

# Design Review Loop — CLI ⇄ Web Design Agent Round-Trip

> A CLI coding agent can grep / cross-file / repo-wide refactor, but **cannot make
> visual judgements** (no eyes). Mock screens, visual audits, and layout/UX
> paradigm decisions go to a **design agent that has visual ability but cannot read
> your local disk**. This skill makes that round-trip repeatable.

---

## Core constraint — why this skill exists

The design surface is a **sandbox**: it cannot read your disk, it **rejects `.zip`**,
and it accepts only a **flat** list of uploaded files (see
`references/web-sandbox-limits.md`).

Consequences you'd otherwise rediscover every time:

- A **path is useless** to it; a **zip is useless** to it — the user must
  **drag loose files** into the uploader.
- So the outbound step must run `stage-handover.sh` to **flatten brief +
  screenshots to the desktop**.
- The deliverables it produces live **inside its sandbox** → the user must
  **download them back** before the CLI agent can see them.

Internalize this and you stop wasting a round on "it says it can't find the file."

---

## 5-Stage Flow

```
Stage 1 OUTBOUND   gather state + evidence → flatten to desktop for upload
   ▼
Stage 2 DESIGN     user uploads → design agent audits + rebuilds → returns deliverables
   ▼
Stage 3 RETURN     user downloads → ingest into repo → verify vs contract → triage
   ▼
Stage 4 DISPATCH   prioritize by severity → hand critical fixes to implementer first
   ▼
Stage 5 CLOSEOUT   post-deploy verify against ground truth → log
```

### Stage 1 — OUTBOUND (CLI agent, local)

1. **Snapshot current state**: what works / broken / partial. Ground visual claims
   in **quantified evidence** (computed styles, element geometry via a browser
   automation tool) + screenshots — not "looks right."
2. **Write the handover package**: a master `HANDOVER-PACKAGE.md` (the entry point)
   + one or more briefs (problem / regression / report). Template:
   `templates/handover-package.template.md`.
3. **Define the deliverable contract**: spell out exactly what the design agent
   **must return** — see `references/deliverable-contract.md`. No contract = scattered
   returns and extra rounds.
4. **Flatten to the desktop**:
   ```bash
   bash stage-handover.sh <source-dir> <name> --zip
   ```
   → loose files (drag to upload) + `00-READ-FIRST-bundle.md` (copy-paste) + a zip
   (transfer/backup only — **do not upload the zip**).
5. For brand/identity-sensitive work, also pack a short brand-guard note so the
   design agent doesn't misread what it's designing for.

### Stage 2 — DESIGN (web sandbox, CLI agent not present)

User uploads the loose files + pastes the bundle + a one-line instruction:
"You are the design agent — return the deliverables listed in the contract."
First turn, run a **brand-guard self-test**: without reading the files, ask the agent
to state what the product/brand is. Wrong answer → have it re-read before starting.

### Stage 3 — RETURN / INGEST (CLI agent, local)

1. User **downloads the deliverables back into the repo** (a dedicated
   `.../<feature>-design-return/` or alongside the outbound audit dir).
2. **Verify completeness** against the contract, item by item. Missing item →
   send back to design; do not fill it in from imagination.
3. **Severity triage**: sort the modification list by 🔴/🟡/⚪ → a prioritized
   implementation list.
4. Operator review against your own decision framework.
5. Return structure spec: `references/return-package-structure.md`.

### Stage 4 — DISPATCH (CLI agent → implementer)

1. **Critical fixes first**: a hot-fix that doesn't need design (e.g. a paste-able
   diff for a regression) can ship independently and early.
2. Write a handoff to the implementer with an environment preamble (assume nothing
   about their local setup).
3. **Split PRs**: ship the critical hot-fix and the feature rebuild as **separate
   PRs** for rollback granularity.

### Stage 5 — CLOSEOUT

- Post-deploy verify by measuring **ground truth** (re-measure computed values; never
  declare done on "should work").
- Write the dev log; reconcile your task list.
- Append a closeout note to the audit doc (what was fixed / skipped / why).

---

## When NOT to use

- ✗ Non-visual surface handoff → a plain packing skill (no return leg)
- ✗ Agent-to-agent session handover → a session snapshot/handover skill
- ✗ Delegating code execution to another coding agent → a delegated-audit skill
- ✗ Just mirroring a design system for the agent to read → a one-way sync, not a loop

---

## See Also

- `stage-handover.sh` — flatten brief + screenshots to the desktop (run every outbound)
- `templates/handover-package.template.md` — the master handover document
- `references/deliverable-contract.md` — what design must return (define in Stage 1, verify in Stage 3)
- `references/return-package-structure.md` — the shape returned work lands in (Stage 3)
- `references/web-sandbox-limits.md` — accepted upload formats + why path/zip fail

## Retro Log

- **First full round-trip (mobile UI rebuild)**: outbound = several briefs + screenshots;
  return = locked spec + visual audit checklist + a severity-tagged modification list +
  a paste-able hot-fix diff + mock screens. Two lessons, now baked in: (1) giving the
  design agent a path or a zip is useless — sandbox can't read disk + rejects zip → the
  `stage-handover.sh` flat-file discipline; (2) deliverables live only in the sandbox
  until downloaded → the Stage 3 ingest leg.
