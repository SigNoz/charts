{{- /* Generated from "configmap.go" */ -}}

{{- define "console.ConfigMap" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.configmap.create) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $data := (dict "config.yaml" (printf "# from .Values.console.config\n%s\n" (tpl (toYaml $values.console.config) $dot)) ) -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $values.console.roles) ))) "r") | int) (0 | int)) -}}
{{- $_ := (set $data "roles.yaml" (tpl (toYaml (dict "roles" $values.console.roles )) $dot)) -}}
{{- end -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $values.console.roleBindings) ))) "r") | int) (0 | int)) -}}
{{- $_ := (set $data "role-bindings.yaml" (tpl (toYaml (dict "roleBindings" $values.console.roleBindings )) $dot)) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) ) (mustMergeOverwrite (dict ) (dict "apiVersion" "v1" "kind" "ConfigMap" )) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") "labels" (get (fromJson (include "console.Labels" (dict "a" (list $dot) ))) "r") )) "data" $data ))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

