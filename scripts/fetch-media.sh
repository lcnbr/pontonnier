#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
repository=https://github.com/lcnbr/pontonnier-media.git
revision=$(tr -d '\r\n' < .media-revision)
if [[ ! "$revision" =~ ^[0-9a-f]{40}$ ]]; then
  printf '.media-revision must contain a full Git commit SHA\n' >&2
  exit 1
fi
if [[ ! -d .media/.git ]]; then
  if [[ -e .media ]]; then
    printf '.media exists but is not a media checkout\n' >&2
    exit 1
  fi
  git init --quiet .media
  git -C .media remote add origin "$repository"
fi
if [[ "$(git -C .media remote get-url origin)" != "$repository" ]]; then
  printf '.media must point to %s\n' "$repository" >&2
  exit 1
fi
if [[ -n "$(git -C .media status --porcelain)" ]]; then
  printf '.media has local changes; commit or move them before building\n' >&2
  exit 1
fi
# Originals are served on demand from the media repository, outside the Pages bundle.
# A partial checkout keeps CI from transferring the much larger original collection.
git -C .media config remote.origin.promisor true
git -C .media config remote.origin.partialclonefilter blob:none
git -C .media sparse-checkout set --cone assets
current=$(git -C .media rev-parse --verify HEAD 2>/dev/null || true)
if [[ "$current" != "$revision" ]]; then
  git -C .media fetch --quiet --filter=blob:none --depth=1 --no-tags origin "$revision"
  git -C .media checkout --quiet --detach "$revision"
fi
printf 'Media ready at %s\n' "$revision"
