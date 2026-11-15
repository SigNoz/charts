{{/* vim: set filetype=mustache: */}}

{{/*
Chart-wide helpers: chart name, fullname and namespace, ingress API detection,
env snippets shared by several components, and the postgresql subchart service.
Component helpers live in _<component>.tpl.
*/}}

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
Return true if Let's Encrypt ClusterIssuer of `cert-manager` should be created.
*/}}
{{- define "ingress.letsencrypt" -}}
{{- $clusterIssuerEnabled := index (index .Values "cert-manager") "letsencrypt" -}}
{{- if ne ($clusterIssuerEnabled | toString) "<nil>" -}}
  {{ $clusterIssuerEnabled }}
{{- else if and (index (index .Values "ingress-nginx") "enabled") (index (index .Values "cert-manager") "enabled") -}}
  true
{{- else -}}
  false
{{- end -}}
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
Common ClickHouse ENV variables and helpers used by SigNoz
Shim for clickhouse.env; it remains until its callers in other components are rewritten.
*/}}
{{- define "snippet.clickhouse-env" }}
{{- include "clickhouse.env" . }}
{{- end }}

{{/*
Minimized ClickHouse ENV variables for user credentials
Shim for clickhouse.credentialsEnv; it remains until its callers in other components are rewritten.
*/}}
{{- define "snippet.clickhouse-credentials" }}
{{- include "clickhouse.credentialsEnv" . }}
{{- end }}

{{/*
Common ENV variables for the telemetry store migrator containers
*/}}
{{- define "snippet.telemetryStoreMigrator-env" }}
{{- include "snippet.clickhouse-credentials" . }}
- name: SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_DSN
  value: "tcp://$(CLICKHOUSE_USER):$(CLICKHOUSE_PASSWORD)@$(CLICKHOUSE_HOST):$(CLICKHOUSE_PORT)"
- name: SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_CLUSTER
  value: $(CLICKHOUSE_CLUSTER)
- name: SIGNOZ_OTEL_COLLECTOR_TIMEOUT
  value: {{ .Values.telemetryStoreMigrator.timeout | default "10m" | quote }}
- name: SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_REPLICATION
  value: {{ .Values.telemetryStoreMigrator.enableReplication | quote }}
{{- end }}

{{/* Helper for the postgresql subchart until it is folded into this chart. */}}
{{/*
Return the service fqdn of Postgresql
*/}}
{{- define "postgresql.service" -}}
{{- if .Values.postgresql.enabled -}}
{{- $username := "$(POSTGRES_USER)" -}}
{{- $password := "$(POSTGRES_PASSWORD)" -}}
{{- $database := "$(POSTGRES_DB)" -}}
{{- $port := "$(POSTGRES_PORT)" -}}
{{- $name := "" -}}
{{- if .Values.postgresql.fullnameOverride -}}
  {{- $name = .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- $name = default "postgresql" .Values.postgresql.nameOverride -}}
  {{- if contains $name .Release.Name -}}
    {{- $name = .Release.Name | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name = printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}
{{- $namespace := .Values.postgresql.namespace -}}
{{- $clusterDomain := default "cluster.local" .Values.global.clusterDomain -}}
{{- if and $namespace (ne $namespace .Release.Namespace) -}}
{{ printf "postgres://%s:%s@%s.%s.svc.%s:%s/%s?sslmode=disable" $username $password $name $namespace $clusterDomain $port $database }}
{{- else -}}
{{ printf "postgres://%s:%s@%s:%s/%s?sslmode=disable" $username $password $name $port $database }}
{{- end -}}
{{- end }}
{{- end -}}
