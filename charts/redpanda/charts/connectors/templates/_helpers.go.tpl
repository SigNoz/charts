{{- /* Generated from "helpers.go" */ -}}

{{- define "connectors.Name" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $name := (default $dot.Chart.Name $values.nameOverride) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "connectors.trunc" (dict "a" (list $name) ))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.Fullname" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not (empty $values.fullnameOverride)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "connectors.trunc" (dict "a" (list $values.fullnameOverride) ))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- $name := (default $dot.Chart.Name $values.nameOverride) -}}
{{- if (contains $name $dot.Release.Name) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "connectors.trunc" (dict "a" (list $dot.Release.Name) ))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "connectors.trunc" (dict "a" (list (printf "%s-%s" $dot.Release.Name $name)) ))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.FullLabels" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict ) (dict "helm.sh/chart" (get (fromJson (include "connectors.ChartLabels" (dict "a" (list $dot) ))) "r") "app.kubernetes.io/managed-by" $dot.Release.Service ) (get (fromJson (include "connectors.PodLabels" (dict "a" (list $dot) ))) "r"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.PodLabels" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict ) (dict "app.kubernetes.io/name" (get (fromJson (include "connectors.Name" (dict "a" (list $dot) ))) "r") "app.kubernetes.io/instance" $dot.Release.Name "app.kubernetes.io/component" (get (fromJson (include "connectors.Name" (dict "a" (list $dot) ))) "r") ) $values.commonLabels)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.ChartLabels" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $chart := (printf "%s-%s" $dot.Chart.Name $dot.Chart.Version) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "connectors.trunc" (dict "a" (list (replace "+" "_" $chart)) ))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.Semver" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (trimPrefix "v" (get (fromJson (include "connectors.Tag" (dict "a" (list $dot) ))) "r"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.ServiceAccountName" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if $values.serviceAccount.create -}}
{{- $_is_returning = true -}}
{{- (dict "r" (default (get (fromJson (include "connectors.Fullname" (dict "a" (list $dot) ))) "r") $values.serviceAccount.name)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (default "default" $values.serviceAccount.name)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.ServiceName" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $_is_returning = true -}}
{{- (dict "r" (default (get (fromJson (include "connectors.Fullname" (dict "a" (list $dot) ))) "r") $values.service.name)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.Tag" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $tag := (default $dot.Chart.AppVersion $values.image.tag) -}}
{{- $matchString := "^v(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$" -}}
{{- if (not (mustRegexMatch $matchString $tag)) -}}
{{- $_ := (fail "image.tag must start with a 'v' and be a valid semver") -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $tag) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.trunc" -}}
{{- $s := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (trimSuffix "-" (trunc (63 | int) $s))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

