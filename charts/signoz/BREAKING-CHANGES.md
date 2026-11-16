# Overhaul release: breaking and configuration changes

This file records what the overhaul work changes for users, per pass, and is folded into the README's breaking-changes section when the release is cut.

## ClickHouse operator from Altinity's chart, and charts/clickhouse folded in (PR #948)

The `signoz` chart now depends on `altinity-clickhouse-operator` 0.27.4 from `https://helm.altinity.com`, and the separate `charts/clickhouse` chart is now part of `charts/signoz`; folding it in renames no ClickHouse object, and persistent volumes and their data are untouched.

### Values that move or disappear

| Old key | New key | Note |
|---|---|---|
| `clickhouse.clickhouseOperator.*` | `altinity-clickhouse-operator.*` | Operator settings use the key names of Altinity's chart. |
| `clickhouse.clickhouseOperator.{logger,queryLog,...}.{ttl,flushInterval}` | none | No direct replacement. Override the whole file under `altinity-clickhouse-operator.configs.configdFiles.<name>`, for example `01-clickhouse-03-query_log.xml`. The defaults are in the chart's `values.yaml`. |
| `clickhouse.zookeeper.*` | `zookeeper.*` | Moved to the top level. |
| none | `clickhouse.operatorUpgradeHook.*` | New. Settings of the pre-upgrade hook Job that recreates the operator Deployment. |

- If a values file still sets an old path, the render fails with a message naming the new path. This applies to `helm install`, `helm upgrade` and `helm template`. Move the value to the new path and run the command again.
- `clickhouse.enabled: false` still turns off ClickHouse, ZooKeeper and the operator. `altinity-clickhouse-operator.enabled` and `zookeeper.enabled` can now be set on their own.
- `global.imageRegistry` and `global.imagePullSecrets` do not reach the operator, metrics-exporter and CRD-hook images, because Altinity's chart reads no `global.*` values. If these images come from another registry or need pull secrets, set these keys instead:
  - `altinity-clickhouse-operator.operator.image.registry`: operator image registry.
  - `altinity-clickhouse-operator.metrics.image.registry`: metrics-exporter image registry.
  - `altinity-clickhouse-operator.crdHook.image.repository`: CRD-hook image. The default is `registry.k8s.io/kubectl`, so the value includes the registry.
  - `altinity-clickhouse-operator.imagePullSecrets`: pull secrets for the operator pod (operator and metrics-exporter). The CRD-hook Job takes its pull secrets from `altinity-clickhouse-operator.crdHook.imagePullSecrets`.

### What happens to objects on the upgrade

- **Operator Deployment.** Its selector changed, and a Deployment selector cannot be changed in place. A pre-upgrade hook Job deletes `<release>-clickhouse-operator`, and Helm creates it again with the same name. Expect a few seconds without an operator. ClickHouse keeps serving. On later upgrades the Job finds nothing to delete.
- **Hook turned off.** If `clickhouse.operatorUpgradeHook.enabled: false` is set, delete the Deployment by hand right before the upgrade:

  ```sh
  kubectl delete deployment <release>-clickhouse-operator -n <namespace>
  ```

- **CRDs.** On every upgrade, Altinity's CRD hook Job takes over the three existing ClickHouse CRDs and adds the Keeper CRD (`clickhousekeeperinstallations.clickhouse-keeper.altinity.com`), with server-side apply. The Job needs the image `registry.k8s.io/kubectl:v1.36.3`, and its ServiceAccount needs a ClusterRole, even though the operator itself is namespace-scoped. If the cluster does not allow that image or a ClusterRole, set `altinity-clickhouse-operator.crdHook.enabled: false` and apply the CRDs by hand before the upgrade, and again whenever the `altinity-clickhouse-operator` version changes:

  ```sh
  helm pull altinity-clickhouse-operator --repo https://helm.altinity.com --version 0.27.4 --untar --untardir ./altinity
  kubectl apply --server-side --force-conflicts -f ./altinity/altinity-clickhouse-operator/crds/
  ```

- **Operator RBAC.** Stays namespaced (`altinity-clickhouse-operator.rbac.namespaceScoped: true`). The Role keeps its name and is patched in place. No action needed.
- **Operator ConfigMaps.** The name suffix changes from `-etc-<dir>-files` to `-<dir>-files`. Update anything outside the chart that refers to them by name.
- **Operator pod label.** `app.kubernetes.io/name` is now `clickhouse-operator` (was `clickhouse`). `app.kubernetes.io/component: operator` is kept. Update selectors, network policies and queries that match the operator pod on the old value.
- **PodDisruptionBudget.** The operator renames `<release>-clickhouse-cluster` to `chi-<release>-clickhouse-cluster`. Update anything that refers to it by name.
- **ClickHouse pods.** The ClickHouse pod template drops the `helm.sh/chart` label and carries the ClickHouse image tag as `app.kubernetes.io/version`. The ClickHouse pods therefore roll once during this upgrade. After that, a new chart version alone no longer restarts them. PVCs and data are untouched.
- **Operator metrics Service.** The settings for its type and annotations are gone. It is always `ClusterIP`, on ports 8888 and 9999. Anything that reached it through another Service type, or read annotations on it, must change.

### Rollback and `--no-hooks`

The old and the new operator Deployment have different selectors, and in these two cases nothing deletes the Deployment. Delete it by hand at the time given:

- **`helm rollback` to a revision from before this upgrade:** run the delete right before `helm rollback`.
- **`helm upgrade --no-hooks` from a chart version before this change:** run the delete right before `helm upgrade`. Later upgrades with `--no-hooks` do not need it. `--no-hooks` also skips the CRD hook, so apply the CRDs by hand as shown above.

```sh
kubectl delete deployment <release>-clickhouse-operator -n <namespace>
```

### Operator behavior that changes with 0.27.4

- **As soon as the 0.27.4 operator runs:** per-CPU metrics (`OS*CPU<n>`, `CPUFrequencyMHz_<n>`) are no longer exported. Dashboards and alerts that use them get no data.
- **At the next ClickHouse restart, on ClickHouse 23.3 and later:** the `clickhouse_operator` user gains `access_management` and named-collection grants.
- **At the next ClickHouse restart, on ClickHouse 23.5 and later:** the operator sets `display_secrets_in_show_and_select: 1`.
- **After a reconcile is aborted:** the operator retries it automatically when a pod becomes Ready.
- **When a replica is deleted or its volume is lost:** the operator removes the replica from ZooKeeper or ClickHouse Keeper.
- **On data loss or a failed StatefulSet update:** the operator recreates the StatefulSet.
- **When a replica is added:** the new replica waits until its replication lag is 10 seconds or less.
- **When a ClickHouseInstallation uses removed syntax:** the operator rejects file names with the `USERS/`, `COMMON/` or `HOST/` prefix and user settings named `k8s_secret_*`, and reports `RemovedSecretRefSyntax`. The chart's templates use none of these. If values or a hand-edited ClickHouseInstallation add them, remove them before the upgrade.
- **Whenever the operator Deployment is updated:** its strategy is `Recreate`. The old operator pod stops before the new one starts, so there is a short time without an operator.

## ClickHouse (pass 1)

ClickHouse values take the Kubernetes shape and are rendered as given.

**Probes:** `clickhouse.startupProbe`, `clickhouse.livenessProbe` and `clickhouse.readinessProbe` are Kubernetes probe objects (`httpGet` plus the timing fields). The `enabled`/`port`/`path` shape is no longer read.

Before:

```yaml
clickhouse:
  livenessProbe:
    enabled: true
    port: http
    path: /ping
    initialDelaySeconds: 60
    periodSeconds: 3
    timeoutSeconds: 1
    failureThreshold: 10
    successThreshold: 1
```

After:

```yaml
clickhouse:
  livenessProbe:
    httpGet:
      port: http
      path: /ping
    initialDelaySeconds: 60
    periodSeconds: 3
    timeoutSeconds: 1
    failureThreshold: 10
    successThreshold: 1
```

**Custom probes:** `clickhouse.customStartupProbe`, `clickhouse.customLivenessProbe` and `clickhouse.customReadinessProbe` have been removed. Set the probe object itself on `clickhouse.startupProbe`, `clickhouse.livenessProbe` or `clickhouse.readinessProbe`.

**Pod security context:** `clickhouse.securityContext`, with its `enabled` flag, is now `clickhouse.podSecurityContext`, a pod security context object without the flag.

Before:

```yaml
clickhouse:
  securityContext:
    enabled: true
    runAsUser: 101
    runAsGroup: 101
    fsGroup: 101
    fsGroupChangePolicy: OnRootMismatch
```

After:

```yaml
clickhouse:
  podSecurityContext:
    runAsUser: 101
    runAsGroup: 101
    fsGroup: 101
    fsGroupChangePolicy: OnRootMismatch
```

**Turning off or switching a probe:** set a probe or `clickhouse.podSecurityContext` to `null` to render none; an empty map keeps the defaults, because Helm merges a user's map over the default map. To use `exec`, `tcpSocket` or `grpc`, also set `httpGet: null`, because a probe may have only one handler.

```yaml
clickhouse:
  readinessProbe: null                                     # no readiness probe
  livenessProbe: {httpGet: null, tcpSocket: {port: 9000}}  # a TCP liveness probe
```

**Volumes:** `clickhouse.additionalVolumes` is now `clickhouse.extraVolumes`, and `clickhouse.additionalVolumeMounts` is now `clickhouse.extraVolumeMounts`. The lists keep their shape.

Each old key (`clickhouse.securityContext`, the three `custom*Probe` keys, `clickhouse.additionalVolumes`, `clickhouse.additionalVolumeMounts`, and a probe that still has `enabled`, `port` or `path`) makes the install fail with a message naming its replacement.

**Removed key:** `clickhouse.logs.system.image.pullSecrets` has been removed. No template read it; ClickHouse pods take their pull secrets from `clickhouse.imagePullSecrets`. If the old key is still set, the install goes ahead and the notes printed after it ask you to remove the key.

## ClickHouse image keys

The five image blocks under `clickhouse` take the `repository`, `tag` and `pullPolicy` shape. The `registry` key is gone from each.

**Removed keys:** `clickhouse.image.registry`, `clickhouse.logs.system.image.registry`, `clickhouse.initContainers.udf.image.registry`, `clickhouse.initContainers.init.image.registry` and `clickhouse.operatorUpgradeHook.image.registry`.

**Repository carries the registry:** when an image needs a registry, it is part of the repository, as in `registry.k8s.io/kubectl`. Images pulled from Docker Hub name no registry, as in `clickhouse/clickhouse-server`.

Before:

```yaml
clickhouse:
  image:
    registry: my.registry
    repository: clickhouse/clickhouse-server
```

After:

```yaml
clickhouse:
  image:
    repository: my.registry/clickhouse/clickhouse-server
```

**Mirrors:** `global.imageRegistry` replaces a registry found at the front of the repository, so a mirrored install keeps the defaults unchanged and sets only `global.imageRegistry`. With `global.imageRegistry: my.registry`, the operator upgrade hook pulls `my.registry/kubectl`, not `my.registry/registry.k8s.io/kubectl`.

Each of the four keys that existed before this release, when set to a non-empty value, makes the install fail with a message naming the replacement. The operator upgrade hook block is new in this release, so it has no old key to reject.

**ClickHouse pods:** the rendered ClickHouse pod template changes from `docker.io/clickhouse/clickhouse-server:<tag>` to `clickhouse/clickhouse-server:<tag>`. This is the same image, but the pod template changes, so the ClickHouse pods roll once on this upgrade. The label change in this release already rolls them, so the upgrade adds no extra restart.
