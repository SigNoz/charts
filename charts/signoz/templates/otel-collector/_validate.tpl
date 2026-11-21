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
{{- if dig "additionalEnvs" dict $oc }}
{{ "`otelCollector.additionalEnvs` has moved to `otelCollector.env`: a list of Kubernetes EnvVar objects, `- name: <NAME>` with `value` or `valueFrom`." }}
{{- end }}
{{- if dig "securityContext" dict $oc }}
{{ "`otelCollector.securityContext` has moved to `otelCollector.containerSecurityContext`: the same Kubernetes SecurityContext, which also applies to the `check` init container." }}
{{- end }}
{{- if dig "command" "extraArgs" list $oc }}
{{ "`otelCollector.command.extraArgs` has moved to `otelCollector.extraArgs`: the same list of arguments." }}
{{- end }}
{{- /*
The old probe keys are refused whenever they hold a value, because `enabled: false` meant "no probe".
*/ -}}
{{- range $probe := list "livenessProbe" "readinessProbe" }}
{{- $p := get $oc $probe }}
{{- $present := list }}
{{- if kindIs "map" $p }}
{{- range $key := list "enabled" "port" "path" }}
{{- if and (hasKey $p $key) (not (kindIs "invalid" (get $p $key))) }}
{{- $present = append $present (ternary (printf "`otelCollector.%s.%s`" $probe $key) (printf "`.%s`" $key) (not $present)) }}
{{- end }}
{{- end }}
{{- end }}
{{- if $present }}
{{- $names := first $present }}
{{- if gt (len $present) 1 }}
{{- $names = printf "%s and %s" (initial $present | join ", ") (last $present) }}
{{- end }}
{{ printf "%s %s moved to `otelCollector.%s.httpGet.port` and `.httpGet.path`: write the probe object, and `otelCollector.%s: null` for no probe." $names (ternary "has" "have" (eq (len $present) 1)) $probe $probe }}
{{- end }}
{{- end }}
{{- if dig "customLivenessProbe" dict $oc }}
{{ "`otelCollector.customLivenessProbe` has moved to `otelCollector.livenessProbe`: write the probe object itself there, with `httpGet: null` for another handler." }}
{{- end }}
{{- if dig "customReadinessProbe" dict $oc }}
{{ "`otelCollector.customReadinessProbe` has moved to `otelCollector.readinessProbe`: write the probe object itself there, with `httpGet: null` for another handler." }}
{{- end }}
{{- end -}}
