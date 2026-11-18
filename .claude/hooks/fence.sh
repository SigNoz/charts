#!/bin/sh
# PreToolUse fence for the chart subagents in .claude/agents/.
#
# Usage: fence.sh explorer-bash|guard-bash|writer-bash|writer-edit < hook-input.json
#
# Exit 0 allows the tool call. Exit 2 blocks it, with the reason on stderr.
# Anything that cannot be parsed or resolved blocks.
#
# Bash modes allow one command per call. A command holding a shell operator,
# redirection, substitution, expansion or a newline is blocked even inside
# quotes, then the command must start with one of the mode's allowed shapes
# and carry none of the flags that make that tool write or mutate.
#
# writer-edit resolves the target path and allows only a .yaml file under
# charts/<chart>/tests/ of this checkout, outside the vendored charts.
set -u

mode=${1:-}

block() {
  printf 'BLOCKED: %s\n' "$*" >&2
  exit 2
}

case "$mode" in
  explorer-bash)
    allowed='git diff, git log, git show, git blame, gh pr view, gh pr list, gh issue view, gh issue list, gh api (GET only), helm template, wc, ls, .claude/hooks/render-compare.sh' ;;
  guard-bash)
    allowed='git diff, git log, git show, helm template, wc, ls, .claude/hooks/render-compare.sh' ;;
  writer-bash)
    allowed='helm unittest, ct lint' ;;
  writer-edit)
    allowed='charts/<chart>/tests/*.yaml' ;;
  *)
    block "fence.sh: unknown mode '$mode'" ;;
esac

command -v jq >/dev/null 2>&1 || block "fence.sh needs jq on PATH"
input=$(cat) || block "fence.sh could not read the hook input"
tool=$(printf '%s' "$input" | jq -er '.tool_name | strings' 2>/dev/null) ||
  block "fence.sh could not parse the hook input"

if [ "$mode" = writer-edit ]; then
  edit_msg='test-writer edits only charts/<chart>/tests/*.yaml (not vendored charts)'
  case "$tool" in Write|Edit|MultiEdit) ;; *) block "$edit_msg" ;; esac
  path=$(printf '%s' "$input" |
    jq -er '.tool_input.file_path | strings | select(test("^[^\\x00-\\x1f\\x7f]+$"))' 2>/dev/null) ||
    block "$edit_msg"
  proj=${CLAUDE_PROJECT_DIR:-}
  [ -n "$proj" ] || block "fence.sh needs CLAUDE_PROJECT_DIR"
  command -v python3 >/dev/null 2>&1 || block "fence.sh needs python3 on PATH"
  case "$path" in /*) ;; *) path="$proj/$path" ;; esac
  resolve() {
    python3 -I -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1"
  }
  rproj=$(resolve "$proj") && [ -n "$rproj" ] || block "$edit_msg"
  rpath=$(resolve "$path") && [ -n "$rpath" ] || block "$edit_msg"
  case "$rpath" in
    "$rproj"/charts/*/tests/*?.yaml) ;;
    *) block "$edit_msg" ;;
  esac
  rel=${rpath#"$rproj"/charts/}
  chart=${rel%%/*}
  case "${rel#"$chart"/}" in tests/*) ;; *) block "$edit_msg" ;; esac
  case "$(printf '%s' "$chart" | tr '[:upper:]' '[:lower:]')" in
    ''|redpanda|zookeeper) block "$edit_msg" ;;
  esac
  [ -f "$rproj/charts/$chart/Chart.yaml" ] || block "$edit_msg"
  exit 0
fi

[ "$tool" = Bash ] || block "$mode fences Bash, not $tool"
printf '%s' "$input" | jq -e '.tool_input.command | strings' >/dev/null 2>&1 ||
  block "no command in the hook input"

if printf '%s' "$input" |
  jq -e '.tool_input.command | test("[;&|<>`$()\\x00-\\x08\\x0a-\\x1f\\x7f]") or test("\\{[^{}]*(,|\\.\\.)[^{}]*\\}")' >/dev/null 2>&1; then
  block 'one command per call: no ; & | < > ` $ ( ) brace expansion or newline, even inside quotes'
fi

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command')
# Quote removal, so a quoted flag is checked as the tool will see it.
clean=$(printf '%s' "$cmd" | tr -d "'\"\\\\")
IFS=$(printf ' \t\nx')
IFS=${IFS%x}
set -f
# shellcheck disable=SC2086
set -- $clean
[ "$#" -gt 0 ] || block "no command in the hook input"

case "$1" in
  env|sh|bash|zsh|eval|exec|xargs|sudo) block "$1 is not allowed: run the command itself" ;;
esac

shape=
case "$1" in
  git)
    case "$mode:${2:-}" in
      explorer-bash:diff|explorer-bash:log|explorer-bash:show|explorer-bash:blame) shape=git ;;
      guard-bash:diff|guard-bash:log|guard-bash:show) shape=git ;;
    esac ;;
  gh)
    if [ "$mode" = explorer-bash ]; then
      case "${2:-} ${3:-}" in
        'pr view'|'pr list'|'issue view'|'issue list') shape=gh ;;
        'api '*) shape=ghapi ;;
      esac
    fi ;;
  helm)
    case "$mode:${2:-}" in
      explorer-bash:template|guard-bash:template) shape=helmtemplate ;;
      writer-bash:unittest) shape=unittest ;;
    esac ;;
  wc|ls)
    [ "$mode" = writer-bash ] || shape=plain ;;
  ct)
    [ "$mode:${2:-}" = writer-bash:lint ] && shape=ctlint ;;
  .claude/hooks/render-compare.sh|./.claude/hooks/render-compare.sh|"${CLAUDE_PROJECT_DIR:-/nonexistent}/.claude/hooks/render-compare.sh")
    [ "$mode" = writer-bash ] || shape=render ;;
esac
[ -n "$shape" ] || block "$mode allows only $allowed"

# cluster_has <word> <letters that take a value> <forbidden letters>
# Walks a short-flag cluster (-iX) the way pflag does: stops at the first
# letter that takes a value, and reports a forbidden letter met before it.
cluster_has() {
  rest=${1#-}
  while [ -n "$rest" ]; do
    c=${rest%"${rest#?}"}
    rest=${rest#?}
    case "$3" in *"$c"*) return 0 ;; esac
    case "$2" in *"$c"*) return 1 ;; esac
  done
  return 1
}

helm_template_flags() {
  for w in "$@"; do
    case "$w" in
      --output*|-o*) block "$w: helm template writes to stdout only" ;;
      --post-renderer*) block "$w: helm template runs no post-renderer" ;;
      --dependency-update) block "$w: helm template does not update dependencies" ;;
    esac
  done
}

case "$shape" in
  git)
    shift 2
    for w in "$@"; do
      case "$w" in
        --ou*|-o*) block "$w: git writes to stdout only" ;;
      esac
    done ;;
  gh) ;;
  ghapi)
    shift 2
    for w in "$@"; do
      case "$w" in
        --method*|--field*|--raw-field*|--input*) block "$w: gh api is GET only" ;;
        --*) ;;
        -?*) cluster_has "$w" Hpqt XfF && block "$w: gh api is GET only" ;;
      esac
    done ;;
  helmtemplate)
    shift 2
    helm_template_flags "$@" ;;
  plain) ;;
  render)
    case "${2:-}" in
      ''|-*) block "render-compare.sh takes <base-ref> <chart> [helm template args...]" ;;
    esac
    case "${3:-}" in
      ''|-*|*/*) block "render-compare.sh takes <base-ref> <chart> [helm template args...]" ;;
    esac
    shift 3
    helm_template_flags "$@" ;;
  unittest)
    shift 2
    for w in "$@"; do
      case "$w" in
        --output*) block "$w: helm unittest writes no result file" ;;
        --*) ;;
        -?*) cluster_has "$w" fv ot && block "$w: helm unittest writes no result file" ;;
      esac
    done ;;
  ctlint)
    shift 2
    while [ "$#" -gt 0 ]; do
      case "$1" in
        --config)
          [ "${2:-}" = ct.yaml ] || block "ct lint reads only --config ct.yaml"
          shift ;;
        --config=ct.yaml|--charts=?*|--all|--debug|--skip-helm-dependencies) ;;
        --charts)
          [ "$#" -ge 2 ] || block "--charts needs a chart"
          shift ;;
        *) block "ct lint allows only --config ct.yaml, --charts, --all, --debug, --skip-helm-dependencies; got $1" ;;
      esac
      shift
    done ;;
esac

exit 0
