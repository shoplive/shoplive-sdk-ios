#!/usr/bin/env bash
#
# Shoplive iOS SDK release script.
#
#   scripts/release.sh <version> <zips-dir> [--no-tag] [--publish]
#
# What it does
#   1. Finds <Module>.xcframework.zip for every module in <zips-dir> and validates each
#      (the zip must hold <Module>.xcframework at its root)
#   2. Computes checksums via `swift package compute-checksum`
#   3. Rewrites the release-managed values in Package.swift
#   4. Sanity-checks the manifest with `swift package dump-package`
#   5. Commits and tags — locally only
#   6. Pushes and creates the GitHub Release only when --publish is given (hard to undo)
#
# --no-tag stops after the commit. Use it when the change goes through a PR: the tag has to
# sit on the merged commit, which does not exist yet.
#
# The XCFrameworks themselves are built in the SDK source repo. This repo only ships them.

set -euo pipefail

# Parallel arrays rather than an associative one: macOS ships bash 3.2, which has no `declare -A`.
MODULES=(ShopliveCore ShoplivePlayerSDK ShopliveStreamerSDK ShopLiveWebRTCHelperSDK WebRTC)
MANIFEST_KEYS=(checksumCore checksumPlayer checksumStreamer checksumRTCHelper checksumWebRTC)

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$REPO_ROOT/Package.swift"

die() { echo "error: $*" >&2; exit 1; }

usage() {
  sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^#\{0,1\} \{0,1\}//'
  exit 1
}

# ---- Arguments ---------------------------------------------------------------

PUBLISH=0
NO_TAG=0
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --publish) PUBLISH=1 ;;
    --no-tag)  NO_TAG=1 ;;
    -h|--help) usage ;;
    *) ARGS+=("$arg") ;;
  esac
done

[ "$NO_TAG" -eq 1 ] && [ "$PUBLISH" -eq 1 ] \
  && { echo "error: --no-tag and --publish are mutually exclusive" >&2; exit 1; }

[ "${#ARGS[@]}" -eq 2 ] || usage

VERSION="${ARGS[0]}"
ZIPS_DIR="${ARGS[1]}"
TAG="v$VERSION"

[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]] \
  || die "version must be semver (got: $VERSION)"

[ -d "$ZIPS_DIR" ] || die "not a directory: $ZIPS_DIR"

command -v swift >/dev/null || die "swift is required"
command -v unzip >/dev/null || die "unzip is required"

# ---- Preconditions -----------------------------------------------------------

cd "$REPO_ROOT"
[ -z "$(git status --porcelain)" ] || die "working tree is dirty; commit or stash first"
if [ "$NO_TAG" -eq 0 ]; then
  git rev-parse --verify --quiet "refs/tags/$TAG" >/dev/null && die "tag $TAG already exists"
fi

# ---- Validate zips and compute checksums -------------------------------------

declare -a CHECKSUMS
declare -a ZIPS

for i in "${!MODULES[@]}"; do
  module="${MODULES[$i]}"
  # The asset name is what the url in Package.swift points at, so it is fixed — no version
  # suffix, since the release tag already carries the version.
  zip="$ZIPS_DIR/$module.xcframework.zip"

  [ -f "$zip" ] || die "$module: zip not found — $zip"

  # SwiftPM looks for <TargetName>.xcframework at the zip root; otherwise resolution breaks.
  # (Piping into `grep -q` would trip pipefail on SIGPIPE, so read the listing into a variable.)
  entries="$(unzip -Z1 "$zip")"
  grep -qE "^$module\.xcframework/" <<<"$entries" \
    || die "$module: no $module.xcframework at the zip root"

  ZIPS[$i]="$zip"
  CHECKSUMS[$i]="$(swift package compute-checksum "$zip")"
  printf '  %-24s %s\n' "$module" "${CHECKSUMS[$i]}"
done

# ---- Rewrite Package.swift ---------------------------------------------------

set_manifest_value() {
  local key="$1" value="$2"
  grep -qE "^let $key( )+= " "$MANIFEST" || die "no '$key' line in Package.swift"
  # Only slash-free semver/checksum values get here, so | is safe as the sed delimiter.
  sed -i '' -E "s|^(let $key[[:space:]]*= ).*$|\1\"$value\"|" "$MANIFEST"
}

set_manifest_value sdkVersion "$VERSION"
for i in "${!MODULES[@]}"; do
  set_manifest_value "${MANIFEST_KEYS[$i]}" "${CHECKSUMS[$i]}"
done

swift package dump-package >/dev/null || die "Package.swift failed to parse — check the rewrite"
echo "Package.swift updated ($TAG)"

# ---- Commit and tag ----------------------------------------------------------

git add Package.swift
git commit -q -m "release: $TAG"

if [ "$NO_TAG" -eq 1 ]; then
  echo "committed $TAG (no tag — tag the merge commit once the PR lands)"
  exit 0
fi

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
