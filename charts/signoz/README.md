# SigNoz

SigNoz is an open-source APM. It helps developers monitor their applications & troubleshoot problems,
an open-source alternative to DataDog, NewRelic, etc. Open source Application Performance Monitoring (APM)
& Observability tool.

### TL;DR;

```sh
helm repo add signoz https://charts.signoz.io
helm install -n platform --create-namespace "my-release" signoz/signoz
```

### Introduction

This chart bootstraps [SigNoz](https://signoz.io) cluster deployment on a
Kubernetes cluster using [Helm](https://helm.sh) package manager.

### Prerequisites

- Kubernetes 1.16+
- Helm 3.0+

### Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm repo add signoz https://charts.signoz.io
helm -n platform --create-namespace install "my-release" signoz/signoz
```

These commands deploy SigNoz on the Kubernetes cluster in the default configuration.
The [Configuration](#configuration) section lists the parameters that can be configured during installation:

> **Tip**: List all releases using `helm list`

### Uninstalling the chart

To uninstall/delete the `my-release` resources:

```bash
helm -n platform uninstall "my-release"
```

See the [Helm docs](https://helm.sh/docs/helm/helm_uninstall/) for documentation on the helm uninstall command.

The command above removes all the Kubernetes components associated
with the chart and deletes the release.

Deletion of the StatefulSet doesn't cascade to deleting associated PVCs. To delete them:

```bash
kubectl -n platform delete pvc --selector app.kubernetes.io/instance=my-release
```

Sometimes everything doesn't get properly removed. If that happens try deleting the namespace:

```bash
kubectl delete namespace platform
```


## Configuration

The following table lists the configurable parameters of the `signoz` chart and their default values.

|              Parameter                   |                             Description                                 |                     Default       |
| ---------------------------------------- | ----------------------------------------------------------------------- | --------------------------------- |
| `fullnameOverride`                       | SigNoz chart full name override (the release name is ignored)           | `""`                              |
| `queryService.name`                      | Query Service component name                                            | `query-service`                   |
| `queryService.image.registry`            | Query Service image registry name                                       | `docker.io`                       |
| `queryService.image.repository`          | Container image name                                                    | `signoz/query-service`            |
| `queryService.image.tag`                 | Container image tag                                                     | `0.7.1`                           |
| `queryService.image.pullPolicy`          | Container pull policy                                                   | `IfNotPresent`                    |
| `queryService.replicas`                  | Number of query-service nodes                                           | `1`                               |
| `queryService.initContainers.init.enabled`      | Query Service initContainer enabled                              | `true`                            |
| `queryService.initContainers.init.image.registry`   | Query Service initContainer registry name                    | `docker.io`                       |
| `queryService.initContainers.init.image.repository` | Query Service initContainer image name                       | `busybox`                         |
| `queryService.initContainers.init.image.tag`        | Query Service initContainer image tag                        | `1.35`                            |
| `queryService.initContainers.init.image.pullPolicy` | Query Service initContainer pull policy                      | `IfNotPresent`                    |
| `queryService.initContainers.init.command`      | Query Service initContainer command line to execute              | See `values.yaml` for defaults    |
| `queryService.configVars`                | Query Service configurations                                            | See `values.yaml` for defaults    |
| `queryService.imagePullSecrets`          | Reference to secrets to be used when pulling images                     | `[]`                              |
| `queryService.serviceAccount.create`     | Service account for query-service nodes enabled                         | `false`                           |
| `queryService.serviceAccount.annotations`    | Service account annotations                                         | `{}`                              |
| `queryService.serviceAccount.name`       | Name of the service account                                             | `{}`                              |
| `queryService.serviceAccount.name`       | Name of the service account                                             | `{}`                              |
| `queryService.resources`                 | Resources requests and limits                                           | See `values.yaml` for defaults    |
| `queryService.podSecurityContext`        | Pods security context                                                   | `{}`                              |
| `queryService.securityContext`           | Security context for query-service node                                 | `{}`                              |
| `queryService.service.type`              | Query Service service type                                              | `ClusterIP`                       |
| `queryService.service.port`              | Query Service service port                                              | `8080`                            |
| `queryService.ingress.enabled`           | Query Service ingress resource enabled                                  | `false`                           |
| `queryService.ingress.hosts`             | Query Service ingress virtual hosts                                     | See `values.yaml` for defaults    |
| `queryService.ingress.annotations`       | Query Service ingress annotations                                       | `nil`                             |
| `queryService.ingress.tls`               | Query Service ingress TLS settings                                      | `nil`                             |
| `queryService.nodeSelector`              | Node labels for query-service pod assignment                            | `{}`                              |
| `queryService.tolerations`               | Query Service tolerations                                               | `[]`                              |
| `queryService.nodeAffinity`              | Query Service affinity policy                                           | `{}`                              |
| `frontend.name`                          | Frontend component name                                                 | `frontend`                        |
| `frontend.image.registry`                | Frontend image registry name                                            | `docker.io`                       |
| `frontend.image.repository`              | Container image name                                                    | `signoz/frontend`                 |
| `frontend.image.tag`                     | Container image tag                                                     | `0.7.1`                           |
| `frontend.image.pullPolicy`              | Container pull policy                                                   | `IfNotPresent`                    |
| `frontend.replicas`                      | Number of query-service nodes                                           | `1`                               |
| `frontend.initContainers.init.enabled`   | Frontend initContainer enabled                                          | `true`                            |
| `frontend.initContainers.init.image.registry`   | Frontend initContainer registry name                             | `docker.io`                       |
| `frontend.initContainers.init.image.repository` | Frontend initContainer image name                                | `busybox`                         |
| `frontend.initContainers.init.image.tag`        | Frontend initContainer image tag                                 | `1.35`                            |
| `frontend.initContainers.init.image.pullPolicy` | Frontend initContainer pull policy                               | `IfNotPresent`                    |
| `frontend.initContainers.init.command`   | Frontend initContainer command line to execute                          | See `values.yaml` for defaults    |
| `frontend.imagePullSecrets`              | Reference to secrets to be used when pulling images                     | `[]`                              |
| `frontend.serviceAccount.create`         | Service account for query-service nodes enabled                         | `false`                           |
| `frontend.serviceAccount.annotations`    | Service account annotations                                             | `{}`                              |
| `frontend.serviceAccount.name`           | Name of the service account                                             | `{}`                              |
| `frontend.resources`                     | Resources requests and limits                                           | See `values.yaml` for defaults    |
| `frontend.podSecurityContext`            | Pods security context                                                   | `{}`                              |
| `frontend.securityContext`               | Security context for query-service node                                 | `{}`                              |
| `frontend.service.type`                  | Frontend service type                                                   | `ClusterIP`                       |
| `frontend.service.port`                  | Frontend service port                                                   | `3301`                            |
| `frontend.ingress.enabled`               | Frontend ingress resource enabled                                       | `false`                           |
| `frontend.ingress.hosts`                 | Frontend ingress virtual hosts                                          | See `values.yaml` for defaults    |
| `frontend.ingress.annotations`           | Frontend ingress annotations                                            | `nil`                             |
| `frontend.ingress.tls`                   | Frontend ingress TLS settings                                           | `nil`                             |
| `frontend.nodeSelector`                  | Node labels for frontend pod assignment                                 | `{}`                              |
| `frontend.tolerations`                   | Frontend tolerations                                                    | `[]`                              |
| `frontend.nodeAffinity`                  | Frontend affinity policy                                                | `{}`                              |
| `otelCollector.name`                     | Otel Collector component name                                           | `otel-collector`                  |
| `otelCollector.image.registry`           | Otel Collector image registry name                                      | `docker.io`                       |
| `otelCollector.image.repository`         | Container image name                                                    | `signoz/query-service`            |
| `otelCollector.image.tag`                | Container image tag                                                     | `0.43.0`                          |
| `otelCollector.image.pullPolicy`         | Container pull policy                                                   | `IfNotPresent`                    |
| `otelCollector.replicas`                 | Number of otel-collector nodes                                          | `1`                               |
| `otelCollector.serviceType`              | Otel Collector service type                                             | `ClusterIP`                       |
| `otelCollector.ports`                    | Lists of ports exposed by otel-collector service                        | See `values.yaml` for defaults    |
| `otelCollector.initContainers.init.enabled`    | Otel Collector initContainer enabled                              | `true`                            |
| `otelCollector.initContainers.init.image.registry`   | Otel Collector initContainer registry name                  | `docker.io`                       |
| `otelCollector.initContainers.init.image.repository` | Otel Collector initContainer image name                     | `busybox`                         |
| `otelCollector.initContainers.init.image.tag`        | Otel Collector initContainer image tag                      | `1.35`                            |
| `otelCollector.initContainers.init.image.pullPolicy` | Otel Collector initContainer pull policy                    | `IfNotPresent`                    |
| `otelCollector.initContainers.init.command`    | Otel Collector initContainer command line to execute              | See `values.yaml` for defaults    |
| `otelCollector.config`                         | Otel Collector configurations                                     | See `values.yaml` for defaults    |
| `otelCollector.imagePullSecrets`               | Reference to secrets to be used when pulling images               | `[]`                              |
| `otelCollector.serviceAccount.create`          | Service account for otel-collector nodes enabled                  | `false`                           |
| `otelCollector.serviceAccount.annotations`     | Service account annotations                                       | `{}`                              |
| `otelCollector.serviceAccount.name`      | Name of the service account                                             | `{}`                              |
| `otelCollector.resources`                | Resources requests and limits                                           | See `values.yaml` for defaults    |
| `otelCollector.livenessProbe`            | Otel Collector liveness probes                                          | See `values.yaml` for defaults    |
| `otelCollector.readinessProbe`           | Otel Collector readiness probes                                         | See `values.yaml` for defaults    |
| `otelCollector.customLivenessProbe`      | Custom liveness probes (if `otelCollector.livenessProbe` not enabled)   | `{}`                              |
| `otelCollector.customReadinessProbe`     | Custom readiness probes (if `otelCollector.readinessProbe` not enabled) | `{}`                              |
| `otelCollector.podSecurityContext`       | Pods security context                                                   | `{}`                              |
| `otelCollector.minReadySeconds`          | Minimum seconds for otel-collector pod to be ready without crashing     | `300`                             |
| `otelCollector.progressDeadlineSeconds`  | Seconds to wait for the deployment to progress before fail reporting    | `120`                             |
| `otelCollector.ballastSizeMib`           | Ballast memory size in Mib                                              | `683`                             |
| `otelCollectorMetrics.name`              | Otel Collector Metrics component name                                   | `otel-collector-metrics`          |
| `otelCollectorMetrics.image.registry`    | Otel Collector Metrics image registry name                              | `docker.io`                       |
| `otelCollectorMetrics.image.repository`  | Container image name                                                    | `signoz/otelcontribcol`           |
| `otelCollectorMetrics.image.tag`         | Container image tag                                                     | `0.43.0`                          |
| `otelCollectorMetrics.image.pullPolicy`  | Container pull policy                                                   | `IfNotPresent`                    |
| `otelCollectorMetrics.replicas`          | Number of otel-collector-metrics nodes                                  | `1`                               |
| `otelCollectorMetrics.serviceType`       | Otel Collector service metrics type                                     | `ClusterIP`                       |
| `otelCollectorMetrics.ports`                    | Lists of ports exposed by otel-collector-metrics service         | See `values.yaml` for defaults    |
| `otelCollectorMetrics.initContainers.init.enabled`    | Otel Collector Metrics initContainer enabled               | `true`                            |
| `otelCollectorMetrics.initContainers.init.image.registry`    | Otel Collector Metrics initContainer registry name  | `docker.io`                       |
| `otelCollectorMetrics.initContainers.init.image.repository`  | Otel Collector Metrics initContainer image name     | `busybox`                         |
| `otelCollectorMetrics.initContainers.init.image.tag`         | Otel Collector Metrics initContainer image tag      | `1.35`                            |
| `otelCollectorMetrics.initContainers.init.image.pullPolicy`  | Otel Collector Metrics initContainer pull policy    | `IfNotPresent`                    |
| `otelCollectorMetrics.initContainers.init.command`  | Otel Collector Metrics initContainer command line to execute | See `values.yaml` for defaults    |
| `otelCollectorMetrics.config`            | Otel Collector Metrics configurations                                   | See `values.yaml` for defaults    |
| `otelCollectorMetrics.imagePullSecrets`  | Reference to secrets to be used when pulling images                     | `[]`                              |
| `otelCollectorMetrics.serviceAccount.create`        | Service account for otel-collector-metrics nodes enabled     | `false`                           |
| `otelCollectorMetrics.serviceAccount.annotations`   | Service account annotations                                  | `{}`                              |
| `otelCollectorMetrics.serviceAccount.name`          | Name of the service account                                  | `{}`                              |
| `otelCollectorMetrics.resources`         | Resources requests and limits                                           | See `values.yaml` for defaults    |
| `otelCollectorMetrics.livenessProbe`     | Otel Collector Metrics liveness probes                                  | See `values.yaml` for defaults    |
| `otelCollectorMetrics.readinessProbe`    | Otel Collector Metrics readiness probes                                 | See `values.yaml` for defaults    |
| `otelCollectorMetrics.customLivenessProbe`    | Custom liveness probes (if `otelCollectorMetrics.livenessProbe` not enabled)   | `{}`                  |
| `otelCollectorMetrics.customReadinessProbe`   | Custom readiness probes (if `otelCollectorMetrics.readinessProbe` not enabled) | `{}`                  |
| `otelCollectorMetrics.minReadySeconds`          | Minimum seconds for otel-collector-metrics pod to be ready without crashing  | `300`                 |
| `otelCollectorMetrics.progressDeadlineSeconds`  | Seconds to wait for the deployment to progress before fail reporting   | `120`                       |
| `otelCollectorMetrics.ballastSizeMib`           | Ballast memory size in Mib                                             | `683`                       |
