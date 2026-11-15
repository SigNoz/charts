{{/*
Shared image helpers. Each reads only its arguments (a dict), never .Values, .Release or .Chart.
*/}}

{{/*
signoz.lib.image: the image reference of a container.
Takes: registry (string, the global registry, may be empty), image (a block with registry,
repository, tag), defaultTag (string, optional), name (string, the block's values path, for
error messages).
Emits: <registry>/<repository>:<tag>, where the registry is `registry` if set, else image.registry;
<repository>:<tag> when both are empty. The tag is image.tag when set, else defaultTag when set,
else image.tag as toString renders it.
*/}}
{{- define "signoz.lib.image" -}}
{{- $image := required (printf "signoz.lib.image: %s is not set" .name) .image -}}
{{- $registryName := default $image.registry .registry -}}
{{- $repositoryName := $image.repository -}}
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
