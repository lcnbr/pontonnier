#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
expected=$(cat .typst-version)
compiler=${TYPST:-typst}
actual=$("$compiler" --version)
if [[ "$actual" != "typst $expected "* ]]; then
  printf 'Expected Typst %s; found %s\n' "$expected" "$actual" >&2
  exit 1
fi
base=${BASE_PATH:-/}
if [[ ! "$base" =~ ^/([A-Za-z0-9_-]+/)*$ ]]; then
  printf 'BASE_PATH must be / or a path such as /pontonnier/\n' >&2
  exit 1
fi
output=$(mktemp -d .build-XXXXXX)
trap 'rm -rf "$output"' EXIT
"$compiler" compile --root . --features html,bundle --format bundle \
  --input "base-path=$base" main.typ "$output"
# Replace only this project's generated directory, after a successful compile.
rm -rf dist
mv "$output" dist
printf 'Built website in dist/ (base path: %s)\n' "$base"
