{{/*
ClickHouse helpers: the ClickHouse installation's names, labels and ServiceAccount, the connection
settings the other components use (in-chart or external ClickHouse), the coordination hosts, the
connection env, and the altinity-clickhouse-operator dependency.
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
{{- include "signoz.lib.fullname" (dict "release" .Release.Name "name" "clickhouse" "nameOverride" .Values.clickhouse.nameOverride "fullnameOverride" .Values.clickhouse.fullnameOverride) -}}
{{- end -}}

{{/*
Return the service name of Clickhouse: the fullname, with the namespace and cluster domain
appended when ClickHouse runs in a namespace other than the release's. A fullnameOverride is
used as it is, without that suffix.
*/}}
{{- define "clickhouse.servicename" -}}
{{- $name := include "clickhouse.fullname" . -}}
{{- $namespace := .Values.clickhouse.namespace -}}
{{- $clusterDomain := default "cluster.local" .Values.global.clusterDomain -}}
{{- if and (not .Values.clickhouse.fullnameOverride) $namespace (ne $namespace .Release.Namespace) -}}
{{ printf "%s.%s.svc.%s" $name $namespace $clusterDomain }}
{{- else -}}
{{ $name }}
{{- end -}}
{{- end }}

{{/*
Return namespace of clickhouse
*/}}
{{- define "clickhouse.namespace" -}}
{{- default .Release.Namespace .Values.clickhouse.namespace -}}
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
Common labels
*/}}
{{- define "clickhouse.labels" -}}
{{- include "signoz.lib.labels" (dict "chart" (include "signoz.chart" .) "selectorLabels" (include "clickhouse.selectorLabels" .) "version" (.Values.clickhouse.image.tag | toString | trunc 63) "managedBy" .Release.Service) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "clickhouse.serviceAccountName" -}}
{{- include "signoz.lib.serviceAccountName" (dict "serviceAccount" .Values.clickhouse.serviceAccount "fullname" (include "clickhouse.fullname" .)) -}}
{{- end -}}

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

{{- define "clickhouse.clickHouseUrl" -}}
{{- if .Values.clickhouse.enabled -}}
  {{- include "clickhouse.servicename" . }}:{{ include "clickhouse.tcpPort" . }}/?username=$(CLICKHOUSE_USER)&password=$(CLICKHOUSE_PASSWORD)
{{- else -}}
  {{- required "externalClickhouse.host is required if using external clickhouse" .Values.externalClickhouse.host }}:{{ include "clickhouse.tcpPort" . }}/?username=$(CLICKHOUSE_USER)&password=$(CLICKHOUSE_PASSWORD)
{{- end -}}
{{- end -}}

{{- define "clickhouse.cluster" -}}
{{- if .Values.clickhouse.enabled -}}
  {{ .Values.clickhouse.cluster }}
{{- else -}}
  {{- required "externalClickhouse.cluster is required if using external clickhouse" .Values.externalClickhouse.cluster }}
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
The coordination (ZooKeeper) nodes of the ClickHouseInstallation: clickhouse.externalZookeeper.servers
when set, else one node per bundled ZooKeeper replica on its headless Service. A YAML list with
no leading newline; include it with nindent.
*/}}
{{- define "clickhouse.coordinationHosts" -}}
{{- if .Values.clickhouse.externalZookeeper -}}
  {{- toYaml .Values.clickhouse.externalZookeeper.servers -}}
{{- else -}}
  {{- $replicaCount := default 1 (.Values.zookeeper.replicaCount | int) -}}
  {{- $svcName := (include "clickhouse.zookeeper.servicename" .) -}}
  {{- $headlessSuffix := (include "clickhouse.zookeeper.headlessSvcSuffix" .) -}}
  {{- range $replicaIndex := until $replicaCount -}}
  {{- /* a newline between nodes, none before the first */ -}}
  {{- if $replicaIndex }}
{{ end -}}
- host: {{ printf "%s-%s.%s" $svcName ($replicaIndex | toString) $headlessSuffix }}
  port: {{ include "clickhouse.zookeeper.port" . }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Common ClickHouse ENV variables and helpers used by SigNoz
*/}}
{{- define "clickhouse.env" }}
{{- include "clickhouse.credentialsEnv" . }}
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
{{- define "clickhouse.credentialsEnv" }}
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

{{/*
Return list of files and contents.
*/}}
{{- define "clickhouse.files" -}}
{{- range $key,$value := .Values.clickhouse.files }}
{{ $key }}: {{ $value | toYaml }}
{{- end }}
{{- end }}

{{/*
Name of the operator Deployment rendered by the altinity-clickhouse-operator subchart.
Mirrors that chart's "altinity-clickhouse-operator.fullname" helper, so the upgrade hook
finds the Deployment under whatever nameOverride/fullnameOverride the user set.
*/}}
{{- define "clickhouse.operatorFullname" -}}
{{- $op := index .Values "altinity-clickhouse-operator" | default dict -}}
{{- include "signoz.lib.fullname" (dict "release" .Release.Name "name" "altinity-clickhouse-operator" "nameOverride" $op.nameOverride "fullnameOverride" $op.fullnameOverride) -}}
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
