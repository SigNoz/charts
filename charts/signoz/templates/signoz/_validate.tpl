{{/*
signoz.validate: the SigNoz server's values rules.
Emits: one line per rule the values break, holding that rule's message; nothing when every rule
holds. validate.yaml gathers these lines with every other component's and fails once.
*/}}
{{- define "signoz.validate" -}}
{{- $signoz := .Values.signoz | default dict }}
{{- range $probe := list "livenessProbe" "readinessProbe" }}
{{- $values := get $signoz $probe | default dict }}
{{- $old := list }}
{{- range $key := list "enabled" "port" "path" }}
{{- if and (kindIs "map" $values) (hasKey $values $key) (not (kindIs "invalid" (get $values $key))) }}
{{- $old = append $old (printf "`signoz.%s.%s`" $probe $key) }}
{{- end }}
{{- end }}
{{- if $old }}
{{- $named := ternary (first $old) (printf "%s and %s" (join ", " (initial $old)) (last $old)) (eq (len $old) 1) }}
{{ printf "%s %s moved to `signoz.%s.httpGet.port` and `signoz.%s.httpGet.path`: write the probe object, and `signoz.%s: null` for no probe." $named (ternary "has" "have" (eq (len $old) 1)) $probe $probe $probe }}
{{- end }}
{{- end }}
{{- if dig "customLivenessProbe" dict $signoz }}
{{ "`signoz.customLivenessProbe` has moved to `signoz.livenessProbe`: write the probe object itself, with `httpGet: null` for another handler." }}
{{- end }}
{{- if dig "customReadinessProbe" dict $signoz }}
{{ "`signoz.customReadinessProbe` has moved to `signoz.readinessProbe`: write the probe object itself, with `httpGet: null` for another handler." }}
{{- end }}
{{- if dig "additionalArgs" list $signoz }}
{{ "`signoz.additionalArgs` has moved to `signoz.extraArgs`: the same list of arguments." }}
{{- end }}
{{- if dig "podAnnotations" dict $signoz }}
{{ "`signoz.podAnnotations` has moved to `signoz.pod.annotations`: the same map of annotations." }}
{{- end }}
{{- if dig "securityContext" dict $signoz }}
{{ "`signoz.securityContext` has moved to `signoz.containerSecurityContext`: the same Kubernetes SecurityContext of the container." }}
{{- end }}
{{- if dig "additionalVolumeMounts" list $signoz }}
{{ "`signoz.additionalVolumeMounts` has moved to `signoz.extraVolumeMounts`: the same list of Kubernetes VolumeMount objects." }}
{{- end }}
{{- if dig "additionalVolumes" list $signoz }}
{{ "`signoz.additionalVolumes` has moved to `signoz.extraVolumes`: the same list of Kubernetes Volume objects." }}
{{- end }}
{{- end -}}
