# Testing intuitions

Lessons for writing and reviewing tests. Add a dated entry after a review catch or postmortem — not every passing green run.

## Regression oracles must follow failure order (APPS-5230, 2026-11-24)

**Trap:** The story *title* describes the user path (`Loading → results`), but the *setup* starts later (e.g. results already on screen). The assertion still “checks the bug,” yet **passes on base without the fix** because early state pre-seeds the good outcome.

**Example (sticky column width after Loading):**

| Setup | Why it lies |
|--------|-------------|
| Mount **with results** (wide), then Loading → results, assert widths match | Broken code can **keep** wide `colWidths` from the first mount through Loading. Parity passes; remeasure never had to recover from a loading-era measure. |
| **Loading** first → deliver results → measure → **cold remount** with same row → compare | After loading-era measure, width must widen; cold mount is an independent oracle. Fails on base, passes with deps unlock + remeasure. |

**Checklist (bug-fix Storybook / e2e / component tests):**

1. **Order:** First on-screen state must be **before** the trigger (loading row, empty list, narrow layout, etc.).
2. **Green on fix branch** is insufficient.
3. **Red on base:** Run the same story or test on the **default branch without the fix** (or temporarily revert the fix). If it still passes, the oracle is wrong — fix setup, not the product.
4. **Parity asserts** (`A ≈ B`): neither path may initialize the state the bug corrupts. Independent paths (e.g. remount / fresh tree / new session).

**Promotion:** Repeatable pattern → repo `AGENTS.md` or team doc; one-off → this file.