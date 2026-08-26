{{/*
Expand the name of the chart.
*/}}
{{- define "signoz-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec). If the release name contains the chart name it is
used as the full name.
*/}}
{{- define "signoz-operator.fullname" -}}
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
Resource name with a suffix, truncated to stay within the 63-character limit.
Takes a dict with:
  - .suffix: the suffix to append (e.g. "leader-election")
  - .context: the root context
*/}}
{{- define "signoz-operator.resourceName" -}}
{{- $fullname := include "signoz-operator.fullname" .context }}
{{- $maxLen := sub 62 (len .suffix) | int }}
{{- if gt (len $fullname) $maxLen }}
{{- printf "%s-%s" (trunc $maxLen $fullname | trimSuffix "-") .suffix | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" $fullname .suffix | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
ServiceAccount name to use. When serviceAccount.enabled is false, the operator
binds to the pre-existing ServiceAccount named in serviceAccount.name.
*/}}
{{- define "signoz-operator.serviceAccountName" -}}
{{- if and (not .Values.serviceAccount.enabled) .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name }}
{{- else }}
{{- include "signoz-operator.fullname" . }}
{{- end }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "signoz-operator.labels" -}}
app.kubernetes.io/name: {{ include "signoz-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end }}

{{/*
Selector labels. These must never change for an existing release: the
Deployment selector is immutable.
*/}}
{{- define "signoz-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
control-plane: controller-manager
{{- end }}
