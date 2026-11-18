#!/usr/bin/env bash
# Renders a chart as it is at <base-ref> and as it is in the working tree,
# then diffs the two renders.
#
# Usage: .claude/hooks/render-compare.sh <base-ref> <chart> [helm template args...]
#
# Prints IDENTICAL and exits 0, or prints the diff and exits 1. When either
# render fails or comes out empty, prints RENDER FAILED (<side>) with helm's
# error and exits 1 without diffing. Writes only to a temporary directory: the
# base side comes from git alone, never from a copy of the working tree, whose
# symlinks would let a write land outside it.
set -euo pipefail

usage() {
  echo "usage: .claude/hooks/render-compare.sh <base-ref> <chart> [helm template args...]" >&2
  exit 2
}

[ "$#" -ge 2 ] || usage
base=$1
chart=$2
shift 2
case "$base" in '' | -*) usage ;; esac
case "$chart" in '' | -* | . | .. | */*) usage ;; esac

cd "$(git rev-parse --show-toplevel)"
sha=$(git rev-parse --verify --quiet "$base^{commit}") || {
  echo "unknown base ref: $base" >&2
  exit 2
}

tmp=$(mktemp -d "${TMPDIR:-/tmp}/render-compare.XXXXXX")
trap 'rm -rf "$tmp"' EXIT

mkdir "$tmp/base"
if git cat-file -e "$sha:charts/$chart" 2>/dev/null; then
  git archive "$sha" -- "charts/$chart" | tar -xf - -C "$tmp/base"
fi

# The gitignored dependency archives come from the working tree, so subcharts
# render the same on both sides. Only regular files are read, and nothing is
# written through a link the base tree may carry.
copy="$tmp/base/charts/$chart"
deps="$copy/charts"
if [ -d "$copy" ] && [ ! -L "$copy" ] && [ ! -L "$deps" ]; then
  for f in "charts/$chart/charts"/*.tgz; do
    if [ -f "$f" ] && [ ! -L "$f" ]; then
      mkdir -p "$deps"
      rm -f "$deps/${f##*/}"
      cp "$f" "$deps/${f##*/}"
    fi
  done
fi

base_rc=0
helm template release-name "$copy" "$@" >"$tmp/base.yaml" 2>"$tmp/base.err" || base_rc=$?
head_rc=0
helm template release-name "charts/$chart" "$@" >"$tmp/head.yaml" 2>"$tmp/head.err" || head_rc=$?

failed=0
for side in base head; do
  if [ "$side" = base ]; then rc=$base_rc; else rc=$head_rc; fi
  if [ "$rc" -ne 0 ] || [ ! -s "$tmp/$side.yaml" ]; then
    {
      echo "RENDER FAILED ($side): helm template exited $rc"
      cat "$tmp/$side.err"
    } >&2
    failed=1
  fi
done
[ "$failed" -eq 0 ] || exit 1

rc=0
diff -u --label "$base" --label "working tree" "$tmp/base.yaml" "$tmp/head.yaml" || rc=$?
if [ "$rc" -eq 0 ]; then
  echo IDENTICAL
fi
exit "$rc"
