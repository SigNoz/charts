{{/*
Telemetry store migrator helpers: the Job's name, labels and ServiceAccount, and the migration
container its four steps share.
*/}}

{{/*
telemetryStoreMigrator.fullname: the stem of the Job's name and the default name of its ServiceAccount.
It is telemetryStoreMigrator.name as written, never prefixed by the release name or changed by the
name overrides: cloud identity bindings and `kubectl logs job/<name>-<revision>` refer to it.
*/}}
{{- define "telemetryStoreMigrator.fullname" -}}
{{- default "signoz-telemetrystore-migrator" .Values.telemetryStoreMigrator.name -}}
{{- end -}}

{{/*
telemetryStoreMigrator.selectorLabels: the labels of the Job and its pods.
An empty telemetryStoreMigrator.name gives the component label `telemetrystore-migrator`, not the
fullname's default, as released.
*/}}
{{- define "telemetryStoreMigrator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ default "telemetrystore-migrator" .Values.telemetryStoreMigrator.name }}
{{- end -}}

{{/*
telemetryStoreMigrator.labels: the labels of the ServiceAccount.
*/}}
{{- define "telemetryStoreMigrator.labels" -}}
{{- include "signoz.lib.labels" (dict "chart" (include "signoz.chart" .) "selectorLabels" (include "telemetryStoreMigrator.selectorLabels" .) "version" .Chart.AppVersion "managedBy" .Release.Service) -}}
{{- end -}}

{{/*
telemetryStoreMigrator.serviceAccountName: the ServiceAccount the Job runs as.
*/}}
{{- define "telemetryStoreMigrator.serviceAccountName" -}}
{{- include "signoz.lib.serviceAccountName" (dict "serviceAccount" .Values.telemetryStoreMigrator.serviceAccount "fullname" (include "telemetryStoreMigrator.fullname" .)) -}}
{{- end -}}
