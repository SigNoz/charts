{{- /* Generated from "helpers.go" */ -}}

{{- define "console.Name" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $name := (default $dot.Chart.Name $values.nameOverride) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "console.cleanForK8s" (dict "a" (list $name) ))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "console.Fullname" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (ne $values.fullnameOverride "") -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "console.cleanForK8s" (dict "a" (list $values.fullnameOverride) ))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- $name := (default $dot.Chart.Name $values.nameOverride) -}}
{{- if (contains $name $dot.Release.Name) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "console.cleanForK8s" (dict "a" (list $dot.Release.Name) ))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "console.cleanForK8s" (dict "a" (list (printf "%s-%s" $dot.Release.Name $name)) ))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "console.ChartLabel" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $chart := (printf "%s-%s" $dot.Chart.Name $dot.Chart.Version) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "console.cleanForK8s" (dict "a" (list (replace "+" "_" $chart)) ))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "console.Labels" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $labels := (dict "helm.sh/chart" (get (fromJson (include "console.ChartLabel" (dict "a" (list $dot) ))) "r") "app.kubernetes.io/managed-by" $dot.Release.Service ) -}}
{{- if (ne $dot.Chart.AppVersion "") -}}
{{- $_ := (set $labels "app.kubernetes.io/version" $dot.Chart.AppVersion) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict ) $labels (get (fromJson (include "console.SelectorLabels" (dict "a" (list $dot) ))) "r") $values.commonLabels)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "console.SelectorLabels" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict "app.kubernetes.io/name" (get (fromJson (include "console.Name" (dict "a" (list $dot) ))) "r") "app.kubernetes.io/instance" $dot.Release.Name )) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "console.cleanForK8s" -}}
{{- $s := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (trimSuffix "-" (trunc (63 | int) $s))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

