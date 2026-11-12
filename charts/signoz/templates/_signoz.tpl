{{/*
SigNoz helpers.
*/}}

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
Return `nodePort: null` if service type is ClusterIP
*/}}
{{- define "signoz.service.ifClusterIP" -}}
{{- if (eq . "ClusterIP") }}
nodePort: null
{{- end }}
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
{{- end }}
{{/*
SQL STORE ENV
Keep it seprate from sqlStorePostgresEnv to maintain the order of env variables
*/}}
{{- $sqlStoreEnv := dict -}}
{{- if .Values.postgresql.enabled -}}
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
