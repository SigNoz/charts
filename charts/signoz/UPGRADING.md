# Upgrading the SigNoz chart

This file lists what to change when you upgrade to each version of the `signoz` chart. The step-by-step upgrade guides are on signoz.io, linked from each version's section.

- [1.0.0](#100)

<a id="100"></a>
## 1.0.0

<a id="100-before"></a>
### Before you upgrade

This section covers upgrades from chart 0.151.0 or earlier to 1.0.0.

`1.0.0` comes with ClickHouse Keeper by default. To keep using ZooKeeper until you migrate, set:

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

Then:

1. Move the keys your values set, listed in each component's section below.
2. With a private registry, set the operator's own image keys ([Registry and pull secrets](#100-registry)).
3. With the bundled Postgres, make no changes in SigNoz while the upgrade runs ([Postgres](#100-postgres)).
4. With `--no-hooks`, Argo CD or rendered manifests, run the hook steps yourself ([Hooks](#100-hooks)).

Step by step: [the upgrade guide][guide].

<a id="100-ts-values"></a>
#### `must change before the chart can be installed`

- **Affects:** Any release whose values set a key that moved or was removed in 1.0.0.
- **Symptom:** `helm upgrade` fails with `1 value must change before the chart can be installed:` or `<n> values must change before the chart can be installed:`, then one line per key. Nothing in the cluster changed.
- **Cause:** Your values still use the old keys.
- **Resolution:** Move each key the error lists, as its component's section below shows.
- **Verify:** `helm template <release> <chart> -f <values>` renders without the error.

<a id="100-clickhouse"></a>
### ClickHouse

Move these keys:

| Old key | New key | Note |
|---|---|---|
| `clickhouse.additionalVolumeMounts` | `clickhouse.extraVolumeMounts` | |
| `clickhouse.additionalVolumes` | `clickhouse.extraVolumes` | |
| `clickhouse.clickhouseOperator` | `altinity-clickhouse-operator` | The keys under it are renamed ([ClickHouse operator](#100-operator)). |
| `clickhouse.customLivenessProbe` | `clickhouse.livenessProbe` | |
| `clickhouse.customReadinessProbe` | `clickhouse.readinessProbe` | |
| `clickhouse.customStartupProbe` | `clickhouse.startupProbe` | |
| `clickhouse.image.registry` | The front of `clickhouse.image.repository` | `repository: docker.io/clickhouse/clickhouse-server` |
| `clickhouse.initContainers.udf` | `clickhouse.udf` | `udf.enabled` and `udf.command`. `udf.image` is ignored: the download runs on `clickhouse.image`. |
| `clickhouse.initContainers`, your own | `clickhouse.extraInitContainers` | A list, where it was a map. |
| `clickhouse.livenessProbe`, `readinessProbe`, `startupProbe` with `enabled`, `port` or `path` | The same keys, as probe objects | `httpGet: {path: /ping, port: http}`, or `null` for no probe. For another handler, also set `httpGet: null`. |
| `clickhouse.logs.system.image.registry` | The front of `clickhouse.logs.system.image.repository` | |
| `clickhouse.namespace` (another namespace) | The same key | Also set `altinity-clickhouse-operator.namespaceOverride` to that namespace, or `watchNamespaces` with `rbac.namespaceScoped: false`. |
| `clickhouse.podAnnotations` | `clickhouse.pod.annotations` | |
| `clickhouse.podLabels` | `clickhouse.pod.labels` | |
| `clickhouse.securityContext` | `clickhouse.podSecurityContext` | Without `enabled`. |
| `clickhouse.zookeeper` | `zookeeper`, at the top level | With `enabled: true` ([Keeper and ZooKeeper](#100-keeper)). |

These defaults changed. Set the old value to keep it:

| Key | Old value | New value |
|---|---|---|
| `clickhouse.logs.system.config.service.telemetry.metrics.address` | `0.0.0.0:8888` | Not set |
| `clickhouse.logs.system.image.tag` | `0.111.16` | `v0.144.15` |
| `externalClickhouse.existingSecretPasswordKey` | `null` | `password` |

| If you | Do |
|---|---|
| Read the ClickHouse password from a pod spec or the ClickHouseInstallation | Read it from Secret `<release>-clickhouse-credentials`, key `password` (`<fullnameOverride>-credentials` with `clickhouse.fullnameOverride`). |
| Use an external ClickHouse and read Secret `<release>-clickhouse-external`, key `clickhouse-password` | Read Secret `<release>-clickhouse-credentials`, key `password`. |
| Change `clickhouse.password`, `externalClickhouse.password` or `postgresql.auth.password` | Restart SigNoz, the collector and ClickHouse or Postgres afterwards. A change no longer restarts them. |
| Read `CLICKHOUSE_HTTP_PORT` in a config of yours | Write the port number there. `clickhouse.service.httpPort` and `externalClickhouse.httpPort` no longer set the variable. |
| Set `clickhouse.logs.system.enabled: true` | Pin no `clickhouse.logs.system.image.tag` older than the default, and remove from `clickhouse.logs.system.config` the [components 0.144.15 lacks](#100-logs-components). |
| Use the `events.proto` format schema | Add it under `clickhouse.files`. |
| Scale ClickHouse down or rename it | Delete the PersistentVolumeClaims (claims) it leaves by hand when you no longer want the data. The operator now keeps them. |
| Have a ClickHouse name over 34 characters (a release name of 24 or more with the default `-clickhouse`) | Move the data with the [guide] before you shorten the name. |
| Set `externalClickhouse.secure: true` | If `externalClickhouse.tcpPort` serves TLS (usually 9440), add `secure=true` to the exporter data source names (DSNs) in `otelCollector.config`. Otherwise set `secure: false`. |
| Set `global.clusterDomain` | Check that it is your cluster's domain. It now reaches ClickHouse. |
| Pin `clickhouse.image.tag` or `keeper.image.tag` with an `@sha256:` digest | Pin by a tag without a digest. |

<a id="100-logs-components"></a>
Components that collector 0.144.15 lacks:

- `ballastextension`
- `carbonexporter`
- `clickhousemetricsexporter`
- `clickhousemetricsexporterv2`
- `loggingexporter`
- `opencensusexporter`
- `opencensusreceiver`
- `routingprocessor`
- `sapmreceiver`

> [!CAUTION]
> Shortening a ClickHouse name renames the ClickHouseInstallation (for example `signoz-observability-prod-clickhouse` to `signoz-obs-prod-ch`). Helm removes the old one, its claims stay, and the operator builds a new, empty ClickHouse. Move the data with the [guide] first.

<a id="100-keeper"></a>
<a id="100-keeper-default"></a>
### Keeper and ZooKeeper

These defaults changed:

| Key | Old value | New value |
|---|---|---|
| `keeper.enabled` | No such key | `true` |
| `zookeeper.enabled` | `true`, as `clickhouse.zookeeper.enabled` | `false` |
| `zookeeper.preAllocSize` | `65536` | `0` |

| If you | Do |
|---|---|
| Use `clickhouse.externalZookeeper.servers` | Set only `keeper.enabled: false`, and leave `zookeeper.enabled` unset. |
| Set `clickhouse.zookeeper.*` | Move the block to `zookeeper`, with `enabled: true`. |
| Set `zookeeper.global.imageRegistry` or `zookeeper.global.storageClass` | Use `zookeeper.image.registry` and `zookeeper.persistence.storageClass`, or `global.*`. |
| Scrape Service `<release>-zookeeper-metrics` | Keep `zookeeper.enabled: true`. The Service goes with ZooKeeper. |
| Want to move to Keeper | Follow the [guide]. |

> [!CAUTION]
> Without these values, an upgrade or sync of an existing install removes ZooKeeper and points ClickHouse at a new, empty Keeper. The ZooKeeper claims stay, and the [guide] has the way back.

<a id="100-keeper-troubleshooting"></a>
**Troubleshooting**

<a id="100-ts-keeper-crd"></a>
#### `no matches for kind "ClickHouseKeeperInstallation" in version "clickhouse-keeper.altinity.com/v1"`

- **Affects:** Existing installs upgraded with `keeper.enabled` at its default.
- **Symptom:** The first `helm upgrade` fails with this error and `ensure CRDs are installed first`. Nothing in the cluster changed.
- **Cause:** Keeper is on by default, and the cluster does not have its CustomResourceDefinition (CRD) yet.
- **Resolution:** Set the values under [Before you upgrade](#100-before) and upgrade again.
- **Verify:** The upgrade completes and the Helm notes print `ClickHouse coordinates through ZooKeeper.`

<a id="100-ts-no-store"></a>
#### `no coordination store for ClickHouse`

- **Affects:** Values with `keeper.enabled: false` and neither ZooKeeper option.
- **Symptom:** `helm upgrade` or `helm template` fails with this error.
- **Cause:** Keeper is off, `zookeeper.enabled` is not `true`, and `clickhouse.externalZookeeper.servers` is empty.
- **Resolution:** Set `zookeeper.enabled: true`, `keeper.enabled: true` or `clickhouse.externalZookeeper.servers`.
- **Verify:** The Helm notes name the store, such as `ClickHouse coordinates through ZooKeeper.`

<a id="100-ts-empty-keeper"></a>
#### Did ClickHouse switch to an empty Keeper?

- **Affects:** Existing installs upgraded or synced without `zookeeper.enabled: true`, for example through Argo CD or rendered manifests that include the CRDs.
- **Symptom:** The Helm notes print `ClickHouse coordinates through ClickHouse Keeper at keeper-<release>-keeper:2181.`, StatefulSet `<release>-zookeeper` is gone, and replicated tables are read-only.
- **Cause:** Default values replaced ZooKeeper with a new Keeper that holds none of the tables' coordination state.
- **Resolution:** Follow the recovery steps in the [guide]. The chart keeps the ZooKeeper claims.
- **Verify:** StatefulSet `<release>-zookeeper` is back.

<a id="100-operator"></a>
### ClickHouse operator

- The operator moves from 0.21.2 to 0.27.4.
- It now comes from Altinity's chart, `altinity-clickhouse-operator`.
- The upgrade brings the three ClickHouse CRDs to 0.27.4 and adds the Keeper CRD.

Altinity's chart ignores the old key names, so rename each key you set:

| Old key under `clickhouse.clickhouseOperator` | New key under `altinity-clickhouse-operator` |
|---|---|
| `image.*` | `operator.image.*` |
| `resources` | `operator.resources` |
| `metricsExporter.*` | `metrics.image.*`, `metrics.resources`, `metrics.env`. The Service port, type and annotations have no counterpart. |
| `imagePullSecrets`, as names (`[ch-pull]`) | `imagePullSecrets`, as objects (`[{name: ch-pull}]`) |
| `serviceMonitor.interval`, `scrapeTimeout`, `relabelings`, `metricRelabelings` | `serviceMonitor.clickhouseMetrics.*`, `serviceMonitor.operatorMetrics.*` |
| `logger`, and each system log table's `ttl` and `flushInterval` | Files in `configs.configdFiles` ([below](#100-operator-system-logs-detail)) |
| `name`, `version`, `service.enabled` | None: remove them |

<a id="100-objects"></a>
Update anything of yours that selects, scrapes or names these:

| Object | Old | New |
|---|---|---|
| Operator pod labels and Deployment selector | `app.kubernetes.io/name: clickhouse`, `app.kubernetes.io/component: operator` | `app.kubernetes.io/name: clickhouse-operator` |
| Ports of Service `<release>-clickhouse-operator-metrics` | `<release>-clickhouse-operator-metrics` (8888) | `ch-metrics` (8888), `op-metrics` (9999) |
| Operator ServiceMonitor | `<release>-clickhouse-operator-metrics` | `<release>-clickhouse-operator-clickhouse-metrics`, endpoints `ch-metrics` and `op-metrics` |
| Operator ConfigMaps | `<release>-clickhouse-operator-etc-files`, `-etc-confd-files`, `-etc-configd-files`, `-etc-templatesd-files`, `-etc-usersd-files` | `<release>-clickhouse-operator-files`, `-confd-files`, `-configd-files`, `-templatesd-files`, `-usersd-files` |
| Operator containers | `operator`, `metrics-exporter` | `altinity-clickhouse-operator`, `metrics-exporter` |
| Operator objects under `clickhouse.nameOverride`, `clickhouse.fullnameOverride` or `clickhouse.clickhouseOperator.name` | `<clickhouse name>-operator`, `<clickhouse name>-<name>` | `<release>-clickhouse-operator`. Set `altinity-clickhouse-operator.fullnameOverride` to keep the old name. |

<a id="100-operator-system-logs-detail"></a>
**System log tables**

- Each table's time to live (TTL) and flush interval, and the logger, are now one XML file under `altinity-clickhouse-operator.configs.configdFiles`.
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
**Troubleshooting**

<a id="100-ts-operator-selector"></a>
#### `cannot patch "<release>-clickhouse-operator" with kind Deployment`

- **Affects:** Upgrades with `--no-hooks`, Argo CD without hooks or `clickhouse.operatorUpgradeHook.enabled: false`, and any `helm rollback` to chart 0.151.0.
- **Symptom:** The upgrade or rollback fails on the operator Deployment's selector, which is immutable.
- **Cause:** The operator Deployment's selector changed in 1.0.0, and the Deployment of the other version is still in place.
- **Resolution:** Delete the Deployment, then run the upgrade or rollback again. Before an upgrade, this selector matches it under any old name, with `clickhouse.namespace` and `clickhouse.nameOverride` in place of `<namespace>` and `clickhouse` when set:

  ```bash
  kubectl -n <namespace> delete deployment -l app.kubernetes.io/name=clickhouse,app.kubernetes.io/instance=<release>,app.kubernetes.io/component
  ```

<a id="100-signoz"></a>
### SigNoz

Move these keys:

| Old key | New key | Note |
|---|---|---|
| `signoz.additionalArgs` | `signoz.extraArgs` | |
| `signoz.additionalVolumeMounts` | `signoz.extraVolumeMounts` | |
| `signoz.additionalVolumes` | `signoz.extraVolumes` | |
| `signoz.customLivenessProbe` | `signoz.livenessProbe` | |
| `signoz.customReadinessProbe` | `signoz.readinessProbe` | |
| `signoz.image.registry` | The front of `signoz.image.repository` | `repository: docker.io/signoz/signoz` |
| `signoz.livenessProbe`, `readinessProbe` with `enabled`, `port` or `path` | The same keys, as probe objects | `httpGet: {path: /api/v1/health, port: http}` |
| `signoz.podAnnotations` | `signoz.pod.annotations` | |
| `signoz.securityContext` | `signoz.containerSecurityContext` | |

| If you | Do |
|---|---|
| Have `/`, `?`, `#` or `%` in the ClickHouse password | Keep those characters out of the password: SigNoz cannot parse its connection string with them. |
| Set a `signoz.env` key named like a chart variable, such as `SIGNOZ_SQLSTORE_*` or `POSTGRES_*` | Delete the key unless its value should apply. It now replaces the chart's variable. |

<a id="100-collector"></a>
### Collector

Move these keys:

| Old key | New key | Note |
|---|---|---|
| `otelCollector.additionalEnvs` | `otelCollector.env` | A list: `[{name: FOO, value: bar}]`. |
| `otelCollector.command.extraArgs` | `otelCollector.extraArgs` | |
| `otelCollector.command.name` | Removed | The collector always runs `/signoz-otel-collector`. |
| `otelCollector.customLivenessProbe` | `otelCollector.livenessProbe` | |
| `otelCollector.customReadinessProbe` | `otelCollector.readinessProbe` | |
| `otelCollector.image.registry` | The front of `otelCollector.image.repository` | `repository: docker.io/signoz/signoz-otel-collector` |
| `otelCollector.livenessProbe`, `readinessProbe` with `enabled`, `port` or `path` | The same keys, as probe objects | `httpGet: {path: /, port: 13133}` |
| `otelCollector.lowCardinalityExceptionGrouping` | `LOW_CARDINAL_EXCEPTION_GROUPING` in `otelCollector.env` | |
| `otelCollector.podAnnotations` | `otelCollector.pod.annotations` | |
| `otelCollector.podLabels` | `otelCollector.pod.labels` | |
| `otelCollector.securityContext` | `otelCollector.containerSecurityContext` | |

| If you | Do |
|---|---|
| Turned on `otelCollector.ports.zipkin` or `jaeger-compact` with `enabled: true` alone | Also write `containerPort`, `servicePort` and `protocol` (`9411` over `TCP`, `6831` over `UDP`). The chart no longer ships these entries. |

<a id="100-migrator"></a>
### Schema migrator

Move these keys:

| Old key | New key | Note |
|---|---|---|
| `telemetryStoreMigrator.name` | The same key | At most 57 characters. |
| `telemetryStoreMigrator.upgradeHelmHooks` | Removed | |

| If you | Do |
|---|---|
| Name or wait for Job `signoz-telemetrystore-migrator` | Use `signoz-telemetrystore-migrator-<revision>`: a new Job on every install and upgrade. Set `telemetryStoreMigrator.enabled: false` to skip one revision. |
| Bind something to ServiceAccount `signoz-telemetrystore-migrator`, such as a cloud identity, or set `telemetryStoreMigrator.serviceAccount.annotations` | Set `telemetryStoreMigrator.serviceAccount.create: true`. It now defaults to `false`. |
| Set `telemetryStoreMigrator.serviceAccount.name` without `create: true` | Add `create: true`, or create the account yourself. |
| Upgraded this release on chart 0.151.0 or earlier | Afterwards delete the left-over Job `signoz-telemetrystore-migrator`, and its ServiceAccount unless `create` is true or `serviceAccount.name` names it. |

<a id="100-postgres"></a>
### Postgres

- The upgrade moves the bundled Postgres database onto its claim.
- Pre-upgrade Job `<release>-postgresql-upgrade-backup` dumps it to `backups/pre-upgrade.sql` on the claim.
- Postgres loads the dump on its first start.

| If you | Do |
|---|---|
| Run the bundled Postgres | Make no changes in SigNoz while the upgrade runs: changes written after the dump are not in it. |
| Upgrade with `--no-hooks` (Terraform `helm_release`: `disable_webhooks = true`), `postgresql.upgradeBackupHook.enabled: false`, a `ReadWriteOncePod` claim or `postgresql.replicaCount: 0` | Take the dump by hand first ([guide]). |
| Have Postgres scaled to 0 | Start it before you upgrade, or dump by hand and set `postgresql.upgradeBackupHook.enabled: false` ([guide]). |
| Mount your own `/docker-entrypoint-initdb.d` | Dump by hand and set `postgresql.upgradeBackupHook.enabled: false` ([guide]). |

> [!CAUTION]
> Without the backup Job or a dump taken by hand, Postgres starts on an empty data folder with no message.

<a id="100-postgres-troubleshooting"></a>
**Troubleshooting**

<a id="100-ts-pg-backup"></a>
#### `pre-upgrade hooks failed` with `job <release>-postgresql-upgrade-backup failed`

- **Affects:** Releases with the bundled Postgres.
- **Symptom:** `helm upgrade` stops with `BackoffLimitExceeded` or `DeadlineExceeded` for the backup Job. Nothing else in the cluster changed.
- **Cause:** With `BackoffLimitExceeded`, the Job could not dump: a wrong password or an unreachable Postgres (`ERROR: cannot connect to Postgres at`), or your own `/docker-entrypoint-initdb.d` (`ERROR: the release mounts its own /docker-entrypoint-initdb.d`). With `DeadlineExceeded`, the Job did not finish in 240 seconds, for example while Postgres is scaled to 0.
- **Resolution:** Read `kubectl -n <namespace> logs job/<release>-postgresql-upgrade-backup`, fix the cause it names and upgrade again. Or take the dump by hand ([guide]) and then set `postgresql.upgradeBackupHook.enabled: false`.
- **Verify:** The Job's log ends with `Dumped database <db> to /claim/backups/pre-upgrade.sql.` or `Nothing to back up.`

<a id="100-ts-pg-not-ready"></a>
#### Why does the Postgres pod stay not Ready after the upgrade?

- **Affects:** Releases with the bundled Postgres.
- **Symptom:** The pod runs but is not Ready, with the event `Startup probe failed` and `pre-upgrade.sql has not been loaded`.
- **Cause:** The dump on the claim was not loaded: it is incomplete (`does not end with COMMIT;`), it failed to load, or the load was interrupted.
- **Resolution:** Load a complete dump by hand and rename the file to `pre-upgrade.sql.loaded` ([guide]).
- **Verify:** The pod becomes Ready.

<a id="100-registry"></a>
### Registry and pull secrets

`global.imageRegistry`, `global.imagePullSecrets` and `imagePullSecrets` cover every image and pod of the chart, with three exceptions:

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

Also:

- Mirror the images that are new in 1.0.0: `clickhouse/clickhouse-keeper:25.12.5`, `altinity/clickhouse-operator:0.27.4`, `altinity/metrics-exporter:0.27.4`, `registry.k8s.io/kubectl:v1.36.3` (the hooks) and, with `clickhouse.logs.system.enabled`, `signoz/signoz-otel-collector:v0.144.15`.
- `global.imageRegistry` now replaces a registry written at the front of a repository. Before, the chart prefixed it. Example: with `repository: docker.io/signoz/signoz` and `global.imageRegistry: my.registry`, the image is `my.registry/signoz/signoz`.
- The chart now lists pull secrets on each pod and no longer on its ServiceAccounts. If a pod of yours runs under one of them, such as `<release>-signoz`, list the pull secrets in that pod's spec.

<a id="100-hooks"></a>
### Hooks

- `helm upgrade` runs three pre-upgrade Jobs in this order:
  1. `<release>-postgresql-upgrade-backup`, with bundled Postgres ([Postgres](#100-postgres)).
  2. `<release>-clickhouse-operator-upgrade`, which deletes the operator Deployment that chart 0.151.0 created.
  3. `<release>-clickhouse-operator-crd-install`, which applies the four CRDs. Allow Helm to create its ClusterRole.
- Act only if a row below applies.

| If you | Do |
|---|---|
| Apply rendered manifests (`helm template --is-upgrade`, `kubectl apply`), or your GitOps tool does not run Helm hooks | Apply every hook object in hook-weight order (`helm.sh/hook-weight`), lowest first, so that each Job's ServiceAccount, roles and ConfigMaps exist before it. Let each Job finish before the next weight, then apply the rest. Delete the hook objects before a chart version that changes them. |
| Upgrade with `--no-hooks` or `clickhouse.operatorUpgradeHook.enabled: false` | Delete the old operator Deployment by hand right before the upgrade ([command](#100-ts-operator-selector)). |
| Upgrade with `--no-hooks` or `altinity-clickhouse-operator.crdHook.enabled: false` | Apply the four CRDs by hand before each operator version change. |
| Upgrade with `--no-hooks` or `postgresql.upgradeBackupHook.enabled: false`, with bundled Postgres | See [Postgres](#100-postgres). |

<a id="100-rollback"></a>
### Rollback

- Do not roll back once ClickHouse runs on Keeper.
- With bundled Postgres, a rollback to chart 0.151.0 starts SigNoz on an empty database. The claim keeps the real one, and upgrading forward again brings it back. You lose the changes made in SigNoz while rolled back.
- To roll back to a chart 0.151.0 revision while ClickHouse still runs on ZooKeeper:
  1. Delete the ClickHouseKeeperInstallation, with Keeper on, and wait.
  2. Delete the operator Deployment right before the rollback.
  3. Roll back.

```bash
kubectl -n <namespace> delete clickhousekeeperinstallation <release>-keeper --wait   # with keeper.enabled: true
kubectl -n <namespace> delete deployment <release>-clickhouse-operator
helm rollback <release> <revision> -n <namespace>
```

<a id="100-uninstall"></a>
### Uninstall

- Follow the [uninstall steps](README.md#uninstalling-the-chart): a plain `helm uninstall` leaves the ClickHouse and Keeper objects on their finalizers.
- Afterwards delete by hand what you no longer want:
  - the ClickHouse, Keeper and Postgres claims
  - the four CRDs
  - a `clickhouse.namespace` Namespace, which the chart now keeps

[guide]: https://signoz.io/docs/operate/migration/upgrade-0-152/
