{{/*
Shared image helpers. Each reads only its arguments (a dict), never .Values, .Release or .Chart.
*/}}

{{/*
signoz.lib.image: the image reference of a container.
Takes: registry (string, the global registry, may be empty), image (a block with repository, tag
and an optional registry), defaultTag (string, optional), name (string, the block's values path,
for error messages).
The repository may start with a registry: a first path segment, before a `/`, that contains `.`
or `:` or equals `localhost` (the container image reference rule), as in registry.k8s.io/kubectl.
Emits: <registry>/<path>:<tag>, or <path>:<tag> when there is no registry. The registry is
`registry` (the global one) if set, else image.registry if set, else the registry inside the
repository if any, else none. <path> is the repository after its registry. Only the global
registry strips a registry from the repository; image.registry is prefixed to the repository as
given. The tag is image.tag when set, else defaultTag when set, else image.tag as toString renders it.
*/}}
{{- define "signoz.lib.image" -}}
{{- $image := required (printf "signoz.lib.image: %s is not set" .name) .image -}}
{{- $registryName := default $image.registry .registry -}}
{{- $repositoryName := $image.repository -}}
{{- if .registry -}}
{{- $segments := splitList "/" ($repositoryName | toString) -}}
{{- if gt (len $segments) 1 -}}
{{- $first := first $segments -}}
{{- if or (contains "." $first) (contains ":" $first) (eq $first "localhost") -}}
{{- $repositoryName = rest $segments | join "/" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $tag := $image.tag | toString -}}
{{- if and (not $image.tag) .defaultTag -}}
{{- $tag = .defaultTag | toString -}}
{{- end -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
signoz.lib.imagePullSecrets: the imagePullSecrets field of a pod spec or ServiceAccount.
Takes: lists (a list of lists of secret names).
Emits: `imagePullSecrets:` followed by `  - name: <name>` for every entry of every list, in order;
nothing at all when every list is empty.
*/}}
{{- define "signoz.lib.imagePullSecrets" -}}
{{- $names := list -}}
{{- range .lists -}}
{{- range . -}}
{{- $names = append $names . -}}
{{- end -}}
{{- end -}}
{{- if $names -}}
imagePullSecrets:
{{- range $names }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}
