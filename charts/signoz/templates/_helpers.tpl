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
Create the name of the service account to use
*/}}
{{- define "signoz.serviceAccountName" -}}
{{- if .Values.signoz.serviceAccount.create -}}
    {{ default (include "signoz.fullname" .) .Values.signoz.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.signoz.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the proper signoz image name
*/}}
{{- define "signoz.image" -}}
{{- $registryName := default .Values.signoz.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.signoz.image.repository -}}
{{- $tag := default .Chart.AppVersion .Values.signoz.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Set signoz port
*/}}
{{- define "signoz.port" -}}
{{- default 8080 .Values.signoz.service.port  -}}
{{- end -}}

{{/*
Set signoz internal port
*/}}
{{- define "signoz.internalPort" -}}
{{- default 8085 .Values.signoz.service.internalPort  -}}
{{- end -}}

{{/*
Set signoz url
*/}}
{{- define "signoz.url" -}}
{{ include "signoz.fullname" . }}:{{ include "signoz.port" . }}
{{- end -}}

{{/*
Set signoz internal url
*/}}
{{- define "signoz.internalUrl" -}}
{{ include "signoz.fullname" . }}:{{ include "signoz.internalPort" . }}
{{- end -}}


{{/*
Create a default fully qualified app name for telemetrystore migrator.
*/}}
{{- define "telemetryStoreMigrator.fullname" -}}
{{- default "signoz-telemetrystore-migrator" .Values.telemetryStoreMigrator.name -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "telemetryStoreMigrator.labels" -}}
helm.sh/chart: {{ include "signoz.chart" . }}
{{ include "telemetryStoreMigrator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common Selector labels of telemetrystore migrator
*/}}
{{- define "telemetryStoreMigrator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ default "telemetrystore-migrator" .Values.telemetryStoreMigrator.name }}
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
app.kubernetes.io/component: {{ default "otel-collector" .Values.otelCollector.name }}
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
{{- $registryName := default .Values.otelCollector.initContainers.init.image.registry .Values.global.imageRegistry -}}
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
{{- $registryName := default .Values.otelCollector.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.otelCollector.image.repository -}}
{{- $tag := .Values.otelCollector.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the clusterRole to use
*/}}
{{- define "otelCollector.clusterRoleName" -}}
{{- if .Values.otelCollector.clusterRole.create }}
{{- $clusterRole := printf "%s-%s" (include "otelCollector.fullname" .) (include "signoz.namespace" .) -}}
{{- default $clusterRole .Values.otelCollector.clusterRole.name }}
{{- else }}
{{- default "default" .Values.otelCollector.clusterRole.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the clusterRoleBinding to use
*/}}
{{- define "otelCollector.clusterRoleBindingName" -}}
{{- if .Values.otelCollector.clusterRole.create }}
{{- $clusterRole := printf "%s-%s" (include "otelCollector.fullname" .) (include "signoz.namespace" .) -}}
{{- default $clusterRole .Values.otelCollector.clusterRole.clusterRoleBinding.name }}
{{- else }}
{{- default "default" .Values.otelCollector.clusterRole.clusterRoleBinding.name }}
{{- end }}
{{- end }}


{{/*
Create the name of the service account to use for telemetryStoreMigrator
*/}}
{{- define "telemetryStoreMigrator.serviceAccountName" -}}
{{- if .Values.telemetryStoreMigrator.serviceAccount.create -}}
    {{ default (include "telemetryStoreMigrator.fullname" .) .Values.telemetryStoreMigrator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.telemetryStoreMigrator.serviceAccount.name }}
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
{{- $name = .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- $name = printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- $namespace := .Values.clickhouse.namespace -}}
{{- $clusterDomain := default "cluster.local" .Values.global.clusterDomain -}}
{{- if and $namespace (ne $namespace .Release.Namespace) -}}
{{ printf "%s.%s.svc.%s" $name $namespace $clusterDomain }}
{{- else -}}
{{ $name }}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Return true if external PostgreSQL is in use
*/}}
{{- define "postgresql.external" -}}
{{- if and (not .Values.postgresql.enabled) .Values.externalPostgresql.host -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object for external PostgreSQL should be created
*/}}
{{- define "postgresql.createSecret" -}}
{{- if and (not .Values.postgresql.enabled) (not .Values.externalPostgresql.existingSecret) .Values.externalPostgresql.password -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the external PostgreSQL secret name
*/}}
{{- define "postgresql.secretName" -}}
{{- if .Values.externalPostgresql.existingSecret -}}
    {{- .Values.externalPostgresql.existingSecret -}}
{{- else -}}
    {{- printf "%s-postgresql-external" .Release.Name -}}
{{- end -}}
{{- end -}}

{{/*
Return the external PostgreSQL secret password key
*/}}
{{- define "postgresql.secretPasswordKey" -}}
{{- if .Values.externalPostgresql.existingSecret -}}
    {{- required "You need to provide existingSecretPasswordKey when an existingSecret is specified in externalPostgresql" .Values.externalPostgresql.existingSecretPasswordKey -}}
{{- else -}}
    {{- printf "postgresql-password" -}}
{{- end -}}
{{- end -}}

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
{{- else if (include "postgresql.external" .) -}}
{{- $username := "$(POSTGRES_USER)" -}}
{{- $password := "$(POSTGRES_PASSWORD)" -}}
{{- $database := "$(POSTGRES_DB)" -}}
{{- $port := "$(POSTGRES_PORT)" -}}
{{- $host := required "externalPostgresql.host is required if using external PostgreSQL" .Values.externalPostgresql.host -}}
{{- $sslmode := default "disable" .Values.externalPostgresql.sslmode -}}
{{ printf "postgres://%s:%s@%s:%s/%s?sslmode=%s" $username $password $host $port $database $sslmode }}
{{- end -}}
{{- end -}}


{{/*
Return `nodePort: null` if service type is ClusterIP
*/}}
{{- define "signoz.service.ifClusterIP" -}}
{{- if (eq . "ClusterIP") }}
nodePort: null
{{- end }}
{{- end }}

{{/*
Return structured list of ports config.
*/}}
{{- define "otelCollector.portsConfig" -}}
{{- $serviceType := deepCopy .service.type -}}
{{- $ports := deepCopy .ports -}}
{{- range $key, $port := $ports -}}
{{- if $port.enabled }}
- name: {{ $key }}
  port: {{ $port.servicePort }}
  targetPort: {{ $key }}
  protocol: {{ $port.protocol }}
  {{- if (eq $serviceType "ClusterIP") }}
  nodePort: null
  {{- else if (eq $serviceType "NodePort") }}
  nodePort: {{ $port.nodePort }}
  {{- end }}
{{- end -}}
{{- end -}}
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
Return the proper Image Registry Secret Names.
*/}}
{{- define "signoz.imagePullSecrets" -}}
{{- if or .Values.global.imagePullSecrets .Values.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}


{{/* 
Create Env
*/}}
{{- define "signoz.env" -}}

{{/*
====== Default ENV ======
*/}}
{{- $defaultEnv := dict
    "signoz_telemetrystore_clickhouse_dsn"     (printf "tcp://%s" (include "clickhouse.clickHouseUrl" .))
    "signoz_telemetrystore_clickhouse_cluster" (include "clickhouse.cluster" .)
}}

{{/*
SQL STORE POSTGRES ENV
*/}}
{{- $sqlStorePostgresEnv := dict -}}
{{- if .Values.postgresql.enabled }}
  {{- $_ := set $sqlStorePostgresEnv "postgres_port" .Values.postgresql.service.port }}
  {{- $_ := set $sqlStorePostgresEnv "postgres_user" .Values.postgresql.auth.username }}
  {{- if .Values.postgresql.auth.existingSecret }}
    {{- $secretCfg := default dict .Values.postgresql.auth.secretKeys }}
    {{- $secretKey := default "password" (get $secretCfg "userPasswordKey") }}
    {{- $_ := set $sqlStorePostgresEnv "postgres_password" (dict "valueFrom" (dict "secretKeyRef" (dict "name" .Values.postgresql.auth.existingSecret "key" $secretKey ))) }}
  {{- else }}
    {{- $_ := set $sqlStorePostgresEnv "postgres_password" .Values.postgresql.auth.password }}
  {{- end }}
  {{- if .Values.postgresql.auth.database }}
    {{- $_ := set $sqlStorePostgresEnv "postgres_db" .Values.postgresql.auth.database }}
  {{- end }}
{{- else if (include "postgresql.external" .) }}
  {{- $_ := set $sqlStorePostgresEnv "postgres_port" .Values.externalPostgresql.port }}
  {{- $_ := set $sqlStorePostgresEnv "postgres_user" .Values.externalPostgresql.user }}
  {{- if .Values.externalPostgresql.existingSecret }}
    {{- $_ := set $sqlStorePostgresEnv "postgres_password" (dict "valueFrom" (dict "secretKeyRef" (dict "name" .Values.externalPostgresql.existingSecret "key" (default "postgresql-password" .Values.externalPostgresql.existingSecretPasswordKey) ))) }}
  {{- else }}
    {{- $_ := set $sqlStorePostgresEnv "postgres_password" (dict "valueFrom" (dict "secretKeyRef" (dict "name" (include "postgresql.secretName" .) "key" (include "postgresql.secretPasswordKey" .) ))) }}
  {{- end }}
  {{- $_ := set $sqlStorePostgresEnv "postgres_db" .Values.externalPostgresql.database }}
{{- end }}
{{/*
SQL STORE ENV
Keep it seprate from sqlStorePostgresEnv to maintain the order of env variables
*/}}
{{- $sqlStoreEnv := dict -}}
{{- if or .Values.postgresql.enabled (include "postgresql.external" .) -}}
{{ $sqlStoreEnv = merge $sqlStoreEnv ( dict "signoz_sqlstore_provider" "postgres")}}
{{ $sqlStoreEnv = merge $sqlStoreEnv ( dict "signoz_sqlstore_postgres_dsn" (include "postgresql.service" .))}}
{{- end }}


{{/*
===== USER ENV VARIABLES =====
*/}}
{{- $userEnv := .Values.signoz.env | default dict -}}


{{/*
====== MERGE AND RENDER ENV BLOCK ======
*/}}

{{- $completeEnv := mergeOverwrite $defaultEnv $userEnv $sqlStorePostgresEnv -}}
{{- template "signoz.renderEnv" $completeEnv -}}
{{/* Render the sqlstoreEnv (provider, dsn) seprately to maintain the order of the env variables */}}
{{- template "signoz.renderEnv" $sqlStoreEnv -}}
{{- end -}}

{{/*
Function to render environment variables 
*/}}
{{- define "signoz.renderEnv" -}}
{{- $dict := . -}}
{{- $processedKeys := dict -}}
{{- range keys . | sortAlpha | reverse }}
{{- $val := pluck . $dict | first -}}
{{- $key := upper . -}}
{{- if not (hasKey $processedKeys $key) }}
{{- $processedKeys = merge $processedKeys (dict $key true) -}}
{{- $valueType := printf "%T" $val -}}
{{- if eq $valueType "map[string]interface {}" }}
- name: {{ $key }}
{{ toYaml $val | indent 2 -}}
{{- else if eq $valueType "string" }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- else }}
- name: {{ $key }}
  value: {{ $val | quote}}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}
