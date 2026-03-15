# Audit Codebase — Skill

Codebase health assessment with two audit modes: AI-readiness and bug detection.

## Triggers

- "is this codebase AI-ready", "audit this codebase", "check this project"
- "audit the bugs", "find bugs in this codebase", "assess code quality"
- "full audit", "health check this project"
- `/audit-codebase ai`, `/audit-codebase bug`, `/audit-codebase full`

## Modes

| Mode | Trigger | What it does |
|------|---------|--------------|
| `ai` | "AI-ready", "ready for AI" | Structural analysis against AI-readiness checklist |
| `bug` | "bugs", "quality", "assess" | Run Assay + generate TLDR with fix plan |
| `full` | Default when unclear | Both modes + combined verdict |

## Skill Directory

All skill files live in `~/.claude/skills/audit-codebase/`:
- `SKILL.md` — this file
- `checklist.md` — AI-Ready Codebase Checklist (reference document)
- `run-assay.sh` — wrapper script for Assay CLI

---

## MODE: AI-Readiness Assessment

Evaluate whether this codebase is structured for effective AI-assisted development.

### Step 1: Gather Data

Run these in parallel:
1. `git ls-files | head -200` — understand file tree structure
2. `find . -name "index.ts" -o -name "index.js" -o -name "mod.ts" -o -name "__init__.py" | head -50` — find module entry points
3. `find . -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" | wc -l` — count test files
4. Check for `CLAUDE.md`, `README.md`, `.cursorrules`, `AGENTS.md` — AI context files
5. Read `package.json`, `tsconfig.json`, or equivalent project config

### Step 2: Evaluate 7 Criteria (score each 0-3)

Read the checklist at `~/.claude/skills/audit-codebase/checklist.md` for full details on each criterion.

**1. File System = Mental Model (0-3)**
- 0: Flat structure, no logical grouping
- 1: Some folders but inconsistent naming
- 2: Clear feature/domain folders, most code organized
- 3: Every module has a logical home, structure is self-documenting

**2. Deep Modules (0-3)**
- 0: Hundreds of tiny files with no grouping
- 1: Some larger modules exist but no clear pattern
- 2: Most features are grouped with entry points
- 3: Clear deep module pattern — each service has index + internal + tests

**3. Clear Module Boundaries (0-3)**
- 0: Any file imports from any other file freely
- 1: Some barrel exports but not enforced
- 2: Most modules have defined public interfaces
- 3: Strict boundaries — imports only through public API

**4. Progressive Disclosure (0-3)**
- 0: Must read implementation to understand any module
- 1: Some types/interfaces exist but incomplete
- 2: Most modules have typed exports that explain behavior
- 3: Full type contracts, JSDoc on public API, can understand without reading internals

**5. Graybox Modules (0-3)**
- 0: Changing any file risks breaking distant parts
- 1: Some modules are isolated but many have hidden coupling
- 2: Most modules can be changed internally without side effects
- 3: All modules are fully encapsulated — change internals freely if tests pass

**6. Tests & Feedback Loops (0-3)**
- 0: No tests
- 1: Some tests exist but poor coverage or slow
- 2: Good test coverage on critical paths, reasonable speed
- 3: Comprehensive tests per module, fast feedback, CI pipeline

**7. Planning Includes Modules (0-3)**
- 0: No specs, PRDs, or architecture docs
- 1: README exists but no module-level docs
- 2: Some architecture documentation, module responsibilities described
- 3: Full specs reference modules, CLAUDE.md guides AI to right areas

### Step 3: Generate AI-Readiness Report

```
══════════════════════════════════════════════════════
AI-READINESS ASSESSMENT: [project-name]
Date: [YYYY-MM-DD]
══════════════════════════════════════════════════════

SCORE: [X]/21 — [Rating]

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

Status icons: 0 = red, 1 = orange, 2 = yellow, 3 = green

---

## MODE: Bug/Quality Assessment (Assay)

### Step 1: Check for Existing Assessment

Run the wrapper script:

```bash
bash ~/.claude/skills/audit-codebase/run-assay.sh "$(pwd)"
```

Parse the output:
- `EXISTING_ASSESSMENT:<path>` — recent data exists, use it (skip to Step 3)
- `STALE_ASSESSMENT:<path>` — data is old, ask user: reuse or re-run?
- `RUNNING_ASSESSMENT:<path>` — Assay is running, wait for completion

If stale and user wants to re-run, or if no assessment exists:

```bash
npx tryassay assess "$(pwd)"
```

This takes several minutes. Tell the user it's running.

### Step 2: Read Assessment Data

Read these files from `.assay-assessment/`:
1. `executive-summary.md` — overall narrative
2. `assessment-summary.json` — scores, flow results, bug counts
3. `bug-report.md` — all bugs with severity and evidence
4. `coverage-matrix.md` — domain-by-domain coverage

### Step 3: Generate TLDR Report

```
══════════════════════════════════════════════════════
BUG ASSESSMENT: [project-name]
Date: [assessment date]
Score: [X]/100
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

Domain status icons: 0-25% = red, 26-50% = orange, 51-75% = yellow, 76-100% = green

---

## MODE: Full (both modes)

Run AI-readiness first, then bug assessment. At the end, add combined summary:

```
══════════════════════════════════════════════════════
COMBINED HEALTH: [project-name]
══════════════════════════════════════════════════════
AI-Readiness:  [X]/21 — [rating]
Code Quality:  [X]/100 — [rating]

VERDICT
[3-4 sentences combining both perspectives.
Is this codebase ready for AI-assisted development?
What should be fixed first — structure or bugs?
Recommended order of operations.]
══════════════════════════════════════════════════════
```

---

## Rules

- Run from the project root (current working directory is the project)
- NEVER modify any code — this is read-only analysis
- Be honest and specific — vague assessments are useless
- Every recommendation must include effort level (low/medium/high)
- The TLDR must be understandable by a non-technical founder
- For the fix plan, consider dependencies (fix X before Y)
- If the project is small or short-lived, say so — don't over-prescribe
