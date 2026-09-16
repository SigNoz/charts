{{- /* Generated from "chart.go" */ -}}

{{- define "console.render" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $manifests := (list (get (fromJson (include "console.ServiceAccount" (dict "a" (list $dot) ))) "r") (get (fromJson (include "console.Secret" (dict "a" (list $dot) ))) "r") (get (fromJson (include "console.ConfigMap" (dict "a" (list $dot) ))) "r") (get (fromJson (include "console.Service" (dict "a" (list $dot) ))) "r") (get (fromJson (include "console.Ingress" (dict "a" (list $dot) ))) "r") (get (fromJson (include "console.Deployment" (dict "a" (list $dot) ))) "r") (get (fromJson (include "console.HorizontalPodAutoscaler" (dict "a" (list $dot) ))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $manifests) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

