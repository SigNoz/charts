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

Each subagent carries PreToolUse hooks that run `.claude/hooks/fence.sh` with the subagent's mode and block any command or edit outside its remit. The fence reads the tool input with `jq` and resolves edit paths with `python3`; without `jq` on PATH it blocks every call, and without `python3` every test-writer edit. Run `CLAUDE_PROJECT_DIR=$PWD .claude/hooks/test-fences.sh` from the repository root after changing it.
