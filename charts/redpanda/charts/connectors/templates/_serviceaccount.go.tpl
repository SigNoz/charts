{{- /* Generated from "serviceaccount.go" */ -}}

{{- define "connectors.ServiceAccount" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.serviceAccount.create) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) ) (mustMergeOverwrite (dict ) (dict "apiVersion" "v1" "kind" "ServiceAccount" )) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "annotations" $values.serviceAccount.annotations "labels" (get (fromJson (include "connectors.FullLabels" (dict "a" (list $dot) ))) "r") "name" (get (fromJson (include "connectors.ServiceAccountName" (dict "a" (list $dot) ))) "r") "namespace" $dot.Release.Namespace )) "automountServiceAccountToken" $values.serviceAccount.automountServiceAccountToken ))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

