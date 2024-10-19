{{/*
Base config for OtelAgent
*/}}
{{- define "otelAgent.baseConfig" -}}
{{- .Values.otelAgent.config | toYaml }}
{{- end }}

{{/*
Base config for OtelDeployment
*/}}
{{- define "otelDeployment.baseConfig" -}}
{{- .Values.otelDeployment.config | toYaml }}
{{- end }}

{{/*
Build config file for daemonset OpenTelemetry Collector: OtelAgent
*/}}
{{- define "otelAgent.config" -}}
{{- $values := deepCopy .Values.otelAgent }}
{{- $data := dict "Values" $values | mustMergeOverwrite (deepCopy .) }}
{{- $config := include "otelAgent.baseConfig" $data | fromYaml }}
{{- if .Values.presets.logsCollection.enabled }}
{{- $config = (include "opentelemetry-collector.applyLogsCollectionConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.hostMetrics.enabled }}
{{- $config = (include "opentelemetry-collector.applyHostMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.kubeletMetrics.enabled }}
{{- $config = (include "opentelemetry-collector.applyKubeletMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.kubernetesAttributes.enabled }}
{{- $config = (include "opentelemetry-collector.applyKubernetesAttributesConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.resourceDetection.enabled }}
{{- $config = (include "opentelemetry-collector.applyResourceDetectionConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.global.deploymentEnvironment }}
{{- $config = (include "opentelemetry-collector.applyDeploymentEnvironmentConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.loggingExporter.enabled }}
{{- $config = (include "opentelemetry-collector.applyLoggingExporterConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.otlpExporter.enabled }}
{{- $config = (include "opentelemetry-collector.applyOtlpExporterConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{ if or (eq (len $config.service.pipelines.logs.receivers) 0) (eq (len $config.service.pipelines.logs.exporters) 0) }}
{{- $_ := unset $config.service.pipelines "logs" }}
{{- end }}
{{- if or (eq (len $config.service.pipelines.metrics.receivers) 0) (eq (len $config.service.pipelines.metrics.exporters) 0) }}
{{- $_ := unset $config.service.pipelines "metrics" }}
{{- end }}
{{- if or (eq (len $config.service.pipelines.traces.receivers) 0) (eq (len $config.service.pipelines.traces.exporters) 0) }}
{{- $_ := unset $config.service.pipelines "traces" }}
{{- end }}
{{- tpl (toYaml $config) . }}
{{- end }}

{{/*
Build config file for deployment OpenTelemetry Collector: OtelDeployment
*/}}
{{- define "otelDeployment.config" -}}
{{- $values := deepCopy .Values }}
{{- $data := dict "Values" $values | mustMergeOverwrite (deepCopy .) }}
{{- $config := include "otelDeployment.baseConfig" $data | fromYaml }}
{{- if .Values.presets.resourceDetection.enabled }}
{{- $config = (include "opentelemetry-collector.applyResourceDetectionConfigForDeployment" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.global.deploymentEnvironment }}
{{- $config = (include "opentelemetry-collector.applyDeploymentEnvironmentConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.clusterMetrics.enabled }}
{{- $config = (include "opentelemetry-collector.applyClusterMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.k8sEvents.enabled }}
{{- $config = (include "opentelemetry-collector.applyK8sEventsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.loggingExporter.enabled }}
{{- $config = (include "opentelemetry-collector.applyLoggingExporterConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.otlpExporter.enabled }}
{{- $config = (include "opentelemetry-collector.applyOtlpExporterConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if or (eq (len (index (index $config.service.pipelines "metrics/internal") "receivers")) 0) (eq (len (index (index $config.service.pipelines "metrics/internal") "exporters")) 0) }}
{{- $_ := unset $config.service.pipelines "metrics/internal" }}
{{- end }}
{{- tpl (toYaml $config) . }}
{{- end }}

{{- define "opentelemetry-collector.applyLoggingExporterConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.loggingExporterConfig" .Values | fromYaml) .config }}
{{- if $config.service.pipelines.logs }}
{{- $_ := set $config.service.pipelines.logs "exporters" (append $config.service.pipelines.logs.exporters "logging" | uniq)  }}
{{- end }}
{{- if $config.service.pipelines.metrics }}
{{- $_ := set $config.service.pipelines.metrics "exporters" (prepend $config.service.pipelines.metrics.exporters "logging" | uniq)  }}
{{- end }}
{{- if $config.service.pipelines.traces }}
{{- $_ := set $config.service.pipelines.traces "exporters" (prepend $config.service.pipelines.traces.exporters "logging" | uniq)  }}
{{- end }}
{{- if index $config.service.pipelines "metrics/internal" }}
{{- $_ := set (index $config.service.pipelines "metrics/internal") "exporters" (prepend (index (index $config.service.pipelines "metrics/internal") "exporters") "logging" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.loggingExporterConfig" -}}
exporters:
  logging:
    {{- with .Values.presets.loggingExporter }}
    verbosity: {{ .verbosity }}
    sampling_initial: {{ .samplingInitial }}
    sampling_thereafter: {{ .samplingThereafter }}
    {{- end }}
{{- end }}


{{- define "opentelemetry-collector.applyOtlpExporterConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.otlpExporterConfig" .Values | fromYaml) .config }}
{{- if $config.service.pipelines.logs }}
{{- $_ := set $config.service.pipelines.logs "exporters" (append $config.service.pipelines.logs.exporters "otlp" | uniq)  }}
{{- end }}
{{- if $config.service.pipelines.metrics }}
{{- $_ := set $config.service.pipelines.metrics "exporters" (prepend $config.service.pipelines.metrics.exporters "otlp" | uniq)  }}
{{- end }}
{{- if $config.service.pipelines.traces }}
{{- $_ := set $config.service.pipelines.traces "exporters" (prepend $config.service.pipelines.traces.exporters "otlp" | uniq)  }}
{{- end }}
{{- if index $config.service.pipelines "metrics/internal" }}
{{- $_ := set (index $config.service.pipelines "metrics/internal") "exporters" (prepend (index (index $config.service.pipelines "metrics/internal") "exporters") "otlp" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.otlpExporterConfig" -}}
exporters:
  otlp:
    endpoint: ${env:OTEL_EXPORTER_OTLP_ENDPOINT}
    tls:
      insecure: ${env:OTEL_EXPORTER_OTLP_INSECURE}
      insecure_skip_verify: ${env:OTEL_EXPORTER_OTLP_INSECURE_SKIP_VERIFY}
      {{- if .Values.otelTlsSecrets.enabled }}
      cert_file: ${env:OTEL_SECRETS_PATH}/cert.pem
      key_file: ${env:OTEL_SECRETS_PATH}/key.pem
      {{- if .Values.otelTlsSecrets.ca }}
      ca_file: ${env:OTEL_SECRETS_PATH}/ca.pem
      {{- end }}
      {{- end }}
    headers:
      "signoz-access-token": "${env:SIGNOZ_API_KEY}"
{{- end }}

{{- define "opentelemetry-collector.applyClusterMetricsConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.clusterMetricsConfig" .Values | fromYaml) .config }}
{{- if index $config.service.pipelines "metrics/internal" }}
{{- $_ := set (index $config.service.pipelines "metrics/internal") "receivers" (append (index (index $config.service.pipelines "metrics/internal") "receivers") "k8s_cluster" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.clusterMetricsConfig" -}}
receivers:
  k8s_cluster:
    collection_interval: {{ .Values.presets.clusterMetrics.collectionInterval }}
    node_conditions_to_report:
      {{- toYaml .Values.presets.clusterMetrics.nodeConditionsToReport | nindent 6 }}
    allocatable_types_to_report:
      {{- toYaml .Values.presets.clusterMetrics.allocatableTypesToReport | nindent 6 }}
    metrics:
      {{- toYaml .Values.presets.clusterMetrics.metrics | nindent 6 }}
{{- end }}

{{- define "opentelemetry-collector.applyK8sEventsConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.k8sEventsConfig" .Values | fromYaml) .config }}
{{- if $config.service.pipelines.logs }}
{{- $_ := set $config.service.pipelines.logs "receivers" (append $config.service.pipelines.logs.receivers "k8s_events" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.k8sEventsConfig" -}}
receivers:
  k8s_events:
    auth_type: {{ .Values.presets.k8sEvents.authType }}
    {{- if gt (len .Values.presets.k8sEvents.namespaces) 0 }}
    namespaces:
      {{- toYaml .Values.presets.k8sEvents.namespaces | nindent 6 }}
    {{- end }}
{{- end }}

{{- define "opentelemetry-collector.applyHostMetricsConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.hostMetricsConfig" .Values | fromYaml) .config }}
{{- if $config.service.pipelines.metrics }}
{{- $_ := set $config.service.pipelines.metrics "receivers" (append $config.service.pipelines.metrics.receivers "hostmetrics" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.hostMetricsConfig" -}}
receivers:
  hostmetrics:
    collection_interval: {{ .Values.presets.hostMetrics.collectionInterval }}
    root_path: /hostfs
    scrapers:
    {{ range $key, $val := .Values.presets.hostMetrics.scrapers }}
      {{ $key }}: {{- $val | toYaml | nindent 8 }}
    {{ end }}
{{- end }}

{{- define "opentelemetry-collector.applyKubeletMetricsConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.kubeletMetricsConfig" .Values | fromYaml) .config }}
{{- if $config.service.pipelines.metrics }}
{{- $_ := set $config.service.pipelines.metrics "receivers" (append $config.service.pipelines.metrics.receivers "kubeletstats" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.kubeletMetricsConfig" -}}
receivers:
  kubeletstats:
    collection_interval: {{ .Values.presets.kubeletMetrics.collectionInterval }}
    auth_type: {{ .Values.presets.kubeletMetrics.authType }}
    endpoint: {{ .Values.presets.kubeletMetrics.endpoint }}
    insecure_skip_verify: {{ default true .Values.presets.kubeletMetrics.insecureSkipVerify }}
    extra_metadata_labels:
      {{ toYaml .Values.presets.kubeletMetrics.extraMetadataLabels | nindent 6 }}
    metric_groups:
      {{ toYaml .Values.presets.kubeletMetrics.metricGroups | nindent 6 }}
    metrics:
      {{ toYaml .Values.presets.kubeletMetrics.metrics | nindent 6 }}
{{- end }}

{{- define "opentelemetry-collector.applyLogsCollectionConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.logsCollectionConfig" .Values | fromYaml) .config }}
{{- if $config.service.pipelines.logs }}
{{- $_ := set $config.service.pipelines.logs "receivers" (append $config.service.pipelines.logs.receivers "filelog/k8s" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.logsCollectionConfig" -}}
receivers:
  filelog/k8s:
    # Include logs from all container
    include:
      # Whitelist specific namespaces, pods or containers if enabled
      {{- if .Values.presets.logsCollection.whitelist.enabled }}
      {{- $namespaces := .Values.presets.logsCollection.whitelist.namespaces }}
      {{- $pods := .Values.presets.logsCollection.whitelist.pods }}
      {{- $containers := .Values.presets.logsCollection.whitelist.containers }}
      {{- $additionalInclude := .Values.presets.logsCollection.whitelist.additionalInclude }}
      # Include specific container's logs using whitelist config.
      # The file format is /var/log/pods/<namespace_name>_<pod_name>_<pod_uid>/<container_name>/<run_id>.log
      {{- if .Values.presets.logsCollection.whitelist.signozLogs }}
      - /var/log/pods/{{ .Release.Namespace }}_{{ .Release.Name }}*-signoz-*/*/*.log
      - /var/log/pods/{{ .Release.Namespace }}_{{ .Release.Name }}*-k8s-infra-*/*/*.log
      {{- if and .Values.namespace (ne .Release.Namespace .Values.namespace) }}
      - /var/log/pods/{{ .Release.Namespace }}_{{ .Release.Name }}*-signoz-*/*/*.log
      - /var/log/pods/{{ .Values.namespace }}_{{ .Release.Name }}*-k8s-infra-*/*/*.log
      {{- end }}
      {{- end }}
      {{- range $namespace := $namespaces }}
      - /var/log/pods/{{ $namespace }}_*/*/*.log
      {{- end }}
      {{- range $pod := $pods }}
      - /var/log/pods/*_{{ $pod }}*_*/*/*.log
      {{- end }}
      {{- range $container := $containers }}
      - /var/log/pods/*_*_*/{{ $container }}/*.log
      {{- end }}
      {{- range $includes := $additionalInclude }}
      - {{ $includes }}
      {{- end }}
      {{- else }}
      {{ toYaml .Values.presets.logsCollection.include | nindent 6 }}
      {{- end }}
    # Blacklist specific namespaces, pods or containers if enabled
    {{- if .Values.presets.logsCollection.blacklist.enabled }}
    {{- $namespaces := .Values.presets.logsCollection.blacklist.namespaces }}
    {{- $pods := .Values.presets.logsCollection.blacklist.pods }}
    {{- $containers := .Values.presets.logsCollection.blacklist.containers }}
    {{- $additionalExclude := .Values.presets.logsCollection.blacklist.additionalExclude }}
    # Exclude specific container's logs using blacklist config or includeSigNozLogs flag.
    # The file format is /var/log/pods/<namespace_name>_<pod_name>_<pod_uid>/<container_name>/<run_id>.log
    exclude:
      {{- if .Values.presets.logsCollection.blacklist.signozLogs }}
      - /var/log/pods/{{ .Release.Namespace }}_{{ .Release.Name }}*-signoz-*/*/*.log
      - /var/log/pods/{{ .Release.Namespace }}_{{ .Release.Name }}*-k8s-infra-*/*/*.log
      {{- if and .Values.namespace (ne .Release.Namespace .Values.namespace) }}
      - /var/log/pods/{{ .Release.Namespace }}_{{ .Release.Name }}*-signoz-*/*/*.log
      - /var/log/pods/{{ .Values.namespace }}_{{ .Release.Name }}*-k8s-infra-*/*/*.log
      {{- end }}
      {{- end }}
      {{- range $namespace := $namespaces }}
      - /var/log/pods/{{ $namespace }}_*/*/*.log
      {{- end }}
      {{- range $pod := $pods }}
      - /var/log/pods/*_{{ $pod }}*_*/*/*.log
      {{- end }}
      {{- range $container := $containers }}
      - /var/log/pods/*_*_*/{{ $container }}/*.log
      {{- end }}
      {{- range $excludes := $additionalExclude }}
      - {{ $excludes }}
      {{- end }}
    {{- else }}
    exclude: []
    {{- end }}
    start_at: {{ .Values.presets.logsCollection.startAt }}
    include_file_path: {{ .Values.presets.logsCollection.includeFilePath }}
    include_file_name: {{ .Values.presets.logsCollection.includeFileName }}
    operators:
    {{ range $operators := .Values.presets.logsCollection.operators }}
      - {{ toYaml $operators | nindent 8 }}
    {{ end }}
{{- end }}

{{- define "opentelemetry-collector.applyKubernetesAttributesConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.kubernetesAttributesConfig" .Values | fromYaml) .config }}
{{- if $config.service.pipelines.logs }}
{{- $_ := set $config.service.pipelines.logs "processors" (prepend $config.service.pipelines.logs.processors "k8sattributes" | uniq) }}
{{- end }}
{{- if $config.service.pipelines.metrics }}
{{- $_ := set $config.service.pipelines.metrics "processors" (prepend $config.service.pipelines.metrics.processors "k8sattributes" | uniq) }}
{{- end }}
{{- if $config.service.pipelines.traces }}
{{- $_ := set $config.service.pipelines.traces "processors" (prepend $config.service.pipelines.traces.processors "k8sattributes" | uniq) }}
{{- end }}
{{- if index $config.service.pipelines "metrics/internal" }}
{{- $_ := set (index $config.service.pipelines "metrics/internal") "processors" (prepend (index (index $config.service.pipelines "metrics/internal") "processors") "k8sattributes" | uniq) }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.kubernetesAttributesConfig" -}}
processors:
  k8sattributes:
    passthrough: {{ .Values.presets.kubernetesAttributes.passthrough }}
    filter:
      {{- toYaml .Values.presets.kubernetesAttributes.filter | nindent 6 }}
    pod_association:
    {{ range $association := .Values.presets.kubernetesAttributes.podAssociation }}
      - {{ toYaml $association | nindent 8 }}
    {{ end }}
    extract:
      metadata:
        {{ toYaml .Values.presets.kubernetesAttributes.extractMetadatas | nindent 8 }}
{{- end }}

{{- define "opentelemetry-collector.applyResourceDetectionConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.resourceDetectionConfig" .Values | fromYaml) .config }}
{{- if $config.service.pipelines.logs }}
{{- $_ := set $config.service.pipelines.logs "processors" (prepend $config.service.pipelines.logs.processors "resourcedetection" | uniq) }}
{{- end }}
{{- if $config.service.pipelines.metrics }}
{{- $_ := set $config.service.pipelines.metrics "processors" (prepend $config.service.pipelines.metrics.processors "resourcedetection" | uniq) }}
{{- end }}
{{- if $config.service.pipelines.traces }}
{{- $_ := set $config.service.pipelines.traces "processors" (prepend $config.service.pipelines.traces.processors "resourcedetection" | uniq) }}
{{- end }}
{{- if index $config.service.pipelines "metrics/internal" }}
{{- $_ := set (index $config.service.pipelines "metrics/internal") "processors" (prepend (index (index $config.service.pipelines "metrics/internal") "processors") "resourcedetection" | uniq) }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.applyResourceDetectionConfigForDeployment" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.resourceDetectionConfigForDeployment" .Values | fromYaml) .config }}
{{- if $config.service.pipelines.logs }}
{{- $_ := set $config.service.pipelines.logs "processors" (prepend $config.service.pipelines.logs.processors "resourcedetection" | uniq) }}
{{- end }}
{{- if $config.service.pipelines.metrics }}
{{- $_ := set $config.service.pipelines.metrics "processors" (prepend $config.service.pipelines.metrics.processors "resourcedetection" | uniq) }}
{{- end }}
{{- if $config.service.pipelines.traces }}
{{- $_ := set $config.service.pipelines.traces "processors" (prepend $config.service.pipelines.traces.processors "resourcedetection" | uniq) }}
{{- end }}
{{- if index $config.service.pipelines "metrics/internal" }}
{{- $_ := set (index $config.service.pipelines "metrics/internal") "processors" (prepend (index (index $config.service.pipelines "metrics/internal") "processors") "resourcedetection" | uniq) }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.resourceDetectionConfig" -}}
processors:
  resourcedetection:
    # detectors: include ec2/eks for AWS, gcp for GCP and azure/aks for Azure
    # env detector included below adds custom labels using OTEL_RESOURCE_ATTRIBUTES envvar (set envResourceAttributes value)
    detectors:
      {{- if eq "aws" .Values.global.cloud }}
      - eks
      - ec2
      {{- end }}
      {{- if hasPrefix "gcp" .Values.global.cloud }}
      - gcp
      {{- end }}
      {{- if eq "azure" .Values.global.cloud }}
      - azure
      {{- end }}
      - k8snode
      - env
      - system
    k8snode:
      node_from_env_var: K8S_NODE_NAME
      auth_type: serviceAccount
    timeout: {{ .Values.presets.resourceDetection.timeout }}
    override: {{ .Values.presets.resourceDetection.override }}
    system:
      resource_attributes:
        host.name:
          enabled: false
        host.id:
          enabled: false
        os.type:
          enabled: true
{{- end }}

{{- define "opentelemetry-collector.resourceDetectionConfigForDeployment" -}}
processors:
  resourcedetection:
    # detectors: include ec2/eks for AWS, gcp for GCP and azure/aks for Azure
    # env detector included below adds custom labels using OTEL_RESOURCE_ATTRIBUTES envvar (set envResourceAttributes value)
    detectors:
      {{- if eq "aws" .Values.global.cloud }}
      - eks
      - ec2
      {{- end }}
      {{- if hasPrefix "gcp" .Values.global.cloud }}
      - gcp
      {{- end }}
      {{- if eq "azure" .Values.global.cloud }}
      - azure
      {{- end }}
      - env
    timeout: {{ .Values.presets.resourceDetection.timeout }}
    override: {{ .Values.presets.resourceDetection.override }}
    {{- if eq "aws" .Values.global.cloud }}
    ec2:
      resource_attributes:
        host.name:
          enabled: false
        host.id:
          enabled: false
        host.image.id:
          enabled: false
        host.type:
          enabled: false
    {{- end}}
    {{- if hasPrefix "gcp" .Values.global.cloud }}
    gcp:
      resource_attributes:
        host.name:
          enabled: false
        host.id:
          enabled: false
        host.type:
          enabled: false
        gcp.gce.instance.name:
          enabled: false
        gcp.gce.instance.hostname:
          enabled: false
    {{- end}}
    {{- if eq "azure" .Values.global.cloud }}
    azure:
      resource_attributes:
        host.name:
          enabled: false
        host.id:
          enabled: false
        azure.vm.name:
          enabled: false
        azure.vm.size:
          enabled: false
        azure.vm.scaleset.name:
          enabled: false
        azure.resourcegroup.name:
          enabled: false
    {{- end}}
{{- end }}

{{- define "opentelemetry-collector.applyDeploymentEnvironmentConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.deploymentEnvironmentConfig" .Values | fromYaml) .config }}
{{- if $config.service.pipelines.logs }}
{{- $_ := set $config.service.pipelines.logs "processors" (prepend $config.service.pipelines.logs.processors "resource/deployenv" | uniq) }}
{{- end }}
{{- if $config.service.pipelines.metrics }}
{{- $_ := set $config.service.pipelines.metrics "processors" (prepend $config.service.pipelines.metrics.processors "resource/deployenv" | uniq) }}
{{- end }}
{{- if $config.service.pipelines.traces }}
{{- $_ := set $config.service.pipelines.traces "processors" (prepend $config.service.pipelines.traces.processors "resource/deployenv" | uniq) }}
{{- end }}
{{- if index $config.service.pipelines "metrics/internal" }}
{{- $_ := set (index $config.service.pipelines "metrics/internal") "processors" (prepend (index (index $config.service.pipelines "metrics/internal") "processors") "resource/deployenv" | uniq) }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.deploymentEnvironmentConfig" -}}
processors:
  resource/deployenv:
    attributes:
    - key: deployment.environment
      value: ${env:DEPLOYMENT_ENVIRONMENT}
      action: insert
{{- end }}
