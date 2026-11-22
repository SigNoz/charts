{{/*
clickhouse.validate: the ClickHouse values rules.
Emits: one line per rule the values break, holding that rule's message; nothing when every rule
holds. validate.yaml gathers these lines with every other component's and fails once.
*/}}
{{- define "clickhouse.validate" -}}
{{- /*
Values keys that no longer do anything at these paths (removed, or moved to a new path).
Fail the render instead of ignoring them, so an old values file is caught at `helm upgrade` time rather than silently misapplied.
`clickhouse.clickhouseOperator` and `clickhouse.zookeeper` fail when present with a non-null value, an empty map included, so a
null placeholder passes.
*/ -}}
{{- if not (kindIs "invalid" (index (.Values.clickhouse | default dict) "clickhouseOperator")) }}
{{ "`clickhouse.clickhouseOperator` has moved to `altinity-clickhouse-operator`: the keys of Altinity's chart, at the top level." }}
{{- end }}
{{- if not (kindIs "invalid" (index (.Values.clickhouse | default dict) "zookeeper")) }}
{{ "`clickhouse.zookeeper` has moved to `zookeeper`: the same keys, at the top level." }}
{{- end }}
{{- /*
ClickHouse values that took the Kubernetes shape: the probes, the pod security context and the extra volumes.
An old key fails when it is set and non-empty; a probe in the old enabled/port/path shape fails when any of those keys holds a value.
*/ -}}
{{- $ch := .Values.clickhouse | default dict }}
{{- if dig "securityContext" dict $ch }}
{{ "`clickhouse.securityContext` has moved to `clickhouse.podSecurityContext`: the same fields, without `enabled`." }}
{{- end }}
{{- if dig "customStartupProbe" dict $ch }}
{{ "`clickhouse.customStartupProbe` has moved to `clickhouse.startupProbe`: the probe object itself." }}
{{- end }}
{{- if dig "customLivenessProbe" dict $ch }}
{{ "`clickhouse.customLivenessProbe` has moved to `clickhouse.livenessProbe`: the probe object itself." }}
{{- end }}
{{- if dig "customReadinessProbe" dict $ch }}
{{ "`clickhouse.customReadinessProbe` has moved to `clickhouse.readinessProbe`: the probe object itself." }}
{{- end }}
{{- if dig "additionalVolumes" list $ch }}
{{ "`clickhouse.additionalVolumes` has moved to `clickhouse.extraVolumes`: the same list of Kubernetes Volume objects." }}
{{- end }}
{{- if dig "additionalVolumeMounts" list $ch }}
{{ "`clickhouse.additionalVolumeMounts` has moved to `clickhouse.extraVolumeMounts`: the same list of Kubernetes VolumeMount objects." }}
{{- end }}
{{- $startupProbe := dig "startupProbe" dict $ch | default dict }}
{{- if or (not (kindIs "invalid" (index $startupProbe "enabled"))) (not (kindIs "invalid" (index $startupProbe "port"))) (not (kindIs "invalid" (index $startupProbe "path"))) }}
{{ "`clickhouse.startupProbe` no longer takes the enabled/port/path shape: write the probe object, or `null` for no probe." }}
{{- end }}
{{- $livenessProbe := dig "livenessProbe" dict $ch | default dict }}
{{- if or (not (kindIs "invalid" (index $livenessProbe "enabled"))) (not (kindIs "invalid" (index $livenessProbe "port"))) (not (kindIs "invalid" (index $livenessProbe "path"))) }}
{{ "`clickhouse.livenessProbe` no longer takes the enabled/port/path shape: write the probe object, or `null` for no probe." }}
{{- end }}
{{- $readinessProbe := dig "readinessProbe" dict $ch | default dict }}
{{- if or (not (kindIs "invalid" (index $readinessProbe "enabled"))) (not (kindIs "invalid" (index $readinessProbe "port"))) (not (kindIs "invalid" (index $readinessProbe "path"))) }}
{{ "`clickhouse.readinessProbe` no longer takes the enabled/port/path shape: write the probe object, or `null` for no probe." }}
{{- end }}
{{- /*
ClickHouse image blocks without a registry key: the repository carries the registry, and global.imageRegistry replaces it.
An old registry key fails when it is set and non-empty; `clickhouse.initContainers` fails when present with a non-null value, an empty map included.
*/ -}}
{{- if dig "image" "registry" "" $ch }}
{{ "`clickhouse.image.registry` has been removed: put the registry in front of `clickhouse.image.repository`." }}
{{- end }}
{{- if dig "logs" "system" "image" "registry" "" $ch }}
{{ "`clickhouse.logs.system.image.registry` has been removed: put the registry in front of `clickhouse.logs.system.image.repository`." }}
{{- end }}
{{- if not (kindIs "invalid" (index $ch "initContainers")) }}
{{ "`clickhouse.initContainers` has moved to `clickhouse.udf` and `clickhouse.extraInitContainers`: the histogramQuantile download and your own init containers." }}
{{- end }}
{{- /*
The pod's labels and annotations moved under clickhouse.pod. An old key fails only when it holds an entry, so an empty map
copied from an older values file passes.
*/ -}}
{{- if dig "podAnnotations" dict $ch }}
{{ "`clickhouse.podAnnotations` has moved to `clickhouse.pod.annotations`: the same map of annotations." }}
{{- end }}
{{- if dig "podLabels" dict $ch }}
{{ "`clickhouse.podLabels` has moved to `clickhouse.pod.labels`: the same map of labels." }}
{{- end }}
{{- /*
ClickHouse in another namespace while none of the operator's watch settings (namespaceOverride, watchNamespaces,
the watch list in its config file) is set: the operator watches only the release namespace, so the
ClickHouseInstallation would never be reconciled. The check never judges those settings' values.
*/ -}}
{{- if and .Values.clickhouse.enabled .Values.clickhouse.namespace (ne .Values.clickhouse.namespace .Release.Namespace) (eq (include "clickhouse.operatorEnabled" .) "true") }}
{{- $ns := .Values.clickhouse.namespace }}
{{- $op := index .Values "altinity-clickhouse-operator" | default dict }}
{{- if and (not ($op.namespaceOverride | default "")) (not ($op.watchNamespaces | default list)) (not (dig "configs" "files" "config.yaml" "watch" "namespaces" "include" list $op)) }}
{{ printf "`clickhouse.namespace` is set to `%s` but the operator's watch settings are untouched: set `altinity-clickhouse-operator.namespaceOverride: %s`, or make the operator watch that namespace." $ns $ns }}
{{- end }}
{{- end }}
{{- end -}}
