---
paths:
  - "charts/**/values.yaml"
  - "charts/**/README.md"
  - "charts/**/README.md.gotmpl"
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
- **`# -- description`** directly above the key; continuation lines are
  plain `#`.
- **No key-prefixed form**: never write `# <key> -- `. Lines a diff does not
  touch keep theirs until the chart migrates.
- **`# @default -- "<text>"`** only for an empty, null or computed value, as a
  quoted JSON string: the README templates parse it as JSON and render
  unquoted prose as `null`.
- **`# @section -- <Name>`** on every key.
- **`# @raw` and `# @ignored`** as helm-docs defines them.
- **No `# --` inside a commented-out block**: helm-docs drops it.
- **Same diff**: a changed default or behavior updates its comment.
- **README with values**: the regenerated `README.md` is committed with the
  `values.yaml` change, never separately.
- **`README.md` is generated**: never hand-edit it; the template is
  `README.md.gotmpl`.

The full standard, quality bar, migration and review severities are
`.claude/skills/values-docs/SKILL.md`.
