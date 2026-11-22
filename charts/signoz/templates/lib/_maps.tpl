{{/*
Shared map helpers. Each reads only its arguments (a dict), never .Values, .Release or .Chart.
*/}}

{{/*
signoz.lib.mergedMap: the merge of several maps, such as an object's labels or annotations.
Takes: maps (a list of maps, lowest precedence first; a null or empty entry adds nothing), keep (a
map, optional).
A key in a later map replaces the value an earlier one gives it, whole; a key in keep replaces every
other value, so keep holds what the chart must own whatever the user sets.
Emits: the merged map as YAML, keys sorted, with no leading indentation; include it with nindent.
Nothing at all when the merged map is empty.
*/}}
{{- define "signoz.lib.mergedMap" -}}
{{- $merged := dict -}}
{{- range .maps -}}
{{- range $key, $value := . -}}
{{- $_ := set $merged $key $value -}}
{{- end -}}
{{- end -}}
{{- range $key, $value := .keep -}}
{{- $_ := set $merged $key $value -}}
{{- end -}}
{{- if $merged -}}
{{- toYaml $merged -}}
{{- end -}}
{{- end -}}
