#!/usr/bin/env bash
set -euo pipefail

# Regenerate the project from project.yml (if XcodeGen is installed), run unit
# tests, and build the macOS target. Visual overlay behavior still requires the
# manual checks in docs/engineering/BUILD.md.

if command -v xcodegen >/dev/null 2>&1; then
  echo "Regenerating Waggle.xcodeproj from project.yml..."
  xcodegen generate
else
  echo "xcodegen not found; building existing Waggle.xcodeproj."
fi

echo "Running Waggle unit tests..."
xcodebuild \
  -project Waggle.xcodeproj \
  -scheme Waggle \
  -destination 'platform=macOS' \
  -configuration Debug \
  test

echo "Building Waggle (Debug)..."
xcodebuild \
  -project Waggle.xcodeproj \
  -scheme Waggle \
  -destination 'platform=macOS' \
  -configuration Debug \
  build
