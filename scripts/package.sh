#!/usr/bin/env bash
set -euo pipefail

# Build, sign (Developer ID), notarize, and staple Waggle into a distributable
# zip that opens with a normal double-click on any Mac (no Gatekeeper warning).
#
# One-time prerequisites:
#   1. A "Developer ID Application" certificate in your login keychain.
#      Xcode ▸ Settings ▸ Accounts ▸ (your team) ▸ Manage Certificates ▸ +
#        ▸ "Developer ID Application"
#      (or https://developer.apple.com/account/resources/certificates — needs
#       the Account Holder role).
#   2. Stored notary credentials (an app-specific password works):
#        xcrun notarytool store-credentials waggle-notary \
#          --apple-id "you@example.com" \
#          --team-id  "YOURTEAMID" \
#          --password "abcd-efgh-ijkl-mnop"   # app-specific pw from account.apple.com
#
# Usage:
#   ./scripts/package.sh
#   # or override detection:
#   DEVID="Developer ID Application: Your Name (TEAMID)" NOTARY_PROFILE=waggle-notary ./scripts/package.sh

PROJECT="Waggle.xcodeproj"
SCHEME="Waggle"
CONFIG="Release"
APP_NAME="Waggle"
DIST_DIR="dist"
NOTARY_PROFILE="${NOTARY_PROFILE:-waggle-notary}"

# Auto-detect the Developer ID Application identity if not provided.
if [ -z "${DEVID:-}" ]; then
  DEVID="$(security find-identity -v -p codesigning \
    | grep "Developer ID Application" | head -1 \
    | sed -E 's/^[^"]*"([^"]*)".*$/\1/')"
fi
if [ -z "${DEVID:-}" ]; then
  echo "error: No 'Developer ID Application' certificate found." >&2
  echo "       Create one in Xcode ▸ Settings ▸ Accounts ▸ Manage Certificates, then retry." >&2
  exit 1
fi

echo "==> Signing identity: $DEVID"
DERIVED="$(mktemp -d)"
trap 'rm -rf "$DERIVED"' EXIT

echo "==> Building $CONFIG (universal, hardened runtime, secure timestamp)…"
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIG" \
  -derivedDataPath "$DERIVED" \
  -destination 'generic/platform=macOS' \
  ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$DEVID" \
  PROVISIONING_PROFILE_SPECIFIER="" \
  ENABLE_HARDENED_RUNTIME=YES \
  OTHER_CODE_SIGN_FLAGS="--timestamp" \
  build

APP="$DERIVED/Build/Products/$CONFIG/$APP_NAME.app"
[ -d "$APP" ] || { echo "error: built app not found at $APP" >&2; exit 1; }

mkdir -p "$DIST_DIR"
ZIP="$DIST_DIR/$APP_NAME.zip"

echo "==> Zipping for notarization…"
/usr/bin/ditto -c -k --keepParent "$APP" "$ZIP"

echo "==> Submitting to Apple notary service (a few minutes)…"
xcrun notarytool submit "$ZIP" --keychain-profile "$NOTARY_PROFILE" --wait

echo "==> Stapling the ticket onto the app…"
xcrun stapler staple "$APP"

echo "==> Re-zipping the stapled app for distribution…"
/usr/bin/ditto -c -k --keepParent "$APP" "$ZIP"

echo "==> Verifying signature + Gatekeeper acceptance…"
codesign --verify --strict --verbose=2 "$APP"
spctl -a -vvv "$APP" || true
xcrun stapler validate "$APP" || true

echo
echo "✅ Done. Share this file: $ZIP"
