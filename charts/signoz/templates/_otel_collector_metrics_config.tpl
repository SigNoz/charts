{{- define "blackexporterJob" -}}
- job_name: blackbox
  metrics_path: /probe
  params:
    module: [http_2xx]
  static_configs:
    - targets:
{{ toYaml .Values.otelCollectorMetrics.blackboxexporter.targets | indent 8 }}
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: endpoint
    - target_label: __address__
      replacement: my-release-prometheus-blackbox-exporter:9115
{{- end }}

{{- define "prometheus-receiver" -}}
prometheus:
  config:
    scrape_configs:
      - job_name: signoz-spanmetrics-collector
        scrape_interval: 60s
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels:
              - __meta_kubernetes_pod_annotation_apm_signoz_io_scrape
            action: keep
            regex: true
          - source_labels:
              - __meta_kubernetes_pod_annotation_apm_signoz_io_path
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels:
              - __meta_kubernetes_pod_ip
              - __meta_kubernetes_pod_annotation_apm_signoz_io_port
            action: replace
            separator: ':'
            target_label: __address__
          - target_label: job_name
            replacement: signoz-spanmetrics-collector
          - source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_name
            action: replace
            target_label: signoz_k8s_name
          - source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_instance
            action: replace
            target_label: signoz_k8s_instance
          - source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_component
            action: replace
            target_label: signoz_k8s_component
          - source_labels:
              - __meta_kubernetes_namespace
            action: replace
            target_label: k8s_namespace_name
          - source_labels:
              - __meta_kubernetes_pod_name
            action: replace
            target_label: k8s_pod_name
          - source_labels:
              - __meta_kubernetes_pod_uid
            action: replace
            target_label: k8s_pod_uid
          - source_labels:
              - __meta_kubernetes_pod_container_name
            action: replace
            target_label: k8s_container_name
          - source_labels:
              - __meta_kubernetes_pod_container_name
            regex: (.+)-init
            action: drop
          - source_labels:
              - __meta_kubernetes_pod_node_name
            action: replace
            target_label: k8s_node_name
          - source_labels:
              - __meta_kubernetes_pod_ready
            action: replace
            target_label: k8s_pod_ready
          - source_labels:
              - __meta_kubernetes_pod_phase
            action: replace
            target_label: k8s_pod_phase
      - job_name: generic-collector
        scrape_interval: 60s
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels:
              - __meta_kubernetes_pod_annotation_signoz_io_scrape
            action: keep
            regex: true
          - source_labels:
              - __meta_kubernetes_pod_annotation_signoz_io_path
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels:
              - __meta_kubernetes_pod_ip
              - __meta_kubernetes_pod_annotation_signoz_io_port
            action: replace
            separator: ':'
            target_label: __address__
          - target_label: job_name
            replacement: generic-collector
          - source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_name
            action: replace
            target_label: signoz_k8s_name
          - source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_instance
            action: replace
            target_label: signoz_k8s_instance
          - source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_component
            action: replace
            target_label: signoz_k8s_component
          - source_labels:
              - __meta_kubernetes_namespace
            action: replace
            target_label: k8s_namespace_name
          - source_labels:
              - __meta_kubernetes_pod_name
            action: replace
            target_label: k8s_pod_name
          - source_labels:
              - __meta_kubernetes_pod_uid
            action: replace
            target_label: k8s_pod_uid
          - source_labels:
              - __meta_kubernetes_pod_container_name
            action: replace
            target_label: k8s_container_name
          - source_labels:
              - __meta_kubernetes_pod_container_name
            regex: (.+)-init
            action: drop
          - source_labels:
              - __meta_kubernetes_pod_node_name
            action: replace
            target_label: k8s_node_name
          - source_labels:
              - __meta_kubernetes_pod_ready
            action: replace
            target_label: k8s_pod_ready
          - source_labels:
              - __meta_kubernetes_pod_phase
            action: replace
            target_label: k8s_pod_phase
    {{- if and .Values.otelCollectorMetrics.blackboxexporter.enabled (gt (len .Values.otelCollectorMetrics.blackboxexporter.targets) 0) }}
      {{- include "blackexporterJob" . | nindent 6 }}
    {{- end }}
{{- end }}

{{- define "otelCollectorMetrics" -}}
receivers:
  hostmetrics:
    collection_interval: 30s
    scrapers:
      cpu: {}
      load: {}
      memory: {}
      disk: {}
      filesystem: {}
      network: {}
{{- include "prometheus-receiver" . | nindent 2 }}
processors:
  # Batch processor config.
  # ref: https://github.com/open-telemetry/opentelemetry-collector/blob/main/processor/batchprocessor/README.md
  batch:
    send_batch_size: 10000
    timeout: 1s
  # Resource detection processor config.
  # ref: https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/resourcedetectionprocessor/README.md
  resourcedetection:
    # detectors: include ec2/eks for AWS, gce/gke for GCP and azure/aks for Azure
    # env detector included below adds custom labels using OTEL_RESOURCE_ATTRIBUTES envvar
    detectors:
      - env
      # - elastic_beanstalk
      # - eks
      # - ecs
      # - ec2
      # - gke
      # - gce
      # - azure
      # - heroku
      - system
    timeout: 2s
    system:
      hostname_sources: [dns, os]
  # Memory Limiter processor.
  # If set to null, will be overridden with values based on k8s resource limits.
  # ref: https://github.com/open-telemetry/opentelemetry-collector/blob/main/processor/memorylimiterprocessor/README.md
  memory_limiter: null
  # K8s Attribute processor config.
  # ref: https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/k8sattributesprocessor/README.md
  k8sattributes/hostmetrics:
    # -- Whether to detect the IP address of agents and add it as an attribute to all telemetry resources.
    # If set to true, Agents will not make any k8s API calls, do any discovery of pods or extract any metadata.
    passthrough: false
    # -- Filters can be used to limit each OpenTelemetry agent to query pods based on specific
    # selector to only dramatically reducing resource requirements for very large clusters.
    filter:
      # -- Restrict each OpenTelemetry agent to query pods running on the same node
      node_from_env_var: K8S_NODE_NAME
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
        - k8s.namespace.name
        - k8s.pod.name
        - k8s.pod.uid
        - k8s.pod.start_time
        - k8s.deployment.name
        - k8s.node.name
extensions:
  health_check:
    endpoint: 0.0.0.0:13133
  zpages:
    endpoint: localhost:55679
  pprof:
    endpoint: localhost:1777
exporters:
  clickhousemetricswrite:
    endpoint: tcp://${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}/?database=${CLICKHOUSE_DATABASE}&username=${CLICKHOUSE_USER}&password=${CLICKHOUSE_PASSWORD}
  clickhousemetricswrite/hostmetrics:
    endpoint: tcp://${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}/?database=${CLICKHOUSE_DATABASE}&username=${CLICKHOUSE_USER}&password=${CLICKHOUSE_PASSWORD}
    resource_to_telemetry_conversion:
      enabled: true
service:
  telemetry:
    metrics:
      address: 0.0.0.0:8888
  extensions: [health_check, zpages, pprof]
  pipelines:
    metrics:
      receivers: [prometheus]
      processors: [batch]
      exporters: [clickhousemetricswrite]
    metrics/hostmetrics:
      receivers: [hostmetrics]
      processors: [resourcedetection, k8sattributes/hostmetrics, batch]
      exporters: [clickhousemetricswrite/hostmetrics]
{{- end }}