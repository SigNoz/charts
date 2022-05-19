{{/*
Common ClickHouse ENV variables and helpers used by SigNoz
*/}}
{{- define "snippet.clickhouse-env" }}
{{- if .Values.clickhouse.enabled -}}
- name: CLICKHOUSE_HOST
  value: {{ include "clickhouse.servicename" . }}
- name: CLICKHOUSE_PORT
  value: {{ include "clickhouse.tcpPort" . | quote }}
- name: CLICKHOUSE_HTTP_PORT
  value: {{ include "clickhouse.httpPort" . | quote }}
- name: CLICKHOUSE_CLUSTER
  value: {{ .Values.clickhouse.cluster | quote }}
- name: CLICKHOUSE_DATABASE
  value: {{ default "signoz_metrics" .Values.clickhouse.database | quote }}
- name: CLICKHOUSE_TRACE_DATABASE
  value: {{ default "signoz_traces" .Values.clickhouse.traceDatabase | quote }}
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
- name: CLICKHOUSE_PORT
  value: {{ default 9000 .Values.externalClickhouse.tcpPort | quote }}
- name: CLICKHOUSE_HTTP_PORT
  value: {{ default 8123 .Values.externalClickhouse.httpPort | quote }}
- name: CLICKHOUSE_CLUSTER
  value: {{ required "externalClickhouse.cluster is required if not clickhouse.enabled" .Values.externalClickhouse.cluster | quote }}
- name: CLICKHOUSE_DATABASE
  value: {{ default "signoz_metrics" .Values.externalClickhouse.database | quote }}
- name: CLICKHOUSE_TRACE_DATABASE
  value: {{ default "signoz_traces" .Values.externalClickhouse.traceDatabase | quote }}
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
- name: CLICKHOUSE_VERIFY
  value: {{ .Values.externalClickhouse.verify | quote }}
{{- end }}
{{- end }}


{*
   ------ CLICKHOUSE ------
*}

{{/*
Set Clickhouse tcp port
*/}}
{{- define "clickhouse.tcpPort" -}}
{{- default 9000 .Values.clickhouse.service.tcpPort -}}
{{- end -}}

{{/*
Set Clickhouse http port
*/}}
{{- define "clickhouse.httpPort" -}}
{{- default 8123 .Values.clickhouse.service.httpPort -}}
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

{{/*
Return the external ClickHouse password
*/}}
{{- define "clickhouse.externalPasswordKey" -}}
{{- if .Values.externalClickhouse.user }}
  {{- required "externalClickhouse.password is required if using external clickhouse" .Values.externalClickhouse.password -}}
{{- end -}}
{{- end -}}

{{/*
Return the ClickHouse http URL
*/}}
{{- define "clickhouse.httpUrl" -}}
{{- if .Values.clickhouse.enabled -}}
  {{- include "clickhouse.servicename" . }}:{{ include "clickhouse.httpPort" . }}
{{- else -}}
  {{- required "externalClickhouse.host is required if using external clickhouse" .Values.externalClickhouse.host }}:{{ include "clickhouse.httpPort" . }}
{{- end -}}
{{- end -}}

{{/*
Return the ClickHouse Metrics URL
*/}}
{{- define "clickhouse.metricsUrl" -}}
{{- if .Values.clickhouse.enabled -}}
  {{- include "clickhouse.servicename" . }}:{{ include "clickhouse.tcpPort" . }}?database={{ .Values.clickhouse.database }}&username={{ .Values.clickhouse.user }}&password={{ .Values.clickhouse.password -}}
{{- else -}}
  {{- required "externalClickhouse.host is required if using external clickhouse" .Values.externalClickhouse.host }}:{{ include "clickhouse.tcpPort" . }}?database={{ .Values.externalClickhouse.database }}&username={{ .Values.externalClickhouse.user }}&password={{ include "clickhouse.externalPasswordKey" . -}}
{{- end -}}
{{- end -}}

{{/*
Return the ClickHouse Traces URL
*/}}
{{- define "clickhouse.tracesUrl" -}}
{{- if .Values.clickhouse.enabled -}}
  {{- include "clickhouse.servicename" . }}:{{ include "clickhouse.tcpPort" . }}?database={{ .Values.clickhouse.traceDatabase }}&username={{ .Values.clickhouse.user }}&password={{ .Values.clickhouse.password -}}
{{- else -}}
  {{- required "externalClickhouse.host is required if using external clickhouse" .Values.externalClickhouse.host }}:{{ include "clickhouse.tcpPort" . }}?database={{ .Values.externalClickhouse.traceDatabase }}&username={{ .Values.externalClickhouse.user }}&password={{ include "clickhouse.externalPasswordKey" . -}}
{{- end -}}
{{- end -}}

