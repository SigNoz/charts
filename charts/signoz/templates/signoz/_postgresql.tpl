{{/*
The SigNoz server's variables for the postgresql subchart; the DSN refers to the variables before it.
*/}}
{{- define "signoz.postgresqlEnv" }}
{{- $postgresql := .Values.postgresql }}
{{- $host := include "signoz.lib.fullname" (dict "release" .Release.Name "name" "postgresql" "nameOverride" $postgresql.nameOverride "fullnameOverride" $postgresql.fullnameOverride) }}
{{- if and $postgresql.namespace (ne $postgresql.namespace .Release.Namespace) }}
{{- $host = printf "%s.%s.svc.%s" $host $postgresql.namespace (include "signoz.clusterDomain" .) }}
{{- end }}
- name: POSTGRES_USER
  value: {{ $postgresql.auth.username | quote }}
- name: POSTGRES_PORT
  value: {{ $postgresql.service.port | quote }}
- name: POSTGRES_PASSWORD
{{- if $postgresql.auth.existingSecret }}
  {{- include "signoz.lib.secretKeyRef" (dict "name" $postgresql.auth.existingSecret "key" (default "password" (get (default dict $postgresql.auth.secretKeys) "userPasswordKey"))) | nindent 2 }}
{{- else }}
  value: {{ $postgresql.auth.password | quote }}
{{- end }}
{{- with $postgresql.auth.database }}
- name: POSTGRES_DB
  value: {{ . | quote }}
{{- end }}
- name: SIGNOZ_SQLSTORE_PROVIDER
  value: postgres
- name: SIGNOZ_SQLSTORE_POSTGRES_DSN
  value: {{ printf "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@%s:$(POSTGRES_PORT)/$(POSTGRES_DB)?sslmode=disable" $host | quote }}
{{- end }}
