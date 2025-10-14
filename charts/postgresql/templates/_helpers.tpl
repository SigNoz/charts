{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "postgresql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for SigNoz.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "postgresql.fullname" -}}
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
Return namespace of the signoz release
*/}}
{{- define "signoz.namespace" -}}
{{- .Release.Namespace -}}
{{- end -}}

{{/*
Standard labels for postgres resources
*/}}
{{- define "postgresql.labels" -}}
app.kubernetes.io/name: {{ include "postgresql.name" . }}
helm.sh/chart:  {{ include "postgresql.chart" . }}
{{ include "postgresql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (used for StatefulSet selector and Pod template)
*/}}
{{- define "postgresql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgresql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ default "signoz-postgres" .Values.name }}
{{- end }}

{{/*
Base name for the chart
*/}}
{{- define "postgresql.name" -}}
{{- default "postgres" .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
ServiceAccount name
*/}}
{{- define "postgresql.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "postgresql.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "postgresql.imagePullSecrets" -}}
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
Return the proper signoz image name
*/}}
{{- define "postgresql.image" -}}
{{- $registryName := default .Values.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Auth secret name
*/}}
{{- define "postgresql.authSecretName" -}}
{{ printf "%s-auth" (include "postgresql.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Postgres ENV
*/}}
{{- define "postgresql.env" -}}
{{- $env := dict -}}
{{- $_ := set $env "POSTGRESQL_PORT_NUMBER" (.Values.service.port | toString) -}}
{{- $_ := set $env "POSTGRESQL_VOLUME_DIR" .Values.persistence.mountPath -}}
{{- $_ := set $env "PGDATA" .Values.persistence.dataDir -}}

{{- $_ := set $env "POSTGRES_USER" .Values.auth.username -}}
{{- if .Values.auth.existingSecret }}
  {{- $secretCfg := default dict .Values.auth.secretKeys -}}
  {{- $secretKey := default "password" (get $secretCfg "userPasswordKey") -}}
  {{- $_ := set $env "POSTGRES_PASSWORD" (dict "valueFrom" (dict "secretKeyRef" (dict "name" .Values.auth.existingSecret "key" $secretKey ))) -}}
{{- else }}
  {{- $_ := set $env "POSTGRES_PASSWORD" .Values.auth.password -}}
{{- end }}
{{- if .Values.auth.database }}
  {{- $_ := set $env "POSTGRES_DB" .Values.auth.database -}}
{{- end }}
{{- if .Values.extraEnv }}
  {{- range .Values.extraEnv }}
    {{- $_ := set $env .name .value -}}
  {{- end }}
{{- end }}


{{- template "postgresql.renderEnv" $env -}}
{{- end}}

{{/*
Function to render environment variables 
*/}}
{{- define "postgresql.renderEnv" -}}
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

{{- define "postgresql.service.ifClusterIP" -}}
{{- if (eq . "ClusterIP") }}
nodePort: null
{{- end }}
{{- end }}
