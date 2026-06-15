# Design ↔ Build Reconciliation (Stage 3)

When a design deliverable comes back, verifying it against the *contract* (did the
agent deliver what we asked?) is **not enough**. You also have to reconcile it
against the *real implementation* — backend API + frontend — before any build.
Skipping this wastes whole rounds: building against a design the backend can't
serve, or against a second-hand mock that already drifted from the design.

---

## §1 — Version-control the SSOT (don't trust "it was handed off")

**Trap (every time):** "we handed this to design ages ago, it's surely in the repo."
Reality is often: only the *tokens* got copied into the code, and the actual
deliverable file lives only on the designer's machine / a NAS / a download folder —
**never committed**. The visual SSOT is then unversioned.

1. **Search the repo first** for the deliverable by name/content before assuming.
   Absent → it isn't version-controlled; fix that now.
2. **Locate the original** (ask; common homes: a NAS share, a download folder). Pull
   it over the fastest link available.
3. **Heavy bundle → don't commit raw.** A self-contained design artifact (e.g. a
   React + Babel export) is often 5–10 MB; committing it bloats the repo forever.
   Commit a **lightweight record** instead:
   - rendered **screenshots** of every screen (see §1a),
   - a **reference doc**: original filename, byte size, **sha256**, canonical store
     path (the NAS/vault it lives in), the brief it answers, provenance.
   - keep the raw bundle in its backed-up store.
4. Small deliverables (a tokens file, a single mock HTML) → commit directly.

### §1a — Rendering an interactive prototype to screenshots
The screens render at runtime and the source is minified, so you must render, not
read.
- These artifacts are often a **vertically/2D-stacked "N essays" scroll**, not
  click-nav — one tall capture (or per-section element captures) gets everything.
- Tooling: headless Chrome `--screenshot` for a single view; a browser-automation
  library (e.g. Playwright with the system Chrome channel, no separate download) to
  find each section element and screenshot it (auto-scrolls, captures full height).
- A section may be a **very wide horizontal strip** (multiple artboards side by
  side) — slice the PNG to read it.

---

## §2 — Three-layer alignment matrix (design ↔ backend ↔ frontend)

One row per screen/feature, three status columns — mark ✅ / 🟡 / ❌.

| screen / feature | design (SSOT) | backend API | frontend impl | gap is in… |
|---|:---:|:---:|:---:|---|
| (example) ingest setup | ✅ | ❌ thin | ❌ not ported | backend + frontend |

**Classify each gap by layer** — the fix differs per layer:
- **design ❌** — design didn't cover it → back to the design stage, don't invent.
- **backend ❌/🟡** — the engine *can* do it but the API doesn't expose the knob →
  an API-extension task.
- **frontend ❌** — design + API are ready, it's just not built → a port task.

**Key discipline — controls must map to real API params, not engine capability.** A
polished dialog often *unifies several services' settings* (e.g. a single "setup"
dialog that secretly spans a file-transfer service **and** a processing service).
"The engine can do it" ≠ "the API exposes it". Walk every control in the design and
find the actual request parameter; controls with no parameter are backend-API tasks,
not frontend work. Miss this and you build a frontend form whose controls do nothing
— the exact "design > wiring" gap you're trying to close.

**Don't fake to match.** If the design shows data the backend can't produce (e.g. a
GPU-utilization tile on a machine with no GPU), **drop it and log the deviation** —
never hardcode a fake value to make the screenshot match.

---

## §3 — Build-target lock

The build target is the **design SSOT itself**, NOT any earlier hand-ported mock
(mock routes/components, etc.). A hand port is a second-hand transcription that has
already drifted. Point every build segment at the SSOT screenshots, and record this
in the plan so a later session doesn't rebuild against the mock.

---

## §4 — Gap → ordered segments

Turn the matrix into a build plan:
- One **segment per coherent screen/flow**, worst-gap first.
- Each segment names **which layer(s) it touches** and its **acceptance** (the live
  render matches the SSOT screen, with real data, tests green).
- A segment that needs both backend + frontend → split into bricks (API first, then
  UI) so each is independently shippable + testable.
- Write it to a dated construction-plan doc.

---

## Worked example (anonymized)

- **§1 hit:** a redesign deliverable (a multi-MB interactive prototype) had only its
  *tokens* extracted into the codebase; the file itself was never committed — found
  only on a NAS share. → mounted the share, rendered each screen, committed a
  `docs/design/<redesign>/` folder (screenshots + a reference with the sha256).
- **§2 hit:** the matrix showed an ingest **setup dialog** that unified a
  file-transfer config **and** a processing config, but the API endpoint accepted
  only `{path, limit}`. The gap was **backend API too thin**, not frontend → the
  first brick was an API extension, not a form. A GPU-utilization tile in the mock
  was **dropped** (the target machines have no GPU) and the deviation logged.
- **§3:** the build target was locked to the committed SSOT screenshots, **not** an
  earlier hand-ported set of mock screens.
- **§4:** an ordered plan, each segment tagged by the layer(s) it touches.
