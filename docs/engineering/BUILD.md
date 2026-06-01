# Build Guide

## Requirements

- macOS 12+
- Xcode
- Swift

## Local Development

Open the Xcode project:

```bash
open Waggle.xcodeproj
```

Run the macOS target from Xcode.

## Command-Line Build

Once the Xcode project exists, document the exact command here.

Expected format:

```bash
xcodebuild -project Waggle.xcodeproj -scheme Waggle -destination 'platform=macOS' build
```

## Manual Verification

After each milestone, verify:

1. App launches.
2. No unexpected standard window appears.
3. Dog overlay appears.
4. Overlay is transparent.
5. Dog can be dragged.
6. Quit works from app/menu bar.
