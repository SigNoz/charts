{{/*
Telemetry Store Migrator helpers.
*/}}

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
Create the name of the service account to use for telemetryStoreMigrator
*/}}
{{- define "telemetryStoreMigrator.serviceAccountName" -}}
{{- if .Values.telemetryStoreMigrator.serviceAccount.create -}}
    {{ default (include "telemetryStoreMigrator.fullname" .) .Values.telemetryStoreMigrator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.telemetryStoreMigrator.serviceAccount.name }}
{{- end -}}
{{- end -}}
