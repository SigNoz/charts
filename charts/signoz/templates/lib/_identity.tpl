{{/*
Shared identity helpers: names, labels and the ServiceAccount name.
Each reads only its arguments (a dict), never .Values, .Release or .Chart.
*/}}

{{/*
signoz.lib.fullname: the fully qualified name of a component.
Takes: release (the release name), name (the component's default name), nameOverride,
fullnameOverride.
Emits: fullnameOverride if set; else, with n = nameOverride if set else name, the release name
when it contains n, else <release>-<n>. Truncated at 63 chars (the DNS naming limit), with a
trailing "-" trimmed.
*/}}
{{- define "signoz.lib.fullname" -}}
{{- if .fullnameOverride -}}
{{- .fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .name .nameOverride -}}
{{- if contains $name .release -}}
{{- .release | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .release $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
signoz.lib.labels: the common labels of a component's objects.
Takes: chart (the helm.sh/chart value), selectorLabels (rendered label lines), version (string,
may be empty), managedBy (string).
Emits: helm.sh/chart, the selector labels verbatim, app.kubernetes.io/version (quoted) only when
version is set, and app.kubernetes.io/managed-by.
*/}}
{{- define "signoz.lib.labels" -}}
helm.sh/chart: {{ .chart }}
{{ .selectorLabels }}
{{- if .version }}
app.kubernetes.io/version: {{ .version | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .managedBy }}
{{- end -}}

{{/*
signoz.lib.serviceAccountName: the ServiceAccount a component's pods run as.
Takes: serviceAccount (the block with create and name), fullname (the component's fullname).
Emits: serviceAccount.name if set; else fullname when serviceAccount.create is true; else "default".
*/}}
{{- define "signoz.lib.serviceAccountName" -}}
{{- if .serviceAccount.name -}}
{{- .serviceAccount.name -}}
{{- else if .serviceAccount.create -}}
{{- .fullname -}}
{{- else -}}
default
{{- end -}}
{{- end -}}
