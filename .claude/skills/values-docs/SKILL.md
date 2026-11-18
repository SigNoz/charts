---
name: values-docs
description: Writing standards for the helm-docs comments in a chart's values.yaml. Apply when adding or editing a values key or its comment, reviewing a diff that touches them, or migrating a chart's values comments to this form. The comments are published documentation: make chart-docs renders them verbatim into the chart's README.md, and CI fails when the committed README drifts from them.
---

# Values docs

The comments above keys in `charts/<chart>/values.yaml` are not code comments.
`make chart-docs` runs helm-docs v1.14.2 (`go run`, `--template-files=README.md.gotmpl`,
`--sort-values-order=file`) and publishes them verbatim into the Configuration
tables of each chart's `README.md`: one row per key, with its type, default and
description. Write them for the operator installing the chart, not for the
maintainer reading the template.

The charts that carry a `README.md.gotmpl` are `charts/signoz`,
`charts/k8s-infra`, `charts/postgresql`, `charts/signoz-mcp-server` and
`charts/signoz-operator`. The "Generate Helm Docs" workflow
(`.github/workflows/helm-docs.yaml`) regenerates `charts/signoz`,
`charts/k8s-infra` and `charts/signoz-mcp-server` on every pull request and
fails on any diff. `charts/redpanda` and `charts/zookeeper` are vendored; their
comments are not edited.

## The comment form

- Document a key with `# -- description` immediately above it; continuation
  lines keep `#` without `--`. Annotation lines follow the description.
- Do not use the key-prefixed form (`# clickhouse.enabled -- ...`). helm-docs
  attaches it by path from anywhere in the file, so a renamed or moved key
  silently loses its description.
- Do not restate a concrete default: helm-docs renders the Default column from
  the YAML value. Use `# @default -- <text>` only when the YAML value is empty,
  null or computed, and explain what the empty, null or sentinel value does.
  The README templates print `@default` text in place of the YAML value, so a
  restated default that falls out of step publishes the wrong default.
- Keep `# @section -- <Name>` on every key. helm-docs assigns sections per
  value, not per block; a key without one lands in the unsectioned table.
- `# @raw` for verbatim blocks; `# @ignored` to exclude a key and its children
  (a subchart's block whose keys belong to that chart, an internal setting).
- Never leave `# --` markers inside commented-out example blocks: helm-docs
  cannot attach them and the text silently disappears.
- Every user-visible key gets a description; cross-reference sibling keys
  with their full path (`externalClickhouse.host`, `clickhouse.extraVolumes`).

```yaml
clickhouse:
  # -- Installs ClickHouse, with the operator and ZooKeeper it needs. When false,
  # every component connects to `externalClickhouse` instead, and
  # `externalClickhouse.host` must be set.
  # @section -- ClickHouse
  enabled: true
  persistence:
    # -- StorageClass of the ClickHouse data claim. `-` sets an empty
    # `storageClassName`, which disables dynamic provisioning; `global.storageClass`
    # overrides it.
    # @default -- the cluster's default StorageClass
    # @section -- ClickHouse
    storageClass: null
```

## Quality bar

State the effect and when to change the setting; never restate the name;
state units in prose and spell them out (seconds, mebibytes); list legal
values in prose; no internal jargon; describe current behavior, not roadmap.
A changed default, unit, or behavior that the comment describes updates the
comment in the same diff.

After editing, run `make chart-docs CHARTS=charts/<chart>` from the repository
root and commit the regenerated `README.md` with the `values.yaml` change. CI
diffs it.

## Migrating a chart

A chart still on the key-prefixed form moves to this one in a single pass:

1. Rewrite every `# <key> -- ` opener to `# -- ` directly above its key, and
   move any detached comment to the key it names.
2. Delete each `# @default` line that restates the YAML value. Keep the ones on
   empty, null or computed values and make them say what that value does.
3. Keep every `# @section` and `# @ignored` line.
4. Rewrite descriptions to the quality bar.
5. Run `make chart-docs CHARTS=charts/<chart>` and read the README diff: the
   Default column shows the YAML values, descriptions change, and no key
   appears in or disappears from the tables.
6. Run `ct lint --config ct.yaml --charts charts/<chart>`; the rendered
   manifests do not change, so `helm unittest charts/<chart> --file 'tests/**/*_test.yaml'`
   passes unchanged.

One `docs(<chart>):` commit per chart, carrying `values.yaml` and its
regenerated `README.md` together.

## What NOT to flag in review

- Subjective wording or polish on a comment that already states effect,
  default, and legal values. Never bikeshed phrasing.
- Template comments, `NOTES.txt` text, test strings, or `README.md.gotmpl`
  prose outside the values tables.
- Anything in `charts/redpanda` or `charts/zookeeper`.
- A chart not yet migrated still using the key-prefixed form on lines the
  diff does not touch.

## Severity (for reviews)

- **high**: changed default, unit, or behavior with the comment (or its
  `@default`) left stating the old one (the README becomes wrong on merge), or
  a `values.yaml` comment change committed without the regenerated README (CI
  fails).
- **medium** (default): new user-facing key with an empty, missing, or
  name-echo description, a `# --` lost inside a commented-out block, or a key
  without `@section`.
- **low**: present and accurate but incomplete (no units, legal values not
  listed, an empty or null default left unexplained, or a `@default` that
  restates the YAML value).

Zero findings on a diff that adds user-facing keys is a claim: state which
keys you checked.
