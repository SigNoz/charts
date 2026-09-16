{{- /* Generated from "hpa.go" */ -}}

{{- define "console.HorizontalPodAutoscaler" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.autoscaling.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $metrics := (list ) -}}
{{- if (ne (toJson $values.autoscaling.targetCPUUtilizationPercentage) "null") -}}
{{- $metrics = (concat (default (list ) $metrics) (list (mustMergeOverwrite (dict "type" "" ) (dict "type" "Resource" "resource" (mustMergeOverwrite (dict "name" "" "target" (dict "type" "" ) ) (dict "name" "cpu" "target" (mustMergeOverwrite (dict "type" "" ) (dict "type" "Utilization" "averageUtilization" $values.autoscaling.targetCPUUtilizationPercentage )) )) )))) -}}
{{- end -}}
{{- if (ne (toJson $values.autoscaling.targetMemoryUtilizationPercentage) "null") -}}
{{- $metrics = (concat (default (list ) $metrics) (list (mustMergeOverwrite (dict "type" "" ) (dict "type" "Resource" "resource" (mustMergeOverwrite (dict "name" "" "target" (dict "type" "" ) ) (dict "name" "memory" "target" (mustMergeOverwrite (dict "type" "" ) (dict "type" "Utilization" "averageUtilization" $values.autoscaling.targetMemoryUtilizationPercentage )) )) )))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "scaleTargetRef" (dict "kind" "" "name" "" ) "maxReplicas" 0 ) "status" (dict "desiredReplicas" 0 "currentMetrics" (coalesce nil) ) ) (mustMergeOverwrite (dict ) (dict "apiVersion" "autoscaling/v2" "kind" "HorizontalPodAutoscaler" )) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") "labels" (get (fromJson (include "console.Labels" (dict "a" (list $dot) ))) "r") )) "spec" (mustMergeOverwrite (dict "scaleTargetRef" (dict "kind" "" "name" "" ) "maxReplicas" 0 ) (dict "scaleTargetRef" (mustMergeOverwrite (dict "kind" "" "name" "" ) (dict "apiVersion" "apps/v1" "kind" "Deployment" "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) "minReplicas" ($values.autoscaling.minReplicas | int) "maxReplicas" ($values.autoscaling.maxReplicas | int) "metrics" $metrics )) ))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

