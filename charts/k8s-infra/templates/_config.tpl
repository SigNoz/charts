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
{{- if .Values.presets.loggingExporter.enabled }}
{{- $config = (include "opentelemetry-collector.applyLoggingExporterConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.otlpExporter.enabled }}
{{- $config = (include "opentelemetry-collector.applyOtlpExporterConfig" (dict "Values" $data "config" $config) | fromYaml) }}
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
{{- if index $config.service.pipelines "metrics/generic" }}
{{- $_ := set (index $config.service.pipelines "metrics/generic") "exporters" (prepend (index (index $config.service.pipelines "metrics/generic") "exporters") "logging" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.loggingExporterConfig" -}}
exporters:
  logging: {}
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
{{- if index $config.service.pipelines "metrics/generic" }}
{{- $_ := set (index $config.service.pipelines "metrics/generic") "exporters" (prepend (index (index $config.service.pipelines "metrics/generic") "exporters") "otlp" | uniq)  }}
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
      cert_file: ${OTEL_SECRETS_PATH}/cert.pem
      key_file: ${OTEL_SECRETS_PATH}/key.pem
    headers:
      "signoz-access-token": "Bearer ${SIGNOZ_API_KEY}"
{{- end }}


{{/*
Build config file for deployment OpenTelemetry Collector: OtelDeployment
*/}}
{{- define "otelDeployment.config" -}}
{{- $values := deepCopy .Values }}
{{- $data := dict "Values" $values | mustMergeOverwrite (deepCopy .) }}
{{- $config := include "otelDeployment.baseConfig" $data | fromYaml }}
{{- if .Values.presets.clusterMetrics.enabled }}
{{- $config = (include "opentelemetry-collector.applyClusterMetricsConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.loggingExporter.enabled }}
{{- $config = (include "opentelemetry-collector.applyLoggingExporterConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- if .Values.presets.otlpExporter.enabled }}
{{- $config = (include "opentelemetry-collector.applyOtlpExporterConfig" (dict "Values" $data "config" $config) | fromYaml) }}
{{- end }}
{{- tpl (toYaml $config) . }}
{{- end }}

{{- define "opentelemetry-collector.applyClusterMetricsConfig" -}}
{{- $config := mustMergeOverwrite (include "opentelemetry-collector.clusterMetricsConfig" .Values | fromYaml) .config }}
{{- if $config.service.pipelines.metrics }}
{{- $_ := set $config.service.pipelines.metrics "receivers" (append $config.service.pipelines.metrics.receivers "k8s_cluster" | uniq)  }}
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
{{- if index $config.service.pipelines "metrics/generic" }}
{{- $_ := set (index $config.service.pipelines "metrics/generic") "receivers" (append (index (index $config.service.pipelines "metrics/generic") "receivers") "hostmetrics" | uniq)  }}
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
{{- if index $config.service.pipelines "metrics/generic" }}
{{- $_ := set (index $config.service.pipelines "metrics/generic") "receivers" (append (index (index $config.service.pipelines "metrics/generic") "receivers") "kubeletstats" | uniq)  }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.kubeletMetricsConfig" -}}
receivers:
  kubeletstats:
    collection_interval: {{ .Values.presets.kubeletMetrics.collectionInterval }}
    auth_type: "serviceAccount"
    endpoint: "${K8S_NODE_NAME}:10250"
    insecure_skip_verify: {{ default true .Values.presets.kubeletMetrics.insecureSkipVerify }}
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
    include: [ /var/log/pods/*/*/*.log ]
    # Blacklist specific namespaces, pods or containers if enabled
    {{- if .Values.presets.logsCollection.blacklist.enabled }}
    {{- $namespaces := .Values.presets.logsCollection.blacklist.namespaces }}
    {{- $pods := .Values.presets.logsCollection.blacklist.pods }}
    {{- $containers := .Values.presets.logsCollection.blacklist.containers }}
    # Exclude specific container's logs using blacklist config or includeSigNozLogs flag.
    # The file format is /var/log/pods/<namespace_name>_<pod_name>_<pod_uid>/<container_name>/<run_id>.log
    exclude:
      {{- if .Values.presets.logsCollection.blacklist.signozLogs }}
      - /var/log/pods/{{ .Release.Namespace }}_*.log
      {{- if and .Values.namespace (ne .Release.Namespace .Values.namespace) }}
      - /var/log/pods/{{ .Values.namespace }}_*.log
      {{- end }}
      {{- end }}
      {{- range $namespace := $namespaces }}
      - /var/log/pods/{{ $namespace }}_*.log
      {{- end }}
      {{- range $pod := $pods }}
      - /var/log/pods/*_{{ $pod }}*_*/*/*.log
      {{- end }}
      {{- range $container := $containers }}
      - /var/log/pods/*_*_*/{{ $container }}/*.log
      {{- end }}
    {{- else }}
    exclude: []
    {{- end }}
    start_at: beginning
    include_file_path: true
    include_file_name: false
    operators:
      # Find out which format is used by kubernetes
      - type: router
        id: get-format
        routes:
          - output: parser-docker
            expr: 'body matches "^\\{"'
          - output: parser-crio
            expr: 'body matches "^[^ Z]+ "'
          - output: parser-containerd
            expr: 'body matches "^[^ Z]+Z"'
      # Parse CRI-O format
      - type: regex_parser
        id: parser-crio
        regex: '^(?P<time>[^ Z]+) (?P<stream>stdout|stderr) (?P<logtag>[^ ]*) ?(?P<log>.*)$'
        output: extract_metadata_from_filepath
        timestamp:
          parse_from: attributes.time
          layout_type: gotime
          layout: '2006-01-02T15:04:05.000000000-07:00'
      # Parse CRI-Containerd format
      - type: regex_parser
        id: parser-containerd
        regex: '^(?P<time>[^ ^Z]+Z) (?P<stream>stdout|stderr) (?P<logtag>[^ ]*) ?(?P<log>.*)$'
        output: extract_metadata_from_filepath
        timestamp:
          parse_from: attributes.time
          layout: '%Y-%m-%dT%H:%M:%S.%LZ'
      # Parse Docker format
      - type: json_parser
        id: parser-docker
        output: extract_metadata_from_filepath
        timestamp:
          parse_from: attributes.time
          layout: '%Y-%m-%dT%H:%M:%S.%LZ'
      # Extract metadata from file path
      - type: regex_parser
        id: extract_metadata_from_filepath
        regex: '^.*\/(?P<namespace>[^_]+)_(?P<pod_name>[^_]+)_(?P<uid>[a-f0-9\-]+)\/(?P<container_name>[^\._]+)\/(?P<restart_count>\d+)\.log$'
        parse_from: attributes["log.file.path"]
      # Rename attributes
      - type: move
        from: attributes.stream
        to: attributes["log.iostream"]
      - type: move
        from: attributes.container_name
        to: resource["k8s.container.name"]
      - type: move
        from: attributes.namespace
        to: resource["k8s.namespace.name"]
      - type: move
        from: attributes.pod_name
        to: resource["k8s.pod.name"]
      - type: move
        from: attributes.restart_count
        to: resource["k8s.container.restart_count"]
      - type: move
        from: attributes.uid
        to: resource["k8s.pod.uid"]
      # Clean up log body
      - type: move
        from: attributes.log
        to: body
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
{{- if index $config.service.pipelines "metrics/generic" }}
{{- $_ := set (index $config.service.pipelines "metrics/generic") "processors" (prepend (index (index $config.service.pipelines "metrics/generic") "processors") "k8sattributes" | uniq) }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "opentelemetry-collector.kubernetesAttributesConfig" -}}
processors:
  k8sattributes:
    passthrough: {{ .Values.presets.kubernetesAttributes.passthrough }}
    pod_association:
    - sources:
      - from: resource_attribute
        name: k8s.pod.ip
    - sources:
      - from: resource_attribute
        name: k8s.pod.uid
    - sources:
      - from: connection
    extract:
      metadata:
      {{ range $metadata := .Values.presets.kubernetesAttributes.extractMetadatas }}
        - {{ $metadata }}
      {{ end }}
{{- end }}
