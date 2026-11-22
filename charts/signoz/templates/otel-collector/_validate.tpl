{{/*
otelCollector.validate: the collector values rules.
Emits: one line per rule the values break, holding that rule's message; nothing when every rule
holds. validate.yaml gathers these lines with every other component's and fails once.
*/}}
{{- define "otelCollector.validate" -}}
{{- $oc := .Values.otelCollector | default dict }}
{{- if dig "podAnnotations" dict $oc }}
{{ "`otelCollector.podAnnotations` has moved to `otelCollector.pod.annotations`: the same map." }}
{{- end }}
{{- if dig "podLabels" dict $oc }}
{{ "`otelCollector.podLabels` has moved to `otelCollector.pod.labels`: the same map." }}
{{- end }}
{{- if dig "additionalEnvs" dict $oc }}
{{ "`otelCollector.additionalEnvs` has moved to `otelCollector.env`: a list of Kubernetes EnvVar objects." }}
{{- end }}
{{- if eq (toString (dig "lowCardinalityExceptionGrouping" false $oc)) "true" }}
{{ "`otelCollector.lowCardinalityExceptionGrouping` has moved to `otelCollector.env`: set `LOW_CARDINAL_EXCEPTION_GROUPING` there." }}
{{- end }}
{{- if dig "securityContext" dict $oc }}
{{ "`otelCollector.securityContext` has moved to `otelCollector.containerSecurityContext`: the same SecurityContext." }}
{{- end }}
{{- if dig "command" "extraArgs" list $oc }}
{{ "`otelCollector.command.extraArgs` has moved to `otelCollector.extraArgs`: the same list of arguments." }}
{{- end }}
{{- $commandName := dig "command" "name" "" $oc }}
{{- if and $commandName (ne (toString $commandName) "/signoz-otel-collector") }}
{{ "`otelCollector.command.name` has been removed: the collector always runs `/signoz-otel-collector`." }}
{{- end }}
{{- if dig "image" "registry" "" $oc }}
{{ "`otelCollector.image.registry` has been removed: put the registry in front of `otelCollector.image.repository`." }}
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
{{ printf "`otelCollector.%s` no longer takes the enabled/port/path shape: write the probe object, or `null` for no probe." $probe }}
{{- end }}
{{- end }}
{{- if dig "customLivenessProbe" dict $oc }}
{{ "`otelCollector.customLivenessProbe` has moved to `otelCollector.livenessProbe`: the probe object itself." }}
{{- end }}
{{- if dig "customReadinessProbe" dict $oc }}
{{ "`otelCollector.customReadinessProbe` has moved to `otelCollector.readinessProbe`: the probe object itself." }}
{{- end }}
{{- end -}}
