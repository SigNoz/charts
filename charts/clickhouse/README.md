# clickhouse

![Version: 24.1.17](https://img.shields.io/badge/Version-24.1.17-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 24.1.2](https://img.shields.io/badge/AppVersion-24.1.2-informational?style=flat-square)

A Helm chart for ClickHouse

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| SigNoz | <hello@signoz.io> | <https://signoz.io> |
| prashant-shahi | <prashant@signoz.io> | <https://prashantshahi.dev> |

## Source Code

* <https://github.com/SigNoz/charts>
* <https://github.com/ClickHouse/ClickHouse>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/bitnamicharts | zookeeper | 11.4.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalVolumeMounts | list | `[]` | Additional volume mounts for ClickHouse pod |
| additionalVolumes | list | `[]` | Additional volumes for ClickHouse pod |
| affinity | object | `{}` | Affinity settings for clickhouse pod |
| allowedNetworkIps | list | `["10.0.0.0/8","100.64.0.0/10","172.16.0.0/12","192.0.0.0/24","198.18.0.0/15","192.168.0.0/16"]` | An allowlist of IP addresses or network masks the ClickHouse user is allowed to access from. By default anything within a private network will be allowed. This should suffice for most use case although to expose to other networks you will need to update this setting.  Refs: - https://clickhouse.com/docs/en/operations/settings/settings-users/#user-namenetworks - https://en.wikipedia.org/wiki/Reserved_IP_addresses#IPv4 |
| annotations | object | `{}` | ClickHouse instance annotations. |
| clickhouseOperator.affinity | object | `{}` | Affinity settings for Clickhouse Operator pod |
| clickhouseOperator.annotations | object | `{}` | Clickhouse Operator deployment annotations |
| clickhouseOperator.asynchronousInsertLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the asynchronous_insert_log table. |
| clickhouseOperator.asynchronousInsertLog.ttl | int | `7` | The number of days to keep the data in the asynchronous_insert_log table. |
| clickhouseOperator.asynchronousMetricLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the asynchronous_metric_log table. |
| clickhouseOperator.asynchronousMetricLog.ttl | int | `30` | The number of days to keep the data in the asynchronous_metric_log table. |
| clickhouseOperator.backupLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the backup_log table. |
| clickhouseOperator.backupLog.ttl | int | `7` | The number of days to keep the data in the backup_log table. |
| clickhouseOperator.blobStorageLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the blob_storage_log table. |
| clickhouseOperator.blobStorageLog.ttl | int | `30` | The number of days to keep the data in the blob_storage_log table. |
| clickhouseOperator.configs.confdFiles | string | `nil` | ClickHouse Operator confd files |
| clickhouseOperator.crashLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the crash_log table. |
| clickhouseOperator.crashLog.ttl | int | `30` | The number of days to keep the data in the crash_log table. |
| clickhouseOperator.env | list | `[]` | Additional environment variables for Clickhouse Operator container. |
| clickhouseOperator.image | object | `{"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"altinity/clickhouse-operator","tag":"0.21.2"}` | Clickhouse Operator image |
| clickhouseOperator.image.pullPolicy | string | `"IfNotPresent"` | Clickhouse Operator image pull policy. |
| clickhouseOperator.image.registry | string | `"docker.io"` | Clickhouse Operator image registry to use. |
| clickhouseOperator.image.repository | string | `"altinity/clickhouse-operator"` | Clickhouse Operator image repository to use. |
| clickhouseOperator.image.tag | string | `"0.21.2"` | Clickhouse Operator image tag. |
| clickhouseOperator.imagePullSecrets | list | `[]` | Image Registry Secret Names for Clickhouse Operator. If global.imagePullSecrets is set as well, it will merged. |
| clickhouseOperator.labels | object | `{}` |  |
| clickhouseOperator.logger | object | `{"console":true,"count":10,"level":"information","size":"1000M"}` | Clickhouse logging config |
| clickhouseOperator.logger.console | bool | `true` | Whether to send log and errorlog to the console instead of file. To enable, set to 1 or true. |
| clickhouseOperator.logger.count | int | `10` | The number of archived log files that ClickHouse stores. |
| clickhouseOperator.logger.level | string | `"information"` | Logging level. Acceptable values: trace, debug, information, warning, error. |
| clickhouseOperator.logger.size | string | `"1000M"` | Size of the file. Applies to log and errorlog. Once the file reaches size, ClickHouse archives and renames it, and creates a new log file in its place. |
| clickhouseOperator.metricLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the metric_log table. |
| clickhouseOperator.metricLog.ttl | int | `30` | The number of days to keep the data in the metric_log table. |
| clickhouseOperator.metricsExporter | object | `{"env":[],"image":{"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"altinity/metrics-exporter","tag":"0.21.2"},"name":"metrics-exporter","service":{"annotations":{},"port":8888,"type":"ClusterIP"}}` | Metrics Exporter config. |
| clickhouseOperator.metricsExporter.env | list | `[]` | Additional environment variables for Metrics Exporter container. |
| clickhouseOperator.metricsExporter.image | object | `{"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"altinity/metrics-exporter","tag":"0.21.2"}` | Metrics Exporter image |
| clickhouseOperator.metricsExporter.image.pullPolicy | string | `"IfNotPresent"` | Metrics Exporter image pull policy. |
| clickhouseOperator.metricsExporter.image.registry | string | `"docker.io"` | Metrics Exporter image registry to use. |
| clickhouseOperator.metricsExporter.image.repository | string | `"altinity/metrics-exporter"` | Metrics Exporter image repository to use. |
| clickhouseOperator.metricsExporter.image.tag | string | `"0.21.2"` | Metrics Exporter image tag. |
| clickhouseOperator.metricsExporter.name | string | `"metrics-exporter"` | name of the component |
| clickhouseOperator.metricsExporter.service | object | `{"annotations":{},"port":8888,"type":"ClusterIP"}` | Metrics Exporter service |
| clickhouseOperator.metricsExporter.service.annotations | object | `{}` | Annotations to use by service associated to Metrics Exporter |
| clickhouseOperator.metricsExporter.service.port | int | `8888` | Metrics Exporter port |
| clickhouseOperator.metricsExporter.service.type | string | `"ClusterIP"` | Service Type: LoadBalancer (allows external access) or NodePort (more secure, no extra cost) |
| clickhouseOperator.name | string | `"operator"` | name of the component |
| clickhouseOperator.nodeSelector | object | `{}` | Node selector for settings for Clickhouse Operator pod |
| clickhouseOperator.partLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the part_log table. |
| clickhouseOperator.partLog.ttl | int | `30` | The number of days to keep the data in the part_log table. |
| clickhouseOperator.podAnnotations | object | `{}` | Clickhouse Operator pod(s) annotation. |
| clickhouseOperator.podLabels | object | `{}` |  |
| clickhouseOperator.podSecurityContext | object | `{}` | Clickhouse Operator pod-level security attributes and common container settings. |
| clickhouseOperator.priorityClassName | string | `""` | Clickhouse Operator priority class name |
| clickhouseOperator.processorsProfileLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the processors_profile_log table. |
| clickhouseOperator.processorsProfileLog.ttl | int | `7` | The number of days to keep the data in the processors_profile_log table. |
| clickhouseOperator.queryLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the query_log table. |
| clickhouseOperator.queryLog.ttl | int | `30` | The number of days to keep the data in the query_log table. |
| clickhouseOperator.queryThreadLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the query_thread_log table. |
| clickhouseOperator.queryThreadLog.ttl | int | `7` | The number of days to keep the data in the query_thread_log table. |
| clickhouseOperator.queryViewsLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the query_views_log table. |
| clickhouseOperator.queryViewsLog.ttl | int | `15` | The number of days to keep the data in the query_views_log table. |
| clickhouseOperator.secret.create | bool | `true` | Specifies whether a secret should be created |
| clickhouseOperator.secret.password | string | `"clickhouse_operator_password"` | User password for Clickhouse Operator |
| clickhouseOperator.secret.username | string | `"clickhouse_operator"` | User name for Clickhouse Operator |
| clickhouseOperator.service.enabled | bool | `true` |  |
| clickhouseOperator.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| clickhouseOperator.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| clickhouseOperator.serviceAccount.name | string | `nil` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| clickhouseOperator.serviceMonitor.additionalLabels | object | `{}` |  |
| clickhouseOperator.serviceMonitor.enabled | bool | `false` |  |
| clickhouseOperator.serviceMonitor.interval | string | `"30s"` |  |
| clickhouseOperator.serviceMonitor.metricRelabelings | list | `[]` |  |
| clickhouseOperator.serviceMonitor.relabelings | list | `[]` |  |
| clickhouseOperator.serviceMonitor.scrapeTimeout | string | `""` |  |
| clickhouseOperator.sessionLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the session_log table. |
| clickhouseOperator.sessionLog.ttl | int | `30` | The number of days to keep the data in the session_log table. |
| clickhouseOperator.tolerations | list | `[]` | Toleration labels for Clickhouse Operator pod assignment |
| clickhouseOperator.topologySpreadConstraints | list | `[]` | TopologySpreadConstraints describes how Clickhouse Operator pods ought to spread |
| clickhouseOperator.traceLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the trace_log table. |
| clickhouseOperator.traceLog.ttl | int | `7` | The number of days to keep the data in the trace_log table. |
| clickhouseOperator.version | string | `"0.21.2"` | Version of the operator |
| clickhouseOperator.zookeeperLog.flushInterval | int | `7500` | Time interval in milliseconds between flushes of the zookeeper_log table. |
| clickhouseOperator.zookeeperLog.ttl | int | `30` | The number of days to keep the data in the zookeeper_log table. |
| cluster | string | `"cluster"` | Clickhouse cluster |
| coldStorage.accessKey | string | `"<access_key_id>"` | Access Key for S3 or GCS |
| coldStorage.defaultKeepFreeSpaceBytes | string | `"10485760"` | Reserve free space on default disk (in bytes) Default value set below is 10MiB |
| coldStorage.enabled | bool | `false` | Whether to enable S3 or GCS cold storage |
| coldStorage.endpoint | string | `"https://<bucket-name>.s3-<region>.amazonaws.com/data/"` | Endpoint for S3 or GCS For S3, if region is us-east-1, endpoint can be https://s3.amazonaws.com         if region is not us-east-1, endpoint should be https://s3-<region>.amazonaws.com For GCS, endpoint should be https://storage.googleapis.com/<bucket-name>/data/ |
| coldStorage.role.annotations | object | `{"eks.amazonaws.com/role-arn":"arn:aws:iam::******:role/*****"}` | Annotations to use by service account associated to Clickhouse instance |
| coldStorage.role.enabled | bool | `false` | Whether to enable AWS IAM ARN role |
| coldStorage.secretAccess | string | `"<secret_access_key>"` | Secret Access Key for S3 or GCS |
| coldStorage.type | string | `"s3"` | Type of cold storage: s3 or gcs |
| customLivenessProbe | object | `{}` |  |
| customReadinessProbe | object | `{}` |  |
| customStartupProbe | object | `{}` |  |
| database | string | `"signoz_metrics"` | Clickhouse database |
| defaultProfiles | object | See `values.yaml` for defaults | Default user profile configuration for Clickhouse. !!! Please DO NOT override this !!! |
| defaultSettings | object | See `values.yaml` for defaults | Default settings configuration for ClickHouse. !!! Please DO NOT override this !!! |
| enabled | bool | `true` | Whether to install clickhouse. If false, `clickhouse.host` must be set |
| externalZookeeper | object | `{}` | URL for external zookeeper. |
| extraContainers | list | `[]` | Extra containers for ClickHouse pod |
| files | object | `{}` | Clickhouse configuration files.  Refs: - https://clickhouse.com/docs/en/operations/configuration-files/ - https://github.com/Altinity/clickhouse-operator/blob/master/docs/chi-examples/05-settings-05-files-nested.yaml |
| fullnameOverride | string | `""` | Fullname override for clickhouse |
| global.cloud | string | `"other"` | Kubernetes cluster cloud provider along with distribution if any. example: `aws`, `azure`, `gcp`, `gcp/autogke`, `hcloud`, `other` Based on the cloud, storage class for the persistent volume is selected. When set to 'aws' or 'gcp' along with `installCustomStorageClass` enabled, then new expandible storage class is created. |
| global.clusterDomain | string | `"cluster.local"` | Kubernetes cluster domain It is used only when components are installed in different namespace |
| global.imagePullSecrets | list | `[]` | Global Image Pull Secrets |
| global.imageRegistry | string | `nil` | Overrides the Docker registry globally for all images |
| global.storageClass | string | `nil` | Overrides the storage class for all PVC with persistence enabled. If not set, the default storage class is used. If set to "-", storageClassName: "", which disables dynamic provisioning |
| image | object | `{"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"clickhouse/clickhouse-server","tag":"24.1.2-alpine"}` | Clickhouse image |
| image.pullPolicy | string | `"IfNotPresent"` | Clickhouse image pull policy. |
| image.registry | string | `"docker.io"` | Clickhouse image registry to use. |
| image.repository | string | `"clickhouse/clickhouse-server"` | Clickhouse image repository to use. |
| image.tag | string | `"24.1.2-alpine"` | Clickhouse image tag. Note: SigNoz does not support all versions of ClickHouse. Please override the default only if you know what you are doing. |
| imagePullSecrets | list | `[]` | Image Registry Secret Names for ClickHouse. If global.imagePullSecrets is set as well, it will merged. |
| initContainers | object | See `values.yaml` for defaults | Clickhouse init container to copy histogramQuantile UDF |
| installCustomStorageClass | bool | `false` | When the `installCustomStorageClass` is enabled with `cloud` set as `gcp` or `aws`, it creates custom storage class with volume expansion permission.  |
| labels | object | `{}` |  |
| layout | object | `{"replicasCount":1,"shardsCount":1}` | Clickhouse cluster layout. (Experimental, use at own risk) For a full list of options, see https://github.com/Altinity/clickhouse-operator/blob/master/docs/custom_resource_explained.md section on clusters and layouts. |
| livenessProbe.enabled | bool | `true` |  |
| livenessProbe.failureThreshold | int | `10` |  |
| livenessProbe.initialDelaySeconds | int | `60` |  |
| livenessProbe.path | string | `"/ping"` |  |
| livenessProbe.periodSeconds | int | `3` |  |
| livenessProbe.port | string | `"http"` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.timeoutSeconds | int | `1` |  |
| logDatabase | string | `"signoz_logs"` | Clickhouse log database (SigNoz Logs) |
| logs.system.config | object | `{"exporters":{"otlp":{"endpoint":"${env:K8S_HOST_IP}:4317","retry_on_failure":{"enabled":true,"initial_interval":"2s","max_elapsed_time":"15s","max_interval":"5s"},"sending_queue":{"enabled":false},"tls":{"insecure":true,"insecure_skip_verify":true}}},"extensions":{"health_check":{"endpoint":"0.0.0.0:13133"}},"processors":{"batch":{"send_batch_max_size":25000,"send_batch_size":20000,"timeout":"1s"},"resourcedetection":{"detectors":["env"]}},"receivers":{"clickhousesystemtablesreceiver":{"dsn":"tcp://localhost:9000","query_log_scrape_config":{"min_scrape_delay_seconds":10,"scrape_interval_seconds":30}}},"service":{"extensions":["health_check"],"pipelines":{"logs":{"exporters":["otlp"],"processors":["resourcedetection","batch"],"receivers":["clickhousesystemtablesreceiver"]}},"telemetry":{"logs":{"encoding":"json"},"metrics":{"address":"0.0.0.0:8888"}}}}` | Config of the opentelemetry collector |
| logs.system.enabled | bool | `false` | Enable collection of system table entries as logs |
| logs.system.image.pullPolicy | string | `"IfNotPresent"` |  |
| logs.system.image.pullSecrets | list | `[]` |  |
| logs.system.image.registry | string | `"docker.io"` |  |
| logs.system.image.repository | string | `"signoz/signoz-otel-collector"` |  |
| logs.system.image.tag | string | `"0.111.16"` |  |
| name | string | `"clickhouse"` | Name of the clickhouse component |
| nameOverride | string | `""` | Name override for clickhouse |
| namespace | string | `""` | Which namespace to install clickhouse and `clickhouse-operator` to (defaults to namespace chart is installed to) |
| nodeSelector | object | `{}` | Node selector for settings for clickhouse pod |
| password | string | `"27ff0399-0d3a-4bd8-919d-17c2181e6fb9"` | Clickhouse password |
| persistence.accessModes | list | `["ReadWriteOnce"]` | Access Modes for persistent volume |
| persistence.enabled | bool | `true` | Enable data persistence using PVC. |
| persistence.existingClaim | string | `""` | Use a manually managed Persistent Volume and Claim. If defined, PVC must be created manually before volume will be bound.  |
| persistence.size | string | `"20Gi"` | Persistent Volume size |
| persistence.storageClass | string | `nil` | Persistent Volume Storage Class to use. If defined, `storageClassName: <storageClass>`. If set to "-", `storageClassName: ""`, which disables dynamic provisioning If undefined (the default) or set to `null`, no storageClassName spec is set, choosing the default provisioner.  |
| podAnnotations | object | `{}` | ClickHouse pod(s) annotation. |
| podDistribution | list | `[]` | Topologies on how to distribute the ClickHouse pod. Possible values can be found here: https://github.com/Altinity/clickhouse-operator/blob/1414503921da3ae475eb6f9a296d3475a6993768/docs/chi-examples/99-clickhouseinstallation-max.yaml#L428-L481 |
| podLabels | object | `{}` |  |
| priorityClassName | string | `""` | Clickhouse priority class name |
| profiles | object | `{}` | Clickhouse user profile configuration. You can use this to override profile settings, for example `default/max_memory_usage: 40000000000` or `default/max_concurrent_queries: 200`  For the full list of settings, see: - https://clickhouse.com/docs/en/operations/settings/settings-profiles/ - https://clickhouse.com/docs/en/operations/settings/settings/  |
| readinessProbe.enabled | bool | `true` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.initialDelaySeconds | int | `10` |  |
| readinessProbe.path | string | `"/ping"` |  |
| readinessProbe.periodSeconds | int | `3` |  |
| readinessProbe.port | string | `"http"` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.timeoutSeconds | int | `1` |  |
| replicasCount | int | `1` | Clickhouse cluster replicas |
| resources | object | See `values.yaml` for defaults | Configure resource requests and limits. Update according to your own use case as these values might not be suitable for your workload. Ref: http://kubernetes.io/docs/user-guide/compute-resources/  |
| secure | bool | `false` | Whether to use TLS connection connecting to ClickHouse |
| securityContext | object | `{"enabled":true,"fsGroup":101,"fsGroupChangePolicy":"OnRootMismatch","runAsGroup":101,"runAsUser":101}` | Security context for Clickhouse node |
| service.annotations | object | `{}` | Annotations to use by service associated to Clickhouse instance |
| service.httpPort | int | `8123` | Clickhouse HTTP port |
| service.tcpPort | int | `9000` | Clickhouse TCP port |
| service.type | string | `"ClusterIP"` | Service Type: LoadBalancer (allows external access) or NodePort (more secure, no extra cost) |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `nil` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| settings | object | `{}` | ClickHouse settings configuration. You can use this to override settings, for example `prometheus/port: 9363` For the full list of settings, see: - https://clickhouse.com/docs/en/operations/settings/settings/ |
| shardsCount | int | `1` | Clickhouse cluster shards |
| startupProbe.enabled | bool | `true` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.initialDelaySeconds | int | `30` |  |
| startupProbe.path | string | `"/ping"` |  |
| startupProbe.periodSeconds | int | `10` |  |
| startupProbe.port | string | `"http"` |  |
| startupProbe.successThreshold | int | `1` |  |
| startupProbe.timeoutSeconds | int | `5` |  |
| templates | object | `{"volumeClaimTemplates":[]}` | Custom volume claim templates for ClickHouse pod This is only used when persistence.enabled is false |
| tolerations | list | `[]` | Toleration labels for clickhouse pod assignment |
| topologySpreadConstraints | list | `[]` | TopologySpreadConstraints describes how clickhouse pods ought to spread |
| traceDatabase | string | `"signoz_traces"` | Clickhouse trace database (SigNoz Traces) |
| user | string | `"admin"` | Clickhouse user |
| verify | bool | `false` | Whether to verify TLS certificate on connection to ClickHouse |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
