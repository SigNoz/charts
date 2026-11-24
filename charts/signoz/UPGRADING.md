# Upgrading the SigNoz chart

This file lists what to change when you upgrade to each version of the `signoz` chart. The step-by-step upgrade guides are on signoz.io, linked from each version's section.

- [1.0.0](#100)

If you run into an issue during an upgrade, open a [GitHub issue](https://github.com/SigNoz/charts/issues) or ask in the [SigNoz Slack community](https://signoz.io/slack).

<a id="100"></a>
## 1.0.0

This section covers upgrades from chart 0.151.0 or earlier to 1.0.0. It lists what changed and what to set. The steps are in the [upgrade guide][guide].

<a id="100-checklist"></a>
### Checklist

Find the rows that match your setup and follow them.

| If you | Do | Section |
|---|---|---|
| Run the bundled ClickHouse | Choose the coordination store: stay on ZooKeeper or migrate to ClickHouse Keeper. | [Keeper and ZooKeeper](#100-keeper) |
| Use a custom values file | Run `helm template` with it. The render lists every key that moved. Then review each component you set values for. | [ClickHouse](#100-clickhouse), [Keeper and ZooKeeper](#100-keeper), [ClickHouse operator](#100-operator), [SigNoz](#100-signoz), [Collector](#100-collector), [Schema migrator](#100-migrator) |
| Run the bundled Postgres | Check that the backup Job runs for your setup. | [Postgres](#100-postgres) |
| Deploy without Helm hooks (Argo CD, rendered manifests, `--no-hooks`, Terraform with hooks disabled) | Run the hook steps yourself. | [Hooks](#100-hooks) |
| Pull images from a private registry or run an air-gapped cluster | Mirror the new images and set the operator's image keys. | [Registry and pull secrets](#100-registry) |

<a id="100-rollback"></a>
### Rollback

- Do not roll back once ClickHouse runs on Keeper.
- With bundled Postgres, a rollback to chart 0.151.0 starts SigNoz on an empty database. The PVC keeps the existing database, and upgrading forward again restores it. You lose the changes made in SigNoz while rolled back.
- To roll back to a chart 0.151.0 revision while ClickHouse still runs on ZooKeeper:
  1. Delete the operator Deployment right before the rollback.
  2. Roll back.
- Where you set `altinity-clickhouse-operator.fullnameOverride`, use that name in the command.

```bash
kubectl -n <namespace> delete deployment <release>-clickhouse-operator
helm rollback <release> <revision> -n <namespace>
```

<a id="100-clickhouse"></a>
### ClickHouse

#### Moved values

| Old key | New key | Note |
|---|---|---|
| `clickhouse.additionalVolumeMounts` | `clickhouse.extraVolumeMounts` | |
| `clickhouse.additionalVolumes` | `clickhouse.extraVolumes` | |
| `clickhouse.clickhouseOperator` | `altinity-clickhouse-operator` | The keys under it are renamed ([ClickHouse operator](#100-operator)). |
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

#### Changed defaults

Set the old value to keep it.

| Key | Old value | New value |
|---|---|---|
| `clickhouse.logs.system.config.service.telemetry.metrics.address` | `0.0.0.0:8888` | Not set. See the collector's [internal telemetry](https://opentelemetry.io/docs/collector/internal-telemetry/) docs. |
| `clickhouse.logs.system.image.tag` | `0.111.16` | `v0.144.15` |
| `externalClickhouse.existingSecretPasswordKey` | `null` | `password` |

#### Setup-specific actions

| If you | Do |
|---|---|
| Run ClickHouse in another namespace (`clickhouse.namespace`) | Also set `altinity-clickhouse-operator.namespaceOverride` to that namespace, or `watchNamespaces` with `rbac.namespaceScoped: false`. |
| Read the ClickHouse password from a Pod spec or the ClickHouseInstallation | Read it from Secret `<release>-clickhouse-credentials`, key `password` (`<fullnameOverride>-credentials` with `clickhouse.fullnameOverride`). |
| Use an external ClickHouse and read Secret `<release>-clickhouse-external`, key `clickhouse-password` | Read Secret `<release>-clickhouse-credentials`, key `password`. |
| Change `clickhouse.password`, `externalClickhouse.password` or `postgresql.auth.password` | Restart SigNoz, the collector and ClickHouse or Postgres afterwards. A password change no longer restarts them. |
| Reference `CLICKHOUSE_HTTP_PORT` in your own configuration | Write the port number there instead. `clickhouse.service.httpPort` and `externalClickhouse.httpPort` no longer set the variable. |
| Set `clickhouse.logs.system.enabled: true` | Do not pin a `clickhouse.logs.system.image.tag` older than the default, and remove from `clickhouse.logs.system.config` the [components not included in collector 0.144.15](#100-logs-components). |
| Scale ClickHouse down or rename it | Delete the remaining PersistentVolumeClaims (PVCs) manually once you no longer need the data. The operator now keeps them. |
| Set `externalClickhouse.secure: true` | If `externalClickhouse.tcpPort` serves TLS (usually 9440), add `secure=true` to the exporter data source names (DSNs) in `otelCollector.config`. Otherwise set `secure: false`. |
| Set `global.clusterDomain` | Check that it is your cluster's domain. It is now passed to ClickHouse. |

<a id="100-logs-components"></a>
Components not included in collector 0.144.15:

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
### Keeper and ZooKeeper

#### Coordination store

Chart 1.0.0 enables ClickHouse Keeper by default, while an existing installation with the bundled ClickHouse runs ZooKeeper. With an external ClickHouse (`clickhouse.enabled: false`), this section does not apply. Otherwise, choose one option before you upgrade:

- **Stay on ZooKeeper.** Set these values. You can migrate later:

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

- **Migrate to ClickHouse Keeper.** Follow the [guide].

> [!CAUTION]
> Choose one of the two options. An upgrade on default values applies neither. `helm upgrade` fails because the Keeper CRD is missing. Through Argo CD or rendered manifests, the upgrade removes ZooKeeper and points ClickHouse at a new, empty Keeper, and the replicated tables become read-only.

#### Moved values

| Old key | New key | Note |
|---|---|---|
| `clickhouse.zookeeper` | `zookeeper`, at the top level | With `enabled: true`. |
| `zookeeper.global.imageRegistry` | `zookeeper.image.registry`, or `global.imageRegistry` | |
| `zookeeper.global.storageClass` | `zookeeper.persistence.storageClass`, or `global.storageClass` | |

#### Changed defaults

| Key | Old value | New value |
|---|---|---|
| `keeper.enabled` | Key did not exist | `true` |
| `zookeeper.enabled` | `true`, as `clickhouse.zookeeper.enabled` | `false` |
| `zookeeper.preAllocSize` | `65536` | `0` |

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
- **Cause:** Keeper is on by default, and the cluster does not have its CustomResourceDefinition (CRD) yet.
- **Resolution:** Set the values under [Keeper and ZooKeeper](#100-keeper) and upgrade again.
- **Verify:** The upgrade completes and the Helm notes print `ClickHouse coordinates through ZooKeeper.`

<a id="100-ts-no-store"></a>
##### `no coordination store for ClickHouse`

- **Affects:** Values with `keeper.enabled: false` and neither ZooKeeper option.
- **Symptom:** `helm upgrade` or `helm template` fails with this error.
- **Cause:** Keeper is off, `zookeeper.enabled` is not `true`, and `clickhouse.externalZookeeper.servers` is empty.
- **Resolution:** Set `zookeeper.enabled: true`, `keeper.enabled: true` or `clickhouse.externalZookeeper.servers`.
- **Verify:** The Helm notes name the store, such as `ClickHouse coordinates through ZooKeeper.`

<a id="100-ts-empty-keeper"></a>
##### Did ClickHouse switch to an empty Keeper?

- **Affects:** Existing installations upgraded or synced without `zookeeper.enabled: true`, for example through Argo CD or rendered manifests that include the CRDs.
- **Symptom:** The Helm notes print `ClickHouse coordinates through ClickHouse Keeper at keeper-<release>-keeper:2181.`, StatefulSet `<release>-zookeeper` no longer exists, and replicated tables are read-only.
- **Cause:** Default values replaced ZooKeeper with a new Keeper that holds none of the tables' coordination state.
- **Resolution:** Follow the recovery steps in the [guide]. The chart keeps the ZooKeeper PVCs.
- **Verify:** StatefulSet `<release>-zookeeper` exists again.

<a id="100-operator"></a>
### ClickHouse operator

- The operator is upgraded from 0.21.2 to 0.27.4.
- It is now installed from Altinity's chart, `altinity-clickhouse-operator`.
- The upgrade brings the three ClickHouse CRDs to 0.27.4 and adds the Keeper CRD.

#### Moved values

Altinity's chart ignores the old key names, so rename each key you set:

| Old key | New key under `altinity-clickhouse-operator` |
|---|---|
| `clickhouse.clickhouseOperator.image.*` | `operator.image.*` |
| `clickhouse.clickhouseOperator.resources` | `operator.resources` |
| `clickhouse.clickhouseOperator.nodeSelector`, `tolerations`, `affinity` | The same keys, at the top level |
| `clickhouse.clickhouseOperator.metricsExporter.*` | `metrics.image.*`, `metrics.resources`, `metrics.env`. The Service port, type and annotations have no counterpart. |
| `clickhouse.clickhouseOperator.imagePullSecrets`, as names (`[ch-pull]`) | `imagePullSecrets`, as objects (`[{name: ch-pull}]`) |
| `clickhouse.clickhouseOperator.serviceMonitor.interval`, `scrapeTimeout`, `relabelings`, `metricRelabelings` | `serviceMonitor.clickhouseMetrics.*`, `serviceMonitor.operatorMetrics.*` |
| `clickhouse.clickhouseOperator.logger`, and each system log table's `ttl` and `flushInterval` | Files in `configs.configdFiles` ([System log tables](#100-operator-system-logs-detail)) |
| `clickhouse.clickhouseOperator.name`, `clickhouse.nameOverride`, `clickhouse.fullnameOverride` | `fullnameOverride`, set to the old operator name to keep it ([Renamed objects](#100-objects)) |
| `clickhouse.clickhouseOperator.version`, `clickhouse.clickhouseOperator.service.enabled` | No replacement. Remove them. |

<a id="100-objects"></a>
#### Renamed objects

Update any selector, scrape configuration or reference of your own that uses these objects:

| Object | Old | New |
|---|---|---|
| Operator Pod labels and Deployment selector | `app.kubernetes.io/name: clickhouse`, `app.kubernetes.io/component: operator` | `app.kubernetes.io/name: clickhouse-operator` |
| Ports of Service `<release>-clickhouse-operator-metrics` | `<release>-clickhouse-operator-metrics` (8888) | `ch-metrics` (8888), `op-metrics` (9999) |
| Operator ServiceMonitor | `<release>-clickhouse-operator-metrics` | `<release>-clickhouse-operator-clickhouse-metrics`, endpoints `ch-metrics` and `op-metrics` |
| Operator ConfigMaps | `<release>-clickhouse-operator-etc-files`, `-etc-confd-files`, `-etc-configd-files`, `-etc-templatesd-files`, `-etc-usersd-files` | `<release>-clickhouse-operator-files`, `-confd-files`, `-configd-files`, `-templatesd-files`, `-usersd-files` |
| Operator containers | `operator`, `metrics-exporter` | `altinity-clickhouse-operator`, `metrics-exporter` |
| Operator objects under `clickhouse.nameOverride`, `clickhouse.fullnameOverride` or `clickhouse.clickhouseOperator.name` | `<clickhouse name>-operator`, `<clickhouse name>-<name>` | `<release>-clickhouse-operator`. Set `altinity-clickhouse-operator.fullnameOverride` to keep the old name. |

<a id="100-operator-system-logs-detail"></a>
#### System log tables

- The logger and each table's time to live (TTL) and flush interval are now each set in an XML file under `altinity-clickhouse-operator.configs.configdFiles`.
- For each key you set, copy the default file from this chart's `values.yaml` into your values and edit it.
- The TTL, in days, is in the `engine` line. The flush interval is in `flush_interval_milliseconds`.
- The default for `partLog` is in Altinity's chart: `helm show values altinity-clickhouse-operator --repo https://helm.altinity.com --version 0.27.4`.

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

- **Affects:** Upgrades with `--no-hooks`, Argo CD without hooks or `clickhouse.operatorUpgradeHook.enabled: false`, and any `helm rollback` to chart 0.151.0.
- **Symptom:** The upgrade or rollback fails on the operator Deployment's selector, which is immutable.
- **Cause:** The operator Deployment's selector changed in 1.0.0, and the Deployment of the other version is still in place.
- **Resolution:** Delete the Deployment, then run the upgrade or rollback again. Before an upgrade, this selector matches it under any old name, with `clickhouse.namespace` and `clickhouse.nameOverride` in place of `<namespace>` and `clickhouse` when set:

  ```bash
  kubectl -n <namespace> delete deployment -l app.kubernetes.io/name=clickhouse,app.kubernetes.io/instance=<release>,app.kubernetes.io/component
  ```

<a id="100-signoz"></a>
### SigNoz

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

#### Setup-specific actions

| If you | Do |
|---|---|
| Have `/`, `?`, `#` or `%` in the ClickHouse password | Use a password without those characters. SigNoz cannot parse its connection string with them. |
| Set a `signoz.env` key named like a chart variable, such as `SIGNOZ_SQLSTORE_*` or `POSTGRES_*` | Remove the key unless you intend its value to apply. It now overrides the chart's variable. |

<a id="100-collector"></a>
### Collector

#### Moved values

| Old key | New key | Note |
|---|---|---|
| `otelCollector.additionalEnvs` | `otelCollector.env` | The same map. A list of `name` and `value` entries also works. |
| `otelCollector.command.extraArgs` | `otelCollector.extraArgs` | |
| `otelCollector.command.name` | Removed | The collector always runs `/signoz-otel-collector`. |
| `otelCollector.customLivenessProbe` | `otelCollector.livenessProbe` | |
| `otelCollector.customReadinessProbe` | `otelCollector.readinessProbe` | |
| `otelCollector.image.registry` | The registry prefix in `otelCollector.image.repository` | `repository: docker.io/signoz/signoz-otel-collector` |
| `otelCollector.livenessProbe`, `readinessProbe` with `enabled`, `port` or `path` | The same keys, as probe objects | `httpGet: {path: /, port: 13133}` |
| `otelCollector.lowCardinalityExceptionGrouping` | `LOW_CARDINAL_EXCEPTION_GROUPING` in `otelCollector.env` | |
| `otelCollector.podAnnotations` | `otelCollector.pod.annotations` | |
| `otelCollector.podLabels` | `otelCollector.pod.labels` | |
| `otelCollector.securityContext` | `otelCollector.containerSecurityContext` | |

#### Setup-specific actions

| If you | Do |
|---|---|
| Enabled `otelCollector.ports.zipkin` or `jaeger-compact` with only `enabled: true` | Also set `containerPort`, `servicePort` and `protocol` (`9411` over `TCP`, `6831` over `UDP`). The chart no longer defines these entries. |

<a id="100-migrator"></a>
### Schema migrator

#### Moved values

| Old key | New key | Note |
|---|---|---|
| `telemetryStoreMigrator.upgradeHelmHooks` | Removed | |

#### Setup-specific actions

| If you | Do |
|---|---|
| Set `telemetryStoreMigrator.name` | Keep it to at most 57 characters. |
| Reference or wait for Job `signoz-telemetrystore-migrator` | Use `signoz-telemetrystore-migrator-<revision>`. Every install and upgrade creates a new Job. Set `telemetryStoreMigrator.enabled: false` to skip one revision. |
| Bind a cloud identity or anything else to ServiceAccount `signoz-telemetrystore-migrator`, or set `telemetryStoreMigrator.serviceAccount.annotations` | Set `telemetryStoreMigrator.serviceAccount.create: true`. It now defaults to `false`. |
| Set `telemetryStoreMigrator.serviceAccount.name` without `create: true` | Add `create: true`, or create the account yourself. |
| Upgraded this release on chart 0.151.0 or earlier | After the upgrade, delete the leftover Job `signoz-telemetrystore-migrator`, and its ServiceAccount unless `create` is true or `serviceAccount.name` names it. |

<a id="100-postgres"></a>
### Postgres

- The upgrade moves the bundled Postgres database onto its PVC.
- Pre-upgrade Job `<release>-postgresql-upgrade-backup` dumps it to `backups/pre-upgrade.sql` on the PVC.
- Postgres loads the dump on its first start.

#### Setup-specific actions

| If you | Do |
|---|---|
| Run the bundled Postgres | Make no changes in SigNoz while the upgrade runs. Changes written after the dump are not included in it. |
| Scaled Postgres to 0 with `kubectl scale` | Start it before you upgrade. Otherwise the backup Job runs and times out. Alternatively, take the dump manually and set `postgresql.upgradeBackupHook.enabled: false` ([guide]). |
| Mount your own `/docker-entrypoint-initdb.d` | Take the dump manually and set `postgresql.upgradeBackupHook.enabled: false` ([guide]). |

The backup Job does not run in any of these cases. Take the dump manually first ([guide]):

- `--no-hooks` (Terraform `helm_release`: `disable_webhooks = true`)
- `postgresql.upgradeBackupHook.enabled: false`
- a `ReadWriteOncePod` PVC
- `postgresql.replicaCount: 0` in your values

> [!CAUTION]
> Without the backup Job or a manual dump, Postgres starts on an empty data directory without any warning.

<a id="100-postgres-troubleshooting"></a>
#### Troubleshooting

<a id="100-ts-pg-backup"></a>
##### `pre-upgrade hooks failed` with `job <release>-postgresql-upgrade-backup failed`

- **Affects:** Releases with the bundled Postgres.
- **Symptom:** `helm upgrade` stops with `BackoffLimitExceeded` or `DeadlineExceeded` for the backup Job. Nothing else in the cluster changed.
- **Cause:**
  - `BackoffLimitExceeded` with `ERROR: cannot connect to Postgres at`: a wrong password or an unreachable Postgres.
  - `BackoffLimitExceeded` with `ERROR: the release mounts its own /docker-entrypoint-initdb.d`: your own init scripts.
  - `DeadlineExceeded`: the Job did not finish in 240 seconds, for example while Postgres is scaled to 0.
- **Resolution:** Read `kubectl -n <namespace> logs job/<release>-postgresql-upgrade-backup`, fix the cause it names and upgrade again. Alternatively, take the dump manually ([guide]) and then set `postgresql.upgradeBackupHook.enabled: false`.
- **Verify:** The Job's log ends with `Dumped database <db> to /claim/backups/pre-upgrade.sql.` or `Nothing to back up.`

<a id="100-ts-pg-not-ready"></a>
##### Why does the Postgres Pod stay not Ready after the upgrade?

- **Affects:** Releases with the bundled Postgres.
- **Symptom:** The Pod runs but is not Ready, with the event `Startup probe failed` and `pre-upgrade.sql has not been loaded`.
- **Cause:** The dump on the PVC was not loaded: it is incomplete (`does not end with COMMIT;`), it failed to load, or the load was interrupted.
- **Resolution:** Load a complete dump manually and rename the file to `pre-upgrade.sql.loaded` ([guide]).
- **Verify:** The Pod becomes Ready.

<a id="100-registry"></a>
### Registry and pull secrets

`global.imageRegistry`, `global.imagePullSecrets` and `imagePullSecrets` apply to every image and Pod in the chart, with three exceptions:

- **ClickHouse operator**, with its CRD hook: only the `altinity-clickhouse-operator.*` keys below.
- **Postgres**, with its backup Job: only `postgresql.image.repository` and `postgresql.imagePullSecrets`.
- **ZooKeeper**: `imagePullSecrets` does not reach it. Use `global.imagePullSecrets` or `zookeeper.image.pullSecrets`.

Set the operator's keys before you upgrade:

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

- Mirror the images that are new in 1.0.0:
  - `clickhouse/clickhouse-keeper:25.12.5`
  - `altinity/clickhouse-operator:0.27.4`
  - `altinity/metrics-exporter:0.27.4`
  - `registry.k8s.io/kubectl:v1.36.3`, for the hooks
  - `signoz/signoz-otel-collector:v0.144.15`, with `clickhouse.logs.system.enabled`
- `global.imageRegistry` now replaces a registry prefix written in a repository. Previously, the chart added it as a prefix. Example: with `repository: docker.io/signoz/signoz` and `global.imageRegistry: my.registry`, the image is `my.registry/signoz/signoz`.
- The chart now lists pull secrets on each Pod and no longer on its ServiceAccounts. If one of your own Pods runs under one of these ServiceAccounts, such as `<release>-signoz`, list the pull secrets in that Pod's spec.

<a id="100-hooks"></a>
### Hooks

- `helm upgrade` runs three pre-upgrade Jobs in this order:
  1. `<release>-postgresql-upgrade-backup`, with bundled Postgres ([Postgres](#100-postgres)).
  2. `<release>-clickhouse-operator-upgrade`, which deletes the operator Deployment that chart 0.151.0 created.
  3. `<release>-clickhouse-operator-crd-install`, which applies the four CRDs. Allow Helm to create its ClusterRole.
- No action is needed unless a row below applies.

#### Setup-specific actions

| If you | Do |
|---|---|
| Apply rendered manifests (`helm template --is-upgrade`, `kubectl apply`), or your GitOps tool does not run Helm hooks | Apply every hook object in hook-weight order (`helm.sh/hook-weight`), lowest first, so that each Job's ServiceAccount, roles and ConfigMaps exist before it. Let each Job finish before the next weight, then apply the rest. Delete the hook objects before a chart version that changes them. |
| Upgrade with `--no-hooks` or `clickhouse.operatorUpgradeHook.enabled: false` | Delete the old operator Deployment manually right before the upgrade ([command](#100-ts-operator-selector)). |
| Upgrade with `--no-hooks` or `altinity-clickhouse-operator.crdHook.enabled: false` | Apply the four CRDs manually before each operator version change. |
| Upgrade with `--no-hooks` or `postgresql.upgradeBackupHook.enabled: false`, with bundled Postgres | See [Postgres](#100-postgres). |

<a id="100-uninstall"></a>
### Uninstall

- Follow the [uninstall steps](README.md#uninstalling-the-chart). `helm uninstall` alone leaves the ClickHouse and Keeper objects held by their finalizers.
- Afterwards, manually delete what you no longer need:
  - the ClickHouse, Keeper and Postgres PVCs
  - the four CRDs
  - a `clickhouse.namespace` Namespace, which the chart now keeps

[guide]: https://signoz.io/docs/operate/migration/upgrade-0-152/
