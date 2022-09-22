{{/*
Expand the name of the chart.
*/}}
{{- define "k8s-infra.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "k8s-infra.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "k8s-infra.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Return namespace of the release
*/}}
{{- define "k8s-infra.namespace" -}}
{{- .Release.Namespace -}}
{{- end -}}

{{/*
Create a default fully qualified app name for the agent.
*/}}
{{- define "otelAgent.fullname" -}}
{{- printf "%s-%s" (include "k8s-infra.fullname" .) .Values.otelAgent.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels for agent.
*/}}
{{- define "otelAgent.labels" -}}
helm.sh/chart: {{ include "k8s-infra.chart" . }}
{{ include "otelAgent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for agent.
*/}}
{{- define "otelAgent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-infra.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ include "otelAgent.name" . }}
{{- end }}

{{/*
Name of the component agent.
*/}}
{{- define "otelAgent.name" -}}
{{ default "otel-agent" .Values.otelAgent.name }}
{{- end }}

{{/*
Create the name of the service account to use for agent.
*/}}
{{- define "otelAgent.serviceAccountName" -}}
{{- if .Values.otelAgent.serviceAccount.create }}
{{- default (include "otelAgent.fullname" .) .Values.otelAgent.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.otelAgent.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper image name of agent.
*/}}
{{- define "otelAgent.image" -}}
{{- $registryName := default .Values.otelAgent.image.registry .Values.global.image.registry -}}
{{- $repositoryName := .Values.otelAgent.image.repository -}}
{{- $tag := default .Chart.AppVersion .Values.otelAgent.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the clusterRole to use for agent.
*/}}
{{- define "otelAgent.clusterRoleName" -}}
{{- if .Values.otelAgent.clusterRole.create }}
{{- $clusterRole := printf "%s-%s" (include "otelAgent.fullname" .) (include "k8s-infra.namespace" .) }}
{{- default $clusterRole .Values.otelAgent.clusterRole.name }}
{{- else }}
{{- default "default" .Values.otelAgent.clusterRole.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the clusterRoleBinding to use for agent.
*/}}
{{- define "otelAgent.clusterRoleBindingName" -}}
{{- if .Values.otelAgent.clusterRole.create }}
{{- $clusterRole := printf "%s-%s" (include "otelAgent.fullname" .) (include "k8s-infra.namespace" .) }}
{{- default $clusterRole .Values.otelAgent.clusterRole.clusterRoleBinding.name }}
{{- else }}
{{- default "default" .Values.otelAgent.clusterRole.clusterRoleBinding.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name for the deployment.
*/}}
{{- define "otelDeployment.fullname" -}}
{{- printf "%s-%s" (include "k8s-infra.fullname" .) .Values.otelDeployment.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels for deployment.
*/}}
{{- define "otelDeployment.labels" -}}
helm.sh/chart: {{ include "k8s-infra.chart" . }}
{{ include "otelDeployment.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for deployment.
*/}}
{{- define "otelDeployment.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-infra.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ include "otelDeployment.name" . }}
{{- end }}

{{/*
Name of the component deployment.
*/}}
{{- define "otelDeployment.name" -}}
{{ default "otel-deployment" .Values.otelDeployment.name }}
{{- end }}

{{/*
Create the name of the service account to use for deployment.
*/}}
{{- define "otelDeployment.serviceAccountName" -}}
{{- if .Values.otelDeployment.serviceAccount.create }}
{{- default (include "otelDeployment.fullname" .) .Values.otelDeployment.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.otelDeployment.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper image name of deployment.
*/}}
{{- define "otelDeployment.image" -}}
{{- $registryName := default .Values.otelDeployment.image.registry .Values.global.image.registry }}
{{- $repositoryName := .Values.otelDeployment.image.repository }}
{{- $tag := default .Chart.AppVersion .Values.otelDeployment.image.tag | toString }}
{{- if $registryName }}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag }}
{{- else }}
    {{- printf "%s:%s" $repositoryName $tag }}
{{- end }}
{{- end }}

{{/*
Create the name of the clusterRole to use for deployment.
*/}}
{{- define "otelDeployment.clusterRoleName" -}}
{{- if .Values.otelDeployment.clusterRole.create }}
{{- $clusterRole := printf "%s-%s" (include "otelDeployment.fullname" .) (include "k8s-infra.namespace" .) }}
{{- default $clusterRole .Values.otelDeployment.clusterRole.name }}
{{- else }}
{{- default "default" .Values.otelDeployment.clusterRole.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the clusterRoleBinding to use for deployment.
*/}}
{{- define "otelDeployment.clusterRoleBindingName" -}}
{{- if .Values.otelDeployment.clusterRole.create }}
{{- $clusterRole := printf "%s-%s" (include "otelDeployment.fullname" .) (include "k8s-infra.namespace" .) }}
{{- default $clusterRole .Values.otelDeployment.clusterRole.clusterRoleBinding.name }}
{{- else }}
{{- default "default" .Values.otelDeployment.clusterRole.clusterRoleBinding.name }}
{{- end }}
{{- end }}

{{/*
Return endpoint of OtelCollector.
*/}}
{{- define "otel.endpoint" -}}
{{- default "my-release-signoz-otel-collector.platform.svc.cluster.local:4317" .Values.otelCollectorEndpoint }}
{{- end }}

{{/*
Whether OtelCollector endpoint is insecure.
*/}}
{{- define "otel.insecure" -}}
{{- default "true" (.Values.otelInsecure | quote) }}
{{- end }}

{{/*
Return API key of SigNoz SAAS
*/}}
{{- define "otel.signozApiKey" -}}
{{- default "" .Values.signozApiKey }}
{{- end }}

{{/*
Return structured list of ports config for Service.
*/}}
{{- define "otel.portsConfig" -}}
{{- $serviceType := deepCopy .service.type }}
{{- $ports := deepCopy .ports }}
{{- range $key, $port := $ports }}
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
{{- end }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "ingress.supportsPathType" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "ingress.isStable" -}}
  {{- eq (include "ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}
