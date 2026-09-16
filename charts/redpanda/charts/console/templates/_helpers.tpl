{{/*
Expand the name of the chart.
Used by tests/test-connection.yaml
*/}}
{{- define "console.name" -}}
{{- get ((include "console.Name" (dict "a" (list .))) | fromJson) "r" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
Used by tests/test-connection.yaml
*/}}
{{- define "console.fullname" -}}
{{- get ((include "console.Fullname" (dict "a" (list .))) | fromJson) "r" }}
{{- end }}

{{/*
Common labels
Used by tests/test-connection.yaml
*/}}
{{- define "console.labels" -}}
{{- (get ((include "console.Labels" (dict "a" (list .))) | fromJson) "r") | toYaml -}}
{{- end }}
