{{/*
clickhouse.validate: the ClickHouse values rules.
Emits: one line per rule the values break, holding that rule's message; nothing when every rule
holds. validate.yaml gathers these lines with every other component's and fails once.
*/}}
{{- define "clickhouse.validate" -}}
{{- /*
Values keys that no longer do anything at these paths (removed, or moved to a new path).
Fail the render instead of ignoring them, so an old values file is caught at `helm upgrade` time rather than silently misapplied.
*/ -}}
{{- if hasKey (.Values.clickhouse | default dict) "clickhouseOperator" }}
{{ "`clickhouse.clickhouseOperator` has moved to `altinity-clickhouse-operator`: the operator's settings in the keys of Altinity's chart, at the top level; `altinity-clickhouse-operator.enabled: false` skips the operator." }}
{{- end }}
{{- if dig "altinity-clickhouse-operator" dict (.Values.clickhouse | default dict) }}
{{ "`clickhouse.altinity-clickhouse-operator` has moved to `altinity-clickhouse-operator`: the same keys, at the top level." }}
{{- end }}
{{- if hasKey (.Values.clickhouse | default dict) "zookeeper" }}
{{ "`clickhouse.zookeeper` has moved to `zookeeper`: the same keys, at the top level; `clickhouse.externalZookeeper` is unchanged." }}
{{- end }}
{{- /*
ClickHouse values that took the Kubernetes shape: the probes, the pod security context and the extra volumes.
An old key fails when it is set and non-empty; a probe in the old enabled/port/path shape fails when any of those keys holds a value.
*/ -}}
{{- $ch := .Values.clickhouse | default dict }}
{{- if dig "securityContext" dict $ch }}
{{ "`clickhouse.securityContext` has moved to `clickhouse.podSecurityContext` and `clickhouse.containerSecurityContext`: the pod's fields, without `enabled`, under `podSecurityContext`, and the container's under `containerSecurityContext`." }}
{{- end }}
{{- if dig "customStartupProbe" dict $ch }}
{{ "`clickhouse.customStartupProbe` has moved to `clickhouse.startupProbe`: the probe object itself, with `httpGet: null` for an `exec`, `tcpSocket` or `grpc` probe." }}
{{- end }}
{{- if dig "customLivenessProbe" dict $ch }}
{{ "`clickhouse.customLivenessProbe` has moved to `clickhouse.livenessProbe`: the probe object itself, with `httpGet: null` for an `exec`, `tcpSocket` or `grpc` probe." }}
{{- end }}
{{- if dig "customReadinessProbe" dict $ch }}
{{ "`clickhouse.customReadinessProbe` has moved to `clickhouse.readinessProbe`: the probe object itself, with `httpGet: null` for an `exec`, `tcpSocket` or `grpc` probe." }}
{{- end }}
{{- if dig "additionalVolumes" list $ch }}
{{ "`clickhouse.additionalVolumes` has moved to `clickhouse.extraVolumes`: the same list of Kubernetes Volume objects." }}
{{- end }}
{{- if dig "additionalVolumeMounts" list $ch }}
{{ "`clickhouse.additionalVolumeMounts` has moved to `clickhouse.extraVolumeMounts`: the same list of Kubernetes VolumeMount objects." }}
{{- end }}
{{- $startupProbe := dig "startupProbe" dict $ch | default dict }}
{{- if or (not (kindIs "invalid" (index $startupProbe "enabled"))) (not (kindIs "invalid" (index $startupProbe "port"))) (not (kindIs "invalid" (index $startupProbe "path"))) }}
{{ "`clickhouse.startupProbe.enabled`, `.port` and `.path`, the old enabled/port/path shape, have moved to `clickhouse.startupProbe.httpGet.port` and `.httpGet.path`: write the probe object, and `clickhouse.startupProbe: null` for `enabled: false`." }}
{{- end }}
{{- $livenessProbe := dig "livenessProbe" dict $ch | default dict }}
{{- if or (not (kindIs "invalid" (index $livenessProbe "enabled"))) (not (kindIs "invalid" (index $livenessProbe "port"))) (not (kindIs "invalid" (index $livenessProbe "path"))) }}
{{ "`clickhouse.livenessProbe.enabled`, `.port` and `.path`, the old enabled/port/path shape, have moved to `clickhouse.livenessProbe.httpGet.port` and `.httpGet.path`: write the probe object, and `clickhouse.livenessProbe: null` for `enabled: false`." }}
{{- end }}
{{- $readinessProbe := dig "readinessProbe" dict $ch | default dict }}
{{- if or (not (kindIs "invalid" (index $readinessProbe "enabled"))) (not (kindIs "invalid" (index $readinessProbe "port"))) (not (kindIs "invalid" (index $readinessProbe "path"))) }}
{{ "`clickhouse.readinessProbe.enabled`, `.port` and `.path`, the old enabled/port/path shape, have moved to `clickhouse.readinessProbe.httpGet.port` and `.httpGet.path`: write the probe object, and `clickhouse.readinessProbe: null` for `enabled: false`." }}
{{- end }}
{{- /*
ClickHouse image blocks without a registry key: the repository carries the registry, and global.imageRegistry replaces it.
An old registry key fails when it is set and non-empty; `clickhouse.initContainers` fails on its presence alone.
*/ -}}
{{- if dig "image" "registry" "" $ch }}
{{ "`clickhouse.image.registry` has been removed: put the registry in front of `clickhouse.image.repository`, as in `my.registry/clickhouse/clickhouse-server`, or set `global.imageRegistry`." }}
{{- end }}
{{- if dig "logs" "system" "image" "registry" "" $ch }}
{{ "`clickhouse.logs.system.image.registry` has been removed: put the registry in front of `clickhouse.logs.system.image.repository`, as in `my.registry/signoz/signoz-otel-collector`, or set `global.imageRegistry`." }}
{{- end }}
{{- if hasKey $ch "initContainers" }}
{{ "`clickhouse.initContainers` has moved to `clickhouse.udf` and `clickhouse.extraInitContainers`: the histogramQuantile download's `enabled` and `command` under `clickhouse.udf`, which runs on the ClickHouse image, and your own init containers in `clickhouse.extraInitContainers`, as Kubernetes Container objects." }}
{{- end }}
{{- /*
The pod's labels and annotations moved under clickhouse.pod. An old key fails only when it holds an entry, so an empty map
copied from an older values file passes.
*/ -}}
{{- if dig "podAnnotations" dict $ch }}
{{ "`clickhouse.podAnnotations` has moved to `clickhouse.pod.annotations`: the same map of annotations." }}
{{- end }}
{{- if dig "podLabels" dict $ch }}
{{ "`clickhouse.podLabels` has moved to `clickhouse.pod.labels`: the same map of labels; a key named like one of the chart's selector labels is ignored." }}
{{- end }}
{{- /*
ClickHouse in another namespace with none of the operator's watch settings set.
This check protects installs that set `clickhouse.namespace` under older chart versions, where the operator was
installed into that namespace. The operator now stays in the release namespace and watches only it unless told
otherwise, so an unchanged values file would leave the CHI unreconciled.
It fires only when none of the operator's watch settings (namespaceOverride, watchNamespaces, the watch list in
the operator's config file) has been set; it never judges their value.
*/ -}}
{{- if and .Values.clickhouse.enabled .Values.clickhouse.namespace (ne .Values.clickhouse.namespace .Release.Namespace) (eq (include "clickhouse.operatorEnabled" .) "true") }}
{{- $ns := .Values.clickhouse.namespace }}
{{- $op := index .Values "altinity-clickhouse-operator" | default dict }}
{{- if and (not ($op.namespaceOverride | default "")) (not ($op.watchNamespaces | default list)) (not (dig "configs" "files" "config.yaml" "watch" "namespaces" "include" list $op)) }}
{{ printf "`clickhouse.namespace` is set to `%s` but the operator's watch settings are untouched, so it would watch only the release namespace and never reconcile the ClickHouseInstallation. Older chart versions installed the operator into that namespace; to keep that layout set `altinity-clickhouse-operator.namespaceOverride: %s`. To keep the operator in the release namespace instead, set `altinity-clickhouse-operator.watchNamespaces: [\"%s\"]` (or the watch list inside `altinity-clickhouse-operator.configs.files.config.yaml`) and `altinity-clickhouse-operator.rbac.namespaceScoped: false` so it has rights there." $ns $ns $ns }}
{{- end }}
{{- end }}
{{- end -}}
