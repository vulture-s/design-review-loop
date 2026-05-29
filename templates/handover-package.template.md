# {{FEATURE}} → Design Agent Handover Package

**Date**: {{DATE}}
**From**: {{OPERATOR}} (decision) + CLI agent (data prep)
**To**: Design Agent
**Status**: full handover, awaiting deliverables

## 0. Instruction (verbatim)

> "{{VERBATIM_INSTRUCTION}}"

= {{INSTRUCTION_RESTATED}}

## 1. Current-state snapshot ({{TIMESTAMP}})

### 1.1 Live state
- **URL / target**: {{TARGET}}
- **Build / version**: {{BUILD_REF}}
- **Repo**: {{REPO_REF}}

### 1.2 What's working ✅
- {{...}}

### 1.3 What's broken 🔴
#### #1 {{TITLE}} ({{SEVERITY}})
- Current: {{...}}
- Impact: {{...}}
- Root cause hypothesis: {{...}}
- Quantified evidence (computed styles / screenshots): {{...}}

### 1.4 What's partial 🟡
- {{...}}

## 2. Artifact index

| File | Purpose | For design |
|---|---|---|
| `HANDOVER-PACKAGE.md` | this file = entry point | ✅ read first |
| `{{BRIEF}}.md` | {{...}} | ✅ |
| `{{screenshot}}.png` | {{...}} | ✅ |

## 3. Requirements for the design agent

→ Full deliverable contract: `references/deliverable-contract.md`.
This round, return: A visual audit checklist / B follow-up modification list
(severity-tagged) / C ≥5 mock screens / D paradigm decisions / E open-question answers.

## 4. Visual / design constraints (don't reinvent)

- Design tokens: {{TOKENS}}
- Typography: {{FONTS}}
- Visual rules: {{RULES}}
- Off-limits (escalate): new color / new typeface / corner radius / gradient /
  third-party UI lib / rebuilding the token system

## 5. Iteration loop

Outbound (this file) → design returns deliverables → CLI agent ingests + verifies +
triages → operator review → implementer ships → post-deploy verify.
Expect ≤ 3 rounds to converge.

## 6. Stop / escalate criteria
- {{...}}

## 7. Open questions for design
- {{Q1}}
- {{Q2}}

## 8. Hand-off
- Deliverable return path: {{RETURN_PATH}}
- Return structure spec: `references/return-package-structure.md`
