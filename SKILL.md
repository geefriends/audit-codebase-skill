---
name: audit-codebase
description: "Audit codebase health for AI-readiness and bug detection. Use when user says 'audit this codebase', 'is this AI-ready', 'find bugs in this project', 'check this project', 'assess code quality', 'health check this project', 'deep audit', 'with codex', 'go deep', 'synthesize and audit', or runs /audit-codebase ai|bug|full|deep."
---

<objective>
Codebase health assessment with four audit modes — AI-readiness scoring, bug detection (via Assay), combined verdict, or deep audit with Codex adversarial pass.
Read-only analysis. The skill never modifies code.
</objective>

<triggers>
- "is this codebase AI-ready", "audit this codebase", "check this project"
- "audit the bugs", "find bugs in this codebase", "assess code quality"
- "full audit", "health check this project"
- "deep audit", "with codex", "go deep", "synthesize and audit"
- `/audit-codebase ai`, `/audit-codebase bug`, `/audit-codebase full`, `/audit-codebase deep`
</triggers>

<modes>
| Mode   | Trigger                     | What it does                                                      | Reference file                |
| ------ | --------------------------- | ----------------------------------------------------------------- | ----------------------------- |
| `ai`   | "AI-ready", "ready for AI"  | Structural analysis against AI-readiness checklist                | `references/mode-ai.md`       |
| `bug`  | "bugs", "quality", "assess" | Run Assay + generate TLDR with fix plan                           | `references/mode-bug.md`      |
| `full` | Default when unclear        | Both modes + combined verdict                                     | `references/mode-full.md`     |
| `deep` | "deep audit", "with codex"  | Full + Codex adversarial pass + dedup synthesis with action plan  | `references/mode-deep.md`     |
</modes>

<workflow>
1. Detect the mode from the user's input. Default to `full` if unclear.
2. Read the matching reference file from `references/mode-<mode>.md`.
3. Follow its steps in order.
4. Output the report using the matching template in `references/report-templates.md`.
</workflow>

<rules>
- Run from the project root (current working directory is the project under audit)
- NEVER modify any code — this skill is read-only analysis
- Be honest and specific — vague assessments are useless
- Every recommendation includes effort level (low/medium/high)
- The TLDR must be understandable by a non-technical founder
- For the fix plan, consider dependencies (fix X before Y)
- If the project is small or short-lived, say so — don't over-prescribe
</rules>

<success_criteria>
- Mode correctly identified from user input
- Required data gathered before scoring or reporting
- Report follows the exact template in `references/report-templates.md`
- All findings have evidence (file paths, scores, concrete examples)
- Output is honest about ROI and whether changes are worth it for this project
- No code modified during the audit
</success_criteria>
