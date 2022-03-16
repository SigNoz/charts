{{/* Common ClickHouse ENV variables and helpers used by SigNoz */}}
{{- define "snippet.clickhouse-env" }}
{{- if .Values.clickhouse.enabled -}}
- name: CLICKHOUSE_HOST
  value: {{ include "clickhouse.servicename" . }}
- name: CLICKHOUSE_CLUSTER
  value: {{ .Values.clickhouse.cluster | quote }}
- name: CLICKHOUSE_DATABASE
  value: {{ .Values.clickhouse.database | quote }}
- name: CLICKHOUSE_USER
  value: {{ .Values.clickhouse.user | quote }}
- name: CLICKHOUSE_PASSWORD
  value: {{ .Values.clickhouse.password | quote }}
- name: CLICKHOUSE_SECURE
  value: {{ .Values.clickhouse.secure | quote }}
- name: CLICKHOUSE_VERIFY
  value: {{ .Values.clickhouse.verify | quote }}
{{- else -}}
- name: CLICKHOUSE_HOST
  value: {{ required "externalClickhouse.host is required if not clickhouse.enabled" .Values.externalClickhouse.host | quote }}
- name: CLICKHOUSE_CLUSTER
  value: {{ required "externalClickhouse.cluster is required if not clickhouse.enabled" .Values.externalClickhouse.cluster | quote }}
- name: CLICKHOUSE_DATABASE
  value: {{ .Values.externalClickhouse.database | quote }}
- name: CLICKHOUSE_USER
  value: {{ required "externalClickhouse.user is required if not clickhouse.enabled" .Values.externalClickhouse.user | quote }}
{{- if .Values.externalClickhouse.existingSecret }}
- name: CLICKHOUSE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "clickhouse.secretName" . }}
      key: {{ include "clickhouse.secretPasswordKey" . }}
{{- else }}
- name: CLICKHOUSE_PASSWORD
  value: {{ required "externalClickhouse.password or externalClickhouse.existingSecret is required if using external clickhouse" .Values.externalClickhouse.password | quote }}
{{- end }}
- name: CLICKHOUSE_SECURE
  value: {{ .Values.externalClickhouse.secure | quote }}
- name: CLICKHOUSE_VERIFY
  value: {{ .Values.externalClickhouse.verify | quote }}
{{- end }}
{{- end }}


{*
   ------ CLICKHOUSE ------
*}

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
{{- if .Values.externalClickhouse.user }}
  {{- required "externalClickhouse.password is required if using external clickhouse" .Values.externalClickhouse.password -}}
{{- end -}}
{{- end -}}

{{/*
Return the ClickHouse tcp URL
*/}}
{{- define "clickhouse.url" -}}
{{- if .Values.clickhouse.enabled -}}
  {{- include "clickhouse.servicename" . }}:{{ include "clickhouse.tcpPort" . }}?username={{ .Values.clickhouse.user }}&password={{ .Values.clickhouse.password -}}
{{- else -}}
  {{- .Values.externalClickhouse.host }}:{{ include "clickhouse.tcpPort" . }}?username={{ .Values.externalClickhouse.user }}&password={{ include "clickhouse.externalPasswordKey" . -}}
{{- end -}}
{{- end -}}

{{/*
Return the ClickHouse http URL
*/}}
{{- define "clickhouse.httpUrl" -}}
{{- if .Values.clickhouse.enabled -}}
  {{- include "clickhouse.servicename" . }}:{{ include "clickhouse.httpPort" . }}
{{- else -}}
  {{- .Values.externalClickhouse.host }}:{{ include "clickhouse.httpPort" . }}
{{- end -}}
{{- end -}}

{{/*
Return the ClickHouse Metrics URL
*/}}
{{- define "clickhouse.metricsUrl" -}}
{{- if .Values.clickhouse.enabled -}}
  {{- include "clickhouse.servicename" . }}:{{ include "clickhouse.tcpPort" . }}?database={{ .Values.clickhouse.database }}&username={{ .Values.clickhouse.user }}&password={{ .Values.clickhouse.password -}}
{{- else -}}
  {{- .Values.externalClickhouse.host }}:{{ include "clickhouse.tcpPort" . }}?database={{ .Values.externalClickhouse.database }}&username={{ .Values.externalClickhouse.user }}&password={{ include "clickhouse.externalPasswordKey" . -}}
{{- end -}}
{{- end -}}
