# signoz

![Version: 0.0.13](https://img.shields.io/badge/Version-0.0.13-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.8.0](https://img.shields.io/badge/AppVersion-0.8.0-informational?style=flat-square)

SigNoz Observability Platform Helm Chart

**Homepage:** <https://signoz.io/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| signoz | <hello@signoz.io> | <https://signoz.io> |
| prashant | <prashant@signoz.io> | <https://prashantshahi.dev> |

## Source Code

* <https://github.com/signoz/charts/>
* <https://github.com/signoz/signoz>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://signoz.github.io/charts | clickhouse | 16.0.5 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` |  |
| clickhouse.service.httpPort | int | `8123` |  |
| clickhouse.service.tcpPort | int | `9000` |  |
| clickhouse.enabled | bool | `true` | Whether to install clickhouse. If false, `clickhouse.host` must be set |
| clickhouse.namespace | string | `nil` | Which namespace to install clickhouse and the `clickhouse-operator` to (defaults to namespace chart is installed to) |
| clickhouse.cluster | string | `"cluster"` | Clickhouse cluster |
| clickhouse.database | string | `"signoz_metrics"` | Clickhouse database (SigNoz Metrics) |
| clickhouse.traceDatabase | string | `"signoz_traces"` | Clickhouse trace database (SigNoz Traces) |
| clickhouse.user | string | `"admin"` | Clickhouse user |
| clickhouse.password | string | `"27ff0399-0d3a-4bd8-919d-17c2181e6fb9"` | Clickhouse password |
| clickhouse.shardsCount | int | `1` | Clickhouse cluster shards |
| clickhouse.replicasCount | int | `1` | Clickhouse cluster replicas |
| clickhouse.image | object | `{"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"yandex/clickhouse-server","tag":"21.12.3.32"}` | Clickhouse image |
| clickhouse.image.registry | string | `"docker.io"` | Clickhouse image registry to use. |
| clickhouse.image.repository | string | `"yandex/clickhouse-server"` | Clickhouse image repository to use. |
| clickhouse.image.tag | string | `"21.12.3.32"` | Clickhouse image tag to use (example: `21.8`).    SigNoz is not always tested with latest version of ClickHouse.    Only if you know what you are doing, proceed with overriding. |
| clickhouse.image.pullPolicy | string | `"IfNotPresent"` | Clickhouse image pull policy. |
| clickhouse.secure | bool | `false` | Whether to use TLS connection connecting to ClickHouse |
| clickhouse.verify | bool | `false` | Whether to verify TLS certificate on connection to ClickHouse |
| clickhouse.tolerations | list | `[]` | Toleration labels for clickhouse pod assignment |
| clickhouse.affinity | object | `{}` | Affinity settings for clickhouse pod |
| clickhouse.resources | object | `{}` | Clickhouse resource requests/limits. See more at http://kubernetes.io/docs/user-guide/compute-resources/ |
| clickhouse.securityContext.enabled | bool | `true` |  |
| clickhouse.securityContext.runAsUser | int | `101` |  |
| clickhouse.securityContext.runAsGroup | int | `101` |  |
| clickhouse.securityContext.fsGroup | int | `101` |  |
| clickhouse.serviceType | string | `"ClusterIP"` | Service Type: LoadBalancer (allows external access) or NodePort (more secure, no extra cost) |
| clickhouse.useNodeSelector | bool | `false` | If enabled, operator will prefer k8s nodes with tag `clickhouse:true` |
| clickhouse.persistence.enabled | bool | `true` | Enable data persistence using PVC. |
| clickhouse.persistence.existingClaim | string | `""` | Use a manually managed Persistent Volume and Claim.    If defined, PVC must be created manually before volume will be bound. |
| clickhouse.persistence.size | string | `"20Gi"` | Persistent Volume size |
| clickhouse.profiles | object | `{}` |  |
| clickhouse.defaultProfiles.default/allow_experimental_window_functions | string | `"1"` |  |
| clickhouse.installCustomStorageClass | bool | `false` |  |
| clickhouse.coldStorage.enabled | bool | `false` |  |
| clickhouse.coldStorage.defaultKeepFreeSpaceBytes | string | `"10485760"` |  |
| clickhouse.coldStorage.endpoint | string | `"https://<bucket-name>.s3.amazonaws.com/data/"` |  |
| clickhouse.coldStorage.role.enabled | bool | `false` |  |
| clickhouse.coldStorage.role.annotations."eks.amazonaws.com/role-arn" | string | `"arn:aws:iam::******:role/*****"` |  |
| clickhouse.coldStorage.accessKey | string | `"<access_key_id>"` |  |
| clickhouse.coldStorage.secretAccess | string | `"<secret_access_key>"` |  |
| clickhouse.clickhouseOperator.nodeSelector | object | `{}` |  |
| externalClickhouse.host | string | `nil` | Host of the external cluster. |
| externalClickhouse.cluster | string | `"cluster"` | Name of the external cluster to run DDL queries on. |
| externalClickhouse.database | string | `"signoz_metrics"` | Database name for the external cluster |
| externalClickhouse.traceDatabase | string | `"signoz_traces"` | Clickhouse trace database (SigNoz Traces) |
| externalClickhouse.user | string | `""` | User name for the external cluster to connect to the external cluster as |
| externalClickhouse.password | string | `""` | Password for the cluster. Ignored if existingClickhouse.existingSecret is set |
| externalClickhouse.existingSecret | string | `nil` | Name of an existing Kubernetes secret object containing the password |
| externalClickhouse.existingSecretPasswordKey | string | `nil` | Name of the key pointing to the password in your Kubernetes secret |
| externalClickhouse.secure | bool | `false` | Whether to use TLS connection connecting to ClickHouse |
| externalClickhouse.verify | bool | `false` | Whether to verify TLS connection connecting to ClickHouse |
| externalClickhouse.httpPort | int | `8123` | HTTP port of Clickhouse |
| externalClickhouse.tcpPort | int | `9000` | TCP port of Clickhouse |
| queryService.name | string | `"query-service"` |  |
| queryService.replicaCount | int | `1` |  |
| queryService.image.registry | string | `"docker.io"` |  |
| queryService.image.repository | string | `"signoz/query-service"` |  |
| queryService.image.tag | string | `"0.8.0"` |  |
| queryService.image.pullPolicy | string | `"IfNotPresent"` |  |
| queryService.imagePullSecrets | list | `[]` |  |
| queryService.serviceAccount.create | bool | `true` |  |
| queryService.serviceAccount.annotations | object | `{}` |  |
| queryService.serviceAccount.name | string | `nil` |  |
| queryService.initContainers.init.enabled | bool | `true` |  |
| queryService.initContainers.init.image.registry | string | `"docker.io"` |  |
| queryService.initContainers.init.image.repository | string | `"busybox"` |  |
| queryService.initContainers.init.image.tag | float | `1.35` |  |
| queryService.initContainers.init.image.pullPolicy | string | `"IfNotPresent"` |  |
| queryService.initContainers.init.command.delay | int | `5` |  |
| queryService.initContainers.init.command.endpoint | string | `"/ping"` |  |
| queryService.initContainers.init.command.waitMessage | string | `"waiting for clickhouseDB"` |  |
| queryService.initContainers.init.command.doneMessage | string | `"clickhouse ready, starting query service now"` |  |
| queryService.configVars.storage | string | `"clickhouse"` |  |
| queryService.configVars.goDebug | string | `"netdns=go"` |  |
| queryService.configVars.telemetryEnabled | bool | `true` |  |
| queryService.configVars.deploymentType | string | `"kubernetes-helm"` |  |
| queryService.podSecurityContext | object | `{}` |  |
| queryService.securityContext | object | `{}` |  |
| queryService.service.type | string | `"ClusterIP"` |  |
| queryService.service.port | int | `8080` |  |
| queryService.ingress.enabled | bool | `false` |  |
| queryService.ingress.annotations | object | `{}` |  |
| queryService.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| queryService.ingress.hosts[0].paths | list | `[]` |  |
| queryService.ingress.tls | list | `[]` |  |
| queryService.resources.requests.cpu | string | `"200m"` |  |
| queryService.resources.requests.memory | string | `"300Mi"` |  |
| queryService.resources.limits.cpu | string | `"750m"` |  |
| queryService.resources.limits.memory | string | `"1000Mi"` |  |
| queryService.nodeSelector | object | `{}` |  |
| queryService.tolerations | list | `[]` |  |
| queryService.affinity | object | `{}` |  |
| frontend.name | string | `"frontend"` |  |
| frontend.replicaCount | int | `1` |  |
| frontend.image.registry | string | `"docker.io"` |  |
| frontend.image.repository | string | `"signoz/frontend"` |  |
| frontend.image.tag | string | `"0.8.0"` |  |
| frontend.image.pullPolicy | string | `"IfNotPresent"` |  |
| frontend.imagePullSecrets | list | `[]` |  |
| frontend.serviceAccount.create | bool | `true` |  |
| frontend.serviceAccount.annotations | object | `{}` |  |
| frontend.serviceAccount.name | string | `nil` |  |
| frontend.initContainers.init.enabled | bool | `true` |  |
| frontend.initContainers.init.image.registry | string | `"docker.io"` |  |
| frontend.initContainers.init.image.repository | string | `"busybox"` |  |
| frontend.initContainers.init.image.tag | float | `1.35` |  |
| frontend.initContainers.init.image.pullPolicy | string | `"IfNotPresent"` |  |
| frontend.initContainers.init.command.delay | int | `5` |  |
| frontend.initContainers.init.command.endpoint | string | `"/api/v1/version"` |  |
| frontend.initContainers.init.command.waitMessage | string | `"waiting for query-service"` |  |
| frontend.initContainers.init.command.doneMessage | string | `"clickhouse ready, starting frontend now"` |  |
| frontend.configVars | object | `{}` |  |
| frontend.podSecurityContext | object | `{}` |  |
| frontend.securityContext | object | `{}` |  |
| frontend.service.type | string | `"ClusterIP"` |  |
| frontend.service.port | int | `3301` |  |
| frontend.ingress.enabled | bool | `false` |  |
| frontend.ingress.annotations | object | `{}` |  |
| frontend.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| frontend.ingress.hosts[0].paths | list | `[]` |  |
| frontend.ingress.tls | list | `[]` |  |
| frontend.resources.requests.cpu | string | `"100m"` |  |
| frontend.resources.requests.memory | string | `"100Mi"` |  |
| frontend.resources.limits.cpu | string | `"200m"` |  |
| frontend.resources.limits.memory | string | `"200Mi"` |  |
| frontend.nodeSelector | object | `{}` |  |
| frontend.tolerations | list | `[]` |  |
| frontend.affinity | object | `{}` |  |
| alertmanager.name | string | `"alertmanager"` |  |
| alertmanager.replicaCount | int | `1` |  |
| alertmanager.image.registry | string | `"docker.io"` |  |
| alertmanager.image.repository | string | `"signoz/alertmanager"` |  |
| alertmanager.image.pullPolicy | string | `"IfNotPresent"` |  |
| alertmanager.image.tag | string | `"0.23.0-0.1"` |  |
| alertmanager.command | list | `[]` |  |
| alertmanager.extraArgs | object | `{}` |  |
| alertmanager.imagePullSecrets | list | `[]` |  |
| alertmanager.service.annotations | object | `{}` |  |
| alertmanager.service.type | string | `"ClusterIP"` |  |
| alertmanager.service.port | int | `9093` |  |
| alertmanager.serviceAccount.create | bool | `true` |  |
| alertmanager.serviceAccount.annotations | object | `{}` |  |
| alertmanager.serviceAccount.name | string | `nil` |  |
| alertmanager.initContainers.init.enabled | bool | `true` |  |
| alertmanager.initContainers.init.image.registry | string | `"docker.io"` |  |
| alertmanager.initContainers.init.image.repository | string | `"busybox"` |  |
| alertmanager.initContainers.init.image.tag | float | `1.35` |  |
| alertmanager.initContainers.init.image.pullPolicy | string | `"IfNotPresent"` |  |
| alertmanager.initContainers.init.command.delay | int | `5` |  |
| alertmanager.initContainers.init.command.endpoint | string | `"/api/v1/version"` |  |
| alertmanager.initContainers.init.command.waitMessage | string | `"waiting for query-service"` |  |
| alertmanager.initContainers.init.command.doneMessage | string | `"clickhouse ready, starting alertmanager now"` |  |
| alertmanager.podSecurityContext.fsGroup | int | `65534` |  |
| alertmanager.dnsConfig | object | `{}` |  |
| alertmanager.securityContext.runAsUser | int | `65534` |  |
| alertmanager.securityContext.runAsNonRoot | bool | `true` |  |
| alertmanager.securityContext.runAsGroup | int | `65534` |  |
| alertmanager.additionalPeers | list | `[]` |  |
| alertmanager.livenessProbe.httpGet.path | string | `"/"` |  |
| alertmanager.livenessProbe.httpGet.port | string | `"http"` |  |
| alertmanager.readinessProbe.httpGet.path | string | `"/"` |  |
| alertmanager.readinessProbe.httpGet.port | string | `"http"` |  |
| alertmanager.ingress.enabled | bool | `false` |  |
| alertmanager.ingress.className | string | `""` |  |
| alertmanager.ingress.annotations | object | `{}` |  |
| alertmanager.ingress.hosts[0].host | string | `"alertmanager.domain.com"` |  |
| alertmanager.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| alertmanager.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| alertmanager.ingress.tls | list | `[]` |  |
| alertmanager.resources.requests.cpu | string | `"100m"` |  |
| alertmanager.resources.requests.memory | string | `"100Mi"` |  |
| alertmanager.resources.limits.cpu | string | `"200m"` |  |
| alertmanager.resources.limits.memory | string | `"200Mi"` |  |
| alertmanager.nodeSelector | object | `{}` |  |
| alertmanager.tolerations | list | `[]` |  |
| alertmanager.affinity | object | `{}` |  |
| alertmanager.statefulSet.annotations | object | `{}` |  |
| alertmanager.podAnnotations | object | `{}` |  |
| alertmanager.podLabels | object | `{}` |  |
| alertmanager.podDisruptionBudget | object | `{}` |  |
| alertmanager.persistence.enabled | bool | `true` |  |
| alertmanager.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| alertmanager.persistence.size | string | `"100Mi"` |  |
| alertmanager.configmapReload.enabled | bool | `false` |  |
| alertmanager.configmapReload.name | string | `"configmap-reload"` |  |
| alertmanager.configmapReload.image.repository | string | `"jimmidyson/configmap-reload"` |  |
| alertmanager.configmapReload.image.tag | string | `"v0.5.0"` |  |
| alertmanager.configmapReload.image.pullPolicy | string | `"IfNotPresent"` |  |
| alertmanager.configmapReload.resources | object | `{}` |  |
| otelCollector.name | string | `"otel-collector"` |  |
| otelCollector.image.registry | string | `"docker.io"` |  |
| otelCollector.image.repository | string | `"signoz/otelcontribcol"` |  |
| otelCollector.image.tag | string | `"0.43.0-0.1"` |  |
| otelCollector.image.pullPolicy | string | `"Always"` |  |
| otelCollector.serviceType | string | `"ClusterIP"` |  |
| otelCollector.imagePullSecrets | list | `[]` |  |
| otelCollector.serviceAccount.create | bool | `true` |  |
| otelCollector.serviceAccount.annotations | object | `{}` |  |
| otelCollector.serviceAccount.name | string | `nil` |  |
| otelCollector.minReadySeconds | int | `5` |  |
| otelCollector.progressDeadlineSeconds | int | `120` |  |
| otelCollector.replicaCount | int | `1` |  |
| otelCollector.ballastSizeMib | int | `683` |  |
| otelCollector.initContainers.init.enabled | bool | `true` |  |
| otelCollector.initContainers.init.image.registry | string | `"docker.io"` |  |
| otelCollector.initContainers.init.image.repository | string | `"busybox"` |  |
| otelCollector.initContainers.init.image.tag | float | `1.35` |  |
| otelCollector.initContainers.init.image.pullPolicy | string | `"IfNotPresent"` |  |
| otelCollector.initContainers.init.command.delay | int | `5` |  |
| otelCollector.initContainers.init.command.endpoint | string | `"/ping"` |  |
| otelCollector.initContainers.init.command.waitMessage | string | `"waiting for clickhouseDB"` |  |
| otelCollector.initContainers.init.command.doneMessage | string | `"clickhouse ready, starting otel collector now"` |  |
| otelCollector.ports.zPages | int | `55679` |  |
| otelCollector.ports.otelGrpcReceiver | int | `4317` |  |
| otelCollector.ports.otelHttpReceiver | int | `4318` |  |
| otelCollector.ports.otelGrpcLegacyReceiver | int | `55680` |  |
| otelCollector.ports.otelHttpLegacyReceiver | int | `55681` |  |
| otelCollector.ports.jaegerGrpcReceiver | int | `14250` |  |
| otelCollector.ports.jaegerHttpReceiver | int | `14268` |  |
| otelCollector.ports.zipkinReceiver | int | `9411` |  |
| otelCollector.ports.queryingMetrics | int | `8888` |  |
| otelCollector.ports.prometheusExportedMetrics | int | `8889` |  |
| otelCollector.livenessProbe.enabled | bool | `false` |  |
| otelCollector.livenessProbe.port | int | `13133` |  |
| otelCollector.livenessProbe.path | string | `"/"` |  |
| otelCollector.livenessProbe.initialDelaySeconds | int | `5` |  |
| otelCollector.livenessProbe.periodSeconds | int | `10` |  |
| otelCollector.livenessProbe.timeoutSeconds | int | `5` |  |
| otelCollector.livenessProbe.failureThreshold | int | `6` |  |
| otelCollector.livenessProbe.successThreshold | int | `1` |  |
| otelCollector.readinessProbe.enabled | bool | `false` |  |
| otelCollector.readinessProbe.port | int | `13133` |  |
| otelCollector.readinessProbe.path | string | `"/"` |  |
| otelCollector.readinessProbe.initialDelaySeconds | int | `5` |  |
| otelCollector.readinessProbe.periodSeconds | int | `10` |  |
| otelCollector.readinessProbe.timeoutSeconds | int | `5` |  |
| otelCollector.readinessProbe.failureThreshold | int | `6` |  |
| otelCollector.readinessProbe.successThreshold | int | `1` |  |
| otelCollector.customLivenessProbe | object | `{}` |  |
| otelCollector.customReadinessProbe | object | `{}` |  |
| otelCollector.resources.requests.cpu | string | `"200m"` |  |
| otelCollector.resources.requests.memory | string | `"400Mi"` |  |
| otelCollector.resources.limits.cpu | string | `"1000m"` |  |
| otelCollector.resources.limits.memory | string | `"2Gi"` |  |
| otelCollector.nodeSelector | object | `{}` |  |
| otelCollector.tolerations | list | `[]` |  |
| otelCollector.affinity | object | `{}` |  |
| otelCollector.config.receivers.otlp/spanmetrics.protocols.grpc.endpoint | string | `"localhost:12345"` |  |
| otelCollector.config.receivers.otlp.protocols.grpc.endpoint | string | `"0.0.0.0:4317"` |  |
| otelCollector.config.receivers.otlp.protocols.http.endpoint | string | `"0.0.0.0:4318"` |  |
| otelCollector.config.receivers.jaeger.protocols.grpc.endpoint | string | `"0.0.0.0:14250"` |  |
| otelCollector.config.receivers.jaeger.protocols.thrift_http.endpoint | string | `"0.0.0.0:14268"` |  |
| otelCollector.config.receivers.hostmetrics.collection_interval | string | `"30s"` |  |
| otelCollector.config.receivers.hostmetrics.scrapers.cpu | object | `{}` |  |
| otelCollector.config.receivers.hostmetrics.scrapers.load | object | `{}` |  |
| otelCollector.config.receivers.hostmetrics.scrapers.memory | object | `{}` |  |
| otelCollector.config.receivers.hostmetrics.scrapers.disk | object | `{}` |  |
| otelCollector.config.receivers.hostmetrics.scrapers.filesystem | object | `{}` |  |
| otelCollector.config.receivers.hostmetrics.scrapers.network | object | `{}` |  |
| otelCollector.config.processors.batch.send_batch_size | int | `1000` |  |
| otelCollector.config.processors.batch.timeout | string | `"10s"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.metrics_exporter | string | `"prometheus"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[0] | string | `"100us"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[1] | string | `"1ms"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[2] | string | `"2ms"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[3] | string | `"6ms"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[4] | string | `"10ms"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[5] | string | `"50ms"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[6] | string | `"100ms"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[7] | string | `"250ms"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[8] | string | `"500ms"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[9] | string | `"1000ms"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[10] | string | `"1400ms"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[11] | string | `"2000ms"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[12] | string | `"5s"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[13] | string | `"10s"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[14] | string | `"20s"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[15] | string | `"40s"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.latency_histogram_buckets[16] | string | `"60s"` |  |
| otelCollector.config.processors.signozspanmetrics/prometheus.dimensions_cache_size | int | `10000` |  |
| otelCollector.config.extensions.health_check | object | `{}` |  |
| otelCollector.config.extensions.zpages | object | `{}` |  |
| otelCollector.config.exporters.clickhouse.datasource | string | `"tcp://${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}/?database=${CLICKHOUSE_TRACE_DATABASE}&username=${CLICKHOUSE_USER}&password=${CLICKHOUSE_PASSWORD}"` |  |
| otelCollector.config.exporters.clickhousemetricswrite.endpoint | string | `"tcp://${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}/?database=${CLICKHOUSE_DATABASE}&username=${CLICKHOUSE_USER}&password=${CLICKHOUSE_PASSWORD}"` |  |
| otelCollector.config.exporters.clickhousemetricswrite.resource_to_telemetry_conversion.enabled | bool | `true` |  |
| otelCollector.config.exporters.prometheus.endpoint | string | `"0.0.0.0:8889"` |  |
| otelCollector.config.service.extensions[0] | string | `"health_check"` |  |
| otelCollector.config.service.extensions[1] | string | `"zpages"` |  |
| otelCollector.config.service.pipelines.traces.receivers[0] | string | `"jaeger"` |  |
| otelCollector.config.service.pipelines.traces.receivers[1] | string | `"otlp"` |  |
| otelCollector.config.service.pipelines.traces.processors[0] | string | `"signozspanmetrics/prometheus"` |  |
| otelCollector.config.service.pipelines.traces.processors[1] | string | `"batch"` |  |
| otelCollector.config.service.pipelines.traces.exporters[0] | string | `"clickhouse"` |  |
| otelCollector.config.service.pipelines.metrics.receivers[0] | string | `"otlp"` |  |
| otelCollector.config.service.pipelines.metrics.receivers[1] | string | `"hostmetrics"` |  |
| otelCollector.config.service.pipelines.metrics.processors[0] | string | `"batch"` |  |
| otelCollector.config.service.pipelines.metrics.exporters[0] | string | `"clickhousemetricswrite"` |  |
| otelCollector.config.service.pipelines.metrics/spanmetrics.receivers[0] | string | `"otlp/spanmetrics"` |  |
| otelCollector.config.service.pipelines.metrics/spanmetrics.exporters[0] | string | `"prometheus"` |  |
| otelCollectorMetrics.name | string | `"otel-collector-metrics"` |  |
| otelCollectorMetrics.image.registry | string | `"docker.io"` |  |
| otelCollectorMetrics.image.repository | string | `"signoz/otelcontribcol"` |  |
| otelCollectorMetrics.image.tag | string | `"0.43.0-0.1"` |  |
| otelCollectorMetrics.image.pullPolicy | string | `"Always"` |  |
| otelCollectorMetrics.imagePullSecrets | list | `[]` |  |
| otelCollectorMetrics.serviceType | string | `"ClusterIP"` |  |
| otelCollectorMetrics.serviceAccount.create | bool | `true` |  |
| otelCollectorMetrics.serviceAccount.annotations | object | `{}` |  |
| otelCollectorMetrics.serviceAccount.name | string | `nil` |  |
| otelCollectorMetrics.minReadySeconds | int | `5` |  |
| otelCollectorMetrics.progressDeadlineSeconds | int | `120` |  |
| otelCollectorMetrics.replicaCount | int | `1` |  |
| otelCollectorMetrics.ballastSizeMib | int | `683` |  |
| otelCollectorMetrics.initContainers.init.enabled | bool | `true` |  |
| otelCollectorMetrics.initContainers.init.image.registry | string | `"docker.io"` |  |
| otelCollectorMetrics.initContainers.init.image.repository | string | `"busybox"` |  |
| otelCollectorMetrics.initContainers.init.image.tag | float | `1.35` |  |
| otelCollectorMetrics.initContainers.init.image.pullPolicy | string | `"IfNotPresent"` |  |
| otelCollectorMetrics.initContainers.init.command.delay | int | `5` |  |
| otelCollectorMetrics.initContainers.init.command.endpoint | string | `"/ping"` |  |
| otelCollectorMetrics.initContainers.init.command.waitMessage | string | `"waiting for clickhouseDB"` |  |
| otelCollectorMetrics.initContainers.init.command.doneMessage | string | `"clickhouse ready, starting otel collector metrics now"` |  |
| otelCollectorMetrics.ports.zPages | int | `55679` |  |
| otelCollectorMetrics.ports.otelGrpcReceiver | int | `4317` |  |
| otelCollectorMetrics.ports.otelHttpReceiver | int | `4318` |  |
| otelCollectorMetrics.ports.otelGrpcLegacyReceiver | int | `55680` |  |
| otelCollectorMetrics.ports.otelHttpLegacyReceiver | int | `55681` |  |
| otelCollectorMetrics.ports.jaegerGrpcReceiver | int | `14250` |  |
| otelCollectorMetrics.ports.jaegerHttpReceiver | int | `14268` |  |
| otelCollectorMetrics.ports.zipkinReceiver | int | `9411` |  |
| otelCollectorMetrics.ports.queryingMetrics | int | `8888` |  |
| otelCollectorMetrics.livenessProbe.enabled | bool | `false` |  |
| otelCollectorMetrics.livenessProbe.port | int | `13133` |  |
| otelCollectorMetrics.livenessProbe.path | string | `"/"` |  |
| otelCollectorMetrics.livenessProbe.initialDelaySeconds | int | `5` |  |
| otelCollectorMetrics.livenessProbe.periodSeconds | int | `10` |  |
| otelCollectorMetrics.livenessProbe.timeoutSeconds | int | `5` |  |
| otelCollectorMetrics.livenessProbe.failureThreshold | int | `6` |  |
| otelCollectorMetrics.livenessProbe.successThreshold | int | `1` |  |
| otelCollectorMetrics.readinessProbe.enabled | bool | `false` |  |
| otelCollectorMetrics.readinessProbe.port | int | `13133` |  |
| otelCollectorMetrics.readinessProbe.path | string | `"/"` |  |
| otelCollectorMetrics.readinessProbe.initialDelaySeconds | int | `5` |  |
| otelCollectorMetrics.readinessProbe.periodSeconds | int | `10` |  |
| otelCollectorMetrics.readinessProbe.timeoutSeconds | int | `5` |  |
| otelCollectorMetrics.readinessProbe.failureThreshold | int | `6` |  |
| otelCollectorMetrics.readinessProbe.successThreshold | int | `1` |  |
| otelCollectorMetrics.customLivenessProbe | object | `{}` |  |
| otelCollectorMetrics.customReadinessProbe | object | `{}` |  |
| otelCollectorMetrics.resources.requests.cpu | string | `"200m"` |  |
| otelCollectorMetrics.resources.requests.memory | string | `"400Mi"` |  |
| otelCollectorMetrics.resources.limits.cpu | string | `"1000m"` |  |
| otelCollectorMetrics.resources.limits.memory | string | `"2Gi"` |  |
| otelCollectorMetrics.nodeSelector | object | `{}` |  |
| otelCollectorMetrics.tolerations | list | `[]` |  |
| otelCollectorMetrics.affinity | object | `{}` |  |
| otelCollectorMetrics.config.receivers.otlp.protocols.grpc.endpoint | string | `"0.0.0.0:4317"` |  |
| otelCollectorMetrics.config.receivers.otlp.protocols.http.endpoint | string | `"0.0.0.0:4318"` |  |
| otelCollectorMetrics.config.receivers.prometheus.config.scrape_configs[0].job_name | string | `"otel-collector"` |  |
| otelCollectorMetrics.config.receivers.prometheus.config.scrape_configs[0].scrape_interval | string | `"30s"` |  |
| otelCollectorMetrics.config.receivers.prometheus.config.scrape_configs[0].static_configs[0].targets[0] | string | `"${OTEL_COLLECTOR_PROMETHEUS}"` |  |
| otelCollectorMetrics.config.processors.batch.send_batch_size | int | `1000` |  |
| otelCollectorMetrics.config.processors.batch.timeout | string | `"10s"` |  |
| otelCollectorMetrics.config.extensions.health_check | object | `{}` |  |
| otelCollectorMetrics.config.extensions.zpages | object | `{}` |  |
| otelCollectorMetrics.config.exporters.clickhousemetricswrite.endpoint | string | `"tcp://${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}/?database=${CLICKHOUSE_DATABASE}&username=${CLICKHOUSE_USER}&password=${CLICKHOUSE_PASSWORD}"` |  |
| otelCollectorMetrics.config.service.extensions[0] | string | `"health_check"` |  |
| otelCollectorMetrics.config.service.extensions[1] | string | `"zpages"` |  |
| otelCollectorMetrics.config.service.pipelines.metrics.receivers[0] | string | `"otlp"` |  |
| otelCollectorMetrics.config.service.pipelines.metrics.receivers[1] | string | `"prometheus"` |  |
| otelCollectorMetrics.config.service.pipelines.metrics.processors[0] | string | `"batch"` |  |
| otelCollectorMetrics.config.service.pipelines.metrics.exporters[0] | string | `"clickhousemetricswrite"` |  |

