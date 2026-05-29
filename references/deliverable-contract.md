# Deliverable Contract — what the design agent must return

> Stage 1 pastes this into the "requirements" section of the handover package;
> Stage 3 verifies the return against it, item by item.
> No contract = scattered returns and extra rounds. With one, the design agent knows
> what "done" looks like.

Each round, require the items below (trim to fit, but every item is either delivered
or explicitly skipped with a reason):

## A — Visual Audit Checklist

For each screen / state:
- **Component list**: name + position + size + spacing acceptance criteria
  (**pin the position explicitly**: edge-anchored / centered / … — so position
  regressions can actually be caught)
- **Typography**: which typeface where, size / weight / letter-spacing
- **Color**: which tokens, where
- **Interaction**: tap / long-press / swipe / drag — which elements
- **Touch target**: every interactive element ≥ 44×44px (Apple HIG)
- **Edge / safe area**: notch / home indicator handling
- **Three states**: empty / loading / error

Format: table + annotated screenshots; can be split per-screen.

## B — Follow-up Modification List

Across **desktop + mobile**, each item with fixed fields:

```
- title / one line
- Severity: 🔴 Critical / 🟡 Major / ⚪ Minor
- Platform: desktop / mobile / both
- Location: file path + line / component
- Current vs Expected (what the spec/prototype says)
- Root cause hypothesis (if any)
- Proposed fix (≥1 option; list trade-offs if multiple)
- Estimated effort + dependencies
```

Require coverage of both: (1) already-known bugs (ask for a better fix too) and
(2) NEW issues the agent finds in its own audit.

## C — Mock Screens

≥ 5 (empty / one-item-selected / picker-open / action-flow / onboarding). May be
delivered as a single openable HTML artboard set.

## D — Paradigm Decisions

List the key layout/UX forks (e.g. layout shell / canvas ratio / picker form /
inspector / action entry / metadata placement), each with a **recommendation +
1-2 alternatives + trade-offs**.

## E — Open-Questions Answers

Whatever open questions Stage 1 listed at the end of the package, require the agent
to answer each in its return README (which fix option / how to split PRs / new tokens
needed? / fold the backlog in or not?).

---

## Stage 3 acceptance gate

- [ ] A/B/C/D/E each has a corresponding file (or an explicit skip + reason)
- [ ] Every B item has severity + platform + location (missing → send back)
- [ ] Fixes are **actionable** (ideally a paste-able diff), not "consider refactoring"
- [ ] No escalate red lines crossed: new color/type/corner-radius/gradient,
      third-party UI lib, rebuilding the whole token system, or a list > 50 items
