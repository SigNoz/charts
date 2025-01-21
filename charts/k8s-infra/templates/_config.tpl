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
{{- if .Values.presets.selfTelemetry.traces.enabled }}
{{- $config = (include "opentelemetry-collector.applySelfTracesConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.selfTelemetry.metrics.enabled }}
{{- $config = (include "opentelemetry-collector.applySelfMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if or .Values.presets.selfTelemetry.metrics.enabled .Values.presets.selfTelemetry.traces.enabled }}
{{- $config = (include "opentelemetry-collector.applySelfTelemetryResourceConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}  
{{- if .Values.presets.selfTelemetry.logs.enabled }}
{{- $config = (include "opentelemetry-collector.applySelfLogsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
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
{{- if .Values.presets.selfTelemetry.logs.enabled }}
{{- $config = (include "opentelemetry-collector.applyOtlpExporterSelfTelemetryConfig" (dict "Values" $data "config" $config) | fromYaml) }}
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
{{- if .Values.presets.selfTelemetry.traces.enabled }}
{{- $config = (include "opentelemetry-collector.applySelfTracesConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.selfTelemetry.metrics.enabled }}
{{- $config = (include "opentelemetry-collector.applySelfMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if or .Values.presets.selfTelemetry.metrics.enabled .Values.presets.selfTelemetry.traces.enabled }}
{{- $config = (include "opentelemetry-collector.applySelfTelemetryResourceConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.resourceDetection.enabled }}
{{- $config = (include "opentelemetry-collector.applyResourceDetectionConfigForDeployment" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.kubernetesAttributes.enabled }}
{{- $config = (include "opentelemetry-collector.applyKubernetesAttributesConfigForDeployment" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.global.deploymentEnvironment }}
{{- $config = (include "opentelemetry-collector.applyDeploymentEnvironmentConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.clusterMetrics.enabled }}
{{- $config = (include "opentelemetry-collector.applyClusterMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.prometheus.enabled }}
{{- $config = (include "opentelemetry-collector.applyPrometheusConfig" (dict "Values" $data "config" $config) | fromYaml) }}
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
{{- if or (eq (len (index (index $config.service.pipelines "metrics/scraper") "receivers")) 0) (eq (len (index (index $config.service.pipelines "metrics/scraper") "exporters")) 0) }}
{{- $_ := unset $config.service.pipelines "metrics/scraper" }}
{{- end }}
{{ if or (eq (len $config.service.pipelines.logs.receivers) 0) (eq (len $config.service.pipelines.logs.exporters) 0) }}
{{- $_ := unset $config.service.pipelines "logs" }}
{{- end }}
{{- tpl (toYaml $config) . }}
{{- end }}

{{- define "opentelemetry-collector.applySelfTracesConfig" -}}
{{- $config := .config }}
{{- $config = mustMergeOverwrite (include "opentelemetry-collector.selfTracesConfig" .Values | fromYaml) $config }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.applySelfMetricsConfig" -}}
{{- $config := .config }}
{{- $config = mustMergeOverwrite (include "opentelemetry-collector.selfMetricsConfig" .Values | fromYaml) $config }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.applySelfTelemetryResourceConfig" -}}
{{- $config := .config }}
{{- $config = mustMergeOverwrite (include "opentelemetry-collector.selfTelemetryResourceConfig" .Values | fromYaml) $config }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.applySelfLogsConfig" -}}
{{- $config := .config }}
{{- $config = mustMergeOverwrite (include "opentelemetry-collector.selfLogsConfig" .Values | fromYaml) $config }}
{{- $config | toYaml }}
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
{{- if index $config.service.pipelines "metrics/scraper" }}
{{- $_ := set (index $config.service.pipelines "metrics/scraper") "exporters" (prepend (index (index $config.service.pipelines "metrics/scraper") "exporters") "logging" | uniq)  }}
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
{{- if index $config.service.pipelines "metrics/scraper" }}
{{- $_ := set (index $config.service.pipelines "metrics/scraper") "exporters" (prepend (index (index $config.service.pipelines "metrics/scraper") "exporters") "otlp" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.applyOtlpExporterSelfTelemetryConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.otlpExporterSelfTelemetryConfig" .Values | fromYaml) .config }}
{{- $config | toYaml }}
{{- end }}



{{- define "opentelemetry-collector.otlpExporterSelfTelemetryConfig" -}}
exporters:
  otlphttp/self_telemetry:
    {{- if .Values.presets.selfTelemetry.endpoint }}
    endpoint: http{{ if not .Values.presets.selfTelemetry.insecure }}s{{ end }}://{{ .Values.presets.selfTelemetry.endpoint }}
    tls:
      insecure: {{ .Values.presets.selfTelemetry.insecure }}
      insecure_skip_verify: {{ .Values.presets.selfTelemetry.insecureSkipVerify }}
    headers:
      "signoz-access-token": "${env:SIGNOZ_SELF_TELEMETRY_API_KEY}"
    {{- else }}
    endpoint: http{{ if not .Values.otelInsecure }}s{{ end }}://${env:OTEL_EXPORTER_OTLP_ENDPOINT}
    tls:
      insecure: ${env:OTEL_EXPORTER_OTLP_INSECURE}
      insecure_skip_verify: ${env:OTEL_EXPORTER_OTLP_INSECURE_SKIP_VERIFY}
    headers:
      "signoz-access-token": ${env:SIGNOZ_SELF_TELEMETRY_API_KEY}
    {{- end }}
{{- end }}

{{/*
Self traces config, if the endpoint is not set in the selfTelemetry config,
it will use the same endpoint as regular otlp exporter.
*/}}
{{- define "opentelemetry-collector.selfTracesConfig" -}}
service:
  telemetry:
    traces:
      processors:
      - batch:
          exporter:
            otlp:
              protocol: http/protobuf
              endpoint: {{ if .Values.presets.selfTelemetry.endpoint }}http{{ if not .Values.presets.selfTelemetry.insecure }}s{{ end }}://{{ .Values.presets.selfTelemetry.endpoint }}{{ else }}http{{ if not .Values.otelInsecure }}s{{ end }}://${env:OTEL_EXPORTER_OTLP_ENDPOINT}{{ end }}
              insecure: {{ if .Values.presets.selfTelemetry.endpoint }}{{ .Values.presets.selfTelemetry.insecure }}{{ else }}${env:OTEL_EXPORTER_OTLP_INSECURE}{{ end }}
              compression: gzip
              headers:
                "signoz-access-token": "${env:SIGNOZ_SELF_TELEMETRY_API_KEY}"
      propagators:
      - tracecontext
      - b3
{{- end }}

{{/*
Self metrics config, if the endpoint is not set in the selfTelemetry config,
it will use the same endpoint as regular otlp exporter.
*/}}
{{- define "opentelemetry-collector.selfMetricsConfig" -}}
service:
  telemetry:
    metrics:
      level: detailed
      readers:
        - periodic:
            exporter:
              otlp:
                protocol: http/protobuf
                endpoint: {{ if .Values.presets.selfTelemetry.endpoint -}}
                  http{{ if not .Values.presets.selfTelemetry.insecure }}s{{ end }}://{{ .Values.presets.selfTelemetry.endpoint }}
                {{- else -}}
                  http{{ if not .Values.otelInsecure }}s{{ end }}://${env:OTEL_EXPORTER_OTLP_ENDPOINT}
                {{- end }}
                insecure: {{ if .Values.presets.selfTelemetry.endpoint }}{{ .Values.presets.selfTelemetry.insecure }}{{ else }}${env:OTEL_EXPORTER_OTLP_INSECURE}{{ end }}
                compression: gzip
                headers:
                  "signoz-access-token": "${env:SIGNOZ_SELF_TELEMETRY_API_KEY}"
{{- end }}

{{/*
OTEL go doesn't support logs yet, so we use filelog receiver to collect logs,
if the endpoint is not set in the selfTelemetry config, it will use the same endpoint as regular otlp exporter.
*/}}
{{- define "opentelemetry-collector.selfLogsConfig" -}}
receivers:
  filelog/self_logs:
    include:
      - /var/log/pods/{{ .Release.Namespace }}_{{ .Release.Name }}*-k8s-infra-*/*/*.log
    start_at: {{ .Values.presets.logsCollection.startAt }}
    include_file_path: {{ .Values.presets.logsCollection.includeFilePath }}
    include_file_name: {{ .Values.presets.logsCollection.includeFileName }}
    operators:
    {{ range $operators := .Values.presets.logsCollection.operators }}
      - {{ toYaml $operators | nindent 8 }}
    {{ end }}
processors:
  filter/non_error_logs:
    logs:
      log_record:
        - 'not IsMatch(body, ".*error.*")'
service:
  pipelines:
    logs/self_logs:
      exporters: [otlphttp/self_telemetry]
      # we want to send only error logs
      processors: [filter/non_error_logs]
      receivers: [filelog/self_logs]
{{- end }}

{{/*
This will add resource attributes to the telemetry data for self telemetry.
i.e selfMetricsConfig, selfTracesConfig
*/}}
{{- define "opentelemetry-collector.selfTelemetryResourceConfig" -}}
service:
  telemetry:
    resource:
      k8s.pod.name: ${env:K8S_POD_NAME}
      k8s.container.name: ${env:K8S_CONTAINER_NAME}
      k8s.node.name: ${env:K8S_NODE_NAME}
      k8s.namespace.name: ${env:K8S_NAMESPACE}
      k8s.cluster.name: ${env:K8S_CLUSTER_NAME}
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
    resource_attributes:
      {{- toYaml .Values.presets.clusterMetrics.resourceAttributes | nindent 6 }}
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

{{- define "opentelemetry-collector.applyPrometheusConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.prometheusConfig" .Values | fromYaml) .config }}
{{- if index $config.service.pipelines "metrics/scraper" }}
{{- $_ := set (index $config.service.pipelines "metrics/scraper") "receivers" (append (index (index $config.service.pipelines "metrics/scraper") "receivers") "prometheus/scraper" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.convertAnnotationToPrometheusMetaLabel" -}}
{{- $name := . | lower -}}
{{- $name = regexReplaceAll "\\." $name "_" -}}
{{- $name := regexReplaceAll "/" $name "_" -}}
{{- $name := regexReplaceAll "-" $name "_" -}}
{{- $name := regexReplaceAll "[^a-z0-9_]" $name "_" -}}
{{- $name -}}
{{- end -}}

{{- define "opentelemetry-collector.prometheusConfig" -}}
{{- $annotationsPrefix := include "opentelemetry-collector.convertAnnotationToPrometheusMetaLabel" .Values.presets.prometheus.annotationsPrefix }}
receivers:
  prometheus/scraper:
    config:
      scrape_configs:
        {{- if .Values.presets.prometheus.enabled }}
        - job_name: "signoz-scraper"
          scrape_interval: {{ .Values.presets.prometheus.scrapeInterval }}
          kubernetes_sd_configs:
            - role: pod
              {{- if or .Values.presets.prometheus.namespaceScoped (len .Values.presets.prometheus.namespaces) }}
              namespaces:
                {{- if .Values.presets.prometheus.namespaceScoped }}
                own_namespace: true
                {{- end }}
                {{- if .Values.presets.prometheus.namespaces }}
                names: {{ toYaml .Values.presets.prometheus.namespaces | nindent 16 }}
                {{- end }}
              {{- end }}
          relabel_configs:
            - source_labels: [__meta_kubernetes_pod_annotation_{{ $annotationsPrefix }}_scrape]
              action: keep
              regex: true
            - source_labels: [__meta_kubernetes_pod_annotation_{{ $annotationsPrefix }}_path]
              action: replace
              target_label: __metrics_path__
              regex: (.+)
            - source_labels: [__meta_kubernetes_pod_ip, __meta_kubernetes_pod_annotation_{{ $annotationsPrefix }}_port]
              action: replace
              separator: ":"
              target_label: __address__
            - target_label: job_name
              replacement: signoz-scraper
            {{- if .Values.presets.prometheus.includePodLabel }}
            - action: labelmap
              regex: __meta_kubernetes_pod_label_(.+)
            {{- end }}
            - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_name]
              action: replace
              target_label: signoz_k8s_name
            - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_instance]
              action: replace
              target_label: signoz_k8s_instance
            - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_component]
              action: replace
              target_label: signoz_k8s_component
            - source_labels: [__meta_kubernetes_namespace]
              action: replace
              target_label: k8s_namespace_name
            - source_labels: [__meta_kubernetes_pod_name]
              action: replace
              target_label: k8s_pod_name
            - source_labels: [__meta_kubernetes_pod_uid]
              action: replace
              target_label: k8s_pod_uid
            {{- if .Values.presets.prometheus.includeContainerName }}
            - source_labels: [__meta_kubernetes_pod_container_name]
              action: replace
              target_label: k8s_container_name
            - source_labels: [__meta_kubernetes_pod_container_name]
              regex: (.+)-init
              action: drop
            {{- end }}
            - source_labels: [__meta_kubernetes_pod_node_name]
              action: replace
              target_label: k8s_node_name
            - source_labels: [__meta_kubernetes_pod_ready]
              action: replace
              target_label: k8s_pod_ready
            - source_labels: [__meta_kubernetes_pod_phase]
              action: replace
              target_label: k8s_pod_phase
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
      {{- if and .Values.namespace (ne .Release.Namespace .Values.namespace) }}
      - /var/log/pods/{{ .Release.Namespace }}_{{ .Release.Name }}*-signoz-*/*/*.log
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
{{- if index $config.service.pipelines "metrics/scraper" }}
{{- $_ := set (index $config.service.pipelines "metrics/scraper") "processors" (prepend (index (index $config.service.pipelines "metrics/scraper") "processors") "k8sattributes" | uniq) }}
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
      annotations:
        {{ toYaml .Values.presets.kubernetesAttributes.extractAnnotations | nindent 8 }}
      labels:
        {{ toYaml .Values.presets.kubernetesAttributes.extractLabels | nindent 8 }}
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
{{- if index $config.service.pipelines "metrics/scraper" }}
{{- $_ := set (index $config.service.pipelines "metrics/scraper") "processors" (prepend (index (index $config.service.pipelines "metrics/scraper") "processors") "resourcedetection" | uniq) }}
{{- end }}
{{- if index $config.service.pipelines "logs/self_logs" }}
{{- $_ := set (index $config.service.pipelines "logs/self_logs") "processors" (prepend (index (index $config.service.pipelines "logs/self_logs") "processors") "resourcedetection" | uniq) }}
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
{{- if index $config.service.pipelines "metrics/scraper" }}
{{- $_ := set (index $config.service.pipelines "metrics/scraper") "processors" (prepend (index (index $config.service.pipelines "metrics/scraper") "processors") "resourcedetection" | uniq) }}
{{- end }}
{{- if index $config.service.pipelines "logs/self_logs" }}
{{- $_ := set (index $config.service.pipelines "logs/self_logs") "processors" (prepend (index (index $config.service.pipelines "logs/self_logs") "processors") "resourcedetection" | uniq) }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.applyKubernetesAttributesConfigForDeployment" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.kubernetesAttributesConfigForDeployment" .Values | fromYaml) .config }}
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

# TODO(srikanthccv): remove separate k8sattributes config for deployment when mode
# of operation is clearly defined for collector.
{{- define "opentelemetry-collector.kubernetesAttributesConfigForDeployment" -}}
processors:
  k8sattributes:
    passthrough: false
    pod_association:
    {{ range $association := .Values.presets.kubernetesAttributes.podAssociation }}
      - {{ toYaml $association | nindent 8 }}
    {{ end }}
    extract:
      metadata:
        {{ toYaml .Values.presets.kubernetesAttributes.extractMetadatas | nindent 8 }}
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
