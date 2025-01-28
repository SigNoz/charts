{{/*
Expand the name of the chart.
*/}}
{{- define "hotrod.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hotrod.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hotrod.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels for the hotrod
*/}}
{{- define "hotrod.labels" -}}
helm.sh/chart: {{ include "hotrod.chart" . }}
{{ include "hotrod.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for the hotrod
*/}}
{{- define "hotrod.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hotrod.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: hotrod
{{- end }}

{{/*
Create the name of the service account to use for the hotrod
*/}}
{{- define "hotrod.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hotrod.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name for the locust
*/}}
{{- define "hotrod.locust.fullname" -}}
{{- printf "%s-locust" (include "hotrod.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Labels for the locust
*/}}
{{- define "hotrod.locust.labels" -}}
helm.sh/chart: {{ include "hotrod.chart" . }}
{{ include "hotrod.locust.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for the locust
*/}}
{{- define "hotrod.locust.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hotrod.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: locust
{{- end }}

{{/*
Create the name of the service account to use for the locust
*/}}
{{- define "hotrod.locust.serviceAccountName" -}}
{{- if .Values.locust.serviceAccount.create }}
{{- default (include "hotrod.locust.fullname" .) .Values.locust.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.locust.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Secret name to be used for SigNoz ingestion key.
*/}}
{{- define "hotrod.otel.secretName" }}
{{- if .Values.otel.existingSecretName }}
{{- .Values.otel.existingSecretName }}
{{- else }}
{{- include "hotrod.fullname" . }}-ingestion-key
{{- end }}
{{- end }}

{{/*
Secret key to be used for SigNoz ingestion key.
*/}}
{{- define "hotrod.otel.secretKey" }}
{{- if .Values.otel.existingSecretName }}
{{- required "otel.existingSecretKey is required when otel.existingSecretName is set" .Values.otel.existingSecretKey }}
{{- else }}
{{- print "signoz-ingestion-key" }}
{{- end }}
{{- end }}

{{/*
OTLP exporter environment variables used by Hotrod.
*/}}
{{- define "hotrod.otlp-env" }}
- name: OTEL_EXPORTER_OTLP_ENDPOINT
  value: {{ required "otel.endpoint is required" .Values.otel.endpoint }}
# - name: OTEL_EXPORTER_OTLP_INSECURE
#   value: {{ default true .Values.otel.insecure | quote }}
{{- if or .Values.otel.existingSecretName .Values.otel.ingestionKey }}
- name: SIGNOZ_INGESTION_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "hotrod.otel.secretName" . }}
      key: {{ include "hotrod.otel.secretKey" . }}
- name: OTEL_EXPORTER_OTLP_HEADERS
  value: "signoz-access-token=$(SIGNOZ_INGESTION_KEY)"
{{- end }}
{{- end }}
