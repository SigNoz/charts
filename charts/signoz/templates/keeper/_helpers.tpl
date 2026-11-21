{{/*
ClickHouse Keeper helpers: the Keeper installation's names, labels, image and client host.
*/}}

{{/*
Expand the name of the component.
*/}}
{{- define "keeper.name" -}}
{{- default .Values.keeper.name .Values.keeper.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified name: the ClickHouseKeeperInstallation's name.
Fails the render past 34 characters, since `chk-<name>-deploy-confd-<cluster>-<shard>-<replica>` must fit 63.
*/}}
{{- define "keeper.fullname" -}}
{{- $name := include "signoz.lib.fullname" (dict "release" .Release.Name "name" "keeper" "nameOverride" .Values.keeper.nameOverride "fullnameOverride" .Values.keeper.fullnameOverride) -}}
{{- if gt (len $name) 34 -}}
{{- fail (printf "keeper name %q is %d characters; the operator derives names from it that must fit 63, so it may be at most 34: shorten the release name or set `keeper.fullnameOverride`" $name (len $name)) -}}
{{- end -}}
{{- $name -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "keeper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "keeper.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: keeper
{{- end -}}

{{/*
Labels on the Keeper pod template: the selector labels only, since a pod template change restarts
Keeper, which drops every ClickHouse session.
*/}}
{{- define "keeper.podLabels" -}}
{{ include "keeper.selectorLabels" . }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "keeper.labels" -}}
{{- include "signoz.lib.labels" (dict "chart" (include "signoz.chart" .) "selectorLabels" (include "keeper.selectorLabels" .) "version" (.Values.keeper.image.tag | toString | trunc 63) "managedBy" .Release.Service) -}}
{{- end -}}

{{/*
The Keeper container image.
*/}}
{{- define "keeper.image" -}}
{{- include "signoz.lib.image" (dict "registry" .Values.global.imageRegistry "image" .Values.keeper.image "name" "keeper.image") -}}
{{- end -}}

{{/*
The client Service the operator creates for the Keeper installation, port 2181.
*/}}
{{- define "keeper.clientHost" -}}
{{- printf "keeper-%s" (include "keeper.fullname" .) -}}
{{- end -}}
