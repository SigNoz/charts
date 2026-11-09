{{/*
OTel Collector helpers.
*/}}

{{/*
Create a default fully qualified app name for otelCollector.
*/}}
{{- define "otelCollector.fullname" -}}
{{- printf "%s-%s" (include "signoz.fullname" .) .Values.otelCollector.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "otelCollector.labels" -}}
helm.sh/chart: {{ include "signoz.chart" . }}
{{ include "otelCollector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "otelCollector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ default "otel-collector" .Values.otelCollector.name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "otelCollector.serviceAccountName" -}}
{{- if .Values.otelCollector.serviceAccount.create -}}
    {{ default (include "otelCollector.fullname" .) .Values.otelCollector.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.otelCollector.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the initContainers image name
*/}}
{{- define "otelCollector.initContainers.init.image" -}}
{{- $registryName := default .Values.otelCollector.initContainers.init.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.otelCollector.initContainers.init.image.repository -}}
{{- $tag := .Values.otelCollector.initContainers.init.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper otelCollector image name
*/}}
{{- define "otelCollector.image" -}}
{{- $registryName := default .Values.otelCollector.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.otelCollector.image.repository -}}
{{- $tag := .Values.otelCollector.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the clusterRole to use
*/}}
{{- define "otelCollector.clusterRoleName" -}}
{{- if .Values.otelCollector.clusterRole.create }}
{{- $clusterRole := printf "%s-%s" (include "otelCollector.fullname" .) (include "signoz.namespace" .) -}}
{{- default $clusterRole .Values.otelCollector.clusterRole.name }}
{{- else }}
{{- default "default" .Values.otelCollector.clusterRole.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the clusterRoleBinding to use
*/}}
{{- define "otelCollector.clusterRoleBindingName" -}}
{{- if .Values.otelCollector.clusterRole.create }}
{{- $clusterRole := printf "%s-%s" (include "otelCollector.fullname" .) (include "signoz.namespace" .) -}}
{{- default $clusterRole .Values.otelCollector.clusterRole.clusterRoleBinding.name }}
{{- else }}
{{- default "default" .Values.otelCollector.clusterRole.clusterRoleBinding.name }}
{{- end }}
{{- end }}

{{/*
Return structured list of ports config.
*/}}
{{- define "otelCollector.portsConfig" -}}
{{- $serviceType := deepCopy .service.type -}}
{{- $ports := deepCopy .ports -}}
{{- range $key, $port := $ports -}}
{{- if $port.enabled }}
- name: {{ $key }}
  port: {{ $port.servicePort }}
  targetPort: {{ $key }}
  protocol: {{ $port.protocol }}
  {{- if (eq $serviceType "ClusterIP") }}
  nodePort: null
  {{- else if (eq $serviceType "NodePort") }}
  nodePort: {{ $port.nodePort }}
  {{- end }}
{{- end -}}
{{- end -}}
{{- end -}}
