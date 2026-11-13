{{/*
Expand the name of the chart.
*/}}
{{- define "signoz-mcp-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name. Every object the chart renders is
named with it, with no suffix.

fullnameOverride is used as written and is never cut: foundry computes the
Service address from the full string, so a cut name would not match it.
templates/validate.yaml fails rendering when it is longer than 63 characters.

Otherwise the release name is used when it already contains the chart name,
and <release>-<chart name> when it does not. A name built from the release
name is cut to 63 characters, the limit of a DNS label, with a trailing "-"
removed.
*/}}
{{- define "signoz-mcp-server.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart name and version, as used by the helm.sh/chart label.
*/}}
{{- define "signoz-mcp-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "signoz-mcp-server.labels" -}}
{{ include "signoz-mcp-server.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "signoz-mcp-server.chart" . }}
{{- end }}

{{/*
Selector labels. These must never change for an existing release: a
Deployment's selector cannot be edited after creation.
*/}}
{{- define "signoz-mcp-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz-mcp-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
User labels with the chart's own labels left out. Takes a dict:

- "chart": the label block the chart renders in the same mapping, as text,
  for example the output of signoz-mcp-server.labels.
- "user": the user's map of labels.

Returns the user's entries whose keys the chart's block does not set, as
YAML, or nothing when none remain. The chart's labels win, so no key is
rendered twice and the pod template keeps matching the Deployment's selector.
The user's map is not modified.
*/}}
{{- define "signoz-mcp-server.userLabels" -}}
{{- $chartLabels := fromYaml .chart -}}
{{- $labels := dict -}}
{{- range $key, $value := .user -}}
{{- if not (hasKey $chartLabels $key) -}}
{{- $_ := set $labels $key $value -}}
{{- end -}}
{{- end -}}
{{- with $labels -}}
{{- toYaml . -}}
{{- end -}}
{{- end -}}

{{/*
Name of the ServiceAccount the pod runs as. When serviceAccount.create is
true, it is serviceAccount.name, or the fullname when that is empty. When
create is false, it is serviceAccount.name, or "default" when that is empty.
*/}}
{{- define "signoz-mcp-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "signoz-mcp-server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image string: registry/repository:tag. The registry comes from
global.imageRegistry when set, otherwise from image.registry; with neither
set the result is repository:tag. The tag defaults to the chart's appVersion.
*/}}
{{- define "signoz-mcp-server.image" -}}
{{- $registry := default .Values.image.registry .Values.global.imageRegistry -}}
{{- $repository := .Values.image.repository -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag | toString -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end -}}

{{/*
Text of one env value. Takes the value of one env entry.

Returns the text of a string, number or bool, given bare or as the "value" of
a map. Returns an empty string for a valueFrom reference and for anything
else.

A float64 that is a whole number within the 64-bit integer range is printed
as plain digits. Helm reads numbers in a values file as float64, so 4194304
would otherwise print as 4.194304e+06. Any other value uses Helm's default
text form. The whole-number test follows _shims.asintegral in
charts/redpanda/templates/_shims.tpl.
*/}}
{{- define "signoz-mcp-server.envPlainValue" -}}
{{- $value := . -}}
{{- if kindIs "map" $value -}}
{{- if hasKey $value "value" -}}
{{- $value = index $value "value" -}}
{{- end -}}
{{- end -}}
{{- if kindIs "float64" $value -}}
{{- if and (eq (floor $value) $value) (ge $value -9.223372036854775808e18) (lt $value 9.223372036854775808e18) -}}
{{- int64 $value -}}
{{- else -}}
{{- toString $value -}}
{{- end -}}
{{- else if has (kindOf $value) (list "string" "bool" "int" "int64") -}}
{{- toString $value -}}
{{- end -}}
{{- end -}}

{{/*
The container's env list. Takes the root context.

- Names are used as written: no case change and no prefix.
- The chart supplies TRANSPORT_MODE=http and MCP_SERVER_PORT=8000. A user
  entry with the same name replaces the chart's value. A null user entry is
  skipped before the merge, so it produces no variable and cannot remove one
  of the chart's values.
- A string, number or bool, bare or as a map with exactly "value", renders as
  a quoted string. A map with exactly "valueFrom" whose content is a map is
  passed through unchanged. Anything else stops rendering with a message
  naming the entry.
- Entries are sorted by name, so a $(VAR) reference resolves only to a name
  that sorts earlier. One map is built, so no name appears twice.
- .Values is not modified.

templates/validate.yaml has already checked that env is a map.
*/}}
{{- define "signoz-mcp-server.env" -}}
{{- $scalarKinds := list "string" "bool" "int" "int64" "float64" -}}
{{- $entries := dict "TRANSPORT_MODE" "http" "MCP_SERVER_PORT" "8000" -}}
{{- range $name, $value := .Values.env -}}
{{- if not (kindIs "invalid" $value) -}}
{{- $_ := set $entries $name $value -}}
{{- end -}}
{{- end -}}
{{- range $index, $name := keys $entries | sortAlpha -}}
{{- $value := index $entries $name -}}
{{- if $index }}{{ "\n" }}{{ end -}}
{{- if has (kindOf $value) $scalarKinds -}}
- name: {{ $name | quote }}
  value: {{ include "signoz-mcp-server.envPlainValue" $value | quote }}
{{- else if kindIs "map" $value -}}
{{- if ne (len $value) 1 -}}
{{- fail (printf "env.%s: expected a string, number, bool, or a map with exactly one of value or valueFrom" $name) -}}
{{- else if hasKey $value "value" -}}
{{- if not (has (kindOf (index $value "value")) $scalarKinds) -}}
{{- fail (printf "env.%s.value: expected a string, number or bool" $name) -}}
{{- end -}}
- name: {{ $name | quote }}
  value: {{ include "signoz-mcp-server.envPlainValue" $value | quote }}
{{- else if hasKey $value "valueFrom" -}}
{{- if not (kindIs "map" (index $value "valueFrom")) -}}
{{- fail (printf "env.%s.valueFrom: expected a map" $name) -}}
{{- end -}}
- name: {{ $name | quote }}
  valueFrom:
    {{- toYaml (index $value "valueFrom") | nindent 4 }}
{{- else -}}
{{- fail (printf "env.%s: expected a string, number, bool, or a map with exactly one of value or valueFrom" $name) -}}
{{- end -}}
{{- else -}}
{{- fail (printf "env.%s: expected a string, number, bool, or a map with exactly one of value or valueFrom" $name) -}}
{{- end -}}
{{- end -}}
{{- end -}}
