# Upgrade the SigNoz chart to 0.152.0

Chart 0.152.0 folds `charts/clickhouse` into `charts/signoz`, renders ClickHouse from `charts/signoz`, and installs the ClickHouse Operator as a dependency from Altinity's chart `altinity-clickhouse-operator` 0.27.4 ([#948](https://github.com/SigNoz/charts/pull/948)). ClickHouse Keeper replaces ZooKeeper as ClickHouse's coordination store ([#956](https://github.com/SigNoz/charts/pull/956)). [#958](https://github.com/SigNoz/charts/issues/958) and [#959](https://github.com/SigNoz/charts/issues/959) explain why.

## Find your sections

| If you | Read |
| --- | --- |
| Upgrade from 0.151.0 or earlier (every install) | [1. The first upgrade](#1-the-first-upgrade) |
| Set `clickhouse.zookeeper.*` in your values | [2. ZooKeeper values](#2-zookeeper-values) |
| Set `clickhouse.clickhouseOperator.*` in your values | [3. Operator values](#3-operator-values) |
| Set a system log table's `ttl` or `flushInterval` in your values | [4. System log tables](#4-system-log-tables) |
| Set any key from the moved-keys table in your values | [5. Moved keys](#5-moved-keys) |
| Set `clickhouse.logs.system.enabled: true` in your values | [5. Moved keys](#5-moved-keys) |
| Set `clickhouse.fullnameOverride`, `clickhouse.nameOverride` or `clickhouse.namespace` in your values, or use a release name that contains `clickhouse` | [6. Names and namespaces](#6-names-and-namespaces) |
| Have something outside the chart that names, selects or watches chart objects | [7. Objects](#7-objects) |
| Set `global.imageRegistry`, `global.imagePullSecrets`, `imagePullSecrets` or a component's `imagePullSecrets` | [8. Registry and pull secrets](#8-registry-and-pull-secrets) |
| Run the operator yourself, turn a hook off, or deploy through Argo CD or Terraform | [9. Hooks and deployers](#9-hooks-and-deployers) |
| Run an external ZooKeeper | [10. External ZooKeeper](#10-external-zookeeper) |
| Plan to move from ZooKeeper to ClickHouse Keeper | [11. ZooKeeper to ClickHouse Keeper](#11-zookeeper-to-clickhouse-keeper) |
| Plan to uninstall or roll back | [12. Uninstall and rollback](#12-uninstall-and-rollback) |
| Set `signoz.env`, a port under `signoz.service`, `signoz.service.labels` or `signoz.ingress.hosts` in your values | [13. The SigNoz container](#13-the-signoz-container) |
| Run the schema migrator (on by default), set a `telemetryStoreMigrator.*` key, or upgrade with `--no-hooks` | [14. Schema migrator](#14-schema-migrator) |
| Set an `otelCollector.*` key or `signoz.service.opampPort` in your values | [15. The collector](#15-the-collector) |
| Set `postgresql.enabled: true` in your values | [16. Bundled Postgres](#16-bundled-postgres) |

Commands in this guide use these placeholders:

- `<release>`: your release name.
- `<namespace>`: the namespace the object lives in. This is the release namespace, or `clickhouse.namespace` when you set it.
- `<clickhouse.name>`: `clickhouse.nameOverride`, or `clickhouse` when that is unset.
- `<clickhouse.fullname>`: the name of your ClickHouseInstallation, `<release>-clickhouse` by default.
- `<keeper.fullname>`: the name of your ClickHouseKeeperInstallation, `keeper.fullnameOverride` when set, else `<release>-keeper`, or `<release>-<keeper.nameOverride>` with `keeper.nameOverride` set.
- `<postgresql.fullname>`: the full name of the bundled Postgres chart, the name of its StatefulSet, `<release>-postgresql` by default ([section 16](#16-bundled-postgres)).

To list both installations with their names, run:

```bash
kubectl get chi,chk -n <namespace> -l app.kubernetes.io/instance=<release>
```

## 1. The first upgrade

### Applies to

Every install upgrading from 0.151.0 or earlier.

### What changes

The chart installs ClickHouse Keeper unless `keeper.enabled: false`, and installs the bundled ZooKeeper only with `zookeeper.enabled: true`.

Helm maps every rendered object against the cluster before any hook runs, so an existing install's first upgrade is refused while the chart renders a ClickHouseKeeperInstallation and the Keeper CRD is missing.

During the upgrade, a pre-upgrade hook replaces the old operator Deployment with the 0.27.4 one, and Altinity's CRD hook adds the Keeper CRD ([section 9](#9-hooks-and-deployers)).

The ClickHouse pods roll once, because their pod template now carries only the selector labels, names the image `clickhouse/clickhouse-server` instead of `docker.io/clickhouse/clickhouse-server`, runs the `<clickhouse.fullname>-udf-init` init container on that image instead of `docker.io/alpine:3.18.2`, and has no `scripts` volume or `/scripts` mount; with `clickhouse.logs.system.enabled: true`, it also has no `lifecycle.postStart` hook and runs the sidecar as `signoz/signoz-otel-collector:v0.144.15` with the command `/signoz-otel-collector`, instead of `docker.io/signoz/signoz-otel-collector:0.111.16` with `/signoz-collector`. The ZooKeeper pod rolls once, because its pod template carries the ZooKeeper chart's new version `0.0.2` and `ZOO_PRE_ALLOC_SIZE` `0` ([section 7](#7-objects)).

### You must

1. Pick one of two routes for this upgrade and write it into your values file. If you run an external ZooKeeper, do [section 10](#10-external-zookeeper) instead of this step.

   - **Stay on ZooKeeper with Keeper off.** Set:

     ```yaml
     zookeeper:
       enabled: true
     keeper:
       enabled: false
     ```

   - **Prepare Keeper beside ZooKeeper.** Apply Altinity's Keeper CRD, then upgrade with ZooKeeper on. Keeper comes up idle, and ClickHouse stays on ZooKeeper.

     ```bash
     kubectl apply -f https://github.com/Altinity/clickhouse-operator/raw/release-0.27.4/deploy/helm/clickhouse-operator/crds/CustomResourceDefinition-clickhousekeeperinstallations.clickhouse-keeper.altinity.com.yaml
     ```

     ```yaml
     zookeeper:
       enabled: true
     ```

2. After you finish every other section that applies to you, upgrade:

   ```bash
   helm upgrade <release> signoz/signoz --version 0.152.0 -n <namespace> -f values.yaml
   ```

3. Keep `zookeeper.enabled: true` in your values until [section 11](#11-zookeeper-to-clickhouse-keeper) is done.

> [!WARNING]
> Once the Keeper CRD exists, an upgrade without `zookeeper.enabled: true` and with Keeper on points ClickHouse at an empty Keeper, and every replicated table goes read-only. The way back is in section 11, under [If you upgraded without `zookeeper.enabled: true`](#if-you-upgraded-without-zookeeperenabled-true).

### You will see

- Without either route, `helm upgrade` stops with `no matches for kind "ClickHouseKeeperInstallation" in version "clickhouse-keeper.altinity.com/v1"`. The release stays at its old revision, with its pods untouched. `helm upgrade --no-hooks` stops the same way.
- During the upgrade, the operator hook logs `deployment.apps "<old operator Deployment>" deleted from <namespace> namespace`.
- During the upgrade, the CRD hook logs `serverside-applied` for four CRDs, `clickhousekeeperinstallations.clickhouse-keeper.altinity.com` among them.
- The ClickHouse, ZooKeeper, signoz and otel-collector pods are each recreated once. Every pod is Ready about 3 minutes after `helm upgrade` returns.
- A table seeded with 1000 rows before the upgrade holds the same 1000 rows after it, and no replica is read-only.
- The notes printed after the upgrade say `3. ClickHouse coordinates through ZooKeeper.` and end with the ZooKeeper deprecation notice.
- With Keeper on beside ZooKeeper, the ClickHouseKeeperInstallation reports `Completed` about a minute after `helm upgrade` returns. Keeper holds 4 znodes, no other pod restarts, and ClickHouse stays on ZooKeeper.

### Verify

```bash
kubectl get chi -n <namespace> -l app.kubernetes.io/instance=<release>
```

`STATUS` is `Completed` and `VERSION` is `0.27.4`.

## 2. ZooKeeper values

### Applies to

Your values set any key under `clickhouse.zookeeper`.

### What changes

The bundled ZooKeeper is a dependency of `charts/signoz` itself, so its values live at the top-level `zookeeper` key, under the same names as before. `clickhouse.zookeeper` set to anything other than `null`, an empty map included, fails the render with a message naming the top-level `zookeeper` key. ClickHouse's coordination hosts render as before.

### You must

1. Move every key under `clickhouse.zookeeper` to the top-level `zookeeper` key, unchanged.
2. Delete `clickhouse.zookeeper.enabled: false` instead of moving it. ZooKeeper is off while `zookeeper.enabled` is unset. For an external ZooKeeper, see [section 10](#10-external-zookeeper).
3. Plan the move to ClickHouse Keeper in [section 11](#11-zookeeper-to-clickhouse-keeper). The bundled ZooKeeper chart is deprecated, and a later release removes it. [#958](https://github.com/SigNoz/charts/issues/958) announces when.

### You will see

A release on 0.149.0 with `clickhouse.zookeeper.replicaCount: 3`, upgraded with `zookeeper.replicaCount: 3`, kept its three ZooKeeper pods, its three `data-<release>-zookeeper-<n>` claims and the same three coordination hosts in its ClickHouseInstallation.

### Verify

```bash
kubectl get chi -n <namespace> -l app.kubernetes.io/instance=<release> -o jsonpath='{.items[0].spec.configuration.zookeeper}'
```

It prints one host per ZooKeeper replica, as before the upgrade:

```text
{"nodes":[{"host":"<release>-zookeeper-0.<release>-zookeeper-headless","port":2181}]}
```

## 3. Operator values

### Applies to

Your values set any key under `clickhouse.clickhouseOperator`.

### What changes

The operator comes from Altinity's chart `altinity-clickhouse-operator` 0.27.4. It takes its settings under the top-level `altinity-clickhouse-operator` key, in Altinity's key names. `clickhouse.clickhouseOperator` set to anything other than `null`, an empty map included, fails the render with a message naming the top-level `altinity-clickhouse-operator` key. The operator and metrics-exporter images are `0.27.4`.

The pre-upgrade hook deletes the old operator Deployment. It selects that Deployment by the presence of its `app.kubernetes.io/component` label, whatever value `clickhouse.clickhouseOperator.name` gave it.

### You must

1. Move each key under `altinity-clickhouse-operator`, as this table shows:

   | Old key under `clickhouse.clickhouseOperator` | New key under `altinity-clickhouse-operator` | Notes |
   | --- | --- | --- |
   | `image.registry` | `operator.image.registry` | |
   | `image.repository` | `operator.image.repository` | |
   | `image.pullPolicy` | `operator.image.pullPolicy` | |
   | `image.tag`, `metricsExporter.image.tag`, `version` | None | Leave them out so both images run `0.27.4` |
   | `imagePullSecrets` | `imagePullSecrets` | As Kubernetes objects (`- name: <secret>`) |
   | `env` | `operator.env` | |
   | `metricsExporter.image.registry` | `metrics.image.registry` | |
   | `metricsExporter.image.repository` | `metrics.image.repository` | |
   | `metricsExporter.image.pullPolicy` | `metrics.image.pullPolicy` | |
   | `metricsExporter.env` | `metrics.env` | |
   | `metricsExporter.name`, `metricsExporter.service.type`, `metricsExporter.service.annotations`, `metricsExporter.service.port`, `service.enabled` | None | [Section 7](#7-objects) describes the metrics Service |
   | `serviceAccount.*`, `secret.*`, `podLabels`, `podAnnotations`, `nodeSelector`, `tolerations`, `affinity`, `topologySpreadConstraints`, `podSecurityContext` | The same names | |
   | `priorityClassName` | `operator.priorityClassName` | |
   | `labels` | `commonLabels` | Reaches every operator object |
   | `annotations` | `commonAnnotations` | Reaches every operator object |
   | `serviceMonitor.enabled`, `serviceMonitor.additionalLabels` | The same names | |
   | `serviceMonitor.interval`, `serviceMonitor.scrapeTimeout`, `serviceMonitor.relabelings`, `serviceMonitor.metricRelabelings` | `serviceMonitor.clickhouseMetrics.*` and `serviceMonitor.operatorMetrics.*` | One block per endpoint |
   | `configs.confdFiles` | `configs.confdFiles` | |
   | `logger.*`, and the system log tables' `ttl` and `flushInterval` | See [section 4](#4-system-log-tables) | |
   | `name` | None | To keep a custom value on the pod, set `podLabels."app.kubernetes.io/component"`. [Section 6](#6-names-and-namespaces) says how to keep the object names |

2. Delete the `clickhouse.clickhouseOperator` block.

### You will see

The operator pod runs two containers, `altinity/clickhouse-operator:0.27.4` and `altinity/metrics-exporter:0.27.4`, and reports `2/2 Running`.

### Verify

```bash
kubectl get deployment -n <namespace> -l app.kubernetes.io/name=clickhouse-operator,app.kubernetes.io/instance=<release> -o jsonpath='{.items[0].spec.template.spec.containers[*].image}'
```

```text
altinity/clickhouse-operator:0.27.4 altinity/metrics-exporter:0.27.4
```

## 4. System log tables

### Applies to

Your values set `ttl` or `flushInterval` for a system log table under `clickhouse.clickhouseOperator`, or a key under `clickhouse.clickhouseOperator.logger`.

### What changes

The fourteen `clickhouse.clickhouseOperator.<table>.ttl` and `.flushInterval` pairs, and the `logger` keys, have no replacement keys. Each table's configuration is a whole file: a value under `altinity-clickhouse-operator.configs.configdFiles.<file>`, written as the operator reads it. The default files carry the same TTLs and flush intervals as the old defaults. A file set to `null` leaves that table unconfigured.

### You must

1. For each table you tuned, copy its default file from the chart's `values.yaml` into your values. Write your TTL, in days, into the `engine` line, and your flush interval, in milliseconds, into `flush_interval_milliseconds`. Each old key has one file:

   | Old key | File |
   | --- | --- |
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

   The default for `01-clickhouse-04-part_log.xml` is in Altinity's chart. To see it, run:

   ```bash
   helm show values altinity-clickhouse-operator --repo https://helm.altinity.com --version 0.27.4
   ```

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

2. To leave a table unconfigured, set its file to `null`:

   ```yaml
   altinity-clickhouse-operator:
     configs:
       configdFiles:
         01-clickhouse-15-zookeeper_log.xml: null
   ```

3. Delete the `ttl`, `flushInterval` and `logger` keys from `clickhouse.clickhouseOperator`.

### You will see

The kind runs kept the default files. The Verify command shows the files the operator received.

### Verify

```bash
kubectl get configmap -n <namespace> -l app.kubernetes.io/name=clickhouse-operator,app.kubernetes.io/instance=<release> -o yaml | grep 'TTL event_date'
```

It prints one `engine` line per configured table, fourteen with the defaults, each with the TTL you wrote.

## 5. Moved keys

### Applies to

Your values set a key in the table below.

### What changes

ClickHouse, SigNoz (`signoz.*`) and collector (`otelCollector.*`) values take the Kubernetes shape and are rendered as given:

- Probes are probe objects.
- The pod and container security contexts are two keys, `podSecurityContext` and `containerSecurityContext`.
- Pod labels and annotations are `pod.labels` and `pod.annotations`.
- Extra volumes are `extraVolumes` and `extraVolumeMounts`, and the SigNoz and collector arguments are `extraArgs`.
- A ClickHouse image block is `repository`, `tag` and `pullPolicy`, with any registry at the front of `repository`.
- Your own ClickHouse init containers are `clickhouse.extraInitContainers`, a list of Container objects.

`zookeeper.enabled` unset now means no ZooKeeper. Keys under `clickhouse.zookeeper` are in [section 2](#2-zookeeper-values), and keys under `clickhouse.clickhouseOperator` are in [sections 3](#3-operator-values) and [4](#4-system-log-tables).

An old values file fails the render once, with one line for every old key it holds, naming the key that replaces it and what to write. "You will see" below shows the output.

> [!NOTE]
> A probe or security context set to `null` renders none, while an empty map keeps the defaults, because Helm merges maps. A probe has one handler, so a non-HTTP probe also sets `httpGet: null`.

> [!NOTE]
> A values file that copies the whole `values.yaml` of 0.151.0 holds twelve old keys, and the render lists all twelve. For `clickhouse.podAnnotations`, `otelCollector.podAnnotations` and the old shape of `signoz.livenessProbe`, `signoz.readinessProbe`, `otelCollector.livenessProbe` and `otelCollector.readinessProbe`, the 0.152.0 defaults hold the same values, so delete those keys.

The histogramQuantile download is `clickhouse.udf`, and it runs on the ClickHouse image. Its init container, `<clickhouse.fullname>-udf-init`, mounts the user scripts volume `shared-binary-volume` at `/var/lib/clickhouse/user_scripts`, and `clickhouse.udf.extraVolumeMounts` adds mounts of `clickhouse.extraVolumes` to it. Entries in `clickhouse.extraInitContainers` run after it and mount only the volumes they list. `clickhouse.initContainers` set to anything other than `null`, an empty map included, fails the render with a message naming `clickhouse.udf` and `clickhouse.extraInitContainers`.

The ClickHouse container takes `clickhouse.env` and `clickhouse.envFrom`, lists of Kubernetes EnvVar and EnvFromSource objects.

The system logs sidecar (`clickhouse.logs.system`, off by default) runs `signoz/signoz-otel-collector:v0.144.15` with the command `/signoz-otel-collector`. Its default config has no `service.telemetry.metrics` block, because `v0.144.15` rejects that block's `address` key. Overrides of existing keys under `clickhouse.logs.system.config`, such as an exporter endpoint or a batch size, merge as before. With the default config, the sidecar logs one warning on start: `"otlp" alias is deprecated; use "otlp_grpc" instead`. `clickhouse.logs.system.env`, `clickhouse.logs.system.envFrom` and `clickhouse.logs.system.extraVolumeMounts` reach the sidecar container.

| Old key | New key | What to write | If you keep the old key |
| --- | --- | --- | --- |
| `clickhouse.securityContext` | `clickhouse.podSecurityContext`, `clickhouse.containerSecurityContext` | The pod fields, without `enabled`, under `podSecurityContext`; the container fields under `containerSecurityContext` | Fails the render when it holds a value; an empty map or list renders |
| `clickhouse.startupProbe.enabled`, `clickhouse.startupProbe.port`, `clickhouse.startupProbe.path` | `clickhouse.startupProbe.httpGet.port`, `clickhouse.startupProbe.httpGet.path` | The probe object; `clickhouse.startupProbe: null` for `enabled: false` | Fails the render when any of the three is present with any value but `null`, `enabled: false` included |
| `clickhouse.livenessProbe.enabled`, `clickhouse.livenessProbe.port`, `clickhouse.livenessProbe.path` | `clickhouse.livenessProbe.httpGet.port`, `clickhouse.livenessProbe.httpGet.path` | As for `startupProbe` | Fails the render when any of the three is present with any value but `null`, `enabled: false` included |
| `clickhouse.readinessProbe.enabled`, `clickhouse.readinessProbe.port`, `clickhouse.readinessProbe.path` | `clickhouse.readinessProbe.httpGet.port`, `clickhouse.readinessProbe.httpGet.path` | As for `startupProbe` | Fails the render when any of the three is present with any value but `null`, `enabled: false` included |
| `clickhouse.customStartupProbe`, `clickhouse.customLivenessProbe`, `clickhouse.customReadinessProbe` | `clickhouse.startupProbe`, `clickhouse.livenessProbe`, `clickhouse.readinessProbe` | The probe object itself, with `httpGet: null` for an `exec`, `tcpSocket` or `grpc` probe | Fails the render when it holds a value; an empty map or list renders |
| `clickhouse.additionalVolumes` | `clickhouse.extraVolumes` | The same list | Fails the render when it holds a value; an empty map or list renders |
| `clickhouse.additionalVolumeMounts` | `clickhouse.extraVolumeMounts` | The same list | Fails the render when it holds a value; an empty map or list renders |
| `clickhouse.podAnnotations` | `clickhouse.pod.annotations` | The same map; the `signoz.io/scrape`, `signoz.io/port` and `signoz.io/path` defaults moved with it | Fails the render when it holds a value; an empty map or list renders |
| `clickhouse.podLabels` | `clickhouse.pod.labels` | The same map; a key named like a selector label (`app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/component`) is ignored | Fails the render when it holds a value; an empty map or list renders |
| `clickhouse.image.registry` | None | The registry at the front of `clickhouse.image.repository`, or `global.imageRegistry` | Fails the render when it holds a value; an empty string renders |
| `clickhouse.logs.system.image.registry` | None | The registry at the front of `clickhouse.logs.system.image.repository`, or `global.imageRegistry` | Fails the render when it holds a value; an empty string renders |
| `clickhouse.initContainers.enabled` | `clickhouse.udf.enabled` | `clickhouse.udf.enabled: false` for `enabled: false` | Fails the render when `clickhouse.initContainers` is present with any value but `null`, an empty map included |
| `clickhouse.initContainers.udf.*` | `clickhouse.udf.enabled`, `clickhouse.udf.command` | `enabled` and `command`, unchanged; no `image`, because the container runs `clickhouse.image`, so a replaced `command` runs there too; [section 8](#8-registry-and-pull-secrets) has examples for a cluster without GitHub access | Fails the render when `clickhouse.initContainers` is present with any value but `null`, an empty map included |
| `clickhouse.initContainers.init.*` | `clickhouse.extraInitContainers` | A replaced `command` as an entry with its own `name`, `image`, `command` and any `volumeMounts` it needs; nothing for the shipped `command`, which calls `curl` on `busybox:1.35`, an image without `curl` | Fails the render when `clickhouse.initContainers` is present with any value but `null`, an empty map included |
| `clickhouse.logs.system.image.pullSecrets` | None | Nothing; ClickHouse pods take `clickhouse.imagePullSecrets` | Goes through; the notes after the upgrade ask you to remove it |
| `clickhouse.logs.system.image.tag`, default `0.111.16` | `clickhouse.logs.system.image.tag`, default `v0.144.15` | Nothing; the sidecar's command is now `/signoz-otel-collector`, the binary `v0.144.15` ships | Goes through silently |
| `clickhouse.logs.system.config.service.telemetry.metrics.address` | None | Nothing; `v0.144.15` rejects the key | Goes through; the sidecar fails at start with `'service.telemetry.metrics' decoding failed ... has invalid keys: address` |
| Components under `clickhouse.logs.system.config` from `ballastextension`, `carbonexporter`, `clickhousemetricsexporter`, `clickhousemetricsexporterv2`, `loggingexporter`, `opencensusexporter`, `opencensusreceiver`, `routingprocessor` or `sapmreceiver` | None | Nothing; `v0.144.15` no longer has these components | Goes through; the sidecar fails at start |
| `clickhouse.replicasCount`, `clickhouse.shardsCount` | `clickhouse.layout.replicasCount`, `clickhouse.layout.shardsCount` | Nothing; `clickhouse.layout.*` was already the key in use | Goes through silently |
| `clickhouse.global.*` | `global.*` | Nothing; `global.*` was already the key in use | Goes through silently |
| `zookeeper.enabled`, unset (was `clickhouse.zookeeper.enabled`, default `true`) | `zookeeper.enabled`, default `false` | `true` while ClickHouse runs on the bundled ZooKeeper ([section 1](#1-the-first-upgrade)) | Goes through and renders no ZooKeeper |
| `signoz.additionalArgs` | `signoz.extraArgs` | The same list | Fails the render when it holds a value; an empty map or list renders |
| `signoz.livenessProbe.enabled`, `signoz.livenessProbe.port`, `signoz.livenessProbe.path` | `signoz.livenessProbe.httpGet.port`, `signoz.livenessProbe.httpGet.path` | The probe object; `signoz.livenessProbe: null` for `enabled: false` | Fails the render when any of the three is present with any value but `null`, `enabled: false` included |
| `signoz.readinessProbe.enabled`, `signoz.readinessProbe.port`, `signoz.readinessProbe.path` | `signoz.readinessProbe.httpGet.port`, `signoz.readinessProbe.httpGet.path` | As for `signoz.livenessProbe` | Fails the render when any of the three is present with any value but `null`, `enabled: false` included |
| `signoz.customLivenessProbe`, `signoz.customReadinessProbe` | `signoz.livenessProbe`, `signoz.readinessProbe` | The probe object itself, with `httpGet: null` for an `exec`, `tcpSocket` or `grpc` probe; the default timings stay unless you set each to `null` | Fails the render when it holds a value; an empty map or list renders |
| `signoz.podAnnotations` | `signoz.pod.annotations` | The same map | Fails the render when it holds a value; an empty map or list renders |
| `signoz.securityContext` | `signoz.containerSecurityContext` | The same map | Fails the render when it holds a value; an empty map or list renders |
| `signoz.additionalVolumeMounts` | `signoz.extraVolumeMounts` | The same list | Fails the render when it holds a value; an empty map or list renders |
| `signoz.additionalVolumes` | `signoz.extraVolumes` | The same list | Fails the render when it holds a value; an empty map or list renders |
| `otelCollector.additionalEnvs` | `otelCollector.env` | A list of Kubernetes EnvVar objects, `- name: <NAME>` with `value` or `valueFrom`, rendered after the chart's variables in the order you write them; an entry named like a chart variable, such as `CLICKHOUSE_USER`, replaces its value; quote a `value` that YAML reads as a number or boolean | Fails the render when it holds a value; an empty map or list renders |
| `otelCollector.command.extraArgs` | `otelCollector.extraArgs` | The same list | Fails the render when it holds a value; an empty map or list renders |
| `otelCollector.livenessProbe.enabled`, `otelCollector.livenessProbe.port`, `otelCollector.livenessProbe.path` | `otelCollector.livenessProbe.httpGet.port`, `otelCollector.livenessProbe.httpGet.path` | The probe object; `otelCollector.livenessProbe: null` for `enabled: false` | Fails the render when any of the three is present with any value but `null`, `enabled: false` included |
| `otelCollector.readinessProbe.enabled`, `otelCollector.readinessProbe.port`, `otelCollector.readinessProbe.path` | `otelCollector.readinessProbe.httpGet.port`, `otelCollector.readinessProbe.httpGet.path` | As for `otelCollector.livenessProbe` | Fails the render when any of the three is present with any value but `null`, `enabled: false` included |
| `otelCollector.customLivenessProbe`, `otelCollector.customReadinessProbe` | `otelCollector.livenessProbe`, `otelCollector.readinessProbe` | The probe object itself, with `httpGet: null` for an `exec`, `tcpSocket` or `grpc` probe; the default timings stay unless you set each to `null` | Fails the render when it holds a value; an empty map or list renders |
| `otelCollector.podAnnotations` | `otelCollector.pod.annotations` | The same map; the `signoz.io/scrape` and `signoz.io/port` defaults moved with it; a `checksum/config` key is ignored, because the chart sets it | Fails the render when it holds a value; an empty map or list renders |
| `otelCollector.podLabels` | `otelCollector.pod.labels` | The same map; a key named like a selector label (`app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/component`) is ignored | Fails the render when it holds a value; an empty map or list renders |
| `otelCollector.securityContext` | `otelCollector.containerSecurityContext` | The same map; it also applies to the collector's `check` init container | Fails the render when it holds a value; an empty map or list renders |

For example:

```yaml
clickhouse:
  podSecurityContext:            # was securityContext, without enabled
    runAsUser: 101
    runAsGroup: 101
    fsGroup: 101
    fsGroupChangePolicy: OnRootMismatch
  livenessProbe:                 # was enabled, port and path
    httpGet:
      port: http
      path: /ping
    initialDelaySeconds: 60
  readinessProbe: null           # was enabled: false
  startupProbe:                  # was customStartupProbe
    httpGet: null
    tcpSocket:
      port: 9000
  image:
    repository: my.registry/clickhouse/clickhouse-server   # was registry: my.registry
```

For the SigNoz server and the collector:

```yaml
signoz:
  pod:
    annotations:                             # was podAnnotations
      backup.velero.io/backup-volumes: signoz-db
  containerSecurityContext:                  # was securityContext
    runAsNonRoot: true
  livenessProbe:                             # was enabled, port and path
    httpGet:
      path: /api/v1/health
    initialDelaySeconds: 30
  readinessProbe: null                       # was enabled: false
otelCollector:
  env:                                       # was additionalEnvs
    - name: GOMEMLIMIT
      value: "800MiB"
  extraArgs:                                 # was command.extraArgs
    - --feature-gates=-pkg.translator.prometheus.NormalizeName
  pod:
    labels:                                  # was podLabels
      team: observability
  livenessProbe:                             # was customLivenessProbe
    httpGet: null
    tcpSocket:
      port: 13133
```

### You must

1. Rewrite each old key in your values as the table says.
2. Delete every old key in the table, including those that go through.

### You will see

- A values file with one old key for each of ClickHouse, the schema migrator, SigNoz and the collector:

  ```yaml
  clickhouse:
    podAnnotations:
      signoz.io/scrape: "true"
  signoz:
    readinessProbe:
      enabled: false
  otelCollector:
    additionalEnvs:
      GOMEMLIMIT: "800MiB"
  telemetryStoreMigrator:
    upgradeHelmHooks: true
  ```

  stops the render once, listing all four:

  ```text
  Error: execution error at (signoz/templates/validate.yaml:22:4): 4 values must change before the chart can be installed:
  - `clickhouse.podAnnotations` has moved to `clickhouse.pod.annotations`: the same map of annotations.
  - `telemetryStoreMigrator.upgradeHelmHooks` has been removed: delete it, since the migrator now runs as a Job named with the release revision on every install and upgrade; set `telemetryStoreMigrator.enabled: false` to skip it.
  - `signoz.readinessProbe.enabled` has moved to `signoz.readinessProbe.httpGet.port` and `signoz.readinessProbe.httpGet.path`: write the probe object, and `signoz.readinessProbe: null` for no probe.
  - `otelCollector.additionalEnvs` has moved to `otelCollector.env`: a list of Kubernetes EnvVar objects, `- name: <NAME>` with `value` or `valueFrom`.
  ```

  The first line counts the lines that follow; with one old key it reads `1 value must change`.
- With `clickhouse.containerSecurityContext` set to `allowPrivilegeEscalation: false`, `capabilities.drop: [ALL]`, `runAsNonRoot: true` and `seccompProfile.type: RuntimeDefault`, the block reached the ClickHouseInstallation, the StatefulSet and the pod. ClickHouse ran as uid 101 with every replica writable.
- Setting `clickhouse.containerSecurityContext` to `null` removed the block and rolled the pod once.

### Verify

```bash
helm template <release> signoz/signoz --version 0.152.0 -n <namespace> -f values.yaml > /dev/null
```

It prints nothing and exits 0.

With `clickhouse.logs.system.enabled: true`, after the upgrade:

```bash
kubectl get pods -n <namespace> -l clickhouse.altinity.com/chi=<clickhouse.fullname> -o jsonpath='{.items[0].spec.containers[1].image}'
```

```text
signoz/signoz-otel-collector:v0.144.15
```

## 6. Names and namespaces

### Applies to

Your values set `clickhouse.fullnameOverride`, `clickhouse.nameOverride` or `clickhouse.namespace`, or your release name contains `clickhouse`.

### What changes

- Operator objects were named `<clickhouse.fullname>-operator`. From this release on they are named `<release>-clickhouse-operator`, whatever `clickhouse.*` said.
- If you keep the current name (step 1 below), the other operator objects are patched in place. Otherwise they are recreated under the new name.
- The ConfigMaps take new names either way.
- The operator pod's labels change either way: `app.kubernetes.io/name` becomes `clickhouse-operator`, and `app.kubernetes.io/component` leaves the Deployment's selector.
- With `clickhouse.namespace` set to another namespace, the operator stays in the release namespace, and the render fails until one of the operator's watch settings is set.
- With `clickhouse.namespace` set to another namespace and `clickhouse.fullnameOverride` also set, `CLICKHOUSE_HOST` becomes `<clickhouse.fullnameOverride>.<clickhouse.namespace>.svc.<global.clusterDomain>`.
- ClickHouse objects keep their names.
- The render fails when `<clickhouse.fullname>` or `<keeper.fullname>` is longer than 34 characters.

### You must

1. To keep the current operator name, read it before the upgrade and set it as `altinity-clickhouse-operator.fullnameOverride`. To take the new name, skip this step.

   ```bash
   kubectl get deployment -n <namespace> -l app.kubernetes.io/name=<clickhouse.name>,app.kubernetes.io/instance=<release>,app.kubernetes.io/component -o name
   ```

   ```yaml
   altinity-clickhouse-operator:
     fullnameOverride: <the name after deployment.apps/>
   ```

2. If `clickhouse.namespace` is set to a namespace other than the release's, set one of the two:
   - **The old layout.** The operator runs beside ClickHouse:

     ```yaml
     altinity-clickhouse-operator:
       namespaceOverride: <clickhouse.namespace>
     ```

   - **The operator in the release namespace.** It watches ClickHouse's namespace, and its Role and RoleBinding become a ClusterRole and ClusterRoleBinding:

     ```yaml
     altinity-clickhouse-operator:
       watchNamespaces: ["<clickhouse.namespace>"]
       rbac:
         namespaceScoped: false
     ```

3. If the render fails on a Keeper name longer than 34 characters, set `keeper.fullnameOverride` to a shorter name.

### You will see

A release named `signoz-pi69ex7kr4` installs with `signoz-pi69ex7kr4-clickhouse` and `signoz-pi69ex7kr4-keeper`. The longest name the operator derives from them is 53 characters.

### Verify

```bash
kubectl get deployment -n <namespace> -l app.kubernetes.io/name=clickhouse-operator,app.kubernetes.io/instance=<release> -o name
```

It prints `deployment.apps/` followed by the name you kept, or by `<release>-clickhouse-operator`.

## 7. Objects

### Applies to

Something outside the chart (a NetworkPolicy, PodMonitor, ServiceMonitor, admission policy, dashboard, alert, script or GitOps diff) names, selects or watches chart objects.

### What changes

The table lists every chart object whose name, labels, containers, ports, namespace or management changes. In an old name, `operator` is `clickhouse.clickhouseOperator.name` when your values set it. To keep an operator name, see [section 6](#6-names-and-namespaces).

The operator renames the ClickHouse PodDisruptionBudget from `<clickhouse.fullname>-<clickhouse.cluster>` to `chi-<clickhouse.fullname>-<clickhouse.cluster>`.

With the default values, Keeper on and ZooKeeper off, the five ZooKeeper objects `StatefulSet/<release>-zookeeper`, `Service/<release>-zookeeper`, `Service/<release>-zookeeper-headless`, `Service/<release>-zookeeper-metrics` and `ConfigMap/<release>-zookeeper-scripts` leave the release, and `ClickHouseKeeperInstallation/<release>-keeper` arrives. With `zookeeper.enabled: true` the five stay.

A diff of the first upgrade also shows changes in text only. The ClickHouse, SigNoz and collector pods render `priorityClassName` only when `clickhouse.priorityClassName`, `signoz.priorityClassName` or `otelCollector.priorityClassName` is set. The SigNoz, collector, `check` and schema migrator containers render environment values with plain YAML quoting, with the same values except the numbers in [section 13](#13-the-signoz-container). Probe fields render in key order, with the same values.

Every component that connects to ClickHouse reads the ClickHouse password from the Secret `<clickhouse.fullname>-credentials` (table below), which the chart writes from `clickhouse.password`. To use a Secret of your own, set `clickhouse.existingSecret`. The chart then creates no Secret and reads the password under `clickhouse.existingSecretPasswordKey`, `password` by default. Also store the SHA-256 hex of the password in that Secret and name its key in `clickhouse.existingSecretPasswordSha256Key`; the ClickHouseInstallation then reads the hash instead of the plain password. Make the hash with `printf '%s' "$PASSWORD" | sha256sum | cut -d' ' -f1`. With `clickhouse.existingSecretPasswordSha256Key` empty, ClickHouse reads the plain key through an environment substitution that is parsed as XML, so the password must not contain `&`, `<` or an `&name;` sequence. With `clickhouse.namespace` set to another namespace, the Secret must exist there as well as in the release namespace.

| Object | Old | New | Update outside the chart |
| --- | --- | --- | --- |
| Operator Deployment | `<clickhouse.fullname>-operator` (`<release>-clickhouse-operator` by default); selector `app.kubernetes.io/name: <clickhouse.name>`, `app.kubernetes.io/instance`, `app.kubernetes.io/component: operator` | `<release>-clickhouse-operator`; selector `app.kubernetes.io/name: clickhouse-operator`, `app.kubernetes.io/instance`; deleted and created again in this upgrade | Anything that names it or patches it |
| Operator pod labels | `app.kubernetes.io/name: <clickhouse.name>`, `app.kubernetes.io/instance`, `app.kubernetes.io/component: operator` | `app.kubernetes.io/name: clickhouse-operator`, `app.kubernetes.io/instance`, `app.kubernetes.io/component: operator`, `helm.sh/chart`, `app.kubernetes.io/version`, `app.kubernetes.io/managed-by` | Selectors, NetworkPolicies, PodMonitors, and dashboard or alert filters on the old `app.kubernetes.io/name` |
| Labels on the operator Deployment, ServiceAccount, Secret, Role, RoleBinding, ConfigMaps and metrics Service | `app.kubernetes.io/name: <clickhouse.name>`, `app.kubernetes.io/component: operator`, `clickhouse.altinity.com/chop: 0.21.2`, `helm.sh/chart: clickhouse-24.1.18` | `app.kubernetes.io/name: clickhouse-operator`, `app.kubernetes.io/version: 0.27.4`, `helm.sh/chart: altinity-clickhouse-operator-0.27.4`; no `component` or `clickhouse.altinity.com/chop` label | Selectors on these objects |
| Operator ServiceAccount, Secret, Role, RoleBinding | `<clickhouse.fullname>-operator` | `<release>-clickhouse-operator`; patched in place when the name is the same, created under the new name otherwise | Anything that names them |
| Operator ConfigMaps | `<clickhouse.fullname>-operator-etc-files`, `-etc-confd-files`, `-etc-configd-files`, `-etc-templatesd-files`, `-etc-usersd-files` | `<release>-clickhouse-operator-files`, `-confd-files`, `-configd-files`, `-templatesd-files`, `-usersd-files`, and new `-keeper-confd-files`, `-keeper-configd-files`, `-keeper-templatesd-files`, `-keeper-usersd-files` | Anything that names them |
| Operator metrics Service | `<clickhouse.fullname>-operator-metrics`, `type: ClusterIP`, port 8888 named `<clickhouse.fullname>-operator-metrics`, selector as the old Deployment | `<release>-clickhouse-operator-metrics`, ClusterIP with no type setting, ports 8888 `ch-metrics` and 9999 `op-metrics` (9999 alone with `altinity-clickhouse-operator.metrics.enabled: false`), selector as the new Deployment, annotations from `altinity-clickhouse-operator.commonAnnotations` | Scrape configs by port name, and anything that set its type or annotations |
| Operator ServiceMonitor, when enabled | `<clickhouse.fullname>-operator-metrics`, endpoint port `<clickhouse.fullname>-operator-metrics` | `<release>-clickhouse-operator-clickhouse-metrics`, endpoint ports `ch-metrics` and `op-metrics` | Rules and dashboards keyed on the job or endpoint |
| Operator objects' namespace, with `clickhouse.namespace` set | `clickhouse.namespace`, the Secret in the release namespace | With `namespaceOverride`, `clickhouse.namespace` for all, the Secret included; with `watchNamespaces`, the release namespace for all, and a ClusterRole and ClusterRoleBinding `<release>-clickhouse-operator` in place of the Role and RoleBinding | NetworkPolicies and RBAC that assume the old namespace |
| Hook objects | None | `<release>-clickhouse-operator-upgrade` Job, ServiceAccount, Role and RoleBinding (`pre-upgrade`); `<release>-clickhouse-operator-crd-install` Job, ServiceAccount, ClusterRole, ClusterRoleBinding and ConfigMaps `-crds-1` to `-crds-4` (`pre-install`, `pre-upgrade`) | Admission policies: the image `registry.k8s.io/kubectl:v1.36.3` and a ClusterRole for the CRD hook |
| ClickHouseInstallation, its ConfigMap `<clickhouse.fullname>-custom-functions`, its ServiceAccount, and the Service from its template | Labels `helm.sh/chart: clickhouse-24.1.18`, `app.kubernetes.io/version: 24.1.2` | Labels `helm.sh/chart: signoz-<chart version>`, `app.kubernetes.io/version: <clickhouse.image.tag>`; names unchanged; a key in `clickhouse.labels` that matches a chart label is rendered once on the ClickHouseInstallation, with your value | Selectors on `helm.sh/chart` or `app.kubernetes.io/version` |
| Ports of the ClickHouse Service from the ClickHouseInstallation's template | `http` and `tcp` with no `targetPort`, so they target `clickhouse.service.httpPort` and `clickhouse.service.tcpPort` on the pod | `targetPort: http` and `targetPort: client`, ClickHouse's own ports 8123 and 9000; `clickhouse.service.httpPort` and `clickhouse.service.tcpPort` move only the Service port | Nothing |
| ClickHouse password | Written into each pod spec and, as `<clickhouse.user>/password`, into the ClickHouseInstallation; with external ClickHouse also stored in the Secret `<release>-clickhouse-external`, key `clickhouse-password` | `Secret/<clickhouse.fullname>-credentials` (`<release>-clickhouse-credentials` by default) with `password`, which every component that connects to ClickHouse reads, and `password_sha256_hex`, which the ClickHouseInstallation reads as `<clickhouse.user>/password_sha256_hex`; with external ClickHouse, `password` only; no Secret with `clickhouse.existingSecret` or `externalClickhouse.existingSecret` | Anything that read the password from a pod spec or from `<release>-clickhouse-external` |
| ClickHouse pod template labels | `app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/component`, `helm.sh/chart`, `app.kubernetes.io/version`, `app.kubernetes.io/managed-by` | `app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/component` | Selectors, affinity and topology spread rules on `helm.sh/chart`, `app.kubernetes.io/version` or `app.kubernetes.io/managed-by` |
| ClickHouse init container `<clickhouse.fullname>-udf-init` | Image `docker.io/alpine:3.18.2` | Same name; image `clickhouse.image`, `clickhouse/clickhouse-server:25.12.5` by default | Admission policies: the init container image |
| ClickHouse container | Mount `/scripts` from the pod volume `scripts`; with `clickhouse.logs.system.enabled: true`, a `lifecycle.postStart` hook running `/scripts/wait-until-ready.sh` | No `/scripts` mount, no `scripts` volume and no `lifecycle.postStart` | Anything that runs `/scripts/wait-until-ready.sh` or expects the mount |
| ConfigMap `<clickhouse.fullname>-scripts` | Holds `wait-until-ready.sh`, mounted at `/scripts` | None | Anything that names it |
| ClickHouse claims the operator stops tracking | Deleted by the operator's cleanup | Kept (`reconciling.cleanup.unknownObjects.pvc: Retain` on the ClickHouseInstallation) | Delete such claims by hand when the data is no longer wanted |
| ClickHouseKeeperInstallation | None | `<keeper.fullname>`, `ClickHouseKeeperInstallation/<release>-keeper` by default, in `<namespace>`; labels `app.kubernetes.io/name: keeper` (`keeper.nameOverride` when set), `app.kubernetes.io/component: keeper` and `keeper.labels`, where a key that matches a chart label is rendered once with your value; pod labels: the three selector labels and `keeper.pod.labels`, where a key named like a selector label is ignored; pod annotations: `keeper.pod.annotations`, by default `signoz.io/scrape`, `signoz.io/port: "9141"` and `signoz.io/path`; one claim per replica from `keeper.persistence.size`, `keeper.persistence.accessModes` and `keeper.persistence.storageClass`, with `global.storageClass` taking precedence, kept when the installation or a replica is removed | NetworkPolicies that let ClickHouse reach `keeper-<keeper.fullname>` on port 2181, PodMonitors on the Keeper pod's labels, and backups of its claims |
| ZooKeeper `StatefulSet/<release>-zookeeper`, `Service/<release>-zookeeper`, `Service/<release>-zookeeper-headless`, `Service/<release>-zookeeper-metrics` and `ConfigMap/<release>-zookeeper-scripts` | Rendered by default; pod template `helm.sh/chart: zookeeper-0.0.1`, `ZOO_PRE_ALLOC_SIZE` `65536` | Rendered only with `zookeeper.enabled: true`; annotation `signoz.io/deprecated: "true"`; pod template `helm.sh/chart: zookeeper-0.0.2`, `ZOO_PRE_ALLOC_SIZE` `0`, the new default of `zookeeper.preAllocSize` | Nothing; see step 3 of [section 1](#1-the-first-upgrade). To keep the old preallocation, set `zookeeper.preAllocSize: 65536` |
| Schema migrator Job and ServiceAccount | Job `signoz-telemetrystore-migrator`; ServiceAccount `signoz-telemetrystore-migrator` | Job `signoz-telemetrystore-migrator-<revision>`; the ServiceAccount only with `telemetryStoreMigrator.serviceAccount.create: true` ([section 14](#14-schema-migrator)) | Anything that names the Job or binds the ServiceAccount |
| Postgres objects, with `postgresql.enabled: true` | Labels `helm.sh/chart: postgresql-0.0.2` | Labels `helm.sh/chart: postgresql-0.0.3`; a new Secret `<postgresql.fullname>-auth` ([section 16](#16-bundled-postgres)) | Selectors on `helm.sh/chart` |

### You must

1. For each row that something outside the chart depends on, adopt the new name, label, port or namespace.
2. Point anything that names the ClickHouse PodDisruptionBudget at `chi-<clickhouse.fullname>-<clickhouse.cluster>`.

### You will see

- During the first upgrade, both PodDisruptionBudgets exist and the ClickHouse pod reports `MultiplePodDisruptionBudgets` warnings. Afterwards only `chi-<clickhouse.fullname>-<clickhouse.cluster>` is left.
- The operator metrics Service shows `8888/TCP,9999/TCP` and selects `app.kubernetes.io/instance=<release>,app.kubernetes.io/name=clickhouse-operator`.
- A Keeper installation brings the StatefulSet `chk-<keeper.fullname>-cluster-0-0`, the Services `keeper-<keeper.fullname>`, `chk-<keeper.fullname>-cluster-0-0` and `chk-<keeper.fullname>-cluster-0-0-client`, and the claim `default-chk-<keeper.fullname>-cluster-0-0-0`, of `keeper.persistence.size` (`10Gi` by default).

### Verify

```bash
kubectl get pods -n <namespace> -l app.kubernetes.io/name=clickhouse-operator,app.kubernetes.io/instance=<release>
```

It lists the one operator pod, `2/2` `Running`.

For the download init container:

```bash
kubectl get pods -n <namespace> -l clickhouse.altinity.com/chi=<clickhouse.fullname> -o jsonpath='{.items[0].spec.initContainers[*].image}'
```

It prints the ClickHouse image, `clickhouse/clickhouse-server:25.12.5` with default values.

## 8. Registry and pull secrets

### Applies to

You set `global.imageRegistry`, `global.imagePullSecrets`, `imagePullSecrets` or a component's `imagePullSecrets`.

### What changes

The operator, metrics-exporter and CRD hook images, and the operator pod's pull secrets, come from Altinity's chart. That chart reads its own keys under `altinity-clickhouse-operator` and no `global.*` value.

The operator upgrade hook pulls `<global.imageRegistry>/kubectl:v1.36.3`, because `global.imageRegistry` replaces the registry at the front of its repository, `registry.k8s.io/kubectl`.

The pods below list their pull secrets in their own spec: `global.imagePullSecrets`, then `imagePullSecrets`, then the list of their component, with each name once. The ServiceAccounts of these components carry no pull secrets.

| Pod | Component list |
| --- | --- |
| ClickHouse | `clickhouse.imagePullSecrets` |
| Operator upgrade hook | `clickhouse.imagePullSecrets` |
| ClickHouse Keeper | `keeper.imagePullSecrets` |
| SigNoz | `signoz.imagePullSecrets` |
| Collector | `otelCollector.imagePullSecrets` |
| Schema migrator | `otelCollector.imagePullSecrets` |

In 0.151.0, the SigNoz, collector and schema migrator ServiceAccounts carried `global.imagePullSecrets` and `imagePullSecrets`, the ClickHouse ServiceAccount and pod carried `global.imagePullSecrets` and `clickhouse.imagePullSecrets`, and the SigNoz and collector pods listed only their own lists. A name in more than one list was listed more than once.

With `global.imageRegistry` set, a registry written at the front of `signoz.image.repository` or `otelCollector.image.repository` is replaced, as it is for ClickHouse: `docker.io/signoz/signoz` becomes `<global.imageRegistry>/signoz/signoz`, where 0.151.0 rendered `<global.imageRegistry>/docker.io/signoz/signoz`. `otelCollector.image.repository` names the image of the collector, its `check` init container and the four schema migrator containers. The default repositories carry no registry, so with them the images are the same as in 0.151.0.

The histogramQuantile download (`clickhouse.udf`) runs the ClickHouse container's image, so there is no `alpine` image to mirror. It downloads the binary from GitHub.

### You must

1. Set the operator's registry and pull secrets:

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

2. For the operator upgrade hook, mirror `registry.k8s.io/kubectl:v1.36.3` to `<global.imageRegistry>/kubectl:v1.36.3`.

3. If ClickHouse cannot reach GitHub, bring the histogramQuantile binary one of two ways:

   - **From your own image.** Turn the download off and copy the binary in with an init container that mounts `shared-binary-volume`, the user scripts volume, at `/var/lib/clickhouse/user_scripts`. In this example, `my.registry/histogram-quantile:v0.0.1` is an image you build with the binary from SigNoz/signoz's `histogram-quantile/v0.0.1` release, for your nodes' architecture, at `/histogramQuantile`:

     ```yaml
     clickhouse:
       udf:
         enabled: false
       extraInitContainers:
         - name: histogram-quantile
           image: my.registry/histogram-quantile:v0.0.1
           command: ["cp", "/histogramQuantile", "/var/lib/clickhouse/user_scripts/histogramQuantile"]
           volumeMounts:
             - name: shared-binary-volume
               mountPath: /var/lib/clickhouse/user_scripts
     ```

   - **From a mirror.** Keep the download and point it at your mirror. Copy the default `clickhouse.udf.command` from the chart's `values.yaml` and change its `wget` line. `clickhouse.udf.env` and `clickhouse.udf.envFrom` reach the download container, for a proxy setting or a mirror credential from a Secret:

     ```yaml
     clickhouse:
       udf:
         envFrom:
           - secretRef:
               name: my-mirror-credentials   # holds MIRROR_TOKEN
         command:
           - sh
           - -c
           - |
             set -e
             version="v0.0.1"
             node_os=$(uname -s | tr '[:upper:]' '[:lower:]')
             node_arch=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
             echo "Fetching histogram-binary for ${node_os}/${node_arch}"
             cd /tmp
             wget --header "Authorization: Bearer ${MIRROR_TOKEN}" -O histogram-quantile.tar.gz "https://my.mirror/histogram-quantile/${version}/histogram-quantile_${node_os}_${node_arch}.tar.gz"
             tar -xzf histogram-quantile.tar.gz
             chmod +x histogram-quantile
             mv histogram-quantile /var/lib/clickhouse/user_scripts/histogramQuantile
             echo "histogram-quantile installed successfully"
     ```

4. If a pod of your own runs under a chart ServiceAccount and pulls from a private registry, list its pull secrets in its own spec.

5. If you write a registry at the front of `signoz.image.repository` or `otelCollector.image.repository` and set `global.imageRegistry`, mirror those images under `<global.imageRegistry>/` followed by the repository without its registry, such as `<global.imageRegistry>/signoz/signoz-otel-collector`.

### You will see

- With default values, both hook Jobs pull `registry.k8s.io/kubectl:v1.36.3`.
- With these values:

  ```yaml
  global:
    imagePullSecrets: ["shared"]
  imagePullSecrets: ["signoz-pull", "shared"]
  clickhouse:
    imagePullSecrets: ["clickhouse-pull"]
  ```

  the ClickHouse pod and the operator upgrade hook list `shared`, `signoz-pull` and `clickhouse-pull`. The SigNoz, collector, schema migrator and ClickHouse Keeper pods list `shared` and `signoz-pull`. None of their ServiceAccounts lists a pull secret.

### Verify

```bash
kubectl get deployment -n <namespace> -l app.kubernetes.io/name=clickhouse-operator,app.kubernetes.io/instance=<release> -o jsonpath='{.items[0].spec.template.spec.containers[*].image}'
```

```text
my.registry/altinity/clickhouse-operator:0.27.4 my.registry/altinity/metrics-exporter:0.27.4
```

For the SigNoz pod's pull secrets:

```bash
kubectl get pods -n <namespace> -l app.kubernetes.io/instance=<release>,app.kubernetes.io/component=signoz -o jsonpath='{.items[0].spec.imagePullSecrets[*].name}'
```

It prints the names in `global.imagePullSecrets`, then `imagePullSecrets`, then `signoz.imagePullSecrets`, each once.

## 9. Hooks and deployers

### Applies to

You run the ClickHouse operator yourself, turn a hook off, upgrade with `--no-hooks`, or deploy through Argo CD or Terraform.

### What changes

Two hooks carry this upgrade:

- The chart's `pre-upgrade` Job `<release>-clickhouse-operator-upgrade` deletes the old operator Deployment, whose selector cannot change in place. Its settings are under `clickhouse.operatorUpgradeHook`, among them the scheduling keys `clickhouse.operatorUpgradeHook.nodeSelector`, `clickhouse.operatorUpgradeHook.tolerations`, `clickhouse.operatorUpgradeHook.affinity`, `clickhouse.operatorUpgradeHook.topologySpreadConstraints` and `clickhouse.operatorUpgradeHook.priorityClassName`, and the security contexts `clickhouse.operatorUpgradeHook.podSecurityContext` and `clickhouse.operatorUpgradeHook.containerSecurityContext`, each rendered only when set.
- Altinity's `pre-install` and `pre-upgrade` Job `<release>-clickhouse-operator-crd-install` applies the four CRDs with server-side apply on every install and upgrade, with a ClusterRole. Its settings are under `altinity-clickhouse-operator.crdHook`.

With `altinity-clickhouse-operator.enabled: false`, the chart renders no operator and neither hook, and the upgrade removes the chart's operator objects.

For the schema migrator, which runs as a Job, see [section 14](#14-schema-migrator).

Argo CD runs `pre-install` and `pre-upgrade` hooks as `PreSync` hooks on every sync. Terraform's `helm_release` runs them unless `disable_webhooks = true`, which is `--no-hooks`.

### You must

1. When the operator upgrade hook does not run (`clickhouse.operatorUpgradeHook.enabled: false`, `--no-hooks` or `disable_webhooks = true`), delete the old operator Deployment right before the upgrade, with the hook's own selector. Later upgrades need no delete.

   ```bash
   kubectl delete deployment -n <namespace> -l app.kubernetes.io/name=<clickhouse.name>,app.kubernetes.io/instance=<release>,app.kubernetes.io/component
   ```

2. When the CRD hook does not run (`altinity-clickhouse-operator.crdHook.enabled: false`, `--no-hooks` or `disable_webhooks = true`), apply the CRDs by hand before the upgrade, and again whenever the `altinity-clickhouse-operator` version changes:

   ```bash
   helm pull altinity-clickhouse-operator --repo https://helm.altinity.com --version 0.27.4 --untar --untardir ./altinity
   kubectl apply --server-side --force-conflicts -f ./altinity/altinity-clickhouse-operator/crds/
   ```

3. When you run the operator yourself, set `altinity-clickhouse-operator.enabled: false`. Your operator must have the four CRDs, `clickhousekeeperinstallations.clickhouse-keeper.altinity.com` included, and reconcile ClickHouseInstallations and ClickHouseKeeperInstallations in `<namespace>`.

4. When the operator upgrade hook's pod must run on tainted or dedicated nodes, or in a namespace that enforces a Pod Security Standard, set its scheduling keys or security contexts. For example:

   ```yaml
   clickhouse:
     operatorUpgradeHook:
       nodeSelector:
         pool: system
       tolerations:
         - key: dedicated
           operator: Equal
           value: system
           effect: NoSchedule
   ```

### You will see

On every upgrade, both hook Jobs run and complete within seconds. On an upgrade with nothing to delete, the operator pod keeps running.

### Verify

```bash
kubectl get crd | grep altinity
```

It lists four CRDs: `clickhouseinstallations.clickhouse.altinity.com`, `clickhouseinstallationtemplates.clickhouse.altinity.com`, `clickhousekeeperinstallations.clickhouse-keeper.altinity.com` and `clickhouseoperatorconfigurations.clickhouse.altinity.com`.

## 10. External ZooKeeper

### Applies to

Your values set `clickhouse.externalZookeeper.servers`.

### What changes

ClickHouse takes `clickhouse.externalZookeeper.servers` over the bundled ZooKeeper and Keeper, and its coordination hosts render as before. Keeper is installed while `keeper.enabled` is true, and ClickHouse leaves it idle.

### You must

1. Set `keeper.enabled: false`.

### You will see

With `keeper.enabled: false`, the CRD hook still adds the Keeper CRD, and the upgrade creates no ClickHouseKeeperInstallation.

### Verify

```bash
kubectl get chi -n <namespace> -l app.kubernetes.io/instance=<release> -o jsonpath='{.items[0].spec.configuration.zookeeper}'
```

It prints your `clickhouse.externalZookeeper.servers` as `nodes`.

## 11. ZooKeeper to ClickHouse Keeper

### Applies to

Your release runs the bundled ZooKeeper (`zookeeper.enabled: true`), and you move ClickHouse to ClickHouse Keeper.

### What changes

The procedure converts the ZooKeeper coordination tree into a Keeper snapshot with `clickhouse keeper-converter`. It then repoints ClickHouse by patching its ClickHouseInstallation (CHI) and restarting its pods, and then removes ZooKeeper from the release.

Keeper swapped in without converting leaves every `ReplicatedMergeTree` table read-only (`TABLE_IS_READ_ONLY`) against an empty tree.

The procedure is written for one Keeper replica, the chart default. Raise `keeper.replicaCount` after step 11.

### You must

#### Before you start

**Access**

- Permission to `kubectl exec` into the release namespace.
- Permission to create Jobs, to scale StatefulSets and Deployments, and to patch the ClickHouseInstallation.
- Permission to run `helm upgrade` on the release.
- Permission to run ClickHouse `SYSTEM` commands as the chart's admin user.
- For Argo CD, permission to turn auto-sync off for the application.

**Tools**

- `kubectl` and `helm`.
- `clickhouse-client`, which is in the ClickHouse server image.

**Starting point**

This procedure starts from a release already upgraded to `0.152.0` or later, with `zookeeper.enabled: true` in its values ([section 1](#1-the-first-upgrade)). After that upgrade:

- ClickHouse still runs on ZooKeeper, because the chart prefers ZooKeeper while both stores are on.
- `system.zookeeper_connection` shows `is_expired` 0, and no table is read-only. Step 1 checks the connection, and step 4 checks the read-only count.
- Keeper is in one of the two states the first upgrade leaves it in ([section 1](#1-the-first-upgrade)). Both are fine. Step 2 turns Keeper on if it is off, and checks it.
  - Off (`keeper.enabled: false`), if the release stayed on ZooKeeper.
  - On (`keeper.enabled: true`, the chart default) and running idle beside ZooKeeper with an empty tree, if the Keeper CRD was applied before the upgrade.
- ZooKeeper values live at `zookeeper.*` ([section 2](#2-zookeeper-values)).
- `keeper.replicaCount` is 1 or unset.
- `zookeeper.dataLogDir` is unset (the chart's default), so snapshots and transaction logs share the claim `data-<release>-zookeeper-<n>`.
  - If it is set, the transaction logs live under `<dataLogDir>/version-2` on `data-log-<release>-zookeeper-<n>`, for the same ordinal as `ZK_LEADER_PVC`. Mount that claim in the step 7 Job as well, and point `--zookeeper-logs-dir` at it. Otherwise the converter replays nothing and the converted tree is stale.
- The chart's ZooKeeper is 3.7. The converter needs 3.4 or later.

If the release has not taken 0.152.0 yet, do [section 1](#1-the-first-upgrade) first and come back here.

**What to know**

- The converter is an offline, file-to-file translation between ZooKeeper's snapshot format and Keeper's. Nothing connects to ZooKeeper or to Keeper while it runs. Both are stopped. It moves the replication metadata (which parts exist, which replica holds what, queues, in-flight mutations), never the parts themselves.
- The output is one snapshot file that Keeper loads at startup, so seeding has to happen before Keeper first runs with real data.
- ACLs and ephemeral nodes do not carry over. Ephemerals are session state and are recreated when clients reconnect. The chart uses no ACLs.
- Repointing ClickHouse is a config change. ClickHouse hot-reloads it, but it does not move its live session. You restart the ClickHouse pods by hand in step 9.

#### Variables

```bash
export NS="<namespace>"
export RELEASE="<release>"

export ZK_STS="<zookeeper-statefulset>"                # default $RELEASE-zookeeper
export ZK_REPLICAS="<zookeeper-replica-count>"          # zookeeper.replicaCount, default 1
export ZK_LEADER_PVC="data-$ZK_STS-<n>"                 # set in step 1

export KEEPER_NAME="<keeper.fullname>"                  # keeper.fullnameOverride, default $RELEASE-keeper
export CHK_STS="chk-$KEEPER_NAME-cluster-0-0"
export CHK_PVC="default-chk-$KEEPER_NAME-cluster-0-0-0"
export KEEPER_HOST="keeper-$KEEPER_NAME"

export CHI_NAME="$(kubectl -n "$NS" get chi -l app.kubernetes.io/instance="$RELEASE" -o jsonpath='{.items[0].metadata.name}')"
export CH_PODS="$(kubectl -n "$NS" get pods -l clickhouse.altinity.com/chi="$CHI_NAME" -o name | sed 's|pod/||' | tr '\n' ' ')"
export CH_POD="$(echo $CH_PODS | cut -d' ' -f1)"
export CH_USER="<clickhouse.user>"                     # default admin
export CH_PASSWORD="<clickhouse.password>"

export COLLECTOR_DEPLOY="<collector-deployment>"       # kubectl -n $NS get deploy | grep otel-collector
export COLLECTOR_REPLICAS="<collector-replica-count>"
export CONVERTER_IMAGE="clickhouse/clickhouse-server:<clickhouse.image.tag>"   # the keeper image has no converter

chc() { kubectl -n "$NS" exec "$CH_POD" -c clickhouse -- clickhouse-client --user "$CH_USER" --password "$CH_PASSWORD" -q "$1"; }
```

| Variable | Meaning |
| --- | --- |
| `ZK_LEADER_PVC` | Claim of the ZooKeeper leader, set in step 1. The leader holds the most current snapshot and log; the conversion reads this volume. With one ZooKeeper replica it is `data-$ZK_STS-0`. |
| `CHK_STS`, `CHK_PVC`, `KEEPER_HOST` | Named by the operator from the ClickHouseKeeperInstallation `$KEEPER_NAME`. Confirm them in step 2. |
| `CH_PODS` | Every ClickHouse pod. All of them are deleted in step 9 and come back under the same names, so the variable stays valid. |
| `COLLECTOR_DEPLOY` | The collector Deployment. Its name depends on the release name, so read it from `kubectl get deploy`. |
| `CONVERTER_IMAGE` | The server image at the version the cluster runs. The slim `clickhouse-keeper` image does not carry the converter. |

#### Steps

Steps 6 through 9 are the outage window. No `helm upgrade` runs inside it.

> [!IMPORTANT]
> If you deploy through Argo CD, turn auto-sync off before step 2 and turn it back on after step 11. Otherwise Argo CD reverts the scale-downs and the CHI patch mid-migration. Where this section says `helm upgrade`, commit the values change and sync by hand.

##### Step 1: Confirm ZooKeeper and collect information

**Purpose:** Confirm that ZooKeeper is what the release runs on, and identify the volume and the leader node the conversion reads from.

**Run:**

```bash
kubectl -n "$NS" get statefulset
kubectl -n "$NS" get pvc

for i in $(seq 0 $((ZK_REPLICAS - 1))); do
  echo -n "$ZK_STS-$i: "
  kubectl -n "$NS" exec "$ZK_STS-$i" -- sh -c 'echo srvr | nc 127.0.0.1 2181' | grep Mode
done
```

**Expect:**

```text
NAME                                READY   AGE
chi-signoz-clickhouse-cluster-0-0   1/1     6m50s
chk-signoz-keeper-cluster-0-0       1/1     3m31s
signoz                              1/1     19m
signoz-zookeeper                    1/1     19m

NAME                                                            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
data-signoz-zookeeper-0                                         Bound    pvc-1fc40997-cf3d-4329-8752-88f23c84241d   8Gi        RWO            standard       <unset>                 19m
data-volumeclaim-template-chi-signoz-clickhouse-cluster-0-0-0   Bound    pvc-773ce07a-b66b-4fb3-b95a-6d998368edc4   20Gi       RWO            standard       <unset>                 17m
default-chk-signoz-keeper-cluster-0-0-0                         Bound    pvc-e784fd28-2a2e-418e-a1ba-679055aa9667   10Gi       RWO            standard       <unset>                 3m31s
signoz-db-signoz-0                                              Bound    pvc-e9aad854-14b8-43ae-bcbf-97cde69b7ff8   1Gi        RWO            standard       <unset>                 19m

signoz-zookeeper-0: Mode: standalone
```

A single-node ZooKeeper reports `Mode: standalone`, and that node is the one to convert from. With three nodes, one reports `leader`. Set `ZK_LEADER_PVC` to the `data-` claim bound to that pod.

**Verify:**

```bash
kubectl -n "$NS" get pvc "$ZK_LEADER_PVC"
chc "SELECT host, port, is_expired FROM system.zookeeper_connection"
```

`host` is the ZooKeeper service and `is_expired` is `0`.

**If it fails:** If there is no ZooKeeper StatefulSet, or `system.zookeeper_connection` already shows `$KEEPER_HOST`, this section does not apply.

##### Step 2: Enable and validate ClickHouse Keeper

**Purpose:** Turn Keeper on if the release deferred it. Confirm that the Keeper StatefulSet, Services and volume are in place and healthy, so the target volume exists before the outage window opens.

**Run:**

If `keeper.enabled` is `false`, set it in your values file and upgrade. If Keeper is already on, there is nothing to run here.

```yaml
keeper:
  enabled: true
```

```bash
helm upgrade "$RELEASE" signoz/signoz --version 0.152.0 -n "$NS" -f values.yaml
```

ZooKeeper is still live and every table is writable, so the schema migrator runs as usual. Argo CD users: commit the values change and sync by hand.

Wait for the ClickHouseKeeperInstallation (CHK) to report `Completed`, then list what it created:

```bash
kubectl -n "$NS" get chk
kubectl -n "$NS" get pvc | grep -E 'zookeeper|keeper'
kubectl -n "$NS" get svc | grep -E 'zookeeper|keeper'
```

**Expect:**

```text
NAME            STATUS      CLUSTERS   HOSTS   HOSTS-COMPLETED   AGE    SUSPEND
signoz-keeper   Completed   1          1                         4m8s

data-signoz-zookeeper-0                                         Bound    pvc-1fc40997-cf3d-4329-8752-88f23c84241d   8Gi        RWO            standard       <unset>                 19m
default-chk-signoz-keeper-cluster-0-0-0                         Bound    pvc-e784fd28-2a2e-418e-a1ba-679055aa9667   10Gi       RWO            standard       <unset>                 3m37s

chk-signoz-keeper-cluster-0-0          ClusterIP   None            <none>        2181/TCP,9444/TCP                                                  3m37s
chk-signoz-keeper-cluster-0-0-client   ClusterIP   None            <none>        2181/TCP                                                           3m37s
keeper-signoz-keeper                   ClusterIP   None            <none>        2181/TCP,9444/TCP                                                  2m22s
signoz-zookeeper                       ClusterIP   10.96.180.26    <none>        2181/TCP,2888/TCP,3888/TCP                                         19m
signoz-zookeeper-headless              ClusterIP   None            <none>        2181/TCP,2888/TCP,3888/TCP                                         19m
signoz-zookeeper-metrics               ClusterIP   10.96.254.85    <none>        9141/TCP                                                           19m
```

Confirm `CHK_STS`, `CHK_PVC` and `KEEPER_HOST` against this output.

**Verify:**

```bash
kubectl -n "$NS" exec "$CHK_STS-0" -- sh -c 'echo ruok | nc 127.0.0.1 2181'
```

```text
imok
```

**If it fails:** If the Keeper pod is not running, check node taints, and check that the Keeper claim landed in the same zone as the ZooKeeper claim. Its storage class is `global.storageClass`, else `keeper.persistence.storageClass`. The converter Job must mount both. Then run step 2 again.

##### Step 3: Stop ingestion and merges

**Purpose:** Freeze the coordination state, so nothing is written to ZooKeeper between the conversion and the swap.

**Run:**

```bash
kubectl -n "$NS" scale deployment "$COLLECTOR_DEPLOY" --replicas=0
kubectl -n "$NS" get pods | grep otel-collector

chc "SYSTEM STOP MERGES"
```

**Expect:**

```text
deployment.apps/signoz-otel-collector scaled
signoz-otel-collector-59fbb9b588-c4fjj        1/1     Terminating   0          8m7s
```

`SYSTEM STOP MERGES` prints nothing. The collector pod can still be listed for a few seconds after the scale-down. A second `get pods` shows it gone.

> [!NOTE]
> Agents sending to the collector buffer and retry while it is down. Expect a gap in your data for the window, not a loss, within the agents' retry limits.

**Verify:**

```bash
chc "SELECT count() FROM system.replication_queue"
chc "SELECT count() FROM system.mutations WHERE NOT is_done"
```

```text
0
0
```

**If it fails:** If either count will not drain to `0`, do not proceed: an in-flight mutation converted mid-flight comes back inconsistent. Wait, or investigate the stuck entry first.

##### Step 4: Record the ZooKeeper tree and replica baseline

**Purpose:** Capture the numbers the migration is verified against: the shape of the tree, and how many replicated tables must come back.

**Run:**

```bash
chc "
  SELECT path, name, numChildren
  FROM system.zookeeper
  WHERE path IN ('/', '/clickhouse', '/clickhouse/$CHI_NAME', '/clickhouse/$CHI_NAME/task_queue')
  ORDER BY path, name
  FORMAT PrettyCompact"

chc "SELECT count() FROM system.replicas"
```

**Expect:**

```text
   ┌─path─────────────────────────────────────┬─name──────────────┬─numChildren─┐
1. │ /                                        │ clickhouse        │           4 │
2. │ /                                        │ zookeeper         │           2 │
3. │ /clickhouse                              │ sessions          │           1 │
4. │ /clickhouse                              │ signoz-clickhouse │           1 │
5. │ /clickhouse                              │ tables            │          56 │
6. │ /clickhouse                              │ task_queue        │           1 │
7. │ /clickhouse/signoz-clickhouse            │ task_queue        │           2 │
8. │ /clickhouse/signoz-clickhouse/task_queue │ ddl               │         354 │
9. │ /clickhouse/signoz-clickhouse/task_queue │ replicas          │           3 │
   └──────────────────────────────────────────┴───────────────────┴─────────────┘

56
```

Write down `numChildren` for `/clickhouse → tables` and the `system.replicas` count. They must match after the swap.

**Verify:**

```bash
chc "SELECT count() FROM system.replicas WHERE is_readonly"
```

```text
0
```

**If it fails:** If any replica is already read-only before the migration starts, fix that first. Do not carry a read-only table through the conversion.

##### Step 5: Capture the Keeper storage paths

**Purpose:** Confirm where inside the Keeper volume the snapshot has to land, so the converter writes where Keeper reads at startup.

**Run:**

```bash
kubectl -n "$NS" exec "$CHK_STS-0" -- id
kubectl -n "$NS" exec "$CHK_STS-0" -- ls -la /var/lib/clickhouse-keeper/coordination/
kubectl -n "$NS" exec "$CHK_STS-0" -- \
  grep -E 'snapshot_storage_path|log_storage_path|server_id' /etc/clickhouse-keeper/keeper_config.xml
```

**Expect:**

```text
uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel),11(floppy),20(dialout),26(tape),27(video),101(clickhouse)

total 0
drwxr-xr-x    1 clickhouse clickhouse        32 Nov 17 08:38 .
drwxrwxrwx    1 clickhouse clickhouse        82 Nov 17 08:38 ..
drwxr-xr-x    1 clickhouse clickhouse         0 Nov 17 08:38 log
drwxr-x---    1 clickhouse clickhouse        44 Nov 17 08:38 logs
drwxr-xr-x    1 clickhouse clickhouse         0 Nov 17 08:38 snapshots

            <server_id>1</server_id>
            <log_storage_path>/var/lib/clickhouse/coordination/logs</log_storage_path>
            <snapshot_storage_path>/var/lib/clickhouse/coordination/snapshots</snapshot_storage_path>
```

The prefix in `keeper_config.xml` and the mount point on disk can differ. Use the path relative to the volume root, which is `coordination/snapshots` either way. That is what step 7 writes to. Files must end up owned by uid and gid `101`, the `fsGroup` that `keeper.podSecurityContext` sets by default.

**Verify:**

```bash
kubectl -n "$NS" exec "$CHK_STS-0" -- sh -c 'echo mntr | nc 127.0.0.1 2181' | grep -E 'zk_server_state|zk_znode_count'
```

```text
zk_server_state	standalone
zk_znode_count	4
```

A near-empty count here is expected: an idle Keeper holds only its own nodes and has never held the real tree.

##### Step 6: Scale ZooKeeper and Keeper down

> [!WARNING]
> From here, ClickHouse has no coordination store, and every `ReplicatedMergeTree` table is read-only until step 9 completes. This is the start of the outage window. Nothing is destroyed: both claims are retained, and you can reverse the step by scaling back up.
>
> Between this step and step 11, do not restart the operator pod and do not run `helm upgrade`. Until step 8, either one restarts Keeper while the converter is writing to its volume. After step 8, an upgrade with ZooKeeper still enabled writes ZooKeeper's hosts back into the CHI, and its schema migrator cannot run while the tables are read-only.

**Purpose:** The conversion is offline and file-level. Both ends must be stopped so the files are consistent and unclaimed.

**Run:**

```bash
kubectl -n "$NS" scale statefulset "$CHK_STS" --replicas=0
kubectl -n "$NS" scale statefulset "$ZK_STS" --replicas=0
```

If ZooKeeper runs more than one replica, this scales all of them. Do not leave one up, or it is promoted to leader and keeps writing.

**Expect:**

```text
statefulset.apps/chk-signoz-keeper-cluster-0-0 scaled
statefulset.apps/signoz-zookeeper scaled
```

**Verify:**

```bash
kubectl -n "$NS" get pods | grep -E 'keeper|zookeeper'
```

```text
chk-signoz-keeper-cluster-0-0-0               1/1     Terminating   0          4m15s
signoz-zookeeper-0                            1/1     Running       0          20m
```

The first `get pods` right after the scale-down still lists the pods. A second one a few seconds later shows none and prints nothing.

**If it fails:** If a pod will not terminate, do not force-delete a ZooKeeper pod mid-write. Wait for the graceful shutdown, then run step 6 again.

##### Step 7: Convert the ZooKeeper data onto the Keeper volume

> [!WARNING]
> The Job deletes the contents of `coordination/log`, `coordination/logs` and `coordination/snapshots` on the Keeper claim before writing. This is deliberate: a leftover snapshot or changelog from Keeper's first start can beat the converted snapshot at load time. Only Keeper's own state is deleted. The ZooKeeper volume and ClickHouse's parts are untouched.

**Purpose:** Translate the ZooKeeper snapshot, plus the transaction logs written after it, into one Keeper snapshot on the Keeper volume.

**Run:**

```bash
kubectl -n "$NS" delete job keeper-converter --ignore-not-found
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: keeper-converter
  namespace: $NS
spec:
  backoffLimit: 0
  template:
    spec:
      restartPolicy: Never
      securityContext:
        fsGroup: 101
      containers:
        - name: converter
          image: $CONVERTER_IMAGE
          command: ["/bin/bash", "-c"]
          args:
            - |
              set -euo pipefail
              rm -rf /chk/coordination/log/* /chk/coordination/logs/* /chk/coordination/snapshots/*
              mkdir -p /chk/coordination/snapshots
              clickhouse keeper-converter \
                --zookeeper-logs-dir /zk/data/version-2 \
                --zookeeper-snapshots-dir /zk/data/version-2 \
                --output-dir /chk/coordination/snapshots
              chown -R 101:101 /chk/coordination
              md5sum /chk/coordination/snapshots/snapshot_*.bin.zstd
          volumeMounts:
            - name: zk
              mountPath: /zk
              readOnly: true
            - name: chk
              mountPath: /chk
      volumes:
        - name: zk
          persistentVolumeClaim:
            claimName: $ZK_LEADER_PVC
        - name: chk
          persistentVolumeClaim:
            claimName: $CHK_PVC
EOF

kubectl -n "$NS" wait --for=condition=complete job/keeper-converter --timeout=600s
kubectl -n "$NS" logs job/keeper-converter | tail -n 5
```

**Expect:**

```text
job.batch/keeper-converter created
job.batch/keeper-converter condition met
Deserialized txns log: 8000
Deserialized txns log: 9000
Finished /zk/data/version-2/log.1 deserialization, totally read 9222 records
Snapshot serialized to path:"/chk/coordination/snapshots/snapshot_9222.bin.zstd"
f2af4b672868853ea2aee209677841d4  /chk/coordination/snapshots/snapshot_9222.bin.zstd
```

The `Totally have 1 snapshots, will use latest` and `Finished, snapshot ZXID 0` lines are earlier in the full log. To see them, filter the log with `grep -E 'Totally|Finished'`.

A stale snapshot on the ZooKeeper side is fine, because the converter replays the logs written after it. That is where the ZXID in the file name comes from. A log line reading `Totally have 0 snapshots` is a failure: the converter found nothing to read.

**Verify:**

```bash
kubectl -n "$NS" logs job/keeper-converter | grep -c 'coordination/snapshots/snapshot_'
kubectl -n "$NS" delete job keeper-converter
```

The count is `2`: the `Snapshot serialized` line and the `md5sum` line.

**If it fails:** If the Job stays `Pending`, the two claims are not attachable to one node. Both are zonal, so they must sit in the same zone (see step 2). If the converter errors on deserialization, nothing has been repointed. Check the ZooKeeper version and go to step 6.

##### Step 8: Bring Keeper up and confirm it loaded the converted tree

**Purpose:** Confirm that Keeper serves the real ClickHouse tree, not an empty one, before any client is pointed at it.

**Run:**

```bash
kubectl -n "$NS" scale statefulset "$CHK_STS" --replicas=1
kubectl -n "$NS" rollout status statefulset "$CHK_STS" --timeout=300s

kubectl -n "$NS" exec "$CHK_STS-0" -- sh -c 'echo mntr | nc 127.0.0.1 2181' | grep -E 'zk_server_state|zk_znode_count'
```

**Expect:**

```text
statefulset.apps/chk-signoz-keeper-cluster-0-0 scaled
Waiting for statefulset spec update to be observed...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
statefulset rolling update complete 1 pods at revision chk-signoz-keeper-cluster-0-0-58f59c9d49...
zk_server_state	standalone
zk_znode_count	5355
```

`zk_znode_count` is in the same order of magnitude as the ZooKeeper tree from step 4, not a handful.

**Verify:**

```bash
kubectl -n "$NS" exec "$CHK_STS-0" -- ls /var/lib/clickhouse-keeper/coordination/snapshots /var/lib/clickhouse-keeper/coordination/logs
```

```text
/var/lib/clickhouse-keeper/coordination/logs:
changelog_9223_109222.bin

/var/lib/clickhouse-keeper/coordination/snapshots:
snapshot_9222.bin.zstd
```

`snapshots` holds the converted `snapshot_<zxid>.bin.zstd` from step 7, and `logs` holds a `changelog_<zxid+1>_...bin` that starts right after it, so Keeper started from the converted snapshot.

**If it fails:** If `zk_znode_count` comes back near-empty, Keeper started from its own state instead of the converted snapshot. Nothing is repointed yet, so this is free to redo: scale Keeper back to 0 and go to step 7.

##### Step 9: Repoint ClickHouse at Keeper and restart the pods

> [!WARNING]
> The host change reaches ClickHouse as a config reload, and the live session does not move. ClickHouse keeps talking to the old host until the pods restart. If you skip the restart, the migration looks like it worked when it has not.
>
> This is the last step before ingestion resumes, and the last point at which rollback is clean. The host and port must be exactly `$KEEPER_HOST` and `2181`, because step 11 re-renders the same values and must find no difference.

**Purpose:** Point ClickHouse at Keeper, and force it to open a new session against the converted tree.

**Run:**

```bash
kubectl -n "$NS" patch chi "$CHI_NAME" --type merge -p '{"spec":{"configuration":{"zookeeper":{"nodes":[{"host":"'"$KEEPER_HOST"'","port":2181}]}}}}'

for P in $CH_PODS; do
  kubectl -n "$NS" delete pod "$P"
done
kubectl -n "$NS" wait --for=condition=Ready pod -l clickhouse.altinity.com/chi="$CHI_NAME" --timeout=300s
```

**Expect:**

```text
clickhouseinstallation.clickhouse.altinity.com/signoz-clickhouse patched
pod "chi-signoz-clickhouse-cluster-0-0-0" deleted
pod/chi-signoz-clickhouse-cluster-0-0-0 condition met
```

**Verify:**

```bash
chc "SELECT host, port, is_expired, connected_time FROM system.zookeeper_connection"
chc "SELECT count() FROM system.replicas WHERE is_readonly"
kubectl -n "$NS" get chi "$CHI_NAME" -o jsonpath='{.metadata.generation}'
```

`host` is `$KEEPER_HOST`, `is_expired` is `0`, `connected_time` is after the restart, and the read-only count is `0`. Note the CHI generation. Step 11 checks that it has not changed.

**If it fails:** If `host` still shows ZooKeeper, the pod did not restart. Delete it again. If tables are read-only against Keeper, the tree did not carry over. See [Rollback during the migration](#rollback-during-the-migration).

##### Step 10: Resume merges and ingestion

**Purpose:** Unfreeze the cluster and let ingestion catch up.

**Run:**

```bash
chc "SYSTEM START MERGES"
kubectl -n "$NS" scale deployment "$COLLECTOR_DEPLOY" --replicas="$COLLECTOR_REPLICAS"
```

**Expect:**

```text
deployment.apps/signoz-otel-collector scaled
```

`SYSTEM START MERGES` prints nothing.

**Verify:**

```bash
kubectl -n "$NS" get pods | grep otel-collector
chc "SELECT count() FROM signoz_traces.signoz_index_v3 WHERE timestamp > now() - INTERVAL 5 MINUTE"
```

```text
signoz-otel-collector-59fbb9b588-fshfm        0/1     Pending     0          0s
6000
```

The collector pod is `Pending` for a few seconds and then `Running`. The row count climbs between two runs of the query only while agents are sending. With nothing sending, the five-minute window makes it fall, which is not a failure.

**If it fails:** If the count stays flat while collectors are healthy, re-check the coordination connection with the step 9 Verify query.

##### Step 11: Remove ZooKeeper from the release

> [!WARNING]
> Run this step right after step 10. Until it runs, the live CHI differs from the release, and any `helm upgrade` with `zookeeper.enabled` still `true` writes ZooKeeper's hosts back into the CHI.

**Purpose:** Make the release agree with the step 9 patch, and remove the ZooKeeper StatefulSet and Services.

**Run:**

Set this in your values file:

```yaml
zookeeper:
  enabled: false
```

```bash
helm upgrade "$RELEASE" signoz/signoz --version 0.152.0 -n "$NS" -f values.yaml
```

The chart renders the same Keeper host the patch set, so the CHI does not change and the operator does nothing. Helm removes the ZooKeeper StatefulSet and its Services, both idle since step 6. It leaves the claim `$ZK_LEADER_PVC`, because Helm never deletes claims.

**Expect:**

```text
Release "signoz" has been upgraded. Happy Helming!
NAME: signoz
LAST DEPLOYED: Tue Nov 17 14:15:12 2026
NAMESPACE: signoz
STATUS: deployed
REVISION: 4
```

The chart's NOTES follow.

**Verify:**

```bash
kubectl -n "$NS" get statefulset "$ZK_STS"
kubectl -n "$NS" get pvc "$ZK_LEADER_PVC"
chc "SELECT host FROM system.zookeeper_connection"
kubectl -n "$NS" get chi "$CHI_NAME" -o jsonpath='{.metadata.generation}'
```

The StatefulSet lookup returns `NotFound`, the claim is still `Bound`, `host` is still `$KEEPER_HOST`, and the CHI generation equals the value noted in step 9.

Argo CD users: turn auto-sync back on now. The sync must show no change on the CHI.

#### Check the result

The migration is complete when all of the following hold, and the Verify query below holds too.

**The tree carried over intact:**

```bash
chc "SELECT name, numChildren FROM system.zookeeper WHERE path = '/clickhouse' FORMAT PrettyCompact"
```

`tables` has the same `numChildren` as in step 4.

**ClickHouse is talking to Keeper, on every pod:**

```bash
for P in $CH_PODS; do
  kubectl -n "$NS" exec "$P" -c clickhouse -- clickhouse-client --user "$CH_USER" --password "$CH_PASSWORD" -q \
    "SELECT host, is_expired FROM system.zookeeper_connection"
done
```

`host` is `$KEEPER_HOST` on each.

**Queues are moving and nothing is stuck:**

```bash
chc "SELECT count() FROM system.replication_queue WHERE num_tries > 10"
chc "SELECT name, value FROM system.errors WHERE name IN ('TABLE_IS_READ_ONLY','KEEPER_EXCEPTION') AND value > 0"
```

The first returns `0`. Error counters are cumulative since the restart, so check that the second stops climbing, not that it reads zero.

**Afterwards:**

- The ZooKeeper StatefulSet is gone after step 11. Its claim is the rollback asset. Keep the claim until the installation has run a full retention cycle on Keeper, then remove it with `kubectl -n "$NS" delete pvc "$ZK_LEADER_PVC"`. If ZooKeeper had replicas, also remove the other `data-$ZK_STS-*` claims.
- To run three Keeper replicas, set `keeper.replicaCount: 3` and run `helm upgrade`. The operator adds the replicas, and they take the tree from the leader.
- Any later change to the coordination hosts needs the same manual pod restart as step 9.

#### Rollback during the migration

**Before step 9.** Nothing has been repointed. Scale Keeper back to `0`, scale ZooKeeper back up, and the release is exactly where step 6 left it:

```bash
kubectl -n "$NS" scale statefulset "$CHK_STS" --replicas=0
kubectl -n "$NS" scale statefulset "$ZK_STS" --replicas="$ZK_REPLICAS"
```

**After step 9, before ingestion resumes.** Rollback is still clean. Patch the CHI back to ZooKeeper, scale ZooKeeper back up, wait for it, and restart the ClickHouse pods. No Helm runs. The ZooKeeper claim was never touched, and its state is still current because writes were frozen in step 3:

```bash
kubectl -n "$NS" patch chi "$CHI_NAME" --type merge -p '{"spec":{"configuration":{"zookeeper":{"nodes":[{"host":"'"$ZK_STS-0.$ZK_STS-headless"'","port":2181}]}}}}'
kubectl -n "$NS" scale statefulset "$ZK_STS" --replicas="$ZK_REPLICAS"
kubectl -n "$NS" rollout status statefulset "$ZK_STS" --timeout=300s

for P in $CH_PODS; do
  kubectl -n "$NS" delete pod "$P"
done
```

With more than one ZooKeeper replica, `nodes` carries one entry per pod: `$ZK_STS-0.$ZK_STS-headless`, `$ZK_STS-1.$ZK_STS-headless`, and so on.

**After ingestion resumes.** There is no clean rollback, because new parts are registered in Keeper only and the ZooKeeper state goes stale behind them. Do not point ClickHouse back at ZooKeeper at that stage, because going back means rebuilding coordination anyway.

**Recovery when the tree did not carry over.** If tables came up read-only against an empty Keeper (`Table is in readonly mode since table metadata was not found in zookeeper`, `No node, path /clickhouse/tables/<uuid>/0/log`), you can rebuild the coordination metadata from the parts already on disk, with no re-ingest and no re-replication. `SYSTEM RESTART REPLICAS` acquires a fresh session and is cluster-wide, run once per server. `SYSTEM RESTORE REPLICA` is what actually writes `/clickhouse/tables/<uuid>/0` back and re-enumerates the active parts, so it runs per table:

```bash
chc "SYSTEM RESTART REPLICAS"

chc "SELECT concat('SYSTEM RESTORE REPLICA ', database, '.', table, ';') FROM system.replicas WHERE is_readonly FORMAT TabSeparatedRaw" \
  | kubectl -n "$NS" exec -i "$CH_POD" -c clickhouse -- clickhouse-client --user "$CH_USER" --password "$CH_PASSWORD" -n

chc "SELECT count() FROM system.replicas WHERE is_readonly"
```

The last query returns `0`. Run this on every ClickHouse pod that reports read-only tables.

#### If you upgraded without `zookeeper.enabled: true`

An install that already has the Keeper CRD, upgraded with values that drop `zookeeper.enabled` without migrating, gets Keeper with an empty tree. Helm has removed the ZooKeeper StatefulSet and Services, and the claim `data-<release>-zookeeper-0` is retained. Every replicated table is read-only. No data is lost.

To go back, turn ZooKeeper on again in your values file:

```yaml
zookeeper:
  enabled: true
```

The schema migrator cannot run while the tables are read-only, so the upgrade below turns it off for this one revision with `telemetryStoreMigrator.enabled=false` ([section 14](#14-schema-migrator)). The next `helm upgrade` without that `--set` runs it again:

```bash
helm upgrade "$RELEASE" signoz/signoz --version 0.152.0 -n "$NS" -f values.yaml --set telemetryStoreMigrator.enabled=false
kubectl -n "$NS" rollout status statefulset "$ZK_STS" --timeout=300s

for P in $CH_PODS; do
  kubectl -n "$NS" delete pod "$P"
done
kubectl -n "$NS" wait --for=condition=Ready pod -l clickhouse.altinity.com/chi="$CHI_NAME" --timeout=300s

chc "SELECT host, port, is_expired FROM system.zookeeper_connection"
chc "SELECT count() FROM system.replicas WHERE is_readonly"
```

`host` is the ZooKeeper host and the read-only count is `0`. When you are ready, start this section from step 1.

#### Getting help

Open an issue on SigNoz/charts with the outputs of steps 4, 7 and 8 and the current `system.zookeeper_connection`. Escalate when replicas stay read-only after `SYSTEM RESTORE REPLICA`.

> [!WARNING]
> Do not delete the ZooKeeper claims, and do not force-delete ZooKeeper pods mid-write. Those volumes are the only rollback path.

### You will see

- In a run with one ClickHouse and one ZooKeeper replica, ingestion was stopped for about 3 minutes (step 3 to step 10), and steps 3 to 11 took about 6 minutes. The converter Job ran for 3 seconds.
- In a run with two ClickHouse replicas and three ZooKeeper replicas, ingestion was stopped for 4 minutes 13 seconds. The converter mounted only the leader's claim and ran for 4 seconds, and Keeper held 7096 znodes after step 8. Both ClickHouse pods came back on Keeper with 56 writable replicas each.
- In that run, `SYSTEM STOP MERGES` stopped merges on `$CH_POD` only. The other replica merged through the window, and the migration finished clean.
- Keeper scaled to zero stays at zero through step 8. The operator logs `No reconcile work - abort reconcile` for the ClickHouseKeeperInstallation.
- Keeper logs `Listen [0.0.0.0]:2181 failed` warnings when it starts after step 8, and serves clients on 2181.
- The step 9 patch alone restarts no pod. The pod delete moves the session, and `connected_time` is after the restart.
- `keeper.replicaCount: 3` after step 11 brings two more Keeper pods within about a minute, a leader with 2 synced followers at the same znode count, and no ClickHouse pod restarts.

### Verify

```bash
chc "SELECT count(), countIf(is_readonly), countIf(is_session_expired) FROM system.replicas"
```

```text
56	0	0
```

The first number equals the count recorded in step 4.

## 12. Uninstall and rollback

### Applies to

You uninstall the release, or roll it back to a revision from before 0.152.0.

### What changes

The operator, the ClickHouseInstallation and the ClickHouseKeeperInstallation are in one release. `helm uninstall` removes the operator before it can finish the installations' finalizers.

The old and new operator Deployments have different selectors, so a rollback to a revision from before 0.152.0 needs the new Deployment deleted by hand.

Claims stay on both paths. Remove them by hand when the data is no longer wanted.

### You must

**To uninstall:**

1. Delete the installations and wait for them:

   ```bash
   kubectl -n <namespace> delete chi,chk -l app.kubernetes.io/instance=<release> --wait
   ```

2. Uninstall the release:

   ```bash
   helm uninstall <release> -n <namespace>
   ```

3. If the release was uninstalled first, remove each installation's finalizer, then delete what the operator left:

   ```bash
   kubectl -n <namespace> patch chi <clickhouse.fullname> --type merge -p '{"metadata":{"finalizers":[]}}'
   kubectl -n <namespace> patch chk <keeper.fullname> --type merge -p '{"metadata":{"finalizers":[]}}'
   kubectl -n <namespace> delete statefulset,service,configmap -l clickhouse.altinity.com/chi=<clickhouse.fullname>
   kubectl -n <namespace> delete statefulset,service,configmap -l clickhouse-keeper.altinity.com/chk=<keeper.fullname>
   ```

**To roll back** to a revision from before 0.152.0, while ClickHouse still runs on ZooKeeper (before section 11, step 9):

1. With Keeper on, delete the ClickHouseKeeperInstallation and wait for it, while the 0.27.4 operator still runs:

   ```bash
   kubectl -n <namespace> delete chk -l app.kubernetes.io/instance=<release> --wait
   ```

2. Delete the operator Deployment right before the rollback:

   ```bash
   kubectl delete deployment -n <namespace> -l app.kubernetes.io/name=clickhouse-operator,app.kubernetes.io/instance=<release>
   ```

3. Roll back:

   ```bash
   helm rollback <release> <revision> -n <namespace>
   ```

> [!IMPORTANT]
> Once ClickHouse runs on Keeper, stay on 0.152.0 or later. For the migration window, see [Rollback during the migration](#rollback-during-the-migration) in section 11.

### You will see

- If `helm uninstall` runs first, the ClickHouseInstallation keeps `finalizer.clickhouseinstallation.altinity.com` with a deletion timestamp. Its StatefulSet, pod and Services keep running, every claim stays `Bound`, and the operator pod is gone within 20 seconds. A ClickHouseKeeperInstallation stays the same way.
- Removing the finalizer prints `clickhouseinstallation.clickhouse.altinity.com/<clickhouse.fullname> patched`.

### Verify

```bash
kubectl get chi,chk -n <namespace> -l app.kubernetes.io/instance=<release>
```

After an uninstall it prints `No resources found in <namespace> namespace.`

## 13. The SigNoz container

### Applies to

Every install: the SigNoz pod rolls once on the first upgrade. The details matter when your values set `signoz.env`, a port under `signoz.service`, `signoz.service.labels` or `signoz.ingress.hosts`.

### What changes

- The SigNoz container lists the chart's variables first: `CLICKHOUSE_*`, then `SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN` and `SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_CLUSTER`, then, with `postgresql.enabled: true`, `POSTGRES_*` and `SIGNOZ_SQLSTORE_*`. Your `signoz.env` keys follow, sorted by the key as you write it, so upper-case keys come before lower-case ones. In 0.151.0 the chart's variables and yours were interleaved.
- A variable whose value references another through `$(NAME)` is placed after it, so Kubernetes expands it.
- A number in `signoz.env` renders in full: `signoz.env.signoz_cache_memory_max__cost: 1000000` gives `"1000000"`, where 0.151.0 gave `"1e+06"`. Other values render with plain YAML quoting and keep their value.
- The ClickHouse variables changed in the SigNoz container, and the same way in the collector, its `check` init container and the schema migrator. `CLICKHOUSE_PASSWORD` reads the key `password` of the Secret `<clickhouse.fullname>-credentials` through a `secretKeyRef`, or the key `clickhouse.existingSecretPasswordKey` of `clickhouse.existingSecret` ([section 7](#7-objects)), where 0.151.0 wrote the password into the pod spec. `CLICKHOUSE_HTTP_PORT` is gone. `CLICKHOUSE_VERIFY` is `"false"`, as the collector already had it.
- SigNoz's connection string `SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN` is `tcp://$(CLICKHOUSE_USER):$(CLICKHOUSE_PASSWORD)@$(CLICKHOUSE_HOST):$(CLICKHOUSE_PORT)`, the form the collector's `check` and the schema migrator already used, and `SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_CLUSTER` is `$(CLICKHOUSE_CLUSTER)`. In 0.151.0 they were `tcp://<host>:<port>/?username=$(CLICKHOUSE_USER)&password=$(CLICKHOUSE_PASSWORD)` and the cluster name. The components put the password into their connection strings unescaped, so it must not contain `/`, `?` or `#`, and a `%` is read as an escape.
- A `signoz.env` key with the name of a chart variable replaces that variable's value in place, and no name is listed twice. This covers `CLICKHOUSE_*` (such as `signoz.env.CLICKHOUSE_USER`), `POSTGRES_*` (such as `signoz.env.postgres_user`), `SIGNOZ_SQLSTORE_PROVIDER` and `SIGNOZ_SQLSTORE_POSTGRES_DSN`.
- The container always declares ports 8080 (`http`), 8085 (`http-internal`) and 4320 (`opamp-internal`), the ports SigNoz listens on. `signoz.service.port`, `signoz.service.internalPort` and `signoz.service.opampPort` move only the Service port, and the Service targets the container ports by name. In 0.151.0 they also set the container ports.
- The pod has no `dashboards` volume, which nothing mounted, so with the default claim template (`signoz.persistence.enabled: true`) and with `postgresql.enabled: true` it has no `volumes` key. Its `volumeMounts` are unchanged. The container has no `args` key while `signoz.extraArgs` is empty.
- An Ingress path in `signoz.ingress.hosts` without `port` routes to `signoz.service.port`, and one without `pathType` gets `ImplementationSpecific`. In 0.151.0 both rendered empty.
- A key in `signoz.service.labels` that matches a chart label is rendered once, with your value.
- New keys: `signoz.envFrom`, `signoz.startupProbe`, `signoz.labels` for the StatefulSet's labels, `signoz.pod.labels` for the pod's labels (a key named like a selector label is ignored), `signoz.extraInitContainers` and `signoz.extraContainers`.

> [!IMPORTANT]
> With `postgresql.enabled: true`, a `signoz.env.signoz_sqlstore_provider`, `signoz.env.signoz_sqlstore_postgres_dsn` or `signoz.env.postgres_*` key now takes effect. In 0.151.0 the chart listed its own `SIGNOZ_SQLSTORE_*` variables after yours, so the chart's value won, and it ignored your `POSTGRES_*` keys. Delete such a key unless you want its value to apply.

### You must

1. If your values hold a key the note above names, delete it before the upgrade, or keep it to apply its value.
2. If your `otelCollector.config`, a `signoz.env` value or anything else reads `CLICKHOUSE_HTTP_PORT`, write the HTTP port itself: `clickhouse.service.httpPort`, or `externalClickhouse.httpPort` for external ClickHouse, `8123` by default.

### You will see

With these values:

```yaml
signoz:
  env:
    signoz_cache_memory_max__cost: 1000000
    CLICKHOUSE_USER: custom
```

the SigNoz container lists its variables in this order, with `CLICKHOUSE_USER` set to `custom` and `SIGNOZ_CACHE_MEMORY_MAX__COST` set to `"1000000"`:

```text
CLICKHOUSE_HOST CLICKHOUSE_PORT CLICKHOUSE_CLUSTER CLICKHOUSE_USER CLICKHOUSE_PASSWORD CLICKHOUSE_SECURE CLICKHOUSE_VERIFY SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_CLUSTER SIGNOZ_ALERTMANAGER_PROVIDER SIGNOZ_ALERTMANAGER_SIGNOZ_EXTERNAL__URL SIGNOZ_CACHE_MEMORY_MAX__COST SIGNOZ_EMAILING_ENABLED SIGNOZ_PROMETHEUS_ACTIVE__QUERY__TRACKER_ENABLED SIGNOZ_TELEMETRYSTORE_PROVIDER
```

### Verify

```bash
kubectl get statefulset -n <namespace> -l app.kubernetes.io/instance=<release>,app.kubernetes.io/component=signoz -o jsonpath='{.items[0].spec.template.spec.containers[0].ports[*].containerPort}'
```

```text
8080 8085 4320
```

```bash
kubectl get statefulset -n <namespace> -l app.kubernetes.io/instance=<release>,app.kubernetes.io/component=signoz -o jsonpath='{.items[0].spec.template.spec.containers[0].env[*].name}'
```

It prints the chart's variables first, then your `signoz.env` keys, with each name once.

## 14. Schema migrator

### Applies to

Every install that runs the schema migrator (`telemetryStoreMigrator.enabled`, on by default). The details matter when your values set a `telemetryStoreMigrator.*` key, you upgrade with `--no-hooks`, or you deploy through Argo CD.

### What changes

- The schema migrator is an ordinary Job named `<telemetryStoreMigrator.name>-<revision>`, `signoz-telemetrystore-migrator-<revision>` by default, where `<revision>` is the release revision. Every install and upgrade creates a new Job, and the migrations run each time. The name is the same whatever the release name. In 0.151.0 it was the Job `signoz-telemetrystore-migrator`, a `pre-upgrade` hook on upgrades under the default `telemetryStoreMigrator.upgradeHelmHooks: true`.
- The Job is a release object, not a hook, so it also runs with `--no-hooks` and with Terraform's `disable_webhooks = true`. To skip it for one upgrade, set `telemetryStoreMigrator.enabled: false`: that revision has no migrator Job, and the collector has no `check` init container.
- `telemetryStoreMigrator.upgradeHelmHooks` has been removed. `false` renders. Any value that turned the hooks on, `true` and a quoted `"false"` included, fails the render with a message to delete the key. The 0.151.0 default was `true`.
- The ServiceAccount `signoz-telemetrystore-migrator` is created only with `telemetryStoreMigrator.serviceAccount.create: true`. The Job runs as `default` unless that is set or `telemetryStoreMigrator.serviceAccount.name` names an existing ServiceAccount. 0.151.0 created it by default, so the upgrade deletes it unless you set `telemetryStoreMigrator.serviceAccount.create: true`.
- The Job always carries the annotation `argocd.argoproj.io/sync-options: Force=true,Replace=true`. Keys in `telemetryStoreMigrator.annotations` are added to it, and your value for `argocd.argoproj.io/sync-options` replaces the chart's. In 0.151.0 the annotation came only with `upgradeHelmHooks: true`.
- `telemetryStoreMigrator.ttlSecondsAfterFinished` sets how long Kubernetes keeps a finished Job. Unset keeps it; `0` deletes it as soon as it finishes.
- New keys for the Job, each rendered as given:
  - `telemetryStoreMigrator.env`: Kubernetes EnvVar objects for the four migration containers and the collector's `check` init container, after the chart's variables, in the order written. An entry named like a chart variable, such as `SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_DSN`, replaces its value.
  - `telemetryStoreMigrator.envFrom`: EnvFromSource objects for the same containers.
  - `telemetryStoreMigrator.podSecurityContext` and `telemetryStoreMigrator.containerSecurityContext`: the security contexts of the Job's pod and of the four migration containers.
  - `telemetryStoreMigrator.extraVolumes` and `telemetryStoreMigrator.extraVolumeMounts`: volumes on the Job's pod, mounted in the four migration containers.
  - `telemetryStoreMigrator.labels`: labels on the Job; a key the chart also sets takes your value.
  - `telemetryStoreMigrator.pod.labels` and `telemetryStoreMigrator.pod.annotations`: labels and annotations on the Job's pod; a pod label named like a selector label is ignored.
  - `telemetryStoreMigrator.priorityClassName`: the priority class of the Job's pod.

The migrator containers' ClickHouse variables changed as [section 13](#13-the-signoz-container) describes. The migrator pod's pull secrets and the registry of its image are in [section 8](#8-registry-and-pull-secrets).

### You must

1. Delete `telemetryStoreMigrator.upgradeHelmHooks` from your values.
2. If something is bound to the ServiceAccount `signoz-telemetrystore-migrator`, such as a cloud identity set through `telemetryStoreMigrator.serviceAccount.annotations`, set `telemetryStoreMigrator.serviceAccount.create: true` to keep it.
3. If the Job from 0.151.0, named `telemetryStoreMigrator.name` without a revision (`signoz-telemetrystore-migrator` by default), is still listed after the upgrade, delete it:

   ```bash
   kubectl -n <namespace> delete job signoz-telemetrystore-migrator
   ```

### You will see

- A new Job `signoz-telemetrystore-migrator-<revision>` on every install and upgrade.
- An upgrade render of the Job, `helm template signoz signoz/signoz --version 0.152.0 --is-upgrade --show-only templates/telemetrystore-migrator/job.yaml`, starts with the Argo CD annotation alone, where 0.151.0 also rendered `helm.sh/hook: pre-upgrade` and `helm.sh/hook-delete-policy: before-hook-creation`. `helm template` renders revision 1:

  ```yaml
  apiVersion: batch/v1
  kind: Job
  metadata:
    name: signoz-telemetrystore-migrator-1
    labels:
      app.kubernetes.io/component: signoz-telemetrystore-migrator
      app.kubernetes.io/instance: signoz
      app.kubernetes.io/name: signoz
    annotations:
      argocd.argoproj.io/sync-options: Force=true,Replace=true
  ```

### Verify

```bash
kubectl -n <namespace> wait --for=condition=complete job/signoz-telemetrystore-migrator-<revision> --timeout=15m
```

```text
job.batch/signoz-telemetrystore-migrator-<revision> condition met
```

`<revision>` is the last revision `helm history <release> -n <namespace>` lists.

## 15. The collector

### Applies to

Your values set an `otelCollector.*` key, `telemetryStoreMigrator.env`, `telemetryStoreMigrator.envFrom` or `signoz.service.opampPort`.

### What changes

- The collector's `check` init container waits for the schema migrator's sync migrations ([section 14](#14-schema-migrator)). It takes `telemetryStoreMigrator.env`, `telemetryStoreMigrator.envFrom` and `telemetryStoreMigrator.resources` from the migrator, and `otelCollector.extraVolumeMounts` and `otelCollector.containerSecurityContext` from the collector. In 0.151.0 it took only `telemetryStoreMigrator.resources` of these.
- The collector reaches SigNoz's OpAMP endpoint on `signoz.service.opampPort`, as in `ws://signoz:4320/v1/opamp` with the defaults. In 0.151.0 it always dialed port 4320.
- `otelCollector.clusterRole.clusterRoleBinding.annotations` reach the ClusterRoleBinding.
- A key in `otelCollector.service.labels` that matches a chart label is rendered once, with your value.
- New keys: `otelCollector.envFrom`, `otelCollector.startupProbe` and `otelCollector.labels` for the Deployment's labels. `otelCollector.env`, `otelCollector.extraArgs`, `otelCollector.pod.labels` and `otelCollector.pod.annotations` replace old keys, in [section 5](#5-moved-keys).

The ClickHouse variables of the collector and its `check` init container changed as [section 13](#13-the-signoz-container) describes. The collector pod's pull secrets and the registry of its images are in [section 8](#8-registry-and-pull-secrets).

### You must

1. If the `check` init container needs a variable or a secret, such as a proxy setting, set it in `telemetryStoreMigrator.env` or `telemetryStoreMigrator.envFrom`.
2. If `check` must read a file, such as a CA certificate for ClickHouse, put its volume in `otelCollector.extraVolumes` and mount it with `otelCollector.extraVolumeMounts`. The collector container mounts it too.

### You will see

With these values:

```yaml
telemetryStoreMigrator:
  env:
    - name: HTTPS_PROXY
      value: http://proxy:3128
otelCollector:
  extraVolumes:
    - name: certs
      secret:
        secretName: ch-ca
  extraVolumeMounts:
    - name: certs
      mountPath: /etc/ssl/ch
  containerSecurityContext:
    runAsNonRoot: true
```

the `check` init container renders with:

```yaml
name: check
securityContext:
  runAsNonRoot: true
volumeMounts:
  - mountPath: /etc/ssl/ch
    name: certs
```

and its variables end with `HTTPS_PROXY`:

```text
CLICKHOUSE_HOST CLICKHOUSE_PORT CLICKHOUSE_CLUSTER CLICKHOUSE_USER CLICKHOUSE_PASSWORD CLICKHOUSE_SECURE CLICKHOUSE_VERIFY SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_DSN SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_CLUSTER SIGNOZ_OTEL_COLLECTOR_TIMEOUT SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_REPLICATION HTTPS_PROXY
```

### Verify

```bash
kubectl get deployment -n <namespace> -l app.kubernetes.io/instance=<release>,app.kubernetes.io/component=otel-collector -o jsonpath='{.items[0].spec.template.spec.initContainers[0].env[*].name}'
```

It prints the chart's variables, `CLICKHOUSE_HOST` to `SIGNOZ_OTEL_COLLECTOR_CLICKHOUSE_REPLICATION`, then the names in `telemetryStoreMigrator.env`.

## 16. Bundled Postgres

### Applies to

Your values set `postgresql.enabled: true`.

### What changes

- The bundled Postgres chart ships inside the SigNoz chart, at version `0.0.3`; 0.151.0 pulled `0.0.2` from `https://charts.signoz.io`. Its objects carry `helm.sh/chart: postgresql-0.0.3`.
- The data claim `pgdata-<postgresql.fullname>-0` is mounted at `/var/lib/postgresql/data`, and `PGDATA` is `/var/lib/postgresql/data/pgdata`. In 0.151.0 the claim was mounted at `/var/lib/postgresql` and `PGDATA` was `/var/lib/postgresql/data`. The database directory is now `pgdata` at the root of the claim, a path the 0.151.0 pod never wrote to. The Postgres pod rolls once.
- The chart stores `postgresql.auth.password` under the key `password` in the Secret `<postgresql.fullname>-auth`. That name is `<release>-postgresql-auth` unless `postgresql.fullnameOverride` or `postgresql.nameOverride` is set, and is cut to 63 characters when longer. The chart creates no such Secret when `postgresql.auth.existingSecret` is set.
- SigNoz reads `POSTGRES_PASSWORD` from the key `password` of the Secret `<postgresql.fullname>-auth` through a `secretKeyRef`, in place of the literal value in its pod spec. With `postgresql.auth.existingSecret` set, SigNoz and Postgres read the password from that Secret, under the key `postgresql.auth.secretKeys.userPasswordKey` (`password` when unset), as in 0.151.0.

> [!IMPORTANT]
> Dump the SigNoz database before the upgrade and compare its tables after it, as below. Postgres starts on a directory of the claim that 0.151.0 never wrote to.

### You must

1. Before the upgrade, list the tables and dump the database. `--clean --if-exists` lets the dump replace the tables a restore finds:

   ```bash
   kubectl -n <namespace> exec <postgresql.fullname>-0 -- psql -U <postgresql.auth.username> -d <postgresql.auth.database> -c '\dt'
   kubectl -n <namespace> exec <postgresql.fullname>-0 -- pg_dump --clean --if-exists -U <postgresql.auth.username> <postgresql.auth.database> > signoz-db.sql
   ```

2. After the upgrade, run the Verify command below. If tables from step 1 are missing, or SigNoz shows none of your users, dashboards or alerts, stop SigNoz, restore the dump and start SigNoz again:

   ```bash
   kubectl -n <namespace> scale statefulset -l app.kubernetes.io/instance=<release>,app.kubernetes.io/component=signoz --replicas=0
   kubectl -n <namespace> exec -i <postgresql.fullname>-0 -- psql -U <postgresql.auth.username> -d <postgresql.auth.database> < signoz-db.sql
   kubectl -n <namespace> scale statefulset -l app.kubernetes.io/instance=<release>,app.kubernetes.io/component=signoz --replicas=<signoz.replicaCount>
   ```

### You will see

The Postgres container renders with the new paths:

```yaml
env:
  - name: POSTGRESQL_VOLUME_DIR
    value: "/var/lib/postgresql/data"
  - name: PGDATA
    value: "/var/lib/postgresql/data/pgdata"
volumeMounts:
  - name: pgdata
    mountPath: /var/lib/postgresql/data
```

and the chart renders the Secret, here for the release `signoz`, shown without its labels and with the password as a placeholder:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: signoz-postgresql-auth
type: Opaque
stringData:
  password: "<postgresql.auth.password>"
```

### Verify

```bash
kubectl -n <namespace> exec <postgresql.fullname>-0 -- psql -U <postgresql.auth.username> -d <postgresql.auth.database> -c '\dt'
```

It lists the same tables as step 1 of "You must".

```bash
kubectl get statefulset -n <namespace> -l app.kubernetes.io/instance=<release>,app.kubernetes.io/component=signoz -o jsonpath='{.items[0].spec.template.spec.containers[0].env[?(@.name=="POSTGRES_PASSWORD")].valueFrom.secretKeyRef.name} {.items[0].spec.template.spec.containers[0].env[?(@.name=="POSTGRES_PASSWORD")].valueFrom.secretKeyRef.key}'
```

It prints the Secret and the key that the SigNoz container's `POSTGRES_PASSWORD` reads. With the default names:

```text
<release>-postgresql-auth password
```

With `postgresql.fullnameOverride` or `postgresql.nameOverride` set, the Secret is `<postgresql.fullname>-auth`. With `postgresql.auth.existingSecret` set, it prints that Secret and `postgresql.auth.secretKeys.userPasswordKey`, `password` when unset.

## Operator 0.27.4 behavior

The 0.27.4 operator does the following on its own:

- Per-CPU metrics (`OS*CPU<n>`, `CPUFrequencyMHz_<n>`) are no longer exported once the 0.27.4 operator runs. Dashboards and alerts on them get no data.
- At the next ClickHouse restart, the `clickhouse_operator` user gains `access_management` and named-collection grants on ClickHouse 23.3 and later, and the operator sets `display_secrets_in_show_and_select: 1` on ClickHouse 23.5 and later.
- An aborted reconcile is retried when a pod becomes Ready.
- A replica that is deleted or loses its volume is removed from ZooKeeper or ClickHouse Keeper.
- On data loss or a failed StatefulSet update, the operator recreates the StatefulSet.
- A new replica waits until its replication lag is 10 seconds or less.
- The operator rejects file names with the `USERS/`, `COMMON/` or `HOST/` prefix and user settings named `k8s_secret_*`, and reports `RemovedSecretRefSyntax`. The chart's templates use none of these. Remove any that your values or a hand-edited ClickHouseInstallation add.
- The operator Deployment's strategy is `Recreate`: whenever it changes, the old operator pod stops before the new one starts.
- The operator keeps a ConfigMap `chi-storage-<clickhouse.fullname>` beside the ClickHouseInstallation.
