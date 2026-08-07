#!/bin/bash
#
# pull-kape-platform-sdk.sh
#
# Pulls the KapePlatformSDK Swift package from the Cloudsmith Swift registry
# (expressvpn/kp_platform_sdks_dev) and unpacks it as a *local* Swift package at
# LocalPackages/KapePlatformSDK/. That directory is gitignored — it is never
# committed; every machine (and CI) populates it by running this script.
#
# Why vendor instead of consuming the registry package directly?
#   The published archive is self-contained: it bundles its sub-packages
#   (KapeClientSDKPackage, LightwayPackage, WireGuardKitPackage incl. the
#   prebuilt WireGuardKitGo.xcframework, and TunnelKitPackage) and references
#   them with `path:` dependencies. SwiftPM forbids a package consumed at a
#   stable registry version from having path/branch/revision dependencies
#   ("…depends on an unstable-version package…"), so it cannot be added as a
#   normal SPM registry dependency. Unpacked locally it resolves cleanly, and
#   Xcode picks it up via the existing LocalPackages synchronized folder group.
#
# Auth:
#   Needs a Cloudsmith entitlement token with read access to the repo. Resolved
#   in order: $CLOUDSMITH_TOKEN -> $CLOUDSMITH_API_KEY -> a `.cloudsmith` file in
#   the repo root (gitignored; contains just the token).
#
# Version:
#   Read from scripts/kape-platform-sdk.version (committed pin). Override with
#   $KAPE_PLATFORM_SDK_VERSION. To list what the registry offers:
#     curl -fsSL -H 'Accept: application/vnd.swift.registry.v1+json' \
#       -H "Authorization: Bearer $TOKEN" \
#       https://swift.cloudsmith.io/expressvpn/kp_platform_sdks_dev/KapePlatformSDK/KapePlatformSDK
#
# Integrity:
#   The archive's SHA-256 is pinned in scripts/kape-platform-sdk.checksum
#   (committed alongside the version pin; --update refreshes both). The pin is
#   the trust anchor when pulling the pinned version; for any other version the
#   checksum from the registry release metadata is required instead. There is
#   no unverified install path: a missing or mismatching checksum always fails.
#
# Archive cache:
#   Set $KAPE_SDK_ARCHIVE_CACHE to a directory to keep/reuse the downloaded
#   .zip (used by CI to cache the *archive*, so the checksum is re-verified on
#   every run — caching the unpacked package would skip verification).
#
# Usage:
#   CLOUDSMITH_TOKEN=<token> ./scripts/pull-kape-platform-sdk.sh
#   ./scripts/pull-kape-platform-sdk.sh            # with a .cloudsmith file present
#   ./scripts/pull-kape-platform-sdk.sh --update   # fetch latest from registry, update version+checksum pins, then pull

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REGISTRY="https://swift.cloudsmith.io/expressvpn/kp_platform_sdks_dev"
SCOPE="KapePlatformSDK"
NAME="KapePlatformSDK"
DEST="$REPO_ROOT/LocalPackages/KapePlatformSDK"
ARCHIVE_ROOT="KapePlatformSDKPackage"        # top-level dir inside the .zip
VERSION_FILE="$REPO_ROOT/scripts/kape-platform-sdk.version"
CHECKSUM_FILE="$REPO_ROOT/scripts/kape-platform-sdk.checksum"
STAMP="$DEST/.kape-pulled-version"

die() { echo "ERROR: $*" >&2; exit 1; }

# ── flags ─────────────────────────────────────────────────────────────────
UPDATE_LATEST=0
for arg in "$@"; do
  case "$arg" in
    --update|-u) UPDATE_LATEST=1 ;;
    *) die "unknown argument: $arg" ;;
  esac
done

# ── token ─────────────────────────────────────────────────────────────────
TOKEN="${CLOUDSMITH_TOKEN:-${CLOUDSMITH_API_KEY:-}}"
if [ -z "$TOKEN" ] && [ -f "$REPO_ROOT/.cloudsmith" ]; then
  TOKEN="$(tr -d ' \t\r\n' < "$REPO_ROOT/.cloudsmith")"
fi
[ -n "$TOKEN" ] || die "no Cloudsmith token: set CLOUDSMITH_TOKEN / CLOUDSMITH_API_KEY, or create $REPO_ROOT/.cloudsmith"

AUTH="Authorization: Bearer $TOKEN"

# ── version ───────────────────────────────────────────────────────────────
VERSION="${KAPE_PLATFORM_SDK_VERSION:-}"

if [ "$UPDATE_LATEST" = "1" ]; then
  echo "==> Fetching latest available version from registry"
  # Use the Cloudsmith native REST API (sort=-date = newest upload first).
  # The Swift registry listing endpoint has no defined ordering for hash-suffixed versions,
  # and the /latest pseudo-version endpoint can point to stale releases.
  CLOUDSMITH_ORG="$(printf '%s' "$REGISTRY" | awk -F/ '{print $(NF-1)}')"
  CLOUDSMITH_REPO="$(printf '%s' "$REGISTRY" | awk -F/ '{print $NF}')"
  LATEST_VERSION="$(curl -fsSL \
    -H "Authorization: Token $TOKEN" \
    "https://api.cloudsmith.io/v1/packages/$CLOUDSMITH_ORG/$CLOUDSMITH_REPO/?q=name%3A$NAME&sort=-date&page_size=1" \
    | /usr/bin/python3 -c \
'import sys,json
pkgs=json.load(sys.stdin)
if not pkgs: sys.exit(1)
print(pkgs[0]["version"])' 2>/dev/null)" \
    || die "could not fetch latest version from Cloudsmith API (check token / network)"
  [ -n "$LATEST_VERSION" ] || die "no versions found in registry"
  PINNED_VERSION="$(tr -d ' \t\r\n' < "$VERSION_FILE" 2>/dev/null || true)"
  if [ "$PINNED_VERSION" = "$LATEST_VERSION" ]; then
    echo "==> Already pinned to latest ($LATEST_VERSION)"
  else
    echo "==> Latest version: $LATEST_VERSION (was: ${PINNED_VERSION:-none})"
    echo "$LATEST_VERSION" > "$VERSION_FILE"
    echo "==> Updated $VERSION_FILE"
  fi
  VERSION="$LATEST_VERSION"
fi

if [ -z "$VERSION" ]; then
  [ -f "$VERSION_FILE" ] || die "no version: set KAPE_PLATFORM_SDK_VERSION or create $VERSION_FILE"
  VERSION="$(tr -d ' \t\r\n' < "$VERSION_FILE")"
fi
[ -n "$VERSION" ] || die "empty version"

BASE="$REGISTRY/$SCOPE/$NAME/$VERSION"

# ── idempotency ────────────────────────────────────────────────────────────
if [ -f "$STAMP" ] && [ "$(cat "$STAMP" 2>/dev/null)" = "$VERSION" ] && [ -f "$DEST/Package.swift" ]; then
  echo "KapePlatformSDK $VERSION already present at LocalPackages/KapePlatformSDK — skipping."
  echo "(delete $STAMP or run with KAPE_PLATFORM_SDK_VERSION set to force a re-pull.)"
  exit 0
fi

# ── expected checksum ────────────────────────────────────────────────────────
# Trust anchor is the committed pin when pulling the pinned version; otherwise
# (version override, --update) the registry release metadata must provide one.
# Fail closed: no expected checksum means no install.
EXPECTED_SHA=""
if [ "$UPDATE_LATEST" = "0" ] && [ "$VERSION" = "$(tr -d ' \t\r\n' < "$VERSION_FILE" 2>/dev/null || true)" ] \
  && [ -f "$CHECKSUM_FILE" ]; then
  EXPECTED_SHA="$(tr -d ' \t\r\n' < "$CHECKSUM_FILE")"
fi
if [ -z "$EXPECTED_SHA" ]; then
  echo "==> KapePlatformSDK $VERSION — fetching release metadata"
  META="$(curl -fsSL -H 'Accept: application/vnd.swift.registry.v1+json' -H "$AUTH" "$BASE")" \
    || die "could not fetch metadata (check token / version '$VERSION' / network)"
  EXPECTED_SHA="$(printf '%s' "$META" | /usr/bin/python3 -c \
    'import sys,json; d=json.load(sys.stdin); print(next((r.get("checksum","") for r in d.get("resources",[]) if r.get("name")=="source-archive"), ""))' 2>/dev/null || true)"
fi
[ -n "$EXPECTED_SHA" ] \
  || die "no expected checksum for $VERSION (no pin in $CHECKSUM_FILE and none in registry metadata); refusing to install unverified archive"

# ── download (optionally via archive cache) ──────────────────────────────────
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
if [ -n "${KAPE_SDK_ARCHIVE_CACHE:-}" ]; then
  mkdir -p "$KAPE_SDK_ARCHIVE_CACHE"
  ZIP="$KAPE_SDK_ARCHIVE_CACHE/KapePlatformSDK-$VERSION.zip"
else
  ZIP="$TMP/kape-platform-sdk.zip"
fi
if [ -f "$ZIP" ]; then
  echo "==> Using cached archive: $ZIP"
else
  echo "==> Downloading source archive"
  curl -fSL --progress-bar -H 'Accept: application/vnd.swift.registry.v1+zip' -H "$AUTH" -o "$ZIP" "$BASE.zip" \
    || { rm -f "$ZIP"; die "download failed"; }
fi

# ── verify checksum (always — cached archives included) ──────────────────────
ACTUAL_SHA="$(shasum -a 256 "$ZIP" | cut -d' ' -f1)"
if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
  rm -f "$ZIP"  # never leave a bad archive where a later run could reuse it
  die "checksum mismatch: expected $EXPECTED_SHA, got $ACTUAL_SHA"
fi
echo "==> Checksum OK ($ACTUAL_SHA)"

if [ "$UPDATE_LATEST" = "1" ]; then
  echo "$ACTUAL_SHA" > "$CHECKSUM_FILE"
  echo "==> Updated $CHECKSUM_FILE"
fi

# ── unpack ──────────────────────────────────────────────────────────────────
echo "==> Unpacking into LocalPackages/KapePlatformSDK"
unzip -q "$ZIP" -d "$TMP/x"
SRC="$TMP/x/$ARCHIVE_ROOT"
if [ ! -f "$SRC/Package.swift" ]; then
  found="$(find "$TMP/x" -maxdepth 3 -name Package.swift | head -1 || true)"
  [ -n "$found" ] || die "Package.swift not found in archive"
  SRC="$(dirname "$found")"
fi

rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$SRC/." "$DEST/"
echo "$VERSION" > "$STAMP"

echo "==> Done: KapePlatformSDK $VERSION installed at LocalPackages/KapePlatformSDK"
