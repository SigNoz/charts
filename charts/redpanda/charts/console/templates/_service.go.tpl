{{- /* Generated from "service.go" */ -}}

{{- define "console.Service" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $port := (mustMergeOverwrite (dict "port" 0 "targetPort" 0 ) (dict "name" "http" "port" (($values.service.port | int) | int) "protocol" "TCP" )) -}}
{{- if (ne (toJson $values.service.targetPort) "null") -}}
{{- $_ := (set $port "targetPort" $values.service.targetPort) -}}
{{- end -}}
{{- if (and (contains "NodePort" (toString $values.service.type)) (ne (toJson $values.service.nodePort) "null")) -}}
{{- $_ := (set $port "nodePort" $values.service.nodePort) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict ) "status" (dict "loadBalancer" (dict ) ) ) (mustMergeOverwrite (dict ) (dict "apiVersion" "v1" "kind" "Service" )) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") "namespace" $dot.Release.Namespace "labels" (get (fromJson (include "console.Labels" (dict "a" (list $dot) ))) "r") "annotations" $values.service.annotations )) "spec" (mustMergeOverwrite (dict ) (dict "type" $values.service.type "selector" (get (fromJson (include "console.SelectorLabels" (dict "a" (list $dot) ))) "r") "ports" (list $port) )) ))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

