{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "signoz.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for SigNoz.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "signoz.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
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
{{- define "signoz.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create a default fully qualified app name for queryService.
*/}}
{{- define "queryService.fullname" -}}
{{- printf "%s-%s" (include "signoz.fullname" .) .Values.queryService.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "queryService.labels" -}}
helm.sh/chart: {{ include "signoz.chart" . }}
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
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.queryService.name }}
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

{{/*
Return the initContainers image name
*/}}
{{- define "queryService.initContainers.init.image" -}}
{{- $registryName := .Values.queryService.initContainers.init.image.registry -}}
{{- $repositoryName := .Values.queryService.initContainers.init.image.repository -}}
{{- $tag := .Values.queryService.initContainers.init.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper queryService image name
*/}}
{{- define "queryService.image" -}}
{{- $registryName := .Values.queryService.image.registry -}}
{{- $repositoryName := .Values.queryService.image.repository -}}
{{- $tag := .Values.queryService.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Set query-service port
*/}}
{{- define "queryService.port" -}}
{{- default 8080 .Values.queryService.service.port  -}}
{{- end -}}

{{/*
Set query-service url
*/}}
{{- define "queryService.url" -}}
{{ include "queryService.fullname" . }}:{{ include "queryService.port" . }}
{{- end -}}


{{/*
Create a default fully qualified app name for frontend.
*/}}
{{- define "frontend.fullname" -}}
{{- printf "%s-%s" (include "signoz.fullname" .) .Values.frontend.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "frontend.labels" -}}
helm.sh/chart: {{ include "signoz.chart" . }}
release: {{ .Release.Name }}
{{ include "frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.frontend.name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "frontend.serviceAccountName" -}}
{{- if .Values.frontend.serviceAccount.create -}}
    {{ default (include "frontend.fullname" .) .Values.frontend.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.frontend.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the proper frontend image name
*/}}
{{- define "frontend.image" -}}
{{- $registryName := .Values.frontend.image.registry -}}
{{- $repositoryName := .Values.frontend.image.repository -}}
{{- $tag := .Values.frontend.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the initContainers image name
*/}}
{{- define "frontend.initContainers.init.image" -}}
{{- $registryName := .Values.frontend.initContainers.init.image.registry -}}
{{- $repositoryName := .Values.frontend.initContainers.init.image.repository -}}
{{- $tag := .Values.frontend.initContainers.init.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}



{{/*
Create a default fully qualified app name.
*/}}
{{- define "alertmanager.fullname" -}}
{{- printf "%s-%s" (include "signoz.fullname" .) .Values.alertmanager.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "alertmanager.labels" -}}
helm.sh/chart: {{ include "signoz.chart" . }}
{{ include "alertmanager.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "alertmanager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.alertmanager.name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "alertmanager.serviceAccountName" -}}
{{- if .Values.alertmanager.serviceAccount.create -}}
    {{ default (include "alertmanager.fullname" .) .Values.alertmanager.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.alertmanager.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Set alertmanager port
*/}}
{{- define "alertmanager.port" -}}
{{- default 9093 .Values.alertmanager.service.port  -}}
{{- end -}}

{{/*
Return the initContainers image name
*/}}
{{- define "alertmanager.initContainers.init.image" -}}
{{- $registryName := .Values.alertmanager.initContainers.init.image.registry -}}
{{- $repositoryName := .Values.alertmanager.initContainers.init.image.repository -}}
{{- $tag := .Values.alertmanager.initContainers.init.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper otelCollector image name
*/}}
{{- define "alertmanager.image" -}}
{{- $registryName := .Values.alertmanager.image.registry -}}
{{- $repositoryName := .Values.alertmanager.image.repository -}}
{{- $tag := .Values.alertmanager.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Set query-service url
*/}}
{{- define "alertmanager.url" -}}
{{ include "alertmanager.fullname" . }}:{{ include "alertmanager.port" . }}
{{- end -}}



{{/*
Create a default fully qualified app name for otelCollector.
*/}}
{{- define "otelCollector.fullname" -}}
{{- printf "%s-%s" (include "signoz.fullname" .) .Values.otelCollector.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "otelCollector.labels" -}}
helm.sh/chart: {{ include "signoz.chart" . }}
{{ include "otelCollector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "otelCollector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.otelCollector.name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "otelCollector.serviceAccountName" -}}
{{- if .Values.otelCollector.serviceAccount.create -}}
    {{ default (include "otelCollector.fullname" .) .Values.otelCollector.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.otelCollector.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the initContainers image name
*/}}
{{- define "otelCollector.initContainers.init.image" -}}
{{- $registryName := .Values.otelCollector.initContainers.init.image.registry -}}
{{- $repositoryName := .Values.otelCollector.initContainers.init.image.repository -}}
{{- $tag := .Values.otelCollector.initContainers.init.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper otelCollector image name
*/}}
{{- define "otelCollector.image" -}}
{{- $registryName := .Values.otelCollector.image.registry -}}
{{- $repositoryName := .Values.otelCollector.image.repository -}}
{{- $tag := .Values.otelCollector.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}



{{/*
Create a default fully qualified app name for otelCollectorMetrics.
*/}}
{{- define "otelCollectorMetrics.fullname" -}}
{{- printf "%s-%s" (include "signoz.fullname" .) .Values.otelCollectorMetrics.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "otelCollectorMetrics.labels" -}}
helm.sh/chart: {{ include "signoz.chart" . }}
{{ include "otelCollectorMetrics.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "otelCollectorMetrics.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.otelCollectorMetrics.name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "otelCollectorMetrics.serviceAccountName" -}}
{{- if .Values.otelCollectorMetrics.serviceAccount.create -}}
    {{ default (include "otelCollectorMetrics.fullname" .) .Values.otelCollectorMetrics.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.otelCollectorMetrics.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the initContainers image name
*/}}
{{- define "otelCollectorMetrics.initContainers.init.image" -}}
{{- $registryName := .Values.otelCollectorMetrics.initContainers.init.image.registry -}}
{{- $repositoryName := .Values.otelCollectorMetrics.initContainers.init.image.repository -}}
{{- $tag := .Values.otelCollectorMetrics.initContainers.init.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper otelCollectorMetrics image name
*/}}
{{- define "otelCollectorMetrics.image" -}}
{{- $registryName := .Values.otelCollectorMetrics.image.registry -}}
{{- $repositoryName := .Values.otelCollectorMetrics.image.repository -}}
{{- $tag := .Values.otelCollectorMetrics.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}



{{/*
Return the service name of Clickhouse
*/}}
{{- define "clickhouse.servicename" -}}
{{- if .Values.clickhouse.fullnameOverride -}}
{{- .Values.clickhouse.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "clickhouse" .Values.clickhouse.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Set Clickhouse http port
*/}}
{{- define "clickhouse.httpPort" -}}
{{- 8123 -}}
{{- end -}}

{{/*
Set Clickhouse tcp port
*/}}
{{- define "clickhouse.tcpPort" -}}
{{- 9000 -}}
{{- end -}}
