{{- /* Generated from "ingress.go" */ -}}

{{- define "console.Ingress" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.ingress.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $tls := (coalesce nil) -}}
{{- range $_, $t := $values.ingress.tls -}}
{{- $hosts := (coalesce nil) -}}
{{- range $_, $host := $t.hosts -}}
{{- $hosts = (concat (default (list ) $hosts) (list (tpl $host $dot))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $tls = (concat (default (list ) $tls) (list (mustMergeOverwrite (dict ) (dict "secretName" $t.secretName "hosts" $hosts )))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $rules := (coalesce nil) -}}
{{- range $_, $host := $values.ingress.hosts -}}
{{- $paths := (coalesce nil) -}}
{{- range $_, $path := $host.paths -}}
{{- $paths = (concat (default (list ) $paths) (list (mustMergeOverwrite (dict "pathType" (coalesce nil) "backend" (dict ) ) (dict "path" $path.path "pathType" $path.pathType "backend" (mustMergeOverwrite (dict ) (dict "service" (mustMergeOverwrite (dict "name" "" "port" (dict ) ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") "port" (mustMergeOverwrite (dict ) (dict "number" ($values.service.port | int) )) )) )) )))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $rules = (concat (default (list ) $rules) (list (mustMergeOverwrite (dict ) (mustMergeOverwrite (dict ) (dict "http" (mustMergeOverwrite (dict "paths" (coalesce nil) ) (dict "paths" $paths )) )) (dict "host" (tpl $host.host $dot) )))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict ) "status" (dict "loadBalancer" (dict ) ) ) (mustMergeOverwrite (dict ) (dict "kind" "Ingress" "apiVersion" "networking.k8s.io/v1" )) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") "labels" (get (fromJson (include "console.Labels" (dict "a" (list $dot) ))) "r") "annotations" $values.ingress.annotations )) "spec" (mustMergeOverwrite (dict ) (dict "ingressClassName" $values.ingress.className "tls" $tls "rules" $rules )) ))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

