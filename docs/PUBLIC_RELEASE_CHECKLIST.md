# Public Release Checklist

The repository is intentionally still private. Do not change visibility, the
remote default branch, or history without an explicit approval step.

## Completed in the preparation pass

- README describes the implemented app, build/test steps, architecture, and privacy boundary.
- Personal signing values were removed from the current tree and replaced by an ignored local override.
- Typing events are content-free; disabling reactions removes their event monitors.
- State priority and Pomodoro transitions have unit tests.
- The generated Xcode project matches `project.yml`.
- Tasks, roadmap, privacy, build, release, and development guidance reflect current behavior.
- A static preview rendered from the production SwiftUI view is included.
- `main` was created from the reviewed preparation commit and pushed while the
  repository remained private. The remote default is still `feat/dog-overlay`.

## History and privacy decision

A value-redacting heuristic scan covered the original 112 commits. It found no private
key blocks or recognizable AWS, GitHub, OpenAI, Slack, Stripe, Google, or bearer
tokens. It did find historical personal code-signing identifiers in project
configuration and a non-noreply author identity in commit metadata. The new
preparation commits also use a personal author email.

Removing those historical identifiers would require a history rewrite (or a
fresh sanitized repository). Neither has been performed. Repeat the scan with a
dedicated secret-scanning tool before publication; heuristic scans are not a
guarantee.

## Branch transition options

### Preserve history

1. Add CI and branch protection, then verify a clean clone of `main`.
2. With explicit approval, change the remote default branch to `main`.
3. With separate explicit approval, change repository visibility.

This is the simplest route, but it publishes the historical signing identifiers
and author metadata described above.

### Sanitize history

The lowest-risk public portfolio option is a new public repository containing a
single reviewed snapshot, while the current repository remains private. If the
same repository must be used, back it up and use a reviewed history-rewrite plan
for both file content and author metadata, then force-update remote refs only
after explicit approval. A branch rename alone does not remove old history.

## Still required before public visibility

- Choose a license and add `LICENSE`; none is selected by this pass.
- Record a live demo and final screenshots.
- Manually verify multi-display placement, Accessibility onboarding/revocation,
  pause/re-enable behavior, launch at login, and notifications.
- Produce a Developer ID signed and notarized release; verify Gatekeeper on a clean Mac.
- Decide ZIP vs DMG and whether signed auto-updates are in scope.
- Add CI for generation drift, tests, and Debug/Release builds.
- Review repository description, topics, social preview, issue templates, and contribution/security guidance.
- Complete or explicitly defer the partial idle-breathing and Pomodoro daily-count tasks.
