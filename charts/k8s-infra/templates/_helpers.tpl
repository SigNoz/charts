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
{{- default .Release.Namespace .Values.namespace }}
{{- end -}}

{{/*
Common labels for the chart.
*/}}
{{- define "k8s-infra.labels" -}}
helm.sh/chart: {{ include "k8s-infra.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

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
{{ include "k8s-infra.labels" . }}
{{ include "otelAgent.selectorLabels" . }}
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
{{- $registryName := default .Values.otelAgent.image.registry .Values.global.imageRegistry -}}
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
Return the proper Image Registry Secret Names for agent.
*/}}
{{- define "otelAgent.imagePullSecrets" -}}
{{- if or .Values.global.imagePullSecrets .Values.otelAgent.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.otelAgent.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
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
{{ include "k8s-infra.labels" . }}
{{ include "otelDeployment.selectorLabels" . }}
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
{{- $registryName := default .Values.otelDeployment.image.registry .Values.global.imageRegistry }}
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
Return the proper Image Registry Secret Names for deployment.
*/}}
{{- define "otelDeployment.imagePullSecrets" -}}
{{- if or .Values.global.imagePullSecrets .Values.otelDeployment.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.otelDeployment.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a fully qualified app name for signoz.
Assuming defaults for fullnameOverride and nameOverride.
*/}}
{{- define "signoz.qualifiedname" -}}
{{- $name := "signoz" }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a fully qualified app name for otel-collector.
*/}}
{{- define "otel.qualifiedname" -}}
{{- printf "%s-%s" (include "signoz.qualifiedname" .) "otel-collector" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Return the service name of OtelCollector.
Assuming defaults for overrides and otel component name.
*/}}
{{- define "otel.servicename" -}}
{{- if and .Values.namespace (ne .Values.namespace .Release.Namespace) }}
{{- $clusterDomain := default "cluster.local" .Values.global.clusterDomain }}
{{- printf "%s.%s.svc.%s" (include "otel.qualifiedname" .) .Release.Namespace $clusterDomain }}
{{- else }}
{{- include "otel.qualifiedname" . }}
{{- end }}
{{- end }}

{{/*
Return endpoint of OtelCollector.
*/}}
{{- define "otel.endpoint" -}}
{{- if .Values.otelCollectorEndpoint }}
{{- .Values.otelCollectorEndpoint }}
{{- else if not .Chart.IsRoot }}
{{- printf "%s:%s" (include "otel.servicename" .) "4317" }}
{{- end }}
{{- end }}

{{/*
Whether OtelCollector endpoint is insecure.
*/}}
{{- define "otel.insecure" -}}
{{- default "true" (.Values.otelInsecure | quote) }}
{{- end }}

{{/*
Whether to skip verifying the TLS certificates.
*/}}
{{- define "otel.insecureSkipVerify" -}}
{{- default "true" (.Values.insecureSkipVerify | quote) }}
{{- end }}

{{/*
Return path of the TLS secrets
*/}}
{{- define "otel.secretsPath" -}}
{{- default "/secrets" .Values.otelTlsSecrets.path }}
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

{{/*
Return name of Otel TLS secret name.
*/}}
{{- define "k8s-infra.otelTlsSecretName" -}}
{{- if .Values.otelTlsSecrets.existingSecretName }}
{{- .Values.otelTlsSecrets.existingSecretName }}
{{- else }}
{{- include "k8s-infra.fullname" . }}-tls-secrets
{{- end }}
{{- end -}}

{{/*
Common K8s environment variables used by OtelAgent and OtelDeployment.
*/}}
{{- define "snippet.k8s-env" }}
- name: K8S_NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
- name: K8S_POD_IP
  valueFrom:
    fieldRef:
      apiVersion: v1
      fieldPath: status.podIP
- name: K8S_HOST_IP
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
- name: K8S_POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: K8S_POD_UID
  valueFrom:
    fieldRef:
      fieldPath: metadata.uid
- name: K8S_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
{{- end }}

{{/*
OTLP exporter environment variables used by OtelAgent and OtelDeployment.
*/}}
{{- define "snippet.otlp-env" }}
- name: OTEL_EXPORTER_OTLP_ENDPOINT
  value: {{ include "otel.endpoint" . }}
- name: OTEL_EXPORTER_OTLP_INSECURE
  value: {{ include "otel.insecure" . }}
{{- if or .Values.apiKeyExistingSecretName .Values.signozApiKey }}
- name: SIGNOZ_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "otel.apiKey.secretName" . }}
      key: {{ include "otel.apiKey.secretKey" . }}
{{- end }}
- name: OTEL_EXPORTER_OTLP_INSECURE_SKIP_VERIFY
  value: {{ include "otel.insecureSkipVerify" . }}
- name: OTEL_SECRETS_PATH
  value: {{ include "otel.secretsPath" . }}
{{- end }}

{{/*
Secret name to be used for SigNoz API key.
*/}}
{{- define "otel.apiKey.secretName" }}
{{- if .Values.apiKeyExistingSecretName }}
{{- .Values.apiKeyExistingSecretName }}
{{- else }}
{{- include "k8s-infra.fullname" . }}-apikey-secret
{{- end }}
{{- end }}

{{/*
Secret key to be used for SigNoz API key.
*/}}
{{- define "otel.apiKey.secretKey" }}
{{- if .Values.apiKeyExistingSecretName }}
{{- required "You need to provide apiKeyExistingSecretKey when an apiKeyExistingSecretName is specified" .Values.apiKeyExistingSecretKey }}
{{- else }}
{{- print "signoz-apikey" }}
{{- end }}
{{- end }}
