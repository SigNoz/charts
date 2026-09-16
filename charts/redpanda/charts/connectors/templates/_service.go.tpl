{{- /* Generated from "service.go" */ -}}

{{- define "connectors.Service" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $ports := (list (mustMergeOverwrite (dict "port" 0 "targetPort" 0 ) (dict "name" "rest-api" "port" ($values.connectors.restPort | int) "targetPort" ($values.connectors.restPort | int) "protocol" "TCP" ))) -}}
{{- range $_, $port := $values.service.ports -}}
{{- $ports = (concat (default (list ) $ports) (list (mustMergeOverwrite (dict "port" 0 "targetPort" 0 ) (dict "name" $port.name "port" ($port.port | int) "targetPort" ($port.port | int) "protocol" "TCP" )))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict ) "status" (dict "loadBalancer" (dict ) ) ) (mustMergeOverwrite (dict ) (dict "apiVersion" "v1" "kind" "Service" )) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "name" (get (fromJson (include "connectors.ServiceName" (dict "a" (list $dot) ))) "r") "labels" (merge (dict ) (get (fromJson (include "connectors.FullLabels" (dict "a" (list $dot) ))) "r") $values.service.annotations) )) "spec" (mustMergeOverwrite (dict ) (dict "ipFamilies" (list "IPv4") "ipFamilyPolicy" "SingleStack" "ports" $ports "selector" (get (fromJson (include "connectors.PodLabels" (dict "a" (list $dot) ))) "r") "sessionAffinity" "None" "type" "ClusterIP" )) ))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

