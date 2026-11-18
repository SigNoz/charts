---
paths:
  - "charts/**"
---

# Chart tests

## What must pass before a push
From the repository root, for every chart the branch touches:

```
ct lint --config ct.yaml --charts charts/<chart>
helm unittest charts/<chart> --file 'tests/**/*_test.yaml'
```

- **`ct lint`** is what `.github/workflows/lint.yaml` runs. `helm lint` alone is
  a subset: ct runs yamllint too, and stops at the first failing file.
- **`helm unittest`** is what `.github/workflows/ci.yaml` runs, through the
  shared primus helm-unittest workflow with the plugin pinned at v1.0.2.
  Without `--file` it reads only `tests/*_test.yaml` and misses every suite in
  a subdirectory.
- **`ct install`** (`.github/workflows/test.yaml`) installs each changed chart
  on a kind cluster in CI. It is not a local gate.

## Test conventions
- **Layout mirrors `templates/`**: suites live under `charts/<chart>/tests/`
  as `tests/<component>/<template>_test.yaml`; a helper file `_<name>.tpl` is
  tested from `tests/lib/<name>_test.yaml`.
- **Filenames end in `_test.yaml`**: CI's glob runs nothing else.
- **`RELEASE-NAME` is the release name**: `release:` is set only in a case
  that tests release behavior.
- **One behavior per `it`**, with explicit `set:` overrides and specific
  assertions over `exists` and over `matchSnapshot`.
- **Every `fail` is asserted**: each `fail` in a chart's templates has a case
  asserting it with `failedTemplate`.
- **Flat layouts migrate whole**: a chart still on the flat
  `<component>_<topic>_test.yaml` layout moves in one pass, in its own
  `test(<chart>):` commit.
- **Vendored charts carry no tests**: `charts/redpanda`, `charts/zookeeper`.

The full standard, including migration, is
`.claude/skills/helm-chart-test/SKILL.md`.

## Trailing newline
Run `tail -c1` on every edited YAML file: the last byte is a newline. ct's
yamllint rejects a `Chart.yaml` or `values.yaml` without one.
