{{/*
Return the full name of the PostgreSQL release
*/}}
{{- define "postgres.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "postgres" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Standard labels for postgres resources
*/}}
{{- define "postgres.labels" -}}
app.kubernetes.io/name: {{ include "postgres.name" . }}
helm.sh/chart:  {{ include "signoz.chart" . }}
{{ include "postgres.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (used for StatefulSet selector and Pod template)
*/}}
{{- define "postgres.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ default "signoz-postgres" .Values.postgres.name }}
{{- end }}

{{/*
Base name for the chart
*/}}
{{- define "postgres.name" -}}
{{- default "postgres" .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
ServiceAccount name
*/}}
{{- define "postgres.serviceAccountName" -}}
{{- if .Values.postgres.serviceAccount.create -}}
    {{ default (include "postgres.fullname" .) .Values.postgres.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.postgres.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "postgres.imagePullSecrets" -}}
{{- if or .Values.global.imagePullSecrets .Values.postgres.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.postgres.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}  
{{- end }}
{{/*
Postgres container image
*/}}
{{- define "postgres.image" -}}
{{ printf "%s:%s" .Values.postgres.image.repository .Values.postgres.image.tag }}
{{- end }}

{{/*
Auth secret name
*/}}
{{- define "postgres.authSecretName" -}}
{{ printf "%s-auth" (include "postgres.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- define "postgres.Url" -}}
{{- if .Values.postgres.enabled -}}
    postgres://{{ .Values.postgres.auth.username}}:{{ .Values.postgres.auth.password }}@{{ include "postgres.fullname" .}}:{{ .Values.postgres.service.port}}/{{ .Values.postgres.auth.database }}?sslmode=disable
{{- end }}
{{- end }}
{{/*
Postgres ENV
*/}}
{{- define "postgres.env" -}}
{{- $env := dict -}}
{{- $_ := set $env "POSTGRESQL_PORT_NUMBER" (.Values.postgres.service.port | toString) -}}
{{- $_ := set $env "POSTGRESQL_VOLUME_DIR" .Values.postgres.persistence.mountPath -}}
{{- if .Values.postgres.persistence.mountPath }}
  {{- $_ := set $env "PGDATA" .Values.postgres.persistence.dataDir -}}
{{- end }}

{{- $_ := set $env "POSTGRES_USER" .Values.postgres.auth.username -}}
{{- if .Values.postgres.auth.existingSecret }}
  {{- $secretCfg := default dict .Values.postgres.auth.secretKeys -}}
  {{- $secretKey := default "password" (get $secretCfg "userPasswordKey") -}}
  {{- $_ := set $env "POSTGRES_PASSWORD" (dict "valueFrom" (dict "secretKeyRef" (dict "name" .Values.postgres.auth.existingSecret "key" $secretKey ))) -}}
{{- else }}
  {{- $_ := set $env "POSTGRES_PASSWORD" .Values.postgres.auth.password -}}
{{- end }}
{{- if .Values.postgres.database }}
  {{- $_ := set $env "POSTGRES_DATABASE" .Values.postgres.database -}}
{{- end }}
{{- if .Values.postgres.extraEnvVars }}
  {{- range .Values.postgres.postgres.extraEnvVars }}
    {{- $_ := set $env .name .value -}}
  {{- end }}
{{- end }}


{{- template "postgres.renderEnv" $env -}}
{{- end}}

{{/*
Function to render environment variables 
*/}}
{{- define "postgres.renderEnv" -}}
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

{{- define "postgres.service.ifClusterIP" -}}
{{- if (eq . "ClusterIP") }}
nodePort: null
{{- end }}
{{- end }}
