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

- **Operator Deployment.** Its selector changed, and a Deployment selector cannot be changed in place. A pre-upgrade hook Job deletes the operator Deployment the old chart created (`<release>-clickhouse-operator`, or `<release>-clickhouse-<name>` when `clickhouse.clickhouseOperator.name` was set), and Helm creates `<release>-clickhouse-operator`. Expect a few seconds without an operator. ClickHouse keeps serving. On later upgrades the Job finds nothing to delete.
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
- **ClickHouse pods.** The ClickHouse pod template carries the selector labels only. `helm.sh/chart`, `app.kubernetes.io/version` and `app.kubernetes.io/managed-by` stay on the ClickHouseInstallation. The ClickHouse pods therefore roll once during this upgrade. After that, a new chart version alone no longer restarts them. PVCs and data are untouched.
- **Operator metrics Service.** The settings for its type and annotations are gone. It is always `ClusterIP`, on ports 8888 and 9999. Anything that reached it through another Service type, or read annotations on it, must change.

### Rollback and `--no-hooks`

The old and the new operator Deployment have different selectors, and in these two cases nothing deletes the Deployment. Delete it by hand at the time given:

- **`helm rollback` to a revision from before this upgrade:** run the delete right before `helm rollback`.
- **`helm upgrade --no-hooks` from a chart version before this change:** run the delete right before `helm upgrade`. Later upgrades with `--no-hooks` do not need it. `--no-hooks` also skips the CRD hook, so apply the CRDs by hand as shown above.

```sh
kubectl delete deployment <release>-clickhouse-operator -n <namespace>
```

### Uninstall

The operator and the ClickHouseInstallation (and the ClickHouseKeeperInstallation, when Keeper is on) are in the same release. `helm uninstall` deletes them in one pass, and the operator is gone before it can finish the installations' finalizers, so the installations stay in Terminating with their StatefulSets, pods and Services still running. Altinity's own chart documents the same behaviour. Delete the installations first and wait for them, then uninstall:

```bash
kubectl -n <namespace> delete chi,chk --all --wait
helm uninstall <release> -n <namespace>
```

If the release was uninstalled first, remove the finalizer from each installation, then delete what the operator left:

```bash
kubectl -n <namespace> patch chi <release>-clickhouse --type merge -p '{"metadata":{"finalizers":[]}}'
kubectl -n <namespace> patch chk <release>-keeper --type merge -p '{"metadata":{"finalizers":[]}}'
kubectl -n <namespace> delete statefulset,service,configmap -l clickhouse.altinity.com/chi=<release>-clickhouse
kubectl -n <namespace> delete statefulset,service,configmap -l clickhouse-keeper.altinity.com/chk=<release>-keeper
```

Claims are never deleted by either path; remove them by hand when the data is no longer wanted.

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

**Pod security context:** `clickhouse.securityContext`, with its `enabled` flag, is now `clickhouse.podSecurityContext`, a pod security context object without the flag. The ClickHouse container's security context is the new `clickhouse.containerSecurityContext`, a Kubernetes SecurityContext object rendered only when set.

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

Each old key (`clickhouse.securityContext`, the three `custom*Probe` keys, `clickhouse.additionalVolumes`, `clickhouse.additionalVolumeMounts`, and a probe that still has `enabled`, `port` or `path`) makes the install fail with a message naming its replacement; for `clickhouse.securityContext` that is `clickhouse.podSecurityContext` or `clickhouse.containerSecurityContext`.

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

## ClickHouse Keeper replaces ZooKeeper

ClickHouse Keeper is now the default coordination store: `keeper.enabled: true` renders a ClickHouseKeeperInstallation that the ClickHouse operator manages. The bundled ZooKeeper is off by default (`zookeeper.enabled: false`) and deprecated. It is kept for installs that have not migrated yet.

- **First upgrade of an existing install:** the upgrade needs one of these two. Either way, keep `zookeeper.enabled: true` until the install has migrated to Keeper.
  - **Stay on ZooKeeper for now:** set `zookeeper.enabled: true` and `keeper.enabled: false`. The upgrade goes through, and its CRD hook adds the Keeper CRD anyway, but no Keeper object is created. When you migrate, step 2 of the guide below turns Keeper on with `keeper.enabled: true`.
  - **Prepare Keeper in the same upgrade:** apply Altinity's Keeper CRD first, then upgrade with `zookeeper.enabled: true`. Keeper comes up idle beside ZooKeeper, and ClickHouse stays on ZooKeeper. When you migrate, step 2 of the guide below only checks Keeper.

    ```bash
    kubectl apply -f https://github.com/Altinity/clickhouse-operator/raw/release-0.27.4/deploy/helm/clickhouse-operator/crds/CustomResourceDefinition-clickhousekeeperinstallations.clickhouse-keeper.altinity.com.yaml
    ```

- **Why:** Helm checks every object the chart renders against the cluster before it runs any hook, so the Keeper CRD must already exist or the ClickHouseKeeperInstallation must not be rendered. The CRD hook adds the Keeper CRD only after that check. An upgrade with neither, such as values that never set these keys or that set only `zookeeper.enabled: true`, is refused with `no matches for kind "ClickHouseKeeperInstallation"`, and nothing on the cluster changes. Add one of the two above and run the upgrade again.
- **ZooKeeper pod:** on installs that keep ZooKeeper, the upgrade restarts the ZooKeeper pod once, because the deprecated ZooKeeper chart has a new version and its `helm.sh/chart` label is on the pod template. ClickHouse reconnects once.
- **Dropping ZooKeeper without migrating:** the read-only state described in "If you upgraded without `zookeeper.enabled: true`" below applies only once the Keeper CRD exists and an upgrade drops `zookeeper.enabled` without migrating.

### Migrating from ZooKeeper to ClickHouse Keeper

Convert the ZooKeeper coordination state into a ClickHouse Keeper snapshot, seed the Keeper volume with it, and repoint ClickHouse at Keeper without losing replication metadata. The conversion happens offline: `clickhouse keeper-converter` reads the ZooKeeper snapshot plus the transaction logs written after it and writes one Keeper snapshot. Table data never moves; only the coordination tree does. Expect 1 to 3 minutes of ingestion downtime and 10 to 20 minutes end to end including the checks.

Swap Keeper in without converting and every `ReplicatedMergeTree` table comes up read-only (`TABLE_IS_READ_ONLY`) against an empty coordination tree. See "Rollback" and "If you upgraded without `zookeeper.enabled: true`" for the way out of that.

This guide is written for one Keeper replica, which is the chart default. If you want three, migrate with one and raise `keeper.replicaCount` after step 11.

#### Prerequisites

**Access**

- `kubectl exec` into the release namespace.
- Permission to create Jobs, to scale StatefulSets and Deployments, and to patch the ClickHouseInstallation.
- Permission to run `helm upgrade` on the release.
- Permission to run ClickHouse `SYSTEM` commands as the chart's admin user.
- Argo CD users: permission to turn auto-sync off for the application.

**Tools**

- `kubectl`, `helm`.
- `clickhouse-client`, present in the ClickHouse server image.

**Before you start**

This guide starts from a release that has already been upgraded to chart version `0.150.0` or later with `zookeeper.enabled: true` in its values. That upgrade is the release's own upgrade, covered by its upgrade notes, not part of this guide. After it:

- ClickHouse still runs on ZooKeeper, because the chart prefers ZooKeeper while both stores are on.
- That upgrade restarted the ZooKeeper pod once (the chart's deprecation bump changes its pod template), so ClickHouse reconnected once; by the time you start here `system.zookeeper_connection` shows `is_expired` 0 and no table is read-only. Step 1 checks the connection and step 4 the read-only count.
- Keeper is in one of the two states the first upgrade leaves it in, as described in "ClickHouse Keeper replaces ZooKeeper" above: off (`keeper.enabled: false`) if the release stayed on ZooKeeper, or on (`keeper.enabled: true`, the chart default) and running idle beside ZooKeeper with an empty tree if the Keeper CRD was applied before the upgrade. Both are fine. Step 2 turns it on if it is off, and checks it.
- ZooKeeper values live at `zookeeper.*`, not `clickhouse.zookeeper.*`.
- `keeper.replicaCount` is 1 or unset.
- The chart's ZooKeeper is 3.7; the converter needs 3.4 or later.

If the release has not been upgraded yet, do that first, in one of the two ways described in "ClickHouse Keeper replaces ZooKeeper" above, and come back here.

**What to know**

- The converter is an offline, file-to-file translation between ZooKeeper's snapshot format and Keeper's. Nothing connects to ZooKeeper or to Keeper while it runs; both are stopped. It moves the replication metadata (which parts exist, which replica holds what, queues, in-flight mutations), never the parts themselves.
- The output is one snapshot file that Keeper loads at startup, so seeding has to happen before Keeper first runs with real data.
- ACLs and ephemeral nodes do not carry over. Ephemerals are session state and are recreated when clients reconnect. The chart uses no ACLs.
- Repointing ClickHouse is a config change. ClickHouse hot-reloads it, but it does not move its live session. You restart the ClickHouse pods by hand in step 9.

#### Variables

```bash
export NS="<release-namespace>"
export RELEASE="<release-name>"

export ZK_STS="$RELEASE-zookeeper"
export ZK_REPLICAS="<zookeeper-replica-count>"          # zookeeper.replicaCount, default 1
export ZK_LEADER_PVC="data-$RELEASE-zookeeper-<n>"      # set in step 1

export CHK_STS="chk-$RELEASE-clickhouse-keeper-cluster-0-0"
export CHK_PVC="default-chk-$RELEASE-clickhouse-keeper-cluster-0-0-0"
export KEEPER_HOST="keeper-$RELEASE-clickhouse-keeper"

export CHI_NAME="$RELEASE-clickhouse"
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
|---|---|
| `ZK_LEADER_PVC` | Claim of the ZooKeeper leader, set in step 1. The leader holds the most current snapshot and log; the conversion reads this volume. With one ZooKeeper replica it is `data-$RELEASE-zookeeper-0`. |
| `CHK_STS`, `CHK_PVC`, `KEEPER_HOST` | Named by the operator from the chart's CHK `$RELEASE-clickhouse-keeper`. Confirm them in step 2. |
| `CH_PODS` | Every ClickHouse pod. All of them are deleted in step 9 and come back under the same names, so the variable stays valid. |
| `COLLECTOR_DEPLOY` | The collector Deployment. Its name depends on the release name, so read it from `kubectl get deploy`. |
| `CONVERTER_IMAGE` | The server image at the version the cluster runs. The slim `clickhouse-keeper` image does not carry the converter. |

#### Steps

Check Keeper, freeze ingestion and merges, convert the ZooKeeper state offline onto the Keeper volume, then repoint ClickHouse and restart it, and finally remove ZooKeeper from the release.

Steps 6 through 9 are the outage window: budget 1 to 3 minutes of ingestion downtime and 10 to 20 minutes end to end including the checks. No `helm upgrade` runs inside it.

**Argo CD:** turn auto-sync off before step 2 and turn it back on after step 11, otherwise Argo reverts the scale-downs and the CHI patch mid-migration. Where this guide says `helm upgrade`, commit the values change and sync by hand.

##### Step 1: Confirm ZooKeeper and collect information

**Purpose:** confirm ZooKeeper is what the release runs on, and identify the volume and the leader node the conversion reads from.

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
signoz-zookeeper-0: Mode: standalone
```

A single-node ZooKeeper reports `Mode: standalone`, and that node is the one to convert from. With three, one reports `leader`. Set `ZK_LEADER_PVC` to the `data-` claim bound to that pod.

**Verify:**

```bash
kubectl -n "$NS" get pvc "$ZK_LEADER_PVC"
chc "SELECT host, port, is_expired FROM system.zookeeper_connection"
```

`host` is the ZooKeeper service and `is_expired` is `0`.

**If it fails:** If there is no ZooKeeper StatefulSet, or `system.zookeeper_connection` already shows `$KEEPER_HOST`, this guide does not apply.

##### Step 2: Enable and validate ClickHouse Keeper

**Purpose:** turn Keeper on if the release deferred it, and confirm the Keeper StatefulSet, services and volume are in place and healthy, so the target volume exists before the outage window opens.

**Run:**

If `keeper.enabled` is `false`, set it in your values file:

```yaml
keeper:
  enabled: true
```

```bash
helm upgrade "$RELEASE" signoz/signoz --version 0.150.0 -n "$NS" -f values.yaml
```

ZooKeeper is still live and every table is writable, so the upgrade runs with its hooks. If Keeper is already on, there is nothing to run here. Argo CD users: commit the values change and sync by hand.

Wait for the CHK to report `Completed`, then list what it created:

```bash
kubectl -n "$NS" get chk
kubectl -n "$NS" get pvc | grep -E 'zookeeper|keeper'
kubectl -n "$NS" get svc | grep -E 'zookeeper|keeper'
```

**Expect:**

```text
NAME                       STATUS      CLUSTERS   HOSTS   AGE
signoz-clickhouse-keeper   Completed   1          1       2m

data-signoz-zookeeper-0                              Bound   ...   RWO   ...
default-chk-signoz-clickhouse-keeper-cluster-0-0-0   Bound   ...   RWO   ...

chk-signoz-clickhouse-keeper-cluster-0-0          ClusterIP   None   <none>   2181/TCP,9444/TCP
chk-signoz-clickhouse-keeper-cluster-0-0-client   ClusterIP   None   <none>   2181/TCP
keeper-signoz-clickhouse-keeper                   ClusterIP   None   <none>   2181/TCP,9444/TCP
signoz-zookeeper                                  ClusterIP   ...    <none>   2181/TCP,2888/TCP,3888/TCP
signoz-zookeeper-headless                         ClusterIP   None   <none>   2181/TCP,2888/TCP,3888/TCP
```

Confirm `CHK_STS`, `CHK_PVC` and `KEEPER_HOST` against this output.

**Verify:**

```bash
kubectl -n "$NS" exec "$CHK_STS-0" -- sh -c 'echo ruok | nc 127.0.0.1 2181'
```

```text
imok
```

**If it fails:** If the Keeper pod is not running, check node taints and that the Keeper claim landed in the same zone as the ZooKeeper claim; the converter Job must mount both. Go to step 2.

##### Step 3: Stop ingestion and merges

**Purpose:** freeze the coordination state so nothing is written to ZooKeeper between the conversion and the swap.

**Run:**

```bash
kubectl -n "$NS" scale deployment "$COLLECTOR_DEPLOY" --replicas=0
kubectl -n "$NS" get pods | grep otel-collector

chc "SYSTEM STOP MERGES"
```

**Expect:**

```text
(no collector pods remain)
Ok.
```

Agents sending to the collector buffer and retry while it is down. Expect a gap in your data for the window, not a loss, within the agents' retry limits.

**Verify:**

```bash
chc "SELECT count() FROM system.replication_queue"
chc "SELECT count() FROM system.mutations WHERE NOT is_done"
```

```text
0
0
```

**If it fails:** If either count will not drain to `0`, do not proceed, because an in-flight mutation converted mid-flight comes back inconsistent. Wait, or investigate the stuck entry first.

##### Step 4: Record the ZooKeeper tree and replica baseline

**Purpose:** capture the numbers the migration is verified against: the shape of the tree, and how many replicated tables must come back.

**Run:**

```bash
chc "
  SELECT path, name, numChildren
  FROM system.zookeeper
  WHERE path IN ('/', '/clickhouse', '/clickhouse/clickhouse', '/clickhouse/clickhouse/task_queue')
  ORDER BY path, name
  FORMAT PrettyCompact"

chc "SELECT count() FROM system.replicas"
```

**Expect:**

```text
   ┌─path──────────────────────────────┬─name───────┬─numChildren─┐
1. │ /                                 │ clickhouse │           3 │
2. │ /                                 │ zookeeper  │           2 │
3. │ /clickhouse                       │ clickhouse │           1 │
4. │ /clickhouse                       │ sessions   │           1 │
5. │ /clickhouse                       │ tables     │          56 │
6. │ /clickhouse/clickhouse            │ task_queue │           2 │
7. │ /clickhouse/clickhouse/task_queue │ ddl        │           0 │
8. │ /clickhouse/clickhouse/task_queue │ replicas   │           1 │
   └───────────────────────────────────┴────────────┴─────────────┘

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

**Purpose:** confirm where inside the Keeper volume the snapshot has to land, so the converter writes where Keeper reads at startup.

**Run:**

```bash
kubectl -n "$NS" exec "$CHK_STS-0" -- id
kubectl -n "$NS" exec "$CHK_STS-0" -- ls -la /var/lib/clickhouse-keeper/coordination/
kubectl -n "$NS" exec "$CHK_STS-0" -- \
  grep -E 'snapshot_storage_path|log_storage_path|server_id' /etc/clickhouse-keeper/keeper_config.xml
```

**Expect:**

```text
uid=0(root) gid=0(root) groups=0(root),…,101(clickhouse)

drwxr-sr-x    2 clickhouse clickhouse      4096 ... log
drwxr-s---    2 clickhouse clickhouse      4096 ... logs
drwxr-sr-x    2 clickhouse clickhouse      4096 ... snapshots

<server_id>1</server_id>
<log_storage_path>/var/lib/clickhouse/coordination/logs</log_storage_path>
<snapshot_storage_path>/var/lib/clickhouse/coordination/snapshots</snapshot_storage_path>
```

The prefix in `keeper_config.xml` and the mount point on disk can differ. Use the path relative to the volume root, which is `coordination/snapshots` either way. That is what step 7 writes to. Files must end up owned by uid and gid `101`.

**Verify:**

```bash
kubectl -n "$NS" exec "$CHK_STS-0" -- sh -c 'echo mntr | nc 127.0.0.1 2181' | grep -E 'zk_server_state|zk_znode_count'
```

```text
zk_server_state	leader
zk_znode_count	5
```

A near-empty count here is expected, because this Keeper has never held the real tree.

##### Step 6: Scale ZooKeeper and Keeper down

**Caution:** from here ClickHouse has no coordination store and every `ReplicatedMergeTree` table is read-only until step 9 completes. This is the start of the outage window. Nothing is destroyed, both claims are retained, and you can reverse the step by scaling back up.

**Caution:** between this step and step 11, do not restart the operator pod and do not run `helm upgrade`. Until step 8, either one restarts Keeper while the converter is writing to its volume. After it, an upgrade with ZooKeeper still enabled writes ZooKeeper's hosts back into the CHI, and its hooks cannot run while the tables are read-only.

**Purpose:** the conversion is offline and file-level; both ends must be stopped so the files are consistent and unclaimed.

**Run:**

```bash
kubectl -n "$NS" scale statefulset "$CHK_STS" --replicas=0
kubectl -n "$NS" scale statefulset "$ZK_STS" --replicas=0
```

If ZooKeeper runs more than one replica, this scales all of them; do not leave one up, or it is promoted to leader and keeps writing.

**Expect:**

```text
statefulset.apps/chk-signoz-clickhouse-keeper-cluster-0-0 scaled
statefulset.apps/signoz-zookeeper scaled
```

**Verify:**

```bash
kubectl -n "$NS" get pods | grep -E 'keeper|zookeeper'
```

```text
(no pods)
```

**If it fails:** If a pod will not terminate, do not force-delete a ZooKeeper pod mid-write. Wait for the graceful shutdown. Go to step 6.

##### Step 7: Convert the ZooKeeper data onto the Keeper volume

**Caution:** the Job deletes the contents of `coordination/log`, `coordination/logs` and `coordination/snapshots` on the Keeper claim before writing. That is deliberate: a leftover snapshot or changelog from Keeper's first start can beat the converted snapshot at load time. Only Keeper's own state is deleted; the ZooKeeper volume and ClickHouse's parts are untouched.

**Purpose:** translate the ZooKeeper snapshot plus the transaction logs written after it into one Keeper snapshot on the Keeper volume.

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
Finished, snapshot ZXID 926
Snapshot serialized to path:"/chk/coordination/snapshots/snapshot_24538.bin.zstd"
d41d8cd98f00b204e9800998ecf8427e  /chk/coordination/snapshots/snapshot_24538.bin.zstd
```

A stale snapshot on the ZooKeeper side is fine, because the converter replays the logs written after it; that is where the ZXID in the file name comes from. A log line reading `Totally have 0 snapshots` is a failure: the converter found nothing to read.

**Verify:**

```bash
kubectl -n "$NS" logs job/keeper-converter | grep -c 'coordination/snapshots/snapshot_'
kubectl -n "$NS" delete job keeper-converter
```

The count is `2`: the `Snapshot serialized` line and the `md5sum` line.

**If it fails:** If the Job stays `Pending`, the two claims are not attachable to one node. Both are zonal, so they must sit in the same zone; see step 2. If the converter errors on deserialization, nothing has been repointed; check the ZooKeeper version and go to step 6.

##### Step 8: Bring Keeper up and confirm it loaded the converted tree

**Purpose:** confirm Keeper serves the real ClickHouse tree, not an empty one, before any client is pointed at it.

**Run:**

```bash
kubectl -n "$NS" scale statefulset "$CHK_STS" --replicas=1
kubectl -n "$NS" rollout status statefulset "$CHK_STS" --timeout=300s

kubectl -n "$NS" exec "$CHK_STS-0" -- sh -c 'echo mntr | nc 127.0.0.1 2181' | grep -E 'zk_server_state|zk_znode_count'
```

**Expect:**

```text
zk_server_state	leader
zk_znode_count	1216
```

`zk_znode_count` in the same order of magnitude as the ZooKeeper tree from step 4, not a handful.

**Verify:**

```bash
kubectl -n "$NS" logs "$CHK_STS-0" | grep -iE 'snapshot|Loaded' | tail -5
```

The startup log names the converted snapshot file it loaded.

**If it fails:** If `zk_znode_count` comes back near-empty, Keeper started from its own state instead of the converted snapshot. Nothing is repointed yet, so this is free to redo: scale Keeper back to 0 and go to step 7.

##### Step 9: Repoint ClickHouse at Keeper and restart the pods

**Caution:** the host change reaches ClickHouse as a config reload, and the live session does not move. ClickHouse keeps talking to the old host until the pods restart. Skip the restart and the migration looks like it worked when it has not. This is the last step before ingestion resumes and the last point at which rollback is clean. The host and port must be exactly `$KEEPER_HOST` and `2181`, because step 11 re-renders the same values and must find no difference.

**Purpose:** point ClickHouse at Keeper and force it to open a new session against the converted tree.

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

`host` is `$KEEPER_HOST`, `is_expired` is `0`, `connected_time` is after the restart, and the read-only count is `0`. Note the CHI generation; step 11 checks that it has not changed.

**If it fails:** If `host` still shows ZooKeeper, the pod did not restart; delete it again. If tables are read-only against Keeper, the tree did not carry over; see "Rollback".

##### Step 10: Resume merges and ingestion

**Purpose:** unfreeze the cluster and let ingestion catch up.

**Run:**

```bash
chc "SYSTEM START MERGES"
kubectl -n "$NS" scale deployment "$COLLECTOR_DEPLOY" --replicas="$COLLECTOR_REPLICAS"
```

**Expect:**

```text
Ok.
deployment.apps/signoz-otel-collector scaled
```

**Verify:**

```bash
kubectl -n "$NS" get pods | grep otel-collector
chc "SELECT count() FROM signoz_traces.signoz_index_v3 WHERE timestamp > now() - INTERVAL 5 MINUTE"
```

Collector pods are `Running` and the row count climbs between two runs of the query.

**If it fails:** If the count stays flat while collectors are healthy, re-check the coordination connection with the step 9 verify query.

##### Step 11: Remove ZooKeeper from the release

**Caution:** run this at once after step 10. Until it runs, the live CHI differs from the release, and any `helm upgrade` with `zookeeper.enabled` still `true` writes ZooKeeper's hosts back into the CHI.

**Purpose:** make the release agree with the step 9 patch and remove the ZooKeeper StatefulSet and Services.

**Run:**

In your values file:

```yaml
zookeeper:
  enabled: false
```

```bash
helm upgrade "$RELEASE" signoz/signoz --version 0.150.0 -n "$NS" -f values.yaml
```

The chart renders the same Keeper host the patch set, so the CHI does not change and the operator does nothing. Helm removes the ZooKeeper StatefulSet and its Services, both idle since step 6, and leaves the claim `$ZK_LEADER_PVC`, because Helm never deletes claims.

**Expect:**

```text
Release "signoz" has been upgraded.
```

**Verify:**

```bash
kubectl -n "$NS" get statefulset "$ZK_STS"
kubectl -n "$NS" get pvc "$ZK_LEADER_PVC"
chc "SELECT host FROM system.zookeeper_connection"
kubectl -n "$NS" get chi "$CHI_NAME" -o jsonpath='{.metadata.generation}'
```

The StatefulSet lookup returns `NotFound`, the claim is still `Bound`, `host` is still `$KEEPER_HOST`, and the CHI generation equals the value noted in step 9.

Argo CD users: this is where auto-sync goes back on. The sync must show no change on the CHI.

#### Verification

The migration is complete when all of the following hold.

**Every replica is writable and no session is expired:**

```bash
chc "SELECT count(), countIf(is_readonly), countIf(is_session_expired) FROM system.replicas"
```

```text
56	0	0
```

The first number matches the count recorded in step 4.

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

No rows from the first. Error counters are cumulative since the restart, so check that the second stops climbing rather than that it reads zero.

**Afterwards:**

- The ZooKeeper StatefulSet is gone after step 11; its claim is the rollback asset. Keep the claim until the installation has run a full retention cycle on Keeper, then remove it with `kubectl -n "$NS" delete pvc "$ZK_LEADER_PVC"` (and the other `data-$RELEASE-zookeeper-*` claims if ZooKeeper had replicas).
- To run three Keeper replicas, set `keeper.replicaCount: 3` and `helm upgrade`. The operator adds the replicas and they take the tree from the leader.
- Any later change to the coordination hosts needs the same manual pod restart as step 9.

#### Rollback

**Before step 9**, nothing has been repointed. Scale Keeper back to `0`, scale ZooKeeper back up, and the release is exactly where step 6 left it:

```bash
kubectl -n "$NS" scale statefulset "$CHK_STS" --replicas=0
kubectl -n "$NS" scale statefulset "$ZK_STS" --replicas="$ZK_REPLICAS"
```

**After step 9, before ingestion resumes**, still clean. Patch the CHI back to ZooKeeper, scale ZooKeeper back up, wait for it, and restart the ClickHouse pods. No Helm runs. The ZooKeeper claim was never touched and its state is still current, because writes were frozen in step 3:

```bash
kubectl -n "$NS" patch chi "$CHI_NAME" --type merge -p '{"spec":{"configuration":{"zookeeper":{"nodes":[{"host":"'"$ZK_STS-0.$ZK_STS-headless"'","port":2181}]}}}}'
kubectl -n "$NS" scale statefulset "$ZK_STS" --replicas="$ZK_REPLICAS"
kubectl -n "$NS" rollout status statefulset "$ZK_STS" --timeout=300s

for P in $CH_PODS; do
  kubectl -n "$NS" delete pod "$P"
done
```

With more than one ZooKeeper replica, `nodes` carries one entry per pod: `$ZK_STS-0.$ZK_STS-headless`, `$ZK_STS-1.$ZK_STS-headless`, and so on.

**After ingestion resumes there is no clean rollback**, because new parts are registered in Keeper only and the ZooKeeper state goes stale behind them. Do not point ClickHouse back at ZooKeeper at that stage, because going back means rebuilding coordination anyway.

**Recovery when the tree did not carry over.** If tables came up read-only against an empty Keeper (`Table is in readonly mode since table metadata was not found in zookeeper`, `No node, path /clickhouse/tables/<uuid>/0/log`), the coordination metadata can be rebuilt from the parts already on disk, with no re-ingest and no re-replication. `SYSTEM RESTART REPLICAS` acquires a fresh session and is cluster-wide, run once per server; `SYSTEM RESTORE REPLICA` is what actually writes `/clickhouse/tables/<uuid>/0` back and re-enumerates the active parts, so it runs per table:

```bash
chc "SYSTEM RESTART REPLICAS"

chc "SELECT concat('SYSTEM RESTORE REPLICA ', database, '.', table, ';') FROM system.replicas WHERE is_readonly FORMAT TabSeparatedRaw" \
  | kubectl -n "$NS" exec -i "$CH_POD" -c clickhouse -- clickhouse-client --user "$CH_USER" --password "$CH_PASSWORD" -n

chc "SELECT count() FROM system.replicas WHERE is_readonly"
```

The last query returns `0`. Run this on every ClickHouse pod that reports read-only tables.

#### If you upgraded without `zookeeper.enabled: true`

An install that already has the Keeper CRD and is upgraded with values that drop `zookeeper.enabled` without migrating gets Keeper with an empty tree. Helm has removed the ZooKeeper StatefulSet and Services, the claim `data-<release>-zookeeper-0` is retained, and every replicated table is read-only. No data is lost.

The way back is to turn ZooKeeper on again. In your values file:

```yaml
zookeeper:
  enabled: true
```

```bash
helm upgrade "$RELEASE" signoz/signoz --version 0.150.0 -n "$NS" -f values.yaml --no-hooks
kubectl -n "$NS" rollout status statefulset "$ZK_STS" --timeout=300s

for P in $CH_PODS; do
  kubectl -n "$NS" delete pod "$P"
done
kubectl -n "$NS" wait --for=condition=Ready pod -l clickhouse.altinity.com/chi="$CHI_NAME" --timeout=300s

chc "SELECT host, port, is_expired FROM system.zookeeper_connection"
chc "SELECT count() FROM system.replicas WHERE is_readonly"
```

The schema migrator hook cannot run while the tables are read-only, so this upgrade skips hooks; this is the one place in this document where the flag is used. `host` is the ZooKeeper host and the read-only count is `0`. Then start this guide from step 1 when ready.

#### Getting help

Open an issue on SigNoz/charts with the outputs of steps 4, 7 and 8 and the current `system.zookeeper_connection`. Escalate when replicas stay read-only after `SYSTEM RESTORE REPLICA`. Do not delete the ZooKeeper claims and do not force-delete ZooKeeper pods mid-write; those volumes are the only rollback path.
