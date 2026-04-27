# Report Templates

All audit modes use these exact templates. Substitute `{{placeholders}}` with real values.

---

## AI-Readiness Report

Used by `ai`, `full`, `deep` modes.

```
══════════════════════════════════════════════════════
AI-READINESS ASSESSMENT: {{project-name}}
Date: {{YYYY-MM-DD}}
══════════════════════════════════════════════════════

SCORE: {{X}}/21 — {{Rating}}

BREAKDOWN
| Criterion                  | Score | Status |
|----------------------------|-------|--------|
| File system = mental model |  X/3  | [icon] |
| Deep modules               |  X/3  | [icon] |
| Clear module boundaries    |  X/3  | [icon] |
| Progressive disclosure     |  X/3  | [icon] |
| Graybox modules            |  X/3  | [icon] |
| Tests & feedback loops     |  X/3  | [icon] |
| Planning includes modules  |  X/3  | [icon] |

EVIDENCE
[For each criterion, 1-2 lines of concrete evidence from the codebase]

TOP 3 IMPROVEMENTS (ranked by impact)
1. [What to do] — [Why it matters] — [Effort: low/medium/high]
2. ...
3. ...

IS IT WORTH IT?
[2-3 sentences: should they restructure? What's the ROI?
Consider project size, lifespan, how much AI coding they do.
Be honest — sometimes the answer is "not worth it for this project."]
══════════════════════════════════════════════════════
```

Status icons by score: 0 = red, 1 = orange, 2 = yellow, 3 = green.

---

## Bug Assessment Report

Used by `bug`, `full`, `deep` modes.

```
══════════════════════════════════════════════════════
BUG ASSESSMENT: {{project-name}}
Date: {{assessment-date}}
Score: {{X}}/100
══════════════════════════════════════════════════════

TLDR
[3-5 sentences in plain language. No jargon. What works,
what's broken, what's the real risk to the business.
Written so a non-technical founder can understand it.]

CRITICAL ISSUES (fix NOW)
1. [Bug title]
   What: [plain language — what's actually broken]
   Impact: [what happens to users/business if you don't fix it]
   Fix: [concrete steps — files to change, what to add]
   Effort: [hours/days estimate]

HIGH PRIORITY (fix this sprint)
1. [Same format as above]

WHAT'S WORKING WELL
- [Domain] — [score]% — [one-line summary]

DOMAIN HEALTH MAP
| Domain                     | Score | Status |
|----------------------------|-------|--------|
| [domain name]              |  XX%  | [icon] |

FIX PLAN
Phase 1 — This week (critical):
  - [bug] — [effort]
  Total: ~[X] days

Phase 2 — Next sprint (high priority):
  - [bug] — [effort]
  Total: ~[X] days

Phase 3 — Ongoing (medium, batch into normal work):
  - [X] medium bugs across [Y] domains
  Total: ~[X] days spread over sprints

Total estimated remediation: [X] days of focused work
══════════════════════════════════════════════════════
```

Domain status icons: 0-25% = red, 26-50% = orange, 51-75% = yellow, 76-100% = green.

---

## Combined Health Verdict

Used by `full` mode (after the AI and Bug reports).

```
══════════════════════════════════════════════════════
COMBINED HEALTH: {{project-name}}
══════════════════════════════════════════════════════
AI-Readiness:  {{X}}/21 — {{rating}}
Code Quality:  {{X}}/100 — {{rating}}

VERDICT
[3-4 sentences combining both perspectives.
Is this codebase ready for AI-assisted development?
What should be fixed first — structure or bugs?
Recommended order of operations.]
══════════════════════════════════════════════════════
```

---

## Deep Audit Synthesis

Used by `deep` mode. Written to `.planning/audits/AUDIT-SYNTHESIS-<YYYY-MM-DD>.md` (if `.planning/` exists) or `.audit/AUDIT-SYNTHESIS-<YYYY-MM-DD>.md` otherwise.

```markdown
# Audit Synthesis — {{project-name}} — {{YYYY-MM-DD}}

**AI-Readiness:** {{X}}/21
**Assay (bugs):** {{Y}}/100
**Codex unique findings:** {{Z}} ({{dup}}/{{total}} were Assay duplicates)

## TLDR

{{3-5 lines: state of the codebase, what to fix first, dedup signal, archive note}}

## Dedup stats

- Codex findings: {{total}}
- Already in Assay: {{dup count}}
- Unique to Codex: {{unique count}}

If dup count >50%, refine future Codex prompts to skip those Assay categories more aggressively.

## BLOCKER (must fix before next milestone / promote / release)

For each:

- **Title** | **File:** path:line | **Fix:** one-line | **Proposed action:** {{open phase / open issue / etc.}}

## HIGH (fix this sprint)

For each:

- **Title** | **File:** path:line | **Fix:** one-line | **Proposed action:** {{open phase / open issue / etc.}}

## NOTE (backlog)

One-line per finding. Proposed action: defer / batch into normal work.

## Archive

- Codex raw: {{path or "/codex:result {{task-id}}"}}
- Assay current: .assay-assessment/
- Assay rotated baseline (if any): .assay-assessment-{{prev-date}}-baseline/
- Previous synthesis: {{path or "none — first synthesis"}}
```

---

## Deep Audit Summary

Printed to terminal at the end of `deep` mode (after the synthesis file is written).

```
══════════════════════════════════════════════════════
DEEP AUDIT — {{project-name}} — {{YYYY-MM-DD}}
══════════════════════════════════════════════════════
AI-Readiness:    {{X}}/21
Assay (bugs):    {{Y}}/100
Codex unique:    {{Z}} findings ({{dup}}/{{total}} were Assay duplicates)

BLOCKER: {{count}}
HIGH:    {{count}}
NOTE:    {{count}}

Synthesis: {{path}}
══════════════════════════════════════════════════════
```
