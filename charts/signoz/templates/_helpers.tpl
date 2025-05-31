{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "signoz.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for SigNoz.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "signoz.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "signoz.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return namespace of the signoz release
*/}}
{{- define "signoz.namespace" -}}
{{- .Release.Namespace -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "signoz.labels" -}}
helm.sh/chart: {{ include "signoz.chart" . }}
{{ include "signoz.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "signoz.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ default "signoz" .Values.signoz.name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "signoz.serviceAccountName" -}}
{{- if .Values.signoz.serviceAccount.create -}}
    {{ default (include "signoz.fullname" .) .Values.signoz.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.signoz.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the initContainers image name
*/}}
{{- define "signoz.initContainers.init.image" -}}
{{- $registryName := default .Values.signoz.initContainers.init.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.signoz.initContainers.init.image.repository -}}
{{- $tag := .Values.signoz.initContainers.init.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the initContainers image name for migration
*/}}
{{- define "signoz.initContainers.migration.image" -}}
{{- $registryName := default .Values.signoz.initContainers.migration.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.signoz.initContainers.migration.image.repository -}}
{{- $tag := .Values.signoz.initContainers.migration.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper signoz image name
*/}}
{{- define "signoz.image" -}}
{{- $registryName := default .Values.signoz.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.signoz.image.repository -}}
{{- $tag := default .Chart.AppVersion .Values.signoz.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Set signoz port
*/}}
{{- define "signoz.port" -}}
{{- default 8080 .Values.signoz.service.port  -}}
{{- end -}}

{{/*
Set signoz internal port
*/}}
{{- define "signoz.internalPort" -}}
{{- default 8085 .Values.signoz.service.internalPort  -}}
{{- end -}}

{{/*
Set signoz url
*/}}
{{- define "signoz.url" -}}
{{ include "signoz.fullname" . }}:{{ include "signoz.port" . }}
{{- end -}}

{{/*
Set signoz internal url
*/}}
{{- define "signoz.internalUrl" -}}
{{ include "signoz.fullname" . }}:{{ include "signoz.internalPort" . }}
{{- end -}}


{{/*
Create a default fully qualified app name for schema migrator.
*/}}
{{- define "schemaMigrator.fullname" -}}
{{- printf "%s-%s" (include "signoz.fullname" .) .Values.schemaMigrator.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "schemaMigrator.labels" -}}
helm.sh/chart: {{ include "signoz.chart" . }}
{{ include "schemaMigrator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common Selector labels of schema migrator
*/}}
{{- define "schemaMigrator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


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
Return the schema migrator's image name
*/}}
{{- define "schemaMigrator.image" -}}
{{- $registryName := default .Values.schemaMigrator.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.schemaMigrator.image.repository -}}
{{- $tag := .Values.schemaMigrator.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}
{{/*
Return the schema migrator's wait initContainer image name
*/}}
{{- define "schemaMigrator.initContainers.wait.image" -}}
{{- $registryName := default .Values.schemaMigrator.initContainers.wait.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.schemaMigrator.initContainers.wait.image.repository -}}
{{- $tag := .Values.schemaMigrator.initContainers.wait.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the schema migrator's init initContainer image name
*/}}
{{- define "schemaMigrator.initContainers.init.image" -}}
{{- $registryName := default .Values.schemaMigrator.initContainers.init.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.schemaMigrator.initContainers.init.image.repository -}}
{{- $tag := .Values.schemaMigrator.initContainers.init.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the schema migrator's init initContainer image name
*/}}
{{- define "schemaMigrator.initContainers.chReady.image" -}}
{{- $registryName := default .Values.schemaMigrator.initContainers.chReady.image.registry .Values.global.imageRegistry -}}
{{- $repositoryName := .Values.schemaMigrator.initContainers.chReady.image.repository -}}
{{- $tag := .Values.schemaMigrator.initContainers.chReady.image.tag | toString -}}
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
Create the name of the Role to use for schema migrator
*/}}
{{- define "schemaMigrator.roleName" -}}
{{- if .Values.schemaMigrator.role.create }}
{{- $role := printf "%s-%s" (include "schemaMigrator.fullname" .) (include "signoz.namespace" .) -}}
{{- default $role .Values.schemaMigrator.role.name }}
{{- else }}
{{- default "default" .Values.schemaMigrator.role.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the RoleBinding to use for schema migrator
*/}}
{{- define "schemaMigrator.roleBindingName" -}}
{{- if .Values.schemaMigrator.role.create }}
{{- $role := printf "%s-%s" (include "schemaMigrator.fullname" .) (include "signoz.namespace" .) -}}
{{- default $role .Values.schemaMigrator.role.roleBinding.name }}
{{- else }}
{{- default "default" .Values.schemaMigrator.role.roleBinding.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for schema migrator
*/}}
{{- define "schemaMigrator.serviceAccountName" -}}
{{- if .Values.schemaMigrator.serviceAccount.create -}}
    {{ default (include "schemaMigrator.fullname" .) .Values.schemaMigrator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.schemaMigrator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service name of Clickhouse
*/}}
{{- define "clickhouse.servicename" -}}
{{- if .Values.clickhouse.fullnameOverride -}}
{{- .Values.clickhouse.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "clickhouse" .Values.clickhouse.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- $name = .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- $name = printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- $namespace := .Values.clickhouse.namespace -}}
{{- $clusterDomain := default "cluster.local" .Values.global.clusterDomain -}}
{{- if and $namespace (ne $namespace .Release.Namespace) -}}
{{ printf "%s.%s.svc.%s" $name $namespace $clusterDomain }}
{{- else -}}
{{ $name }}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Return `nodePort: null` if service type is ClusterIP
*/}}
{{- define "signoz.service.ifClusterIP" -}}
{{- if (eq . "ClusterIP") }}
nodePort: null
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
Return true if Let's Encrypt ClusterIssuer of `cert-manager` should be created.
*/}}
{{- define "ingress.letsencrypt" -}}
{{- $clusterIssuerEnabled := index (index .Values "cert-manager") "letsencrypt" -}}
{{- if ne ($clusterIssuerEnabled | toString) "<nil>" -}}
  {{ $clusterIssuerEnabled }}
{{- else if and (index (index .Values "ingress-nginx") "enabled") (index (index .Values "cert-manager") "enabled") -}}
  true
{{- else -}}
  false
{{- end -}}
{{- end -}}

{{/*
Common K8s environment variables used by SigNoz OtelCollector.
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
Return the proper Image Registry Secret Names.
*/}}
{{- define "signoz.imagePullSecrets" -}}
{{- if or .Values.global.imagePullSecrets .Values.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Function to render additional environment variables 
*/}}
{{- define "signoz.renderAdditionalEnv" -}}
{{- $dict := . -}}
{{- $processedKeys := dict -}}
{{- range keys . | sortAlpha }}
{{- $val := pluck . $dict | first -}}
{{- $key := upper . -}}
{{- if not (hasKey $processedKeys $key) }}
{{- $processedKeys = merge $processedKeys (dict $key true) -}}
{{- $valueType := printf "%T" $val -}}
{{- if eq $valueType "map[string]interface {}" }}
- name: {{ $key }}
{{ toYaml $val | indent 2 -}}
{{- else if eq $valueType "string" }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- else }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}
