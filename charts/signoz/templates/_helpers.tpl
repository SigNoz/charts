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
Return namespace of the signoz release
*/}}
{{- define "signoz.namespace" -}}
{{- .Release.Namespace -}}
{{- end -}}

{{/*
Return the Kubernetes cluster DNS domain: global.clusterDomain if set, else `cluster.local`.
Every host name the chart writes takes its domain from this helper, never from a literal. A custom
resource with a domain field, such as the ClickHouseInstallation's namespaceDomainPattern, gets
it only when the domain is not `cluster.local`.
*/}}
{{- define "signoz.clusterDomain" -}}
{{- default "cluster.local" .Values.global.clusterDomain -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "signoz.labels" -}}
helm.sh/chart: {{ include "signoz.chart" . }}
{{ include "signoz.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "signoz.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ default "signoz" .Values.signoz.name }}
{{- end -}}

{{/*
Set signoz port
*/}}
{{- define "signoz.port" -}}
{{- default 8080 .Values.signoz.service.port  -}}
{{- end -}}


{{/*
Set signoz url
*/}}
{{- define "signoz.url" -}}
{{ include "signoz.fullname" . }}:{{ include "signoz.port" . }}
{{- end -}}


{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "ingress.supportsPathType" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "ingress.isStable" -}}
  {{- eq (include "ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}


{{/*
Common K8s environment variables used by SigNoz OtelCollector.
*/}}
{{- define "snippet.k8s-env" }}
- name: K8S_NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
- name: K8S_POD_IP
  valueFrom:
    fieldRef:
      apiVersion: v1
      fieldPath: status.podIP
- name: K8S_HOST_IP
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
- name: K8S_POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: K8S_POD_UID
  valueFrom:
    fieldRef:
      fieldPath: metadata.uid
- name: K8S_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
{{- end }}

{{/*
Common ENV variables for the telemetry store migrator containers
*/}}
{{- define "snippet.telemetryStoreMigrator-env" }}
{{- include "clickhouse.env" . }}
- name: SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_DSN
  value: {{ include "clickhouse.dsn" . | quote }}
- name: SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_CLUSTER
  value: $(CLICKHOUSE_CLUSTER)
- name: SIGNOZ_OTEL_COLLECTOR_TIMEOUT
  value: {{ .Values.telemetryStoreMigrator.timeout | default "10m" | quote }}
- name: SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_REPLICATION
  value: {{ .Values.telemetryStoreMigrator.enableReplication | quote }}
{{- end }}

