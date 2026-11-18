#!/usr/bin/env bash
# Renders a chart as it is at <base-ref> and as it is in the working tree,
# then diffs the two renders.
#
# Usage: .claude/hooks/render-compare.sh <base-ref> <chart> [helm template args...]
#
# Prints IDENTICAL and exits 0, or prints the diff and exits 1. When either
# render fails or comes out empty, prints RENDER FAILED (<side>) with helm's
# error and exits 1 without diffing. Writes only to a temporary directory.
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

# The base copy starts from the working tree, so the gitignored dependency
# archives under charts/<chart>/charts/ are the same on both sides.
mkdir "$tmp/base"
if [ -d "charts/$chart" ]; then
  cp -R "charts/$chart" "$tmp/base/"
fi

git diff --no-renames --name-status -z "$sha" -- "charts/$chart" >"$tmp/changes"
while IFS= read -r -d '' status && IFS= read -r -d '' path; do
  rel=${path#charts/}
  case "$status" in
    A) rm -f "$tmp/base/$rel" ;;
    *)
      mkdir -p "$(dirname "$tmp/base/$rel")"
      git show "$sha:$path" >"$tmp/base/$rel"
      ;;
  esac
done <"$tmp/changes"

git ls-files -z --others --exclude-standard -- "charts/$chart" >"$tmp/untracked"
while IFS= read -r -d '' path; do
  rm -f "$tmp/base/${path#charts/}"
done <"$tmp/untracked"

base_rc=0
helm template release-name "$tmp/base/$chart" "$@" >"$tmp/base.yaml" 2>"$tmp/base.err" || base_rc=$?
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
