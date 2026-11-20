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

{{/*
telemetryStoreMigrator.migration: one migration container of the Job.
Takes: name (the container name), args (the migrate command's arguments), context (the root context).
Every migration runs the collector's image, so it applies the schema that collector version expects.
Emits: the container as one list item, with no leading indentation; include it with nindent.
*/}}
{{- define "telemetryStoreMigrator.migration" -}}
{{- $values := .context.Values -}}
- name: {{ .name }}
  image: {{ include "signoz.lib.image" (dict "registry" $values.global.imageRegistry "image" $values.otelCollector.image "name" "otelCollector.image") }}
  imagePullPolicy: {{ $values.otelCollector.image.pullPolicy }}
  {{- with include "signoz.lib.env" (dict "chart" (list (include "snippet.telemetryStoreMigrator-env" .context | fromYamlArray)) "user" $values.telemetryStoreMigrator.env) }}
  env:
    {{- . | trim | nindent 4 }}
  {{- end }}
  {{- with $values.telemetryStoreMigrator.envFrom }}
  envFrom:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  args:
    {{- toYaml .args | nindent 4 }}
  {{- with $values.telemetryStoreMigrator.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}
