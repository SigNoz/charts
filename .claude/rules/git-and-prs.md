# Git and pull request conventions

These apply to every commit, push and PR in this repo.

## No AI attribution
Never add `Co-Authored-By: Claude ...`, "Generated with Claude Code" or any
other AI attribution to commit messages, PR bodies, template or values
comments, or generated docs. Stop the commit body before any trailer, and
`git commit --amend` to strip one already there. Human `Co-Authored-By:`
trailers are fine.

## Commit messages
Conventional Commits with the chart or component as scope: lower-case,
imperative, no trailing period. From main's history:
`feat(otel-collector): add the stale-data filter to the collector pipelines`,
`feat(signoz-mcp-server): add a chart for the SigNoz MCP server`,
`chore(signoz-operator): bump SigNoz Operator to v0.0.5`.

## Stage by path
Stage each file by path, never `git add -A` or `git add .`. Dependency
archives under `charts/*/charts/*.tgz` are rebuilt by `helm dependency build`
and never committed. `charts/redpanda` and `charts/zookeeper` are vendored:
they are never edited and carry no tests.

## Push explicitly
Name the remote and branch on every push: `git push origin <branch>`, even
when the branch tracks an upstream. Never bare `git push`. Force-push only
with `git push origin <branch> --force-with-lease`.

## Verify before any push
Run CI's own commands for every chart the branch touches, as
`.claude/rules/testing.md` lists them.

## PR descriptions
The repo has no PR template. Keep the body short: what changed and why,
grouped by chart when several change. No `## Test plan`, `## Testing` or
checklist sections; mention verification inline when it matters.

## Branching
Commit or push only when asked. On `main`, branch first.

## No chart version bumps in feature changes
A change to `charts/signoz` leaves `version` and `appVersion` in `Chart.yaml`
alone: the prereleaser workflow (`.github/workflows/prereleaser.yaml`) bumps
them in a `chore(release):` PR; chart-releaser (`.github/workflows/release.yaml`)
publishes on push to main. `ct.yaml` sets `check-version-increment: false`.
Any other chart's `version` moves only when asked.
