# Upgrading the SigNoz Helm Chart

This file lists what to change when you upgrade to each version of the SigNoz Helm Chart (`signoz`). The step-by-step upgrade guides are on signoz.io, linked from each version's section.

- [1.0.0](#100)

If you run into an issue during an upgrade, open a [GitHub issue](https://github.com/SigNoz/charts/issues) or ask in the [SigNoz Slack community](https://signoz.io/slack).

<a id="100"></a>
## 1.0.0

SigNoz Helm Chart 1.0.0 ships SigNoz v0.152.0 and makes ClickHouse Keeper the default coordination store for ClickHouse. It also moves the bundled PostgreSQL database onto its PersistentVolumeClaim (PVC) and upgrades the Altinity ClickHouse Operator to 0.27.4. This section covers upgrades from SigNoz Helm Chart 0.151.0 or earlier. The steps are in the [upgrade guide][guide].

> [!WARNING]
> **Breaking changes in SigNoz Helm Chart 1.0.0**
>
> - ClickHouse Keeper is on by default. With the bundled ClickHouse on default values, `helm upgrade` fails, and Argo CD or rendered manifests point ClickHouse at a new, empty ClickHouse Keeper. See [ClickHouse Keeper and ZooKeeper](#100-keeper).
> - Values keys moved. `helm template` fails and lists every moved key you set with its replacement. Two sets of keys are ignored without an error, so rename them yourself: old key names under `altinity-clickhouse-operator` ([ClickHouse Operator](#100-operator)), and `zookeeper.global.imageRegistry` and `zookeeper.global.storageClass` ([ClickHouse Keeper and ZooKeeper](#100-keeper-moved)). See each component's Moved values table.
> - The bundled PostgreSQL database moves onto its PVC. Without the backup Job or a manual dump, PostgreSQL starts empty. See [PostgreSQL](#100-postgres).
> - Without Helm hooks (Argo CD, rendered manifests, `--no-hooks`), the upgrade stops on the old ClickHouse Operator Deployment, or PostgreSQL starts empty. See [Hooks](#100-hooks).

<details>
<summary>What changed in SigNoz Helm Chart 1.0.0</summary>

- **Security hardening**: ClickHouse can run under the restricted Pod Security Standard (OpenShift, GKE with PodSecurity, Kyverno) through `clickhouse.containerSecurityContext`.
- **Persistence**: PostgreSQL data lives on its PVC and survives Pod and container restarts. Before, with default values on containerd, it was lost whenever the container restarted. ClickHouse PVCs are retained after a scale-down or rename.
- **Reliability**: ClickHouse Keeper replaces the JVM-based ZooKeeper, which could use as much memory as ClickHouse and restart silently when OOMKilled. The bundled ZooKeeper is deprecated.
- **Safe upgrades**: pre-upgrade hooks back up PostgreSQL and apply the CustomResourceDefinitions (CRDs) first, and `helm template` fails on most moved values keys before anything reaches the cluster.
- **Availability**: ClickHouse keeps serving while the ClickHouse Operator is replaced, and `keeper.replicaCount` scales ClickHouse Keeper out.
- **Lifecycle**: the ClickHouse Operator moves from 0.21.2 to 0.27.4 and follows Altinity's releases, with CRDs updated on every upgrade.
- **Observability**: an optional ServiceMonitor (`altinity-clickhouse-operator.serviceMonitor.enabled`) scrapes ClickHouse and ClickHouse Operator metrics on separate endpoints.
- **Configurability**: values use standard Kubernetes shapes, and each ClickHouse system log table can be tuned or turned off.
- **Supply chain**: ClickHouse Keeper uses the official `clickhouse/clickhouse-keeper` image instead of a forked ZooKeeper image.

For the reasons behind these changes, see [#958](https://github.com/SigNoz/charts/issues/958) and [#959](https://github.com/SigNoz/charts/issues/959).

</details>

<a id="100-checklist"></a>
### Who needs to act

Do each of these before upgrading.

| If you | Do |
|---|---|
| Run the bundled ClickHouse | [Set the values that keep ZooKeeper for the upgrade](#100-keeper). |
| Use a custom values file | Run `helm template` with it, and review the section of each component you set values for. |
| Run the bundled PostgreSQL | [Check that the backup Job runs for your setup](#100-postgres). |
| Deploy without Helm hooks (Argo CD, rendered manifests, `--no-hooks`, Terraform with hooks disabled) | [Run the hook steps yourself](#100-hooks). |
| Pull images from a private registry or run an air-gapped cluster | [Mirror the new images and set the ClickHouse Operator's image keys](#100-registry). |

<a id="100-expect"></a>
### What to expect during the upgrade

- `helm upgrade` returns within seconds, and the restarts continue after it.
- ClickHouse, ZooKeeper and SigNoz restart once, and so does the bundled PostgreSQL Pod. ClickHouse, the UI and queries are unavailable for a few minutes.
- The ClickHouse Operator is replaced within seconds, and ClickHouse keeps running through that.
- Ingestion is interrupted for up to a few minutes. Agents that retry resend what they held. A record or two sent while the SigNoz OTel Collector Pod is replaced can be lost.
- Each ClickHouse Pod start downloads `histogramQuantile` from GitHub in an init container, so slow or blocked access to GitHub lengthens the restart. More replicas take longer.

<a id="100-rollback"></a>
### Rollback

- Roll back only while ClickHouse still runs on ZooKeeper. Once ClickHouse runs on ClickHouse Keeper, there is no rollback to SigNoz Helm Chart 0.151.0. Stay on ZooKeeper until you are sure of the upgrade, then migrate.
- With bundled PostgreSQL, a rollback to SigNoz Helm Chart 0.151.0 starts SigNoz on an empty database, with a new organization and root user. The PVC keeps the existing database, and upgrading forward again restores it. You lose the changes made in SigNoz while rolled back. While rolled back, the database may live inside the container again, as on SigNoz Helm Chart 0.151.0, so a PostgreSQL restart can empty it.

To roll back to SigNoz Helm Chart 0.151.0:

1. Find the last SigNoz Helm Chart 0.151.0 revision in the release history.
2. Delete the ClickHouse Operator Deployment right before the rollback. Where you set `altinity-clickhouse-operator.fullnameOverride`, use that name. With `altinity-clickhouse-operator.namespaceOverride`, the Deployment is in that namespace.
3. Roll back to that revision.
4. Wait until the ClickHouseInstallation reports `Completed`.

```bash
helm history <release> -n <namespace>
kubectl -n <namespace> delete deployment <release>-clickhouse-operator
helm rollback <release> <revision> -n <namespace>
kubectl -n <namespace> get chi -w
```

During and after the rollback:

- The rollback needs no values file and runs no hooks.
- The older ClickHouse Operator restarts ClickHouse once. ClickHouse, the UI and queries are unavailable for a few minutes. ZooKeeper, SigNoz and the SigNoz OTel Collector restart once.
- The four CRDs, the ClickHouse Keeper CRD among them, stay at the newer version. The older ClickHouse Operator works with them.
- To upgrade again, run `helm upgrade` with your 1.0.0 values file. Do not use `--reuse-values`, because the rolled-back release holds the 0.151.0 values.

If the rollback fails, see [What state does a failed `helm rollback` leave?](#100-ts-rollback-failed)

<a id="100-stay-on-0151"></a>
<details>
<summary>Staying on SigNoz Helm Chart 0.151.0</summary>

If you do not want to move to SigNoz Helm Chart 1.0.0 yet, you can stay on SigNoz Helm Chart 0.151.0 and move to newer SigNoz versions by setting the SigNoz and SigNoz OTel Collector image tags in your values. We recommend upgrading to SigNoz Helm Chart 1.0.0.

```yaml
signoz:
  image:
    tag: <signoz-version>
otelCollector:
  image:
    tag: <collector-version>
```

- `<collector-version>` is the SigNoz OTel Collector version for that SigNoz release.
- Use your 0.151.0 values file. The 1.0.0 keys do not exist in SigNoz Helm Chart 0.151.0.
- Pass `--version 0.151.0`. Without it, `helm upgrade` takes 1.0.0.

```bash
helm upgrade <release> signoz/signoz --version 0.151.0 -n <namespace> -f <values>
```

</details>

<a id="100-clickhouse"></a>
### ClickHouse

<a id="100-clickhouse-moved"></a>
#### Moved values

| Old key | New key | Note |
|---|---|---|
| `clickhouse.additionalVolumeMounts` | `clickhouse.extraVolumeMounts` | |
| `clickhouse.additionalVolumes` | `clickhouse.extraVolumes` | |
| `clickhouse.clickhouseOperator` | `altinity-clickhouse-operator` | The keys under it are renamed ([ClickHouse Operator](#100-operator)). |
| `clickhouse.customLivenessProbe` | `clickhouse.livenessProbe` | |
| `clickhouse.customReadinessProbe` | `clickhouse.readinessProbe` | |
| `clickhouse.customStartupProbe` | `clickhouse.startupProbe` | |
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

SigNoz Helm Chart 1.0.0 enables ClickHouse Keeper by default and deprecates the bundled ZooKeeper, while an existing installation with the bundled ClickHouse runs ZooKeeper. With an external ClickHouse (`clickhouse.enabled: false`), this section does not apply. Otherwise, keep ZooKeeper for the upgrade:

- **Set these values before you upgrade.**

  ```yaml
  zookeeper:
    enabled: true
  keeper:
    enabled: false
  ```

  If you used `clickhouse.externalZookeeper`, set only:

  ```yaml
  keeper:
    enabled: false
  ```

- **Migrate to ClickHouse Keeper afterwards, if you want to.** The [migration guide](https://signoz.io/docs/operate/clickhouse/migrate-zookeeper-to-keeper/) starts from a release that is already on SigNoz Helm Chart 1.0.0 with ZooKeeper.

> [!CAUTION]
> Do not upgrade on default values. `helm upgrade` fails while the cluster lacks the ClickHouse Keeper CustomResourceDefinition (CRD). Through Argo CD or rendered manifests, the upgrade removes ZooKeeper and points ClickHouse at a new, empty ClickHouse Keeper, and the replicated tables become read-only.

<a id="100-keeper-moved"></a>
#### Moved values

| Old key | New key | Note |
|---|---|---|
| `clickhouse.zookeeper` | `zookeeper`, at the top level | With `enabled: true`. |
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

<a id="100-keeper-troubleshooting"></a>
#### Troubleshooting

<a id="100-ts-keeper-crd"></a>
##### `no matches for kind "ClickHouseKeeperInstallation" in version "clickhouse-keeper.altinity.com/v1"`

- **Affects:** Existing installations upgraded with `keeper.enabled` at its default.
- **Symptom:** The first `helm upgrade` fails with this error and `ensure CRDs are installed first`. Nothing in the cluster changed.
- **Cause:** ClickHouse Keeper is on by default, and the cluster does not have its CRD yet.
- **Resolution:** Set the values under [ClickHouse Keeper and ZooKeeper](#100-keeper) and upgrade again.
- **Verify:** The upgrade completes and the Helm notes print `ClickHouse coordinates through ZooKeeper.`

<a id="100-ts-no-store"></a>
##### `no coordination store for ClickHouse`

- **Affects:** Values with `keeper.enabled: false` and neither ZooKeeper option.
- **Symptom:** `helm upgrade` or `helm template` fails with this error.
- **Cause:** ClickHouse Keeper is off, `zookeeper.enabled` is not `true`, and `clickhouse.externalZookeeper` is unset.
- **Resolution:** Set `zookeeper.enabled: true`, `keeper.enabled: true` or `clickhouse.externalZookeeper.servers`.
- **Verify:** The Helm notes name the store, such as `ClickHouse coordinates through ZooKeeper.`

<a id="100-ts-empty-keeper"></a>
##### Did ClickHouse switch to an empty ClickHouse Keeper?

- **Affects:** Existing installations upgraded or synced without `zookeeper.enabled: true`, for example through Argo CD or rendered manifests that include the CRDs.
- **Symptom:** The Helm notes print `ClickHouse coordinates through ClickHouse Keeper at keeper-<release>-keeper:2181.`, StatefulSet `<release>-zookeeper` no longer exists, and replicated tables are read-only.
- **Cause:** Default values replaced ZooKeeper with a new ClickHouse Keeper that holds none of the tables' coordination state.
- **Resolution:** Follow the [recovery steps](https://signoz.io/docs/operate/clickhouse/migrate-zookeeper-to-keeper/#replicated-tables-are-read-only-after-an-upgrade-without-zookeeperenabled-true). The SigNoz Helm Chart keeps the ZooKeeper PVCs.
- **Verify:** StatefulSet `<release>-zookeeper` exists again.

<a id="100-operator"></a>
### ClickHouse Operator

- The Altinity ClickHouse Operator is upgraded from 0.21.2 to 0.27.4.
- It is now installed from Altinity's Helm chart, `altinity-clickhouse-operator`.
- The upgrade brings the three ClickHouse CRDs to 0.27.4 and adds the ClickHouse Keeper CRD.

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

<a id="100-operator-troubleshooting"></a>
#### Troubleshooting

<a id="100-ts-operator-selector"></a>
##### `cannot patch "<release>-clickhouse-operator" with kind Deployment`

- **Affects:** Upgrades with `--no-hooks`, Argo CD without hooks or `clickhouse.operatorUpgradeHook.enabled: false`, and any `helm rollback` to SigNoz Helm Chart 0.151.0.
- **Symptom:** The upgrade or rollback fails on the ClickHouse Operator Deployment's selector, which is immutable.
- **Cause:** The ClickHouse Operator Deployment's selector changed in SigNoz Helm Chart 1.0.0, and the Deployment of the other version is still in place.
- **Resolution:** Delete the Deployment, then run the upgrade or rollback again. Before an upgrade, this selector matches it under any old name, with `clickhouse.namespace` and `clickhouse.nameOverride` in place of `<namespace>` and `clickhouse` when set:

  ```bash
  kubectl -n <namespace> delete deployment -l app.kubernetes.io/name=clickhouse,app.kubernetes.io/instance=<release>,app.kubernetes.io/component
  ```

  This selector matches only the SigNoz Helm Chart 0.151.0 Deployment, so it finds nothing before a rollback. Before a rollback, delete the newer Deployment by name, `<release>-clickhouse-operator` or the value of `altinity-clickhouse-operator.fullnameOverride`, as in [Rollback](#100-rollback).

<a id="100-ts-rollback-failed"></a>
##### What state does a failed `helm rollback` leave?

- **Affects:** A `helm rollback` to SigNoz Helm Chart 0.151.0 run without deleting the ClickHouse Operator Deployment first.
- **Symptom:** The rollback fails with `cannot patch "<release>-clickhouse-operator" with kind Deployment`, and `helm history` shows a failed revision and none deployed. ZooKeeper, SigNoz and the SigNoz OTel Collector restarted, and ClickHouse was down for about a minute.
- **Cause:** The failed rollback reverted everything except the ClickHouse Operator Deployment.
- **Resolution:** Delete the ClickHouse Operator Deployment and run the same rollback again, as in [Rollback](#100-rollback). It succeeds from that state.
- **Verify:** `helm history` shows a deployed revision, and the ClickHouseInstallation reports `Completed`.
- **Leftovers:** These objects stay in the namespace and belong to no revision:
  - nine `<release>-clickhouse-operator-*` ConfigMaps
  - Secret `<release>-clickhouse-credentials`
  - the upgrade's schema migrator Job

  They caused no problem in testing, and the next upgrade adopted the ones that were checked: two of the ConfigMaps and the Secret.

<a id="100-signoz"></a>
### SigNoz

<a id="100-signoz-moved"></a>
#### Moved values

| Old key | New key | Note |
|---|---|---|
| `signoz.additionalArgs` | `signoz.extraArgs` | |
| `signoz.additionalVolumeMounts` | `signoz.extraVolumeMounts` | |
| `signoz.additionalVolumes` | `signoz.extraVolumes` | |
| `signoz.customLivenessProbe` | `signoz.livenessProbe` | |
| `signoz.customReadinessProbe` | `signoz.readinessProbe` | |
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

<a id="100-collector-moved"></a>
#### Moved values

| Old key | New key | Note |
|---|---|---|
| `otelCollector.additionalEnvs` | `otelCollector.env` | The same map. A list of `name` and `value` entries also works. |
| `otelCollector.command.extraArgs` | `otelCollector.extraArgs` | |
| `otelCollector.command.name` | Removed | The SigNoz OTel Collector always runs `/signoz-otel-collector`. |
| `otelCollector.customLivenessProbe` | `otelCollector.livenessProbe` | |
| `otelCollector.customReadinessProbe` | `otelCollector.readinessProbe` | |
| `otelCollector.image.registry` | The registry prefix in `otelCollector.image.repository` | `repository: docker.io/signoz/signoz-otel-collector` |
| `otelCollector.livenessProbe`, `readinessProbe` with `enabled`, `port` or `path` | The same keys, as probe objects | `httpGet: {path: /, port: 13133}` |
| `otelCollector.lowCardinalityExceptionGrouping` | `LOW_CARDINAL_EXCEPTION_GROUPING` in `otelCollector.env` | |
| `otelCollector.podAnnotations` | `otelCollector.pod.annotations` | |
| `otelCollector.podLabels` | `otelCollector.pod.labels` | |
| `otelCollector.securityContext` | `otelCollector.containerSecurityContext` | |

<a id="100-collector-actions"></a>
#### Setup-specific actions

| If you | Do |
|---|---|
| Enabled `otelCollector.ports.zipkin` or `jaeger-compact` with only `enabled: true` | Also set `containerPort`, `servicePort` and `protocol` (`9411` over `TCP`, `6831` over `UDP`). The SigNoz Helm Chart no longer defines these entries. |

<a id="100-collector-troubleshooting"></a>
#### Troubleshooting

<a id="100-ts-collector-refuses"></a>
##### Why does the SigNoz OTel Collector refuse data while its Pod is Ready?

- **Affects:** Releases after an upgrade or a rollback.
- **Symptom:** The SigNoz OTel Collector Pod is Ready but refuses connections on ports 4317 and 4318. Its log shows `failed to apply config` with `cannot configure clickhouse logs exporter: dial tcp ...:9000: connect: connection refused`.
- **Cause:** The SigNoz OTel Collector opens ports 4317 and 4318 only after SigNoz sends it its configuration. The configuration arrived while ClickHouse was restarting, so it failed to apply. The Pod can recover by itself after a few minutes, or not at all.
- **Resolution:** Delete the Pod:

  ```bash
  kubectl -n <namespace> delete pod -l app.kubernetes.io/component=otel-collector
  ```

- **Verify:** New telemetry arrives in SigNoz.

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
| Mount your own `/docker-entrypoint-initdb.d` | Take the dump and load it manually, then set `postgresql.upgradeBackupHook.enabled: false` ([guide]). Otherwise the upgrade stops, because the dump would not be loaded. |
| Set `postgresql.persistence.mountPath` to a path other than `/var/lib/postgresql`, set `postgresql.persistence.dataDir` to a path outside it, or mount your own volume at the data directory | Check where the data directory lives. If it is not on a volume, take the dump manually first ([guide]). The backup Job does not run. |
| Set `postgresql.persistence.enabled: false` | Expect an empty database after the upgrade. The database is not on a persistent volume and does not survive the upgrade, as with any Pod restart. The backup Job does not run, and nothing loads a dump afterwards. |

The backup Job does not run in any of these cases. Take the dump manually first, while the release is still on SigNoz Helm Chart 0.151.0 ([guide]):

- Helm hooks do not run: Argo CD, rendered manifests, `--no-hooks`, or Terraform `helm_release` with `disable_webhooks = true`. With Argo CD or rendered manifests, you can apply the backup Job yourself instead ([Hooks](#100-hooks)).
- `postgresql.upgradeBackupHook.enabled: false`
- a `ReadWriteOncePod` PVC

> [!CAUTION]
> Without the backup Job or a manual dump, PostgreSQL starts on an empty data directory without any warning.

<a id="100-postgres-troubleshooting"></a>
#### Troubleshooting

<a id="100-ts-pg-backup"></a>
##### `pre-upgrade hooks failed` with `job <release>-postgresql-upgrade-backup failed`

- **Affects:** Releases with the bundled PostgreSQL.
- **Symptom:** `helm upgrade` stops with `BackoffLimitExceeded` or `DeadlineExceeded` for the backup Job. Nothing else in the cluster changed.
- **Cause:**
  - `BackoffLimitExceeded` with `ERROR: cannot connect to Postgres at`: a wrong password or an unreachable PostgreSQL.
  - `BackoffLimitExceeded` with `ERROR: the release mounts its own /docker-entrypoint-initdb.d`: your own init scripts.
  - `DeadlineExceeded`: the Job did not finish in `postgresql.upgradeBackupHook.activeDeadlineSeconds` (240 by default), for example while PostgreSQL is scaled to 0 or the database is large.
- **Resolution:** Read `kubectl -n <namespace> logs job/<release>-postgresql-upgrade-backup`, fix the cause it names and upgrade again. Alternatively, take the dump manually ([guide]) and then set `postgresql.upgradeBackupHook.enabled: false`.
- **Verify:** The Job's log ends with `Dumped database <db> to /claim/backups/pre-upgrade.sql.` or `Nothing to back up.`

<a id="100-ts-pg-not-ready"></a>
##### Why does the PostgreSQL Pod stay not Ready after the upgrade?

- **Affects:** Releases with the bundled PostgreSQL.
- **Symptom:** The Pod runs but is not Ready, with the event `Startup probe failed` and `pre-upgrade.sql has not been loaded`.
- **Cause:** The dump on the PVC was not loaded: it is incomplete (`does not end with COMMIT;`), it failed to load, the load was interrupted, or you mount your own `/docker-entrypoint-initdb.d`.
- **Resolution:** Load a complete dump manually and rename the file to `pre-upgrade.sql.loaded` ([guide]).
- **Verify:** The Pod becomes Ready.

<a id="100-registry"></a>
### Registry and pull secrets

`global.imageRegistry`, `global.imagePullSecrets` and `imagePullSecrets` apply to every image and Pod in the SigNoz Helm Chart, with four exceptions:

- **ClickHouse Operator**, with its CRD hook: only the `altinity-clickhouse-operator.*` keys below.
- **PostgreSQL**, with its backup Job: only `postgresql.image.registry`, `postgresql.image.repository` and `postgresql.imagePullSecrets`.
- **ZooKeeper**: `imagePullSecrets` does not reach it. Use `global.imagePullSecrets` or `zookeeper.image.pullSecrets`.
- **The `helm test` Pod**: it gets the registry but no pull secrets.

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
- No action is needed unless a row below applies.

<a id="100-hooks-actions"></a>
#### Setup-specific actions

| If you | Do |
|---|---|
| Apply rendered manifests (`helm template --is-upgrade`, `kubectl apply`), or your GitOps tool does not run Helm hooks | Apply every hook object in hook-weight order (`helm.sh/hook-weight`), lowest first, so that each Job's ServiceAccount, Roles and ConfigMaps exist before it. Let each Job finish before the next weight, then apply the rest. Delete the hook objects before a SigNoz Helm Chart version that changes them. |
| Upgrade with `--no-hooks` or `clickhouse.operatorUpgradeHook.enabled: false` | Delete the old ClickHouse Operator Deployment manually right before the upgrade ([command](#100-ts-operator-selector)). |
| Upgrade with `--no-hooks` or `altinity-clickhouse-operator.crdHook.enabled: false` | Apply the four CRDs manually before each ClickHouse Operator version change. |
| Upgrade with `--no-hooks` or `postgresql.upgradeBackupHook.enabled: false`, with bundled PostgreSQL | See [PostgreSQL](#100-postgres). |

<a id="100-uninstall"></a>
### Uninstall

- Follow the [uninstall steps](README.md#uninstalling-the-chart). `helm uninstall` alone leaves the ClickHouse and ClickHouse Keeper objects held by their finalizers.
- Afterwards, manually delete what you no longer need:
  - the ClickHouse, ClickHouse Keeper and PostgreSQL PVCs
  - the four CRDs
  - a `clickhouse.namespace` Namespace, which the SigNoz Helm Chart now keeps

[guide]: https://signoz.io/docs/operate/migration/upgrade-0-152/
