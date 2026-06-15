# design-review-loop

A reusable **Claude Code skill** for handing visual/design work to a web-sandboxed
design agent (e.g. Claude on claude.ai, "Claude Design") and bringing the result
back into your repo — without losing a round-trip to the same avoidable mistakes.

> 🌐 **English** | [繁體中文](README.zh-TW.md)

## The problem this solves

A CLI coding agent can grep, refactor across files, and read your whole repo — but
it **can't make visual judgements** (no eyes). For mock screens, visual audits, and
layout/UX decisions you hand the work to a design agent that *does* have visual
ability but **runs in a sandbox**:

- it **cannot read your local disk** — giving it a file path is useless
- it **rejects `.zip`** and only accepts a **flat list** of uploaded files
- whatever it produces lives **inside its sandbox** until you download it back

Every team that does this loop ad-hoc burns a round-trip rediscovering those three
facts. This skill bakes them in: a staging script that flattens your brief +
screenshots to the desktop for drag-upload, a fixed **deliverable contract** so the
design agent knows what "done" means, and an **ingest** step so the result lands
back in your repo in a predictable shape.

## The 5-stage loop

```
1 OUTBOUND   gather state + evidence → stage flat files to desktop for upload
2 DESIGN     you upload → design agent audits + rebuilds → returns deliverables
3 RETURN     download → version-control the SSOT → reconcile design↔backend↔frontend → verify
4 DISPATCH   prioritize by severity → hand critical fixes to the implementer first
5 CLOSEOUT   post-deploy verify against ground truth → log it
```

See [`SKILL.md`](./SKILL.md) for the full flow.

## Install

Drop the folder into your Claude Code skills directory:

```bash
cp -r design-review-loop ~/.claude/skills/
# or into a project: cp -r design-review-loop <project>/.claude/skills/
```

Claude Code picks it up from the `name` + `description` frontmatter in `SKILL.md`.

## Use the staging script directly

```bash
bash design-review-loop/stage-handover.sh <source-dir> [dest-name] [--zip] [--dry-run]
```

Gathers every web-acceptable file under `<source-dir>` (recursive), flattens them
into `~/Desktop/<dest-name>/`, stitches all `.md` into a single
`00-READ-FIRST-bundle.md`, and (with `--zip`) also writes a zip for transfer/backup.

> **Upload the loose files, not the zip** — the web sandbox rejects archives and
> reads a flat list only.

## What's inside

| File | Purpose |
|---|---|
| `SKILL.md` | The 5-stage workflow |
| `stage-handover.sh` | Flatten brief + screenshots to desktop for upload |
| `references/deliverable-contract.md` | What the design agent must return (define ⟶ verify) |
| `references/return-package-structure.md` | The shape returned work lands in |
| `references/web-sandbox-limits.md` | Why path/zip don't work; accepted formats |
| `references/design-build-reconcile.md` | Stage 3 reconcile: version-control the SSOT, design↔backend↔frontend matrix, build-target lock |
| `templates/handover-package.template.md` | The master brief you hand over |

## Test

```bash
bash test/smoke.sh
```

Stages a fixture and asserts the contract (flatten, drop rejected formats, stitch the
bundle, `--dry-run` writes nothing). Runs in CI on every push — see
[`.github/workflows/ci.yml`](./.github/workflows/ci.yml).

## License

MIT — see [`LICENSE`](./LICENSE).
