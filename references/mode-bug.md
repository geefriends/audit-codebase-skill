# Mode: Bug/Quality Assessment (Assay)

## Step 1: Check for Existing Assessment

Run the wrapper script (skill is symlinked at `~/.claude/skills/audit-codebase/`):

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

## Step 2: Read Assessment Data

Read these files from `.assay-assessment/`:

1. `executive-summary.md` — overall narrative
2. `assessment-summary.json` — scores, flow results, bug counts
3. `bug-report.md` — all bugs with severity and evidence
4. `coverage-matrix.md` — domain-by-domain coverage

## Step 3: Generate Report

Use the bug-assessment template in `references/report-templates.md` (`Bug Assessment Report` section).

Domain status icons by score: 0-25% = red, 26-50% = orange, 51-75% = yellow, 76-100% = green.
