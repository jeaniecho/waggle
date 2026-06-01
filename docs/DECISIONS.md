# Architecture Decisions

## ADR-001 — Use SwiftUI + AppKit

Decision:
Use SwiftUI for UI rendering and AppKit for windowing/system behavior.

Reason:
Transparent always-on-top desktop overlays require AppKit-level control. SwiftUI is still useful for state-driven dog rendering.

Status:
Accepted

## ADR-002 — macOS Only for MVP

Decision:
Target macOS only.

Reason:
Desktop overlay behavior, accessibility permissions, and global event monitoring differ heavily across platforms. macOS-only keeps the MVP focused.

Status:
Accepted

## ADR-003 — Local-First

Decision:
No backend, accounts, cloud sync, or analytics.

Reason:
The MVP does not require a server. Local-first improves privacy and development speed.

Status:
Accepted

## ADR-004 — Pixel-Art Dog

Decision:
Use pixel-art dog visuals.

Reason:
Pixel art fits desktop pet expectations, works well at small sizes, and keeps animation scope manageable.

Status:
Accepted

## ADR-005 — UserDefaults for MVP Settings

Decision:
Use UserDefaults for local settings.

Reason:
Settings are simple and low-risk: position, timer durations, and feature toggles.

Status:
Accepted

## ADR-006 — Separate Semantic State from Animation State

Decision:
Use separate `DogState` and `DogAnimationState`.

Reason:
Semantic behavior and visual rendering evolve independently. This prevents UI assets from controlling product logic.

Status:
Accepted

## ADR-007 — No External Dependencies for MVP

Decision:
Avoid third-party dependencies.

Reason:
Native APIs are sufficient for the MVP. Fewer dependencies reduce maintenance and setup complexity.

Status:
Accepted
