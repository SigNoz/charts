---
name: helm-chart-test
description: Plan, write and validate helm-unittest tests for a chart. Use when adding, expanding, fixing, reviewing or migrating a chart's tests, or when a template, helper or values change needs matching rendered-manifest tests. Covers coverage discovery, the mirrored tests/<component>/<template>_test.yaml layout, the RELEASE-NAME and selector conventions, failedTemplate checks for every fail in the templates, and the commands CI runs (helm unittest with the tests/**/*_test.yaml glob, ct lint).
---

# /helm-chart-test [chart] [component]

Use this skill whenever the user asks to add, expand, fix, review or migrate helm-unittest coverage for a chart, or when a chart feature change needs matching rendered-manifest tests.

## Argument Handling

**During feature implementation**, infer the chart and component from the files being changed or from the requested feature. Add or update focused tests for the affected rendered behavior without pausing for broad coverage analysis or scoping questions, unless the requested behavior is ambiguous.

**If no arguments are provided for a standalone test task**, ask the user which chart they want to work on, then proceed as if they provided just the chart name.

**If only `<chart>` is provided for a standalone coverage audit**, run the full discovery and coverage analysis below before asking any questions.

**If `<chart> <component>` is provided for a standalone test task**, inspect that component and choose the relevant existing or new test files. Ask scoping questions only when the requested coverage depth or target templates cannot be inferred.

## Feature Implementation Mode

When this skill is used as part of implementing a chart feature, do not stop after planning or ask the user to choose a component. Instead:

1. Identify the affected chart from `charts/<chart>/...`.
2. Identify affected templates, helpers, and values from the feature diff or requested change.
3. Read existing nearby tests and mirror their style.
4. Add or update focused tests for the new or changed rendered behavior.
5. Cover important enabled/disabled branches, value propagation, selectors, labels, annotations, containers, volumes, and service wiring touched by the feature.
6. Run `helm unittest charts/<chart> --file 'tests/**/*_test.yaml'` from the repository root.

Ask the user only when there are multiple plausible feature semantics or when the chart/component cannot be determined from local context.

## Discovery and Coverage Analysis

Work through these steps silently. Produce a single structured report at the end.

### 1. Understand the Chart Structure

- Read `charts/<chart>/Chart.yaml` and note the chart type, version, kubeVersion, and dependencies. Dependencies come from `Chart.yaml`; `charts/signoz` resolves its subcharts from https://charts.signoz.io, so a change to a sibling chart reaches it only after a release and a version bump.
- `charts/redpanda` and `charts/zookeeper` are vendored: they are never edited and carry no tests.
- Read the top level of `charts/<chart>/values.yaml` to understand major configuration axes, deployment modes, and component enable flags.
- List `charts/<chart>/templates/**`.
- Identify component groups. Subdirectories under `templates/` are natural groups (`charts/signoz/templates/signoz/`, `otel-collector/`, `telemetrystore-migrator/`), and the root templates (`charts/signoz/templates/secrets-clickhouse-external.yaml`, `NOTES.txt`) form one more. If the chart has flat templates, treat the whole chart as one component.
- Read the helpers before testing templates that call them. In `charts/signoz` these are `templates/_helpers.tpl` (for example `signoz.fullname`, `signoz.labels`, `signoz.selectorLabels`, `otelCollector.fullname`, `telemetryStoreMigrator.fullname` and `clickhouse.servicename`) and `templates/_clickhouse.tpl` (for example `clickhouse.httpUrl`, `clickhouse.secretName` and `snippet.clickhouse-credentials`). ClickHouse itself is the separate `clickhouse` chart, a dependency of `charts/signoz`; these helpers only build the names, ports and credentials that point at it.

### 2. Map Existing Test Coverage

- List `charts/<chart>/tests/**`.
- For each component group, count:
  - renderable templates, excluding `_*.tpl` helper/partial files
  - corresponding test files in `charts/<chart>/tests/<component>/`
- A chart still on the flat layout keeps its suites directly under `tests/` as `<component>_<topic>_test.yaml`. Map those by the `templates:` list inside each suite, not by file name.
- Check whether existing tests exercise the relevant branches, not just whether a file exists.

### 3. Assess Complexity

Determine whether the chart is **simple** or **complex**.

- **Simple**: flat templates, no deployment modes, fewer than 10 renderable templates.
- **Complex**: subdirectories, deployment modes, major conditional rendering, or more than 10 renderable templates.

For a simple chart, present a single coverage table and recommend whether to proceed with the whole chart at once.

For a complex chart, group templates into logical work units and recommend a starting component.

### 4. Present the Coverage Report

Use this format:

```md
## <chart> - Test Coverage Analysis

| Component | Renderable templates | Test files | Coverage |
|---|---:|---:|---|
| root-level (secrets-clickhouse-external.yaml, NOTES.txt) | N | N | None / Partial / Good |
| signoz | N | N | None / Partial / Good |
| otel-collector | N | N | None / Partial / Good |
| telemetrystore-migrator | N | N | None / Partial / Good |

### Notes
- <important observations about deployment modes, required values, lookup usage, subcharts, or test complexity>

### Suggested starting point
<recommend the lowest-risk, highest-value component and explain why>

Recommended next test target: <component or whole chart>
```

For standalone coverage audits, wait for the user to choose a component before writing tests. For feature implementation, proceed with focused tests for the component touched by the feature.

## Scoping Questions

For standalone test-expansion tasks where scope cannot be inferred, ask:

1. Scope within the component: all templates, or specific templates?
2. Existing tests: extend partial tests, or add new test files alongside them?
3. Coverage depth: happy path only, or full branch coverage for every significant `if` / `with` / `range`?
4. Known gotchas: deployment modes, required values, lookup behavior, subchart values, or compatibility constraints?

After the user answers, summarize the agreed scope in one short paragraph, then begin writing tests. Skip these questions when implementing a specific feature and the affected behavior is clear from the request or diff.

## helm-unittest Overview

Tests are YAML files in `charts/<chart>/tests/` that validate rendered Kubernetes manifests. Each test renders templates with specified values and asserts on the output.

Each `tests[].it` case renders independently with that case's value inputs. Keep tests focused and deterministic: one behavior per test, explicit value overrides, and scoped assertions.

### Test File Structure

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/helm-unittest/helm-unittest/main/schema/helm-testsuite.json
suite: <descriptive suite name>
values:
  - ../values/<scenario>.yaml
set:
  key.nested: value
templates:
  - templates/signoz/statefulset.yaml
tests:
  - it: <test case description>
    values:
      - ../values/<scenario>.yaml
    set:
      key.nested: value
    documentSelector:
      path: metadata.name
      value: RELEASE-NAME-signoz
    asserts:
      - isKind:
          of: StatefulSet
      - equal:
          path: metadata.name
          value: RELEASE-NAME-signoz
      - contains:
          path: spec.template.spec.containers[0].ports
          content:
            name: http
            containerPort: 8080
            protocol: TCP
```

The first line is the `yaml-language-server` schema comment, so editors validate the suite. Values files are resolved relative to the suite file, so a suite in `tests/signoz/` reaches a fixture in `tests/values/` as `../values/<scenario>.yaml`.

### Scope, Precedence, and Targeting

- Value precedence: chart `values.yaml` < suite `values` < suite `set` < test `values` < test `set`.
- Template scope precedence: suite `templates` can be narrowed by test `template` / `templates`, then by assertion-level `template`.
- Document targeting precedence: assertion `documentSelector` / `documentIndex` overrides test-level selector/index.
- Use `documentSelector` for multi-document templates instead of brittle numeric `documentIndex` when possible.
- A selector must find a document in every template in scope. When it targets an object that only some of the suite's templates render, set `skipEmptyTemplates: true` on the selector or narrow the scope with `template`.
- `hasDocuments` ignores selectors by default; set `filterAware: true` to count only selector/index-filtered documents.

### Suite and Test Options

- `release`: set only in a case that tests behavior depending on `.Release` (`name`, `namespace`, `revision`, `upgrade`). Every other case runs under helm-unittest's defaults, release `RELEASE-NAME` in namespace `NAMESPACE`.
- `capabilities`: pin Kubernetes versions/APIs for branches guarded by `.Capabilities.*`.
- `chart`: override `.Chart.version` / `.Chart.appVersion` when template output depends on them.
- `excludeTemplates`: narrow broad template globs to avoid unrelated documents in a suite.
- `skip`: only for temporary or unreleased behavior; prefer active assertions over skipped tests.
- `postRenderer`: use only when chart behavior explicitly depends on post-render transforms.

## Testing `lookup` with `kubernetesProvider`

Use `kubernetesProvider` whenever templates call `lookup`; without it, `lookup` returns empty and branch coverage is incomplete.

- Register API kinds in `scheme` using `"<group>/<version>/<Kind>"` or `"v1/<Kind>"` for core APIs.
- Each scheme entry must define `gvr` (`group` optional for core APIs, plus `version`, `resource`) and `namespaced`.
- Provide fixture resources in `objects`. A fixture that a lookup in `.Release.Namespace` must find lives in `NAMESPACE`, the default release namespace.
- Test-level `kubernetesProvider.objects` can add scenario-specific fixtures without rewriting suite-wide defaults.

```yaml
templates:
  - templates/<component>/<template>.yaml
kubernetesProvider:
  scheme:
    "v1/Secret":
      gvr:
        version: "v1"
        resource: "secrets"
      namespaced: true
    "networking.k8s.io/v1/Ingress":
      gvr:
        group: "networking.k8s.io"
        version: "v1"
        resource: "ingresses"
      namespaced: true
  objects:
    - kind: Secret
      apiVersion: v1
      metadata:
        name: existing
        namespace: NAMESPACE
tests:
  - it: reuses the Secret found through lookup
    asserts:
      - equal:
          path: <path that carries the looked-up name>
          value: existing
  - it: finds a test-level object through lookup
    kubernetesProvider:
      objects:
        - kind: Secret
          apiVersion: v1
          metadata:
            name: scenario
            namespace: NAMESPACE
    asserts:
      - equal:
          path: <path that carries the looked-up name>
          value: scenario
```

## Assertion Guidance

| Assertion | Purpose |
|---|---|
| `equal` | Exact match at JSON path |
| `notEqual` | Value differs from expected |
| `matchRegex` | Regular expression match on string value |
| `exists` | Path exists in rendered output |
| `notExists` | Path is absent from rendered output |
| `isEmpty` / `isNotEmpty` | Path is empty or not empty |
| `isNullOrEmpty` / `isNotNullOrEmpty` | Path is null/empty or present with content |
| `isKind` | Kubernetes resource kind check |
| `isAPIVersion` | API version check |
| `contains` | Array/map contains entry |
| `notContains` | Array/map does not contain entry |
| `hasDocuments` | Number of YAML documents rendered |
| `matchSnapshot` | Snapshot testing |
| `failedTemplate` | Template should fail to render |
| `notFailedTemplate` | Template should render successfully |
| `isSubset` | Rendered output is a superset of expected |
| `lengthEqual` | Array/map length equals expected count |

Use antonym assertions (`notEqual`, `notContains`, etc.) instead of relying on `not: true` unless that is clearer.

Prefer `equal`, `contains`, and specific negative assertions over broad `exists` checks. Specific assertions catch regressions. `contains` matches a whole array element; add `any: true` to match on the listed keys only.

### Assertion Scoping Patterns

```yaml
  - it: targets the StatefulSet among objects that share its name
    templates:
      - templates/signoz/statefulset.yaml
      - templates/signoz/service.yaml
    asserts:
      - equal:
          path: spec.replicas
          value: 1
        documentSelector:
          path: kind
          value: StatefulSet
          skipEmptyTemplates: true
```

```yaml
  - it: counts only selected docs
    template: templates/secrets-clickhouse-external.yaml
    set:
      clickhouse.enabled: false
      externalClickhouse.host: clickhouse.example
      externalClickhouse.password: secret
    documentSelector:
      path: kind
      value: Secret
    asserts:
      - hasDocuments:
          count: 1
          filterAware: true
```

### Multi-Template Safety

If a suite includes several templates, set `template` on every assertion unless the test intentionally targets all templates.

Put `template` at the assertion root, not inside assertion parameters.

Wrong:

```yaml
      - notContains:
          template: templates/signoz/statefulset.yaml
          path: spec.template.spec.containers[0].env
          content:
            name: SIGNOZ_SQLSTORE_PROVIDER
          any: true
```

Correct:

```yaml
      - template: templates/signoz/statefulset.yaml
        notContains:
          path: spec.template.spec.containers[0].env
          content:
            name: SIGNOZ_SQLSTORE_PROVIDER
          any: true
```

### Path and jsonPath Guidance

- Prefer precise paths over broad existence checks.
- When map keys contain dots or slashes, use jsonPath bracket syntax.
- Keep escaping consistent to avoid false negatives.

```yaml
  - equal:
      path: metadata.labels["app.kubernetes.io/component"]
      value: signoz
```

### Conditional Rendering Tests

```yaml
  - it: should not render when autoscaling is disabled
    template: templates/otel-collector/hpa.yaml
    set:
      otelCollector.autoscaling.enabled: false
    asserts:
      - hasDocuments:
          count: 0
```

### Testing with Release Values

Only a case like this one sets `release:`.

```yaml
  - it: names the autoscaler after the release and places it in the release namespace
    template: templates/otel-collector/hpa.yaml
    release:
      name: my-release
      namespace: my-namespace
    set:
      otelCollector.autoscaling.enabled: true
    asserts:
      - equal:
          path: metadata.name
          value: my-release-signoz-otel-collector
      - equal:
          path: metadata.namespace
          value: my-namespace
```

### Render Failures

Every `fail` in a chart's templates gets a case asserting it with `failedTemplate` and the full `errorMessage`, so a reworded or dropped check shows up as a test failure. Pair the failing cases with a case that renders the replacement value and asserts `notFailedTemplate`.

No template outside the vendored charts calls `fail` yet, so the shape below uses placeholders:

```yaml
  - it: fails on <the refused value>
    set:
      <key>: <refused value>
    asserts:
      - failedTemplate:
          errorMessage: "<the full message the fail call prints>"
```

## Test File Organization

Mirror the template directory structure. A template at `templates/<component>/<template>.yaml` is tested from `tests/<component>/<template>_test.yaml`; a template at the root of `templates/` from `tests/<template>_test.yaml`. A helper file `templates/_<name>.tpl` is tested from `tests/<name>_test.yaml`, and a helper file under `templates/<component>/` from `tests/<component>/<name>_test.yaml`, named without the leading underscore:

```text
charts/signoz/tests/
  helpers_test.yaml
  clickhouse_test.yaml
  secrets-clickhouse-external_test.yaml
  signoz/
    statefulset_test.yaml
  otel-collector/
    deployment_test.yaml
  values/
    <scenario>.yaml
```

`<template>_test.yaml` is preferred. When one template carries several suites that need different suite-level `set:` or `values:`, they sit side by side as `<template>_<topic>_test.yaml`. A suite that spans components lives with the component whose behavior it asserts.

Suite filenames must end with `_test.yaml`: CI runs helm-unittest with `--file "tests/**/*_test.yaml"`, so any other file under `tests/` (the values fixtures under `tests/values/`) is never run as a suite.

## Migrating a Chart

A chart still on the flat layout moves all of its suites into the mirrored layout in one pass, in a commit of its own (`test(<chart>): ...`). File contents stay unchanged except for the `release:` rule: a suite-level `release:` is removed, expected names and namespaces become the `RELEASE-NAME` / `NAMESPACE` forms, and a case that tests release behavior keeps its own `release:`. Run the chart's tests before and after; the suite and test counts match.

New tests for a chart not yet migrated still go in the mirrored layout.

## Writing Workflow

1. Read the template being tested. Understand every conditional, value reference, helper call, and document emitted.
2. Read the helper files the template calls (every `_*.tpl` under `templates/`; in `charts/signoz`, `templates/_helpers.tpl` and `templates/_clickhouse.tpl`).
3. Read `values.yaml` to understand defaults and the full value schema.
4. Map render targets: determine whether the template emits zero, one, or many documents and which selector is stable.
5. Write tests for default rendering, significant conditional branches, selector behavior, multi-template scoping, and edge cases.
6. Run the tests.
7. Fix failures by adjusting assertions to match actual rendered output.
8. Repeat until the test file passes.

## Running Tests

CI runs the unit tests from `.github/workflows/ci.yaml` through the shared primus workflow, with the helm-unittest plugin pinned at v1.0.2 (helm-unittest issue 790). Check the local plugin with `helm plugin list`. Run from the repository root.

Run tests for one chart, as CI does:

```bash
helm unittest charts/<chart> --file 'tests/**/*_test.yaml'
```

Run one test file:

```bash
helm unittest charts/<chart> --file 'tests/<component>/<template>_test.yaml'
```

Run every chart:

```bash
for chart in charts/*/; do helm unittest "$chart" --file 'tests/**/*_test.yaml'; done
```

Without `--file`, helm-unittest reads only `tests/*_test.yaml` and silently skips every suite in a component directory.

The second gate is chart-testing lint, which the "Lint Charts" workflow runs:

```bash
ct lint --config ct.yaml --charts charts/<chart>
```

## Rules

- Only create or edit `.yaml` files under `charts/*/tests/` when this skill is being used specifically to write tests.
- Do not modify templates, `values.yaml`, `Chart.yaml`, or non-test files as part of a test-writing task unless the user explicitly expands the scope.
- `charts/redpanda` and `charts/zookeeper` are vendored: they are never edited and carry no tests.
- Never run destructive shell commands.
- Use `RELEASE-NAME` as the release name in assertions. Set `release:` only in cases that test release behavior.
- Always set deployment-mode-style flags explicitly. Do not rely on defaults when a chart has conditional rendering modes. The suite-level `set:` blocks in `charts/k8s-infra/tests` that switch every preset on or off are chart behavior and stay.
- When a template has subchart dependencies, use `set` to provide required subchart values.
- Always run the relevant helm-unittest command after writing tests.
- If a test run reveals the template does not render with default values, inspect `values.yaml` and adjust the test setup.
- Prefer `documentSelector` over hardcoded `documentIndex` for templates that can reorder output.
- Use `hasDocuments.filterAware: true` when asserting counts under selector/index filtering.
- Use `template` / `templates` at test or assertion level to prevent cross-template assertion bleed.
- For negative paths, assert absence with `notExists` or `notContains`.
- Assert every `fail` in a chart's templates with `failedTemplate`.
