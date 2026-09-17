{{- /* Generated from "service.nodeport.go" */ -}}

{{- define "redpanda.NodePortService" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (or (not $values.external.enabled) (not $values.external.service.enabled)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- if (ne $values.external.type "NodePort") -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $ports := (coalesce nil) -}}
{{- range $name, $listener := $values.listeners.admin.external -}}
{{- if (not (get (fromJson (include "redpanda.AdminExternal.IsEnabled" (dict "a" (list $listener)))) "r")) -}}
{{- continue -}}
{{- end -}}
{{- $nodePort := ($listener.port | int) -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $listener.advertisedPorts)))) "r") | int) (0 | int)) -}}
{{- $nodePort = (index $listener.advertisedPorts (0 | int)) -}}
{{- end -}}
{{- $ports = (concat (default (list) $ports) (list (mustMergeOverwrite (dict "port" 0 "targetPort" 0) (dict "name" (printf "admin-%s" $name) "protocol" "TCP" "port" ($listener.port | int) "nodePort" $nodePort)))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- range $name, $listener := $values.listeners.kafka.external -}}
{{- if (not (get (fromJson (include "redpanda.KafkaExternal.IsEnabled" (dict "a" (list $listener)))) "r")) -}}
{{- continue -}}
{{- end -}}
{{- $nodePort := ($listener.port | int) -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $listener.advertisedPorts)))) "r") | int) (0 | int)) -}}
{{- $nodePort = (index $listener.advertisedPorts (0 | int)) -}}
{{- end -}}
{{- $ports = (concat (default (list) $ports) (list (mustMergeOverwrite (dict "port" 0 "targetPort" 0) (dict "name" (printf "kafka-%s" $name) "protocol" "TCP" "port" ($listener.port | int) "nodePort" $nodePort)))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- range $name, $listener := $values.listeners.http.external -}}
{{- if (not (get (fromJson (include "redpanda.HTTPExternal.IsEnabled" (dict "a" (list $listener)))) "r")) -}}
{{- continue -}}
{{- end -}}
{{- $nodePort := ($listener.port | int) -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $listener.advertisedPorts)))) "r") | int) (0 | int)) -}}
{{- $nodePort = (index $listener.advertisedPorts (0 | int)) -}}
{{- end -}}
{{- $ports = (concat (default (list) $ports) (list (mustMergeOverwrite (dict "port" 0 "targetPort" 0) (dict "name" (printf "http-%s" $name) "protocol" "TCP" "port" ($listener.port | int) "nodePort" $nodePort)))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- range $name, $listener := $values.listeners.schemaRegistry.external -}}
{{- if (not (get (fromJson (include "redpanda.SchemaRegistryExternal.IsEnabled" (dict "a" (list $listener)))) "r")) -}}
{{- continue -}}
{{- end -}}
{{- $nodePort := ($listener.port | int) -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $listener.advertisedPorts)))) "r") | int) (0 | int)) -}}
{{- $nodePort = (index $listener.advertisedPorts (0 | int)) -}}
{{- end -}}
{{- $ports = (concat (default (list) $ports) (list (mustMergeOverwrite (dict "port" 0 "targetPort" 0) (dict "name" (printf "schema-%s" $name) "protocol" "TCP" "port" ($listener.port | int) "nodePort" $nodePort)))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $annotations := $values.external.annotations -}}
{{- if (eq (toJson $annotations) "null") -}}
{{- $annotations = (dict) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict) "status" (dict "loadBalancer" (dict))) (mustMergeOverwrite (dict) (dict "apiVersion" "v1" "kind" "Service")) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" (printf "%s-external" (get (fromJson (include "redpanda.ServiceName" (dict "a" (list $dot)))) "r")) "namespace" $dot.Release.Namespace "labels" (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r") "annotations" $annotations)) "spec" (mustMergeOverwrite (dict) (dict "externalTrafficPolicy" "Local" "ports" $ports "publishNotReadyAddresses" true "selector" (get (fromJson (include "redpanda.StatefulSetPodLabelsSelector" (dict "a" (list $dot)))) "r") "sessionAffinity" "None" "type" "NodePort"))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

