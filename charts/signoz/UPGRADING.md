# Upgrading the SigNoz chart

This file lists what changed in each version of the `signoz` chart, for looking things up.
The step-by-step upgrade guides are on signoz.io, linked from each version's section.

- [1.0.0](#100): [find what applies to you](#100-router)

<a id="100"></a>
## 1.0.0

<a id="100-before"></a>
### Before you upgrade

1. The chart refuses every moved or removed values key before anything changes, all in one error ([Values](#100-values)).
2. ClickHouse Keeper replaces the bundled ZooKeeper as the default coordination store ([Keeper and ZooKeeper](#100-keeper)).
3. Pre-upgrade hooks replace the ClickHouse operator Deployment and apply four CRDs ([Hooks](#100-hooks)).
4. Every pod is recreated once, and ClickHouse keeps its data ([What the upgrade does](#100-what-happens)).
5. `helm rollback` to chart 0.151.0 fails partway ([Limits](#100-limits)).

> [!IMPORTANT]
> On every existing install, set `zookeeper.enabled: true` and `keeper.enabled: false` for the first upgrade and keep them until you migrate to Keeper. Without them the upgrade is refused ([details](#100-keeper-crd)), or ClickHouse moves to an empty Keeper ([details](#100-keeper-switch-detail)).

The step-by-step guide: [the upgrade guide][guide].

<a id="100-router"></a>
### Find what applies to you

| Your setup | Start here |
|---|---|
| Any existing release, whatever its setup (read these first) | [What to know first](#100-before), [what the upgrade does](#100-what-happens), [keys that moved or changed](#100-values), [Keeper replacing ZooKeeper](#100-keeper) |
| Argo CD or rendered manifests (`helm template --is-upgrade`, `kubectl apply`) | [Keeper switch on the first sync](#100-keeper-switch-detail), [operator Deployment](#100-operator-replaced-detail), [the Postgres backup step](#100-pg-backup-hook-detail), [hooks in order](#100-hooks) |
| Bundled Postgres (`postgresql.enabled: true`) | [the backup step](#100-pg-backup-hook-detail), [hook stopping the upgrade](#100-pg-hook-stops-detail), [Postgres not Ready](#100-pg-loader-detail), [all Postgres changes](#100-postgres) |
| External ClickHouse (`clickhouse.enabled: false`) | [TLS and `secure: true`](#100-external-ch-tls-detail), [the password's new Secret](#100-external-ch-secret), [all ClickHouse changes](#100-clickhouse), [keys that now do nothing](#100-ignored-keys) |
| Private registry, pull secrets or pinned image tags | [Registry and pull secrets](#100-registry), [images to mirror](#100-versions), [registry keys that moved](#100-values), [tags with a digest](#100-digest-tag) |
| ZooKeeper settings or an external ZooKeeper | [switch to an empty Keeper](#100-keeper-switch-detail), [moving `clickhouse.zookeeper`](#100-zk-literal), [Keeper and ZooKeeper](#100-keeper), [moved ZooKeeper keys](#100-values) |
| ClickHouse operator settings | [operator keys that moved or do nothing](#100-values), [operator pull secrets](#100-operator-pull-secrets), [all operator changes](#100-operator), [renamed operator objects](#100-objects-renamed) |
| A custom ClickHouse name or namespace | [renaming a long ClickHouse name](#100-ch-name-length-detail), [`clickhouse.namespace` and name keys](#100-values), [kept claims](#100-clickhouse), [the Namespace after uninstall](#100-uninstall) |
| Non-root or restricted pod security | [cases not tested](#100-not-tested), [security context keys](#100-values), [histogramQuantile init container](#100-udf-init), [migrator security contexts](#100-migrator-new-keys) |
| You patch, monitor or write network policies against chart objects | [labels and selectors](#100-objects-labels), [ports, containers and env](#100-objects-names), [all object changes](#100-objects), [hooks](#100-hooks) |
| You rotate a password or keep it in your own Secret | [restarts after a password change](#100-password-restart), [passwords that stop SigNoz](#100-signoz-dsn-detail), [ClickHouse password Secrets](#100-clickhouse) |
| Rollback or uninstall | [what a rollback does](#100-rollback), [what an uninstall leaves](#100-uninstall) |

For any other values key, search this page for the key, and for an error or log line, see [Messages](#100-messages). Every change is also listed [by component](#100-components).

<a id="100-what-happens"></a>
### What the upgrade does

1. Helm renders the chart. A moved key, or a ClickHouseKeeperInstallation without its CRD, stops the upgrade here and nothing changes.
2. With bundled Postgres, the backup hook dumps a database that lives only in the container to the Postgres claim.
3. The operator-upgrade hook deletes the operator Deployment that chart 0.151.0 created, then the CRD hook applies the four CRDs.
4. Helm applies the release: the new operator Deployment, the ClickHouse credentials Secret and Job `signoz-telemetrystore-migrator-<revision>` are created, and objects chart 1.0.0 no longer renders are removed.
5. The operator, SigNoz, collector, ZooKeeper (when kept) and Postgres (when enabled) pods are recreated once, and the operator recreates the ClickHouse pod. ClickHouse data stays.
6. The migrator Job runs beside the new pods, can fail and restart while ClickHouse is recreated, then completes. Postgres loads the dump on its first start.

| Object | During the upgrade |
|---|---|
| Deployment `<release>-clickhouse-operator` | Deleted by the operator-upgrade hook, then created with its new selector ([operator](#100-operator)). |
| CustomResourceDefinitions | The CRD hook moves the three ClickHouse CRDs to 0.27.4 and adds the Keeper CRD. |
| ClickHouseInstallation `<release>-clickhouse` | Keeps its name, cluster name and claims. The operator recreates its pod once. |
| ConfigMap `<release>-clickhouse-scripts` | Removed. The old ClickHouse pod can log `FailedMount` for it until it is recreated. |
| PodDisruptionBudget of the ClickHouse cluster | `chi-<release>-clickhouse-cluster` appears beside `<release>-clickhouse-cluster`, and the ClickHouse pod logs `MultiplePodDisruptionBudgets` while both exist. |
| ZooKeeper StatefulSet, Services and ConfigMaps | Kept with `zookeeper.enabled: true`, and the pod restarts once ([defaults](#100-changed-defaults)). Removed otherwise ([caution](#100-keeper-switch-detail)). |
| ClickHouseKeeperInstallation `<release>-keeper` | Created while `keeper.enabled` is true. |
| Secret `<release>-clickhouse-credentials` | Created. ClickHouse, SigNoz, the collector and the migrator read the password from it ([ClickHouse](#100-clickhouse)). |
| StatefulSet `<release>-signoz`, Deployment `<release>-signoz-otel-collector` | Pods recreated once. |
| Job `signoz-telemetrystore-migrator-<revision>`, and Job and ServiceAccount `signoz-telemetrystore-migrator` | The new Job is created and runs beside the new pods. The old objects are removed by Helm or left behind ([migrator](#100-migrator)). |
| StatefulSet `<release>-postgresql` | The pod comes back with the claim's `data/` folder at the data directory, loads the dump, then becomes Ready. |
| Operator ConfigMaps | Replaced by [renamed](#100-objects-renamed) ones. |

<a id="100-values"></a>
### Values

Before anything changes, the chart refuses a values file that sets a moved or removed key, and lists every such key in one error under a count:

```text
Error: execution error at (signoz/templates/validate.yaml:22:4): 2 values must change before the chart can be installed:
- `signoz.additionalArgs` has moved to `signoz.extraArgs`: the same list of arguments.
- `signoz.podAnnotations` has moved to `signoz.pod.annotations`: the same map of annotations.
```

<a id="100-moved-keys"></a>**Table 1. Moved or removed keys.** Each key is refused only in the case its note names. "0.151.0 default" marks a key refused even at the value chart 0.151.0's `values.yaml` gave it, so a copy of that file is refused with 14 lines.

| Old key | Now | Note |
|---|---|---|
| `clickhouse.additionalVolumeMounts` | `clickhouse.extraVolumeMounts` | Same list. Refused when non-empty. |
| `clickhouse.additionalVolumes` | `clickhouse.extraVolumes` | Same list. Refused when non-empty. |
| `clickhouse.clickhouseOperator` | `altinity-clickhouse-operator`, in Altinity's key names | Refused with any non-null value, an empty map and the 0.151.0 default included. Old key names moved as they are do nothing ([Table 3](#100-ignored-keys)). System log keys: [entry](#100-operator-system-logs-detail). |
| `clickhouse.customLivenessProbe` | `clickhouse.livenessProbe` | The probe object itself. Refused when non-empty. |
| `clickhouse.customReadinessProbe` | `clickhouse.readinessProbe` | The probe object itself. Refused when non-empty. |
| `clickhouse.customStartupProbe` | `clickhouse.startupProbe` | The probe object itself. Refused when non-empty. |
| `clickhouse.image.registry` | The front of `clickhouse.image.repository` | Refused while non-empty, the 0.151.0 default included. `global.imageRegistry` still replaces it. |
| `clickhouse.initContainers` | `clickhouse.udf` and `clickhouse.extraInitContainers` | Refused with any non-null value, an empty map and the 0.151.0 default included ([row](#100-udf-init)). |
| `clickhouse.livenessProbe` with `enabled`, `port` or `path` | A probe object (`httpGet.path: /ping`, `httpGet.port: http`) merged with the chart's timings, or `null` for none | Refused while one of those holds a value. Use `httpGet: null` for another handler. |
| `clickhouse.logs.system.image.registry` | The front of `clickhouse.logs.system.image.repository` | Refused while non-empty. |
| `clickhouse.namespace` (another namespace) | Same key, but the operator stays in the release namespace | Refused until `altinity-clickhouse-operator.namespaceOverride`, `watchNamespaces` or the operator's watch list is set. Use `namespaceOverride` for the old layout, or `watchNamespaces` with `rbac.namespaceScoped: false`. |
| `clickhouse.podAnnotations` | `clickhouse.pod.annotations` | Same map and default. Refused when it holds an entry, the 0.151.0 default included. |
| `clickhouse.podLabels` | `clickhouse.pod.labels` | Same map. Refused when it holds an entry. |
| `clickhouse.readinessProbe` with `enabled`, `port` or `path` | A probe object, as for `clickhouse.livenessProbe` | Refused while one of those holds a value. |
| `clickhouse.securityContext` | `clickhouse.podSecurityContext`, without `enabled` | Refused when non-empty, the 0.151.0 default included. New `clickhouse.containerSecurityContext` covers the `clickhouse` container, the histogramQuantile init container and the `logs-system-exporter` sidecar. |
| `clickhouse.startupProbe` with `enabled`, `port` or `path` | A probe object, as for `clickhouse.livenessProbe` | Refused while one of those holds a value. |
| `clickhouse.zookeeper` | `zookeeper`, the same keys at the top level | Refused with any non-null value, an empty map and the 0.151.0 default included. Add `zookeeper.enabled: true` and `keeper.enabled: false` when you move it ([row](#100-zk-literal)), and drop `enabled: false`. |
| `otelCollector.additionalEnvs` | `otelCollector.env`, a list of EnvVar objects after the chart's variables | Refused when non-empty. Rewrite each entry as `name` and `value`. |
| `otelCollector.command.extraArgs` | `otelCollector.extraArgs` | Same list. Refused when non-empty. |
| `otelCollector.command.name` | Removed: the collector always runs `/signoz-otel-collector` | Refused when it names another binary. |
| `otelCollector.customLivenessProbe` | `otelCollector.livenessProbe` | The probe object itself. Refused when non-empty. |
| `otelCollector.customReadinessProbe` | `otelCollector.readinessProbe` | The probe object itself. Refused when non-empty. |
| `otelCollector.image.registry` | The front of `otelCollector.image.repository` | Refused while non-empty, the 0.151.0 default included. The collector, `check` and the migrator share this image. |
| `otelCollector.livenessProbe` with `enabled`, `port` or `path` | A probe object (`httpGet.path: /`, `httpGet.port: 13133`) merged with the chart's timings | Refused while one of those holds a value, the 0.151.0 default included. |
| `otelCollector.lowCardinalityExceptionGrouping` | `LOW_CARDINAL_EXCEPTION_GROUPING` in `otelCollector.env` | Refused when `true`. `false` passes and does nothing. |
| `otelCollector.podAnnotations` | `otelCollector.pod.annotations` | Same map. Refused when it holds an entry, the 0.151.0 default included. |
| `otelCollector.podLabels` | `otelCollector.pod.labels` | Same map. Refused when it holds an entry. |
| `otelCollector.readinessProbe` with `enabled`, `port` or `path` | A probe object, as for `otelCollector.livenessProbe` | Refused while one of those holds a value, the 0.151.0 default included. |
| `otelCollector.securityContext` | `otelCollector.containerSecurityContext`, now also on `check` | Refused when non-empty. |
| `signoz.additionalArgs` | `signoz.extraArgs` | Same list. Refused when non-empty. |
| `signoz.additionalVolumeMounts` | `signoz.extraVolumeMounts` | Same list. Refused when non-empty. |
| `signoz.additionalVolumes` | `signoz.extraVolumes` | Same list. Refused when non-empty. |
| `signoz.customLivenessProbe` | `signoz.livenessProbe` | The probe object itself. Refused when non-empty. |
| `signoz.customReadinessProbe` | `signoz.readinessProbe` | The probe object itself. Refused when non-empty. |
| `signoz.image.registry` | The front of `signoz.image.repository` | Refused while non-empty, the 0.151.0 default included. |
| `signoz.livenessProbe` with `enabled`, `port` or `path` | A probe object merged with the chart's timings | Refused while one of those holds a value, the 0.151.0 default included. |
| `signoz.podAnnotations` | `signoz.pod.annotations` | Same map. Refused when non-empty. |
| `signoz.readinessProbe` with `enabled`, `port` or `path` | A probe object merged with the chart's timings | Refused while one of those holds a value, the 0.151.0 default included. |
| `signoz.securityContext` | `signoz.containerSecurityContext` | Same SecurityContext. Refused when non-empty. |
| `telemetryStoreMigrator.name` longer than 57 characters | Same key, at most 57 characters | Refused while the migrator is enabled. |
| `telemetryStoreMigrator.upgradeHelmHooks` | Removed | Refused when `true`, the 0.151.0 default included. `false` does nothing. |

<a id="100-changed-defaults"></a>**Table 2. Defaults that changed.**

| Key | Before | Now |
|---|---|---|
| `clickhouse.logs.system.config.service.telemetry.metrics.address` | `0.0.0.0:8888` | Not set |
| `clickhouse.logs.system.image.tag` | `0.111.16` | `v0.144.15` |
| `externalClickhouse.existingSecretPasswordKey` | `null`, and `externalClickhouse.existingSecret` was refused without it | `password` |
| `keeper.enabled` | No such key: ClickHouse used the bundled ZooKeeper | `true` ([row](#100-keeper-default)) |
| `otelCollector.env` | `{}`, as `otelCollector.additionalEnvs` | `[]` |
| `otelCollector.extraArgs` | `null`, as `otelCollector.command.extraArgs` | `[]` |
| `otelCollector.image.repository` | `signoz/signoz-otel-collector` | `docker.io/signoz/signoz-otel-collector`, the same image |
| `otelCollector.ports.jaeger-compact`, `otelCollector.ports.zipkin` | Disabled entries, `6831` over `UDP` and `9411` over `TCP` | No entries ([row](#100-collector-ports)) |
| `signoz.image.repository` | `signoz/signoz` | `docker.io/signoz/signoz`, the same image |
| `telemetryStoreMigrator.serviceAccount.create` | `true` | `false` ([row](#100-migrator-sa)) |
| `zookeeper.clusterDomain` | `cluster.local`, as `clickhouse.zookeeper.clusterDomain` | `""`, which follows `global.clusterDomain`, then `cluster.local`, so defaults render the same |
| `zookeeper.commonAnnotations` | `{}` | `signoz.io/deprecated: "true"` |
| `zookeeper.enabled` | `true`, as `clickhouse.zookeeper.enabled` | `false`, and ZooKeeper also needs `clickhouse.enabled` |
| `zookeeper.preAllocSize` | `65536` | `0`. Set `65536` to keep the old value. |

<a id="100-ignored-keys"></a>**Table 3. Keys accepted but ignored, in whole or in part.**

| Key | What it used to do |
|---|---|
| `altinity-clickhouse-operator.image.*` | As `clickhouse.clickhouseOperator.image.*`, set the operator image. Use `altinity-clickhouse-operator.operator.image.*`. |
| `altinity-clickhouse-operator.metricsExporter.*` | Set the metrics-exporter image, resources and Service. Use `altinity-clickhouse-operator.metrics.image.*`, `metrics.resources` and `metrics.env`. The Service port, type and annotations have no counterpart. |
| `altinity-clickhouse-operator.name`, `altinity-clickhouse-operator.version`, `altinity-clickhouse-operator.service.enabled` | Were operator settings under `clickhouse.clickhouseOperator`. |
| `altinity-clickhouse-operator.logger.*`, `altinity-clickhouse-operator.queryLog.ttl` and the other system log `ttl` and `flushInterval` keys | Set the logger and the system log tables' TTL and flush interval. Use files in `altinity-clickhouse-operator.configs.configdFiles` ([entry](#100-operator-system-logs-detail)). |
| `altinity-clickhouse-operator.resources` | Set the operator container's resources. Use `altinity-clickhouse-operator.operator.resources`. |
| `altinity-clickhouse-operator.serviceMonitor.interval`, `scrapeTimeout`, `relabelings`, `metricRelabelings` | Shaped the operator ServiceMonitor. Use `serviceMonitor.clickhouseMetrics.*` and `serviceMonitor.operatorMetrics.*`. |
| `clickhouse.nameOverride`, `clickhouse.fullnameOverride` | Also renamed the operator objects. Now only `altinity-clickhouse-operator.fullnameOverride` does ([renamed](#100-objects-renamed)). |
| `clickhouse.imagePullSecrets` | Was also listed on the ClickHouse ServiceAccount ([details](#100-registry)). |
| `clickhouse.password`, `externalClickhouse.password`, `postgresql.auth.password` | A change restarted the pods that use the password. Now it changes only a Secret ([row](#100-password-restart)). |
| `clickhouse.replicasCount`, `clickhouse.shardsCount` | Nothing in chart 0.151.0 either. Use `clickhouse.layout.replicasCount` and `clickhouse.layout.shardsCount`. |
| `clickhouse.service.httpPort` | Also set `CLICKHOUSE_HTTP_PORT` in SigNoz, the collector, `check` and the migrator. Now it moves only the Service port. |
| `clickhouse.udf.image` | As `clickhouse.initContainers.udf.image`, set the histogramQuantile download's image ([row](#100-udf-init)). |
| `externalClickhouse.httpPort` | Set `CLICKHOUSE_HTTP_PORT` in SigNoz, the collector, `check` and the migrator. Write the port number where a config of yours read it. |
| `global.imagePullSecrets` | Also reached the operator pod and the SigNoz, collector, migrator and ClickHouse ServiceAccounts ([details](#100-registry)). |
| `global.imageRegistry` | Was prefixed to every repository, the operator images included. Now it replaces a registry written in the repository ([details](#100-registry)). |
| `imagePullSecrets` | Was listed on the SigNoz, collector and migrator ServiceAccounts. Now it is on the pods ([details](#100-registry)). |
| `signoz.additionalEnvs`, `signoz.configVars`, `signoz.smtpVars`, `schemaMigrator`, `signoz.initContainers.init`, `signoz.initContainers.migration`, `otelCollector.initContainers.init` | Nothing, with a `DEPRECATION NOTICE` in the notes. Now nothing is printed. Values go in `signoz.env`, and `schemaMigrator` overrides in `telemetryStoreMigrator`. |
| `signoz.service.port`, `signoz.service.internalPort`, `signoz.service.opampPort` | Also set the container ports. Now the container always declares 8080, 8085 and 4320, and these move only the Service ports. |
| `telemetryStoreMigrator.serviceAccount.annotations` without `create: true` | Annotated the migrator ServiceAccount, created by default ([row](#100-migrator-sa)). |
| `telemetryStoreMigrator.upgradeHelmHooks: false` | Rendered the migrator as a plain Job, which it now always is. |
| `zookeeper.*` while `zookeeper.enabled` is false | As `clickhouse.zookeeper.*`, configured the bundled ZooKeeper, which ran by default ([row](#100-zk-literal)). |
| `zookeeper.global.imageRegistry`, `zookeeper.global.storageClass` | As `clickhouse.zookeeper.global.*`, set ZooKeeper's registry and storage class. Use `zookeeper.image.registry` and `zookeeper.persistence.storageClass`, or `global.*`. |

<a id="100-components"></a>
### Changes by component

<a id="100-registry"></a>
#### Registry and pull secrets

Every pod lists its own pull secrets now, and `global.imageRegistry` reaches every image except the operator's, the CRD hook's and Postgres's.

Each pod lists these, in this order, each name once:

| Pod | Pull secrets |
|---|---|
| ClickHouse, and the operator-upgrade hook Job | `global.imagePullSecrets`, `imagePullSecrets`, `clickhouse.imagePullSecrets` |
| ClickHouse Keeper | `global.imagePullSecrets`, `imagePullSecrets`, `keeper.imagePullSecrets` |
| SigNoz | `global.imagePullSecrets`, `imagePullSecrets`, `signoz.imagePullSecrets` |
| Collector, and the schema migrator | `global.imagePullSecrets`, `imagePullSecrets`, `otelCollector.imagePullSecrets` |
| Operator | `altinity-clickhouse-operator.imagePullSecrets` only, as `name:` objects ([row](#100-operator-pull-secrets)) |
| CRD hook Job | `altinity-clickhouse-operator.crdHook.imagePullSecrets` only, as `name:` objects |
| Postgres, and its backup Job | `postgresql.imagePullSecrets`. Their ServiceAccount `<release>-postgresql` lists `global.imagePullSecrets` and `postgresql.imagePullSecrets`, as in chart 0.151.0. |
| ZooKeeper, when kept | `global.imagePullSecrets`, `zookeeper.image.pullSecrets` |
| The `helm test` pod | None |

No other chart ServiceAccount lists pull secrets. A pod of yours that runs under one of them, such as `<release>-signoz`, and pulled with its pull secrets must list them in its own spec.

Each image, and what to mirror with `global.imageRegistry: <registry>`:

| Image | Mirror as | Set by |
|---|---|---|
| `clickhouse/clickhouse-server:25.12.5`, also for the histogramQuantile download | `<registry>/clickhouse/clickhouse-server:25.12.5` | `clickhouse.image` |
| `clickhouse/clickhouse-keeper:25.12.5` | `<registry>/clickhouse/clickhouse-keeper:25.12.5` | `keeper.image` |
| `signoz/zookeeper:3.7.1`, when kept | `<registry>/signoz/zookeeper:3.7.1` | `zookeeper.image` |
| `signoz/signoz-otel-collector:v0.144.15`, the system-logs sidecar | `<registry>/signoz/signoz-otel-collector:v0.144.15` | `clickhouse.logs.system.image` |
| `docker.io/signoz/signoz:<tag>` | `<registry>/signoz/signoz:<tag>` | `signoz.image` |
| `docker.io/signoz/signoz-otel-collector:v0.144.16`, the collector, `check` and the migrator | `<registry>/signoz/signoz-otel-collector:v0.144.16` | `otelCollector.image` |
| `registry.k8s.io/kubectl:v1.36.3`, the operator-upgrade hook | `<registry>/kubectl:v1.36.3` | `clickhouse.operatorUpgradeHook.image` |
| `docker.io/busybox:1.35`, the `helm test` pod | `<registry>/busybox:1.35` | Fixed in the chart |
| `registry.k8s.io/kubectl:v1.36.3`, the CRD hook | Not applied | `altinity-clickhouse-operator.crdHook.image` |
| `altinity/clickhouse-operator:0.27.4` | Not applied | `altinity-clickhouse-operator.operator.image` |
| `altinity/metrics-exporter:0.27.4` | Not applied | `altinity-clickhouse-operator.metrics.image` |
| `postgres:15`, Postgres and its backup Job | Not applied | `postgresql.image` |

`global.imageRegistry` replaces a registry written at the front of a repository: it renders `<registry>/signoz/signoz` where chart 0.151.0 rendered `<registry>/myreg.io/signoz/signoz`. With default repositories the images are the same as before.

For the operator and its CRD hook, set Altinity's keys before you upgrade. The CRD hook runs after the old operator Deployment is deleted, so an image it cannot pull leaves no operator ([Hooks](#100-hooks)). These values render `my.registry/altinity/clickhouse-operator:0.27.4`, `my.registry/altinity/metrics-exporter:0.27.4` and `my.registry/kubectl:v1.36.3`, each pod with `my-pull-secret`:

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

The histogramQuantile init container downloads its binary from GitHub (`https://github.com/SigNoz/signoz/releases/download/histogram-quantile%2Fv0.0.1/...`). Without GitHub access, bring the binary one of two ways. Both render as shown. Not tested on a cluster.

From an image of your own, built with the binary of SigNoz's `histogram-quantile/v0.0.1` release for your nodes at `/histogramQuantile`: turn the download off and copy the binary into `shared-binary-volume`, which ClickHouse mounts at `/var/lib/clickhouse/user_scripts`.

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

From a mirror: keep the download, copy the default `clickhouse.udf.command` from the chart's `values.yaml` and change its `wget` line. `clickhouse.udf.env` and `clickhouse.udf.envFrom` reach the download container, for a proxy or a mirror credential:

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

<a id="100-clickhouse"></a>
#### ClickHouse

ClickHouse is now rendered by the SigNoz chart itself, keeps its name and data, and takes its password from a Secret.

| Change | Affects you if | Do |
|---|---|---|
| <a id="100-ch-credentials"></a>The password moves out of plain text in the ClickHouseInstallation and pod specs into Secret `<release>-clickhouse-credentials` (`password`, `password_sha256_hex`), read through `secretKeyRef`. | Something reads the password from a pod spec or the ClickHouseInstallation. | Read it from the Secret. |
| <a id="100-password-restart"></a>A change to `clickhouse.password`, `externalClickhouse.password` or `postgresql.auth.password` now changes only its Secret and restarts no pod. Whether ClickHouse takes it without a restart is not tested. | You rotate a password through values. | Restart SigNoz, the collector and ClickHouse or Postgres afterwards. |
| <a id="100-ch-existing-secret"></a>New `clickhouse.existingSecret`, with `existingSecretPasswordKey` (default `password`) and `existingSecretPasswordSha256Key`, reads the password from your Secret, the plain key when no SHA-256 key is set. | You want the password out of values. | Nothing. |
| <a id="100-udf-init"></a>The histogramQuantile download moves from `docker.io/alpine:3.18.2` under `clickhouse.initContainers.udf` to init container `<release>-clickhouse-udf-init` on the ClickHouse image under `clickhouse.udf`, which ignores `udf.image`. | You set `clickhouse.initContainers`, or mirror alpine. | Move `udf.enabled` and `udf.command` to `clickhouse.udf`, and list your own init containers under `clickhouse.extraInitContainers`, which fails with a YAML parse error on a map. |
| <a id="100-logs-sidecar"></a>The system-logs sidecar now runs `signoz/signoz-otel-collector:v0.144.15` as `/signoz-otel-collector`, where it ran `0.111.16` as `/signoz-collector`. | `clickhouse.logs.system.enabled` is true. | See [the entry](#100-logs-sidecar-detail). |
| <a id="100-events-proto"></a>The ClickHouseInstallation no longer ships `events.proto` in `spec.configuration.files`. | You use that format schema. | Add it under `clickhouse.files`. |
| <a id="100-ch-claims-retained"></a>The operator now keeps ClickHouse claims it no longer tracks (`reconciling.cleanup.unknownObjects.pvc: Retain`) instead of deleting them. | You scale ClickHouse down or rename it. | Delete such claims by hand when the data is no longer wanted. |
| <a id="100-ch-pull-secrets"></a>Pull secrets move from the ClickHouse ServiceAccount to the pod, which also lists the top-level `imagePullSecrets` ([details](#100-registry)). | You use a private registry, or your own pods rely on that ServiceAccount. | List pull secrets on your own pods. |
| <a id="100-ch-name-length"></a>A ClickHouse name over 34 characters, such as a release name of 24 characters or more with the default `-clickhouse`, is now refused. | Your release name or `clickhouse.fullnameOverride` is long. | See [the caution](#100-ch-name-length-detail). |
| <a id="100-external-ch-secret"></a>External ClickHouse's password moves from Secret `<release>-clickhouse-external` (key `clickhouse-password`) and the pod specs to Secret `<release>-clickhouse-credentials` (key `password`). | `clickhouse.enabled` is false. | Point anything that read the old Secret at the new one. |
| <a id="100-external-ch-tls"></a>With `externalClickhouse.secure: true`, SigNoz, `check` and the migrator now connect over TLS, while the collector's exporters stay on plain TCP (not tested). | Your external ClickHouse has `secure: true`. | See [the entry](#100-external-ch-tls-detail). |
| <a id="100-cluster-domain"></a>`global.clusterDomain` now reaches ClickHouse: `namespaceDomainPattern` on the ClickHouseInstallation and Keeper, the operator's `hostRegexpTemplate`, and a cross-namespace `CLICKHOUSE_HOST`. | You set it, even to a value chart 0.151.0 ignored. | Check that it is your cluster's domain. |
| <a id="100-digest-tag"></a>`clickhouse.image.tag` and `keeper.image.tag` now also fill `app.kubernetes.io/version` (cut to 63 characters), so a tag with `@sha256:` gives labels the API server rejects (not tested). | You pin the ClickHouse or Keeper image by digest in the tag. | Pin by a tag without a digest. |
| <a id="100-ch-new-keys"></a>New `clickhouse` keys or defaults: `env`, `envFrom`, `extraInitContainers`, `containerSecurityContext`, `logs.system.env`, `logs.system.envFrom`, `logs.system.extraVolumeMounts`, `logs.system.resources`, `persistence.storageClass`, `serviceAccount.name`. | You set one. | Nothing. |

<a id="100-logs-sidecar-detail"></a>
**The system-logs sidecar runs a newer collector**

- **Before:** The sidecar ran `docker.io/signoz/signoz-otel-collector:0.111.16` as `/signoz-collector`, and the `clickhouse` container waited in a `postStart` script.
- **Now:** It runs `signoz/signoz-otel-collector:v0.144.15` as `/signoz-otel-collector`, with no `postStart` wait and no `service.telemetry.metrics` block in its default config. A tag pinned to `0.111.16` gets a binary that image lacks, so the sidecar cannot start (not tested).
- **Affects you if:** `clickhouse.logs.system.enabled` is true.
- **Do:** Remove components 0.144.15 lacks from `clickhouse.logs.system.config`, and pin no tag older than the default.

<a id="100-ch-name-length-detail"></a>
**ClickHouse names longer than 34 characters**

- **Before:** Any ClickHouse name rendered.
- **Now:** A name over 34 characters is refused, and no value keeps it.
- **Affects you if:** An existing install's ClickHouse name is that long.
- **Do:** Plan a data migration before you shorten the name ([guide]).

> [!CAUTION]
> Following the message renames the ClickHouseInstallation (for example `signoz-observability-prod-clickhouse` to `signoz-obs-prod-ch`). Helm removes the old one, its claims stay, and the operator builds a new, empty ClickHouse with no warning. Move the data with the [guide] first.

<a id="100-external-ch-tls-detail"></a>
**`externalClickhouse.secure` now switches more connections to TLS**

- **Before:** `CLICKHOUSE_VERIFY` was set only on the collector container, and `externalClickhouse.secure` reached only the `CLICKHOUSE_SECURE` variable.
- **Now:** SigNoz, `check` and the migrator also get `CLICKHOUSE_VERIFY` (default `false`). With `secure: true` they connect with `?secure=true`, plus `skip_verify=true` unless verify is on, while the collector's five exporters stay on plain TCP. Not tested against a TLS ClickHouse.
- **Affects you if:** Your external ClickHouse has `externalClickhouse.secure: true`.
- **Do:** If `externalClickhouse.tcpPort` serves TLS (usually 9440), add `secure=true` to the exporter DSNs in `otelCollector.config`. Otherwise set `secure: false`.

<a id="100-keeper"></a>
#### Keeper and ZooKeeper

ClickHouse Keeper replaces the bundled ZooKeeper as the default coordination store, and an existing install keeps ZooKeeper only when its values say so.

| Change | Affects you if | Do |
|---|---|---|
| <a id="100-keeper-default"></a>The default store moves from the bundled ZooKeeper to ClickHouseKeeperInstallation `<release>-keeper`, reached at `keeper-<release>-keeper:2181`. | You install fresh or upgrade on default values. | On an existing install, keep `zookeeper.enabled: true` and `keeper.enabled: false` until you migrate ([guide]). |
| <a id="100-keeper-crd"></a>With `keeper.enabled` at its default, the first `helm upgrade` is refused before anything changes, `--no-hooks` included, because the Keeper CRD comes from a hook. Rendered manifests carry it with `--include-crds`, or in the CRD hook Job applied first. | You upgrade an existing install without `keeper.enabled: false`. | Set `zookeeper.enabled: true` and `keeper.enabled: false`. |
| <a id="100-keeper-switch"></a>Once the Keeper CRD exists, as with `helm template --include-crds` (Argo CD), an upgrade on default values removes ZooKeeper and moves ClickHouse to an empty Keeper. | You upgrade an existing install without `zookeeper.enabled: true`. | See [the caution](#100-keeper-switch-detail). |
| <a id="100-zk-literal"></a>A `clickhouse.zookeeper` block moved to `zookeeper` without `enabled: true` is ignored, and ClickHouse moves to a one-node Keeper with a 10Gi claim, printing nothing. | You follow the `clickhouse.zookeeper` refusal literally. | Add `zookeeper.enabled: true` and `keeper.enabled: false` to the moved block. |
| <a id="100-keeper-idle"></a>With `clickhouse.externalZookeeper.servers`, or `zookeeper.enabled: true` alone, an idle Keeper (one node, 10Gi claim) is installed beside the store ClickHouse uses. | You use an external ZooKeeper, or keep ZooKeeper that way. | Set `keeper.enabled: false`, and with an external ZooKeeper leave `zookeeper.enabled` unset. |
| <a id="100-keeper-keys"></a>New `keeper.*` keys: image `clickhouse/clickhouse-keeper:25.12.5`, 1 replica, 10Gi `ReadWriteOnce`, 100m CPU, 256Mi, metrics on 9141 with `signoz.io` annotations, logger, coordination, scheduling, security, env and volumes. | You install fresh or turn Keeper on. | Nothing. |

<a id="100-keeper-switch-detail"></a>
**Default values move ClickHouse to an empty Keeper**

- **Before:** ZooKeeper's StatefulSet, Services and ConfigMaps were release objects by default.
- **Now:** Once the Keeper CRD exists, an upgrade on default values removes them, points ClickHouse at a new, empty Keeper, and replicated tables lose their coordination state. The ZooKeeper claims stay.
- **Affects you if:** An existing install upgrades or syncs without `zookeeper.enabled: true`, GitOps on default values included.
- **Do:** Keep ZooKeeper as below, and to recover from the switch follow the [guide].

> [!CAUTION]
> Nothing warns about this switch: the notes print only `ClickHouse coordinates through ClickHouse Keeper at keeper-<release>-keeper:2181.` Set `zookeeper.enabled: true` and `keeper.enabled: false` before the first upgrade or sync.

<a id="100-operator"></a>
#### ClickHouse operator

The operator now comes from Altinity's own chart at 0.27.4, with new object names, labels and settings keys.

| Change | Affects you if | Do |
|---|---|---|
| <a id="100-operator-replaced"></a>The operator Deployment's selector becomes `app.kubernetes.io/name: clickhouse-operator` and `instance`, so pre-upgrade hook Job `<release>-clickhouse-operator-upgrade` deletes the old Deployment on every upgrade. | Every existing install, and upgrades with that hook off. | See [the warning](#100-operator-replaced-detail). |
| <a id="100-operator-images"></a>Operator, metrics-exporter and CRD-hook images and pull secrets come only from `altinity-clickhouse-operator.*` ([details](#100-registry)). | You use a private registry. | Set them before you upgrade, as [shown](#100-registry). |
| <a id="100-operator-pull-secrets"></a>Operator pull secrets moved as names (`[ch-pull]`) to `altinity-clickhouse-operator.imagePullSecrets` render strings where Kubernetes needs objects (rejection not tested). | You set operator pull secrets. | Write `[{name: ch-pull}]`. |
| <a id="100-operator-system-logs"></a>System log TTLs, flush intervals and the logger move from `clickhouse.clickhouseOperator` keys to whole XML files in `altinity-clickhouse-operator.configs.configdFiles`, with the same defaults. | You tuned a system log table or the logger. | See [the entry](#100-operator-system-logs-detail). |
| <a id="100-operator-config"></a>0.27.4's operator config: 5 s connect and 4 s query timeouts (were 2 s and 5 s), 5 shard threads, restarts on `files/*.xml` but not on coordination-node changes, and drops a deleted host's replica metadata. | Every install. | Nothing. |
| <a id="100-operator-rbac"></a>The operator's Role adds `delete` on pods, `get`, `list` and `watch` on `endpointslices`, and ClickHouseKeeperInstallations with their finalizers and status, removing nothing. | You audit RBAC rules. | Nothing. |
| <a id="100-operator-off"></a>New `altinity-clickhouse-operator.enabled: false` renders no operator and neither operator hook, and an upgrade then removes the chart's operator objects. | You run your own operator. | Nothing. |
| <a id="100-hook-jobs-kubectl"></a>`helm template` renders the 12 operator hook objects, with or without `--is-upgrade`, and `kubectl apply` treats them as ordinary objects: each hook Job runs once and stays. | You apply rendered manifests, or your GitOps tool does not run Helm hooks. | Apply the hook Jobs in [weight order](#100-hooks) before the rest, and delete them before a chart version that changes them. |

<a id="100-operator-replaced-detail"></a>
**A hook replaces the operator Deployment**

- **Before:** The selector was `app.kubernetes.io/name: clickhouse`, `app.kubernetes.io/instance` and `app.kubernetes.io/component: operator`.
- **Now:** The hook deletes the old Deployment and finds nothing after the first upgrade. With rendered manifests, its Job has to finish before the new Deployment is applied, or that apply is rejected and has to be repeated.
- **Affects you if:** You upgrade with `--no-hooks`, Argo CD without hooks, or `clickhouse.operatorUpgradeHook.enabled: false`.
- **Do:** Delete the old Deployment by hand right before the upgrade ([guide]).

> [!WARNING]
> With the hook off and the old operator Deployment in place, the upgrade fails on the Deployment's immutable selector. Delete Deployment `<release>-clickhouse-operator` right before the upgrade, or let the hook run.

<a id="100-operator-system-logs-detail"></a>
**System log tables are configured as whole files**

- **Before:** The TTL and flush interval of each system log table, and the logger, were keys under `clickhouse.clickhouseOperator`, such as `queryLog.ttl` and `queryLog.flushInterval`.
- **Now:** Each is one XML file under `altinity-clickhouse-operator.configs.configdFiles`, which the operator receives in ConfigMap `<release>-clickhouse-operator-configd-files`. The TTL, in days, sits in the file's `engine` line, and the flush interval, in milliseconds, in `flush_interval_milliseconds`. A file set to `null` is left out, so its table is not configured.
- **Affects you if:** You set a `ttl`, `flushInterval` or `logger` key under `clickhouse.clickhouseOperator`.
- **Do:** Copy the default file of each table you tuned into your values, edit it, and delete the old keys. Not tested on a cluster: the operator applying an edited file.

| Old key under `clickhouse.clickhouseOperator` | File under `altinity-clickhouse-operator.configs.configdFiles` | Default TTL and flush interval | Default file in |
|---|---|---|---|
| `logger` | `01-clickhouse-02-logger.xml` | Not a table | This chart's `values.yaml` |
| `queryLog` | `01-clickhouse-03-query_log.xml` | 30 days, 7500 ms | This chart's `values.yaml` |
| `partLog` | `01-clickhouse-04-part_log.xml` | 30 days, 7500 ms | Altinity's chart |
| `traceLog` | `01-clickhouse-05-trace_log.xml` | 7 days, 7500 ms | This chart's `values.yaml` |
| `asynchronousInsertLog` | `01-clickhouse-06-asynchronous_insert_log.xml` | 7 days, 7500 ms | This chart's `values.yaml` |
| `asynchronousMetricLog` | `01-clickhouse-07-asynchronous_metric_log.xml` | 30 days, 7500 ms | This chart's `values.yaml` |
| `backupLog` | `01-clickhouse-08-backup_log.xml` | 7 days, 7500 ms | This chart's `values.yaml` |
| `blobStorageLog` | `01-clickhouse-09-blob_storage_log.xml` | 30 days, 7500 ms | This chart's `values.yaml` |
| `crashLog` | `01-clickhouse-10-crash_log.xml` | 30 days, 7500 ms | This chart's `values.yaml` |
| `metricLog` | `01-clickhouse-11-metric_log.xml` | 30 days, 7500 ms | This chart's `values.yaml` |
| `queryThreadLog` | `01-clickhouse-12-query_thread_log.xml` | 7 days, 7500 ms | This chart's `values.yaml` |
| `queryViewsLog` | `01-clickhouse-13-query_views_log.xml` | 15 days, 7500 ms | This chart's `values.yaml` |
| `sessionLog` | `01-clickhouse-14-session_log.xml` | 30 days, 7500 ms | This chart's `values.yaml` |
| `zookeeperLog` | `01-clickhouse-15-zookeeper_log.xml` | 30 days, 7500 ms | This chart's `values.yaml` |
| `processorsProfileLog` | `01-clickhouse-16-processors_profile_log.xml` | 7 days, 7500 ms | This chart's `values.yaml` |

Altinity's chart also holds `01-clickhouse-01-listen.xml`. To read its defaults:

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

To leave a table unconfigured:

```yaml
altinity-clickhouse-operator:
  configs:
    configdFiles:
      01-clickhouse-15-zookeeper_log.xml: null
```

<a id="100-signoz"></a>
#### SigNoz

The SigNoz server keeps its image, while its values keys, probes and ClickHouse connection string change.

| Change | Affects you if | Do |
|---|---|---|
| <a id="100-signoz-dsn"></a>SigNoz's connection string now carries the ClickHouse password, unencoded, in its user part, so some characters stop SigNoz (not tested in a pod). | Your ClickHouse password holds `/`, `?`, `#` or `%`. | See [the entry](#100-signoz-dsn-detail). |
| <a id="100-signoz-env-override"></a>A `signoz.env` key named like a chart variable, such as `SIGNOZ_SQLSTORE_*` or `POSTGRES_*` with bundled Postgres, now replaces that variable instead of losing to it, and entries referencing each other in a circle are refused. | You set such keys. | Delete the key unless its value should apply. |
| <a id="100-signoz-env-numbers"></a>A large number in `signoz.env` renders in full (`"1000000"`, was `"1e+06"`). | You set one. | Nothing. |
| <a id="100-signoz-ingress"></a>An Ingress path without `port` or `pathType` now routes to `signoz.service.port` with `ImplementationSpecific` instead of rendering empty fields. | Your Ingress hosts leave them out. | Nothing. |
| <a id="100-signoz-pull-secrets"></a>Pull secrets move from the SigNoz ServiceAccount to the pod ([details](#100-registry)). | You use a private registry, or your own pods rely on that ServiceAccount. | List pull secrets on your own pods. |
| <a id="100-signoz-new-keys"></a>New `signoz` keys: `envFrom`, `labels`, `pod.labels`, `extraInitContainers`, `extraContainers`, `startupProbe`. | You set one. | Nothing. |

<a id="100-signoz-dsn-detail"></a>
**SigNoz puts the ClickHouse password in its connection string's user part**

- **Before:** The credentials sat in the connection string's query (`?username=...&password=...`).
- **Now:** They sit in its user part, unencoded. A password with `/`, `?`, `#`, or a `%` not followed by two hex digits fails to parse, and SigNoz cannot open its telemetry store. `+` and `&` now pass. Checked with SigNoz's parser, not tested in a running pod.
- **Affects you if:** Your ClickHouse password holds one of those characters.
- **Do:** Keep those characters out of the password.

<a id="100-collector"></a>
#### Collector

The collector keeps its image, while its values keys, probes, ports and pull secrets change.

| Change | Affects you if | Do |
|---|---|---|
| <a id="100-collector-ports"></a>The disabled `zipkin` (9411, TCP) and `jaeger-compact` (6831, UDP) port entries are gone, so `enabled: true` alone renders a port with no number, which Kubernetes rejects (not tested). | You turned either on with `enabled: true` alone. | Also write `containerPort`, `servicePort` and `protocol`. |
| <a id="100-collector-pull-secrets"></a>Pull secrets move from the collector's ServiceAccount to the pod ([details](#100-registry)). | You use a private registry. | Nothing. |
| <a id="100-collector-opamp"></a>The collector dials SigNoz's OpAMP on `signoz.service.opampPort` instead of always 4320. | You changed that port. | Nothing. |
| <a id="100-collector-crb-annotations"></a>`otelCollector.clusterRole.clusterRoleBinding.annotations`, ignored before, now reach the ClusterRoleBinding. | You set them. | Nothing. |
| <a id="100-collector-check"></a>The `check` init container now also takes `telemetryStoreMigrator.env`, `telemetryStoreMigrator.envFrom`, `telemetryStoreMigrator.resources` and `otelCollector.extraVolumeMounts`. | You reach ClickHouse through a proxy or with a CA file. | Set them there, with the volumes in `otelCollector.extraVolumes`. |
| <a id="100-collector-new-keys"></a>New `otelCollector` keys: `envFrom`, `extraArgs`, `labels`, `pod.labels`, `startupProbe`. | You set one. | Nothing. |

<a id="100-migrator"></a>
#### Schema migrator

The migrator is a plain Job with the revision in its name, and it no longer runs as a hook or holds up the upgrade.

| Change | Affects you if | Do |
|---|---|---|
| <a id="100-migrator-job"></a>The migrator moves from `signoz-telemetrystore-migrator`, a pre-upgrade hook on upgrade, to plain Job `signoz-telemetrystore-migrator-<revision>`, new on every install and upgrade, `--no-hooks` included. | Something names or waits for the Job, or you upgrade with `--no-hooks` or Argo CD. | Wait on the new name. Set `telemetryStoreMigrator.enabled: false` to skip one revision. |
| <a id="100-migrations-no-gate"></a>Migrations now run beside the upgraded workloads, may fail and restart while ClickHouse is recreated, and no longer fail `helm upgrade`, which waits for Jobs only with `--wait-for-jobs`. Only `check` waits for them. | Every install. | Nothing. |
| <a id="100-migrator-sa"></a>`telemetryStoreMigrator.serviceAccount.create` now defaults to `false`, so the Job runs as `default` and `serviceAccount.annotations` such as `eks.amazonaws.com/role-arn` are ignored. | Something is bound to ServiceAccount `signoz-telemetrystore-migrator`, such as a cloud identity. | Set `create: true` with the annotations, after deleting a [left-over](#100-migrator-leftovers) ServiceAccount or with `--take-ownership` (not tested). |
| <a id="100-migrator-leftovers"></a>Job and ServiceAccount `signoz-telemetrystore-migrator`, made as hooks by chart 0.151.0 upgrades, are removed by Helm only at a release's install revision, and otherwise can stay (not tested). | Your release was upgraded on chart 0.151.0 or an earlier hook-based version. | Afterwards delete that Job, and the ServiceAccount unless `create` is true or `serviceAccount.name` names it, since the Job then runs as it. |
| <a id="100-migrator-sa-name"></a>`telemetryStoreMigrator.serviceAccount.name` without `create: true` names an account nobody creates, so the Job's pods never start and on a fresh install `check` cannot pass (not tested). | You set it without `create: true`. | Add `create: true`, or create the account. |
| <a id="100-migrator-pull-secrets"></a>The migrator pod lists its own pull secrets, `otelCollector.imagePullSecrets` included ([details](#100-registry)). | You use a private registry. | Nothing. |
| <a id="100-migrator-new-keys"></a>New `telemetryStoreMigrator` keys: `env`, `envFrom`, `podSecurityContext`, `containerSecurityContext`, `extraVolumes`, `extraVolumeMounts`, `labels`, `pod.labels`, `pod.annotations`, `priorityClassName`, `ttlSecondsAfterFinished`. | You set one. | Nothing. |

<a id="100-postgres"></a>
#### Postgres

The bundled Postgres is now part of the SigNoz chart and keeps its database on its claim, and a pre-upgrade hook carries over a database that lived only in the container.

| Change | Affects you if | Do |
|---|---|---|
| <a id="100-pg-data-on-claim"></a>The database moves from the image's own volume, lost on container restarts, to the claim's `data/` folder at `/var/lib/postgresql/data`. | `postgresql.enabled` is true. | Nothing ([conditions](#100-pg-data-on-claim-detail)). |
| <a id="100-pg-backup-hook"></a>A pre-upgrade step, Job `<release>-postgresql-upgrade-backup`, carries over a database held in the container by dumping it to `backups/pre-upgrade.sql` on the claim. | `postgresql.enabled` is true. | See [how each upgrade runs it](#100-pg-backup-hook-detail). |
| <a id="100-pg-hook-stops"></a>When the hook cannot dump (wrong password, Postgres unreachable, your own `/docker-entrypoint-initdb.d`, or its 240 s deadline), the upgrade stops before anything changes. | The hook fails. | See [the warning](#100-pg-hook-stops-detail). |
| <a id="100-pg-hook-node"></a>The hook Job must run on the Postgres pod's node, so with Postgres scaled to 0 it stays Pending and fails with `DeadlineExceeded` after about 240 s. | Postgres is not running on a multi-node cluster. | Start Postgres, or dump by hand and turn the hook off ([guide]). |
| <a id="100-pg-own-volumes"></a>With a volume of yours at the data directory the database already lives there, so no backup step is rendered. With your own `/docker-entrypoint-initdb.d` the step refuses the upgrade. | You mount extra volumes into Postgres. | For `/docker-entrypoint-initdb.d`, dump by hand and turn the step off ([guide]). |
| <a id="100-pg-loader"></a>Postgres' first start on the claim loads `backups/pre-upgrade.sql` in one transaction (from ConfigMap `<release>-postgresql-restore`) and renames it `pre-upgrade.sql.loaded`, while a truncated or failing dump leaves the database empty. | `postgresql.enabled` is true. | See [the warning](#100-pg-loader-detail). |
| <a id="100-pg-interrupted-load"></a>A load interrupted by a container stop leaves orphaned files on the claim, and the next start skips initialisation and stays not Ready. | The first start after the upgrade is interrupted. | Load the dump by hand and rename it ([guide]). |
| <a id="100-pg-startup-probe"></a>A new startup probe (180 tries, 10 s apart) holds Postgres not Ready while `backups/pre-upgrade.sql` exists, naming the file and the guide in its event. | `postgresql.enabled` is true. | Nothing. |
| <a id="100-pg-new-keys"></a>New `postgresql` keys: `upgradeBackupHook.*`, `startupProbe.*`. | You set one. | Nothing. |
| <a id="100-pg-existing-claim"></a>A templated `postgresql.persistence.existingClaim` still names the same claim, now rendered by the SigNoz chart. | You template it. | Nothing. |

<a id="100-pg-data-on-claim-detail"></a>
**The Postgres database lives on its claim**

- **Before:** The claim was mounted at `/var/lib/postgresql` while `PGDATA` was `/var/lib/postgresql/data`, so the database lived in the image's own volume and was lost on every container restart, on runtimes that honour image volumes.
- **Now:** The claim's `data/` folder is also mounted at `/var/lib/postgresql/data`, so the database survives restarts. That needs persistence on at the default `postgresql.persistence.mountPath`, no volume of yours there, and a `postgres` tag from 15 to 17. Another mount path keeps the old layout, so the upgrade does not move the data and renders no backup step.
- **Affects you if:** `postgresql.enabled` is true.
- **Do:** Nothing. The backup step below carries the database over.

<a id="100-pg-backup-hook-detail"></a>
**The backup step carries over a database held in the container**

- **Before:** An upgrade restarted Postgres and lost the database held in the container.
- **Now:** Before anything changes, the step dumps that database to `backups/pre-upgrade.sql` on the claim, or does nothing when the claim already holds it, running on the Postgres pod's node with `backoffLimit: 0` and a 240 s deadline. `helm upgrade` runs it as a pre-upgrade hook. Manifests rendered with `helm template --is-upgrade` include its Job, which has to be applied and finish before the rest, since `kubectl` does not order hooks ([guide]). A GitOps tool runs it when it renders the chart as an upgrade and runs Helm hooks. For Argo CD that is [not tested](#100-not-tested).
- **Affects you if:** Your install's database lives only in the container.
- **Do:** Make no changes in SigNoz while the upgrade runs: changes written after the dump are not in it, and in full-chart upgrades Postgres stopped 7 to 16 seconds after the backup Job finished.

> [!CAUTION]
> When the step is switched off or cannot run on such an install, Postgres starts on an empty data folder with no message. That happens with `--no-hooks`, `postgresql.upgradeBackupHook.enabled: false`, a `ReadWriteOncePod` claim or `postgresql.replicaCount: 0`. Take the dump by hand first, as the [guide] describes.

<a id="100-pg-hook-stops-detail"></a>
**The backup hook stops the upgrade when it cannot dump**

- **Before:** Nothing could stop an upgrade over Postgres.
- **Now:** The release is marked failed, and the failed Job and its pod stay until the next upgrade with the hook on.
- **Affects you if:** The hook fails.
- **Do:** Fix the cause, or dump by hand and turn the hook off ([guide]).

> [!WARNING]
> The upgrade is refused until the hook succeeds. Fix the cause the Job's log names, or take the dump by hand first and then set `postgresql.upgradeBackupHook.enabled: false`. Turning the hook off without that dump loses the database.

<a id="100-pg-loader-detail"></a>
**Postgres waits for the dump to load**

- **Before:** Nothing loaded a dump.
- **Now:** The loader renames the file once loaded. A truncated or failing dump, or an interrupted load, leaves it in place.
- **Affects you if:** The load fails or is interrupted.
- **Do:** Load a complete dump by hand and rename the file ([guide]).

> [!WARNING]
> The Postgres pod does not become Ready while `backups/pre-upgrade.sql` is on the claim. Load a complete dump by hand and rename the file to `pre-upgrade.sql.loaded`, as the log and the [guide] describe.

<a id="100-objects"></a>
### Objects

<a id="100-objects-removed"></a>**Removed**

| Object | Note |
|---|---|
| ConfigMap `<release>-clickhouse-scripts` | Held `wait-until-ready.sh`, mounted at `/scripts` in the ClickHouse pod. The old pod can log `FailedMount` for it until it is recreated. |
| StatefulSet `<release>-zookeeper`, Services `<release>-zookeeper`, `<release>-zookeeper-headless` and `<release>-zookeeper-metrics`, ConfigMap `<release>-zookeeper-scripts` | Removed unless `zookeeper.enabled: true` ([caution](#100-keeper-switch-detail)). The claims stay, and scrapers of `<release>-zookeeper-metrics` lose their target. |
| ServiceAccount `signoz-telemetrystore-migrator` | Removed unless `telemetryStoreMigrator.serviceAccount.create: true`, or [left behind](#100-migrator-leftovers). |

<a id="100-objects-renamed"></a>**Renamed**

| Old | New | Note |
|---|---|---|
| ConfigMaps `<release>-clickhouse-operator-etc-files`, `-etc-confd-files`, `-etc-configd-files`, `-etc-templatesd-files`, `-etc-usersd-files` | `<release>-clickhouse-operator-files`, `-confd-files`, `-configd-files`, `-templatesd-files`, `-usersd-files` | Operator configuration. |
| Secret `<release>-clickhouse-external`, key `clickhouse-password` | Secret `<release>-clickhouse-credentials`, key `password` | External ClickHouse. |
| Job `signoz-telemetrystore-migrator` | Job `signoz-telemetrystore-migrator-<revision>` | A new one each revision. |
| PodDisruptionBudget `<release>-clickhouse-cluster`, made by the operator | `chi-<release>-clickhouse-cluster` | Both exist during the first upgrade, and the ClickHouse pod logs `MultiplePodDisruptionBudgets`. |
| ServiceMonitor `<release>-clickhouse-operator-metrics`, one endpoint on port `<release>-clickhouse-operator-metrics` | `<release>-clickhouse-operator-clickhouse-metrics`, endpoints `ch-metrics` and `op-metrics` at 30s | With the operator ServiceMonitor on. It selects `app.kubernetes.io/name: clickhouse-operator` and `instance`. |
| Operator objects `<clickhouse name>-operator` under `clickhouse.nameOverride` or `clickhouse.fullnameOverride` | `<release>-clickhouse-operator` | Set `altinity-clickhouse-operator.fullnameOverride` to keep the old name. |

<a id="100-objects-added"></a>**Added**

| Object | Note |
|---|---|
| ClickHouseKeeperInstallation `<release>-keeper` | While `keeper.enabled` is true, the default. |
| CustomResourceDefinition `clickhousekeeperinstallations.clickhouse-keeper.altinity.com` | Applied by the CRD hook with the other three. |
| Secret `<release>-clickhouse-credentials` | ClickHouse's password. |
| ConfigMaps `<release>-clickhouse-operator-keeper-confd-files`, `-keeper-configd-files`, `-keeper-templatesd-files`, `-keeper-usersd-files` | Operator configuration for Keeper. |
| Secret `<release>-postgresql-auth` (key `password`) and ConfigMap `<release>-postgresql-restore` | With bundled Postgres. Postgres and SigNoz read `POSTGRES_PASSWORD` from the Secret, where chart 0.151.0 wrote it into both pod specs. The ConfigMap holds the dump loader. |
| ServiceAccount, Role and RoleBinding `<release>-clickhouse-operator-upgrade` (weight -10) | Hook objects for the operator-upgrade Job ([Hooks](#100-hooks)). |
| ConfigMaps `<release>-clickhouse-operator-crds-1` to `-crds-4` (weight -7), ClusterRole, ClusterRoleBinding and ServiceAccount `<release>-clickhouse-operator-crd-install` (weight -6) | Hook objects for the CRD hook. Helm must be allowed to create the ClusterRole. |

<a id="100-objects-labels"></a>**Labels and selectors that changed**

| Objects | Before | Now |
|---|---|---|
| Selector of Deployment `<release>-clickhouse-operator` | `app.kubernetes.io/name: clickhouse`, `app.kubernetes.io/instance`, `app.kubernetes.io/component: operator` | `app.kubernetes.io/name: clickhouse-operator`, `app.kubernetes.io/instance` |
| Operator Deployment, ServiceAccount, Role, RoleBinding, Secret, metrics Service and ConfigMaps | `app.kubernetes.io/name: clickhouse`, `app.kubernetes.io/component: operator`, `app.kubernetes.io/version: 24.1.2`, `clickhouse.altinity.com/chop: 0.21.2`, `helm.sh/chart: clickhouse-24.1.18` | `app.kubernetes.io/name: clickhouse-operator`, no `component`, `app.kubernetes.io/version: 0.27.4`, no `chop`, `helm.sh/chart: altinity-clickhouse-operator-0.27.4` |
| Operator pod template | `app.kubernetes.io/name: clickhouse`, `app.kubernetes.io/instance`, `app.kubernetes.io/component: operator` | `app.kubernetes.io/name: clickhouse-operator`, plus `helm.sh/chart`, `app.kubernetes.io/version` and `app.kubernetes.io/managed-by: Helm`, still `component: operator`. Each Altinity chart version change rolls the pod. |
| Selector of Service `<release>-clickhouse-operator-metrics` | The old operator pod labels | The new operator pod labels |
| ClickHouseInstallation and its service template, ConfigMap `<release>-clickhouse-custom-functions`, ServiceAccount `<release>-clickhouse` | `helm.sh/chart: clickhouse-24.1.18`, `app.kubernetes.io/version: 24.1.2` | `helm.sh/chart: signoz-<chart version>`, and `app.kubernetes.io/version` is `clickhouse.image.tag` cut to 63 characters (`25.12.5`). The new credentials Secret and operator-upgrade hook objects carry it too ([digest tags](#100-digest-tag)). |
| ClickHouse pod template inside the ClickHouseInstallation | Selector labels plus `app.kubernetes.io/managed-by`, `app.kubernetes.io/version`, `helm.sh/chart` | Selector labels only. The operator still copies the installation's own labels onto the StatefulSet and pod. |
| Postgres objects | `helm.sh/chart: postgresql-0.0.2`, `app.kubernetes.io/version: 15.0.0` | `helm.sh/chart: signoz-<chart version>`, and `app.kubernetes.io/version` is `postgresql.image.tag` without a digest (`15`). Selectors unchanged. |
| ZooKeeper objects, when kept | `helm.sh/chart: zookeeper-0.0.1` | `helm.sh/chart: zookeeper-0.0.2` and annotation `signoz.io/deprecated: "true"`. The pod rolls once. |
| SigNoz and collector Services | A key in `signoz.service.labels` or `otelCollector.service.labels` named like a chart label was rendered twice | Rendered once, with your value |
| SigNoz, collector and migrator pods | The same labels and selectors | Unchanged |

<a id="100-objects-names"></a>**Ports and names that changed**

| Where | Before | Now |
|---|---|---|
| ClickHouse Service template ports `http` and `tcp` | No `targetPort` | `targetPort: http` and `client`, so `clickhouse.service.httpPort` and `tcpPort` move only the Service port |
| ClickHouse container port 9000 | Listed once | Named `client` by the chart and listed again as the operator's `tcp`. The Service targets `client`. |
| Ports of Service `<release>-clickhouse-operator-metrics` | One, `<release>-clickhouse-operator-metrics` (8888), with `type: ClusterIP` | `ch-metrics` (8888) and `op-metrics` (9999), with no `type` field (still ClusterIP) |
| Operator containers | `operator` and `metrics-exporter`, port `metrics` (8888) | `altinity-clickhouse-operator` and `metrics-exporter`, port `ch-metrics` (8888), plus a memory IPC `emptyDir`, config under `/etc/clickhouse-operator/chi/` and `chk/`, and strategy `Recreate` |
| Operator `users.d` file | `01-clickhouse-user.xml`, defining user `clickhouse_operator` | `01-clickhouse-operator-profile.xml` |
| `CLICKHOUSE_HTTP_PORT` in SigNoz, the collector, `check` and the migrator | Set | Removed |
| `CLICKHOUSE_VERIFY` | Collector container only | Also SigNoz, `check` and the migrator |
| `CLICKHOUSE_PASSWORD` in every container | A literal value | From Secret `<release>-clickhouse-credentials` |
| SigNoz `SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_CLUSTER` and connection string | A literal cluster, credentials in the query (`tcp://<host>:9000/?username=$(CLICKHOUSE_USER)&password=$(CLICKHOUSE_PASSWORD)`) | `$(CLICKHOUSE_CLUSTER)`, and `tcp://$(CLICKHOUSE_USER):$(CLICKHOUSE_PASSWORD)@$(CLICKHOUSE_HOST):$(CLICKHOUSE_PORT)` |
| SigNoz pod | A `dashboards` emptyDir volume and `args: null` | Neither |

<a id="100-hooks"></a>
### Hooks

| Hook | When it runs | What it does | How to turn it off | What a failure looks like |
|---|---|---|---|---|
| Job `<release>-postgresql-upgrade-backup` | `helm upgrade` with bundled Postgres, and `helm template --is-upgrade` ([how](#100-pg-backup-hook-detail)) | Dumps a database held in the container to the claim | `postgresql.upgradeBackupHook.enabled: false` or `--no-hooks`, after a dump by hand | `pre-upgrade hooks failed` with `BackoffLimitExceeded` or `DeadlineExceeded` ([warning](#100-pg-hook-stops-detail)) |
| Job `<release>-clickhouse-operator-upgrade` | Every `helm upgrade`, and in [rendered manifests](#100-hook-jobs-kubectl) | Deletes the operator Deployment chart 0.151.0 created | `clickhouse.operatorUpgradeHook.enabled: false` or `--no-hooks`, then delete it by hand | With the hook off, the upgrade fails on the immutable selector ([warning](#100-operator-replaced-detail)) |
| Job `<release>-clickhouse-operator-crd-install` | Every `helm install` and `helm upgrade`, and in rendered manifests | Applies the four CRDs, the [Keeper CRD](#100-keeper-crd) included, logging `serverside-applied` | `altinity-clickhouse-operator.crdHook.enabled: false` or `--no-hooks`, then apply the CRDs by hand before each operator version change | The upgrade fails after the old operator is deleted, leaving none (not tested) |
| Job and ServiceAccount `signoz-telemetrystore-migrator`, chart 0.151.0 only | Chart 0.151.0: before each `helm upgrade` | Ran the migrations | Removed: the migrator is now [a plain Job](#100-migrator-job) | A failed migration failed the upgrade, which it [no longer does](#100-migrations-no-gate) |

Helm runs the Jobs in weight order, `<release>-postgresql-upgrade-backup` at -11, `<release>-clickhouse-operator-upgrade` at -9 and `<release>-clickhouse-operator-crd-install` at -5, each after the objects it needs, listed under [Added](#100-objects-added), and rendered manifests apply them in that order, each finished, before the rest.

<a id="100-messages"></a>
### Messages

| Message | What it means | Read |
|---|---|---|
| `<n> values must change before the chart can be installed:` | The chart refused moved or removed keys, one per line below. Nothing changed. Under `helm upgrade` it starts `Error: UPGRADE FAILED:` and still says "installed". | [Values](#100-values) |
| `has moved to`, `has been removed:`, `no longer takes the enabled/port/path shape`, `but the operator's watch settings are untouched`, `characters: shorten it to at most 57.` | One refused key per line. | [Table 1](#100-moved-keys) |
| `clickhouse name "<name>" is <n> characters; the operator derives names from it that must fit 63, so it may be at most 34` | The ClickHouse name is too long. | [ClickHouse](#100-ch-name-length) |
| `keeper name "<name>" is <n> characters; the operator derives names from it that must fit 63, so it may be at most 34`, `no coordination store for ClickHouse` | The Keeper name is too long: shorten the release name or set `keeper.fullnameOverride`. Or every coordination store is off: set `clickhouse.externalZookeeper.servers`, `zookeeper.enabled: true` or `keeper.enabled: true`. | [Keeper and ZooKeeper](#100-keeper) |
| `env: these variables reference each other in a circle` | Entries in `signoz.env` reference each other in a circle. Break it. | [SigNoz](#100-signoz-env-override) |
| `env: an entry has no name`, `is set twice in one list` | A list-shaped env (`otelCollector.env`, `clickhouse.env`, `keeper.env`, the migrator's) has an entry without `name`, or a name twice. | [Collector](#100-collector) |
| `signoz.image is not set` | An image block is `null`. Give it a repository and tag. Chart 0.151.0 failed with `nil pointer evaluating interface {}.registry` instead. | [SigNoz](#100-signoz) |
| `YAML parse error on signoz/templates/clickhouse/clickhouseinstallation.yaml` | A map moved to `clickhouse.extraInitContainers`, which takes a list. | [ClickHouse](#100-udf-init) |
| `resource mapping not found for name: "<release>-keeper" namespace: "<namespace>" from "": no matches for kind "ClickHouseKeeperInstallation" in version "clickhouse-keeper.altinity.com/v1"` | The first upgrade with Keeper on and no Keeper CRD. Nothing changed. Helm adds `ensure CRDs are installed first`. | [Keeper and ZooKeeper](#100-keeper-crd) |
| `Rollback "<release>" failed: cannot patch "<release>-clickhouse-operator" with kind Deployment` | A rollback to chart 0.151.0 hit the operator Deployment's immutable selector after reverting other objects. | [Rollback](#100-rollback) |
| `job <release>-postgresql-upgrade-backup failed: DeadlineExceeded` | The backup hook did not finish in 240 s, for example while Postgres is scaled to 0. | [Postgres](#100-pg-hook-node) |
| `pre-upgrade hooks failed` with `job <release>-postgresql-upgrade-backup failed: BackoffLimitExceeded`, and in the Job's log `ERROR: cannot connect to Postgres at` | The Postgres backup hook could not dump, here for a wrong password or unreachable Postgres while the claim holds no data directory. Nothing changed: the line ends `The upgrade stopped before anything changed.` | [Postgres](#100-pg-hook-stops-detail) |
| `ERROR: the release mounts its own /docker-entrypoint-initdb.d, so the dump would not be loaded on the first start.` | Your own `/docker-entrypoint-initdb.d` stops the hook. | [Postgres](#100-pg-own-volumes) |
| `Dumped database <db> to /claim/backups/pre-upgrade.sql.`, `Nothing to back up.` | The hook dumped the database for the first start to load, or found it already on the claim. | [Postgres](#100-pg-backup-hook) |
| `Loading /var/lib/postgresql/backups/pre-upgrade.sql into database <db>` | The loader started. It ends with `renamed it to /var/lib/postgresql/backups/pre-upgrade.sql.loaded`. | [Postgres](#100-pg-loader) |
| `does not end with COMMIT;, so it is incomplete and was not loaded.`, `failed with the error above.` | A truncated dump, or one that failed to load. The database is empty and the pod is not Ready while the file is there. | [Postgres](#100-pg-loader-detail) |
| `Startup probe failed: 127.0.0.1:5432 - accepting connections` with `pre-upgrade.sql has not been loaded; see https://signoz.io/docs/operate/migration/upgrade-0-152/` | Postgres runs, but a dump waits to be loaded, so the pod stays not Ready. | [Postgres](#100-pg-loader-detail) |
| `deployment.apps "<release>-clickhouse-operator" deleted from <namespace> namespace`, `No resources found`, `serverside-applied` | Hook logs: the operator-upgrade hook removed chart 0.151.0's operator, or found nothing on a later upgrade, and the CRD hook applied a CRD. | [Hooks](#100-hooks) |
| `MountVolume.SetUp failed for volume "scripts" : configmap "<release>-clickhouse-scripts" not found`, `MultiplePodDisruptionBudgets` | Warnings on the old ClickHouse pod during the first upgrade, until the operator recreates it: its ConfigMap is [removed](#100-objects-removed), and two PodDisruptionBudgets exist while one is [renamed](#100-objects-renamed). | [Objects](#100-objects) |
| `just recreate the service in case of service type change ''=>'ClusterIP'` | Operator event `Error` `UpdateFailed` for the ClickHouse Services on every fresh install, each followed by `OK` `Create Service`. | [ClickHouse operator](#100-operator) |
| `SigNoz release <release> in namespace <namespace>:` | The first line of the notes, replacing `1. You have just deployed SigNoz cluster:`. The notes now name the coordination store and link the docs. | None |
| `ClickHouse coordinates through ClickHouse Keeper at keeper-<release>-keeper:2181.` | ClickHouse uses Keeper. On an existing install without `zookeeper.enabled: true`, this is the switch to an empty Keeper. | [Keeper and ZooKeeper](#100-keeper-switch-detail) |
| `ClickHouse coordinates through ZooKeeper.`, `The bundled ZooKeeper is deprecated; ClickHouse Keeper replaces it.`, `Keep zookeeper.enabled: true until you migrate. Migrate with the upgrade guide:` | Printed while `zookeeper.enabled` is true, followed by the address of the [guide], which has the migration. | [Keeper and ZooKeeper](#100-keeper-default) |
| `ClickHouse coordinates through the servers in clickhouse.externalZookeeper.servers.` | An external ZooKeeper. Keeper is still installed unless `keeper.enabled: false`. | [Keeper and ZooKeeper](#100-keeper-idle) |
| `DEPRECATION NOTICE:`, `We no longer bundle K8s-Infra chart with the SigNoz chart installation.`, `coalesce.go:237: warning: skipped value for zookeeper.initContainers: Not a table.` | No longer printed. Chart 0.151.0 printed the first for seven keys that did nothing and still do nothing, the second and lines about OtelCollectorMetrics and Frontend after an upgrade, and the third on every render. | [Table 3](#100-ignored-keys) |

<a id="100-limits"></a>
### Limits

<a id="100-rollback"></a>
#### Rollback

- `helm rollback` to a chart 0.151.0 revision fails on the operator Deployment's immutable selector, after Helm has reverted some objects.
- With bundled Postgres, Postgres goes back to the old layout and SigNoz starts on an empty database, while the claim keeps the real one. Upgrading forward again finds it (`Nothing to back up.`) and brings the original organization back. Writes made while rolled back are lost.
- After running on Keeper, StatefulSet `<release>-zookeeper` comes back on its retained claim with the coordination state from before the upgrade, and ClickHouse points at it again. Metadata written on Keeper is unknown to it. What ClickHouse then does is not tested.
- Do not roll back once ClickHouse runs on Keeper, or across the switch, without a plan for the replicated tables.

To roll back to a chart 0.151.0 revision while ClickHouse still runs on ZooKeeper, delete the ClickHouseKeeperInstallation (with Keeper on) and wait, delete the operator Deployment right before the rollback, then roll back. Not tested: no run took these steps.

```bash
kubectl -n <namespace> delete clickhousekeeperinstallation <release>-keeper --wait   # with keeper.enabled: true
kubectl -n <namespace> delete deployment <release>-clickhouse-operator
helm rollback <release> <revision> -n <namespace>
```

<a id="100-uninstall"></a>
#### Uninstall

What differs from chart 0.151.0 after `helm uninstall`:
- A fresh install leaves two objects on their finalizers, the ClickHouseInstallation and the ClickHouseKeeperInstallation, where chart 0.151.0 left one.
- The Keeper claim stays, where chart 0.151.0 left a ZooKeeper claim.
- Four CRDs stay, where chart 0.151.0 left three.
- Bundled Postgres data stays on its claim and returns when the release is installed again.
- Installing again over a stuck object works, and a plain `helm upgrade` with the same values then recreates the ClickHouse and Keeper objects.
- A `clickhouse.namespace` Namespace now stays, with `helm.sh/resource-policy: keep` and `argocd.argoproj.io/sync-options: Prune=false,Delete=false`. Delete it by hand when nothing in it is wanted.

On both chart versions, a plain `helm uninstall` leaves the ClickHouse objects on their finalizers ([uninstall steps](README.md#uninstalling-the-chart)).

<a id="100-not-tested"></a>
#### What was not tested

> [!NOTE]
> None of these was run on a cluster. Try the ones that apply to you on a test cluster before you rely on them.

- The changes marked "not tested" above:
  - [password changes](#100-password-restart)
  - [system-logs sidecar](#100-logs-sidecar-detail)
  - [TLS to an external ClickHouse](#100-external-ch-tls-detail)
  - [digest tags](#100-digest-tag)
  - [operator pull secrets](#100-operator-pull-secrets)
  - [passwords that stop SigNoz](#100-signoz-dsn-detail)
  - [partial collector ports](#100-collector-ports)
  - [migrator ServiceAccount](#100-migrator-sa)
  - [left-over migrator objects](#100-migrator-leftovers)
  - [migrator ServiceAccount name](#100-migrator-sa-name)
  - [a failing CRD hook](#100-hooks)
  - [ClickHouse after a rollback to ZooKeeper, and the rollback steps](#100-rollback)
  - [edited system log files](#100-operator-system-logs-detail)
  - [the histogramQuantile binary without GitHub](#100-registry)
- How replicated tables behave against an empty Keeper ([switch](#100-keeper-switch)), and an idle Keeper beside a ZooKeeper in use ([idle Keeper](#100-keeper-idle)).
- Argo CD's own handling of the hooks and of `--is-upgrade` ([backup step](#100-pg-backup-hook)).
- `clickhouse.containerSecurityContext` at runtime, with uid 101 and writable volumes ([Table 1](#100-moved-keys)), and the hooks in a namespace that enforces the `restricted` Pod Security profile with default values ([Hooks](#100-hooks)).
- A plain password holding `&` or `<` through `clickhouse.existingSecret` without the SHA-256 key ([own Secret](#100-ch-existing-secret)).
- A fresh non-root install of the bundled Postgres, and what its pod shows once the startup probe's 30 minutes run out while a dump waits ([startup probe](#100-pg-startup-probe)).

<a id="100-versions"></a>
### Versions

| What | Before | Now |
|---|---|---|
| Chart `signoz` | 0.151.0 | 1.0.0 |
| Chart `altinity-clickhouse-operator` | None | 0.27.4, from `https://helm.altinity.com` |
| Chart `clickhouse` | 24.1.18, from `https://charts.signoz.io` | Part of the SigNoz chart |
| Chart `postgresql` | 0.0.2, from `https://charts.signoz.io` | Part of the SigNoz chart |
| Chart `zookeeper` | 0.0.1, inside the `clickhouse` chart | 0.0.2, from this repository, deprecated |
| Charts `signoz-otel-gateway` and `redpanda` | 0.0.4 and 5.10.2, from `https://charts.signoz.io` | Unchanged |
| ClickHouse operator | 0.21.2 | 0.27.4 |
| Operator image | `docker.io/altinity/clickhouse-operator:0.21.2` | `altinity/clickhouse-operator:0.27.4` |
| Metrics exporter image | `docker.io/altinity/metrics-exporter:0.21.2` | `altinity/metrics-exporter:0.27.4` |
| CRDs | 3, at 0.21.2, installed on first install only | 4, at 0.27.4, adding `clickhousekeeperinstallations.clickhouse-keeper.altinity.com`, applied by a hook on every install and upgrade |
| ClickHouse image | `docker.io/clickhouse/clickhouse-server:25.12.5` | `clickhouse/clickhouse-server:25.12.5`, the same Docker Hub image |
| histogramQuantile download image | `docker.io/alpine:3.18.2` | `clickhouse/clickhouse-server:25.12.5` |
| Keeper image | None | `clickhouse/clickhouse-keeper:25.12.5`, following `global.imageRegistry` |
| System-logs sidecar image | `docker.io/signoz/signoz-otel-collector:0.111.16` | `signoz/signoz-otel-collector:v0.144.15` |
| Operator hook image | None | `registry.k8s.io/kubectl:v1.36.3` ([with `global.imageRegistry`](#100-registry)) |
| Postgres backup hook image | None | `postgres:15` |
| SigNoz | v0.151.0 (`docker.io/signoz/signoz:v0.151.0`) | v0.152.0, set when chart 1.0.0 is released |
| Collector image, also for `check` and the migrator | `docker.io/signoz/signoz-otel-collector:v0.144.16` | Unchanged |
| Postgres image | `postgres:15` | Unchanged |
| ZooKeeper image | `signoz/zookeeper:3.7.1` | Unchanged |

[guide]: https://signoz.io/docs/operate/migration/upgrade-0-152/
