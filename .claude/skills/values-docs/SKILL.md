---
name: values-docs
description: Writing standards for the helm-docs comments in a chart's values.yaml. Apply when adding or editing a values key or its comment, reviewing a diff that touches them, migrating a chart's values comments to this form, or generating a chart's values.schema.json. The comments are published documentation: make chart-docs renders them verbatim into the chart's README.md, and CI fails when the committed README drifts from them.
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
fails on any diff. `charts/redpanda` and `charts/zookeeper` are vendored: they
are never edited and carry no tests.

## The comment form

- **One line for the table, detail above it.** The `# --` line is one short,
  noun-led sentence stating what the value sets (`# -- Image pull policy.`).
  When to change it, units, legal values, interactions and examples go above
  it as plain `#` lines: helm-docs reads a comment from its last `# --` line
  down, so they stay in `values.yaml` and never reach the README. A
  continuation line only finishes the sentence or adds one cross-reference.
- **Leaves only.** A map that only groups keys (`clickhouse:`, `image:`,
  `persistence:`, `serviceAccount:`) carries no `# --`; helm-docs gives each
  child a row under its full path. A `# --` on a non-empty map collapses it
  into one row and hides every child without its own `# --`: do that only for
  an opaque value (a free-form config map, a probe object, a file set), always
  with `# @default -- "<text>"`, or the whole structure lands in the Default
  cell. An empty map or list, or a list of scalars, counts as a leaf: its row
  shows the YAML value.
- **`# --` directly above the key**, annotations after it. Never the
  key-prefixed `# <key> -- `: helm-docs attaches it by path from anywhere in
  the file, so a moved key silently loses its description.
- **`# @default -- "<text>"`** only on an empty, null or computed value or an
  opaque map, saying what that value does; a concrete default renders from the
  YAML value. The text is a quoted JSON string: the README templates parse it
  as JSON, render unquoted prose as `null`, and print it in place of the YAML
  value, so a restated default that falls out of step publishes a wrong one.
- **`# @section -- <Name>`** on every documented key; sections are per value,
  so a key without one lands in the unsectioned table.
- **`# @raw`** for verbatim blocks; **`# @ignored`** to exclude a key and its
  children (a subchart's block, an internal setting).
- **No `# --` inside a commented-out block**: helm-docs drops it silently.
- **`##` is not a helm-docs marker**: a `## --` line documents nothing.

```yaml
clickhouse:
  # When false, every component connects to `externalClickhouse` instead, and
  # `externalClickhouse.host` must be set.
  # -- Install ClickHouse.
  # @section -- ClickHouse
  enabled: true
  image:
    # The tag SigNoz is tested against. Moving off it is supported only to a
    # version SigNoz lists as compatible.
    # -- Image tag.
    # @section -- ClickHouse
    tag: 25.12.5
  persistence:
    # `-` sets an empty `storageClassName`, which disables dynamic
    # provisioning; `global.storageClass` overrides this value.
    # -- StorageClass of the claim.
    # @default -- "the cluster's default StorageClass"
    # @section -- ClickHouse
    storageClass: null
```

This renders three rows (`clickhouse.enabled`, `clickhouse.image.tag`,
`clickhouse.persistence.storageClass`), each described by its one sentence;
the three maps get none.

A changed default, unit or behavior updates its comment in the same diff.
After editing, run `make chart-docs CHARTS=charts/<chart>` from the repository
root and commit the regenerated `README.md` with the `values.yaml` change; CI
diffs it. `README.md` is never edited by hand.

## Vocabulary

A recurring Kubernetes field gets the same `# --` sentence in every component
and every chart. This table is the authoritative list.

| Key | `# --` sentence |
|---|---|
| `image.registry` / `.repository` / `.tag` / `.pullPolicy` | `Image registry.` / `Image repository.` / `Image tag.` / `Image pull policy.` |
| `imagePullSecrets` | `Secrets for pulling images from a private registry.` |
| `replicaCount`, `replicas` | `Number of replicas.` |
| `resources` | `Resource requests and limits for the container.` |
| `nodeSelector` | `Node labels for pod assignment.` |
| `tolerations` | `Tolerations for pod assignment.` |
| `affinity` | `Affinity rules for pod assignment.` |
| `topologySpreadConstraints` | `Topology spread constraints for pod assignment.` |
| `annotations`, `podAnnotations` / `labels`, `podLabels` | `Annotations to add to the <object>.` / `Labels to add to the <object>.` |
| `podSecurityContext` / `securityContext`, `containerSecurityContext` | `Security context for the pod.` / `Security context for the container.` |
| `serviceAccount.create` / `.name` / `.annotations` | `Create a ServiceAccount.` / `Name of the ServiceAccount.` / `Annotations to add to the ServiceAccount.` |
| `service.type` / `.port` / `.annotations` | `Kubernetes Service type.` / `Service port.` / `Annotations to add to the Service.` |
| `persistence.enabled` / `.storageClass` / `.size` / `.accessModes` / `.existingClaim` | `Enable persistence with a PersistentVolumeClaim.` / `StorageClass of the claim.` / `Size of the claim.` / `Access modes of the claim.` / `Name of an existing claim to use.` |
| `env`, `extraEnv` / `envFrom` | `Extra environment variables for the container.` / `Sources of extra environment variables for the container.` |
| `extraVolumes` / `extraVolumeMounts` | `Extra volumes for the pod.` / `Extra volume mounts for the container.` |
| `initContainers` / `sidecars` | `Extra init containers for the pod.` / `Extra containers for the pod.` |
| `livenessProbe` / `readinessProbe` / `startupProbe` | `Liveness probe for the container.` / `Readiness probe for the container.` / `Startup probe for the container.` |
| `priorityClassName` | `Priority class of the pod.` |
| `nameOverride` / `fullnameOverride` | `Override the chart name.` / `Override the full resource name.` |
| `enabled` on a component | `Install <component>.` |

`<object>` names the object: pod, Service, ServiceAccount, Job. `<component>`
is the component's one-word name (`# -- Install ClickHouse.`), with nothing
else on the line. A map-valued field in this table is an opaque value: it
keeps its `# --`, and a non-empty default takes an `@default`.

A key not in the table gets one sentence saying what it sets, with at most one
constraint or cross-reference in backticks (`externalClickhouse.host`). Units
are spelled out (seconds, mebibytes) in the prose above the line, never in the
`# --` line.

## Schema

A chart's `values.schema.json` is generated from `values.yaml` and its `# --`
comments, never edited by hand. `make chart-schema CHARTS=charts/<chart>` runs
the `helm-values-schema-json` generator through a pinned `go run`, the way
`make chart-docs` runs helm-docs:

```sh
go run github.com/losisin/helm-values-schema-json/v2@v2.6.1 \
  --values charts/<chart>/values.yaml --output charts/<chart>/values.schema.json \
  --draft 7 --use-helm-docs --no-additional-properties
```

The target lands in the `Makefile` with the first chart's schema, together
with a CI job that regenerates the schemas and fails on `git diff`, in the
shape of the README check. `--draft 7` emits draft-07, which Helm validates
against. `--use-helm-docs` makes each `# --` sentence, with its continuation
lines, the property's description. `--no-additional-properties` sets
`additionalProperties: false` on the root and on every object that does not
set its own.

- **Strict by default.** The root and the chart's own blocks reject unknown
  keys. `# @schema additionalProperties:true` keeps a block open: every
  subchart block (the keys named under `dependencies` in `Chart.yaml`),
  `global`, and free-form maps (`settings`, `files`, `defaultProfiles`, `env`,
  `resources`, `affinity`, the security contexts, the probes). Label maps
  (`annotations`, `labels`, `nodeSelector`) stay open to strings only with
  `# @schema additionalProperties:{type: string}`.
- **`# @schema` lines sit above the `# --` line**, with the other prose, so
  helm-docs never prints them; a `# @schema` line between `# --` and the key
  fails the generator. Keywords share one line, separated by semicolons.
- **Annotate only where inference is wrong.** The generator types each key
  from its YAML value. A `null` default needs `type:[<type>, null]`; a count
  an autoscaler may unset, `type:[integer, null]`; a quantity or duration,
  `type:[string, integer]`; an enum such as `pullPolicy`,
  `enum:[IfNotPresent, Always, Never]`; anything rendered through `tpl`,
  `type:string`. Counts and ports are `integer`, never `number`.
- **Moved keys.** The old key stays in `values.yaml` for one release cycle as
  `<key>: null` with `# @ignored` (no README row) and
  `# @schema type:[<old type>, null]` (the schema admits it), so the chart's
  `fail` or `required` check for the old key gives the move message. A moved
  map also needs `additionalProperties:true` on that line, or the strict
  schema rejects its contents first. After the cycle the placeholder is
  deleted and the schema rejects the key as unknown.

```yaml
clickhouse:
  image:
    # Set `Always` only for a mutable tag.
    # @schema enum:[IfNotPresent, Always, Never]
    # -- Image pull policy.
    # @section -- ClickHouse
    pullPolicy: IfNotPresent
  persistence:
    # @schema type:[string, null]
    # -- StorageClass of the claim.
    # @default -- "the cluster's default StorageClass"
    # @section -- ClickHouse
    storageClass: null
```

With a schema in place, `helm install`, `upgrade`, `template` and `lint`
reject unknown keys and wrong types before any template renders, and
helm-unittest validates every `set:` against it, so a suite that sets a wrong
type becomes a `failedTemplate` case.

A chart gets its schema after its comment migration, in its own PR: generate,
annotate until `helm lint`, `helm template` with default values and the unit
suites pass with the schema in place, then commit the schema with its
annotations. From then on every `values.yaml` change regenerates it in the
same diff.

## Migrating a chart

A chart still on the key-prefixed form or on long descriptions moves to this
form in a single pass:

1. Rewrite every `# <key> -- ` opener to `# -- ` directly above its key, and
   move any detached comment to the key it names.
2. Split each long description into the one-line `# --` and plain `#` prose
   above it.
3. Remove `# --` from structural maps and give each child its own. The maps'
   rows disappear from the README, which is expected; opaque maps keep theirs
   with an `@default`.
4. Apply the vocabulary to every recurring field.
5. Delete each `# @default` that restates the YAML value. Keep the ones on
   empty, null or computed values and on opaque maps, saying what that value
   does. Keep every `# @section` and `# @ignored` line.
6. Run `make chart-docs CHARTS=charts/<chart>` and read the README diff: the
   Default column shows the YAML values, each description is one sentence,
   structural maps give way to rows for their children, and no other key
   appears in or disappears from the tables.
7. Prove only comments changed:
   `diff <(git show HEAD:charts/<chart>/values.yaml | yq -o=json) <(yq -o=json charts/<chart>/values.yaml)`
   prints nothing, `.claude/hooks/render-compare.sh HEAD <chart>` prints
   `IDENTICAL`, and `ct lint --config ct.yaml --charts charts/<chart>` and
   `helm unittest charts/<chart> --file 'tests/**/*_test.yaml'` pass unchanged.

One `docs(<chart>):` commit per chart, carrying `values.yaml` and its
regenerated `README.md` together.

## What NOT to flag in review

- Subjective wording or polish on a chart-specific sentence that already
  follows the form. Never bikeshed phrasing; the vocabulary is the only fixed
  wording.
- Template comments, `NOTES.txt` text, test strings, or `README.md.gotmpl`
  prose outside the values tables.
- Anything in `charts/redpanda` or `charts/zookeeper`.
- A chart not yet migrated, on lines the diff does not touch: key-prefixed
  openers, long `# --` lines, `# --` on structural maps.

## Severity (for reviews)

- **high**: changed default, unit, or behavior with the comment (or its
  `@default`) left stating the old one (the README becomes wrong on merge), or
  a `values.yaml` comment change committed without the regenerated README (CI
  fails), or a `values.yaml` change committed without the regenerated
  `values.schema.json` when the chart has one.
- **medium** (default): new user-facing key with an empty, missing, or
  name-echo description (a vocabulary sentence is not a name echo), a `# --`
  lost inside a commented-out block, a key without `@section`, a `# --` line
  longer than one sentence or carrying prose that belongs above it, a recurring
  field whose sentence departs from the vocabulary, a `# --` on a structural
  map, or a new nullable or polymorphic key without a `# @schema` annotation.
- **low**: present and accurate but incomplete (no units, legal values not
  listed, an empty or null default left unexplained, or a `@default` that
  restates the YAML value).

Zero findings on a diff that adds user-facing keys is a claim: state which
keys you checked.
