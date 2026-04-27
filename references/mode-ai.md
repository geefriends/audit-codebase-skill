# Mode: AI-Readiness Assessment

Evaluate whether this codebase is structured for effective AI-assisted development.

## Step 1: Gather Data

Run these in parallel:

1. `git ls-files | head -200` — file tree structure
2. `find . -name "index.ts" -o -name "index.js" -o -name "mod.ts" -o -name "__init__.py" | head -50` — module entry points
3. `find . -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" | wc -l` — test file count
4. Check for `CLAUDE.md`, `README.md`, `.cursorrules`, `AGENTS.md` — AI context files
5. Read `package.json`, `tsconfig.json`, or equivalent project config

## Step 2: Score 7 Criteria (0-3 each)

Read `references/checklist.md` for the full scoring rubric, anti-patterns, and red flags. Apply each criterion's 0-3 scale to the gathered data.

The 7 criteria, in order:

1. File system = mental model
2. Deep modules
3. Clear module boundaries
4. Progressive disclosure
5. Graybox modules
6. Tests & feedback loops
7. Planning includes modules

For each criterion, record concrete evidence from the codebase (file paths, counts, examples) — not just a number.

## Step 3: Generate Report

Use the AI-readiness template in `references/report-templates.md` (`AI-Readiness Report` section).

Status icons by score: 0 = red, 1 = orange, 2 = yellow, 3 = green.

Rating bands (out of 21):

- 18-21: AI-ready
- 12-17: Partially ready
- 6-11: Not ready
- 0-5: AI-hostile
