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

| Parameter                                                   | Description                                                                                                | Default                        |
|-------------------------------------------------------------|------------------------------------------------------------------------------------------------------------|--------------------------------|
| `fullnameOverride`                                          | SigNoz chart full name override (the release name is ignored)                                              | `""`                           |
| `signoz.name`                                         | Query Service component name                                                                               | `signoz`                |
| `signoz.image.registry`                               | Query Service image registry name                                                                          | `docker.io`                    |
| `signoz.image.repository`                             | Container image name                                                                                       | `signoz/signoz`         |
| `signoz.image.tag`                                    | Container image tag                                                                                        | `0.64.0`                       |
| `signoz.image.pullPolicy`                             | Container pull policy                                                                                      | `IfNotPresent`                 |
| `signoz.replicaCount`                                 | Number of signoz nodes                                                                              | `1`                            |
| `signoz.initContainers.init.enabled`                  | Query Service initContainer enabled                                                                        | `true`                         |
| `signoz.initContainers.init.image.registry`           | Query Service initContainer registry name                                                                  | `docker.io`                    |
| `signoz.initContainers.init.image.repository`         | Query Service initContainer image name                                                                     | `busybox`                      |
| `signoz.initContainers.init.image.tag`                | Query Service initContainer image tag                                                                      | `1.35`                         |
| `signoz.initContainers.init.image.pullPolicy`         | Query Service initContainer pull policy                                                                    | `IfNotPresent`                 |
| `signoz.initContainers.init.command`                  | Query Service initContainer command line to execute                                                        | See `values.yaml` for defaults |
| `signoz.initContainers.init.resources`                | Resources requests and limits                                                                              | See `values.yaml` for defaults |
| `signoz.additionalEnvs`                               | Additional environment variables for signoz container                                               | `[]`                           |
| `signoz.configVars`                                   | Query Service configurations                                                                               | See `values.yaml` for defaults |
| `signoz.smtpVars.enabled`                             | Enable SMTP for user invitation. It will set `SMTP_ENABLED` when enabled.                                  | `false`                        |
| `signoz.smtpVars.existingSecret.fromKey`              | Name of key in secret to get value for `SMTP_FROM`. If empty, will not set the env variable.               | `""`                           | 
| `signoz.smtpVars.existingSecret.hostKey`              | Name of key in secret to get value for `SMTP_HOST`. If empty will not set the env variable.                | `""`                           | 
| `signoz.smtpVars.existingSecret.name`                 | Name fo the existing k8s secret to pick the values. Needed when one of the key for existing secret is set. | `""`                           | 
| `signoz.smtpVars.existingSecret.passwordKey`          | Name of key in secret to get value for `SMTP_PASSWORD`. If empty will not set the env variable.            | `""`                           | 
| `signoz.smtpVars.existingSecret.portKey`              | Name of key in secret to get value for `SMTP_PORT`. If empty will not set the env variable.                | `""`                           | 
| `signoz.smtpVars.existingSecret.usernameKey `         | Name of key in secret to get value for `SMTP_USERNAME`. If empty will not set the env variable.            | `""`                           | 
| `signoz.imagePullSecrets`                             | Reference to secrets to be used when pulling images                                                        | `[]`                           |
| `signoz.serviceAccount.create`                        | Service account for signoz nodes enabled                                                            | `true`                         |
| `signoz.serviceAccount.annotations`                   | Service account annotations                                                                                | `{}`                           |
| `signoz.serviceAccount.name`                          | Name of the service account                                                                                | `nil`                          |
| `signoz.resources`                                    | Resources requests and limits                                                                              | See `values.yaml` for defaults |
| `signoz.podSecurityContext`                           | Pods security context                                                                                      | `{}`                           |
| `signoz.securityContext`                              | Security context for signoz node                                                                    | `{}`                           |
| `signoz.service.annotations`                          | Service annotations                                                                                        | `{}`                           |
| `signoz.service.labels`                               | Service labels                                                                                             | `{}`                           |
| `signoz.service.type`                                 | Query Service service type                                                                                 | `ClusterIP`                    |
| `signoz.service.port`                                 | Query Service service port                                                                                 | `8080`                         |
| `signoz.service.internalPort`                         | Query Service service internal port                                                                        | `8085`                         |
| `signoz.livenessProbe`                                | Query Service liveness probes                                                                              | See `values.yaml` for defaults |
| `signoz.readinessProbe`                               | Query Service readiness probes                                                                             | See `values.yaml` for defaults |
| `signoz.customLivenessProbe`                          | Custom liveness probes (if `signoz.livenessProbe` not enabled)                                       | `{}`                           |
| `signoz.customReadinessProbe`                         | Custom readiness probes (if `signoz.readinessProbe` not enabled)                                     | `{}`                           |
| `signoz.ingress.enabled`                              | Query Service ingress resource enabled                                                                     | `false`                        |
| `signoz.ingress.className`                            | Query Service ingress class name                                                                           | `""`                           |
| `signoz.ingress.hosts`                                | Query Service ingress virtual hosts                                                                        | See `values.yaml` for defaults |
| `signoz.ingress.annotations`                          | Query Service ingress annotations                                                                          | `{}`                           |
| `signoz.ingress.tls`                                  | Query Service ingress TLS settings                                                                         | `[]`                           |
| `signoz.nodeSelector`                                 | Node labels for signoz pod assignment                                                               | `{}`                           |
| `signoz.tolerations`                                  | Query Service tolerations                                                                                  | `[]`                           |
| `signoz.nodeAffinity`                                 | Query Service affinity policy                                                                              | `{}`                           |
| `schemaMigrator.nodeSelector`                               | Node labels for schemaMigrator pod assignment                                                              | `{}`                           |
| `schemaMigrator.tolerations`                                | schemaMigrator tolerations                                                                                 | `[]`                           |
| `schemaMigrator.nodeAffinity`                               | schemaMigrator affinity policy                                                                             | `{}`                           |
| `schemaMigrator.initContainers.init.enabled`                | Schema migrator initContainer enabled                                                                      | `true`                         |
| `schemaMigrator.initContainers.init.image.registry`         | Schema migrator initContainer registry name                                                                | `docker.io`                    |
| `schemaMigrator.initContainers.init.image.repository`       | Schema migrator initContainer image name                                                                   | `busybox`                      |
| `schemaMigrator.initContainers.init.image.tag`              | Schema migrator initContainer image tag                                                                    | `1.35`                         |
| `schemaMigrator.initContainers.init.image.pullPolicy`       | Schema migrator initContainer pull policy                                                                  | `IfNotPresent`                 |
| `schemaMigrator.initContainers.init.command`                | Schema migrator initContainer command line to execute                                                      | See `values.yaml` for defaults |
| `schemaMigrator.initContainers.init.resources`              | Resources requests and limits                                                                              | See `values.yaml` for defaults |
| `otelCollector.name`                                        | Otel Collector component name                                                                              | `otel-collector`               |
| `otelCollector.image.registry`                              | Otel Collector image registry name                                                                         | `docker.io`                    |
| `otelCollector.image.repository`                            | Container image name                                                                                       | `signoz/signoz-otel-collector` |
| `otelCollector.image.tag`                                   | Container image tag                                                                                        | `0.111.16`                     |
| `otelCollector.image.pullPolicy`                            | Container pull policy                                                                                      | `IfNotPresent`                 |
| `otelCollector.replicaCount`                                | Number of otel-collector nodes                                                                             | `1`                            |
| `otelCollector.service.type`                                | Otel Collector service type                                                                                | `ClusterIP`                    |
| `otelCollector.service.annotations`                         | Service annotations                                                                                        | `{}`                           |
| `otelCollector.service.labels`                              | Service labels                                                                                             | `{}`                           |
| `otelCollector.ports`                                       | Lists of ports exposed by otel-collector service                                                           | See `values.yaml` for defaults |
| `otelCollector.additionalEnvs`                              | Additional environment variables for otel-collector container                                              | `[]`                           |
| `otelCollector.initContainers.init.enabled`                 | Otel Collector initContainer enabled                                                                       | `false`                        |
| `otelCollector.initContainers.init.image.registry`          | Otel Collector initContainer registry name                                                                 | `docker.io`                    |
| `otelCollector.initContainers.init.image.repository`        | Otel Collector initContainer image name                                                                    | `busybox`                      |
| `otelCollector.initContainers.init.image.tag`               | Otel Collector initContainer image tag                                                                     | `1.35`                         |
| `otelCollector.initContainers.init.image.pullPolicy`        | Otel Collector initContainer pull policy                                                                   | `IfNotPresent`                 |
| `otelCollector.initContainers.init.command`                 | Otel Collector initContainer command line to execute                                                       | See `values.yaml` for defaults |
| `otelCollector.initContainers.init.resources`               | Resources requests and limits                                                                              | See `values.yaml` for defaults |
| `otelCollector.config`                                      | Otel Collector configurations                                                                              | See `values.yaml` for defaults |
| `otelCollector.imagePullSecrets`                            | Reference to secrets to be used when pulling images                                                        | `[]`                           |
| `otelCollector.serviceAccount.create`                       | Service account for otel-collector nodes enabled                                                           | `true`                         |
| `otelCollector.serviceAccount.annotations`                  | Service account annotations                                                                                | `{}`                           |
| `otelCollector.serviceAccount.name`                         | Name of the service account                                                                                | `nil`                          |
| `otelCollector.resources`                                   | Resources requests and limits                                                                              | See `values.yaml` for defaults |
| `otelCollector.nodeSelector`                                | Node labels for Otel Collector pod assignment                                                              | `{}`                           |
| `otelCollector.tolerations`                                 | Otel Collector tolerations                                                                                 | `[]`                           |
| `otelCollector.nodeAffinity`                                | Otel Collector affinity policy                                                                             | `{}`                           |
| `otelCollector.livenessProbe`                               | Otel Collector liveness probes                                                                             | See `values.yaml` for defaults |
| `otelCollector.readinessProbe`                              | Otel Collector readiness probes                                                                            | See `values.yaml` for defaults |
| `otelCollector.customLivenessProbe`                         | Custom liveness probes (if `otelCollector.livenessProbe` not enabled)                                      | `{}`                           |
| `otelCollector.customReadinessProbe`                        | Custom readiness probes (if `otelCollector.readinessProbe` not enabled)                                    | `{}`                           |
| `otelCollector.extraVolumes`                                | Extra volumes to be added to the otel-collector pods                                                       | `[]`                           |
| `otelCollector.extraVolumeMounts`                           | Extra volume mounts to be added to the otel-collector pods                                                 | `[]`                           |
| `otelCollector.ingress.enabled`                             | Open Telemetry Collector ingress resource enabled                                                          | `false`                        |
| `otelCollector.ingress.className`                           | Open Telemetry Collector ingress class name                                                                | `""`                           |
| `otelCollector.ingress.hosts`                               | Open Telemetry Collector ingress virtual hosts                                                             | See `values.yaml` for defaults |
| `otelCollector.ingress.annotations`                         | Open Telemetry Collector ingress annotations                                                               | `{}`                           |
| `otelCollector.ingress.tls`                                 | Open Telemetry Collector ingress TLS settings                                                              | `[]`                           |
| `otelCollector.podSecurityContext`                          | Pods security context                                                                                      | `{}`                           |
| `otelCollector.minReadySeconds`                             | Minimum seconds for otel-collector pod to be ready without crashing                                        | `300`                          |