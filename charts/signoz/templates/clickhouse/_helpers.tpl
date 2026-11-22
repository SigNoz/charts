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
Fails the render past 34 characters, since `chi-<name>-deploy-confd-<cluster>-<shard>-<replica>` must fit 63.
*/}}
{{- define "clickhouse.fullname" -}}
{{- $name := include "signoz.lib.fullname" (dict "release" .Release.Name "name" "clickhouse" "nameOverride" .Values.clickhouse.nameOverride "fullnameOverride" .Values.clickhouse.fullnameOverride) -}}
{{- if and .Values.clickhouse.enabled (gt (len $name) 34) -}}
{{- fail (printf "clickhouse name %q is %d characters; the operator derives names from it that must fit 63, so it may be at most 34: shorten the release name or set `clickhouse.fullnameOverride`" $name (len $name)) -}}
{{- end -}}
{{- $name -}}
{{- end -}}

{{/*
Return the service name of Clickhouse: the fullname, with the namespace and cluster domain
appended when ClickHouse runs in a namespace other than the release's.
*/}}
{{- define "clickhouse.servicename" -}}
{{- $name := include "clickhouse.fullname" . -}}
{{- $namespace := .Values.clickhouse.namespace -}}
{{- $clusterDomain := include "signoz.clusterDomain" . -}}
{{- if and $namespace (ne $namespace .Release.Namespace) -}}
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
Labels on the ClickHouse pod template: the selector labels only, since a pod template change
recreates the ClickHouse pods.
*/}}
{{- define "clickhouse.podLabels" -}}
{{ include "clickhouse.selectorLabels" . }}
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
Return true if the chart creates the ClickHouse password Secret.
*/}}
{{- define "clickhouse.createSecret" -}}
{{- $values := .Values.externalClickhouse -}}
{{- if .Values.clickhouse.enabled -}}
{{- $values = .Values.clickhouse -}}
{{- end -}}
{{- include "signoz.lib.createSecret" (dict "existing" $values.existingSecret) -}}
{{- end -}}

{{/*
Return the name of the Secret holding the ClickHouse password.
*/}}
{{- define "clickhouse.secretName" -}}
{{- $values := .Values.externalClickhouse -}}
{{- if .Values.clickhouse.enabled -}}
{{- $values = .Values.clickhouse -}}
{{- end -}}
{{- include "signoz.lib.secretName" (dict "existing" $values.existingSecret "fullname" (include "clickhouse.fullname" .) "suffix" "credentials") -}}
{{- end -}}

{{/*
Return the key of the ClickHouse password inside its Secret. existingSecretPasswordKey counts only
with existingSecret, since the chart's own Secret always stores it under `password`.
*/}}
{{- define "clickhouse.secretPasswordKey" -}}
{{- $values := .Values.externalClickhouse -}}
{{- if .Values.clickhouse.enabled -}}
{{- $values = .Values.clickhouse -}}
{{- end -}}
{{- include "signoz.lib.secretKey" (dict "existing" (and $values.existingSecret $values.existingSecretPasswordKey) "default" "password") -}}
{{- end -}}

{{/*
Return the key of the SHA-256 hex of the bundled ClickHouse password inside its Secret, or empty when the ClickHouseInstallation reads the plain password.
*/}}
{{- define "clickhouse.secretPasswordSha256Key" -}}
{{- if .Values.clickhouse.existingSecret -}}
{{- .Values.clickhouse.existingSecretPasswordSha256Key -}}
{{- else -}}
password_sha256_hex
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
{{- $clusterDomain := include "signoz.clusterDomain" . }}
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
Connection variables for every container that talks to ClickHouse. Include them first in the container's env, since
the variables after them refer to them.
*/}}
{{- define "clickhouse.env" }}
{{- $values := .Values.externalClickhouse }}
{{- $host := "" }}
{{- $port := .Values.externalClickhouse.tcpPort }}
{{- if .Values.clickhouse.enabled }}
{{- $values = .Values.clickhouse }}
{{- $host = include "clickhouse.servicename" . }}
{{- $port = .Values.clickhouse.service.tcpPort }}
{{- else }}
{{- $host = required "externalClickhouse.host is required if not clickhouse.enabled" $values.host }}
{{- $_ := required "externalClickhouse.cluster is required if not clickhouse.enabled" $values.cluster }}
{{- end }}
- name: CLICKHOUSE_HOST
  value: {{ $host | quote }}
- name: CLICKHOUSE_PORT
  value: {{ default 9000 $port | quote }}
- name: CLICKHOUSE_CLUSTER
  value: {{ $values.cluster | quote }}
- name: CLICKHOUSE_USER
  value: {{ $values.user | quote }}
- name: CLICKHOUSE_PASSWORD
  {{- include "signoz.lib.secretKeyRef" (dict "name" (include "clickhouse.secretName" .) "key" (include "clickhouse.secretPasswordKey" .)) | nindent 2 }}
- name: CLICKHOUSE_SECURE
  value: {{ $values.secure | quote }}
- name: CLICKHOUSE_VERIFY
  value: {{ $values.verify | quote }}
{{- end }}

{{/*
Names of the four databases the collector writes to.
*/}}
{{- define "clickhouse.databasesEnv" }}
{{- $values := .Values.externalClickhouse }}
{{- if .Values.clickhouse.enabled }}
{{- $values = .Values.clickhouse }}
{{- end }}
- name: CLICKHOUSE_DATABASE
  value: {{ default "signoz_metrics" $values.database | quote }}
- name: CLICKHOUSE_TRACE_DATABASE
  value: {{ default "signoz_traces" $values.traceDatabase | quote }}
- name: CLICKHOUSE_LOG_DATABASE
  value: {{ default "signoz_logs" $values.logDatabase | quote }}
- name: CLICKHOUSE_METER_DATABASE
  value: {{ default "signoz_meter" $values.meterDatabase | quote }}
{{- end }}

{{/*
ClickHouse DSN for SigNoz and the migrator, built from the variables of clickhouse.env. For an external ClickHouse it
ends in `?secure=true` when `externalClickhouse.secure` is on, plus `&skip_verify=true` when `externalClickhouse.verify`
is off. The credentials go in the userinfo, since a query parameter would turn a `+` in the password into a space.
*/}}
{{- define "clickhouse.dsn" -}}
{{- $values := .Values.externalClickhouse -}}
tcp://$(CLICKHOUSE_USER):$(CLICKHOUSE_PASSWORD)@$(CLICKHOUSE_HOST):$(CLICKHOUSE_PORT)
{{- if and (not .Values.clickhouse.enabled) (eq (toString $values.secure) "true") }}?secure=true{{ if ne (toString $values.verify) "true" }}&skip_verify=true{{ end }}{{ end }}
{{- end -}}

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
