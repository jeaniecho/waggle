# Claude Code Workflow

Use this workflow for each implementation task.

## 1. Plan

Write a short plan:
- Goal
- Files to create/change
- Risks
- Verification steps

## 2. Implement

Make the smallest coherent change.

Prefer:
- Runnable increments
- Focused files
- Explicit state
- Native APIs

## 3. Verify

Run build/checks where possible.

If unable to run:
- State the command that should be run.
- State why it could not be run.

## 4. Document

Update:
- Relevant task file
- Relevant spec
- Build notes if commands change
- ADR only if an architectural decision changes

## Change Size

Avoid huge all-in-one changes.

Good task size:
- One feature slice
- One manager
- One UI behavior

Bad task size:
- Overlay + input + timers + sprites in one pass
