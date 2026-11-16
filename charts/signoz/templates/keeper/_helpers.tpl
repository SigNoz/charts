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
*/}}
{{- define "keeper.fullname" -}}
{{- include "signoz.lib.fullname" (dict "release" .Release.Name "name" "clickhouse-keeper" "nameOverride" .Values.keeper.nameOverride "fullnameOverride" .Values.keeper.fullnameOverride) -}}
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
Labels on the Keeper pod template. `helm.sh/chart` stays off it: a pod template change restarts
Keeper, which drops every ClickHouse session.
*/}}
{{- define "keeper.podLabels" -}}
{{ include "keeper.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.keeper.image.tag | toString | trunc 63 | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
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
