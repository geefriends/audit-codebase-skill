# Mode: Deep (Full + Codex)

Runs `ai` + `bug` like `full`, then spawns a Codex adversarial audit informed by the Assay findings, then synthesizes everything into a single action plan with dedup against Assay.

## When to use

- Mature codebase, user wants the deepest possible review before a milestone, promotion, or release
- Standalone audit feels too shallow on cross-cutting concerns (architecture drift, multi-tenant isolation, subtle pipeline bugs)
- User explicitly wants Codex involved ("deep", "with codex", "go deep")

## Step 1: Run AI-readiness + Assay

Run `references/mode-ai.md` Steps 1-3 and `references/mode-bug.md` Steps 1-3. Same as `full` mode.

## Step 2: Decide whether to spawn Codex

Codex requires the OpenAI Codex CLI installed and authenticated. Check with `which codex 2>&1`.

If unavailable → tell the user, save the AI-readiness + Assay outputs, exit. Do not block.

If available → AskUserQuestion:

> "Run Codex deep audit now? Will spawn `/codex:rescue --background --model gpt-5.5 --effort high` with the Assay findings injected so Codex skips them. Cost: ~15-30 messages on the gpt-5.5 quota (~25-40 min real time). Useful for what Assay cannot see: cross-cutting coherence, architecture drift, multi-tenant boundaries, subtle logic bugs, accumulated tech debt."
>
> - **Run now** — spawn Codex
> - **Save prompt for later** — write the prompt to `.audit/codex-prompt-<YYYY-MM-DD>.md`, exit
> - **Skip** — exit with ai+bug results only

## Step 3: Spawn Codex (if "Run now")

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

## Step 4: Synthesize

When Codex returns, combine the 3 inputs (AI-readiness + Assay + Codex) into a single action plan.

Dedup: for each Codex finding, check the Assay `bug-report.md` for a matching entry by file path + finding nature. Mark Codex findings that duplicate Assay as `dup`. Track count.

Categorize unique (non-dup) Codex findings:

- **BLOCKER** — must fix before next milestone / promote / release
- **HIGH** — fix this sprint (next 1-2 phases)
- **NOTE** — backlog, batch into normal work

Write synthesis to:

- `.planning/audits/AUDIT-SYNTHESIS-<YYYY-MM-DD>.md` if `.planning/` exists (RIFF-managed project)
- `.audit/AUDIT-SYNTHESIS-<YYYY-MM-DD>.md` otherwise (create `.audit/` if missing)

Use the synthesis template in `references/report-templates.md` (`Deep Audit Synthesis` section).

## Step 5: Report and recommend next steps

Print the deep-audit summary template from `references/report-templates.md` (`Deep Audit Summary` section).

Recommend next steps based on context:

- **RIFF-managed project** (`.planning/` exists): suggest invoking `/riff:add-phase` to open new P0 phase(s) for BLOCKER findings, P1 phase(s) for HIGH. NOTE → propose appending to `DECAY.md` "Deferred from deep audit" section.
- **Non-RIFF project**: suggest opening tracker issues for BLOCKER + HIGH (one issue per finding or grouped by file). NOTE → suggest a backlog file or label.

Do NOT auto-fix any finding. The synthesis informs, the user decides.
