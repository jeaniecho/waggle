# Releasing / Sharing Waggle

Waggle is distributed outside the App Store, so to let anyone open it with a
normal double-click (no Gatekeeper warning) the app must be **signed with a
Developer ID Application certificate and notarized** by Apple.

## One-time setup

### 1. Create a "Developer ID Application" certificate
You currently only have *Apple Development* certificates (fine for local dev,
not for distribution). Create the Developer ID one:

- Xcode ▸ **Settings ▸ Accounts** ▸ select your team ▸ **Manage Certificates…**
  ▸ **＋** ▸ **Developer ID Application**.
- or developer.apple.com ▸ Certificates ▸ ＋ ▸ *Developer ID Application*.

Note: creating Developer ID certs requires the **Account Holder** role on the
team. If you belong to more than one team, create it under whichever team you
want to ship under.

Verify it landed in your keychain:
```bash
security find-identity -v -p codesigning | grep "Developer ID Application"
```

### 2. Store notary credentials
Create an **app-specific password** at https://account.apple.com (Sign-In &
Security ▸ App-Specific Passwords), then:
```bash
xcrun notarytool store-credentials waggle-notary \
  --apple-id "you@example.com" \
  --team-id  "YOURTEAMID" \
  --password "abcd-efgh-ijkl-mnop"
```
This saves a reusable keychain profile named `waggle-notary`.

## Build a distributable

```bash
./scripts/package.sh
```

This builds a Release **universal** binary (Apple Silicon + Intel), signs it
with Developer ID + hardened runtime + a secure timestamp, submits it to Apple's
notary service, staples the ticket, and writes:

```
dist/Waggle.zip
```

Send that zip to anyone — they unzip and double-click; macOS verifies the
stapled notarization and opens it normally.

## Notes

- **Deployment target:** macOS 12+.
- **Accessibility:** the typing reaction needs Accessibility permission, which
  each user grants on their own Mac (right-click the dog ▸ "Enable typing
  reactions…"). Everything else works without it.
- **No entitlements file needed:** Waggle isn't sandboxed and uses no
  capabilities that require entitlements; global event monitoring is gated by
  the user's Accessibility grant at runtime.
- **Local dev signing is unchanged:** `project.yml` keeps the Apple Development
  identity so the Accessibility grant persists across local rebuilds. The
  packaging script overrides signing to Developer ID only for distribution.
