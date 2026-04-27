# Audit Codebase — Skill

Codebase health assessment with two audit modes: AI-readiness and bug detection.

## Triggers

- "is this codebase AI-ready", "audit this codebase", "check this project"
- "audit the bugs", "find bugs in this codebase", "assess code quality"
- "full audit", "health check this project"
- "deep audit", "with codex", "go deep", "synthesize and audit"
- `/audit-codebase ai`, `/audit-codebase bug`, `/audit-codebase full`, `/audit-codebase deep`

## Modes

| Mode   | Trigger                     | What it does                                                      |
| ------ | --------------------------- | ----------------------------------------------------------------- |
| `ai`   | "AI-ready", "ready for AI"  | Structural analysis against AI-readiness checklist                |
| `bug`  | "bugs", "quality", "assess" | Run Assay + generate TLDR with fix plan                           |
| `full` | Default when unclear        | Both modes + combined verdict                                     |
| `deep` | "deep audit", "with codex"  | Full + Codex adversarial pass + dedup synthesis with action plan  |

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

## MODE: Deep (Full + Codex)

`deep` runs `ai` + `bug` like `full`, then spawns a Codex adversarial audit informed by the Assay findings, then synthesizes everything into a single action plan with dedup against Assay.

Use when:

- The codebase is mature (many phases shipped, several integrations) and the user wants the deepest possible review before a milestone, promotion, or release
- A standalone audit is fine but feels too shallow on cross-cutting concerns (architecture drift, multi-tenant isolation, subtle pipeline bugs)
- The user explicitly wants Codex involved (says "deep", "with codex", "go deep")

### Step 1: Run AI-readiness + Assay

Run the `ai` workflow (Steps 1-3 of MODE: AI-Readiness) and the `bug` workflow (Steps 1-3 of MODE: Bug Assessment). Same as MODE: Full.

### Step 2: Decide whether to spawn Codex

Codex requires the OpenAI Codex CLI installed and authenticated. Check with `which codex 2>&1`.

If unavailable → tell the user, save the AI-readiness + Assay outputs, exit. Do not block.

If available → AskUserQuestion:

> "Run Codex deep audit now? Will spawn `/codex:rescue --background --model gpt-5.5 --effort high` with the Assay findings injected so Codex skips them. Cost: ~15-30 messages on the gpt-5.5 quota (~25-40 min real time). Useful for what Assay cannot see: cross-cutting coherence, architecture drift, multi-tenant boundaries, subtle logic bugs, accumulated tech debt."
>
> - **Run now** — spawn Codex
> - **Save prompt for later** — write the prompt to `.audit/codex-prompt-<YYYY-MM-DD>.md`, exit
> - **Skip** — exit with ai+bug results only

### Step 3: Spawn Codex (if "Run now")

Build the prompt from Assay findings + AI-readiness gaps:

```
Audit this codebase as an adversarial reviewer. Read the file tree first, then focus on the highest-stakes surfaces (auth, data integrity, multi-tenant, payment flows, irreversible operations, recent integrations).

Assay {{assessment-date}} flagged these critical/high findings:
{{paste titles + one-line summaries from .assay-assessment/bug-report.md}}

AI-readiness gaps (lowest-scoring criteria):
{{paste from ai-readiness output the criteria scoring 1 or 2}}

Skip those. Focus on what Assay cannot see:
- Cross-cutting coherence between modules and pipelines
- Architecture drift since the last major refactor
- Multi-tenant isolation leaks (especially across system-admin / cross-org bypass paths)
- Subtle logic bugs in orchestrators and async flows
- Accumulated tech debt across recent changes
- Security reasoning beyond per-file OWASP (chains, replay, race conditions, irreversible ops without audit log)

Output JSON per the adversarial review schema. Severity: BLOCKER (ship-stopping), HIGH (fix this sprint), NOTE (consider).
```

Spawn via the Codex plugin: invoke `/codex:rescue --background --model gpt-5.5 --effort high "<prompt>"`. The plugin returns a task ID.

Inform the user: "Codex audit started in background (task: {{id}}). I'll wait and synthesize when it completes. Check progress with `/codex:status` if you want."

Poll `/codex:status {{id}}` until status is `complete`. Surface error and stop if Codex fails.

### Step 4: Synthesize

When Codex returns, combine the 3 inputs (AI-readiness + Assay + Codex) into a single action plan.

Dedup: for each Codex finding, check the Assay bug-report.md for a matching entry by file path + finding nature. Mark Codex findings that duplicate Assay as `dup`. Track count.

Categorize unique (non-dup) Codex findings:

- **BLOCKER** — must fix before next milestone / promote / release
- **HIGH** — fix this sprint (next 1-2 phases)
- **NOTE** — backlog, batch into normal work

Write synthesis to:

- `.planning/audits/AUDIT-SYNTHESIS-<YYYY-MM-DD>.md` if `.planning/` exists (RIFF-managed project)
- `.audit/AUDIT-SYNTHESIS-<YYYY-MM-DD>.md` otherwise (create `.audit/` if missing)

Format:

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
- **Title** | **File:** path:line | **Fix:** one-line | **Proposed action:** {{see Step 5 mapping}}

## HIGH (fix this sprint)

For each:
- **Title** | **File:** path:line | **Fix:** one-line | **Proposed action:** {{see Step 5 mapping}}

## NOTE (backlog)

One-line per finding. Proposed action: defer / batch into normal work.

## Archive

- Codex raw: {{path or "/codex:result {{task-id}}"}}
- Assay current: .assay-assessment/
- Assay rotated baseline (if any): .assay-assessment-{{prev-date}}-baseline/
- Previous synthesis: {{path or "none — first synthesis"}}
```

### Step 5: Report and recommend next steps

Print:

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

Recommend next steps based on context:

- **RIFF-managed project** (`.planning/` exists): suggest invoking `/riff:add-phase` to open new P0 phase(s) for BLOCKER findings, P1 phase(s) for HIGH. NOTE → propose appending to `DECAY.md` "Deferred from deep audit" section.
- **Non-RIFF project**: suggest opening tracker issues for BLOCKER + HIGH (one issue per finding or grouped by file). NOTE → suggest a backlog file or label.

Do NOT auto-fix any finding. The synthesis informs, the user decides.

---

## Rules

- Run from the project root (current working directory is the project)
- NEVER modify any code — this is read-only analysis
- Be honest and specific — vague assessments are useless
- Every recommendation must include effort level (low/medium/high)
- The TLDR must be understandable by a non-technical founder
- For the fix plan, consider dependencies (fix X before Y)
- If the project is small or short-lived, say so — don't over-prescribe
