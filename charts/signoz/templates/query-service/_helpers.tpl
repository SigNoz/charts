{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "queryService.name" -}}
{{- default .Chart.Name .Values.queryService.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "queryService.fullname" -}}
{{- if .Values.queryService.fullnameOverride -}}
{{- .Values.queryService.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.queryService.name -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "queryService.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "queryService.labels" -}}
helm.sh/chart: {{ include "queryService.chart" . }}
{{ include "queryService.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "queryService.selectorLabels" -}}
app.kubernetes.io/name: {{ include "queryService.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "queryService.serviceAccountName" -}}
{{- if .Values.queryService.serviceAccount.create -}}
    {{ default (include "queryService.fullname" .) .Values.queryService.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.queryService.serviceAccount.name }}
{{- end -}}
{{- end -}}
