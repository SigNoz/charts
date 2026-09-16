{{- /* Generated from "values.go" */ -}}

{{- define "connectors.Auth.SASLEnabled" -}}
{{- $c := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $saslEnabled := (not (empty $c.sasl.userName)) -}}
{{- $saslEnabled = (and $saslEnabled (not (empty $c.sasl.mechanism))) -}}
{{- $saslEnabled = (and $saslEnabled (not (empty $c.sasl.secretRef))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $saslEnabled) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

