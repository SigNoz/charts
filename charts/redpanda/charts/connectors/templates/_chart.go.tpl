{{- /* Generated from "chart.go" */ -}}

{{- define "connectors.render" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $manifests := (list (get (fromJson (include "connectors.Deployment" (dict "a" (list $dot) ))) "r") (get (fromJson (include "connectors.PodMonitor" (dict "a" (list $dot) ))) "r") (get (fromJson (include "connectors.Service" (dict "a" (list $dot) ))) "r") (get (fromJson (include "connectors.ServiceAccount" (dict "a" (list $dot) ))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $manifests) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

