#!/bin/sh
# Releases are immutable: fail if any existing file under releases/ was modified,
# deleted or renamed relative to the base ref. Adding new Releases is fine.
set -eu
base="${1:?usage: append-only.sh <base-ref>}"
changed=$(git diff --name-only --diff-filter=MDR "$base"...HEAD -- releases/)
if [ -n "$changed" ]; then
  echo "Releases are immutable; add a new Release id instead of changing:" >&2
  echo "$changed" >&2
  exit 1
fi
