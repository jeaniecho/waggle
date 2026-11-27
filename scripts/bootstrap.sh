#!/usr/bin/env bash
set -euo pipefail

echo "Waggle bootstrap"
if command -v xcodegen >/dev/null 2>&1; then
  echo "Regenerating Waggle.xcodeproj from project.yml..."
  xcodegen generate
else
  echo "xcodegen not found; using the committed Waggle.xcodeproj."
fi
echo ""
echo "Next:"
echo "  ./scripts/verify.sh"
echo "  open Waggle.xcodeproj"
echo ""
echo "No runtime dependencies are required."
