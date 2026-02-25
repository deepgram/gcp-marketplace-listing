#!/usr/bin/env bash
#
# bump.sh — Update all version references in gcp-marketplace-listing to a
# new release version.
#
# Usage:
#   ./bump.sh <version>
#
# Arguments:
#   version  Full semver tag, e.g. 1.6.0
#
# Files updated:
#   schema.yaml                                         (publishedVersion, image tag defaults)
#   apptest/deployer/schema.yaml                        (testerImage full reference)
#   chart/deepgram-self-hosted-starter/Chart.yaml       (version, appVersion)
#   README.md                                           (IMAGE_TAG example)
#
# This script is idempotent: running it twice with the same version produces
# the same result. It is called by build.sh in gcp-marketplace-listing-internal
# as the first step of a release build, but can also be run standalone to
# prepare a version bump commit independently of building.

set -euo pipefail

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------

usage() {
    echo "Usage: $0 <version>"
    echo "  Example: $0 1.6.0"
    exit 1
}

if [[ $# -ne 1 ]]; then
    usage
fi

NEW_TAG="$1"

if [[ ! "$NEW_TAG" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: version must be in major.minor.patch format (e.g. 1.6.0)"
    exit 1
fi

# ---------------------------------------------------------------------------
# Portable in-place sed (BSD sed on macOS requires an empty-string extension)
# ---------------------------------------------------------------------------

if [[ "$(uname)" == "Darwin" ]]; then
    SED_INPLACE=(-i '')
else
    SED_INPLACE=(-i)
fi

# Resolve repo root from the script's own location so this works whether
# called directly or via an absolute path from build.sh.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Bumping version references to $NEW_TAG"

# ---------------------------------------------------------------------------
# schema.yaml
#
# Three fields updated:
#   publishedVersion: X.Y.Z
#   deepgramSelfHostedStarter.image.tag  default: X.Y.Z
#   tester.image.tag                     default: X.Y.Z
#
# The pattern `default: [0-9][0-9.]*` is safe here because all other
# `default:` values in this file begin with `gcr.io/` and will not match.
# ---------------------------------------------------------------------------

sed "${SED_INPLACE[@]}" \
    -e "s/publishedVersion: [0-9][0-9.]*/publishedVersion: $NEW_TAG/" \
    -e "s/\(default: \)[0-9][0-9.]*/\1$NEW_TAG/g" \
    "$REPO_ROOT/schema.yaml"

# ---------------------------------------------------------------------------
# apptest/deployer/schema.yaml
#
# Updates the testerImage full reference:
#   default: .../deployer/tester:X.Y.Z
# ---------------------------------------------------------------------------

sed "${SED_INPLACE[@]}" \
    -e "s|deployer/tester:[0-9][0-9.]*|deployer/tester:$NEW_TAG|" \
    "$REPO_ROOT/apptest/deployer/schema.yaml"

# ---------------------------------------------------------------------------
# chart/deepgram-self-hosted-starter/Chart.yaml
#
# Updates version and appVersion fields.
# Anchored to line start (^) to avoid matching keys like `kubeVersion`.
# ---------------------------------------------------------------------------

sed "${SED_INPLACE[@]}" \
    -e "s/^version: [0-9][0-9.]*/version: $NEW_TAG/" \
    -e "s/^appVersion: [0-9][0-9.]*/appVersion: $NEW_TAG/" \
    "$REPO_ROOT/chart/deepgram-self-hosted-starter/Chart.yaml"

# ---------------------------------------------------------------------------
# README.md
#
# Updates the IMAGE_TAG example in the installation instructions.
# ---------------------------------------------------------------------------

sed "${SED_INPLACE[@]}" \
    -e "s/IMAGE_TAG=[0-9][0-9.]*/IMAGE_TAG=$NEW_TAG/" \
    "$REPO_ROOT/README.md"

echo "    schema.yaml"
echo "    apptest/deployer/schema.yaml"
echo "    chart/deepgram-self-hosted-starter/Chart.yaml"
echo "    README.md"
