---
paths:
  - "charts/**/values.yaml"
  - "charts/**/README.md"
  - "charts/**/README.md.gotmpl"
  - "charts/**/values.schema.json"
---

# values.yaml comments

## The comments are published
`make chart-docs CHARTS=charts/<chart>` runs helm-docs v1.14.2 against the
chart's `README.md.gotmpl` and renders the `values.yaml` comments into its
`README.md`. `.github/workflows/helm-docs.yaml` regenerates `charts/signoz`,
`charts/k8s-infra` and `charts/signoz-mcp-server` on every PR and fails on
drift. The charts with a `README.md.gotmpl` are `charts/signoz`,
`charts/k8s-infra`, `charts/postgresql`, `charts/signoz-mcp-server` and
`charts/signoz-operator`.

## Comment form
- **One line for the table**: `# --` is one short, noun-led sentence stating
  what the value sets. When to change it, units, interactions and examples go
  above it as plain `#` lines, which never reach the README. A continuation
  line only finishes the sentence or adds one cross-reference.
- **Leaves only**: a map that only groups keys carries no `# --`; its children
  get rows under their full paths. A `# --` on a non-empty map collapses it
  into one row and hides its undocumented children: only for an opaque value,
  always with `# @default -- "<text>"`.
- **Vocabulary**: a recurring Kubernetes field takes the sentence the skill's
  vocabulary table gives it, in every component and chart.
- **`# --` directly above the key**; never the key-prefixed `# <key> -- `.
  Lines a diff does not touch keep theirs until the chart migrates.
- **`# @default -- "<text>"`** only for an empty, null or computed value or an
  opaque map, as a quoted JSON string: the README templates parse it as JSON
  and render unquoted prose as `null`.
- **`# @section -- <Name>`** on every documented key.
- **`# @raw` and `# @ignored`** as helm-docs defines them.
- **No `# --` inside a commented-out block**: helm-docs drops it.
- **`##` is not a helm-docs marker**: a `## --` line documents nothing.
- **Same diff**: a changed default or behavior updates its comment.
- **README with values**: the regenerated `README.md` is committed with the
  `values.yaml` change, never separately.
- **`README.md` is generated**: never hand-edit it; the template is
  `README.md.gotmpl`.

## Schema
- **Generated**: `values.schema.json` comes from `values.yaml` and its `# --`
  comments via `make chart-schema CHARTS=charts/<chart>`; never hand-edit it.
  A chart that has one commits the regenerated schema with every
  `values.yaml` change.
- **Strict**: unknown keys are rejected; `# @schema additionalProperties:true`
  keeps subchart blocks, `global` and free-form maps open.
- **`# @schema` above `# --`**, with the prose, and only where inference is
  wrong: a `null` default, a polymorphic or nullable key, an enum, `tpl`.
- **Moved keys** stay one release cycle as `<key>: null` with `# @ignored`
  and `# @schema type:[<old type>, null]`.

The full standard, the vocabulary table, the schema, migration and review
severities are `.claude/skills/values-docs/SKILL.md`.
