{{/*
Common ClickHouse ENV variables and helpers used by SigNoz
*/}}

{{- define "snippet.clickhouse-env" }}
{{- include "snippet.clickhouse-credentials" . }}
{{- if .Values.clickhouse.enabled }}
- name: CLICKHOUSE_DATABASE
  value: {{ default "signoz_metrics" .Values.clickhouse.database | quote }}
- name: CLICKHOUSE_TRACE_DATABASE
  value: {{ default "signoz_traces" .Values.clickhouse.traceDatabase | quote }}
- name: CLICKHOUSE_LOG_DATABASE
  value: {{ default "signoz_logs" .Values.clickhouse.logDatabase | quote }}
- name: CLICKHOUSE_METER_DATABASE
  value: {{ default "signoz_meter" .Values.clickhouse.meterDatabase | quote }}
- name: CLICKHOUSE_VERIFY
  value: {{ .Values.clickhouse.verify | quote }}
{{- else }}
- name: CLICKHOUSE_DATABASE
  value: {{ default "signoz_metrics" .Values.externalClickhouse.database | quote }}
- name: CLICKHOUSE_TRACE_DATABASE
  value: {{ default "signoz_traces" .Values.externalClickhouse.traceDatabase | quote }}
- name: CLICKHOUSE_LOG_DATABASE
  value: {{ default "signoz_logs" .Values.externalClickhouse.logDatabase | quote }}
- name: CLICKHOUSE_METER_DATABASE
  value: {{ default "signoz_meter" .Values.externalClickhouse.meterDatabase | quote }}
- name: CLICKHOUSE_VERIFY
  value: {{ .Values.externalClickhouse.verify | quote }}
{{- end }}
{{- end }}

{{/*
Minimized ClickHouse ENV variables for user credentials
*/}}
{{- define "snippet.clickhouse-credentials" }}
{{ if .Values.clickhouse.enabled -}}
- name: CLICKHOUSE_HOST
  value: {{ include "clickhouse.servicename" . }}
- name: CLICKHOUSE_PORT
  value: {{ include "clickhouse.tcpPort" . | quote }}
- name: CLICKHOUSE_HTTP_PORT
  value: {{ include "clickhouse.httpPort" . | quote }}
- name: CLICKHOUSE_CLUSTER
  value: {{ .Values.clickhouse.cluster | quote }}
- name: CLICKHOUSE_USER
  value: {{ .Values.clickhouse.user | quote }}
- name: CLICKHOUSE_PASSWORD
  value: {{ .Values.clickhouse.password | quote }}
- name: CLICKHOUSE_SECURE
  value: {{ .Values.clickhouse.secure | quote }}
{{- else -}}
- name: CLICKHOUSE_HOST
  value: {{ required "externalClickhouse.host is required if not clickhouse.enabled" .Values.externalClickhouse.host | quote }}
- name: CLICKHOUSE_PORT
  value: {{ default 9000 .Values.externalClickhouse.tcpPort | quote }}
- name: CLICKHOUSE_HTTP_PORT
  value: {{ default 8123 .Values.externalClickhouse.httpPort | quote }}
- name: CLICKHOUSE_CLUSTER
  value: {{ required "externalClickhouse.cluster is required if not clickhouse.enabled" .Values.externalClickhouse.cluster | quote }}
- name: CLICKHOUSE_USER
  value: {{ .Values.externalClickhouse.user | quote }}
{{- if .Values.externalClickhouse.existingSecret }}
- name: CLICKHOUSE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "clickhouse.secretName" . }}
      key: {{ include "clickhouse.secretPasswordKey" . }}
{{- else }}
- name: CLICKHOUSE_PASSWORD
  value: {{ .Values.externalClickhouse.password | quote }}
{{- end }}
- name: CLICKHOUSE_SECURE
  value: {{ .Values.externalClickhouse.secure | quote }}
{{- end }}
{{- end }}

{*
   ------ CLICKHOUSE ------
*}

{{/*
Set Clickhouse tcp port
*/}}
{{- define "clickhouse.tcpPort" -}}
{{- if .Values.clickhouse.enabled }}
{{- default 9000 .Values.clickhouse.service.tcpPort }}
{{- else }}
{{- default 9000 .Values.externalClickhouse.tcpPort }}
{{- end }}
{{- end -}}

{{/*
Set Clickhouse http port
*/}}
{{- define "clickhouse.httpPort" -}}
{{- if .Values.clickhouse.enabled }}
{{- default 8123 .Values.clickhouse.service.httpPort }}
{{- else }}
{{- default 8123 .Values.externalClickhouse.httpPort }}
{{- end }}
{{- end -}}

{{/*
Return true if a secret object for ClickHouse should be created
*/}}
{{- define "clickhouse.createSecret" -}}
{{- if and (not .Values.clickhouse.enabled) (not .Values.externalClickhouse.existingSecret) .Values.externalClickhouse.password }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the ClickHouse secret name
*/}}
{{- define "clickhouse.secretName" -}}
{{- if .Values.externalClickhouse.existingSecret }}
    {{- .Values.externalClickhouse.existingSecret | quote -}}
{{- else -}}
    {{- printf "%s-external" ( include "clickhouse.servicename" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the ClickHouse secret key
*/}}
{{- define "clickhouse.secretPasswordKey" -}}
{{- if .Values.externalClickhouse.existingSecret }}
    {{- required "You need to provide existingSecretPasswordKey when an existingSecret is specified in externalClickhouse" .Values.externalClickhouse.existingSecretPasswordKey | quote }}
{{- else -}}
    {{- printf "clickhouse-password" -}}
{{- end -}}
{{- end -}}

{{/*
Return the external ClickHouse password
*/}}
{{- define "clickhouse.externalPasswordKey" -}}
{{- if .Values.externalClickhouse.password }}
  {{- required "externalClickhouse.password is required if using external clickhouse" .Values.externalClickhouse.password -}}
{{- end -}}
{{- end -}}

{{/*
Return the ClickHouse http URL
*/}}
{{- define "clickhouse.httpUrl" -}}
{{- $httpUrl := "" -}}
{{- $httpPrefix := "" -}}
{{- if .Values.clickhouse.enabled }}
  {{- $httpUrl = printf "%s:%s" (include "clickhouse.servicename" .) (include "clickhouse.httpPort" .) }}
  {{- if .Values.clickhouse.secure }}
    {{- $httpPrefix = "https://" }}
  {{- end }}
{{- else }}
  {{- $httpUrl = printf "%s:%s" (required "externalClickhouse.host is required if using external clickhouse" .Values.externalClickhouse.host) ( include "clickhouse.httpPort" .) }}
  {{- if .Values.externalClickhouse.secure }}
    {{- $httpPrefix = "https://" }}
  {{- end }}
{{- end }}
{{- printf "%s%s" $httpPrefix $httpUrl }}
{{- end -}}

{{/*
Return the ClickHouse Metrics URL
*/}}
{{- define "clickhouse.metricsUrl" -}}
{{- if .Values.clickhouse.enabled -}}
  tcp://{{ .Values.clickhouse.user }}:{{ .Values.clickhouse.password }}@{{ include "clickhouse.servicename" . }}:{{ include "clickhouse.tcpPort" . }}/{{ .Values.clickhouse.database -}}
{{- else -}}
  tcp://{{ .Values.externalClickhouse.user }}:{{ include "clickhouse.externalPasswordKey" . }}@{{- required "externalClickhouse.host is required if using external clickhouse" .Values.externalClickhouse.host }}:{{ include "clickhouse.tcpPort" . }}/{{ .Values.externalClickhouse.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the ClickHouse Traces URL
*/}}
{{- define "clickhouse.tracesUrl" -}}
{{- if .Values.clickhouse.enabled -}}
  tcp://{{ .Values.clickhouse.user }}:{{ .Values.clickhouse.password }}@{{ include "clickhouse.servicename" . }}:{{ include "clickhouse.tcpPort" . }}/{{ .Values.clickhouse.traceDatabase -}}
{{- else -}}
  tcp://{{ .Values.externalClickhouse.user }}:$(CLICKHOUSE_PASSWORD)@{{ required "externalClickhouse.host is required if using external clickhouse" .Values.externalClickhouse.host }}:{{ include "clickhouse.tcpPort" . }}/{{ .Values.externalClickhouse.traceDatabase -}}
{{- end -}}
{{- end -}}

{{- define "clickhouse.clickHouseUrl" -}}
{{- if .Values.clickhouse.enabled -}}
  {{- include "clickhouse.servicename" . }}:{{ include "clickhouse.tcpPort" . }}/?username=$(CLICKHOUSE_USER)&password=$(CLICKHOUSE_PASSWORD)
{{- else -}}
  {{- required "externalClickhouse.host is required if using external clickhouse" .Values.externalClickhouse.host }}:{{ include "clickhouse.tcpPort" . }}/?username=$(CLICKHOUSE_USER)&password=$(CLICKHOUSE_PASSWORD)
{{- end -}}
{{- end -}}


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

{{- define "clickhouse.cluster" -}}
{{- if .Values.clickhouse.enabled -}}
  {{ .Values.clickhouse.cluster }}
{{- else -}}
  {{- required "externalClickhouse.cluster is required if using external clickhouse" .Values.externalClickhouse.cluster }}
{{- end -}}
{{- end -}}

{{/*
   ------ CLICKHOUSE INSTANCE (formerly the clickhouse subchart) ------
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "clickhouse.name" -}}
{{- default "clickhouse" .Values.clickhouse.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "clickhouse.fullname" -}}
{{- if .Values.clickhouse.fullnameOverride -}}
{{- .Values.clickhouse.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "clickhouse" .Values.clickhouse.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "clickhouse.labels" -}}
helm.sh/chart: {{ include "signoz.chart" . }}
{{ include "clickhouse.podLabels" . }}
{{- end -}}

{{/*
Labels on the ClickHouse pod template (CHI podTemplates).
Any change under the StatefulSet's spec.template recreates the ClickHouse pods. `helm.sh/chart`
would carry the signoz chart version, which changes every release, so it stays off the pod template.
The version label follows the image tag, which only changes when the pods roll anyway.
*/}}
{{- define "clickhouse.podLabels" -}}
{{ include "clickhouse.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.clickhouse.image.tag | toString | trunc 63 | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "clickhouse.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clickhouse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ default "clickhouse" .Values.clickhouse.name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "clickhouse.serviceAccountName" -}}
{{- if .Values.clickhouse.serviceAccount.create -}}
    {{ default (include "clickhouse.fullname" .) .Values.clickhouse.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.clickhouse.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Set zookeeper host
*/}}
{{- define "clickhouse.zookeeper.servicename" -}}
{{- if .Values.zookeeper.fullnameOverride -}}
{{- .Values.zookeeper.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.zookeeper.nameOverride -}}
{{- printf "%s-%s" .Release.Name .Values.zookeeper.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "zookeeper" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Set zookeeper port
*/}}
{{- define "clickhouse.zookeeper.port" -}}
{{- default 2181 }}
{{- end }}

{{/*
Return suffix part of the headless service
*/}}
{{- define "clickhouse.zookeeper.headlessSvcSuffix" -}}
{{- $namespace := .Values.zookeeper.namespaceOverride }}
{{- $clusterDomain := default "cluster.local" .Values.global.clusterDomain }}
{{- $name := printf "%s-headless" (include "clickhouse.zookeeper.servicename" .) }}
{{- if and $namespace (ne $namespace .Values.clickhouse.namespace) }}
{{- printf "%s.%s.svc.%s" $name $namespace $clusterDomain }}
{{- else -}}
{{- $name }}
{{- end }}
{{- end }}

{{/*
Return the initContainers image name
*/}}
{{- define "clickhouse.initContainers.init.image" -}}
{{- $registryName := default .Values.clickhouse.initContainers.init.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.clickhouse.initContainers.init.image.repository -}}
{{- $tag := .Values.clickhouse.initContainers.init.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the initContainers image name for UDF
*/}}
{{- define "clickhouse.initContainers.udf.image" -}}
{{- $registryName := default .Values.clickhouse.initContainers.udf.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.clickhouse.initContainers.udf.image.repository -}}
{{- $tag := .Values.clickhouse.initContainers.udf.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper clickhouse image name
*/}}
{{- define "clickhouse.image" -}}
{{- $registryName := default .Values.clickhouse.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.clickhouse.image.repository -}}
{{- $tag := .Values.clickhouse.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper exporter image name
*/}}
{{- define "logs.system.image" -}}
{{- $registryName := default .Values.clickhouse.logs.system.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.clickhouse.logs.system.image.repository -}}
{{- $tag := .Values.clickhouse.logs.system.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return `nodePort: null` if service type is ClusterIP
*/}}
{{- define "service.ifClusterIP" -}}
{{- if (eq . "ClusterIP") -}}
nodePort: null
{{- end -}}
{{- end -}}

{{/*
Return the proper Image Registry Secret Names.
*/}}
{{- define "clickhouse.imagePullSecrets" -}}
{{- if or .Values.global.imagePullSecrets .Values.clickhouse.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.clickhouse.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Return service account annotations of ClickHouse instance.
*/}}
{{- define "clickhouse.serviceAccountAnnotations" -}}
{{- $annotations := dict }}
{{- if .Values.clickhouse.serviceAccount.create }}
{{- $annotations = merge $annotations .Values.clickhouse.serviceAccount.annotations }}
{{- end }}
{{- if and .Values.clickhouse.coldStorage.enabled .Values.clickhouse.coldStorage.role.enabled }}
{{- $annotations = merge $annotations .Values.clickhouse.coldStorage.role.annotations }}
{{- end -}}
annotations:
  {{- toYaml $annotations | nindent 2 }}
{{- end }}

{{/*
Return namespace of clickhouse
*/}}
{{- define "clickhouse.namespace" -}}
{{- default .Release.Namespace .Values.clickhouse.namespace -}}
{{- end -}}

{{/*
Name of the operator Deployment rendered by the altinity-clickhouse-operator subchart.
Mirrors that chart's "altinity-clickhouse-operator.fullname" helper, so the upgrade hook
finds the Deployment under whatever nameOverride/fullnameOverride the user set.
*/}}
{{- define "clickhouse.operatorFullname" -}}
{{- $op := index .Values "altinity-clickhouse-operator" | default dict -}}
{{- if $op.fullnameOverride -}}
{{- $op.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "altinity-clickhouse-operator" $op.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Whether the altinity-clickhouse-operator dependency is installed ("true"/"false").
Mirrors the Chart.yaml condition `altinity-clickhouse-operator.enabled,clickhouse.enabled`:
an explicit `altinity-clickhouse-operator.enabled` wins, otherwise it follows `clickhouse.enabled`.
*/}}
{{- define "clickhouse.operatorEnabled" -}}
{{- $op := index .Values "altinity-clickhouse-operator" | default dict -}}
{{- if hasKey $op "enabled" -}}{{ $op.enabled }}{{- else -}}{{ .Values.clickhouse.enabled }}{{- end -}}
{{- end -}}

{{/*
Image of the operator upgrade hook Job.
*/}}
{{- define "clickhouse.operatorUpgradeHook.image" -}}
{{- $registryName := default .Values.clickhouse.operatorUpgradeHook.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.clickhouse.operatorUpgradeHook.image.repository -}}
{{- $tag := .Values.clickhouse.operatorUpgradeHook.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return list of files and contents.
*/}}
{{- define "clickhouse.files" -}}
{{- range $key,$value := .Values.clickhouse.files }}
{{ $key }}: {{ $value | toYaml }}
{{- end }}
{{- end }}
