# AI-Ready Codebase Checklist

> Based on Matt Pocock's "Your codebase is NOT ready for AI" (Feb 2026)
> Core concept: Deep modules from "A Philosophy of Software Design" by John Ousterhout

## The Core Insight

AI has no memory of your codebase. Every session, it's a new starter walking in blind.
Your codebase architecture - not your prompts - is the biggest influence on AI output quality.

---

## Checklist

### 1. File System Matches Mental Model

- [ ] Feature groupings are reflected in the folder structure (not just in your head)
- [ ] Related modules live together in clearly named directories
- [ ] A new developer (or AI) can understand the codebase map by reading the file tree
- [ ] No "junk drawer" folders where unrelated modules are dumped together

### 2. Deep Modules Over Shallow Modules

- [ ] Each major feature/service is a single deep module (lots of implementation, simple interface)
- [ ] Public API (exports) is small and well-defined for each module
- [ ] Internal implementation details are hidden behind the interface
- [ ] Avoid many tiny interconnected modules that create a web of dependencies

**Deep module pattern:**

```
service/
  index.ts          # Public interface (simple, well-typed exports)
  internal/         # Implementation details (AI manages this)
  __tests__/        # Tests that lock down behavior
```

**Anti-pattern (shallow modules):**

```
utils/
  formatDate.ts     # Tiny module
  parseUrl.ts       # Tiny module
  validateEmail.ts  # Tiny module
  ... 50 more tiny files all importing each other
```

### 3. Clear Module Boundaries

- [ ] Each module/service has a clearly defined public interface
- [ ] Cross-module imports only go through the public interface (not reaching into internals)
- [ ] Dependencies between modules are explicit, not implicit
- [ ] Barrel files or index exports make the interface obvious

### 4. Progressive Disclosure of Complexity

- [ ] AI can understand what a module does by reading only the interface (types, exports)
- [ ] AI doesn't need to read implementation to use a module
- [ ] Documentation exists at the module level (README or JSDoc on exports)
- [ ] Type definitions serve as self-documenting contracts

### 5. Graybox Modules (AI-Delegatable)

- [ ] Module internals can be changed without affecting other parts of the codebase
- [ ] Tests validate behavior at the interface level (not implementation details)
- [ ] AI can safely modify implementation as long as tests pass
- [ ] You only need to look inside a module when applying taste or optimizing performance

### 6. Tests and Feedback Loops

- [ ] Tests exist for each module's public behavior
- [ ] Tests run fast enough to give AI immediate feedback
- [ ] AI can verify its changes didn't break anything
- [ ] Test failures clearly indicate what went wrong (good error messages)

### 7. Planning With Modules in Mind

- [ ] PRDs and specs reference which modules are affected
- [ ] Implementation issues describe interface changes explicitly
- [ ] New features are planned as additions to existing modules or new deep modules
- [ ] Testing strategy is defined before implementation starts

---

## Quick Score

| Criterion                  | Score (0-3) | Notes |
| -------------------------- | ----------- | ----- |
| File system = mental model |             |       |
| Deep modules (not shallow) |             |       |
| Clear module boundaries    |             |       |
| Progressive disclosure     |             |       |
| Graybox (AI-delegatable)   |             |       |
| Tests & feedback loops     |             |       |
| Planning includes modules  |             |       |
| **Total**                  | **/21**     |       |

**Rating:**

- 18-21: AI-ready - your codebase will get strong results from AI coding tools
- 12-17: Partially ready - specific areas need restructuring
- 6-11: Not ready - significant architectural work needed before AI will be effective
- 0-5: AI-hostile - expect poor results, high cognitive burnout, and wasted time

---

## Red Flags (Things That Make a Codebase AI-Hostile)

1. **Web of shallow modules** - dozens of tiny files all importing from each other
2. **No enforced boundaries** - any file can import from any other file
3. **Mental model only in your head** - file structure doesn't reflect logical groupings
4. **No tests** - AI has no way to verify its changes work
5. **Slow feedback loops** - tests take minutes to run, blocking AI iteration
6. **Implicit relationships** - modules depend on each other through side effects or global state

## Key Takeaway

> "What works for humans is also great for AI. Software quality matters more than ever."

Design your codebase as if you're onboarding 20 new developers every day - because with AI, you are.

---

_Source: [Matt Pocock - Your codebase is NOT ready for AI](https://youtu.be/uC44zFz7JSM)_
_Book reference: "A Philosophy of Software Design" by John Ousterhout_
