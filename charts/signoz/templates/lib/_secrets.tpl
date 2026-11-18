{{/*
Shared Secret helpers. Each reads only its arguments (a dict), never .Values, .Release or .Chart.
Values convention for a credential: `<block>.<field>` is a plain value rendered only into a
chart-created Secret `<fullname>-<suffix>`, under the key named after the field.
`<block>.existingSecret` names a Secret the user created and suppresses the chart's;
`<block>.existingSecret<Field>Key` names the key inside it, default the field name.
Consumers read the value through `secretKeyRef` only; URLs are built from `$(ENV)` references.
*/}}

{{/*
signoz.lib.secretName: the name of the Secret a credential is read from.
Takes: existing (string, the user's Secret, may be empty), fullname (the component's fullname),
suffix (string).
Emits: existing if set; else <fullname>-<suffix>, truncated at 63 chars (the DNS naming limit),
with a trailing "-" trimmed.
*/}}
{{- define "signoz.lib.secretName" -}}
{{- if .existing -}}
{{- .existing -}}
{{- else -}}
{{- printf "%s-%s" .fullname .suffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
signoz.lib.secretKey: the key of a credential inside its Secret.
Takes: existing (string, the key inside the user's Secret, may be empty), default (string, the
field name).
Emits: existing if set; else default.
*/}}
{{- define "signoz.lib.secretKey" -}}
{{- if .existing -}}
{{- .existing -}}
{{- else -}}
{{- .default -}}
{{- end -}}
{{- end -}}

{{/*
signoz.lib.createSecret: whether the chart creates the Secret.
Takes: existing (string, the user's Secret, may be empty).
Emits: "true" when existing is empty; else nothing, so the result works in an `if`.
*/}}
{{- define "signoz.lib.createSecret" -}}
{{- if not .existing -}}
true
{{- end -}}
{{- end -}}

{{/*
signoz.lib.secretKeyRef: the valueFrom that reads a credential from its Secret.
Takes: name (the Secret's name), key (the key inside it).
Emits: `valueFrom:` with `secretKeyRef.name` and `secretKeyRef.key`, with no leading indentation;
include it with nindent.
*/}}
{{- define "signoz.lib.secretKeyRef" -}}
valueFrom:
  secretKeyRef:
    name: {{ .name }}
    key: {{ .key }}
{{- end -}}
