# Return Package Structure — where returned design work lands

> Stage 3: the design agent produces deliverables in its sandbox → the user downloads
> them → the CLI agent files them in the repo. This spec gives the return folder a
> fixed shape, so ingest / verification / dispatch always have something predictable.

## Landing location

```
<project>/.../<feature>-design-return/      # long-term keep
  or
<project>/.../audit/<date>-<feature>/handoff/   # alongside the outbound audit dir
```

## Canonical structure (maps to deliverable-contract A–E)

```
handoff/
├── README.md                         # index + open-question answers (contract E)
├── 03-<surface>/
│   ├── SPEC.md                       # the locked implementation spec
│   └── AUDIT-CHECKLIST.md            # contract A — visual audit checklist
├── 04-modifications/
│   └── FOLLOWUPS.md                  # contract B — modification list (severity-tagged)
├── 05-<fix-name>/
│   └── <FIX>-PROPOSAL.md             # paste-able diff for a critical fix (hot-fix)
├── 01-tokens/ 02-components/         # (optional) token export / component refs
└── <feature>.html                   # contract C — mock screens (openable)
```

## Ingest checklist (after the CLI agent files it in the repo)

1. **Format filter**: the agent may return web-only formats; make sure no junk lands
   in the repo.
2. **Verify** against the Stage 3 gate in `deliverable-contract.md`, item by item.
3. **Extract severity**: pull 🔴 items into a "hot-fix batch", 🟡/⚪ into a
   "rebuild batch".
4. **Extract paste-able diffs**: a diff inside `05-*-PROPOSAL` goes straight into the
   dispatch handoff, flagged "critical, don't wait for the rebuild."
5. **Commit** the return package into version control — the design output is a
   source-of-truth artifact.

## Notes

- Returned files exist **only in the design sandbox** → the user must download them.
  The CLI agent not finding them ≠ work not done — first check whether it's been
  ingested yet.
- Multiple iterations on one feature → suffix the return folder `-r2` / `-r3`; never
  overwrite a prior round (keep the audit trail).
