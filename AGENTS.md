## Change log workflow

### Files
- **`readMeChanges.md`** (repo root) — living “what changed” readme. **Newest entry always at the top.**
- **`readMeChanges-archive/`** (optional) — older major versions when the main file gets long (e.g. `v1.2.md`, `v1.1.md`).

### When planning (before the plan is written)
At the **start of every plan**, ask once:

> **Is this change major or minor?**
> - **Major** — user-visible behavior, schema/migration, breaking or risky flows, new feature area, or multi-file UX shift.
> - **Minor** — small fix, copy tweak, single-screen polish, internal refactor with no user-facing change.

Do not guess. Wait for the answer before finishing the plan.

### After the plan is approved (before or right after build)
1. Add a new entry at the **top** of `readMeChanges.md`.
2. Use this shape:

```markdown
## [Unreleased] — YYYY-MM-DD — {Major|Minor}
**Summary:** one line
**Plan:** link or short name (e.g. Finance UX Phase 2)
**In scope:** bullets
**Not in scope:** bullets (if any)