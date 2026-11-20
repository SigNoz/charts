{{/*
otelCollector.validate: the collector values rules.
Emits: one line per rule the values break, holding that rule's message; nothing when every rule
holds. validate.yaml gathers these lines with every other component's and fails once.
*/}}
{{- define "otelCollector.validate" -}}
{{- $oc := .Values.otelCollector | default dict }}
{{- if dig "podAnnotations" dict $oc }}
{{ "`otelCollector.podAnnotations` has moved to `otelCollector.pod.annotations`: the same map of pod annotations, with the same defaults." }}
{{- end }}
{{- if dig "podLabels" dict $oc }}
{{ "`otelCollector.podLabels` has moved to `otelCollector.pod.labels`: the same map of pod labels." }}
{{- end }}
{{- if dig "securityContext" dict $oc }}
{{ "`otelCollector.securityContext` has moved to `otelCollector.containerSecurityContext`: the same Kubernetes SecurityContext, which also applies to the `check` init container." }}
{{- end }}
{{- end -}}
