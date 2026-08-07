#!/usr/bin/env bash
#
# Shoplive iOS SDK release script.
#
#   scripts/release.sh <version> <core.zip> <player.zip> <streamer.zip> [--publish]
#
# What it does
#   1. Validates the three zips (each must hold <Name>.xcframework at its root)
#   2. Computes checksums via `swift package compute-checksum`
#   3. Rewrites the four release-managed values in Package.swift
#   4. Sanity-checks the manifest with `swift package dump-package`
#   5. Commits and tags — locally only
#   6. Pushes and creates the GitHub Release only when --publish is given (hard to undo)
#
# The XCFrameworks themselves are built in the SDK source repo. This repo only ships them.

set -euo pipefail

MODULES=(ShopliveCore ShoplivePlayerSDK ShopliveStreamerSDK)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$REPO_ROOT/Package.swift"

die() { echo "error: $*" >&2; exit 1; }

usage() {
  sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^#\{0,1\} \{0,1\}//'
  exit 1
}

# ---- Arguments ---------------------------------------------------------------

PUBLISH=0
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --publish) PUBLISH=1 ;;
    -h|--help) usage ;;
    *) ARGS+=("$arg") ;;
  esac
done

[ "${#ARGS[@]}" -eq 4 ] || usage

VERSION="${ARGS[0]}"
ZIPS=("${ARGS[1]}" "${ARGS[2]}" "${ARGS[3]}")
TAG="v$VERSION"

[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]] \
  || die "version must be semver (got: $VERSION)"

command -v swift >/dev/null || die "swift is required"
command -v unzip >/dev/null || die "unzip is required"

# ---- Preconditions -----------------------------------------------------------

cd "$REPO_ROOT"
[ -z "$(git status --porcelain)" ] || die "working tree is dirty; commit or stash first"
git rev-parse --verify --quiet "refs/tags/$TAG" >/dev/null && die "tag $TAG already exists"

# ---- Validate zips and compute checksums -------------------------------------

declare -a CHECKSUMS
for i in "${!MODULES[@]}"; do
  module="${MODULES[$i]}"
  zip="${ZIPS[$i]}"

  [ -f "$zip" ] || die "$module: zip not found — $zip"
  [ "$(basename "$zip")" = "$module.xcframework.zip" ] \
    || die "$module: zip must be named $module.xcframework.zip (asset name == the url in Package.swift)"

  # SwiftPM looks for <TargetName>.xcframework at the zip root; otherwise resolution breaks.
  # (Piping into `grep -q` would trip pipefail on SIGPIPE, so read the listing into a variable.)
  entries="$(unzip -Z1 "$zip")"
  grep -qE "^$module\.xcframework/" <<<"$entries" \
    || die "$module: no $module.xcframework at the zip root"

  CHECKSUMS[$i]="$(swift package compute-checksum "$zip")"
  echo "  $module  ${CHECKSUMS[$i]}"
done

# ---- Rewrite Package.swift ---------------------------------------------------

set_manifest_value() {
  local key="$1" value="$2"
  grep -qE "^let $key( )+= " "$MANIFEST" || die "no '$key' line in Package.swift"
  # Only slash-free semver/checksum values get here, so | is safe as the sed delimiter.
  sed -i '' -E "s|^(let $key[[:space:]]*= ).*$|\1\"$value\"|" "$MANIFEST"
}

set_manifest_value sdkVersion       "$VERSION"
set_manifest_value checksumCore     "${CHECKSUMS[0]}"
set_manifest_value checksumPlayer   "${CHECKSUMS[1]}"
set_manifest_value checksumStreamer "${CHECKSUMS[2]}"

swift package dump-package >/dev/null || die "Package.swift failed to parse — check the rewrite"
echo "Package.swift updated ($TAG)"

# ---- Commit and tag ----------------------------------------------------------

git add Package.swift
git commit -q -m "release: $TAG"
git tag -a "$TAG" -m "Shoplive iOS SDK $TAG"
echo "committed and tagged $TAG (local only)"

if [ "$PUBLISH" -eq 0 ]; then
  cat <<EOF

Stopped at the local commit and tag. Review, then run the commands below —
or re-run this script with --publish.

  git push origin HEAD "$TAG"
  gh release create "$TAG" --title "$TAG" --generate-notes ${ZIPS[*]}

EOF
  exit 0
fi

command -v gh >/dev/null || die "--publish requires the gh CLI"

git push origin HEAD "$TAG"
gh release create "$TAG" --title "$TAG" --generate-notes "${ZIPS[@]}"
echo "released $TAG"
