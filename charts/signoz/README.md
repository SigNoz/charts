
# SigNoz

![Version: 0.151.0](https://img.shields.io/badge/Version-0.151.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.151.0](https://img.shields.io/badge/AppVersion-v0.151.0-informational?style=flat-square)

SigNoz is an open-source observability platform native to OpenTelemetry with logs, traces and metrics in a single application. An open-source alternative to DataDog, NewRelic, etc. 🔥 🖥. 👉 Open source Application Performance Monitoring (APM) & Observability tool

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

1. Add the `charts.signoz.io` repo, if you haven't already:

   ```bash
   helm repo add signoz https://charts.signoz.io
   ```

2. Update the repo:

   ```bash
   helm repo update signoz
   ```

3. Install the chart with the release name `my-release`:

   ```bash
   helm upgrade --install my-release signoz/signoz \
     --namespace platform \
     --create-namespace
   ```

4. Check that the pods are running:

   ```bash
   kubectl get pods -n platform
   ```

These commands deploy SigNoz in the default configuration. The [Configuration](#configuration) section lists the parameters you can set.

### Uninstalling the chart

To uninstall the chart, delete the release. `helm uninstall` first deletes the ClickHouse resources the chart created, the ClickHouseInstallation and the ClickHouseKeeperInstallation, through the chart's uninstall hook (`hooks.uninstall`), and then removes the release. The hook's objects are created in `clickhouse.namespace`, where the ClickHouse resources are.

The hook deletes both ClickHouse resources whatever annotations they carry. For `helm.sh/resource-policy: keep` on one of them (`clickhouse.annotations`, `keeper.annotations`) to take effect, also set `hooks.uninstall.enabled: false`.

#### Deleting the release

```bash
helm uninstall my-release -n platform
```

The hook waits for ClickHouse to shut down, within Helm's default timeout of 5 minutes. On a large installation, pass a longer one, for example `--timeout 15m`.

#### Without the uninstall hook

With `hooks.uninstall.enabled: false`, `helm uninstall --no-hooks`, or rendered manifests (`helm template`, `kubectl apply`), the hook does not run: delete the ClickHouse resources before the release. The steps follow Altinity's [Uninstalling the Operator](https://docs.altinity.com/altinitykubernetesoperator/quickuninstall/).

> [!IMPORTANT]
> Without the hook, never run `helm uninstall` while the ClickHouse resources exist. `helm uninstall` removes the ClickHouse operator, and only the operator can finish deleting them.

1. With `keeper.enabled: true`, delete the ClickHouseKeeperInstallation (`chk`):

   ```bash
   kubectl delete chk my-release-keeper -n platform
   ```

2. Delete the ClickHouseInstallation (`chi`). This takes a few minutes:

   ```bash
   kubectl delete chi my-release-clickhouse -n platform
   ```

With `clickhouse.namespace` set, use that namespace in both commands. Then delete the release.

#### Deleting the PVCs

The PersistentVolumeClaims (PVCs) stay after the uninstall. The bundled Postgres database returns when you install the release again with the same name and namespace.

```bash
kubectl get pvc -n platform
kubectl delete pvc -n platform --selector app.kubernetes.io/instance=my-release
```

**Deleting the PVCs destroys the data stored on them.**

#### Deleting the CRDs

The four CustomResourceDefinitions (CRDs) of the ClickHouse operator stay after the uninstall. They are cluster-wide: delete them only when no other release in the cluster uses the ClickHouse operator.

```bash
kubectl get crds | grep clickhouse
kubectl delete crd clickhouseinstallations.clickhouse.altinity.com
kubectl delete crd clickhouseinstallationtemplates.clickhouse.altinity.com
kubectl delete crd clickhousekeeperinstallations.clickhouse-keeper.altinity.com
kubectl delete crd clickhouseoperatorconfigurations.clickhouse.altinity.com
```

#### Deleting the namespace

Delete the namespace after the ClickHouse resources are gone. A Namespace created through `clickhouse.namespace` also stays after the uninstall: delete it the same way.

```bash
kubectl delete ns platform
```

#### If `helm uninstall` ran first without the hook

- The ClickHouse resources stay on their finalizers, and their pods keep running.
- A namespace deleted in this state stays `Terminating`.

Clear the finalizers. Kubernetes then removes the resources and their pods:

```bash
kubectl -n platform patch chi my-release-clickhouse --type=merge -p '{"metadata":{"finalizers":null}}'
kubectl -n platform patch chk my-release-keeper --type=merge -p '{"metadata":{"finalizers":null}}'   # with keeper.enabled: true
```

> [!WARNING]
> ### Breaking Changes
> #### Version 1.0.0
> The upgrade notes are in [`UPGRADING.md`](https://github.com/SigNoz/charts/blob/main/charts/signoz/UPGRADING.md), and the steps are in the [upgrade guide](https://signoz.io/docs/operate/migration/upgrade-0-152/).
>
> #### Version 0.131.0
> ClickHouse has been upgraded from `25.5.6` to `25.12.5`. This is a significant ClickHouse version jump, so review the upgrade guide before upgrading to avoid issues with your existing data.
>
> See the [upgrade guide](https://signoz.io/docs/operate/migration/upgrade-0-131) for details.
>
> #### Version 0.116.1
> Support for legacy environment variable by using following values has been removed from the chart templates and users must migrate any custom templates or values that relied on the legacy env behavior:
> - `signoz.configVars` has been remove
> - `signoz.smtpVars` has been removed
> - `signoz.additionalEnvs` has been removed
>
> #### Version 0.113.0
> `schemaMigrator` has been deprecated and replaced by `telemetryStoreMigrator`.
>
> Store migrations are now handled by a single Job using the built-in `migrate` command in `signoz-otel-collector`.
> If you had any overrides in `schemaMigrator`, move them to `telemetryStoreMigrator`. See the [upgrade guide](https://signoz.io/docs/operate/migration/upgrade-0.113) for details.
>
> The following `initContainers` have been removed as they are no longer required:
> - `signoz.initContainers.init`
> - `signoz.initContainers.migration`
> - `otelCollector.initContainers.init`
>
> Otel-collector no longer depends on the migrator Job existing. Readiness is now determined by a ClickHouse-based check (`migrate sync check`). If you had any of these overrides, remove them from your values.
>
> **Helm value reference (v0.113.0)** 
>
> Use the table below when migrating your `values.yaml`.
>  - Keys marked **Replaced** should be moved to the new path.
>  - Keys marked **Deprecated** have no replacement, so remove them from your overrides.
>
> | Key | Status | Replacement |
> | --- | --- | --- |
> | `signoz.initContainers.init` | Deprecated | None |
> | `signoz.initContainers.migration` | Deprecated | None |
> | `otelCollector.initContainers.init` | Deprecated | None |
> | `schemaMigrator.enabled` | Replaced | `telemetryStoreMigrator.enabled` |
> | `schemaMigrator.name` | Replaced | `telemetryStoreMigrator.name` |
> | `schemaMigrator.annotations` | Replaced | `telemetryStoreMigrator.annotations` |
> | `schemaMigrator.upgradeHelmHooks` | Replaced | `telemetryStoreMigrator.upgradeHelmHooks` |
> | `schemaMigrator.enableReplication` | Replaced | `telemetryStoreMigrator.enableReplication` |
> | `schemaMigrator.nodeSelector` | Replaced | `telemetryStoreMigrator.nodeSelector` |
> | `schemaMigrator.tolerations` | Replaced | `telemetryStoreMigrator.tolerations` |
> | `schemaMigrator.affinity` | Replaced | `telemetryStoreMigrator.affinity` |
> | `schemaMigrator.topologySpreadConstraints` | Replaced | `telemetryStoreMigrator.topologySpreadConstraints` |
> | `schemaMigrator.resources` | Replaced | `telemetryStoreMigrator.resources` |
> | `schemaMigrator.serviceAccount` | Replaced | `telemetryStoreMigrator.serviceAccount` |
> | `schemaMigrator.image` | Deprecated | None (uses otel-collector image) |
> | `schemaMigrator.args` | Deprecated | None |
> | `schemaMigrator.initContainers` | Deprecated | None |
> | `schemaMigrator.role` | Deprecated | None |
>
> #### Version 0.89.0
> After August 28, 2025, Bitnami will require paid subscriptions for their image updates. SigNoz utilises Bitnami container images and Helm charts for Zookeeper.
>
> To ensure continued stability, we have migrated the Zookeeper Images and Charts to our own repositories.
>
> You must upgrade to SigNoz `v0.89.0` to avoid any service interruption.
> More details are available in [Issue #731](https://github.com/SigNoz/charts/issues/731)
> #### Version 0.88.0
> **Configuration Migration Required:**
> - `signoz.configVars` has been deprecated
> - `signoz.smtpVars` has been deprecated
> - `signoz.additionalEnvs` has been deprecated
> These configuration options must now be specified under `signoz.env` instead.
>
> Refer to the official [documentation](https://github.com/SigNoz/signoz/blob/main/conf/example.yaml) for a complete list of env variables.
> <br/> Note on Variable Naming: Environment variables are derived from the YAML configuration.
> <br/> For example, a key `address` for `smtp` under the `emailing` section becomes `signoz_emailing_smtp_address`.
>
> **Before:**
> ```yaml
> signoz:
>  configVars:
>    storage: clickhouse
>  smtpVars:
>    existingSecret:
>      name: my-secret-name
>      hostKey: my-smtp-host-key
>      portKey: my-smtp-port-key
> ```
>
> **After:**
> ```yaml
> signoz:
>  env:
>    storage: clickhouse
>    signoz_emailing_smtp_address:
>      valueFrom:
>        secretKeyRef:
>          name: my-secret-name
>          key: my-smtp-address-key
> ```

### ClickHouse operator

The ClickHouse operator comes from Altinity's `altinity-clickhouse-operator` chart, installed as a dependency of this chart.
Its values live under `altinity-clickhouse-operator.*`, in Altinity's own format, and are not listed in the tables below.
See [Altinity's chart](https://github.com/Altinity/clickhouse-operator/tree/master/deploy/helm/clickhouse-operator) for the full list.

## Values

<h3>Global Settings</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="global"><a href="./values.yaml#L3">global</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cloud: other
clusterDomain: cluster.local
clusterName: ""
imagePullSecrets: []
imageRegistry: null
storageClass: null</pre>
</div>
            </td>
            <td>Global override values for the chart.</td>
        </tr>
        <tr>
            <td id="global--imageRegistry"><a href="./values.yaml#L7">global.imageRegistry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Global image registry override. Not applied to the `altinity-clickhouse-operator` subchart and `postgresql` images.</td>
        </tr>
        <tr>
            <td id="global--imagePullSecrets"><a href="./values.yaml#L10">global.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Global image pull secrets, as a list of Secret names. Not applied to the `altinity-clickhouse-operator` subchart.</td>
        </tr>
        <tr>
            <td id="global--storageClass"><a href="./values.yaml#L15">global.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>StorageClass of the SigNoz, ClickHouse and ZooKeeper PVCs. When set, it overrides their own `persistence.storageClass`. When neither is set, the PVCs use the cluster's default StorageClass. `-` renders an empty `storageClassName`, which disables dynamic provisioning.</td>
        </tr>
        <tr>
            <td id="global--clusterDomain"><a href="./values.yaml#L20">global.clusterDomain</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster.local</pre>
</div>
            </td>
            <td>Kubernetes cluster domain. ClickHouse, its operator and ZooKeeper build their Pods' host names on it, as does the address of a component in another namespace.</td>
        </tr>
        <tr>
            <td id="global--clusterName"><a href="./values.yaml#L25">global.clusterName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Kubernetes cluster name. The resource detection processor attaches it to telemetry data.</td>
        </tr>
        <tr>
            <td id="global--cloud"><a href="./values.yaml#L32">global.cloud</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">other</pre>
</div>
            </td>
            <td>Cloud provider and distribution of the Kubernetes cluster. One of `aws`, `azure`, `gcp`, `gcp/autogke`, `hcloud` or `other`. The chart selects the StorageClass for PersistentVolumes from this value. With `aws` or `gcp` and `installCustomStorageClass` enabled, the chart creates an expandable StorageClass.</td>
        </tr>
    </tbody>
</table>
<h3>General Settings</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="nameOverride"><a href="./values.yaml#L36">nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Override the chart name.</td>
        </tr>
        <tr>
            <td id="fullnameOverride"><a href="./values.yaml#L40">fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Override the full resource name.</td>
        </tr>
        <tr>
            <td id="clusterName"><a href="./values.yaml#L44">clusterName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the Kubernetes cluster, which the SigNoz collectors attach to telemetry data.</td>
        </tr>
        <tr>
            <td id="imagePullSecrets"><a href="./values.yaml#L47">imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets, as a list of Secret names. Not applied to the `altinity-clickhouse-operator` and `zookeeper` subcharts.</td>
        </tr>
    </tbody>
</table>
<h3>Hooks</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="hooks--uninstall--enabled"><a href="./values.yaml#L62">hooks.uninstall.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Run a pre-delete hook Job that deletes the ClickHouseInstallation and the ClickHouseKeeperInstallation while the operator still runs, so that `helm uninstall` completes.</td>
        </tr>
        <tr>
            <td id="hooks--uninstall--image--repository"><a href="./values.yaml#L67">hooks.uninstall.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">registry.k8s.io/kubectl</pre>
</div>
            </td>
            <td>Image repository.</td>
        </tr>
        <tr>
            <td id="hooks--uninstall--image--tag"><a href="./values.yaml#L71">hooks.uninstall.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v1.36.3</pre>
</div>
            </td>
            <td>Image tag.</td>
        </tr>
        <tr>
            <td id="hooks--uninstall--image--pullPolicy"><a href="./values.yaml#L74">hooks.uninstall.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Image pull policy.</td>
        </tr>
        <tr>
            <td id="hooks--uninstall--resources"><a href="./values.yaml#L77">hooks.uninstall.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
        <tr>
            <td id="hooks--uninstall--nodeSelector"><a href="./values.yaml#L80">hooks.uninstall.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node labels for pod assignment.</td>
        </tr>
        <tr>
            <td id="hooks--uninstall--tolerations"><a href="./values.yaml#L83">hooks.uninstall.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="hooks--uninstall--affinity"><a href="./values.yaml#L86">hooks.uninstall.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for pod assignment.</td>
        </tr>
        <tr>
            <td id="hooks--uninstall--topologySpreadConstraints"><a href="./values.yaml#L90">hooks.uninstall.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod assignment. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/</td>
        </tr>
        <tr>
            <td id="hooks--uninstall--priorityClassName"><a href="./values.yaml#L93">hooks.uninstall.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class of the pod.</td>
        </tr>
        <tr>
            <td id="hooks--uninstall--podSecurityContext"><a href="./values.yaml#L97">hooks.uninstall.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="hooks--uninstall--containerSecurityContext"><a href="./values.yaml#L101">hooks.uninstall.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
    </tbody>
</table>
<h3>ClickHouse</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="clickhouse"><a href="./values.yaml#L106">clickhouse</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>The ClickHouse this chart installs, a ClickHouseInstallation that the operator from `altinity-clickhouse-operator` reconciles.</td>
        </tr>
        <tr>
            <td id="clickhouse--enabled"><a href="./values.yaml#L111">clickhouse.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Install ClickHouse, with the operator and ZooKeeper it needs. When false, every component connects to `externalClickhouse` instead, and `externalClickhouse.host` must be set.</td>
        </tr>
        <tr>
            <td id="clickhouse--name"><a href="./values.yaml#L114">clickhouse.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">clickhouse</pre>
</div>
            </td>
            <td>Value of the `app.kubernetes.io/component` label on the ClickHouse objects and Pods.</td>
        </tr>
        <tr>
            <td id="clickhouse--nameOverride"><a href="./values.yaml#L118">clickhouse.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Replaces `clickhouse` in the ClickHouse name `<release>-clickhouse` and in its `app.kubernetes.io/name` label.</td>
        </tr>
        <tr>
            <td id="clickhouse--fullnameOverride"><a href="./values.yaml#L123">clickhouse.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the ClickHouseInstallation and its Service in place of `<release>-clickhouse`, and the prefix of its other objects. At most 34 characters.</td>
        </tr>
        <tr>
            <td id="clickhouse--namespace"><a href="./values.yaml#L145">clickhouse.namespace</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Namespace of the ClickHouseInstallation. Empty means the release namespace. Any other value makes the chart create that namespace and keep it on uninstall (`helm.sh/resource-policy: keep`), and needs the operator pointed at it.
For a namespace `clickhouse`, either run the operator there:

  ```yaml
  altinity-clickhouse-operator:
    namespaceOverride: clickhouse
  ```

or keep it in the release namespace with the rights to watch that one:

  ```yaml
  altinity-clickhouse-operator:
    watchNamespaces: [clickhouse]
    rbac:
      namespaceScoped: false
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--image"><a href="./values.yaml#L148">clickhouse.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">pullPolicy: IfNotPresent
repository: clickhouse/clickhouse-server
tag: 25.12.5</pre>
</div>
            </td>
            <td>Image of the ClickHouse container, also run by the histogramQuantile download init container.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--repository"><a href="./values.yaml#L152">clickhouse.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">clickhouse/clickhouse-server</pre>
</div>
            </td>
            <td>Image repository, optionally prefixed with a registry. `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--tag"><a href="./values.yaml#L156">clickhouse.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">25.12.5</pre>
</div>
            </td>
            <td>Image tag. SigNoz is tested against the default.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--pullPolicy"><a href="./values.yaml#L160">clickhouse.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Image pull policy.</td>
        </tr>
        <tr>
            <td id="clickhouse--imagePullSecrets"><a href="./values.yaml#L163">clickhouse.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for the ClickHouse Pod and the operator-upgrade hook Pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--layout"><a href="./values.yaml#L169">clickhouse.layout</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">replicasCount: 1
shardsCount: 1</pre>
</div>
            </td>
            <td>Shards and replicas of the ClickHouse cluster (experimental), the operator's cluster `layout` rendered as given: https://github.com/Altinity/clickhouse-operator/blob/master/docs/custom_resource_explained.md</td>
        </tr>
        <tr>
            <td id="clickhouse--cluster"><a href="./values.yaml#L175">clickhouse.cluster</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster</pre>
</div>
            </td>
            <td>Name of the ClickHouse cluster, which the migrator creates SigNoz's tables on and SigNoz queries.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount"><a href="./values.yaml#L178">clickhouse.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
create: true
name: null</pre>
</div>
            </td>
            <td>ClickHouse ServiceAccount configuration.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount--create"><a href="./values.yaml#L182">clickhouse.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Create a ServiceAccount for the ClickHouse Pod. When false the Pod runs as `name`, or as `default` when `name` is empty.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount--annotations"><a href="./values.yaml#L186">clickhouse.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ServiceAccount.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount--name"><a href="./values.yaml#L190">clickhouse.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of the ServiceAccount to create (empty: the ClickHouse name), or of an existing one to run as when `create` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--labels"><a href="./values.yaml#L193">clickhouse.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the ClickHouseInstallation.</td>
        </tr>
        <tr>
            <td id="clickhouse--annotations"><a href="./values.yaml#L197">clickhouse.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ClickHouseInstallation.</td>
        </tr>
        <tr>
            <td id="clickhouse--pod--labels"><a href="./values.yaml#L202">clickhouse.pod.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Pod. A key named like a selector label (`app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/component`) is ignored.</td>
        </tr>
        <tr>
            <td id="clickhouse--pod--annotations"><a href="./values.yaml#L207">clickhouse.pod.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io/scrape, signoz.io/port and signoz.io/path for the metrics endpoint</pre>
</div>
            </td>
            <td>Annotations to add to the Pod. The `signoz.io/*` defaults make the SigNoz collectors scrape the metrics endpoint set in `clickhouse.settings`.</td>
        </tr>
        <tr>
            <td id="clickhouse--service"><a href="./values.yaml#L213">clickhouse.service</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
httpPort: 8123
tcpPort: 9000
type: ClusterIP</pre>
</div>
            </td>
            <td>ClickHouse Service configuration.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--annotations"><a href="./values.yaml#L217">clickhouse.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Service.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--type"><a href="./values.yaml#L221">clickhouse.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>Type of the ClickHouse Service. `LoadBalancer` or `NodePort` exposes ClickHouse outside the cluster.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--httpPort"><a href="./values.yaml#L225">clickhouse.service.httpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8123</pre>
</div>
            </td>
            <td>HTTP port of the ClickHouse Service, which the components connect to.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--tcpPort"><a href="./values.yaml#L229">clickhouse.service.tcpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">9000</pre>
</div>
            </td>
            <td>Native TCP port of the ClickHouse Service, which SigNoz, the collector and the migrator connect to.</td>
        </tr>
        <tr>
            <td id="clickhouse--database"><a href="./values.yaml#L233">clickhouse.database</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_metrics</pre>
</div>
            </td>
            <td>Database the collector writes metrics to.</td>
        </tr>
        <tr>
            <td id="clickhouse--traceDatabase"><a href="./values.yaml#L237">clickhouse.traceDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_traces</pre>
</div>
            </td>
            <td>Database the collector writes traces to.</td>
        </tr>
        <tr>
            <td id="clickhouse--logDatabase"><a href="./values.yaml#L241">clickhouse.logDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_logs</pre>
</div>
            </td>
            <td>Database the collector writes logs to.</td>
        </tr>
        <tr>
            <td id="clickhouse--meterDatabase"><a href="./values.yaml#L245">clickhouse.meterDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_meter</pre>
</div>
            </td>
            <td>Database the collector writes meter data to.</td>
        </tr>
        <tr>
            <td id="clickhouse--user"><a href="./values.yaml#L249">clickhouse.user</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">admin</pre>
</div>
            </td>
            <td>ClickHouse user the installation creates and every component connects as.</td>
        </tr>
        <tr>
            <td id="clickhouse--password"><a href="./values.yaml#L254">clickhouse.password</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">27ff0399-0d3a-4bd8-919d-17c2181e6fb9</pre>
</div>
            </td>
            <td>Password of `clickhouse.user`, stored in the Secret `<clickhouse.fullname>-credentials`. Ignored when `clickhouse.existingSecret` is set. It must not contain `/`, `?` or `#`, and a `%` is read as an escape. A change does not restart the Pods.</td>
        </tr>
        <tr>
            <td id="clickhouse--existingSecret"><a href="./values.yaml#L259">clickhouse.existingSecret</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of a Secret you created that holds the password of `clickhouse.user`. When set, the chart creates no Secret. With `clickhouse.namespace` set to another namespace, the Secret must exist there and in the release namespace.</td>
        </tr>
        <tr>
            <td id="clickhouse--existingSecretPasswordKey"><a href="./values.yaml#L263">clickhouse.existingSecretPasswordKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">password</pre>
</div>
            </td>
            <td>Key of the password inside `clickhouse.existingSecret`.</td>
        </tr>
        <tr>
            <td id="clickhouse--existingSecretPasswordSha256Key"><a href="./values.yaml#L269">clickhouse.existingSecretPasswordSha256Key</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Key of the password's SHA-256 hex inside `clickhouse.existingSecret`. When empty, the password must not contain `&`, `<` or an `&name;` sequence. Create the hash with `printf '%s' "$PASSWORD" | sha256sum | cut -d' ' -f1`.</td>
        </tr>
        <tr>
            <td id="clickhouse--secure"><a href="./values.yaml#L273">clickhouse.secure</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Passed as `CLICKHOUSE_SECURE` to the Pods that connect to ClickHouse.</td>
        </tr>
        <tr>
            <td id="clickhouse--verify"><a href="./values.yaml#L277">clickhouse.verify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Passed as `CLICKHOUSE_VERIFY` to the Pods that connect to ClickHouse.</td>
        </tr>
        <tr>
            <td id="clickhouse--allowedNetworkIps"><a href="./values.yaml#L281">clickhouse.allowedNetworkIps</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- 10.0.0.0/8
- 100.64.0.0/10
- 172.16.0.0/12
- 192.0.0.0/24
- 198.18.0.0/15
- 192.168.0.0/16</pre>
</div>
            </td>
            <td>Networks `clickhouse.user` may connect from, as addresses or CIDR ranges. The defaults are the private ranges. Add any other range a client connects from.</td>
        </tr>
        <tr>
            <td id="clickhouse--externalZookeeper"><a href="./values.yaml#L301">clickhouse.externalZookeeper</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ZooKeeper that ClickHouse coordinates through instead of the bundled store, ClickHouse Keeper or ZooKeeper, whichever is on. Set that store's own `enabled` (`keeper.enabled`, `zookeeper.enabled`) to false with it, or the bundled store is still installed.
One `servers` entry per ZooKeeper node:

  ```yaml
  servers:
    - host: signoz-signoz-zookeeper
      port: 2181
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--profiles"><a href="./values.yaml#L313">clickhouse.profiles</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ClickHouse settings profiles, one key per profile and setting. They override `defaultProfiles`. Settings: https://clickhouse.com/docs/en/operations/settings/settings/
A 40 GB memory cap on each query run under the default profile:

  ```yaml
  default/max_memory_usage: 40000000000
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--defaultProfiles"><a href="./values.yaml#L317">clickhouse.defaultProfiles</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Profile settings SigNoz's queries rely on. `clickhouse.profiles` overrides a single setting.</td>
        </tr>
        <tr>
            <td id="clickhouse--settings"><a href="./values.yaml#L335">clickhouse.settings</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>ClickHouse server settings, keyed by their path in the server config. They override `defaultSettings`. The `prometheus/*` defaults serve the metrics that `clickhouse.pod.annotations` point at. Settings: https://clickhouse.com/docs/en/operations/server-configuration-parameters/settings
Debug logging, the `level` setting under `logger`:

  ```yaml
  logger/level: debug
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--defaultSettings"><a href="./values.yaml#L345">clickhouse.defaultSettings</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">format_schema_path: /etc/clickhouse-server/config.d/
user_defined_executable_functions_config: /etc/clickhouse-server/functions/custom-functions.xml
user_scripts_path: /var/lib/clickhouse/user_scripts/</pre>
</div>
            </td>
            <td>Server settings that load the histogramQuantile function and set the format schema directory. `clickhouse.settings` overrides a single setting.</td>
        </tr>
        <tr>
            <td id="clickhouse--files"><a href="./values.yaml#L362">clickhouse.files</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>ClickHouse configuration files, keyed by path. Files under `config.d/` merge into the server config.
A file that sets the server name clickhouse-client shows in its prompt:

  ```yaml
  config.d/display_name.xml: |
    <clickhouse>
      <display_name>signoz</display_name>
    </clickhouse>
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--templates"><a href="./values.yaml#L409">clickhouse.templates</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">volumeClaimTemplates: []</pre>
</div>
            </td>
            <td>Volume claim templates of the ClickHouse installation, used only when `clickhouse.persistence.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--templates--volumeClaimTemplates"><a href="./values.yaml#L427">clickhouse.templates.volumeClaimTemplates</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Volume claim templates added when `persistence.enabled` is false. Mount each through `clickhouse.extraVolumeMounts` under the same `name`. Without a mount at `/var/lib/clickhouse` the data is not kept.
Each entry takes these four fields, here a 50Gi PVC named `data`:

  ```yaml
  - name: data
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 50Gi
    storageClassName: standard
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--podDistribution"><a href="./values.yaml#L432">clickhouse.podDistribution</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Operator rules that spread the ClickHouse Pods across nodes, rendered as given. Types: https://github.com/Altinity/clickhouse-operator/blob/1414503921da3ae475eb6f9a296d3475a6993768/docs/chi-examples/99-clickhouseinstallation-max.yaml#L428-L481</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage"><a href="./values.yaml#L444">clickhouse.coldStorage</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>S3 or GCS disk added as the `s3` volume of a `tiered` storage policy, where SigNoz's retention settings move older data.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--enabled"><a href="./values.yaml#L448">clickhouse.coldStorage.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable cold storage on S3 or Google Cloud Storage (GCS).</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--defaultKeepFreeSpaceBytes"><a href="./values.yaml#L452">clickhouse.coldStorage.defaultKeepFreeSpaceBytes</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"10485760"</pre>
</div>
            </td>
            <td>Free space to keep on the default disk, in bytes.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--type"><a href="./values.yaml#L456">clickhouse.coldStorage.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">s3</pre>
</div>
            </td>
            <td>Type of cold storage: `s3` or `gcs`.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--endpoint"><a href="./values.yaml#L473">clickhouse.coldStorage.endpoint</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">https://<bucket-name>.s3-<region>.amazonaws.com/data/</pre>
</div>
            </td>
            <td>Bucket URL including the path ClickHouse writes under.
An S3 bucket:

  ```yaml
  endpoint: https://my-bucket.s3-us-east-1.amazonaws.com/data/
  ```

or a GCS bucket:

  ```yaml
  endpoint: https://storage.googleapis.com/my-bucket/data/
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--accessKey"><a href="./values.yaml#L478">clickhouse.coldStorage.accessKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml"><access_key_id></pre>
</div>
            </td>
            <td>Access key ID for S3 or GCS. ClickHouse uses it for `gcs`, and for `s3` when `role.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--secretAccess"><a href="./values.yaml#L483">clickhouse.coldStorage.secretAccess</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml"><secret_access_key></pre>
</div>
            </td>
            <td>Secret access key for S3 or GCS. ClickHouse uses it for `gcs`, and for `s3` when `role.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--role"><a href="./values.yaml#L486">clickhouse.coldStorage.role</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::******:role/*****
enabled: false</pre>
</div>
            </td>
            <td>AWS IAM role that gives ClickHouse access to the `s3` bucket in place of `accessKey` and `secretAccess`.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--role--enabled"><a href="./values.yaml#L490">clickhouse.coldStorage.role.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Use the role for `s3`: ClickHouse takes credentials from its environment instead of `accessKey` and `secretAccess`.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--role--annotations"><a href="./values.yaml#L493">clickhouse.coldStorage.role.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">eks.amazonaws.com/role-arn: arn:aws:iam::******:role/*****</pre>
</div>
            </td>
            <td>ServiceAccount annotations that bind the role, added when `coldStorage.enabled` and `role.enabled` are both true.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs"><a href="./values.yaml#L499">clickhouse.logs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Sidecar collector in the ClickHouse Pod that sends `system.query_log` entries as logs to an OTLP receiver on the node's port 4317, such as the k8s-infra agent.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--enabled"><a href="./values.yaml#L503">clickhouse.logs.system.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Collect ClickHouse system table entries as logs.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--image--repository"><a href="./values.yaml#L508">clickhouse.logs.system.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/signoz-otel-collector</pre>
</div>
            </td>
            <td>Image repository, optionally prefixed with a registry. `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--image--tag"><a href="./values.yaml#L512">clickhouse.logs.system.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v0.144.15</pre>
</div>
            </td>
            <td>Tag of the system logs sidecar image.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--image--pullPolicy"><a href="./values.yaml#L516">clickhouse.logs.system.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Pull policy of the system logs sidecar image.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--resources"><a href="./values.yaml#L520">clickhouse.logs.system.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--env"><a href="./values.yaml#L523">clickhouse.logs.system.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for the container. An entry named like one the chart sets replaces it.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--envFrom"><a href="./values.yaml#L526">clickhouse.logs.system.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Sources of extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--extraVolumeMounts"><a href="./values.yaml#L529">clickhouse.logs.system.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the container. Their volumes come from `clickhouse.extraVolumes`.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--config"><a href="./values.yaml#L533">clickhouse.logs.system.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Configuration of the sidecar collector, rendered as given into its config file.</td>
        </tr>
        <tr>
            <td id="clickhouse--installCustomStorageClass"><a href="./values.yaml#L583">clickhouse.installCustomStorageClass</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create an expandable StorageClass: `gp2-resizable` when `global.cloud` starts with `aws`, `gce-resizable` when it starts with `gcp`. No volume uses it until `clickhouse.persistence.storageClass` names it.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook"><a href="./values.yaml#L588">clickhouse.operatorUpgradeHook</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Pre-upgrade hook Job that deletes the operator Deployment an older chart created. When disabled, delete that Deployment before upgrading: `kubectl delete deployment <release>-clickhouse-operator -n <namespace>`.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--enabled"><a href="./values.yaml#L591">clickhouse.operatorUpgradeHook.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Run the hook on `helm upgrade`.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--repository"><a href="./values.yaml#L595">clickhouse.operatorUpgradeHook.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">registry.k8s.io/kubectl</pre>
</div>
            </td>
            <td>Image repository, optionally prefixed with a registry. `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--tag"><a href="./values.yaml#L598">clickhouse.operatorUpgradeHook.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v1.36.3</pre>
</div>
            </td>
            <td>Tag of the kubectl image. The image publishes no `latest` tag.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--pullPolicy"><a href="./values.yaml#L601">clickhouse.operatorUpgradeHook.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Pull policy of the kubectl image.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--backoffLimit"><a href="./values.yaml#L604">clickhouse.operatorUpgradeHook.backoffLimit</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3</pre>
</div>
            </td>
            <td>Retries before the Job, and with it the upgrade, is marked failed.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--resources"><a href="./values.yaml#L607">clickhouse.operatorUpgradeHook.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resources of the hook container.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--nodeSelector"><a href="./values.yaml#L610">clickhouse.operatorUpgradeHook.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node labels for Pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--tolerations"><a href="./values.yaml#L613">clickhouse.operatorUpgradeHook.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for Pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--affinity"><a href="./values.yaml#L616">clickhouse.operatorUpgradeHook.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for Pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--topologySpreadConstraints"><a href="./values.yaml#L620">clickhouse.operatorUpgradeHook.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for Pod assignment. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--priorityClassName"><a href="./values.yaml#L623">clickhouse.operatorUpgradeHook.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>PriorityClass of the Pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--podSecurityContext"><a href="./values.yaml#L627">clickhouse.operatorUpgradeHook.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the Pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--containerSecurityContext"><a href="./values.yaml#L631">clickhouse.operatorUpgradeHook.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--enabled"><a href="./values.yaml#L637">clickhouse.udf.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Download the histogramQuantile binary from GitHub in an init container. SigNoz's histogram percentile queries call it. When false, supply the binary through `clickhouse.extraInitContainers`.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--command"><a href="./values.yaml#L641">clickhouse.udf.command</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Command of the histogramQuantile download init container.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--env"><a href="./values.yaml#L672">clickhouse.udf.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for the container.
A proxy for the download, and a credential from a Secret for a mirror that `command` fetches from:

  ```yaml
  - name: https_proxy
    value: http://proxy.example.com:3128
  - name: MIRROR_TOKEN
    valueFrom:
      secretKeyRef:
        name: mirror-credentials
        key: token
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--envFrom"><a href="./values.yaml#L676">clickhouse.udf.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Sources of extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--resources"><a href="./values.yaml#L680">clickhouse.udf.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--extraVolumeMounts"><a href="./values.yaml#L683">clickhouse.udf.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the container. Their volumes come from `clickhouse.extraVolumes`.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraInitContainers"><a href="./values.yaml#L688">clickhouse.extraInitContainers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra init containers for the Pod, run after the histogramQuantile download. The user scripts volume is `shared-binary-volume`, mounted at `/var/lib/clickhouse/user_scripts`.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraContainers"><a href="./values.yaml#L691">clickhouse.extraContainers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra containers for the Pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--startupProbe"><a href="./values.yaml#L706">clickhouse.startupProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Startup probe for the container. `null` renders none. A handler other than `httpGet` must also set `httpGet: null`. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
A TCP check on the native port in place of the HTTP one:

  ```yaml
  httpGet: null
  tcpSocket:
    port: 9000
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--livenessProbe"><a href="./values.yaml#L729">clickhouse.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Liveness probe for the container. `null` renders none. A handler other than `httpGet` must also set `httpGet: null`. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
A TCP check on the native port in place of the HTTP one:

  ```yaml
  httpGet: null
  tcpSocket:
    port: 9000
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--readinessProbe"><a href="./values.yaml#L752">clickhouse.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Readiness probe for the container. `null` renders none. A handler other than `httpGet` must also set `httpGet: null`. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
A TCP check on the native port in place of the HTTP one:

  ```yaml
  httpGet: null
  tcpSocket:
    port: 9000
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--resources"><a href="./values.yaml#L763">clickhouse.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">requests:
    cpu: 100m
    memory: 200Mi</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
        <tr>
            <td id="clickhouse--podSecurityContext"><a href="./values.yaml#L774">clickhouse.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">fsGroup: 101
fsGroupChangePolicy: OnRootMismatch
runAsGroup: 101
runAsUser: 101</pre>
</div>
            </td>
            <td>Security context for the Pod. `null` renders none, and `{}` keeps the defaults. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="clickhouse--containerSecurityContext"><a href="./values.yaml#L795">clickhouse.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for every container of the ClickHouse Pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
The restricted profile ClickHouse runs under:

  ```yaml
  allowPrivilegeEscalation: false
  capabilities:
    drop: [ALL]
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--priorityClassName"><a href="./values.yaml#L798">clickhouse.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>PriorityClass of the Pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--nodeSelector"><a href="./values.yaml#L802">clickhouse.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node labels for Pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--tolerations"><a href="./values.yaml#L806">clickhouse.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for Pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--affinity"><a href="./values.yaml#L810">clickhouse.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for Pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--topologySpreadConstraints"><a href="./values.yaml#L814">clickhouse.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for Pod assignment. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence"><a href="./values.yaml#L817">clickhouse.persistence</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">accessModes:
    - ReadWriteOnce
enabled: true
existingClaim: ""
size: 20Gi
storageClass: null</pre>
</div>
            </td>
            <td>ClickHouse persistence configuration.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--enabled"><a href="./values.yaml#L822">clickhouse.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Keep ClickHouse data on a PersistentVolumeClaim. When false, the data lives in an `emptyDir` and is lost with the Pod, unless `clickhouse.templates.volumeClaimTemplates` provides volumes.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--existingClaim"><a href="./values.yaml#L826">clickhouse.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of a PersistentVolumeClaim you created for the ClickHouse data, used instead of a PVC from the template.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--storageClass"><a href="./values.yaml#L831">clickhouse.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>StorageClass of the ClickHouse data PVC. `-` disables dynamic provisioning, null uses the cluster default, and `global.storageClass` overrides it.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--accessModes"><a href="./values.yaml#L836">clickhouse.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access modes of the PVC. Ref: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--size"><a href="./values.yaml#L841">clickhouse.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">20Gi</pre>
</div>
            </td>
            <td>Size of the PVC.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraVolumes"><a href="./values.yaml#L844">clickhouse.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the Pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraVolumeMounts"><a href="./values.yaml#L847">clickhouse.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the container.</td>
        </tr>
        <tr>
            <td id="clickhouse--env"><a href="./values.yaml#L850">clickhouse.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for the container. Names starting with `CONFIGURATION_` belong to the operator.</td>
        </tr>
        <tr>
            <td id="clickhouse--envFrom"><a href="./values.yaml#L853">clickhouse.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Sources of extra environment variables for the container.</td>
        </tr>
    </tbody>
</table>
<h3>ClickHouse Keeper</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="keeper--enabled"><a href="./values.yaml#L860">keeper.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Install Keeper.</td>
        </tr>
        <tr>
            <td id="keeper--name"><a href="./values.yaml#L863">keeper.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">keeper</pre>
</div>
            </td>
            <td>Name of the ClickHouse Keeper component, the `app.kubernetes.io/name` label of its objects. `keeper.nameOverride` takes precedence.</td>
        </tr>
        <tr>
            <td id="keeper--nameOverride"><a href="./values.yaml#L866">keeper.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Override the chart name.</td>
        </tr>
        <tr>
            <td id="keeper--fullnameOverride"><a href="./values.yaml#L870">keeper.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Override the full resource name, the name of the ClickHouseKeeperInstallation. With the default name, the release name can have at most 27 characters.</td>
        </tr>
        <tr>
            <td id="keeper--image--repository"><a href="./values.yaml#L874">keeper.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">clickhouse/clickhouse-keeper</pre>
</div>
            </td>
            <td>Image repository, optionally prefixed with a registry. `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="keeper--image--tag"><a href="./values.yaml#L878">keeper.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">25.12.5</pre>
</div>
            </td>
            <td>Image tag. It does not follow `clickhouse.image.tag`. A Keeper restart drops every ClickHouse session.</td>
        </tr>
        <tr>
            <td id="keeper--image--pullPolicy"><a href="./values.yaml#L881">keeper.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Image pull policy.</td>
        </tr>
        <tr>
            <td id="keeper--imagePullSecrets"><a href="./values.yaml#L884">keeper.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for the Keeper Pod.</td>
        </tr>
        <tr>
            <td id="keeper--replicaCount"><a href="./values.yaml#L887">keeper.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Number of replicas. Keeper needs a majority of its replicas to work.</td>
        </tr>
        <tr>
            <td id="keeper--labels"><a href="./values.yaml#L890">keeper.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the ClickHouseKeeperInstallation. A key that names a chart label replaces its value.</td>
        </tr>
        <tr>
            <td id="keeper--annotations"><a href="./values.yaml#L893">keeper.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ClickHouseKeeperInstallation.</td>
        </tr>
        <tr>
            <td id="keeper--pod--labels"><a href="./values.yaml#L898">keeper.pod.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Pod. A key named like a selector label (`app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/component`) is ignored.</td>
        </tr>
        <tr>
            <td id="keeper--pod--annotations"><a href="./values.yaml#L903">keeper.pod.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Annotations to add to the Pod. Set a key to `null` to drop a default. `signoz.io/port` must equal `prometheus/port` in `keeper.settings`.</td>
        </tr>
        <tr>
            <td id="keeper--settings"><a href="./values.yaml#L911">keeper.settings</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>ClickHouse Keeper server settings. Set a key to `null` to drop a default. `prometheus/port` must equal the `signoz.io/port` annotation in `keeper.pod.annotations`.</td>
        </tr>
        <tr>
            <td id="keeper--podSecurityContext"><a href="./values.yaml#L927">keeper.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Security context for the Pod. `null` renders none, and `{}` keeps the defaults. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="keeper--containerSecurityContext"><a href="./values.yaml#L933">keeper.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">no container security context</pre>
</div>
            </td>
            <td>Security context for the container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="keeper--env"><a href="./values.yaml#L936">keeper.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="keeper--envFrom"><a href="./values.yaml#L939">keeper.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Sources of extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="keeper--extraVolumes"><a href="./values.yaml#L942">keeper.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the Pod.</td>
        </tr>
        <tr>
            <td id="keeper--extraVolumeMounts"><a href="./values.yaml#L945">keeper.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the container.</td>
        </tr>
        <tr>
            <td id="keeper--resources"><a href="./values.yaml#L949">keeper.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
        <tr>
            <td id="keeper--priorityClassName"><a href="./values.yaml#L956">keeper.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">no PriorityClass</pre>
</div>
            </td>
            <td>PriorityClass of the Pod.</td>
        </tr>
        <tr>
            <td id="keeper--nodeSelector"><a href="./values.yaml#L959">keeper.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node labels for Pod assignment.</td>
        </tr>
        <tr>
            <td id="keeper--tolerations"><a href="./values.yaml#L962">keeper.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for Pod assignment.</td>
        </tr>
        <tr>
            <td id="keeper--affinity"><a href="./values.yaml#L965">keeper.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for Pod assignment.</td>
        </tr>
        <tr>
            <td id="keeper--topologySpreadConstraints"><a href="./values.yaml#L969">keeper.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for Pod assignment. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/</td>
        </tr>
        <tr>
            <td id="keeper--podDistribution"><a href="./values.yaml#L972">keeper.podDistribution</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topologies for distributing the ClickHouse Keeper Pods, in the operator's `podDistribution` format.</td>
        </tr>
        <tr>
            <td id="keeper--persistence--accessModes"><a href="./values.yaml#L978">keeper.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access modes of the PVC. Ref: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes</td>
        </tr>
        <tr>
            <td id="keeper--persistence--size"><a href="./values.yaml#L982">keeper.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10Gi</pre>
</div>
            </td>
            <td>Size of the PVC.</td>
        </tr>
        <tr>
            <td id="keeper--persistence--storageClass"><a href="./values.yaml#L986">keeper.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the default provisioner</pre>
</div>
            </td>
            <td>StorageClass of the PVC. `-` disables dynamic provisioning, null uses the cluster default, and `global.storageClass` overrides it.</td>
        </tr>
    </tbody>
</table>
<h3>ZooKeeper</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="zookeeper"><a href="./values.yaml#L991">zookeeper</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Values of the bundled ZooKeeper chart, which ClickHouse coordinates through when `zookeeper.enabled` is true. Its keys follow Bitnami's chart: https://github.com/bitnami/charts/blob/main/bitnami/zookeeper/values.yaml</td>
        </tr>
        <tr>
            <td id="zookeeper--enabled"><a href="./values.yaml#L996">zookeeper.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Install the bundled ZooKeeper. Deprecated: ClickHouse Keeper (`keeper.enabled`) is the default coordination store, and unset now means off. An existing install that runs ZooKeeper sets this to true for the upgrade together with `keeper.enabled: false`, or after applying the Keeper CRD, and keeps it until it has moved to Keeper; see https://signoz.io/docs/operate/migration/upgrade-0-152/</td>
        </tr>
        <tr>
            <td id="zookeeper--commonAnnotations"><a href="./values.yaml#L999">zookeeper.commonAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io/deprecated: "true"</pre>
</div>
            </td>
            <td>Annotations on the metadata of every ZooKeeper object (not on the Pod template).</td>
        </tr>
        <tr>
            <td id="zookeeper--image"><a href="./values.yaml#L1003">zookeeper.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">registry: null
repository: signoz/zookeeper
tag: 3.7.1</pre>
</div>
            </td>
            <td>ZooKeeper image configuration.</td>
        </tr>
        <tr>
            <td id="zookeeper--image--registry"><a href="./values.yaml#L1006">zookeeper.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Image registry.</td>
        </tr>
        <tr>
            <td id="zookeeper--image--repository"><a href="./values.yaml#L1009">zookeeper.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/zookeeper</pre>
</div>
            </td>
            <td>Image repository.</td>
        </tr>
        <tr>
            <td id="zookeeper--image--tag"><a href="./values.yaml#L1012">zookeeper.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3.7.1</pre>
</div>
            </td>
            <td>ZooKeeper version; ClickHouse does not work with every ZooKeeper version, so change it only to one ClickHouse supports.</td>
        </tr>
        <tr>
            <td id="zookeeper--nameOverride"><a href="./values.yaml#L1015">zookeeper.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Replaces `zookeeper` in the ZooKeeper name `<release>-zookeeper`, by which the ClickHouse installation finds it.</td>
        </tr>
        <tr>
            <td id="zookeeper--fullnameOverride"><a href="./values.yaml#L1018">zookeeper.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the ZooKeeper objects in place of `<release>-zookeeper`, by which the ClickHouse installation finds it.</td>
        </tr>
        <tr>
            <td id="zookeeper--namespaceOverride"><a href="./values.yaml#L1021">zookeeper.namespaceOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Namespace of ZooKeeper, which must already exist. Empty means the release namespace.</td>
        </tr>
        <tr>
            <td id="zookeeper--podAnnotations"><a href="./values.yaml#L1024">zookeeper.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io/path: /metrics
signoz.io/port: "9141"
signoz.io/scrape: "true"</pre>
</div>
            </td>
            <td>Annotations on the ZooKeeper Pods. The `signoz.io/*` defaults let the SigNoz collectors scrape its metrics on port 9141.</td>
        </tr>
        <tr>
            <td id="zookeeper--autopurge"><a href="./values.yaml#L1030">zookeeper.autopurge</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">purgeInterval: 1</pre>
</div>
            </td>
            <td>Periodic purge of old ZooKeeper snapshots and transaction logs.</td>
        </tr>
        <tr>
            <td id="zookeeper--autopurge--purgeInterval"><a href="./values.yaml#L1033">zookeeper.autopurge.purgeInterval</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Hours between purges; 0 disables purging.</td>
        </tr>
        <tr>
            <td id="zookeeper--metrics"><a href="./values.yaml#L1036">zookeeper.metrics</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: true
service:
    annotations: {}
    enabled: true</pre>
</div>
            </td>
            <td>ZooKeeper Prometheus metrics configuration.</td>
        </tr>
        <tr>
            <td id="zookeeper--metrics--enabled"><a href="./values.yaml#L1039">zookeeper.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Serve ZooKeeper's Prometheus metrics on port 9141, the port `podAnnotations` point the collectors at.</td>
        </tr>
        <tr>
            <td id="zookeeper--metrics--service--annotations"><a href="./values.yaml#L1044">zookeeper.metrics.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the metrics Service.</td>
        </tr>
        <tr>
            <td id="zookeeper--logLevel"><a href="./values.yaml#L1050">zookeeper.logLevel</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">INFO</pre>
</div>
            </td>
            <td>ZooKeeper log level.</td>
        </tr>
        <tr>
            <td id="zookeeper--livenessProbe"><a href="./values.yaml#L1054">zookeeper.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>Bitnami's built-in liveness probe. `customLivenessProbe` replaces it. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/</td>
        </tr>
        <tr>
            <td id="zookeeper--readinessProbe"><a href="./values.yaml#L1059">zookeeper.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>Bitnami's built-in readiness probe. `customReadinessProbe` replaces it. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/</td>
        </tr>
        <tr>
            <td id="zookeeper--customLivenessProbe"><a href="./values.yaml#L1064">zookeeper.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">exec:
    command:
        - /bin/bash
        - -c
        - curl -s -m 2 http://localhost:8080/commands/ruok | grep ruok
failureThreshold: 6
initialDelaySeconds: 30
periodSeconds: 10
successThreshold: 1
timeoutSeconds: 5</pre>
</div>
            </td>
            <td>Liveness probe of the ZooKeeper container: the `ruok` command on its admin server at port 8080. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/</td>
        </tr>
        <tr>
            <td id="zookeeper--customReadinessProbe"><a href="./values.yaml#L1075">zookeeper.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">exec:
    command:
        - /bin/bash
        - -c
        - curl -s -m 2 http://localhost:8080/commands/ruok | grep error | grep null
failureThreshold: 6
initialDelaySeconds: 5
periodSeconds: 10
successThreshold: 1
timeoutSeconds: 5</pre>
</div>
            </td>
            <td>Readiness probe of the ZooKeeper container: ready once the admin server's `ruok` command reports no error. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/</td>
        </tr>
        <tr>
            <td id="zookeeper--minServerId"><a href="./values.yaml#L1085">zookeeper.minServerId</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>ZooKeeper server ID of the first replica. Each further replica takes the next ID.</td>
        </tr>
        <tr>
            <td id="zookeeper--replicaCount"><a href="./values.yaml#L1088">zookeeper.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Number of ZooKeeper replicas, each listed as a coordination node of the ClickHouse installation. Use an odd number to keep a quorum.</td>
        </tr>
        <tr>
            <td id="zookeeper--pdb"><a href="./values.yaml#L1091">zookeeper.pdb</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">create: false</pre>
</div>
            </td>
            <td>PodDisruptionBudget of the ZooKeeper Pods.</td>
        </tr>
        <tr>
            <td id="zookeeper--pdb--create"><a href="./values.yaml#L1095">zookeeper.pdb.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create a PodDisruptionBudget. Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence"><a href="./values.yaml#L1098">zookeeper.persistence</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">accessModes:
    - ReadWriteOnce
annotations: {}
enabled: true
existingClaim: ""
size: 8Gi
storageClass: null</pre>
</div>
            </td>
            <td>Storage of the ZooKeeper data.</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--enabled"><a href="./values.yaml#L1101">zookeeper.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable persistence with a PersistentVolumeClaim (PVC). When false, the data lives in an `emptyDir`.</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--existingClaim"><a href="./values.yaml#L1104">zookeeper.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of an existing PVC to use, with a single replica only.</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--storageClass"><a href="./values.yaml#L1107">zookeeper.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>StorageClass of the ZooKeeper data PVC. `-` disables dynamic provisioning, null uses the cluster default, and `global.storageClass` overrides it.</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--accessModes"><a href="./values.yaml#L1111">zookeeper.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access modes of the PVC. Ref: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--size"><a href="./values.yaml#L1115">zookeeper.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8Gi</pre>
</div>
            </td>
            <td>Size of the PVC.</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--annotations"><a href="./values.yaml#L1118">zookeeper.persistence.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the PVC.</td>
        </tr>
        <tr>
            <td id="zookeeper--resources"><a href="./values.yaml#L1121">zookeeper.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">limits: {}
requests:
    cpu: 100m
    memory: 256Mi</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
    </tbody>
</table>
<h3>External ClickHouse</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="externalClickhouse"><a href="./values.yaml#L1337">externalClickhouse</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster: cluster
database: signoz_metrics
existingSecret: null
existingSecretPasswordKey: password
host: null
httpPort: 8123
logDatabase: signoz_logs
meterDatabase: signoz_meter
password: ""
secure: false
tcpPort: 9000
traceDatabase: signoz_traces
user: ""
verify: false</pre>
</div>
            </td>
            <td>External ClickHouse configuration. Required when `clickhouse.enabled` is false, and used only then.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--host"><a href="./values.yaml#L1341">externalClickhouse.host</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Host of the external ClickHouse.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--cluster"><a href="./values.yaml#L1345">externalClickhouse.cluster</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster</pre>
</div>
            </td>
            <td>Cluster of the external ClickHouse that the migrator creates SigNoz's tables on and SigNoz queries.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--database"><a href="./values.yaml#L1349">externalClickhouse.database</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_metrics</pre>
</div>
            </td>
            <td>Database the collector writes metrics to.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--traceDatabase"><a href="./values.yaml#L1353">externalClickhouse.traceDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_traces</pre>
</div>
            </td>
            <td>Database the collector writes traces to.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--logDatabase"><a href="./values.yaml#L1357">externalClickhouse.logDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_logs</pre>
</div>
            </td>
            <td>Database the collector writes logs to.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--meterDatabase"><a href="./values.yaml#L1361">externalClickhouse.meterDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_meter</pre>
</div>
            </td>
            <td>Database the collector writes meter data to.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--user"><a href="./values.yaml#L1365">externalClickhouse.user</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>User the components connect as.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--password"><a href="./values.yaml#L1370">externalClickhouse.password</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Password of `externalClickhouse.user`, written into the Secret `<clickhouse.fullname>-credentials` that the components read. Ignored when `externalClickhouse.existingSecret` is set.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--existingSecret"><a href="./values.yaml#L1375">externalClickhouse.existingSecret</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of a Secret you created that holds the password of `externalClickhouse.user`. When set, the chart creates no Secret and the components read this one.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--existingSecretPasswordKey"><a href="./values.yaml#L1379">externalClickhouse.existingSecretPasswordKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">password</pre>
</div>
            </td>
            <td>Key of the password inside `externalClickhouse.existingSecret`.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--secure"><a href="./values.yaml#L1384">externalClickhouse.secure</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Connect to an external ClickHouse behind TLS by appending `?secure=true` to the SigNoz and migrator connection strings. Set `externalClickhouse.tcpPort` to its secure port, usually 9440, and add the same parameters to the exporter connection strings in `otelCollector.config`.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--verify"><a href="./values.yaml#L1389">externalClickhouse.verify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Verify the server's TLS certificate when `externalClickhouse.secure` is true. False appends `&skip_verify=true` to the SigNoz and migrator connection strings. Add it to the exporter connection strings in `otelCollector.config` yourself.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--httpPort"><a href="./values.yaml#L1393">externalClickhouse.httpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8123</pre>
</div>
            </td>
            <td>HTTP port of the external ClickHouse.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--tcpPort"><a href="./values.yaml#L1397">externalClickhouse.tcpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">9000</pre>
</div>
            </td>
            <td>Native TCP port of the external ClickHouse.</td>
        </tr>
    </tbody>
</table>
<h3>SigNoz</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="signoz--name"><a href="./values.yaml#L1401">signoz.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz</pre>
</div>
            </td>
            <td>Name of the SigNoz component, the `app.kubernetes.io/component` selector label. An upgrade cannot change it.</td>
        </tr>
        <tr>
            <td id="signoz--replicaCount"><a href="./values.yaml#L1404">signoz.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Number of replicas. With SQLite, each replica has its own database.</td>
        </tr>
        <tr>
            <td id="signoz--image--repository"><a href="./values.yaml#L1408">signoz.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">docker.io/signoz/signoz</pre>
</div>
            </td>
            <td>Image repository, with its registry. `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="signoz--image--tag"><a href="./values.yaml#L1411">signoz.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v0.151.0</pre>
</div>
            </td>
            <td>Image tag. Empty means the chart's `appVersion`.</td>
        </tr>
        <tr>
            <td id="signoz--image--pullPolicy"><a href="./values.yaml#L1414">signoz.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Image pull policy.</td>
        </tr>
        <tr>
            <td id="signoz--imagePullSecrets"><a href="./values.yaml#L1417">signoz.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for the SigNoz Pod.</td>
        </tr>
        <tr>
            <td id="signoz--serviceAccount--create"><a href="./values.yaml#L1421">signoz.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Create a ServiceAccount.</td>
        </tr>
        <tr>
            <td id="signoz--serviceAccount--annotations"><a href="./values.yaml#L1424">signoz.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ServiceAccount.</td>
        </tr>
        <tr>
            <td id="signoz--serviceAccount--name"><a href="./values.yaml#L1428">signoz.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the release's full name, or default</pre>
</div>
            </td>
            <td>Name of the ServiceAccount. Empty means the release's full name when `create` is true, and `default` otherwise.</td>
        </tr>
        <tr>
            <td id="signoz--annotations"><a href="./values.yaml#L1463">signoz.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">no annotations</pre>
</div>
            </td>
            <td>Annotations to add to the StatefulSet.</td>
        </tr>
        <tr>
            <td id="signoz--labels"><a href="./values.yaml#L1466">signoz.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the StatefulSet. A key that matches a chart label replaces it.</td>
        </tr>
        <tr>
            <td id="signoz--extraArgs"><a href="./values.yaml#L1469">signoz.extraArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra arguments for the container, added after the image's own.</td>
        </tr>
        <tr>
            <td id="signoz--env"><a href="./values.yaml#L1489">signoz.env</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the five SigNoz settings in values.yaml</pre>
</div>
            </td>
            <td>Extra environment variables for the container, as `NAME: value`. A key named like a variable the chart sets replaces it. A string, number or boolean is the value. A map is the rest of the EnvVar, such as `valueFrom`. The names follow the SigNoz configuration: `provider` under `telemetry_store` is `signoz_telemetrystore_provider`. When a key is set in both cases, the lower-case one wins. Set a default to `null` to remove it. All names: https://github.com/SigNoz/signoz/blob/main/conf/example.yaml
A plain value and a value from a Secret:

  ```yaml
  MY_KEY: my-value
  SECRET_KEY:
    valueFrom:
      secretKeyRef:
        name: my-secret
        key: my-key
  ```
</td>
        </tr>
        <tr>
            <td id="signoz--envFrom"><a href="./values.yaml#L1506">signoz.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Sources of extra environment variables for the container. A variable of the same name in `signoz.env` or set by the chart takes precedence.</td>
        </tr>
        <tr>
            <td id="signoz--podSecurityContext"><a href="./values.yaml#L1510">signoz.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the Pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="signoz--pod--annotations"><a href="./values.yaml#L1514">signoz.pod.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Pod.</td>
        </tr>
        <tr>
            <td id="signoz--pod--labels"><a href="./values.yaml#L1517">signoz.pod.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Pod. A key named like a selector label is ignored.</td>
        </tr>
        <tr>
            <td id="signoz--containerSecurityContext"><a href="./values.yaml#L1521">signoz.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="signoz--extraVolumeMounts"><a href="./values.yaml#L1524">signoz.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the container.</td>
        </tr>
        <tr>
            <td id="signoz--extraVolumes"><a href="./values.yaml#L1527">signoz.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the Pod.</td>
        </tr>
        <tr>
            <td id="signoz--extraInitContainers"><a href="./values.yaml#L1530">signoz.extraInitContainers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra init containers for the Pod.</td>
        </tr>
        <tr>
            <td id="signoz--extraContainers"><a href="./values.yaml#L1534">signoz.extraContainers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra containers for the Pod. The SQLite database is on the PVC `signoz-db`, mounted at `/var/lib/signoz`.</td>
        </tr>
        <tr>
            <td id="signoz--livenessProbe"><a href="./values.yaml#L1540">signoz.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">an HTTP GET of /api/v1/health on port http</pre>
</div>
            </td>
            <td>Liveness probe for the container. `null` renders none. A handler other than `httpGet` must also set `httpGet: null`. Set a field to `null` to drop it. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/</td>
        </tr>
        <tr>
            <td id="signoz--readinessProbe"><a href="./values.yaml#L1554">signoz.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">an HTTP GET of /api/v1/health?live=1 on port http</pre>
</div>
            </td>
            <td>Readiness probe for the container. `null` renders none. A handler other than `httpGet` must also set `httpGet: null`. Set a field to `null` to drop it. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/</td>
        </tr>
        <tr>
            <td id="signoz--startupProbe"><a href="./values.yaml#L1567">signoz.startupProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">no startup probe</pre>
</div>
            </td>
            <td>Startup probe for the container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/</td>
        </tr>
        <tr>
            <td id="signoz--resources"><a href="./values.yaml#L1647">signoz.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">requests of 100m CPU and 100Mi of memory</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
        <tr>
            <td id="signoz--priorityClassName"><a href="./values.yaml#L1654">signoz.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">no PriorityClass</pre>
</div>
            </td>
            <td>PriorityClass of the Pod.</td>
        </tr>
        <tr>
            <td id="signoz--nodeSelector"><a href="./values.yaml#L1657">signoz.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node labels for Pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--tolerations"><a href="./values.yaml#L1660">signoz.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for Pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--affinity"><a href="./values.yaml#L1663">signoz.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for Pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--topologySpreadConstraints"><a href="./values.yaml#L1667">signoz.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for Pod assignment. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/</td>
        </tr>
        <tr>
            <td id="signoz--persistence--enabled"><a href="./values.yaml#L1672">signoz.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable persistence with a PersistentVolumeClaim. When false, the SQLite database is in an `emptyDir`. Ignored when `postgresql.enabled` is true.</td>
        </tr>
        <tr>
            <td id="signoz--persistence--existingClaim"><a href="./values.yaml#L1676">signoz.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">none, the chart's volume claim template</pre>
</div>
            </td>
            <td>Name of an existing PVC to use. Only used when `signoz.persistence.enabled` is true.</td>
        </tr>
        <tr>
            <td id="signoz--persistence--storageClass"><a href="./values.yaml#L1680">signoz.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the cluster's default StorageClass</pre>
</div>
            </td>
            <td>StorageClass of the PVC. `-` disables dynamic provisioning, and `global.storageClass` overrides it.</td>
        </tr>
        <tr>
            <td id="signoz--persistence--accessModes"><a href="./values.yaml#L1684">signoz.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access modes of the PVC. Ref: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes</td>
        </tr>
        <tr>
            <td id="signoz--persistence--size"><a href="./values.yaml#L1688">signoz.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1Gi</pre>
</div>
            </td>
            <td>Size of the PVC.</td>
        </tr>
    </tbody>
</table>
<h3>SigNoz Networking</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="signoz--service--annotations"><a href="./values.yaml#L1432">signoz.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Service.</td>
        </tr>
        <tr>
            <td id="signoz--service--labels"><a href="./values.yaml#L1435">signoz.service.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Service. A key that matches a chart label replaces it.</td>
        </tr>
        <tr>
            <td id="signoz--service--type"><a href="./values.yaml#L1438">signoz.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>Kubernetes Service type: `ClusterIP`, `NodePort` or `LoadBalancer`.</td>
        </tr>
        <tr>
            <td id="signoz--service--port"><a href="./values.yaml#L1441">signoz.service.port</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8080</pre>
</div>
            </td>
            <td>Service port of the HTTP API and UI. The container port stays 8080.</td>
        </tr>
        <tr>
            <td id="signoz--service--internalPort"><a href="./values.yaml#L1444">signoz.service.internalPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8085</pre>
</div>
            </td>
            <td>Service port for the internal API. The container port stays 8085.</td>
        </tr>
        <tr>
            <td id="signoz--service--opampPort"><a href="./values.yaml#L1447">signoz.service.opampPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">4320</pre>
</div>
            </td>
            <td>Service port for OpAMP. The container port stays 4320.</td>
        </tr>
        <tr>
            <td id="signoz--service--nodePort"><a href="./values.yaml#L1451">signoz.service.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">chosen by the cluster</pre>
</div>
            </td>
            <td>NodePort for HTTP. Only used when `signoz.service.type` is `NodePort`.</td>
        </tr>
        <tr>
            <td id="signoz--service--internalNodePort"><a href="./values.yaml#L1455">signoz.service.internalNodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">chosen by the cluster</pre>
</div>
            </td>
            <td>NodePort for the internal API. Only used when `signoz.service.type` is `NodePort`.</td>
        </tr>
        <tr>
            <td id="signoz--service--opampInternalNodePort"><a href="./values.yaml#L1459">signoz.service.opampInternalNodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">chosen by the cluster</pre>
</div>
            </td>
            <td>NodePort for OpAMP. Only used when `signoz.service.type` is `NodePort`.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--enabled"><a href="./values.yaml#L1571">signoz.ingress.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create an Ingress for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--className"><a href="./values.yaml#L1575">signoz.ingress.className</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>IngressClass of the Ingress. Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class</td>
        </tr>
        <tr>
            <td id="signoz--ingress--annotations"><a href="./values.yaml#L1578">signoz.ingress.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Ingress.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--labels"><a href="./values.yaml#L1581">signoz.ingress.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Ingress. A key that matches a chart label replaces it.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--hosts"><a href="./values.yaml#L1586">signoz.ingress.hosts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the host signoz.domain.com, with the path / on port 8080</pre>
</div>
            </td>
            <td>Hosts and paths of the Ingress. A path without `port` routes to `signoz.service.port`, and a path without `pathType` gets `ImplementationSpecific`.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--tls"><a href="./values.yaml#L1595">signoz.ingress.tls</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>TLS settings of the Ingress, as entries with `hosts` and an optional `secretName`. Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#tls</td>
        </tr>
        <tr>
            <td id="signoz--httpRoute--enabled"><a href="./values.yaml#L1600">signoz.httpRoute.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create a Gateway API HTTPRoute for SigNoz. The Gateway API CRDs and a Gateway must already exist in the cluster.</td>
        </tr>
        <tr>
            <td id="signoz--httpRoute--annotations"><a href="./values.yaml#L1603">signoz.httpRoute.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the HTTPRoute.</td>
        </tr>
        <tr>
            <td id="signoz--httpRoute--labels"><a href="./values.yaml#L1606">signoz.httpRoute.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the HTTPRoute. A key that matches a chart label replaces it.</td>
        </tr>
        <tr>
            <td id="signoz--httpRoute--parentRefs"><a href="./values.yaml#L1619">signoz.httpRoute.parentRefs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Gateways the HTTPRoute attaches to. Ref: https://gateway-api.sigs.k8s.io/reference/api-types/httproute/#attaching-to-gateways
A listener of a Gateway in another namespace:

  ```yaml
  - name: my-gateway
    namespace: gateway-system
    sectionName: https
  ```
</td>
        </tr>
        <tr>
            <td id="signoz--httpRoute--hostnames"><a href="./values.yaml#L1623">signoz.httpRoute.hostnames</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Hostnames the HTTPRoute matches. Ref: https://gateway-api.sigs.k8s.io/reference/api-types/httproute/#hostnames</td>
        </tr>
        <tr>
            <td id="signoz--httpRoute--rules"><a href="./values.yaml#L1641">signoz.httpRoute.rules</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">one rule to the SigNoz Service on port 8080</pre>
</div>
            </td>
            <td>Rules of the HTTPRoute. A backendRef without `name` goes to the SigNoz Service, and one without `port` to `signoz.service.port`. Ref: https://gateway-api.sigs.k8s.io/reference/api-types/httproute/#rules
Only the API paths:

  ```yaml
  - matches:
      - path:
          type: PathPrefix
          value: /api
    backendRefs:
      - port: 8080
  ```
</td>
        </tr>
    </tbody>
</table>
<h3>Telemetry Store Migrator</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="telemetryStoreMigrator"><a href="./values.yaml#L1692">telemetryStoreMigrator</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Telemetry store migrator configuration.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--enabled"><a href="./values.yaml#L1696">telemetryStoreMigrator.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the telemetry store migrator, a Job that runs on every install and upgrade. The collector's `check` init container waits for its migrations.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--name"><a href="./values.yaml#L1699">telemetryStoreMigrator.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz-telemetrystore-migrator</pre>
</div>
            </td>
            <td>Name of the migrator component. The Job is named `<name>-<release revision>`. At most 57 characters.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--annotations"><a href="./values.yaml#L1703">telemetryStoreMigrator.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations added to the Job, merged over the chart's `argocd.argoproj.io/sync-options: Force=true,Replace=true`. A value for that key replaces the chart's.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--labels"><a href="./values.yaml#L1706">telemetryStoreMigrator.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Job. A key the chart also sets takes your value.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--pod--labels"><a href="./values.yaml#L1710">telemetryStoreMigrator.pod.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Pod. A key the chart also sets keeps the chart's value.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--pod--annotations"><a href="./values.yaml#L1713">telemetryStoreMigrator.pod.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Pod.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--enableReplication"><a href="./values.yaml#L1717">telemetryStoreMigrator.enableReplication</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable replication in the migrations.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--timeout"><a href="./values.yaml#L1721">telemetryStoreMigrator.timeout</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10m</pre>
</div>
            </td>
            <td>Timeout of the migration.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--ttlSecondsAfterFinished"><a href="./values.yaml#L1728">telemetryStoreMigrator.ttlSecondsAfterFinished</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Seconds Kubernetes keeps a finished migrator Job, and its logs, before deleting it. Set it (for example `604800`) to clean up Jobs a failed upgrade leaves behind. Leave it unset under Argo CD, which recreates a deleted Job and re-runs the migrator. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--nodeSelector"><a href="./values.yaml#L1732">telemetryStoreMigrator.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node labels for Pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--tolerations"><a href="./values.yaml#L1736">telemetryStoreMigrator.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for Pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--affinity"><a href="./values.yaml#L1740">telemetryStoreMigrator.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for Pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--topologySpreadConstraints"><a href="./values.yaml#L1745">telemetryStoreMigrator.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for Pod assignment. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--priorityClassName"><a href="./values.yaml#L1748">telemetryStoreMigrator.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>PriorityClass of the Pod.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--podSecurityContext"><a href="./values.yaml#L1752">telemetryStoreMigrator.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the Pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--resources"><a href="./values.yaml#L1755">telemetryStoreMigrator.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resource requests and limits for the migration containers and the collector's `check` init container.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--containerSecurityContext"><a href="./values.yaml#L1759">telemetryStoreMigrator.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the migration containers. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--env"><a href="./values.yaml#L1763">telemetryStoreMigrator.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for the migration containers and the collector's `check` init container. An entry named like one the chart sets replaces it.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--envFrom"><a href="./values.yaml#L1766">telemetryStoreMigrator.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Sources of extra environment variables for the migration containers and the collector's `check` init container.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--extraVolumes"><a href="./values.yaml#L1769">telemetryStoreMigrator.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the Pod.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--extraVolumeMounts"><a href="./values.yaml#L1772">telemetryStoreMigrator.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the migration containers.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--serviceAccount"><a href="./values.yaml#L1777">telemetryStoreMigrator.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
create: false
name: null</pre>
</div>
            </td>
            <td>ServiceAccount of the migrator Job; by default none is created and the Job runs as `default`. Set `create: true` when a policy or credential is bound to a ServiceAccount. On an install from a chart before 1.0.0, first delete the old `signoz-telemetrystore-migrator` ServiceAccount or upgrade with `--take-ownership`.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--serviceAccount--create"><a href="./values.yaml#L1780">telemetryStoreMigrator.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create a ServiceAccount.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--serviceAccount--annotations"><a href="./values.yaml#L1783">telemetryStoreMigrator.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ServiceAccount.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--serviceAccount--name"><a href="./values.yaml#L1786">telemetryStoreMigrator.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of the ServiceAccount to create, or of an existing one to run as when `create` is false.</td>
        </tr>
    </tbody>
</table>
<h3>Otel Collector</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="otelCollector"><a href="./values.yaml#L1790">otelCollector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>OpenTelemetry Collector configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--name"><a href="./values.yaml#L1794">otelCollector.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">otel-collector</pre>
</div>
            </td>
            <td>Name of the collector component.</td>
        </tr>
        <tr>
            <td id="otelCollector--image--repository"><a href="./values.yaml#L1798">otelCollector.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">docker.io/signoz/signoz-otel-collector</pre>
</div>
            </td>
            <td>Image repository, with its registry. `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="otelCollector--image--tag"><a href="./values.yaml#L1801">otelCollector.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v0.144.16</pre>
</div>
            </td>
            <td>Image tag.</td>
        </tr>
        <tr>
            <td id="otelCollector--image--pullPolicy"><a href="./values.yaml#L1804">otelCollector.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Image pull policy.</td>
        </tr>
        <tr>
            <td id="otelCollector--imagePullSecrets"><a href="./values.yaml#L1807">otelCollector.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for the collector Pod, as a list of Secret names.</td>
        </tr>
        <tr>
            <td id="otelCollector--strategy"><a href="./values.yaml#L1812">otelCollector.strategy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">RollingUpdate</pre>
</div>
            </td>
            <td>Deployment strategy. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy</td>
        </tr>
        <tr>
            <td id="otelCollector--extraArgs"><a href="./values.yaml#L1815">otelCollector.extraArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra arguments for the container, added after the chart's `--config`, `--manager-config` and `--copy-path`.</td>
        </tr>
        <tr>
            <td id="otelCollector--configMap--create"><a href="./values.yaml#L1819">otelCollector.configMap.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Create a ConfigMap.</td>
        </tr>
        <tr>
            <td id="otelCollector--serviceAccount--create"><a href="./values.yaml#L1823">otelCollector.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Create a ServiceAccount.</td>
        </tr>
        <tr>
            <td id="otelCollector--serviceAccount--annotations"><a href="./values.yaml#L1826">otelCollector.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ServiceAccount.</td>
        </tr>
        <tr>
            <td id="otelCollector--serviceAccount--name"><a href="./values.yaml#L1829">otelCollector.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of the ServiceAccount. When empty and `create` is true, the chart generates one.</td>
        </tr>
        <tr>
            <td id="otelCollector--annotations"><a href="./values.yaml#L1846">otelCollector.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations to add to the Deployment.</td>
        </tr>
        <tr>
            <td id="otelCollector--labels"><a href="./values.yaml#L1849">otelCollector.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Deployment. A key that repeats a chart label replaces its value.</td>
        </tr>
        <tr>
            <td id="otelCollector--pod--annotations"><a href="./values.yaml#L1854">otelCollector.pod.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io/port: "8888"
signoz.io/scrape: "true"</pre>
</div>
            </td>
            <td>Annotations to add to the Pod. Set a key to `null` to drop a default. A `checksum/config` key is ignored.</td>
        </tr>
        <tr>
            <td id="otelCollector--pod--labels"><a href="./values.yaml#L1859">otelCollector.pod.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Pod. A key named like a selector label is ignored.</td>
        </tr>
        <tr>
            <td id="otelCollector--env"><a href="./values.yaml#L1871">otelCollector.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for the container. An entry named like one the chart sets replaces it. The chart sets the `CLICKHOUSE_*` and `K8S_*` variables and `LOW_CARDINAL_EXCEPTION_GROUPING`.
Group exceptions with low cardinality:

  ```yaml
  - name: LOW_CARDINAL_EXCEPTION_GROUPING
    value: "true"
  ```
</td>
        </tr>
        <tr>
            <td id="otelCollector--envFrom"><a href="./values.yaml#L1874">otelCollector.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Sources of extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="otelCollector--minReadySeconds"><a href="./values.yaml#L1879">otelCollector.minReadySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Seconds a new Pod must be ready before it counts as available. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#min-ready-seconds</td>
        </tr>
        <tr>
            <td id="otelCollector--progressDeadlineSeconds"><a href="./values.yaml#L1884">otelCollector.progressDeadlineSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">600</pre>
</div>
            </td>
            <td>Seconds the Deployment may take to progress before it is marked failed. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#progress-deadline-seconds</td>
        </tr>
        <tr>
            <td id="otelCollector--replicaCount"><a href="./values.yaml#L1888">otelCollector.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Number of replicas.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--create"><a href="./values.yaml#L1892">otelCollector.clusterRole.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Create a ClusterRole.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--annotations"><a href="./values.yaml#L1895">otelCollector.clusterRole.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ClusterRole.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--name"><a href="./values.yaml#L1898">otelCollector.clusterRole.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the ClusterRole. When empty, the chart generates one.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--rules"><a href="./values.yaml#L1902">otelCollector.clusterRole.rules</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>RBAC rules of the ClusterRole. The `k8sattributes` processor requires them.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--clusterRoleBinding--annotations"><a href="./values.yaml#L1918">otelCollector.clusterRole.clusterRoleBinding.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ClusterRoleBinding.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--clusterRoleBinding--name"><a href="./values.yaml#L1921">otelCollector.clusterRole.clusterRoleBinding.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the ClusterRoleBinding. When empty, the chart generates one.</td>
        </tr>
        <tr>
            <td id="otelCollector--livenessProbe"><a href="./values.yaml#L2076">otelCollector.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">httpGet on port 13133, path /</pre>
</div>
            </td>
            <td>Liveness probe for the container. `null` renders none. A handler other than `httpGet` must also set `httpGet: null`. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/</td>
        </tr>
        <tr>
            <td id="otelCollector--readinessProbe"><a href="./values.yaml#L2089">otelCollector.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">httpGet on port 13133, path /</pre>
</div>
            </td>
            <td>Readiness probe for the container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/</td>
        </tr>
        <tr>
            <td id="otelCollector--startupProbe"><a href="./values.yaml#L2102">otelCollector.startupProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">no startup probe</pre>
</div>
            </td>
            <td>Startup probe for the container. It holds the liveness and readiness probes back until it succeeds. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/</td>
        </tr>
        <tr>
            <td id="otelCollector--extraVolumeMounts"><a href="./values.yaml#L2105">otelCollector.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the collector container and its `check` init container.</td>
        </tr>
        <tr>
            <td id="otelCollector--extraVolumes"><a href="./values.yaml#L2109">otelCollector.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the Pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--resources"><a href="./values.yaml#L2241">otelCollector.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
        <tr>
            <td id="otelCollector--priorityClassName"><a href="./values.yaml#L2252">otelCollector.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>PriorityClass of the Pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--nodeSelector"><a href="./values.yaml#L2256">otelCollector.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node labels for Pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--tolerations"><a href="./values.yaml#L2260">otelCollector.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for Pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--affinity"><a href="./values.yaml#L2264">otelCollector.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for Pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--topologySpreadConstraints"><a href="./values.yaml#L2269">otelCollector.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Topology spread constraints for Pod assignment. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/</td>
        </tr>
        <tr>
            <td id="otelCollector--podSecurityContext"><a href="./values.yaml#L2280">otelCollector.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the Pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="otelCollector--containerSecurityContext"><a href="./values.yaml#L2286">otelCollector.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the collector container and its `check` init container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--enabled"><a href="./values.yaml#L2298">otelCollector.autoscaling.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable autoscaling with a HorizontalPodAutoscaler (HPA). Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--minReplicas"><a href="./values.yaml#L2301">otelCollector.autoscaling.minReplicas</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Minimum number of replicas.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--maxReplicas"><a href="./values.yaml#L2304">otelCollector.autoscaling.maxReplicas</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">11</pre>
</div>
            </td>
            <td>Maximum number of replicas.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--targetCPUUtilizationPercentage"><a href="./values.yaml#L2307">otelCollector.autoscaling.targetCPUUtilizationPercentage</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">50</pre>
</div>
            </td>
            <td>Target CPU utilization percentage.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--targetMemoryUtilizationPercentage"><a href="./values.yaml#L2310">otelCollector.autoscaling.targetMemoryUtilizationPercentage</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">50</pre>
</div>
            </td>
            <td>Target memory utilization percentage.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--behavior"><a href="./values.yaml#L2313">otelCollector.autoscaling.behavior</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Scaling behavior policies.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--autoscalingTemplate"><a href="./values.yaml#L2329">otelCollector.autoscaling.autoscalingTemplate</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Template for autoscaling.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--annotations"><a href="./values.yaml#L2333">otelCollector.autoscaling.keda.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations to add to the KEDA ScaledObject.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--enabled"><a href="./values.yaml#L2336">otelCollector.autoscaling.keda.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable autoscaling with KEDA.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--pollingInterval"><a href="./values.yaml#L2339">otelCollector.autoscaling.keda.pollingInterval</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"30"</pre>
</div>
            </td>
            <td>Polling interval for metrics data, in seconds.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--cooldownPeriod"><a href="./values.yaml#L2342">otelCollector.autoscaling.keda.cooldownPeriod</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"300"</pre>
</div>
            </td>
            <td>Cooldown period before scaling down, in seconds.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--minReplicaCount"><a href="./values.yaml#L2345">otelCollector.autoscaling.keda.minReplicaCount</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"1"</pre>
</div>
            </td>
            <td>Minimum replica count for KEDA.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--maxReplicaCount"><a href="./values.yaml#L2348">otelCollector.autoscaling.keda.maxReplicaCount</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"5"</pre>
</div>
            </td>
            <td>Maximum replica count for KEDA.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--triggers"><a href="./values.yaml#L2351">otelCollector.autoscaling.keda.triggers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>KEDA trigger configuration.</td>
        </tr>
    </tbody>
</table>
<h3>Otel Collector Networking</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="otelCollector--service--annotations"><a href="./values.yaml#L1833">otelCollector.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Service.</td>
        </tr>
        <tr>
            <td id="otelCollector--service--labels"><a href="./values.yaml#L1836">otelCollector.service.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Service.</td>
        </tr>
        <tr>
            <td id="otelCollector--service--type"><a href="./values.yaml#L1839">otelCollector.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>Kubernetes Service type: `ClusterIP`, `NodePort` or `LoadBalancer`.</td>
        </tr>
        <tr>
            <td id="otelCollector--service--loadBalancerSourceRanges"><a href="./values.yaml#L1842">otelCollector.service.loadBalancerSourceRanges</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Source ranges allowed when the Service type is `LoadBalancer`.</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress--enabled"><a href="./values.yaml#L2113">otelCollector.ingress.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create an Ingress for the collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress--className"><a href="./values.yaml#L2117">otelCollector.ingress.className</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>IngressClass of the Ingress. Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress--annotations"><a href="./values.yaml#L2120">otelCollector.ingress.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Ingress.</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress--labels"><a href="./values.yaml#L2123">otelCollector.ingress.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Ingress. A key that matches a chart label replaces it.</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress--hosts"><a href="./values.yaml#L2128">otelCollector.ingress.hosts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the host otelcollector.domain.com, with the path / on port 4318</pre>
</div>
            </td>
            <td>Hosts and paths of the Ingress. A path without `port` routes to `otelCollector.ports.otlp-http.servicePort`, and a path without `pathType` gets `ImplementationSpecific`.</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress--tls"><a href="./values.yaml#L2137">otelCollector.ingress.tls</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>TLS settings of the Ingress. Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#tls</td>
        </tr>
        <tr>
            <td id="otelCollector--httpRoute--enabled"><a href="./values.yaml#L2145">otelCollector.httpRoute.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create a Gateway API HTTPRoute for the collector. The Gateway API CRDs and a Gateway must already exist in the cluster.</td>
        </tr>
        <tr>
            <td id="otelCollector--httpRoute--annotations"><a href="./values.yaml#L2148">otelCollector.httpRoute.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the HTTPRoute.</td>
        </tr>
        <tr>
            <td id="otelCollector--httpRoute--labels"><a href="./values.yaml#L2151">otelCollector.httpRoute.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the HTTPRoute. A key that matches a chart label replaces it.</td>
        </tr>
        <tr>
            <td id="otelCollector--httpRoute--parentRefs"><a href="./values.yaml#L2164">otelCollector.httpRoute.parentRefs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Gateways the HTTPRoute attaches to. Ref: https://gateway-api.sigs.k8s.io/reference/api-types/httproute/#attaching-to-gateways
A listener of a Gateway in another namespace:

  ```yaml
  - name: my-gateway
    namespace: gateway-system
    sectionName: https
  ```
</td>
        </tr>
        <tr>
            <td id="otelCollector--httpRoute--hostnames"><a href="./values.yaml#L2168">otelCollector.httpRoute.hostnames</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Hostnames the HTTPRoute matches. Ref: https://gateway-api.sigs.k8s.io/reference/api-types/httproute/#hostnames</td>
        </tr>
        <tr>
            <td id="otelCollector--httpRoute--rules"><a href="./values.yaml#L2186">otelCollector.httpRoute.rules</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">one rule to the collector Service on port 4318</pre>
</div>
            </td>
            <td>Rules of the HTTPRoute. A backendRef without `name` goes to the collector Service. Ref: https://gateway-api.sigs.k8s.io/reference/api-types/httproute/#rules
Only the OTLP HTTP paths:

  ```yaml
  - matches:
      - path:
          type: PathPrefix
          value: /v1
    backendRefs:
      - port: 4318
  ```
</td>
        </tr>
        <tr>
            <td id="otelCollector--grpcRoute--enabled"><a href="./values.yaml#L2193">otelCollector.grpcRoute.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create a Gateway API GRPCRoute for the collector. The Gateway API CRDs, of v1.1 or later, and a Gateway must already exist in the cluster.</td>
        </tr>
        <tr>
            <td id="otelCollector--grpcRoute--annotations"><a href="./values.yaml#L2196">otelCollector.grpcRoute.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the GRPCRoute.</td>
        </tr>
        <tr>
            <td id="otelCollector--grpcRoute--labels"><a href="./values.yaml#L2199">otelCollector.grpcRoute.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the GRPCRoute. A key that matches a chart label replaces it.</td>
        </tr>
        <tr>
            <td id="otelCollector--grpcRoute--parentRefs"><a href="./values.yaml#L2212">otelCollector.grpcRoute.parentRefs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Gateways the GRPCRoute attaches to. Ref: https://gateway-api.sigs.k8s.io/reference/api-types/grpcroute/#attaching-to-gateways
A listener of a Gateway in another namespace:

  ```yaml
  - name: my-gateway
    namespace: gateway-system
    sectionName: grpc
  ```
</td>
        </tr>
        <tr>
            <td id="otelCollector--grpcRoute--hostnames"><a href="./values.yaml#L2217">otelCollector.grpcRoute.hostnames</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Hostnames the GRPCRoute matches. Keep them apart from `otelCollector.httpRoute.hostnames` on a shared listener: implementations may reject one of the two routes. Ref: https://gateway-api.sigs.k8s.io/reference/api-types/grpcroute/#cross-serving</td>
        </tr>
        <tr>
            <td id="otelCollector--grpcRoute--rules"><a href="./values.yaml#L2235">otelCollector.grpcRoute.rules</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">one rule to the collector Service on port 4317</pre>
</div>
            </td>
            <td>Rules of the GRPCRoute. A backendRef without `name` goes to the collector Service. Ref: https://gateway-api.sigs.k8s.io/reference/api-types/grpcroute/#rules
Only OTLP traces:

  ```yaml
  - matches:
      - method:
          service: opentelemetry.proto.collector.trace.v1.TraceService
          method: Export
    backendRefs:
      - port: 4317
  ```
</td>
        </tr>
    </tbody>
</table>
<h3>Otel Collector Ports</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="otelCollector--ports"><a href="./values.yaml#L1926">otelCollector.ports</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Port configuration. Each entry is a port of the collector container and of its Service. An entry of your own needs `enabled`, `containerPort`, `servicePort` and `protocol`. Its name is a port name of at most 15 characters.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp--enabled"><a href="./values.yaml#L1930">otelCollector.ports.otlp.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Service port for OTLP gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp--containerPort"><a href="./values.yaml#L1933">otelCollector.ports.otlp.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">4317</pre>
</div>
            </td>
            <td>Container port for OTLP gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp--servicePort"><a href="./values.yaml#L1936">otelCollector.ports.otlp.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">4317</pre>
</div>
            </td>
            <td>Service port for OTLP gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp--nodePort"><a href="./values.yaml#L1939">otelCollector.ports.otlp.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>NodePort for OTLP gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp--protocol"><a href="./values.yaml#L1942">otelCollector.ports.otlp.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for OTLP gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp-http--enabled"><a href="./values.yaml#L1946">otelCollector.ports.otlp-http.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Service port for OTLP HTTP.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp-http--containerPort"><a href="./values.yaml#L1949">otelCollector.ports.otlp-http.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">4318</pre>
</div>
            </td>
            <td>Container port for OTLP HTTP.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp-http--servicePort"><a href="./values.yaml#L1952">otelCollector.ports.otlp-http.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">4318</pre>
</div>
            </td>
            <td>Service port for OTLP HTTP.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp-http--nodePort"><a href="./values.yaml#L1955">otelCollector.ports.otlp-http.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>NodePort for OTLP HTTP.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp-http--protocol"><a href="./values.yaml#L1958">otelCollector.ports.otlp-http.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for OTLP HTTP.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-thrift--enabled"><a href="./values.yaml#L1962">otelCollector.ports.jaeger-thrift.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Service port for Jaeger Thrift.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-thrift--containerPort"><a href="./values.yaml#L1965">otelCollector.ports.jaeger-thrift.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">14268</pre>
</div>
            </td>
            <td>Container port for Jaeger Thrift.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-thrift--servicePort"><a href="./values.yaml#L1968">otelCollector.ports.jaeger-thrift.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">14268</pre>
</div>
            </td>
            <td>Service port for Jaeger Thrift.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-thrift--nodePort"><a href="./values.yaml#L1971">otelCollector.ports.jaeger-thrift.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>NodePort for Jaeger Thrift.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-thrift--protocol"><a href="./values.yaml#L1974">otelCollector.ports.jaeger-thrift.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for Jaeger Thrift.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-grpc--enabled"><a href="./values.yaml#L1978">otelCollector.ports.jaeger-grpc.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Service port for Jaeger gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-grpc--containerPort"><a href="./values.yaml#L1981">otelCollector.ports.jaeger-grpc.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">14250</pre>
</div>
            </td>
            <td>Container port for Jaeger gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-grpc--servicePort"><a href="./values.yaml#L1984">otelCollector.ports.jaeger-grpc.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">14250</pre>
</div>
            </td>
            <td>Service port for Jaeger gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-grpc--nodePort"><a href="./values.yaml#L1987">otelCollector.ports.jaeger-grpc.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>NodePort for Jaeger gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-grpc--protocol"><a href="./values.yaml#L1990">otelCollector.ports.jaeger-grpc.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for Jaeger gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--metrics--enabled"><a href="./values.yaml#L1994">otelCollector.ports.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Service port for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--metrics--containerPort"><a href="./values.yaml#L1997">otelCollector.ports.metrics.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8888</pre>
</div>
            </td>
            <td>Container port for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--metrics--servicePort"><a href="./values.yaml#L2000">otelCollector.ports.metrics.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8888</pre>
</div>
            </td>
            <td>Service port for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--metrics--nodePort"><a href="./values.yaml#L2003">otelCollector.ports.metrics.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>NodePort for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--metrics--protocol"><a href="./values.yaml#L2006">otelCollector.ports.metrics.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zpages--enabled"><a href="./values.yaml#L2010">otelCollector.ports.zpages.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable the Service port for zPages.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zpages--containerPort"><a href="./values.yaml#L2013">otelCollector.ports.zpages.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">55679</pre>
</div>
            </td>
            <td>Container port for zPages.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zpages--servicePort"><a href="./values.yaml#L2016">otelCollector.ports.zpages.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">55679</pre>
</div>
            </td>
            <td>Service port for zPages.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zpages--nodePort"><a href="./values.yaml#L2019">otelCollector.ports.zpages.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>NodePort for zPages.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zpages--protocol"><a href="./values.yaml#L2022">otelCollector.ports.zpages.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for zPages.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--pprof--enabled"><a href="./values.yaml#L2026">otelCollector.ports.pprof.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable the Service port for pprof.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--pprof--containerPort"><a href="./values.yaml#L2029">otelCollector.ports.pprof.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1777</pre>
</div>
            </td>
            <td>Container port for pprof.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--pprof--servicePort"><a href="./values.yaml#L2032">otelCollector.ports.pprof.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1777</pre>
</div>
            </td>
            <td>Service port for pprof.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--pprof--nodePort"><a href="./values.yaml#L2035">otelCollector.ports.pprof.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>NodePort for pprof.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--pprof--protocol"><a href="./values.yaml#L2038">otelCollector.ports.pprof.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for pprof.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsheroku--enabled"><a href="./values.yaml#L2042">otelCollector.ports.logsheroku.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Service port for Heroku logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsheroku--containerPort"><a href="./values.yaml#L2045">otelCollector.ports.logsheroku.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8081</pre>
</div>
            </td>
            <td>Container port for Heroku logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsheroku--servicePort"><a href="./values.yaml#L2048">otelCollector.ports.logsheroku.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8081</pre>
</div>
            </td>
            <td>Service port for Heroku logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsheroku--nodePort"><a href="./values.yaml#L2051">otelCollector.ports.logsheroku.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>NodePort for Heroku logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsheroku--protocol"><a href="./values.yaml#L2054">otelCollector.ports.logsheroku.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for Heroku logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsjson--enabled"><a href="./values.yaml#L2058">otelCollector.ports.logsjson.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Service port for JSON logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsjson--containerPort"><a href="./values.yaml#L2061">otelCollector.ports.logsjson.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8082</pre>
</div>
            </td>
            <td>Container port for JSON logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsjson--servicePort"><a href="./values.yaml#L2064">otelCollector.ports.logsjson.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8082</pre>
</div>
            </td>
            <td>Service port for JSON logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsjson--nodePort"><a href="./values.yaml#L2067">otelCollector.ports.logsjson.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>NodePort for JSON logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsjson--protocol"><a href="./values.yaml#L2070">otelCollector.ports.logsjson.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for JSON logs.</td>
        </tr>
    </tbody>
</table>
<h3>Otel Collector Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="otelCollector--config"><a href="./values.yaml#L2355">otelCollector.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>OpenTelemetry Collector pipeline configuration.</td>
        </tr>
    </tbody>
</table>
<h3>Postgres</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="postgresql--enabled"><a href="./values.yaml#L2496">postgresql.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Install PostgreSQL. Switching an existing release from SQLite to Postgres needs a new release.</td>
        </tr>
        <tr>
            <td id="postgresql--namespace"><a href="./values.yaml#L2499">postgresql.namespace</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Namespace of Postgres. Empty means the release namespace.</td>
        </tr>
        <tr>
            <td id="postgresql--nameOverride"><a href="./values.yaml#L2502">postgresql.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Override the chart name.</td>
        </tr>
        <tr>
            <td id="postgresql--fullnameOverride"><a href="./values.yaml#L2505">postgresql.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Override the full resource name.</td>
        </tr>
        <tr>
            <td id="postgresql--replicaCount"><a href="./values.yaml#L2509">postgresql.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Number of replicas.</td>
        </tr>
        <tr>
            <td id="postgresql--image--repository"><a href="./values.yaml#L2514">postgresql.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">postgres</pre>
</div>
            </td>
            <td>Image repository.</td>
        </tr>
        <tr>
            <td id="postgresql--image--tag"><a href="./values.yaml#L2518">postgresql.image.tag</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"15"</pre>
</div>
            </td>
            <td>Image tag.</td>
        </tr>
        <tr>
            <td id="postgresql--image--pullPolicy"><a href="./values.yaml#L2522">postgresql.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Image pull policy.</td>
        </tr>
        <tr>
            <td id="postgresql--imagePullSecrets"><a href="./values.yaml#L2526">postgresql.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for the Postgres Pod.</td>
        </tr>
        <tr>
            <td id="postgresql--service--annotations"><a href="./values.yaml#L2531">postgresql.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Service.</td>
        </tr>
        <tr>
            <td id="postgresql--service--labels"><a href="./values.yaml#L2535">postgresql.service.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Service.</td>
        </tr>
        <tr>
            <td id="postgresql--service--type"><a href="./values.yaml#L2539">postgresql.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>Kubernetes Service type.</td>
        </tr>
        <tr>
            <td id="postgresql--service--port"><a href="./values.yaml#L2543">postgresql.service.port</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5432</pre>
</div>
            </td>
            <td>Service port.</td>
        </tr>
        <tr>
            <td id="postgresql--auth--username"><a href="./values.yaml#L2548">postgresql.auth.username</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz</pre>
</div>
            </td>
            <td>User to create.</td>
        </tr>
        <tr>
            <td id="postgresql--auth--password"><a href="./values.yaml#L2551">postgresql.auth.password</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz123</pre>
</div>
            </td>
            <td>Password of the user, stored in the Secret `<fullname>-auth` under the key `password`. Ignored when `auth.existingSecret` is set.</td>
        </tr>
        <tr>
            <td id="postgresql--auth--database"><a href="./values.yaml#L2555">postgresql.auth.database</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Database to create.</td>
        </tr>
        <tr>
            <td id="postgresql--auth--existingSecret"><a href="./values.yaml#L2559">postgresql.auth.existingSecret</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of a Secret you created that holds the password. When set, the chart creates no Secret and ignores `auth.password`.</td>
        </tr>
        <tr>
            <td id="postgresql--auth--secretKeys--userPasswordKey"><a href="./values.yaml#L2564">postgresql.auth.secretKeys.userPasswordKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">password</pre>
</div>
            </td>
            <td>Key of the password inside `auth.existingSecret`.</td>
        </tr>
        <tr>
            <td id="postgresql--resources"><a href="./values.yaml#L2568">postgresql.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
        <tr>
            <td id="postgresql--priorityClassName"><a href="./values.yaml#L2572">postgresql.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>PriorityClass of the Pod.</td>
        </tr>
        <tr>
            <td id="postgresql--podSecurityContext"><a href="./values.yaml#L2577">postgresql.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the Pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="postgresql--securityContext"><a href="./values.yaml#L2582">postgresql.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/</td>
        </tr>
        <tr>
            <td id="postgresql--podAnnotations"><a href="./values.yaml#L2586">postgresql.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Pod.</td>
        </tr>
        <tr>
            <td id="postgresql--annotations"><a href="./values.yaml#L2590">postgresql.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Postgres objects.</td>
        </tr>
        <tr>
            <td id="postgresql--nodeSelector"><a href="./values.yaml#L2594">postgresql.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node labels for Pod assignment.</td>
        </tr>
        <tr>
            <td id="postgresql--tolerations"><a href="./values.yaml#L2598">postgresql.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for Pod assignment.</td>
        </tr>
        <tr>
            <td id="postgresql--affinity"><a href="./values.yaml#L2602">postgresql.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for Pod assignment.</td>
        </tr>
        <tr>
            <td id="postgresql--topologySpreadConstraints"><a href="./values.yaml#L2607">postgresql.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for Pod assignment. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/</td>
        </tr>
        <tr>
            <td id="postgresql--livenessProbe--enabled"><a href="./values.yaml#L2612">postgresql.livenessProbe.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the liveness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--livenessProbe--initialDelaySeconds"><a href="./values.yaml#L2616">postgresql.livenessProbe.initialDelaySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">20</pre>
</div>
            </td>
            <td>Initial delay of the liveness probe, in seconds.</td>
        </tr>
        <tr>
            <td id="postgresql--livenessProbe--periodSeconds"><a href="./values.yaml#L2620">postgresql.livenessProbe.periodSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10</pre>
</div>
            </td>
            <td>Period of the liveness probe, in seconds.</td>
        </tr>
        <tr>
            <td id="postgresql--livenessProbe--timeoutSeconds"><a href="./values.yaml#L2624">postgresql.livenessProbe.timeoutSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Timeout of the liveness probe, in seconds.</td>
        </tr>
        <tr>
            <td id="postgresql--livenessProbe--successThreshold"><a href="./values.yaml#L2628">postgresql.livenessProbe.successThreshold</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Success threshold of the liveness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--livenessProbe--failureThreshold"><a href="./values.yaml#L2632">postgresql.livenessProbe.failureThreshold</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">6</pre>
</div>
            </td>
            <td>Failure threshold of the liveness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--readinessProbe--enabled"><a href="./values.yaml#L2637">postgresql.readinessProbe.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the readiness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--readinessProbe--initialDelaySeconds"><a href="./values.yaml#L2641">postgresql.readinessProbe.initialDelaySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Initial delay of the readiness probe, in seconds.</td>
        </tr>
        <tr>
            <td id="postgresql--readinessProbe--periodSeconds"><a href="./values.yaml#L2645">postgresql.readinessProbe.periodSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Period of the readiness probe, in seconds.</td>
        </tr>
        <tr>
            <td id="postgresql--readinessProbe--timeoutSeconds"><a href="./values.yaml#L2649">postgresql.readinessProbe.timeoutSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3</pre>
</div>
            </td>
            <td>Timeout of the readiness probe, in seconds.</td>
        </tr>
        <tr>
            <td id="postgresql--readinessProbe--successThreshold"><a href="./values.yaml#L2653">postgresql.readinessProbe.successThreshold</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Success threshold of the readiness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--readinessProbe--failureThreshold"><a href="./values.yaml#L2657">postgresql.readinessProbe.failureThreshold</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">6</pre>
</div>
            </td>
            <td>Failure threshold of the readiness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--startupProbe--enabled"><a href="./values.yaml#L2662">postgresql.startupProbe.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the startup probe. It passes once Postgres answers and no dump waits at `backups/pre-upgrade.sql`. The liveness and readiness probes start only after it passes.</td>
        </tr>
        <tr>
            <td id="postgresql--startupProbe--initialDelaySeconds"><a href="./values.yaml#L2665">postgresql.startupProbe.initialDelaySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">0</pre>
</div>
            </td>
            <td>Delay before the first startup probe.</td>
        </tr>
        <tr>
            <td id="postgresql--startupProbe--periodSeconds"><a href="./values.yaml#L2668">postgresql.startupProbe.periodSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10</pre>
</div>
            </td>
            <td>Interval between startup probes.</td>
        </tr>
        <tr>
            <td id="postgresql--startupProbe--timeoutSeconds"><a href="./values.yaml#L2671">postgresql.startupProbe.timeoutSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Timeout of each startup probe.</td>
        </tr>
        <tr>
            <td id="postgresql--startupProbe--successThreshold"><a href="./values.yaml#L2674">postgresql.startupProbe.successThreshold</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Consecutive successes for the startup probe to pass. Kubernetes accepts only 1.</td>
        </tr>
        <tr>
            <td id="postgresql--startupProbe--failureThreshold"><a href="./values.yaml#L2678">postgresql.startupProbe.failureThreshold</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">180</pre>
</div>
            </td>
            <td>Consecutive failures before the container is restarted. With the default period, a first start has 30 minutes to load a dump.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--enabled"><a href="./values.yaml#L2683">postgresql.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable persistence with a PersistentVolumeClaim.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--existingClaim"><a href="./values.yaml#L2688">postgresql.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">none, the chart's volume claim template</pre>
</div>
            </td>
            <td>Name of an existing PVC to use. Rendered as a template. `{{ .Release.Name }}-{{ .Chart.Name }}` names the PVC `<release>-postgresql`.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--size"><a href="./values.yaml#L2692">postgresql.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10Gi</pre>
</div>
            </td>
            <td>Size of the PVC.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--storageClass"><a href="./values.yaml#L2696">postgresql.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>StorageClass of the PVC.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--accessModes"><a href="./values.yaml#L2701">postgresql.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access modes of the PVC. Ref: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--mountPath"><a href="./values.yaml#L2708">postgresql.persistence.mountPath</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">/var/lib/postgresql</pre>
</div>
            </td>
            <td>Mount path of the data PVC. At `/var/lib/postgresql`, the chart also mounts the PVC's `data` directory at `/var/lib/postgresql/data`, so the database is on the PVC. Not applied to the official `postgres` image at tag 18 or later, or when an `additionalVolumeMounts` entry uses that path. At any other path, `persistence.dataDir` must be under this one.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--subPath"><a href="./values.yaml#L2712">postgresql.persistence.subPath</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Subpath of the PVC that holds the Postgres data.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--dataDir"><a href="./values.yaml#L2716">postgresql.persistence.dataDir</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">/var/lib/postgresql/data</pre>
</div>
            </td>
            <td>Data directory of Postgres (`PGDATA`). It must be a subdirectory of `persistence.mountPath`. A container that does not run as root cannot initialize the `data` directory. Use `/var/lib/postgresql/pgdata` for it.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--enabled"><a href="./values.yaml#L2725">postgresql.upgradeBackupHook.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Run the pre-upgrade hook Job that dumps a database not on the PVC, for the new Pod to load. Not run on `helm install`, without persistence, with a `persistence.mountPath` other than `/var/lib/postgresql`, with a `persistence.dataDir` outside it, with an `additionalVolumeMounts` entry at or above the data directory, with a `ReadWriteOncePod` PVC, or with `replicaCount: 0`. It runs on the Postgres Pod's node. While that Pod is absent, the upgrade fails after `activeDeadlineSeconds` with `DeadlineExceeded`. When false without a dump taken by hand, a database that is not on the PVC is lost: https://signoz.io/docs/operate/migration/upgrade-0-152/#take-the-postgresql-dump-by-hand</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--activeDeadlineSeconds"><a href="./values.yaml#L2729">postgresql.upgradeBackupHook.activeDeadlineSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">240</pre>
</div>
            </td>
            <td>Time limit of the Job. When it passes, the Job and the upgrade fail. A value of 300 or more needs `helm upgrade --timeout` raised with it.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--resources"><a href="./values.yaml#L2733">postgresql.upgradeBackupHook.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">requests 50m CPU and 64Mi memory, limits 1 CPU and 256Mi memory</pre>
</div>
            </td>
            <td>Resource requests and limits for the container. `null` sets none, and `{}` keeps the defaults.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--nodeSelector"><a href="./values.yaml#L2743">postgresql.upgradeBackupHook.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the value of `nodeSelector`</pre>
</div>
            </td>
            <td>Node labels for Pod assignment. They must match the node of the Postgres Pod.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--tolerations"><a href="./values.yaml#L2746">postgresql.upgradeBackupHook.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for Pod assignment, added to the Postgres Pod's `tolerations`.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--priorityClassName"><a href="./values.yaml#L2750">postgresql.upgradeBackupHook.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the value of `priorityClassName`</pre>
</div>
            </td>
            <td>PriorityClass of the Pod.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--podAnnotations"><a href="./values.yaml#L2753">postgresql.upgradeBackupHook.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Pod.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--podLabels"><a href="./values.yaml#L2756">postgresql.upgradeBackupHook.podLabels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Pod. A key the chart also sets keeps the chart's value.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--annotations"><a href="./values.yaml#L2759">postgresql.upgradeBackupHook.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Job. The `helm.sh/hook`, `helm.sh/hook-weight` and `helm.sh/hook-delete-policy` keys are ignored.</td>
        </tr>
        <tr>
            <td id="postgresql--additionalArgs"><a href="./values.yaml#L2763">postgresql.additionalArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra arguments for the container.</td>
        </tr>
        <tr>
            <td id="postgresql--additionalVolumes"><a href="./values.yaml#L2767">postgresql.additionalVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the Pod.</td>
        </tr>
        <tr>
            <td id="postgresql--additionalVolumeMounts"><a href="./values.yaml#L2771">postgresql.additionalVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the container.</td>
        </tr>
        <tr>
            <td id="postgresql--extraEnv"><a href="./values.yaml#L2775">postgresql.extraEnv</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="postgresql--serviceAccount--create"><a href="./values.yaml#L2780">postgresql.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Create a ServiceAccount.</td>
        </tr>
        <tr>
            <td id="postgresql--serviceAccount--annotations"><a href="./values.yaml#L2784">postgresql.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ServiceAccount.</td>
        </tr>
        <tr>
            <td id="postgresql--serviceAccount--name"><a href="./values.yaml#L2788">postgresql.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of the ServiceAccount. When empty and `create` is true, the chart generates one.</td>
        </tr>
    </tbody>
</table>
<h3>Otel Gateway Settings</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="signoz-otel-gateway"><a href="./values.yaml#L2791">signoz-otel-gateway</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false
strategy: ""</pre>
</div>
            </td>
            <td>signoz-otel-gateway subchart values. Configurable with the licensed version of SigNoz.</td>
        </tr>
    </tbody>
</table>
<h3>signoz-otel-gateway</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="signoz-otel-gateway--strategy"><a href="./values.yaml#L2798">signoz-otel-gateway.strategy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">RollingUpdate</pre>
</div>
            </td>
            <td>Deployment strategy.</td>
        </tr>
    </tbody>
</table>
<h3>Redpanda Settings</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="redpanda"><a href="./values.yaml#L3011">redpanda</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>redpanda subchart values. Configurable with the licensed version of SigNoz.</td>
        </tr>
    </tbody>
</table>

