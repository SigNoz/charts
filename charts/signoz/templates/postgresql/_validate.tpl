{{/*
postgresql.validate: the Postgres values rules.
Emits: one line per rule the values break, holding that rule's message; nothing when every rule
holds. validate.yaml gathers these lines with every other component's and fails once.
*/}}
{{- define "postgresql.validate" -}}
{{- /*
persistence.existingClaim goes through tpl with the signoz chart's context, so a template written for the
old postgresql subchart would read the signoz chart's `.Chart` and root `.Values`.
*/ -}}
{{- $claim := .Values.postgresql.persistence.existingClaim }}
{{- if and .Values.postgresql.enabled (kindIs "string" $claim) $claim }}
{{- if contains ".Chart." $claim }}
{{ "`postgresql.persistence.existingClaim` is rendered by the signoz chart, where `.Chart` is the signoz chart: write the claim name out, or build it from `.Release.Name`." }}
{{- end }}
{{- if contains ".Values." ($claim | replace ".Values.global." "" | replace ".Values.postgresql." "") }}
{{ "`postgresql.persistence.existingClaim` is rendered by the signoz chart, whose values hold the Postgres keys under `postgresql`: write `.Values.postgresql.<key>`." }}
{{- end }}
{{- end }}
{{- end -}}
