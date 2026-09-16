{{- /* Generated from "serviceaccount.go" */ -}}

{{- define "console.ServiceAccountName" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if $values.serviceAccount.create -}}
{{- if (ne $values.serviceAccount.name "") -}}
{{- $_is_returning = true -}}
{{- (dict "r" $values.serviceAccount.name) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (default "default" $values.serviceAccount.name)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "console.ServiceAccount" -}}
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
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) ) (mustMergeOverwrite (dict ) (dict "kind" "ServiceAccount" "apiVersion" "v1" )) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "name" (get (fromJson (include "console.ServiceAccountName" (dict "a" (list $dot) ))) "r") "labels" (get (fromJson (include "console.Labels" (dict "a" (list $dot) ))) "r") "namespace" $dot.Release.Namespace "annotations" $values.serviceAccount.annotations )) "automountServiceAccountToken" $values.serviceAccount.automountServiceAccountToken ))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

