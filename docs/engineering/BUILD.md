# Build Guide

## Requirements

- macOS 12+
- A recent Xcode release with the macOS SDK
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) when changing `project.yml`

Waggle has no third-party runtime dependencies.

## Generate, test, and build

`project.yml` is the source of truth. The generated project is committed so a
contributor can build without installing XcodeGen.

```bash
xcodegen generate       # when project.yml changes
./scripts/verify.sh      # unit tests + Debug build
open Waggle.xcodeproj
```

Equivalent direct commands:

```bash
xcodebuild -project Waggle.xcodeproj -scheme Waggle \
  -destination 'platform=macOS' -configuration Debug test

xcodebuild -project Waggle.xcodeproj -scheme Waggle \
  -destination 'platform=macOS' -configuration Debug build
```

Run the `Waggle` scheme from Xcode, or open the built application from Xcode's
Products group. Quit with Cmd-Q.

## Signing

`Config/Signing.xcconfig` contains public ad-hoc defaults and intentionally has
no developer team or certificate identity. For a stable local signature:

```bash
cp Config/LocalSigning.xcconfig.example Config/LocalSigning.xcconfig
```

Fill the ignored copy with your own Apple Development team and identity. A
stable signature is useful because macOS associates Accessibility grants with
the signed application. Release packaging is separate: `scripts/package.sh`
accepts a Developer ID identity from the local keychain or `DEVID` environment
variable and never requires committing it.

## Manual verification

1. Launch the app; the dog and menu-bar item appear without a standard document window.
2. Drag the dog, relaunch, and confirm its position is restored.
3. Move the cursor near/far and confirm the dog reacts and settles.
4. Enable Accessibility, type, and confirm generic ear/typing reactions.
5. Disable typing reactions and confirm typing no longer changes the dog.
6. Trigger a short Pomodoro configuration and confirm focus/break visuals.
7. Confirm stretch, pause-all-reactions, notification, and show/hide controls.
