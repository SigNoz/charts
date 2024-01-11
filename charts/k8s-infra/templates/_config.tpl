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
{{- if .Values.presets.resourceDetectionInternal.enabled }}
{{- $config = (include "opentelemetry-collector.applyResourceDetectionInternalConfig" (dict "Values" $data "config" $config) | fromYaml) }}
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
{{- if or (eq (len (index (index $config.service.pipelines "metrics/internal") "receivers")) 0) (eq (len (index (index $config.service.pipelines "metrics/internal") "exporters")) 0) }}
{{- $_ := unset $config.service.pipelines "metrics/internal" }}
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
{{- if .Values.presets.resourceDetectionInternal.enabled }}
{{- $config = (include "opentelemetry-collector.applyResourceDetectionInternalConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.clusterMetrics.enabled }}
{{- $config = (include "opentelemetry-collector.applyClusterMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
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
    endpoint: ${OTEL_EXPORTER_OTLP_ENDPOINT}
    tls:
      insecure: ${OTEL_EXPORTER_OTLP_INSECURE}
      insecure_skip_verify: ${OTEL_EXPORTER_OTLP_INSECURE_SKIP_VERIFY}
      {{- if .Values.otelTlsSecrets.enabled }}
      cert_file: ${OTEL_SECRETS_PATH}/cert.pem
      key_file: ${OTEL_SECRETS_PATH}/key.pem
      {{- if .Values.otelTlsSecrets.ca }}
      ca_file: ${OTEL_SECRETS_PATH}/ca.pem
      {{- end }}
      {{- end }}
    headers:
      "signoz-access-token": "Bearer ${SIGNOZ_API_KEY}"
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
{{- end }}

{{- define "opentelemetry-collector.applyHostMetricsConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.hostMetricsConfig" .Values | fromYaml) .config }}
{{- if index $config.service.pipelines "metrics/internal" }}
{{- $_ := set (index $config.service.pipelines "metrics/internal") "receivers" (append (index (index $config.service.pipelines "metrics/internal") "receivers") "hostmetrics" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.hostMetricsConfig" -}}
receivers:
  hostmetrics:
    collection_interval: {{ .Values.presets.hostMetrics.collectionInterval }}
    scrapers:
    {{ range $key, $val := .Values.presets.hostMetrics.scrapers }}
      {{ $key }}: {{ $val | toYaml }}
    {{ end }}
{{- end }}

{{- define "opentelemetry-collector.applyKubeletMetricsConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.kubeletMetricsConfig" .Values | fromYaml) .config }}
{{- if index $config.service.pipelines "metrics/internal" }}
{{- $_ := set (index $config.service.pipelines "metrics/internal") "receivers" (append (index (index $config.service.pipelines "metrics/internal") "receivers") "kubeletstats" | uniq)  }}
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
{{- if index $config.service.pipelines "metrics/internal" }}
{{- $_ := set (index $config.service.pipelines "metrics/internal") "processors" (prepend (index (index $config.service.pipelines "metrics/internal") "processors") "resourcedetection" | uniq) }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.resourceDetectionConfig" -}}
processors:
  resourcedetection:
    detectors:
      {{- toYaml .Values.presets.resourceDetection.detectors | nindent 6 }}
    timeout: {{ .Values.presets.resourceDetection.timeout }}
    override: {{ .Values.presets.resourceDetection.override }}
    {{- if has "system" .Values.presets.resourceDetection.detectors }}
    system:
      hostname_sources:
        {{- toYaml .Values.presets.resourceDetection.systemHostnameSources | nindent 8 }}
    {{- end }}
{{- end }}

{{- define "opentelemetry-collector.applyResourceDetectionInternalConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.resourceDetectionInternalConfig" .Values | fromYaml) .config }}
{{- if index $config.service.pipelines "metrics/internal" }}
{{- $_ := set (index $config.service.pipelines "metrics/internal") "processors" (prepend (index (index $config.service.pipelines "metrics/internal") "processors") "resourcedetection/internal" | uniq) }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.resourceDetectionInternalConfig" -}}
processors:
  resourcedetection/internal:
    detectors:
      - env
    timeout: {{ .Values.presets.resourceDetectionInternal.timeout }}
    override: {{ .Values.presets.resourceDetectionInternal.override }}
{{- end }}
