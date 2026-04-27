# audit-codebase

A [Claude Code](https://claude.com/claude-code) skill that audits codebase health from three complementary angles: structural AI-readiness scoring, automated bug detection (via [Assay](https://www.npmjs.com/package/tryassay)), and an optional Codex adversarial deep audit. Synthesizes all findings into a single action plan with deduplication.

## Why three angles

Each tool sees different things:

- **AI-readiness checklist** catches structural rot — deep modules, clear boundaries, progressive disclosure, the things that make a codebase pleasant or painful for AI agents (and humans) to work in.
- **Assay** runs claims-based static analysis on your routes and surfaces concrete bugs with severity scoring.
- **Codex adversarial review** (optional, via the `gpt-5.5` model) catches what static analysis cannot see: cross-pipeline coherence, subtle logic bugs, multi-tenant isolation leaks, accumulated tech debt across phases.

This skill runs them in sequence with the right context each time, then synthesizes findings (deduping Codex against Assay) into one prioritized action list.

## Modes

| Mode   | Trigger phrases                                  | What it does                                                      |
| ------ | ------------------------------------------------ | ----------------------------------------------------------------- |
| `ai`   | "AI-ready", "ready for AI"                       | Structural analysis against AI-readiness checklist                |
| `bug`  | "bugs", "quality", "assess"                      | Run Assay + generate TLDR with fix plan                           |
| `full` | Default when unclear, "full audit"               | Both modes + combined verdict                                     |
| `deep` | "deep audit", "with codex", "synthesize and audit" | Full + Codex adversarial pass + dedup synthesis with action plan |

## Install

```bash
# Clone the skill
git clone https://github.com/alexadark/audit-codebase-skill ~/DEV/skills/audit-codebase-skill

# Symlink into Claude Code's skills directory
ln -s ~/DEV/skills/audit-codebase-skill ~/.claude/skills/audit-codebase
```

Verify by listing your skills inside Claude Code; `audit-codebase` should appear.

## Prerequisites

**Required for `bug`, `full`, and `deep` modes** (Assay):

- `npx` (comes with Node.js 18+)
- `ANTHROPIC_API_KEY` exported in your shell (Assay uses Claude under the hood)

**Optional for `deep` mode** (Codex):

- [openai/codex-plugin-cc](https://github.com/openai/codex-plugin-cc) installed in your Claude Code setup
- Active ChatGPT subscription (Plus or higher) or OpenAI API key
- The skill gracefully falls back to `full` mode if Codex is not available

## Usage

In a Claude Code session, anywhere in your project root:

- `"audit this codebase"` → runs `full` mode
- `"is this codebase AI-ready?"` → runs `ai` mode
- `"find bugs in this project"` → runs `bug` mode
- `"deep audit with codex"` → runs `deep` mode
- `/audit-codebase deep` → explicit invocation by mode name

The skill auto-detects whether prior assessment data exists (`.assay-assessment/`) and reuses it if recent (<7 days), or proposes a re-run if stale.

## What you get

### `ai` mode output

A score out of 21 across 7 criteria, with concrete evidence and ranked improvements:

```
══════════════════════════════════════════════════════
AI-READINESS ASSESSMENT: my-project
Date: 2026-04-27
══════════════════════════════════════════════════════

SCORE: 17/21 — Largely AI-ready

| Criterion                  | Score | Status |
|----------------------------|-------|--------|
| File system = mental model |  3/3  | green  |
| Deep modules               |  2/3  | yellow |
| Clear module boundaries    |  2/3  | yellow |
| Progressive disclosure     |  3/3  | green  |
| Graybox modules            |  2/3  | yellow |
| Tests & feedback loops     |  2/3  | yellow |
| Planning includes modules  |  3/3  | green  |

EVIDENCE
[concrete findings per criterion, with file paths]

TOP 3 IMPROVEMENTS (ranked by impact)
1. [What to do] — [Why it matters] — [Effort: low/medium/high]
2. ...
3. ...

IS IT WORTH IT?
[honest assessment based on project size and lifespan]
══════════════════════════════════════════════════════
```

### `bug` mode output

Score out of 100 + bug list with severity + domain coverage map:

```
══════════════════════════════════════════════════════
BUG ASSESSMENT: my-project
Date: 2026-04-27
Score: 91/100
Bugs: 18 total (Critical: 1, High: 4, Medium: 13, Low: 0)
══════════════════════════════════════════════════════

TLDR
[3-5 sentences, business-language, what works and what's broken]

CRITICAL (fix NOW)
1. [Bug title]
   What: [plain language explanation]
   Impact: [what happens if not fixed]
   Fix: [concrete steps]
   Effort: [hours/days]

HIGH PRIORITY (fix this sprint)
[same format]

DOMAIN HEALTH MAP
| Domain                     | Score | Status |
|----------------------------|-------|--------|
| [domain name]              |  XX%  | [icon] |

FIX PLAN
Phase 1 — This week (critical): ...
Phase 2 — Next sprint (high):  ...
Phase 3 — Ongoing (medium):     ...
══════════════════════════════════════════════════════
```

### `full` mode output

Combines the above two plus a single verdict and recommended order of operations.

### `deep` mode output

The 3-input synthesis. Runs `full` first, then asks before spawning Codex (cost warning), then dedups Codex findings against Assay so you do not get the same bug flagged twice:

```
══════════════════════════════════════════════════════
DEEP AUDIT — my-project — 2026-04-27
══════════════════════════════════════════════════════
AI-Readiness:    17/21
Assay (bugs):    91/100
Codex unique:    7 findings (4/11 were Assay duplicates)

BLOCKER: 1 → see synthesis BLOCKER section
HIGH:    3 → see synthesis HIGH section
NOTE:    3 → see synthesis NOTE section

Synthesis: .audit/AUDIT-SYNTHESIS-2026-04-27.md
Codex raw: /codex:result <task-id>
Assay raw: .assay-assessment/
══════════════════════════════════════════════════════
```

The synthesis file (`AUDIT-SYNTHESIS-<date>.md`) contains:

- **TLDR** (3-5 lines on overall state)
- **Dedup stats** (unique to Codex vs already in Assay; if >50% overlap, refine future prompts)
- **BLOCKER** findings with proposed fix actions
- **HIGH** findings with proposed fix actions
- **NOTE** findings batched for backlog
- **Archive** paths for the raw outputs

## How `deep` mode works

1. Runs `ai` and `bug` modes first (free, no Codex calls).
2. Asks if you want to spawn Codex now. Estimated cost: 15-30 messages on the `gpt-5.5` quota (~25-40 min real time on a ChatGPT Plus account).
3. If yes: builds an Assay-informed prompt that tells Codex to skip findings already covered, and focus on cross-cutting concerns Assay cannot see.
4. Spawns Codex via the [codex-plugin-cc](https://github.com/openai/codex-plugin-cc) `/codex:rescue --background` command.
5. When Codex returns, dedups findings vs Assay, categorizes by severity (BLOCKER / HIGH / NOTE).
6. Writes synthesis to `.audit/AUDIT-SYNTHESIS-<date>.md` (or `.planning/audits/` if RIFF-managed project).
7. Prints summary with recommended next actions tailored to context (RIFF or generic).

## Read-only by design

This skill never edits, deletes, or refactors code. It analyzes, reports, and recommends. Fixes are always your decision based on the synthesis.

## File structure

```
audit-codebase/
├── SKILL.md                       # the skill router (read by Claude Code)
├── references/
│   ├── checklist.md               # AI-Readiness Checklist (scoring rubric, anti-patterns, red flags)
│   ├── mode-ai.md                 # AI-readiness workflow
│   ├── mode-bug.md                # Bug-assessment workflow (Assay)
│   ├── mode-full.md               # Composes ai + bug + combined verdict
│   ├── mode-deep.md               # Full + Codex adversarial + synthesis
│   └── report-templates.md        # All report templates (one per mode)
├── run-assay.sh                   # wrapper for npx tryassay assess (handles 7-day caching)
├── README.md                      # this file
└── LICENSE                        # MIT
```

## Related

- [openai/codex-plugin-cc](https://github.com/openai/codex-plugin-cc) — Codex plugin for Claude Code, required for `deep` mode
- [tryassay](https://www.npmjs.com/package/tryassay) — Static analysis tool used by `bug`, `full`, and `deep` modes
- [Claude Code](https://claude.com/claude-code) — the CLI this skill plugs into

## License

[MIT](LICENSE)

## Author

Alexandra Spalato — [@alexadark](https://github.com/alexadark)
