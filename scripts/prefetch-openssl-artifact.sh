#!/bin/bash
#
# prefetch-openssl-artifact.sh
#
# Pre-seeds krzyzanowskim/OpenSSL-Package's binary xcframework into SwiftPM's
# cloned-source-packages directory so package resolution (run by the test build)
# treats it as already resolved and never reaches for it over the network.
#
# Why: that dependency (dragged in by the Kape TunnelKit fork) is a remote
# `.binaryTarget` whose zip lives on GitHub release-assets. SwiftPM's URLSession
# download of it hard-stalls on GitHub Actions macOS runners — no output, no
# progress — until the test step's timeout fires. `curl` fetches the same asset
# fine, so we download + verify + extract it here and write the matching
# workspace-state.json entry; SwiftPM then finds the artifact in place and skips
# the download. Once seeded it is captured by the .build/SourcePackages cache, so
# subsequent runs short-circuit on the cache-hit guard below.
#
# Usage: ./scripts/prefetch-openssl-artifact.sh [SOURCE_PACKAGES_DIR]
#   SOURCE_PACKAGES_DIR defaults to .build/SourcePackages (must match the
#   -clonedSourcePackagesDirPath passed to xcodebuild / run_tests).
#
# Version/URL/checksum are pinned below and must match the openssl-package pin in
# Package.resolved; a mismatch is caught up front (SwiftPM would otherwise reject
# the seed and fall back to the stalling download).

set -euo pipefail

SPM_DIR="${1:-.build/SourcePackages}"

VERSION="3.6.2000"
URL="https://github.com/krzyzanowskim/OpenSSL/releases/download/${VERSION}/OpenSSL.xcframework.zip"
CHECKSUM="37846a8bd302cb2443eff47f1045ab844d0cd40bf82cc6159cfad9aa5c3eff9e"

ART_DIR="$SPM_DIR/artifacts/openssl-package/OpenSSL"
XCF="$ART_DIR/OpenSSL.xcframework"

# ── version-drift guard ─────────────────────────────────────────────────────
RESOLVED="PIA VPN.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
if [ -f "$RESOLVED" ]; then
  WANT="$(/usr/bin/python3 -c '
import json,sys
d=json.load(open(sys.argv[1]))
pins=d.get("pins") or d.get("object",{}).get("pins",[])
print(next((p.get("state",{}).get("version","") for p in pins if p.get("identity")=="openssl-package"), ""))
' "$RESOLVED" 2>/dev/null || true)"
  if [ -n "$WANT" ] && [ "$WANT" != "$VERSION" ]; then
    echo "ERROR: openssl-package is pinned to $WANT in Package.resolved, but this script seeds $VERSION." >&2
    echo "       Update VERSION/URL/CHECKSUM in $0 (see github.com/krzyzanowskim/OpenSSL/releases)." >&2
    exit 1
  fi
fi

# ── cache-hit short-circuit ─────────────────────────────────────────────────
if [ -d "$XCF" ]; then
  echo "OpenSSL.xcframework already present at $XCF — skipping prefetch."
  exit 0
fi

# ── download + verify ───────────────────────────────────────────────────────
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
ZIP="$TMP/OpenSSL.xcframework.zip"

echo "==> Downloading OpenSSL.xcframework $VERSION"
curl -fSL --ipv4 --retry 5 --retry-all-errors --connect-timeout 30 --max-time 300 -o "$ZIP" "$URL"

echo "==> Verifying checksum"
ACTUAL="$(shasum -a 256 "$ZIP" | cut -d' ' -f1)"
[ "$ACTUAL" = "$CHECKSUM" ] || { echo "ERROR: checksum mismatch: got $ACTUAL, expected $CHECKSUM" >&2; exit 1; }

# ── extract into SwiftPM's artifacts layout ─────────────────────────────────
echo "==> Extracting into $ART_DIR"
mkdir -p "$ART_DIR"
unzip -q "$ZIP" -d "$ART_DIR"

# ── record it in workspace-state.json (matches what a real resolve writes) ──
ABS_XCF="$(cd "$ART_DIR" && pwd)/OpenSSL.xcframework"
STATE="$SPM_DIR/workspace-state.json"
/usr/bin/python3 - "$STATE" "$ABS_XCF" "$URL" "$CHECKSUM" <<'PY'
import json, os, sys
state_path, xcf, url, checksum = sys.argv[1:5]
entry = {
    "kind": {"xcframework": {}},
    "packageRef": {
        "identity": "openssl-package",
        "kind": "remoteSourceControl",
        "location": "https://github.com/krzyzanowskim/OpenSSL-Package.git",
        "name": "OpenSSL",
    },
    "path": xcf,
    "source": {"checksum": checksum, "type": "remote", "url": url},
    "targetName": "OpenSSL",
}
if os.path.exists(state_path):
    doc = json.load(open(state_path))
else:
    doc = {"version": 7, "object": {"dependencies": [], "prebuilts": [], "artifacts": []}}
obj = doc.setdefault("object", {})
obj.setdefault("dependencies", [])
obj.setdefault("prebuilts", [])
obj["artifacts"] = [a for a in obj.get("artifacts", []) if a.get("targetName") != "OpenSSL"] + [entry]
json.dump(doc, open(state_path, "w"), indent=2)
print("seeded", state_path)
PY

echo "==> Done: seeded OpenSSL.xcframework at $XCF"
