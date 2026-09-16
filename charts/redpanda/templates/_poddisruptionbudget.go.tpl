{{- /* Generated from "poddisruptionbudget.go" */ -}}

{{- define "redpanda.PodDisruptionBudget" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $budget := ($values.statefulset.budget.maxUnavailable | int) -}}
{{- $minReplicas := ((div ($values.statefulset.replicas | int) (2 | int)) | int) -}}
{{- if (and (gt $budget (1 | int)) (gt $budget $minReplicas)) -}}
{{- $_ := (fail (printf "statefulset.budget.maxUnavailable is set too high to maintain quorum: %d > %d" $budget $minReplicas)) -}}
{{- end -}}
{{- $maxUnavailable := ($budget | int) -}}
{{- $matchLabels := (get (fromJson (include "redpanda.StatefulSetPodLabelsSelector" (dict "a" (list $dot)))) "r") -}}
{{- $_ := (set $matchLabels "redpanda.com/poddisruptionbudget" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict) "status" (dict "disruptionsAllowed" 0 "currentHealthy" 0 "desiredHealthy" 0 "expectedPods" 0)) (mustMergeOverwrite (dict) (dict "apiVersion" "policy/v1" "kind" "PodDisruptionBudget")) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") "namespace" $dot.Release.Namespace "labels" (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r"))) "spec" (mustMergeOverwrite (dict) (dict "selector" (mustMergeOverwrite (dict) (dict "matchLabels" $matchLabels)) "maxUnavailable" $maxUnavailable))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

