{{/*
Shared environment helpers. Each reads only its arguments (a dict), never .Values, .Release or .Chart.
*/}}

{{/*
signoz.lib.env: the env entries of one container.
Takes: chart (a list of layers the chart owns, lowest precedence first) and user (one layer, optional).
A layer is a list of EnvVar objects, taken in the order written, or a map of NAME to a scalar or to
the rest of an EnvVar ({valueFrom: ...}), names uppercased and taken alphabetically.
- A later layer naming a variable of an earlier one changes its value where it stands.
- New entries of a user LIST are rendered exactly as written and never move.
- Every other variable (the chart's, and the keys of a user map) is placed after whatever its
  value references through $(NAME).
Fails on a name set twice in one list, an entry without a name, and a circle of references.
Emits: one `- name: <NAME>` entry per variable with the rest of its EnvVar, each starting on a new
line, so trim the result before nindent; nothing at all when no layer sets a variable, so the
caller emits `env:` only for a non-empty result.
*/}}
{{- define "signoz.lib.env" -}}
{{- $env := dict -}}
{{- $seq := list -}}
{{- $pinned := dict -}}
{{- $layers := list -}}
{{- range .chart }}{{ $layers = append $layers (dict "layer" . "user" false) }}{{ end -}}
{{- if .user }}{{ $layers = append $layers (dict "layer" .user "user" true) }}{{ end -}}
{{- range $l := $layers -}}
  {{- $layer := $l.layer -}}
  {{- if kindIs "slice" $layer -}}
    {{- $seen := dict -}}
    {{- range $item := $layer -}}
      {{- $name := get $item "name" | default "" -}}
      {{- if not $name }}{{ fail "env: an entry has no name" }}{{ end -}}
      {{- if hasKey $seen $name }}{{ fail (printf "env: %q is set twice in one list" $name) }}{{ end -}}
      {{- $_ := set $seen $name true -}}
      {{- if not (hasKey $env $name) -}}
        {{- $seq = append $seq $name -}}
        {{- if $l.user }}{{ $_ := set $pinned $name true }}{{ end -}}
      {{- end -}}
      {{- $_ := set $env $name (omit $item "name") -}}
    {{- end -}}
  {{- else if kindIs "map" $layer -}}
    {{- range $key := keys $layer | sortAlpha -}}
      {{- $val := get $layer $key -}}
      {{- $name := upper $key -}}
      {{- if not (kindIs "invalid" $val) -}}
        {{- if not (hasKey $env $name) }}{{ $seq = append $seq $name }}{{ end -}}
        {{- if kindIs "map" $val -}}
          {{- $_ := set $env $name $val -}}
        {{- else if kindIs "float64" $val -}}
          {{- $_ := set $env $name (dict "value" (ternary (printf "%d" (int64 $val)) (toString $val) (eq (floor $val) $val))) -}}
        {{- else -}}
          {{- $_ := set $env $name (dict "value" (toString $val)) -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $deps := dict -}}
{{- range $name, $entry := $env -}}
  {{- $refs := list -}}
  {{- range regexFindAll "\\$\\(([^)]+)\\)" (replace "$$" "" (toString (get $entry "value" | default ""))) -1 -}}
    {{- $ref := . | trimPrefix "$(" | trimSuffix ")" -}}
    {{- if and (hasKey $env $ref) (ne $ref $name) }}{{ $refs = append $refs $ref }}{{ end -}}
  {{- end -}}
  {{- $_ := set $deps $name $refs -}}
{{- end -}}
{{- $done := dict -}}
{{- $order := list -}}
{{- range until (len $seq) -}}
  {{- if lt (len $order) (len $seq) -}}
    {{- range $name := $seq -}}
      {{- if not (hasKey $done $name) -}}
        {{- $ready := true -}}
        {{- if not (hasKey $pinned $name) -}}
          {{- range get $deps $name }}{{ if not (hasKey $done .) }}{{ $ready = false }}{{ end }}{{ end -}}
        {{- end -}}
        {{- if $ready }}{{ $order = append $order $name }}{{ $_ := set $done $name true }}{{ end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- if lt (len $order) (len $seq) -}}
  {{- $stuck := list -}}
  {{- range $seq }}{{ if not (hasKey $done .) }}{{ $stuck = append $stuck . }}{{ end }}{{ end -}}
  {{- fail (printf "env: these variables reference each other in a circle: %s" (join ", " $stuck)) -}}
{{- end -}}
{{- range $name := $order }}
- name: {{ $name }}
  {{- toYaml (get $env $name) | nindent 2 }}
{{- end -}}
{{- end -}}
