# Build Guide

## Requirements

- macOS 12+
- Xcode (project generated/verified with Xcode 26)
- Swift
- [XcodeGen](https://github.com/yonatan/XcodeGen) — `brew install xcodegen` (only needed to regenerate the project)

## Project Generation

The Xcode project is generated from `project.yml` (the source of truth) using
XcodeGen. `Waggle.xcodeproj` is committed for convenience, but if it is missing
or `project.yml` changes, regenerate it:

```bash
xcodegen generate
```

## Local Development

Open the Xcode project:

```bash
open Waggle.xcodeproj
```

Select the `Waggle` scheme and run the macOS target from Xcode.

## Command-Line Build

```bash
xcodebuild -project Waggle.xcodeproj -scheme Waggle -destination 'platform=macOS' -configuration Debug build
```

## Run from Command Line

```bash
open ~/Library/Developer/Xcode/DerivedData/Waggle-*/Build/Products/Debug/Waggle.app
```

(Or just Run from Xcode.) Quit with Cmd-Q.

## Manual Verification

After each milestone, verify:

1. App launches.
2. No unexpected standard window appears.
3. Dog overlay appears (placeholder pixel dog, bottom-right by default).
4. Overlay is transparent and floats above other windows.
5. Dog can be dragged (click-and-drag the dog to move it).
6. Dog position persists: drag the dog, quit (Cmd-Q), relaunch — it reappears
   where it was left.
7. Quit works from the app menu (Cmd-Q).
