# Waggle

A tiny, local-first macOS desktop dog that reacts while you work and gently
helps with focus and stretch breaks.

![Waggle states rendered from the production SwiftUI view](docs/assets/waggle-states.png)

## What works

- Transparent, always-on-top `NSPanel` overlay with drag-and-drop positioning
- Cursor direction, proximity, and idle/sleep reactions
- Privacy-preserving typing activity reaction with an 800 ms debounce
- Stretch reminders, system notifications, and configurable intervals
- Pomodoro focus, short break, long break, pause/resume, and session counting
- Menu bar controls, Settings, first-run onboarding, coat colours, and launch at login
- Local persistence with `UserDefaults`; no account, backend, analytics, or telemetry

The preview above is generated directly from `DogSpriteView` with
`scripts/render_demo.swift`. For the live behavior, run the app and move the
cursor near the dog, type with the optional permission enabled, or start a
Pomodoro from the menu bar.

## Requirements

- macOS 12 or later
- A recent Xcode release with the macOS SDK
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) only when regenerating the project (`brew install xcodegen`)

There are no runtime package dependencies.

## Build and test

```bash
git clone https://github.com/jeaniecho/waggle.git
cd waggle
./scripts/verify.sh
open Waggle.xcodeproj
```

`project.yml` is the source of truth and `Waggle.xcodeproj` is committed for
convenience. The verification script regenerates it when XcodeGen is available,
then runs the unit tests and a Debug build.

By default, development builds use repository-safe ad-hoc signing. If you want
a stable Apple Development signature so macOS keeps the Accessibility grant
across rebuilds, copy `Config/LocalSigning.xcconfig.example` to
`Config/LocalSigning.xcconfig` and fill in your own values. That local file is
ignored by Git.

## Optional Accessibility permission

Only the global typing reaction needs Accessibility access:

```text
System Settings > Privacy & Security > Accessibility
```

Waggle remains usable without it. Disabling a reaction removes its event
monitor immediately; Pause All Reactions also removes the click monitors.

## Privacy

Typing events are treated as content-free activity signals: Waggle does not
read `characters`, key codes, modifiers, application names, or window titles.
It never stores keystrokes, cursor history, documents, screenshots, or behavior
analytics. Cursor coordinates are used in memory only to face the dog toward
the current pointer position. All preferences stay in `UserDefaults`, and the
app makes no network requests.

See [the privacy design](docs/engineering/PRIVACY.md) for the exact data boundary.

## Design

AppKit owns the transparent floating panel and global event monitors. SwiftUI
renders the dog and settings. `DogViewModel` resolves competing signals in this
order:

```text
dragging > stretching > Pomodoro break > Pomodoro focus > typing > cursor > sleep/idle
```

Timer and input managers publish semantic signals; the view model selects one
state and maps it to a visual animation. See [the architecture](docs/ARCHITECTURE.md).

## Project status

The native MVP is implemented and builds locally. Remaining public-release work
includes a license decision, release signing/notarization, a recorded live demo,
localization, and final distribution choices. The repository is currently
private; visibility is intentionally managed outside this codebase.

See [the public release checklist](docs/PUBLIC_RELEASE_CHECKLIST.md) for the
history findings and `main` transition options.

## License

No open-source license has been selected yet. Until a license file is added,
the source is not granted for reuse, modification, or redistribution.
