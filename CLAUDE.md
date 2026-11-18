@AGENTS.md

# Claude Code

The rules under `.claude/rules/` (git-and-prs, testing, values) are binding and complement this guide.

## Skills

- `/helm-chart-test [chart] [component]` plans, writes and runs helm-unittest suites for a chart or one of its components.
- `/values-docs` applies the helm-docs comment standard to a `values.yaml` change.

## Subagents

- `chart-explorer` maps templates, helpers, value paths and history before a refactor.
- `refactor-guard` checks the diff, the rendered output and test coverage after a refactor.
- `test-writer` fills coverage gaps with helm-unittest suites.

Each subagent carries PreToolUse hooks that block any command or edit outside its remit. The hooks read the tool input with `jq`; without `jq` on PATH they block every call.
