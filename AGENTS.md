# Agent guide for the SigNoz charts repository

## Repository overview

This repository holds the SigNoz Helm charts, one chart per directory under `charts/`, published to the Helm repository at https://charts.signoz.io. The "Release Charts" workflow (`.github/workflows/release.yaml`) runs chart-releaser on every push to `main` and publishes new chart versions. The `prereleaser` workflow, run by maintainers in the releaser team, bumps `charts/signoz` in `chore(release): ...` commits; every other chart bumps its own `version` in its PR, and `ct.yaml` sets `check-version-increment: false`. A change to `charts/signoz` leaves `version` and `appVersion` in `Chart.yaml` untouched; any other chart's `version` moves only when asked.

## Charts

Each chart follows the standard Helm structure (`Chart.yaml`, `values.yaml`, `templates/`), with suites under `tests/` where the chart has them.

| Chart | Holds | Tests | Generated README |
|---|---|---|---|
| `signoz` | The SigNoz umbrella: SigNoz (`templates/signoz/`), the OTel collector (`templates/otel-collector/`) and the telemetry store migrator (`templates/telemetrystore-migrator/`); depends on `clickhouse`, `signoz-otel-gateway`, `redpanda` and `postgresql` | yes | yes |
| `clickhouse` | ClickHouse and the ClickHouse operator, with ZooKeeper as the `zookeeper` subchart (`file://../zookeeper`) | yes | no |
| `k8s-infra` | The Kubernetes collection agent: the `otel-agent` DaemonSet and the `otel-deployment` Deployment | yes | yes |
| `signoz-otel-gateway` | The SigNoz OpenTelemetry gateway | no | no |
| `signoz-operator` | The SigNoz Kubernetes operator and its CRDs | yes | yes |
| `signoz-mcp-server` | The SigNoz MCP server | yes | yes |
| `postgresql` | PostgreSQL, an optional dependency of `signoz` | yes | yes |

`charts/signoz` resolves its dependencies from https://charts.signoz.io, not from the sibling directories, so a change to `charts/clickhouse` reaches `charts/signoz` only after a release and a dependency version bump.

`charts/redpanda` (the upstream Redpanda chart) and `charts/zookeeper` (the Bitnami ZooKeeper chart) are vendored: they are never edited and carry no tests.

## Feature implementation workflow

Most agent tasks in this repository are chart feature changes. For these tasks:

1. Identify the affected chart under `charts/<chart>/` and keep the change scoped to that chart.
2. Read the chart's `Chart.yaml`, `values.yaml`, the templates and `_*.tpl` helpers involved, and the existing suites under `tests/` before editing.
3. Implement the feature in the chart's existing template style and values structure.
4. When a `values.yaml` key or its comment changes, follow `.claude/skills/values-docs/SKILL.md` and regenerate the chart's `README.md`.
5. Add or update helm-unittest coverage for the rendered behavior the change controls, following `.claude/skills/helm-chart-test/SKILL.md`.
6. Run the validation commands below for every chart the change touches.

Ask for clarification only when the intended chart or behavior cannot be inferred from the request and the local context.

## Validation commands

Run these from the repository root. `ct.yaml` lists the charts CI lints and installs: `clickhouse`, `k8s-infra`, `signoz`, `postgresql`, `signoz-operator` and `signoz-mcp-server`.

Unit tests. CI (`ci.yaml`) runs this for every chart through the shared `signoz/primus.workflows` helm-unittest workflow, with the plugin pinned at v1.0.2:

```bash
helm unittest charts/<chart> --file 'tests/**/*_test.yaml'
```

Lint. The "Lint Charts" workflow (`lint.yaml`) runs `ct lint --config ct.yaml`, which adds yamllint and Chart.yaml schema checks to `helm lint`:

```bash
ct lint --config ct.yaml --charts charts/<chart>
```

Docs. The "Generate Helm Docs" workflow (`helm-docs.yaml`) regenerates `charts/signoz`, `charts/k8s-infra` and `charts/signoz-mcp-server` with helm-docs v1.14.2 and fails on any diff:

```bash
make chart-docs CHARTS=charts/<chart>
```

Install. The "Test Charts" workflow (`test.yaml`) runs `ct install --config ct.yaml` on a kind cluster when `ct list-changed` reports a change, with the `--helm-extra-set-args` that file sets.

## Values documentation

The comments above keys in `values.yaml` are published documentation: helm-docs renders them into the `README.md` of every chart that carries a `README.md.gotmpl`. `.claude/skills/values-docs/SKILL.md` states the comment form, the vocabulary, the schema and the migration procedure. Most existing keys still use the key-prefixed `# <key> -- ` form with `# @default --`; new or edited keys follow the skill. Commit the regenerated `README.md` with the `values.yaml` change.

## Contributing conventions

- Commits follow Conventional Commits with the chart or component as scope, lower-case and imperative, with no trailing period: `feat(otel-collector): add the logs normalizer to the logs pipeline`, `fix(k8s-infra): grant persistentvolumes to otel-agent ClusterRole`.
- PR bodies are short: what changed and why, grouped by chart when more than one changes, with no test plan or checklist section.
- No AI or assistant attribution in commits, PR bodies, template comments or generated docs.
- A change to `charts/signoz` leaves `version` and `appVersion` in `Chart.yaml` unchanged; any other chart's `version` moves only when asked.
- Push with the remote and branch named: `git push origin <branch>`.
- Before any push, run the validation commands for every chart touched.
- `charts/redpanda` and `charts/zookeeper` are vendored: they are never edited and carry no tests.
- Dependency archives under `charts/*/charts/*.tgz` come from `helm dependency build`, are gitignored, and are never committed.

The binding detail for Claude Code lives in `.claude/rules/`.

## Skills and agents

| Path | Use |
|---|---|
| `.claude/skills/helm-chart-test/SKILL.md` | helm-unittest conventions: coverage discovery, suite layout, selectors and the commands CI runs |
| `.claude/skills/values-docs/SKILL.md` | The helm-docs comment standard for `values.yaml`, the generated `values.schema.json`, and the migration to them |
| `.claude/agents/chart-explorer.md` | Read-only analysis of templates, helpers, value paths and history before a refactor |
| `.claude/agents/refactor-guard.md` | Diff impact, rendered-output comparison and coverage gaps after a refactor |
| `.claude/agents/test-writer.md` | Writes and runs helm-unittest suites under `charts/*/tests/` |

PreToolUse hooks fence the subagents through `.claude/hooks/fence.sh`. Each Bash call is one command, with no shell operators, redirection, substitution, expansion or newlines. `chart-explorer` runs only read-only git, gh, `helm template`, `wc`, `ls` and `.claude/hooks/render-compare.sh` commands; `refactor-guard` runs the same set without gh and `git blame`; `test-writer` runs only `helm unittest` and `ct lint`, and edits only `.yaml` files under `charts/<chart>/tests/` outside the vendored charts, checked after resolving `..` and symlinks. `.claude/hooks/test-fences.sh` tests the fence.
