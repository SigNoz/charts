{{- /* Generated from "service_internal.go" */ -}}

{{- define "redpanda.MonitoringEnabledLabel" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict "monitoring.redpanda.com/enabled" (printf "%t" $values.monitoring.enabled))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ServiceInternal" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $ports := (list) -}}
{{- $ports = (concat (default (list) $ports) (list (mustMergeOverwrite (dict "port" 0 "targetPort" 0) (dict "name" "admin" "protocol" "TCP" "appProtocol" $values.listeners.admin.appProtocol "port" ($values.listeners.admin.port | int) "targetPort" ($values.listeners.admin.port | int))))) -}}
{{- if $values.listeners.http.enabled -}}
{{- $ports = (concat (default (list) $ports) (list (mustMergeOverwrite (dict "port" 0 "targetPort" 0) (dict "name" "http" "protocol" "TCP" "port" ($values.listeners.http.port | int) "targetPort" ($values.listeners.http.port | int))))) -}}
{{- end -}}
{{- $ports = (concat (default (list) $ports) (list (mustMergeOverwrite (dict "port" 0 "targetPort" 0) (dict "name" "kafka" "protocol" "TCP" "port" ($values.listeners.kafka.port | int) "targetPort" ($values.listeners.kafka.port | int))))) -}}
{{- $ports = (concat (default (list) $ports) (list (mustMergeOverwrite (dict "port" 0 "targetPort" 0) (dict "name" "rpc" "protocol" "TCP" "port" ($values.listeners.rpc.port | int) "targetPort" ($values.listeners.rpc.port | int))))) -}}
{{- if $values.listeners.schemaRegistry.enabled -}}
{{- $ports = (concat (default (list) $ports) (list (mustMergeOverwrite (dict "port" 0 "targetPort" 0) (dict "name" "schemaregistry" "protocol" "TCP" "port" ($values.listeners.schemaRegistry.port | int) "targetPort" ($values.listeners.schemaRegistry.port | int))))) -}}
{{- end -}}
{{- $annotations := (dict) -}}
{{- if (ne (toJson $values.service) "null") -}}
{{- $annotations = $values.service.internal.annotations -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict) "status" (dict "loadBalancer" (dict))) (mustMergeOverwrite (dict) (dict "apiVersion" "v1" "kind" "Service")) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" (get (fromJson (include "redpanda.ServiceName" (dict "a" (list $dot)))) "r") "namespace" $dot.Release.Namespace "labels" (merge (dict) (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r") (get (fromJson (include "redpanda.MonitoringEnabledLabel" (dict "a" (list $dot)))) "r")) "annotations" $annotations)) "spec" (mustMergeOverwrite (dict) (dict "type" "ClusterIP" "publishNotReadyAddresses" true "clusterIP" "None" "selector" (get (fromJson (include "redpanda.StatefulSetPodLabelsSelector" (dict "a" (list $dot)))) "r") "ports" $ports))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

