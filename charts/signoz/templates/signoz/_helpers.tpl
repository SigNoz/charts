{{/*
The SigNoz server's telemetry store variables, built on the variables of clickhouse.env.
*/}}
{{- define "signoz.telemetryStoreEnv" }}
- name: SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN
  value: {{ include "clickhouse.dsn" . | quote }}
- name: SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_CLUSTER
  value: $(CLICKHOUSE_CLUSTER)
{{- end }}
