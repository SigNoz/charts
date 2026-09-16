{{- /* Generated from "podmonitor.go" */ -}}

{{- define "connectors.PodMonitor" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.monitoring.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "podMetricsEndpoints" (coalesce nil) "selector" (dict ) "namespaceSelector" (dict ) ) ) (mustMergeOverwrite (dict ) (dict "apiVersion" "monitoring.coreos.com/v1" "kind" "PodMonitor" )) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "name" (get (fromJson (include "connectors.Fullname" (dict "a" (list $dot) ))) "r") "labels" $values.monitoring.labels "annotations" $values.monitoring.annotations )) "spec" (mustMergeOverwrite (dict "podMetricsEndpoints" (coalesce nil) "selector" (dict ) "namespaceSelector" (dict ) ) (dict "namespaceSelector" $values.monitoring.namespaceSelector "podMetricsEndpoints" (list (mustMergeOverwrite (dict "bearerTokenSecret" (dict "key" "" ) ) (dict "path" "/" "port" "prometheus" ))) "selector" (mustMergeOverwrite (dict ) (dict "matchLabels" (get (fromJson (include "connectors.PodLabels" (dict "a" (list $dot) ))) "r") )) )) ))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

