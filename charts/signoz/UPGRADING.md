# Upgrading the SigNoz Helm Chart

This file lists what to change when you upgrade to each version of the SigNoz Helm Chart (`signoz`). The step-by-step upgrade guides are on signoz.io, linked from each version's section.

- [1.0.0](#100)

If you run into an issue during an upgrade, open a [GitHub issue](https://github.com/SigNoz/charts/issues) or ask in the [SigNoz Slack community](https://signoz.io/slack).

<a id="100"></a>
## 1.0.0

SigNoz Helm Chart 1.0.0 ships SigNoz v0.152.0 and makes ClickHouse Keeper the default coordination store for ClickHouse. It also moves the bundled PostgreSQL database onto its PersistentVolumeClaim (PVC) and upgrades the Altinity ClickHouse Operator to 0.27.4. This section covers upgrades from SigNoz Helm Chart 0.151.0 or earlier. The steps are in the [upgrade guide][guide].

> [!WARNING]
> SigNoz Helm Chart 1.0.0 has breaking changes. Read them in the [upgrade guide][guide] before you upgrade.

<a id="100-checklist"></a>
### Who needs to act

See [Who needs to act][guide-who] in the upgrade guide.

<a id="100-rollback"></a>
<a id="100-expect"></a>
<a id="100-stay-on-0151"></a>
<a id="100-ts-rollback-failed"></a>
### Rollback

The rollback steps are in the [upgrade guide][guide-rollback].

<a id="100-clickhouse"></a>
### ClickHouse

<a id="100-clickhouse-moved"></a>
#### Moved values

| Old key | New key | Note |
|---|---|---|
| `clickhouse.additionalVolumeMounts` | `clickhouse.extraVolumeMounts` | |
| `clickhouse.additionalVolumes` | `clickhouse.extraVolumes` | |
| `clickhouse.clickhouseOperator` | `altinity-clickhouse-operator` | The keys under it are renamed ([ClickHouse Operator](#100-operator)). |
| `clickhouse.customLivenessProbe` | `clickhouse.livenessProbe` | For a handler other than `httpGet`, such as `exec` or `tcpSocket`, also set `httpGet: null`. |
| `clickhouse.customReadinessProbe` | `clickhouse.readinessProbe` | For a handler other than `httpGet`, such as `exec` or `tcpSocket`, also set `httpGet: null`. |
| `clickhouse.customStartupProbe` | `clickhouse.startupProbe` | For a handler other than `httpGet`, such as `exec` or `tcpSocket`, also set `httpGet: null`. |
| `clickhouse.image.registry` | The registry prefix in `clickhouse.image.repository` | `repository: docker.io/clickhouse/clickhouse-server` |
| `clickhouse.initContainers.udf` | `clickhouse.udf` | `udf.enabled` and `udf.command`. `udf.image` is ignored because the download runs on `clickhouse.image`. |
| Your own `clickhouse.initContainers` entries | `clickhouse.extraInitContainers` | A list instead of a map. |
| `clickhouse.livenessProbe`, `readinessProbe`, `startupProbe` with `enabled`, `port` or `path` | The same keys, as probe objects | `httpGet: {path: /ping, port: http}`, or `null` for no probe. For another handler, also set `httpGet: null`. |
| `clickhouse.logs.system.image.registry` | The registry prefix in `clickhouse.logs.system.image.repository` | |
| `clickhouse.podAnnotations` | `clickhouse.pod.annotations` | |
| `clickhouse.podLabels` | `clickhouse.pod.labels` | |
| `clickhouse.securityContext` | `clickhouse.podSecurityContext` | Without `enabled`. |

<a id="100-clickhouse-defaults"></a>
#### Changed defaults

Set the old value to keep it.

| Key | Old value | New value |
|---|---|---|
| `clickhouse.logs.system.config.service.telemetry.metrics.address` | `0.0.0.0:8888` | Not set. See the OpenTelemetry Collector [internal telemetry](https://opentelemetry.io/docs/collector/internal-telemetry/) docs. |
| `clickhouse.logs.system.image.tag` | `0.111.16` | `v0.144.15` |
| `externalClickhouse.existingSecretPasswordKey` | `null` | `password` |

<a id="100-clickhouse-actions"></a>
#### Setup-specific actions

| If you | Do |
|---|---|
| Run ClickHouse in another namespace (`clickhouse.namespace`) | Also set `altinity-clickhouse-operator.namespaceOverride` to that namespace, or `watchNamespaces` with `rbac.namespaceScoped: false`. |
| Read the ClickHouse password from a Pod spec or the ClickHouseInstallation | Read it from Secret `<release>-clickhouse-credentials`, key `password` (`<fullnameOverride>-credentials` with `clickhouse.fullnameOverride`). |
| Use an external ClickHouse and read Secret `<release>-clickhouse-external`, key `clickhouse-password` | Read Secret `<release>-clickhouse-credentials`, key `password`. |
| Change `clickhouse.password`, `externalClickhouse.password` or `postgresql.auth.password` | Restart SigNoz, the SigNoz OTel Collector, and ClickHouse or PostgreSQL afterwards. A password change no longer restarts them. |
| Reference `CLICKHOUSE_HTTP_PORT` in your own configuration | Write the port number there instead. `clickhouse.service.httpPort` and `externalClickhouse.httpPort` no longer set the variable. |
| Set `clickhouse.logs.system.enabled: true` | Do not pin a `clickhouse.logs.system.image.tag` older than the default, and remove from `clickhouse.logs.system.config` the [components not included in SigNoz OTel Collector 0.144.15](#100-logs-components). |
| Scale ClickHouse down or rename it | Delete the remaining PVCs manually once you no longer need the data. The ClickHouse Operator now keeps them. |
| Set `externalClickhouse.secure: true` | If `externalClickhouse.tcpPort` serves TLS (usually 9440), add `secure=true` to the exporter data source names (DSNs) in `otelCollector.config`. Otherwise set `secure: false`. |
| Set `global.clusterDomain` | Check that it is your cluster's domain. It is now passed to ClickHouse. |

<a id="100-logs-components"></a>
Components not included in SigNoz OTel Collector 0.144.15:

- `ballastextension`
- `carbonexporter`
- `clickhousemetricsexporter`
- `clickhousemetricsexporterv2`
- `loggingexporter`
- `opencensusexporter`
- `opencensusreceiver`
- `routingprocessor`
- `sapmreceiver`

<a id="100-keeper"></a>
<a id="100-keeper-default"></a>
### ClickHouse Keeper and ZooKeeper

#### Coordination store

See [Step 1: Keep ZooKeeper for the upgrade][guide-store] in the upgrade guide.

<a id="100-keeper-moved"></a>
#### Moved values

| Old key | New key | Note |
|---|---|---|
| `clickhouse.zookeeper` | `zookeeper`, at the top level | With `enabled: true`. |
| `clickhouse.zookeeper.global.imageRegistry` | `zookeeper.image.registry`, and `zookeeper.volumePermissions.image.registry` for the volume-permissions init container | |
| `clickhouse.zookeeper.global.storageClass` | `zookeeper.persistence.storageClass` | |
| `zookeeper.global.imageRegistry` | `zookeeper.image.registry`, or `global.imageRegistry` | The old key is ignored without an error. |
| `zookeeper.global.storageClass` | `zookeeper.persistence.storageClass`, or `global.storageClass` | The old key is ignored without an error. |

<a id="100-keeper-defaults"></a>
#### Changed defaults

| Key | Old value | New value |
|---|---|---|
| `keeper.enabled` | Key did not exist | `true` |
| `zookeeper.enabled` | `true`, as `clickhouse.zookeeper.enabled` | `false` |
| `zookeeper.preAllocSize` | `65536` | `0` |

<a id="100-keeper-actions"></a>
#### Setup-specific actions

| If you | Do |
|---|---|
| Scrape Service `<release>-zookeeper-metrics` | Keep `zookeeper.enabled: true`. The Service is removed together with ZooKeeper. |

<a id="100-operator"></a>
### ClickHouse Operator

- The Altinity ClickHouse Operator is upgraded from 0.21.2 to 0.27.4.
- It is now installed from Altinity's Helm chart, `altinity-clickhouse-operator`.
- The upgrade brings the three ClickHouse CustomResourceDefinitions (CRDs) to 0.27.4 and adds the ClickHouse Keeper CRD.
- ClickHouse Operator 0.27.4 needs Kubernetes 1.25 or later, so SigNoz Helm Chart 1.0.0 does too.

<a id="100-operator-moved"></a>
#### Moved values

Altinity's Helm chart ignores the old key names, so rename each key you set:

| Old key | New key under `altinity-clickhouse-operator` |
|---|---|
| `clickhouse.clickhouseOperator.image.*` | `operator.image.*` |
| `clickhouse.clickhouseOperator.resources` | `operator.resources` |
| `clickhouse.clickhouseOperator.nodeSelector`, `tolerations`, `affinity` | The same keys, at the top level |
| `clickhouse.clickhouseOperator.metricsExporter.*` | `metrics.image.*`, `metrics.resources`, `metrics.env`. The Service port, type and annotations have no counterpart. |
| `clickhouse.clickhouseOperator.imagePullSecrets`, as names (`[ch-pull]`) | `imagePullSecrets`, as objects (`[{name: ch-pull}]`) |
| `clickhouse.clickhouseOperator.serviceMonitor.interval`, `scrapeTimeout`, `relabelings`, `metricRelabelings` | `serviceMonitor.clickhouseMetrics.*`, `serviceMonitor.operatorMetrics.*` |
| `clickhouse.clickhouseOperator.logger`, and each system log table's `ttl` and `flushInterval` | Files in `configs.configdFiles` ([System log tables](#100-operator-system-logs-detail)) |
| `clickhouse.clickhouseOperator.name`, `clickhouse.nameOverride`, `clickhouse.fullnameOverride` | `fullnameOverride`, set to the old ClickHouse Operator name to keep it ([Renamed objects](#100-objects)) |
| `clickhouse.clickhouseOperator.version`, `clickhouse.clickhouseOperator.service.enabled` | No replacement. Remove them. |

<a id="100-objects"></a>
#### Renamed objects

Update any selector, scrape configuration or reference of your own that uses these objects:

| Object | Old | New |
|---|---|---|
| ClickHouse Operator Pod labels and Deployment selector | `app.kubernetes.io/name: clickhouse`, `app.kubernetes.io/component: operator` | `app.kubernetes.io/name: clickhouse-operator`. The Pods keep `app.kubernetes.io/component: operator`. |
| Ports of Service `<release>-clickhouse-operator-metrics` | `<release>-clickhouse-operator-metrics` (8888) | `ch-metrics` (8888), `op-metrics` (9999) |
| ClickHouse Operator ServiceMonitor | `<release>-clickhouse-operator-metrics` | `<release>-clickhouse-operator-clickhouse-metrics`, endpoints `ch-metrics` and `op-metrics` |
| ClickHouse Operator ConfigMaps | `<release>-clickhouse-operator-etc-files`, `-etc-confd-files`, `-etc-configd-files`, `-etc-templatesd-files`, `-etc-usersd-files` | `<release>-clickhouse-operator-files`, `-confd-files`, `-configd-files`, `-templatesd-files`, `-usersd-files` |
| ClickHouse Operator containers | `operator`, `metrics-exporter` | `altinity-clickhouse-operator`, `metrics-exporter` |
| ClickHouse Operator objects under `clickhouse.nameOverride`, `clickhouse.fullnameOverride` or `clickhouse.clickhouseOperator.name` | `<clickhouse name>-operator`, `<clickhouse name>-<name>` | `<release>-clickhouse-operator`. Set `altinity-clickhouse-operator.fullnameOverride` to keep the old name. |

<a id="100-operator-system-logs-detail"></a>
#### System log tables

- The logger and each table's time to live (TTL) and flush interval are now each set in an XML file under `altinity-clickhouse-operator.configs.configdFiles`.
- For each key you set, copy the default file from the SigNoz Helm Chart's `values.yaml` into your values and edit it.
- The TTL, in days, is in the `engine` line. The flush interval is in `flush_interval_milliseconds`.
- The default for `partLog` is in Altinity's Helm chart: `helm show values altinity-clickhouse-operator --repo https://helm.altinity.com --version 0.27.4`.

| Old key under `clickhouse.clickhouseOperator` | File under `altinity-clickhouse-operator.configs.configdFiles` |
|---|---|
| `logger` | `01-clickhouse-02-logger.xml` |
| `queryLog` | `01-clickhouse-03-query_log.xml` |
| `partLog` | `01-clickhouse-04-part_log.xml` |
| `traceLog` | `01-clickhouse-05-trace_log.xml` |
| `asynchronousInsertLog` | `01-clickhouse-06-asynchronous_insert_log.xml` |
| `asynchronousMetricLog` | `01-clickhouse-07-asynchronous_metric_log.xml` |
| `backupLog` | `01-clickhouse-08-backup_log.xml` |
| `blobStorageLog` | `01-clickhouse-09-blob_storage_log.xml` |
| `crashLog` | `01-clickhouse-10-crash_log.xml` |
| `metricLog` | `01-clickhouse-11-metric_log.xml` |
| `queryThreadLog` | `01-clickhouse-12-query_thread_log.xml` |
| `queryViewsLog` | `01-clickhouse-13-query_views_log.xml` |
| `sessionLog` | `01-clickhouse-14-session_log.xml` |
| `zookeeperLog` | `01-clickhouse-15-zookeeper_log.xml` |
| `processorsProfileLog` | `01-clickhouse-16-processors_profile_log.xml` |

For example, `clickhouse.clickhouseOperator.zookeeperLog.ttl: 1` becomes:

```yaml
altinity-clickhouse-operator:
  configs:
    configdFiles:
      01-clickhouse-15-zookeeper_log.xml: |
        <yandex>
            <zookeeper_log replace="1">
                <database>system</database>
                <table>zookeeper_log</table>
                <engine>Engine = MergeTree PARTITION BY event_date ORDER BY event_time TTL event_date + interval 1 day</engine>
                <flush_interval_milliseconds>7500</flush_interval_milliseconds>
            </zookeeper_log>
        </yandex>
```

Set a file to `null` to leave its table unconfigured.

<a id="100-signoz"></a>
### SigNoz

- The Ingress renders `networking.k8s.io/v1` only. The `networking.k8s.io/v1beta1` and `extensions/v1beta1` fallbacks are gone.
- `signoz.ingress.labels` labels the Ingress, and `signoz.httpRoute` creates a Gateway API HTTPRoute. Both are new.

<a id="100-signoz-moved"></a>
#### Moved values

| Old key | New key | Note |
|---|---|---|
| `signoz.additionalArgs` | `signoz.extraArgs` | |
| `signoz.additionalVolumeMounts` | `signoz.extraVolumeMounts` | |
| `signoz.additionalVolumes` | `signoz.extraVolumes` | |
| `signoz.customLivenessProbe` | `signoz.livenessProbe` | For a handler other than `httpGet`, such as `exec` or `tcpSocket`, also set `httpGet: null`. |
| `signoz.customReadinessProbe` | `signoz.readinessProbe` | For a handler other than `httpGet`, such as `exec` or `tcpSocket`, also set `httpGet: null`. |
| `signoz.image.registry` | The registry prefix in `signoz.image.repository` | `repository: docker.io/signoz/signoz` |
| `signoz.livenessProbe`, `readinessProbe` with `enabled`, `port` or `path` | The same keys, as probe objects | `httpGet: {path: /api/v1/health, port: http}` |
| `signoz.podAnnotations` | `signoz.pod.annotations` | |
| `signoz.securityContext` | `signoz.containerSecurityContext` | |

<a id="100-signoz-actions"></a>
#### Setup-specific actions

| If you | Do |
|---|---|
| Have `/`, `?`, `#` or `%` in the ClickHouse password | Use a password without those characters. SigNoz cannot parse its connection string with them. |
| Set a `signoz.env` key named like a SigNoz Helm Chart variable, such as `SIGNOZ_SQLSTORE_*` or `POSTGRES_*` | Remove the key unless you intend its value to apply. It now overrides the SigNoz Helm Chart's variable. |

<a id="100-collector"></a>
### SigNoz OTel Collector

- The Ingress renders `networking.k8s.io/v1` only, and the HorizontalPodAutoscaler `autoscaling/v2` only. The `networking.k8s.io/v1beta1`, `extensions/v1beta1` and `autoscaling/v2beta2` fallbacks are gone.
- `otelCollector.ingress.labels` labels the Ingress, `otelCollector.httpRoute` and `otelCollector.grpcRoute` create Gateway API routes, and an `otelCollector.ports` entry can set `appProtocol`. All are new.
- A collector Ingress path without `pathType` now gets `ImplementationSpecific`, and one without `port` now goes to `otelCollector.ports.otlp-http.servicePort`, as on the SigNoz Ingress.

<a id="100-collector-moved"></a>
#### Moved values

| Old key | New key | Note |
|---|---|---|
| `otelCollector.additionalEnvs` | `otelCollector.env` | The same map. A list of `name` and `value` entries also works. |
| `otelCollector.command.extraArgs` | `otelCollector.extraArgs` | |
| `otelCollector.command.name` | Removed | The SigNoz OTel Collector always runs `/signoz-otel-collector`. |
| `otelCollector.customLivenessProbe` | `otelCollector.livenessProbe` | For a handler other than `httpGet`, such as `exec` or `tcpSocket`, also set `httpGet: null`. |
| `otelCollector.customReadinessProbe` | `otelCollector.readinessProbe` | For a handler other than `httpGet`, such as `exec` or `tcpSocket`, also set `httpGet: null`. |
| `otelCollector.image.registry` | The registry prefix in `otelCollector.image.repository` | `repository: docker.io/signoz/signoz-otel-collector` |
| `otelCollector.livenessProbe`, `readinessProbe` with `enabled`, `port` or `path` | The same keys, as probe objects | `httpGet: {path: /, port: 13133}` |
| `otelCollector.lowCardinalityExceptionGrouping` | `LOW_CARDINAL_EXCEPTION_GROUPING` in `otelCollector.env` | |
| `otelCollector.podAnnotations` | `otelCollector.pod.annotations` | |
| `otelCollector.podLabels` | `otelCollector.pod.labels` | |
| `otelCollector.securityContext` | `otelCollector.containerSecurityContext` | |

<a id="100-collector-defaults"></a>
#### Changed defaults

Set the old value to keep it.

| Key | Old value | New value |
|---|---|---|
| `otelCollector.config.exporters.clickhouselogsexporter.timeout` | `10s` | `45s` |
| `otelCollector.config.exporters.clickhousetraces.timeout` | Not set (5s) | `45s` |
| `otelCollector.config.exporters.metadataexporter.timeout` | `10s` | `45s` |

<a id="100-collector-actions"></a>
#### Setup-specific actions

| If you | Do |
|---|---|
| Enabled `otelCollector.ports.zipkin` or `jaeger-compact` with only `enabled: true` | Also set `containerPort`, `servicePort` and `protocol` (`9411` over `TCP`, `6831` over `UDP`). The SigNoz Helm Chart no longer defines these entries. |

<a id="100-migrator"></a>
### Schema migrator

<a id="100-migrator-moved"></a>
#### Moved values

| Old key | New key | Note |
|---|---|---|
| `telemetryStoreMigrator.upgradeHelmHooks` | Removed | |

<a id="100-migrator-actions"></a>
#### Setup-specific actions

| If you | Do |
|---|---|
| Set `telemetryStoreMigrator.name` | Keep it to at most 57 characters. |
| Reference or wait for Job `signoz-telemetrystore-migrator` | Use `signoz-telemetrystore-migrator-<revision>`. Every install and upgrade creates a new Job. Set `telemetryStoreMigrator.enabled: false` to skip one revision. |
| Bind a cloud identity or anything else to ServiceAccount `signoz-telemetrystore-migrator`, or set `telemetryStoreMigrator.serviceAccount.annotations` | Set `telemetryStoreMigrator.serviceAccount.create: true`. It now defaults to `false`. On a release installed from a chart before 1.0.0, first delete the old `signoz-telemetrystore-migrator` ServiceAccount or upgrade with `--take-ownership`. |
| Set `telemetryStoreMigrator.serviceAccount.name` without `create: true` | Add `create: true`, or create the ServiceAccount yourself. |
| Upgraded this release on SigNoz Helm Chart 0.151.0 or earlier | After the upgrade, delete the leftover Job `signoz-telemetrystore-migrator`. Also delete its ServiceAccount, unless you set `create: true` (see the row above) or `serviceAccount.name` names it. |

<a id="100-postgres"></a>
### PostgreSQL

- On SigNoz Helm Chart 0.151.0 and earlier, with default values on containerd (EKS, GKE, AKS, kind), the bundled PostgreSQL database lives in a container-scoped volume instead of its PVC, so it is lost whenever the container restarts ([#834](https://github.com/SigNoz/charts/issues/834)).
- On CRI-O (OpenShift), or when you set `postgresql.persistence.mountPath` to `/var/lib/postgresql/data` or `postgresql.persistence.dataDir` to a path outside it, the database is already on the PVC.
- The upgrade moves the bundled PostgreSQL database onto its PVC.
- Pre-upgrade Job `<release>-postgresql-upgrade-backup` dumps it to `backups/pre-upgrade.sql` on the PVC.
- PostgreSQL loads the dump on its first start.

No action is needed in these cases:

- You use the default PostgreSQL settings and a plain `helm upgrade`, and the PostgreSQL Pod is running.
- The database is already on the PVC. The backup Job logs `Nothing to back up.`
- You set `postgresql.auth.existingSecret` or a password in your values. The backup Job reads either.
- You set `postgresql.replicaCount: 0`. No PostgreSQL runs, so there is no database to move.

<a id="100-postgres-actions"></a>
#### Setup-specific actions

| If you | Do |
|---|---|
| Run the bundled PostgreSQL | Do not restart or scale PostgreSQL before upgrading. On SigNoz Helm Chart 0.151.0 the database may live inside the container. |
| Run the bundled PostgreSQL | Make no changes in SigNoz while the upgrade runs. Changes written after the dump are not included in it. |
| Have the PostgreSQL Pod down or unreachable, for example scaled to 0 with `kubectl scale` | Start it before you upgrade. Otherwise the backup Job fails and the upgrade stops before anything changes. With default values on containerd, a Pod scaled to 0 on SigNoz Helm Chart 0.151.0 has already lost its database, so the backup Job dumps an empty one. |
| Have a large database | Raise `postgresql.upgradeBackupHook.activeDeadlineSeconds`. The dump has 240 seconds by default. At 300 or more, also raise `helm upgrade --timeout`. |
| Mount your own `/docker-entrypoint-initdb.d` | Take the dump and load it manually, then set `postgresql.upgradeBackupHook.enabled: false` ([guide][guide-dump]). Otherwise the upgrade stops, because the dump would not be loaded. |
| Set `postgresql.persistence.mountPath` to a path other than `/var/lib/postgresql`, set `postgresql.persistence.dataDir` to a path outside it, or mount your own volume at the data directory | Check where the data directory lives. If it is not on a volume, take the dump manually first ([guide][guide-dump]). The backup Job does not run. |
| Set `postgresql.persistence.enabled: false` | Expect an empty database after the upgrade. The database is not on a persistent volume and does not survive the upgrade, as with any Pod restart. The backup Job does not run, and nothing loads a dump afterwards. |

The backup Job does not run in any of these cases. Take the dump manually first, while the release is still on SigNoz Helm Chart 0.151.0 ([guide][guide-dump]):

- Helm hooks do not run: rendered manifests, `--no-hooks`, or Terraform `helm_release` with `disable_webhooks = true`. With rendered manifests, you can apply the backup Job yourself instead ([Hooks](#100-hooks)).
- Argo CD: the backup Job renders only for a Helm upgrade, so it is not in the rendered manifests ([guide][guide-argocd]).
- `postgresql.upgradeBackupHook.enabled: false`
- a `ReadWriteOncePod` PVC

> [!CAUTION]
> Without the backup Job or a manual dump, PostgreSQL starts on an empty data directory without any warning.

<a id="100-registry"></a>
### Registry and pull secrets

`global.imageRegistry`, `global.imagePullSecrets` and `imagePullSecrets` apply to every image and Pod in the SigNoz Helm Chart, with three exceptions:

- **ClickHouse Operator**, with its CRD hook: only the `altinity-clickhouse-operator.*` keys below.
- **PostgreSQL**, with its backup Job: only `postgresql.image.registry`, `postgresql.image.repository` and `postgresql.imagePullSecrets`.
- **ZooKeeper**: `imagePullSecrets` does not reach it. Use `global.imagePullSecrets` or `zookeeper.image.pullSecrets`.

Set the ClickHouse Operator's keys before you upgrade:

```yaml
altinity-clickhouse-operator:
  operator:
    image:
      registry: my.registry
  metrics:
    image:
      registry: my.registry
  crdHook:
    image:
      repository: my.registry/kubectl
    imagePullSecrets:
      - name: my-pull-secret
  imagePullSecrets:
    - name: my-pull-secret
```

In addition:

- Mirror the images that are new in SigNoz Helm Chart 1.0.0:
  - `clickhouse/clickhouse-keeper:25.12.5`
  - `altinity/clickhouse-operator:0.27.4`
  - `altinity/metrics-exporter:0.27.4`
  - `registry.k8s.io/kubectl:v1.36.3`, for the hooks
  - `signoz/signoz-otel-collector:v0.144.15`, with `clickhouse.logs.system.enabled`
- `global.imageRegistry` now replaces a registry prefix written in a repository. Previously, the SigNoz Helm Chart added it as a prefix. Example: with `repository: docker.io/signoz/signoz` and `global.imageRegistry: my.registry`, the image is `my.registry/signoz/signoz`.
- The SigNoz Helm Chart now lists pull secrets on each Pod and no longer on its ServiceAccounts. If one of your own Pods runs under one of these ServiceAccounts, such as `<release>-signoz`, list the pull secrets in that Pod's spec.

<a id="100-hooks"></a>
### Hooks

- `helm upgrade` runs three pre-upgrade Jobs in this order:
  1. `<release>-postgresql-upgrade-backup`, with bundled PostgreSQL ([PostgreSQL](#100-postgres)).
  2. `<release>-clickhouse-operator-upgrade`, which deletes the ClickHouse Operator Deployment that SigNoz Helm Chart 0.151.0 created.
  3. `<release>-clickhouse-operator-crd-install`, which applies the four CRDs. Allow Helm to create its ClusterRole.
- `helm uninstall` runs one pre-delete Job, `<release>-signoz-uninstall`, the chart's uninstall hook, which deletes the ClickHouse resources, the ClickHouseInstallation and the ClickHouseKeeperInstallation, while the ClickHouse Operator still runs, so that the uninstall completes. It runs only on `helm uninstall`. `hooks.uninstall.enabled: false` turns it off.
- The SigNoz Helm Chart no longer ships a `helm test` Pod, `<release>-signoz-test-connection`, so `helm test` has nothing to run.
- No action is needed unless a row below applies.
- With Argo CD, the pre-install and pre-upgrade hooks run as PreSync hooks on every sync. See [With Argo CD][guide-argocd] in the upgrade guide.

<a id="100-hooks-actions"></a>
#### Setup-specific actions

| If you | Do |
|---|---|
| Apply rendered manifests (`helm template --is-upgrade`, `kubectl apply`), or your GitOps tool does not run Helm hooks | Apply every `pre-install` and `pre-upgrade` hook object in hook-weight order (`helm.sh/hook-weight`), lowest first, so that each Job's ServiceAccount, Roles and ConfigMaps exist before it. Let each Job finish before the next weight, then apply the rest. Never apply the `pre-delete` hook objects: applying the Job deletes the ClickHouseInstallation and the ClickHouseKeeperInstallation at once. Render with `hooks.uninstall.enabled: false` to leave them out. Delete the hook objects before a SigNoz Helm Chart version that changes them. |
| Apply rendered manifests (`helm template`, `kubectl apply`) | Render with `--namespace` set to the namespace you apply them to. Every namespaced object now sets its namespace, so `kubectl apply -n` with another namespace fails. |
| Upgrade with `--no-hooks` or `clickhouse.operatorUpgradeHook.enabled: false` | Delete the old ClickHouse Operator Deployment manually right before the upgrade ([command][guide-selector]). |
| Uninstall with `--no-hooks` or `hooks.uninstall.enabled: false`, or apply rendered manifests | Delete the ClickHouseKeeperInstallation and the ClickHouseInstallation before the ClickHouse Operator ([uninstall steps](README.md#uninstalling-the-chart)). |
| Upgrade with `--no-hooks` or `altinity-clickhouse-operator.crdHook.enabled: false` | Apply the four CRDs manually before each ClickHouse Operator version change. |
| Upgrade with `--no-hooks` or `postgresql.upgradeBackupHook.enabled: false`, with bundled PostgreSQL | See [PostgreSQL](#100-postgres). |

<a id="100-keeper-troubleshooting"></a>
<a id="100-ts-keeper-crd"></a>
<a id="100-ts-no-store"></a>
<a id="100-ts-empty-keeper"></a>
<a id="100-operator-troubleshooting"></a>
<a id="100-ts-operator-selector"></a>
<a id="100-collector-troubleshooting"></a>
<a id="100-ts-collector-refuses"></a>
<a id="100-postgres-troubleshooting"></a>
<a id="100-ts-pg-backup"></a>
<a id="100-ts-pg-not-ready"></a>
### Troubleshooting

See [Troubleshooting][guide-troubleshooting] in the upgrade guide.

<a id="100-uninstall"></a>
### Uninstall

Follow the [uninstall steps](README.md#uninstalling-the-chart).

[guide]: https://signoz.io/docs/operate/migration/upgrade-0-152/
[guide-dump]: https://signoz.io/docs/operate/migration/upgrade-0-152/#take-the-postgresql-dump-by-hand
[guide-rollback]: https://signoz.io/docs/operate/migration/upgrade-0-152/#roll-back
[guide-who]: https://signoz.io/docs/operate/migration/upgrade-0-152/#who-needs-to-act
[guide-store]: https://signoz.io/docs/operate/migration/upgrade-0-152/#step-1-keep-zookeeper-for-the-upgrade
[guide-troubleshooting]: https://signoz.io/docs/operate/migration/upgrade-0-152/#troubleshooting
[guide-selector]: https://signoz.io/docs/operate/migration/upgrade-0-152/#cannot-patch-release-clickhouse-operator-with-kind-deployment
[guide-argocd]: https://signoz.io/docs/operate/migration/upgrade-0-152/#with-argo-cd
