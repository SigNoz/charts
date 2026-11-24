
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

To uninstall the chart, first delete the ClickHouse resources it created. The steps follow Altinity's [Uninstalling the Operator](https://docs.altinity.com/altinitykubernetesoperator/quickuninstall/).

> [!IMPORTANT]
> Never run `helm uninstall` while the ClickHouse resources exist. `helm uninstall` removes the ClickHouse operator, and only the operator can finish deleting them.

#### Deleting the ClickHouse resources

1. With `keeper.enabled: true`, delete the ClickHouseKeeperInstallation (`chk`):

   ```bash
   kubectl delete chk my-release-keeper -n platform
   ```

2. Delete the ClickHouseInstallation (`chi`). This takes a few minutes:

   ```bash
   kubectl delete chi my-release-clickhouse -n platform
   ```

With `clickhouse.namespace` set, use that namespace in both commands.

#### Deleting the release

```bash
helm uninstall my-release -n platform
```

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

#### If `helm uninstall` ran first

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
            <td>Overrides the Image registry globally for all components.</td>
        </tr>
        <tr>
            <td id="global--imagePullSecrets"><a href="./values.yaml#L15">global.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Secrets for pulling images from a private registry.</td>
        </tr>
        <tr>
            <td id="global--storageClass"><a href="./values.yaml#L20">global.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>StorageClass of the SigNoz, ClickHouse and ZooKeeper claims; when set, it overrides their own `persistence.storageClass`. When neither is set, the cluster's default StorageClass is used; "-" renders an empty storageClassName, which disables dynamic provisioning.</td>
        </tr>
        <tr>
            <td id="global--clusterDomain"><a href="./values.yaml#L25">global.clusterDomain</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster.local</pre>
</div>
            </td>
            <td>The Kubernetes cluster domain. ClickHouse, its operator and ZooKeeper build their pods' host names on it, as does the address of a component in another namespace.</td>
        </tr>
        <tr>
            <td id="global--clusterName"><a href="./values.yaml#L30">global.clusterName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>The Kubernetes cluster name. It is used to attach to telemetry data via the resource detection processor.</td>
        </tr>
        <tr>
            <td id="global--cloud"><a href="./values.yaml#L37">global.cloud</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">other</pre>
</div>
            </td>
            <td>The Kubernetes cluster cloud provider and distribution (if any). example: `aws`, `azure`, `gcp`, `gcp/autogke`, `hcloud`, `other` The storage class for persistent volumes is selected based on this value. When set to 'aws' or 'gcp' with `installCustomStorageClass` enabled, a new expandable storage class is created.</td>
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
            <td id="nameOverride"><a href="./values.yaml#L41">nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Override the default chart name.</td>
        </tr>
        <tr>
            <td id="fullnameOverride"><a href="./values.yaml#L45">fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Override the default full chart name.</td>
        </tr>
        <tr>
            <td id="clusterName"><a href="./values.yaml#L49">clusterName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the K8s cluster. Used by SigNoz OtelCollectors to attach to telemetry data.</td>
        </tr>
        <tr>
            <td id="imagePullSecrets"><a href="./values.yaml#L55">imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Secrets for pulling images from a private registry.</td>
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
            <td id="clickhouse"><a href="./values.yaml#L61">clickhouse</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>The ClickHouse this chart installs, a ClickHouseInstallation that the operator from `altinity-clickhouse-operator` reconciles.</td>
        </tr>
        <tr>
            <td id="clickhouse--enabled"><a href="./values.yaml#L66">clickhouse.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Install ClickHouse, with the operator and ZooKeeper it needs. When false, every component connects to `externalClickhouse` instead, and `externalClickhouse.host` must be set.</td>
        </tr>
        <tr>
            <td id="clickhouse--name"><a href="./values.yaml#L69">clickhouse.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">clickhouse</pre>
</div>
            </td>
            <td>Value of the `app.kubernetes.io/component` label on the ClickHouse objects and pods.</td>
        </tr>
        <tr>
            <td id="clickhouse--nameOverride"><a href="./values.yaml#L73">clickhouse.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Replaces `clickhouse` in the ClickHouse name `<release>-clickhouse` and in its `app.kubernetes.io/name` label.</td>
        </tr>
        <tr>
            <td id="clickhouse--fullnameOverride"><a href="./values.yaml#L78">clickhouse.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the ClickHouseInstallation and its Service in place of `<release>-clickhouse`, and the prefix of its other objects. At most 34 characters, because the operator derives longer names from it; set it when a long release name fails the render.</td>
        </tr>
        <tr>
            <td id="clickhouse--namespace"><a href="./values.yaml#L100">clickhouse.namespace</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Namespace of the ClickHouseInstallation; empty means the release namespace. Any other value makes the chart create that namespace and keep it on uninstall (`helm.sh/resource-policy: keep`), and needs the operator pointed at it.
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
            <td id="clickhouse--image"><a href="./values.yaml#L103">clickhouse.image</a></td>
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
            <td id="clickhouse--image--repository"><a href="./values.yaml#L107">clickhouse.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">clickhouse/clickhouse-server</pre>
</div>
            </td>
            <td>Image repository, optionally prefixed with a registry; `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--tag"><a href="./values.yaml#L111">clickhouse.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">25.12.5</pre>
</div>
            </td>
            <td>ClickHouse server version. SigNoz is tested against this tag; move off it only to a version SigNoz supports.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--pullPolicy"><a href="./values.yaml#L115">clickhouse.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>ClickHouse image pull policy.</td>
        </tr>
        <tr>
            <td id="clickhouse--imagePullSecrets"><a href="./values.yaml#L121">clickhouse.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Secrets for pulling images from a private registry.</td>
        </tr>
        <tr>
            <td id="clickhouse--layout"><a href="./values.yaml#L127">clickhouse.layout</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">replicasCount: 1
shardsCount: 1</pre>
</div>
            </td>
            <td>Shards and replicas of the ClickHouse cluster (experimental), the operator's cluster `layout` rendered as given: https://github.com/Altinity/clickhouse-operator/blob/master/docs/custom_resource_explained.md</td>
        </tr>
        <tr>
            <td id="clickhouse--cluster"><a href="./values.yaml#L133">clickhouse.cluster</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster</pre>
</div>
            </td>
            <td>Name of the ClickHouse cluster, which the migrator creates SigNoz's tables on and SigNoz queries.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount"><a href="./values.yaml#L136">clickhouse.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
create: true
name: null</pre>
</div>
            </td>
            <td>ClickHouse Service Account configuration.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount--create"><a href="./values.yaml#L140">clickhouse.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Create a ServiceAccount for the ClickHouse pod; when false the pod runs as `name`, or as `default` when `name` is empty.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount--annotations"><a href="./values.yaml#L144">clickhouse.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the service account.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount--name"><a href="./values.yaml#L148">clickhouse.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of the ServiceAccount to create (empty: the ClickHouse name), or of an existing one to run as when `create` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--labels"><a href="./values.yaml#L151">clickhouse.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels added to the ClickHouseInstallation.</td>
        </tr>
        <tr>
            <td id="clickhouse--annotations"><a href="./values.yaml#L155">clickhouse.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations added to the ClickHouseInstallation.</td>
        </tr>
        <tr>
            <td id="clickhouse--pod--labels"><a href="./values.yaml#L162">clickhouse.pod.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--pod--annotations"><a href="./values.yaml#L168">clickhouse.pod.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io/scrape, signoz.io/port and signoz.io/path for the metrics endpoint</pre>
</div>
            </td>
            <td>Annotations to add to the pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--service"><a href="./values.yaml#L174">clickhouse.service</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
httpPort: 8123
tcpPort: 9000
type: ClusterIP</pre>
</div>
            </td>
            <td>ClickHouse service configuration.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--annotations"><a href="./values.yaml#L178">clickhouse.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ClickHouse service.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--type"><a href="./values.yaml#L182">clickhouse.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>Type of the ClickHouse Service; `LoadBalancer` or `NodePort` exposes ClickHouse outside the cluster.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--httpPort"><a href="./values.yaml#L186">clickhouse.service.httpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8123</pre>
</div>
            </td>
            <td>HTTP port of the ClickHouse Service, which the components connect to.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--tcpPort"><a href="./values.yaml#L190">clickhouse.service.tcpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">9000</pre>
</div>
            </td>
            <td>Native TCP port of the ClickHouse Service, which SigNoz, the collector and the migrator connect to.</td>
        </tr>
        <tr>
            <td id="clickhouse--database"><a href="./values.yaml#L194">clickhouse.database</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_metrics</pre>
</div>
            </td>
            <td>Database the collector writes metrics to.</td>
        </tr>
        <tr>
            <td id="clickhouse--traceDatabase"><a href="./values.yaml#L198">clickhouse.traceDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_traces</pre>
</div>
            </td>
            <td>Database the collector writes traces to.</td>
        </tr>
        <tr>
            <td id="clickhouse--logDatabase"><a href="./values.yaml#L202">clickhouse.logDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_logs</pre>
</div>
            </td>
            <td>Database the collector writes logs to.</td>
        </tr>
        <tr>
            <td id="clickhouse--meterDatabase"><a href="./values.yaml#L206">clickhouse.meterDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_meter</pre>
</div>
            </td>
            <td>Database the collector writes meter data to.</td>
        </tr>
        <tr>
            <td id="clickhouse--user"><a href="./values.yaml#L210">clickhouse.user</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">admin</pre>
</div>
            </td>
            <td>ClickHouse user the installation creates and every component connects as.</td>
        </tr>
        <tr>
            <td id="clickhouse--password"><a href="./values.yaml#L220">clickhouse.password</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">27ff0399-0d3a-4bd8-919d-17c2181e6fb9</pre>
</div>
            </td>
            <td>Password of `clickhouse.user`.</td>
        </tr>
        <tr>
            <td id="clickhouse--existingSecret"><a href="./values.yaml#L228">clickhouse.existingSecret</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of a Secret you created that holds the password of `clickhouse.user`.</td>
        </tr>
        <tr>
            <td id="clickhouse--existingSecretPasswordKey"><a href="./values.yaml#L232">clickhouse.existingSecretPasswordKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">password</pre>
</div>
            </td>
            <td>Key of the password inside `clickhouse.existingSecret`.</td>
        </tr>
        <tr>
            <td id="clickhouse--existingSecretPasswordSha256Key"><a href="./values.yaml#L241">clickhouse.existingSecretPasswordSha256Key</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Key of the password's SHA-256 hex inside `clickhouse.existingSecret`.</td>
        </tr>
        <tr>
            <td id="clickhouse--secure"><a href="./values.yaml#L245">clickhouse.secure</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Passed as `CLICKHOUSE_SECURE` to the pods that connect to ClickHouse.</td>
        </tr>
        <tr>
            <td id="clickhouse--verify"><a href="./values.yaml#L249">clickhouse.verify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Passed as `CLICKHOUSE_VERIFY` to the pods that connect to ClickHouse.</td>
        </tr>
        <tr>
            <td id="clickhouse--allowedNetworkIps"><a href="./values.yaml#L253">clickhouse.allowedNetworkIps</a></td>
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
            <td>Networks `clickhouse.user` may connect from, as addresses or CIDR ranges. The defaults are the private ranges; add any other range a client connects from.</td>
        </tr>
        <tr>
            <td id="clickhouse--externalZookeeper"><a href="./values.yaml#L273">clickhouse.externalZookeeper</a></td>
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
            <td id="clickhouse--profiles"><a href="./values.yaml#L286">clickhouse.profiles</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ClickHouse settings profiles, one key per profile and setting; they override `defaultProfiles`. Settings: https://clickhouse.com/docs/en/operations/settings/settings/
A 40 GB memory cap on each query run under the default profile:

  ```yaml
  default/max_memory_usage: 40000000000
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--defaultProfiles"><a href="./values.yaml#L290">clickhouse.defaultProfiles</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Profile settings SigNoz's queries rely on. Do not replace this map; override a single setting through `clickhouse.profiles`.</td>
        </tr>
        <tr>
            <td id="clickhouse--settings"><a href="./values.yaml#L308">clickhouse.settings</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>ClickHouse server settings, keyed by their path in the server config; they override `defaultSettings`. The `prometheus/*` defaults serve the metrics that `clickhouse.pod.annotations` point at. Settings: https://clickhouse.com/docs/en/operations/server-configuration-parameters/settings
Debug logging, the `level` setting under `logger`:

  ```yaml
  logger/level: debug
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--defaultSettings"><a href="./values.yaml#L318">clickhouse.defaultSettings</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">format_schema_path: /etc/clickhouse-server/config.d/
user_defined_executable_functions_config: /etc/clickhouse-server/functions/custom-functions.xml
user_scripts_path: /var/lib/clickhouse/user_scripts/</pre>
</div>
            </td>
            <td>Server settings that load the histogramQuantile function and set the format schema directory. Do not replace this map; override a single setting through `clickhouse.settings`.</td>
        </tr>
        <tr>
            <td id="clickhouse--files"><a href="./values.yaml#L335">clickhouse.files</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>ClickHouse configuration files, keyed by path; files under `config.d/` merge into the server config.
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
            <td id="clickhouse--templates"><a href="./values.yaml#L382">clickhouse.templates</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">volumeClaimTemplates: []</pre>
</div>
            </td>
            <td>Volume claim templates of the ClickHouse installation, used only when `clickhouse.persistence.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--templates--volumeClaimTemplates"><a href="./values.yaml#L400">clickhouse.templates.volumeClaimTemplates</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Volume claim templates added when `persistence.enabled` is false. Mount each through `clickhouse.extraVolumeMounts` under the same `name`; without a mount at `/var/lib/clickhouse` the data is not kept.
Each entry takes these four fields, here a 50Gi claim named `data`:

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
            <td id="clickhouse--podDistribution"><a href="./values.yaml#L406">clickhouse.podDistribution</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Operator rules that spread the ClickHouse pods across nodes, rendered as given; types: https://github.com/Altinity/clickhouse-operator/blob/1414503921da3ae475eb6f9a296d3475a6993768/docs/chi-examples/99-clickhouseinstallation-max.yaml#L428-L481</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage"><a href="./values.yaml#L418">clickhouse.coldStorage</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>S3 or GCS disk added as the `s3` volume of a `tiered` storage policy, where SigNoz's retention settings move older data.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--enabled"><a href="./values.yaml#L422">clickhouse.coldStorage.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable S3/GCS cold storage.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--defaultKeepFreeSpaceBytes"><a href="./values.yaml#L426">clickhouse.coldStorage.defaultKeepFreeSpaceBytes</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"10485760"</pre>
</div>
            </td>
            <td>Reserve free space on the default disk (in bytes).</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--type"><a href="./values.yaml#L430">clickhouse.coldStorage.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">s3</pre>
</div>
            </td>
            <td>Type of cold storage: `s3` or `gcs`.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--endpoint"><a href="./values.yaml#L447">clickhouse.coldStorage.endpoint</a></td>
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
            <td id="clickhouse--coldStorage--accessKey"><a href="./values.yaml#L452">clickhouse.coldStorage.accessKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml"><access_key_id></pre>
</div>
            </td>
            <td>Access Key ID for S3 or GCS. Used for `gcs`, and for `s3` when `role.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--secretAccess"><a href="./values.yaml#L457">clickhouse.coldStorage.secretAccess</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml"><secret_access_key></pre>
</div>
            </td>
            <td>Secret Access Key for S3 or GCS. Used for `gcs`, and for `s3` when `role.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--role"><a href="./values.yaml#L460">clickhouse.coldStorage.role</a></td>
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
            <td id="clickhouse--coldStorage--role--enabled"><a href="./values.yaml#L464">clickhouse.coldStorage.role.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Use the role for `s3`: ClickHouse takes credentials from its environment instead of `accessKey` and `secretAccess`.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--role--annotations"><a href="./values.yaml#L467">clickhouse.coldStorage.role.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">eks.amazonaws.com/role-arn: arn:aws:iam::******:role/*****</pre>
</div>
            </td>
            <td>ServiceAccount annotations that bind the role, added when `coldStorage.enabled` and `role.enabled` are both true.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs"><a href="./values.yaml#L473">clickhouse.logs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Sidecar collector in the ClickHouse pod that sends `system.query_log` entries as logs to an OTLP receiver on the node's port 4317, such as the k8s-infra agent.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--enabled"><a href="./values.yaml#L477">clickhouse.logs.system.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable collection of system table entries as logs</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--image--repository"><a href="./values.yaml#L482">clickhouse.logs.system.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/signoz-otel-collector</pre>
</div>
            </td>
            <td>Image repository, optionally prefixed with a registry; `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--image--tag"><a href="./values.yaml#L486">clickhouse.logs.system.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v0.144.15</pre>
</div>
            </td>
            <td>Tag of the system logs sidecar image.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--image--pullPolicy"><a href="./values.yaml#L490">clickhouse.logs.system.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Pull policy of the system logs sidecar image.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--resources"><a href="./values.yaml#L494">clickhouse.logs.system.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resources of the system logs sidecar container, a Kubernetes ResourceRequirements object rendered as given.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--env"><a href="./values.yaml#L499">clickhouse.logs.system.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--envFrom"><a href="./values.yaml#L504">clickhouse.logs.system.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Sources of extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--extraVolumeMounts"><a href="./values.yaml#L509">clickhouse.logs.system.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the container.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--config"><a href="./values.yaml#L513">clickhouse.logs.system.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Configuration of the sidecar collector, rendered as given into its config file.</td>
        </tr>
        <tr>
            <td id="clickhouse--installCustomStorageClass"><a href="./values.yaml#L563">clickhouse.installCustomStorageClass</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create an expandable StorageClass: `gp2-resizable` when `global.cloud` starts with `aws`, `gce-resizable` when it starts with `gcp`. No volume uses it until `clickhouse.persistence.storageClass` names it.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook"><a href="./values.yaml#L568">clickhouse.operatorUpgradeHook</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Pre-upgrade Job that deletes the operator Deployment an older chart created, whose selector labels cannot change in place; it matches nothing afterwards. When disabled, delete that Deployment yourself before upgrading: `kubectl delete deployment <release>-clickhouse-operator -n <namespace>`.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--enabled"><a href="./values.yaml#L571">clickhouse.operatorUpgradeHook.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Run the hook on `helm upgrade`.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--repository"><a href="./values.yaml#L575">clickhouse.operatorUpgradeHook.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">registry.k8s.io/kubectl</pre>
</div>
            </td>
            <td>Image repository, optionally prefixed with a registry; `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--tag"><a href="./values.yaml#L578">clickhouse.operatorUpgradeHook.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v1.36.3</pre>
</div>
            </td>
            <td>Tag of the kubectl image. The image publishes no `latest` tag.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--pullPolicy"><a href="./values.yaml#L581">clickhouse.operatorUpgradeHook.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Pull policy of the kubectl image.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--backoffLimit"><a href="./values.yaml#L584">clickhouse.operatorUpgradeHook.backoffLimit</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3</pre>
</div>
            </td>
            <td>Retries before the Job, and with it the upgrade, is marked failed.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--resources"><a href="./values.yaml#L587">clickhouse.operatorUpgradeHook.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resources of the hook container.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--nodeSelector"><a href="./values.yaml#L592">clickhouse.operatorUpgradeHook.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node labels for pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--tolerations"><a href="./values.yaml#L595">clickhouse.operatorUpgradeHook.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--affinity"><a href="./values.yaml#L598">clickhouse.operatorUpgradeHook.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--topologySpreadConstraints"><a href="./values.yaml#L601">clickhouse.operatorUpgradeHook.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--priorityClassName"><a href="./values.yaml#L605">clickhouse.operatorUpgradeHook.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class of the pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--podSecurityContext"><a href="./values.yaml#L609">clickhouse.operatorUpgradeHook.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--containerSecurityContext"><a href="./values.yaml#L614">clickhouse.operatorUpgradeHook.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the container.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--enabled"><a href="./values.yaml#L620">clickhouse.udf.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Download the histogramQuantile binary, which SigNoz's histogram percentile queries call, from GitHub in an init container. Without GitHub access, set it to false and supply the binary through `clickhouse.extraInitContainers`.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--command"><a href="./values.yaml#L624">clickhouse.udf.command</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Command of the download init container; by default it fetches the histogramQuantile release for the node's OS and architecture.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--env"><a href="./values.yaml#L655">clickhouse.udf.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Environment of the download init container, Kubernetes EnvVar objects rendered as given.
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
            <td id="clickhouse--udf--envFrom"><a href="./values.yaml#L659">clickhouse.udf.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>envFrom of the download init container, Kubernetes EnvFromSource objects rendered as given.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--resources"><a href="./values.yaml#L663">clickhouse.udf.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resource requests and limits of the download init container; empty sets none, so set it where a policy requires limits on every container.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--extraVolumeMounts"><a href="./values.yaml#L668">clickhouse.udf.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the container.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraInitContainers"><a href="./values.yaml#L672">clickhouse.extraInitContainers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Init containers added to the ClickHouse pod after the histogramQuantile download, Kubernetes Container objects rendered as given. The user scripts volume is `shared-binary-volume`, mounted at `/var/lib/clickhouse/user_scripts`.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraContainers"><a href="./values.yaml#L675">clickhouse.extraContainers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra containers in the ClickHouse pod, Kubernetes Container objects rendered as given.</td>
        </tr>
        <tr>
            <td id="clickhouse--startupProbe"><a href="./values.yaml#L690">clickhouse.startupProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Startup probe of the ClickHouse container, a Kubernetes probe object rendered as given; `null` renders none. Helm merges your map into the default, so a handler other than `httpGet` must also clear `httpGet`.
A TCP check on the native port in place of the HTTP one:

  ```yaml
  httpGet: null
  tcpSocket:
    port: 9000
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--livenessProbe"><a href="./values.yaml#L712">clickhouse.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Liveness probe of the ClickHouse container, a Kubernetes probe object rendered as given; `null` renders none. Helm merges your map into the default, so a handler other than `httpGet` must also clear `httpGet`.
A TCP check on the native port in place of the HTTP one:

  ```yaml
  httpGet: null
  tcpSocket:
    port: 9000
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--readinessProbe"><a href="./values.yaml#L734">clickhouse.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Readiness probe of the ClickHouse container, a Kubernetes probe object rendered as given; `null` renders none. Helm merges your map into the default, so a handler other than `httpGet` must also clear `httpGet`.
A TCP check on the native port in place of the HTTP one:

  ```yaml
  httpGet: null
  tcpSocket:
    port: 9000
  ```
</td>
        </tr>
        <tr>
            <td id="clickhouse--resources"><a href="./values.yaml#L746">clickhouse.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">requests:
    cpu: 100m
    memory: 200Mi</pre>
</div>
            </td>
            <td>Resources of the ClickHouse container, a Kubernetes ResourceRequirements object rendered as given; size them for your load.</td>
        </tr>
        <tr>
            <td id="clickhouse--podSecurityContext"><a href="./values.yaml#L757">clickhouse.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">fsGroup: 101
fsGroupChangePolicy: OnRootMismatch
runAsGroup: 101
runAsUser: 101</pre>
</div>
            </td>
            <td>Security context of the ClickHouse pod, a Kubernetes PodSecurityContext object rendered as given; `null` renders none, while `{}` keeps the defaults, since Helm merges maps.</td>
        </tr>
        <tr>
            <td id="clickhouse--containerSecurityContext"><a href="./values.yaml#L777">clickhouse.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context of every container the chart renders in the ClickHouse pod; rendered only when set.
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
            <td id="clickhouse--priorityClassName"><a href="./values.yaml#L780">clickhouse.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class of the ClickHouse pods; empty sets none.</td>
        </tr>
        <tr>
            <td id="clickhouse--nodeSelector"><a href="./values.yaml#L784">clickhouse.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for assigning the ClickHouse pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--tolerations"><a href="./values.yaml#L788">clickhouse.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Toleration labels for ClickHouse pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--affinity"><a href="./values.yaml#L792">clickhouse.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for the ClickHouse pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--topologySpreadConstraints"><a href="./values.yaml#L795">clickhouse.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints of the ClickHouse pods, Kubernetes objects rendered as given.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence"><a href="./values.yaml#L799">clickhouse.persistence</a></td>
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
            <td id="clickhouse--persistence--enabled"><a href="./values.yaml#L804">clickhouse.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Keep ClickHouse data on a PersistentVolumeClaim. When false, the data lives in an `emptyDir` and is lost with the pod, unless `clickhouse.templates.volumeClaimTemplates` provides volumes.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--existingClaim"><a href="./values.yaml#L808">clickhouse.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of a PersistentVolumeClaim you created for the ClickHouse data, used instead of a claim from the template.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--storageClass"><a href="./values.yaml#L813">clickhouse.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>StorageClass of the ClickHouse data claim; `-` disables dynamic provisioning, null uses the cluster default, and `global.storageClass` overrides it.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--accessModes"><a href="./values.yaml#L817">clickhouse.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access Modes for the persistent volume.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--size"><a href="./values.yaml#L822">clickhouse.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">20Gi</pre>
</div>
            </td>
            <td>Persistent Volume size.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraVolumes"><a href="./values.yaml#L825">clickhouse.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the ClickHouse pod, a list of Kubernetes Volume objects.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraVolumeMounts"><a href="./values.yaml#L828">clickhouse.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the ClickHouse container, a list of Kubernetes VolumeMount objects.</td>
        </tr>
        <tr>
            <td id="clickhouse--env"><a href="./values.yaml#L833">clickhouse.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="clickhouse--envFrom"><a href="./values.yaml#L838">clickhouse.envFrom</a></td>
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
            <td id="keeper--enabled"><a href="./values.yaml#L846">keeper.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Install Keeper.</td>
        </tr>
        <tr>
            <td id="keeper--name"><a href="./values.yaml#L850">keeper.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">keeper</pre>
</div>
            </td>
            <td>Name of the ClickHouse Keeper component, the `app.kubernetes.io/name` label of its objects.</td>
        </tr>
        <tr>
            <td id="keeper--nameOverride"><a href="./values.yaml#L854">keeper.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Override the chart name.</td>
        </tr>
        <tr>
            <td id="keeper--fullnameOverride"><a href="./values.yaml#L858">keeper.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Override the full resource name.</td>
        </tr>
        <tr>
            <td id="keeper--image--repository"><a href="./values.yaml#L863">keeper.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">clickhouse/clickhouse-keeper</pre>
</div>
            </td>
            <td>Image repository.</td>
        </tr>
        <tr>
            <td id="keeper--image--tag"><a href="./values.yaml#L867">keeper.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">25.12.5</pre>
</div>
            </td>
            <td>Image tag.</td>
        </tr>
        <tr>
            <td id="keeper--image--pullPolicy"><a href="./values.yaml#L870">keeper.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Image pull policy.</td>
        </tr>
        <tr>
            <td id="keeper--imagePullSecrets"><a href="./values.yaml#L874">keeper.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Secrets for pulling images from a private registry.</td>
        </tr>
        <tr>
            <td id="keeper--replicaCount"><a href="./values.yaml#L879">keeper.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Number of replicas.</td>
        </tr>
        <tr>
            <td id="keeper--labels"><a href="./values.yaml#L883">keeper.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the ClickHouseKeeperInstallation.</td>
        </tr>
        <tr>
            <td id="keeper--annotations"><a href="./values.yaml#L886">keeper.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ClickHouseKeeperInstallation.</td>
        </tr>
        <tr>
            <td id="keeper--pod--labels"><a href="./values.yaml#L891">keeper.pod.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the pod.</td>
        </tr>
        <tr>
            <td id="keeper--pod--annotations"><a href="./values.yaml#L897">keeper.pod.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Annotations to add to the pod.</td>
        </tr>
        <tr>
            <td id="keeper--settings"><a href="./values.yaml#L906">keeper.settings</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>ClickHouse Keeper server settings, rendered into the installation's `configuration.settings`.</td>
        </tr>
        <tr>
            <td id="keeper--podSecurityContext"><a href="./values.yaml#L924">keeper.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Security context for the pod.</td>
        </tr>
        <tr>
            <td id="keeper--containerSecurityContext"><a href="./values.yaml#L930">keeper.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">no container security context</pre>
</div>
            </td>
            <td>Security context for the container.</td>
        </tr>
        <tr>
            <td id="keeper--env"><a href="./values.yaml#L934">keeper.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="keeper--envFrom"><a href="./values.yaml#L938">keeper.envFrom</a></td>
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
            <td>Extra volumes for the pod.</td>
        </tr>
        <tr>
            <td id="keeper--extraVolumeMounts"><a href="./values.yaml#L946">keeper.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the container.</td>
        </tr>
        <tr>
            <td id="keeper--resources"><a href="./values.yaml#L950">keeper.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
        <tr>
            <td id="keeper--priorityClassName"><a href="./values.yaml#L958">keeper.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">no priority class</pre>
</div>
            </td>
            <td>Priority class of the pod.</td>
        </tr>
        <tr>
            <td id="keeper--nodeSelector"><a href="./values.yaml#L961">keeper.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node labels for pod assignment.</td>
        </tr>
        <tr>
            <td id="keeper--tolerations"><a href="./values.yaml#L964">keeper.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="keeper--affinity"><a href="./values.yaml#L967">keeper.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for pod assignment.</td>
        </tr>
        <tr>
            <td id="keeper--topologySpreadConstraints"><a href="./values.yaml#L970">keeper.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod assignment.</td>
        </tr>
        <tr>
            <td id="keeper--podDistribution"><a href="./values.yaml#L974">keeper.podDistribution</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topologies for distributing the ClickHouse Keeper pods, in the operator's `podDistribution` format.</td>
        </tr>
        <tr>
            <td id="keeper--persistence--accessModes"><a href="./values.yaml#L979">keeper.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access modes of the claim.</td>
        </tr>
        <tr>
            <td id="keeper--persistence--size"><a href="./values.yaml#L983">keeper.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10Gi</pre>
</div>
            </td>
            <td>Size of the claim.</td>
        </tr>
        <tr>
            <td id="keeper--persistence--storageClass"><a href="./values.yaml#L988">keeper.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the default provisioner</pre>
</div>
            </td>
            <td>StorageClass of the claim.</td>
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
            <td id="zookeeper"><a href="./values.yaml#L994">zookeeper</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Values of the bundled ZooKeeper chart, which ClickHouse coordinates through when `zookeeper.enabled` is true; its keys follow Bitnami's chart: https://github.com/bitnami/charts/blob/main/bitnami/zookeeper/values.yaml</td>
        </tr>
        <tr>
            <td id="zookeeper--enabled"><a href="./values.yaml#L999">zookeeper.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Install the bundled ZooKeeper. Deprecated: ClickHouse Keeper (`keeper.enabled`) is the default coordination store, and unset now means off. An existing install that runs ZooKeeper sets this to true for the upgrade together with `keeper.enabled: false`, or after applying the Keeper CRD, and keeps it until it has moved to Keeper; see https://signoz.io/docs/operate/migration/upgrade-0-152/</td>
        </tr>
        <tr>
            <td id="zookeeper--commonAnnotations"><a href="./values.yaml#L1003">zookeeper.commonAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io/deprecated: "true"</pre>
</div>
            </td>
            <td>Annotations on the metadata of every ZooKeeper object (not on the pod template).</td>
        </tr>
        <tr>
            <td id="zookeeper--image"><a href="./values.yaml#L1008">zookeeper.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">registry: null
repository: signoz/zookeeper
tag: 3.7.1</pre>
</div>
            </td>
            <td>Zookeeper image</td>
        </tr>
        <tr>
            <td id="zookeeper--image--registry"><a href="./values.yaml#L1011">zookeeper.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Zookeeper image registry to use.</td>
        </tr>
        <tr>
            <td id="zookeeper--image--repository"><a href="./values.yaml#L1014">zookeeper.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/zookeeper</pre>
</div>
            </td>
            <td>Zookeeper image repository to use.</td>
        </tr>
        <tr>
            <td id="zookeeper--image--tag"><a href="./values.yaml#L1017">zookeeper.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3.7.1</pre>
</div>
            </td>
            <td>ZooKeeper version; ClickHouse does not work with every ZooKeeper version, so change it only to one ClickHouse supports.</td>
        </tr>
        <tr>
            <td id="zookeeper--nameOverride"><a href="./values.yaml#L1021">zookeeper.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Replaces `zookeeper` in the ZooKeeper name `<release>-zookeeper`, by which the ClickHouse installation finds it.</td>
        </tr>
        <tr>
            <td id="zookeeper--fullnameOverride"><a href="./values.yaml#L1024">zookeeper.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the ZooKeeper objects in place of `<release>-zookeeper`, by which the ClickHouse installation finds it.</td>
        </tr>
        <tr>
            <td id="zookeeper--namespaceOverride"><a href="./values.yaml#L1028">zookeeper.namespaceOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Namespace of ZooKeeper, which must already exist; empty means the release namespace.</td>
        </tr>
        <tr>
            <td id="zookeeper--podAnnotations"><a href="./values.yaml#L1032">zookeeper.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io/path: /metrics
signoz.io/port: "9141"
signoz.io/scrape: "true"</pre>
</div>
            </td>
            <td>Annotations on the ZooKeeper pods; the `signoz.io/*` defaults let the SigNoz collectors scrape its metrics on port 9141.</td>
        </tr>
        <tr>
            <td id="zookeeper--autopurge"><a href="./values.yaml#L1039">zookeeper.autopurge</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">purgeInterval: 1</pre>
</div>
            </td>
            <td>Periodic purge of old ZooKeeper snapshots and transaction logs.</td>
        </tr>
        <tr>
            <td id="zookeeper--autopurge--purgeInterval"><a href="./values.yaml#L1042">zookeeper.autopurge.purgeInterval</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Hours between purges; 0 disables purging.</td>
        </tr>
        <tr>
            <td id="zookeeper--metrics"><a href="./values.yaml#L1046">zookeeper.metrics</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: true
service:
    annotations: {}
    enabled: true</pre>
</div>
            </td>
            <td>ZooKeeper Prometheus Exporter configuration.</td>
        </tr>
        <tr>
            <td id="zookeeper--metrics--enabled"><a href="./values.yaml#L1049">zookeeper.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Serve ZooKeeper's Prometheus metrics on port 9141, the port `podAnnotations` point the collectors at.</td>
        </tr>
        <tr>
            <td id="zookeeper--metrics--service--annotations"><a href="./values.yaml#L1055">zookeeper.metrics.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ZooKeeper metrics service annotation</td>
        </tr>
        <tr>
            <td id="zookeeper--logLevel"><a href="./values.yaml#L1062">zookeeper.logLevel</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">INFO</pre>
</div>
            </td>
            <td>Zookeeper log level.</td>
        </tr>
        <tr>
            <td id="zookeeper--livenessProbe"><a href="./values.yaml#L1066">zookeeper.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>Bitnami's built-in liveness probe, off because `customLivenessProbe` replaces it.</td>
        </tr>
        <tr>
            <td id="zookeeper--readinessProbe"><a href="./values.yaml#L1070">zookeeper.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>Bitnami's built-in readiness probe, off because `customReadinessProbe` replaces it.</td>
        </tr>
        <tr>
            <td id="zookeeper--customLivenessProbe"><a href="./values.yaml#L1074">zookeeper.customLivenessProbe</a></td>
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
            <td>Liveness probe of the ZooKeeper container: the `ruok` command on its admin server at port 8080.</td>
        </tr>
        <tr>
            <td id="zookeeper--customReadinessProbe"><a href="./values.yaml#L1084">zookeeper.customReadinessProbe</a></td>
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
            <td>Readiness probe of the ZooKeeper container: ready once the admin server's `ruok` command reports no error.</td>
        </tr>
        <tr>
            <td id="zookeeper--minServerId"><a href="./values.yaml#L1095">zookeeper.minServerId</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>ZooKeeper server ID of the first replica; each further replica takes the next ID.</td>
        </tr>
        <tr>
            <td id="zookeeper--replicaCount"><a href="./values.yaml#L1099">zookeeper.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Number of ZooKeeper replicas, each listed as a coordination node of the ClickHouse installation; use an odd number to keep a quorum.</td>
        </tr>
        <tr>
            <td id="zookeeper--pdb"><a href="./values.yaml#L1103">zookeeper.pdb</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">create: false</pre>
</div>
            </td>
            <td>PodDisruptionBudget of the ZooKeeper pods.</td>
        </tr>
        <tr>
            <td id="zookeeper--pdb--create"><a href="./values.yaml#L1106">zookeeper.pdb.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Specifies whether a Pod Disruption Budget should be created</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence"><a href="./values.yaml#L1110">zookeeper.persistence</a></td>
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
            <td id="zookeeper--persistence--enabled"><a href="./values.yaml#L1113">zookeeper.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable ZooKeeper data persistence using PVC. If false, use emptyDir</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--existingClaim"><a href="./values.yaml#L1117">zookeeper.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of an existing PVC to use (only when deploying a single replica)</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--storageClass"><a href="./values.yaml#L1121">zookeeper.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>StorageClass of the ZooKeeper data claim; `-` disables dynamic provisioning, null uses the cluster default, and `global.storageClass` overrides it.</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--accessModes"><a href="./values.yaml#L1125">zookeeper.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>PVC Access modes</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--size"><a href="./values.yaml#L1130">zookeeper.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8Gi</pre>
</div>
            </td>
            <td>PVC Storage Request for ZooKeeper data volume</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--annotations"><a href="./values.yaml#L1134">zookeeper.persistence.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the PVC</td>
        </tr>
        <tr>
            <td id="zookeeper--resources"><a href="./values.yaml#L1138">zookeeper.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">limits: {}
requests:
    cpu: 100m
    memory: 256Mi</pre>
</div>
            </td>
            <td>Resources requests and limits for zookeeper</td>
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
            <td id="externalClickhouse"><a href="./values.yaml#L1355">externalClickhouse</a></td>
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
            <td>External ClickHouse configuration. Required when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--host"><a href="./values.yaml#L1360">externalClickhouse.host</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Host of the external ClickHouse cluster. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--cluster"><a href="./values.yaml#L1365">externalClickhouse.cluster</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster</pre>
</div>
            </td>
            <td>Cluster of the external ClickHouse that the migrator creates SigNoz's tables on and SigNoz queries. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--database"><a href="./values.yaml#L1370">externalClickhouse.database</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_metrics</pre>
</div>
            </td>
            <td>Database the collector writes metrics to. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--traceDatabase"><a href="./values.yaml#L1375">externalClickhouse.traceDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_traces</pre>
</div>
            </td>
            <td>Database the collector writes traces to. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--logDatabase"><a href="./values.yaml#L1380">externalClickhouse.logDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_logs</pre>
</div>
            </td>
            <td>Database the collector writes logs to. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--meterDatabase"><a href="./values.yaml#L1385">externalClickhouse.meterDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_meter</pre>
</div>
            </td>
            <td>Database the collector writes meter data to. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--user"><a href="./values.yaml#L1390">externalClickhouse.user</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Username to connect to the external cluster. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--password"><a href="./values.yaml#L1396">externalClickhouse.password</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Password of `externalClickhouse.user`, written into the Secret `<clickhouse.fullname>-credentials` that the components read; ignored when `externalClickhouse.existingSecret` is set. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--existingSecret"><a href="./values.yaml#L1402">externalClickhouse.existingSecret</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of a Secret you created that holds the password of `externalClickhouse.user`; when set, the chart creates no Secret and the components read this one. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--existingSecretPasswordKey"><a href="./values.yaml#L1407">externalClickhouse.existingSecretPasswordKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">password</pre>
</div>
            </td>
            <td>Key of the password inside `externalClickhouse.existingSecret`. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--secure"><a href="./values.yaml#L1413">externalClickhouse.secure</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Connect to an external ClickHouse behind TLS by appending `?secure=true` to the SigNoz and migrator connection strings. Set `externalClickhouse.tcpPort` to its secure port, usually 9440, and add the same parameters to the exporter connection strings in `otelCollector.config` by hand. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--verify"><a href="./values.yaml#L1419">externalClickhouse.verify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>With `externalClickhouse.secure` true, whether to verify the server's TLS certificate. False appends `&skip_verify=true` to the SigNoz and migrator connection strings; add it to the exporter connection strings in `otelCollector.config` by hand. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--httpPort"><a href="./values.yaml#L1424">externalClickhouse.httpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8123</pre>
</div>
            </td>
            <td>HTTP port of the external ClickHouse instance. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--tcpPort"><a href="./values.yaml#L1429">externalClickhouse.tcpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">9000</pre>
</div>
            </td>
            <td>TCP port of the external ClickHouse instance. Used only when `clickhouse.enabled` is false.</td>
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
            <td id="signoz--name"><a href="./values.yaml#L1435">signoz.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz</pre>
</div>
            </td>
            <td>Name of the SigNoz component.</td>
        </tr>
        <tr>
            <td id="signoz--replicaCount"><a href="./values.yaml#L1440">signoz.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Number of replicas.</td>
        </tr>
        <tr>
            <td id="signoz--image--repository"><a href="./values.yaml#L1446">signoz.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">docker.io/signoz/signoz</pre>
</div>
            </td>
            <td>Image repository.</td>
        </tr>
        <tr>
            <td id="signoz--image--tag"><a href="./values.yaml#L1450">signoz.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v0.151.0</pre>
</div>
            </td>
            <td>Image tag.</td>
        </tr>
        <tr>
            <td id="signoz--image--pullPolicy"><a href="./values.yaml#L1453">signoz.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Image pull policy.</td>
        </tr>
        <tr>
            <td id="signoz--imagePullSecrets"><a href="./values.yaml#L1457">signoz.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Secrets for pulling images from a private registry.</td>
        </tr>
        <tr>
            <td id="signoz--serviceAccount--create"><a href="./values.yaml#L1461">signoz.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Create a ServiceAccount.</td>
        </tr>
        <tr>
            <td id="signoz--serviceAccount--annotations"><a href="./values.yaml#L1464">signoz.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ServiceAccount.</td>
        </tr>
        <tr>
            <td id="signoz--serviceAccount--name"><a href="./values.yaml#L1470">signoz.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the release's full name, or default</pre>
</div>
            </td>
            <td>Name of the ServiceAccount.</td>
        </tr>
        <tr>
            <td id="signoz--annotations"><a href="./values.yaml#L1515">signoz.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">no annotations</pre>
</div>
            </td>
            <td>Annotations to add to the StatefulSet.</td>
        </tr>
        <tr>
            <td id="signoz--labels"><a href="./values.yaml#L1520">signoz.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the StatefulSet.</td>
        </tr>
        <tr>
            <td id="signoz--extraArgs"><a href="./values.yaml#L1525">signoz.extraArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra arguments for the container.</td>
        </tr>
        <tr>
            <td id="signoz--env"><a href="./values.yaml#L1548">signoz.env</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the five SigNoz settings in values.yaml</pre>
</div>
            </td>
            <td>Extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="signoz--envFrom"><a href="./values.yaml#L1567">signoz.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Sources of extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="signoz--podSecurityContext"><a href="./values.yaml#L1572">signoz.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the pod.</td>
        </tr>
        <tr>
            <td id="signoz--pod--annotations"><a href="./values.yaml#L1576">signoz.pod.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the pod.</td>
        </tr>
        <tr>
            <td id="signoz--pod--labels"><a href="./values.yaml#L1581">signoz.pod.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the pod.</td>
        </tr>
        <tr>
            <td id="signoz--containerSecurityContext"><a href="./values.yaml#L1591">signoz.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the container.</td>
        </tr>
        <tr>
            <td id="signoz--extraVolumeMounts"><a href="./values.yaml#L1596">signoz.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the container.</td>
        </tr>
        <tr>
            <td id="signoz--extraVolumes"><a href="./values.yaml#L1600">signoz.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the pod.</td>
        </tr>
        <tr>
            <td id="signoz--extraInitContainers"><a href="./values.yaml#L1605">signoz.extraInitContainers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra init containers for the pod.</td>
        </tr>
        <tr>
            <td id="signoz--extraContainers"><a href="./values.yaml#L1611">signoz.extraContainers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra containers for the pod.</td>
        </tr>
        <tr>
            <td id="signoz--livenessProbe"><a href="./values.yaml#L1619">signoz.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">an HTTP GET of /api/v1/health on port http</pre>
</div>
            </td>
            <td>Liveness probe for the container.</td>
        </tr>
        <tr>
            <td id="signoz--readinessProbe"><a href="./values.yaml#L1633">signoz.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">an HTTP GET of /api/v1/health?live=1 on port http</pre>
</div>
            </td>
            <td>Readiness probe for the container.</td>
        </tr>
        <tr>
            <td id="signoz--startupProbe"><a href="./values.yaml#L1646">signoz.startupProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">no startup probe</pre>
</div>
            </td>
            <td>Startup probe for the container.</td>
        </tr>
        <tr>
            <td id="signoz--resources"><a href="./values.yaml#L1685">signoz.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">requests of 100m CPU and 100Mi of memory</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
        <tr>
            <td id="signoz--priorityClassName"><a href="./values.yaml#L1692">signoz.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">no priority class</pre>
</div>
            </td>
            <td>Priority class of the pod.</td>
        </tr>
        <tr>
            <td id="signoz--nodeSelector"><a href="./values.yaml#L1695">signoz.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node labels for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--tolerations"><a href="./values.yaml#L1698">signoz.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--affinity"><a href="./values.yaml#L1701">signoz.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--topologySpreadConstraints"><a href="./values.yaml#L1704">signoz.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--persistence--enabled"><a href="./values.yaml#L1711">signoz.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable persistence with a PersistentVolumeClaim.</td>
        </tr>
        <tr>
            <td id="signoz--persistence--existingClaim"><a href="./values.yaml#L1716">signoz.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">none, the chart's claim template</pre>
</div>
            </td>
            <td>Name of an existing claim to use.</td>
        </tr>
        <tr>
            <td id="signoz--persistence--storageClass"><a href="./values.yaml#L1722">signoz.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the cluster's default StorageClass</pre>
</div>
            </td>
            <td>StorageClass of the claim.</td>
        </tr>
        <tr>
            <td id="signoz--persistence--accessModes"><a href="./values.yaml#L1725">signoz.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access modes of the claim.</td>
        </tr>
        <tr>
            <td id="signoz--persistence--size"><a href="./values.yaml#L1729">signoz.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1Gi</pre>
</div>
            </td>
            <td>Size of the claim.</td>
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
            <td id="signoz--service--annotations"><a href="./values.yaml#L1474">signoz.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Service.</td>
        </tr>
        <tr>
            <td id="signoz--service--labels"><a href="./values.yaml#L1479">signoz.service.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Service.</td>
        </tr>
        <tr>
            <td id="signoz--service--type"><a href="./values.yaml#L1483">signoz.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>Kubernetes Service type.</td>
        </tr>
        <tr>
            <td id="signoz--service--port"><a href="./values.yaml#L1488">signoz.service.port</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8080</pre>
</div>
            </td>
            <td>Service port.</td>
        </tr>
        <tr>
            <td id="signoz--service--internalPort"><a href="./values.yaml#L1492">signoz.service.internalPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8085</pre>
</div>
            </td>
            <td>Service port for the internal API.</td>
        </tr>
        <tr>
            <td id="signoz--service--opampPort"><a href="./values.yaml#L1496">signoz.service.opampPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">4320</pre>
</div>
            </td>
            <td>Service port for OpAMP.</td>
        </tr>
        <tr>
            <td id="signoz--service--nodePort"><a href="./values.yaml#L1501">signoz.service.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">chosen by the cluster</pre>
</div>
            </td>
            <td>Node port for HTTP.</td>
        </tr>
        <tr>
            <td id="signoz--service--internalNodePort"><a href="./values.yaml#L1506">signoz.service.internalNodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">chosen by the cluster</pre>
</div>
            </td>
            <td>Node port for the internal API.</td>
        </tr>
        <tr>
            <td id="signoz--service--opampInternalNodePort"><a href="./values.yaml#L1511">signoz.service.opampInternalNodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">chosen by the cluster</pre>
</div>
            </td>
            <td>Node port for OpAMP.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--enabled"><a href="./values.yaml#L1650">signoz.ingress.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create an Ingress for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--className"><a href="./values.yaml#L1654">signoz.ingress.className</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>IngressClass of the Ingress.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--annotations"><a href="./values.yaml#L1660">signoz.ingress.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Ingress.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--hosts"><a href="./values.yaml#L1667">signoz.ingress.hosts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the host signoz.domain.com, with the path / on port 8080</pre>
</div>
            </td>
            <td>Hosts and paths of the Ingress.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--tls"><a href="./values.yaml#L1679">signoz.ingress.tls</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>TLS settings of the Ingress.</td>
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
            <td id="telemetryStoreMigrator"><a href="./values.yaml#L1733">telemetryStoreMigrator</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Default values for the Telemetry Store Migrator.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--enabled"><a href="./values.yaml#L1738">telemetryStoreMigrator.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Telemetry Store Migrator component.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--name"><a href="./values.yaml#L1743">telemetryStoreMigrator.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz-telemetrystore-migrator</pre>
</div>
            </td>
            <td>The name of the Telemetry Store Migrator component.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--annotations"><a href="./values.yaml#L1747">telemetryStoreMigrator.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations added to the Job, merged over the chart's `argocd.argoproj.io/sync-options: Force=true,Replace=true`; a value for that key replaces the chart's.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--labels"><a href="./values.yaml#L1751">telemetryStoreMigrator.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Job.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--pod--labels"><a href="./values.yaml#L1756">telemetryStoreMigrator.pod.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the pod.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--pod--annotations"><a href="./values.yaml#L1759">telemetryStoreMigrator.pod.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the pod.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--enableReplication"><a href="./values.yaml#L1763">telemetryStoreMigrator.enableReplication</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to enable replication for the Telemetry Store Migrator.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--timeout"><a href="./values.yaml#L1767">telemetryStoreMigrator.timeout</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10m</pre>
</div>
            </td>
            <td>Timeout for the migration.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--ttlSecondsAfterFinished"><a href="./values.yaml#L1773">telemetryStoreMigrator.ttlSecondsAfterFinished</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Seconds Kubernetes keeps a finished migrator Job, and its logs, before deleting it. Set it (for example `604800`) to clean up Jobs a failed upgrade leaves behind; leave it unset under Argo CD, which recreates a deleted Job and re-runs the migrator.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--nodeSelector"><a href="./values.yaml#L1777">telemetryStoreMigrator.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--tolerations"><a href="./values.yaml#L1781">telemetryStoreMigrator.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--affinity"><a href="./values.yaml#L1785">telemetryStoreMigrator.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--topologySpreadConstraints"><a href="./values.yaml#L1789">telemetryStoreMigrator.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--priorityClassName"><a href="./values.yaml#L1793">telemetryStoreMigrator.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class of the pod.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--podSecurityContext"><a href="./values.yaml#L1797">telemetryStoreMigrator.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the pod.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--resources"><a href="./values.yaml#L1801">telemetryStoreMigrator.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--containerSecurityContext"><a href="./values.yaml#L1805">telemetryStoreMigrator.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the container.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--env"><a href="./values.yaml#L1812">telemetryStoreMigrator.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--envFrom"><a href="./values.yaml#L1817">telemetryStoreMigrator.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Sources of extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--extraVolumes"><a href="./values.yaml#L1821">telemetryStoreMigrator.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the pod.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--extraVolumeMounts"><a href="./values.yaml#L1825">telemetryStoreMigrator.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the container.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--serviceAccount"><a href="./values.yaml#L1830">telemetryStoreMigrator.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
create: false
name: null</pre>
</div>
            </td>
            <td>ServiceAccount of the migrator Job; by default none is created and the Job runs as `default`. Set `create: true` when a policy or credential is bound to a ServiceAccount. On an install from a chart before 1.0.0, first delete the old `signoz-telemetrystore-migrator` ServiceAccount or upgrade with `--take-ownership`.</td>
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
            <td id="otelCollector"><a href="./values.yaml#L1844">otelCollector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Default values for the OpenTelemetry Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--name"><a href="./values.yaml#L1848">otelCollector.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">otel-collector</pre>
</div>
            </td>
            <td>The name of the Otel Collector component.</td>
        </tr>
        <tr>
            <td id="otelCollector--image"><a href="./values.yaml#L1852">otelCollector.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Image configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--imagePullSecrets"><a href="./values.yaml#L1866">otelCollector.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Secrets for pulling images from a private registry.</td>
        </tr>
        <tr>
            <td id="otelCollector--strategy"><a href="./values.yaml#L1870">otelCollector.strategy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">RollingUpdate</pre>
</div>
            </td>
            <td>Deployment strategy to use</td>
        </tr>
        <tr>
            <td id="otelCollector--extraArgs"><a href="./values.yaml#L1875">otelCollector.extraArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra command-line arguments for the collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--configMap"><a href="./values.yaml#L1878">otelCollector.configMap</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">create: true</pre>
</div>
            </td>
            <td>ConfigMap settings.</td>
        </tr>
        <tr>
            <td id="otelCollector--serviceAccount"><a href="./values.yaml#L1884">otelCollector.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
create: true
name: null</pre>
</div>
            </td>
            <td>Service Account configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--annotations"><a href="./values.yaml#L1912">otelCollector.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the Otel Collector Deployment.</td>
        </tr>
        <tr>
            <td id="otelCollector--labels"><a href="./values.yaml#L1916">otelCollector.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the Deployment.</td>
        </tr>
        <tr>
            <td id="otelCollector--pod--annotations"><a href="./values.yaml#L1923">otelCollector.pod.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io/port: "8888"
signoz.io/scrape: "true"</pre>
</div>
            </td>
            <td>Annotations to add to the pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--pod--labels"><a href="./values.yaml#L1929">otelCollector.pod.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--env"><a href="./values.yaml#L1944">otelCollector.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="otelCollector--envFrom"><a href="./values.yaml#L1949">otelCollector.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Sources of extra environment variables for the container.</td>
        </tr>
        <tr>
            <td id="otelCollector--minReadySeconds"><a href="./values.yaml#L1954">otelCollector.minReadySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Minimum number of seconds for a new pod to be ready.</td>
        </tr>
        <tr>
            <td id="otelCollector--progressDeadlineSeconds"><a href="./values.yaml#L1958">otelCollector.progressDeadlineSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">600</pre>
</div>
            </td>
            <td>Maximum time in seconds for a deployment to make progress before it is considered failed.</td>
        </tr>
        <tr>
            <td id="otelCollector--replicaCount"><a href="./values.yaml#L1962">otelCollector.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>The number of pod replicas for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole"><a href="./values.yaml#L1966">otelCollector.clusterRole</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>RBAC ClusterRole configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--livenessProbe"><a href="./values.yaml#L2182">otelCollector.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">httpGet on port 13133, path /</pre>
</div>
            </td>
            <td>Liveness probe for the container.</td>
        </tr>
        <tr>
            <td id="otelCollector--readinessProbe"><a href="./values.yaml#L2194">otelCollector.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">httpGet on port 13133, path /</pre>
</div>
            </td>
            <td>Readiness probe for the container.</td>
        </tr>
        <tr>
            <td id="otelCollector--startupProbe"><a href="./values.yaml#L2208">otelCollector.startupProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">no startup probe</pre>
</div>
            </td>
            <td>Startup probe for the container.</td>
        </tr>
        <tr>
            <td id="otelCollector--extraVolumeMounts"><a href="./values.yaml#L2213">otelCollector.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the container.</td>
        </tr>
        <tr>
            <td id="otelCollector--extraVolumes"><a href="./values.yaml#L2217">otelCollector.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the Otel Collector pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--resources"><a href="./values.yaml#L2254">otelCollector.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Resource requests and limits. Ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
        </tr>
        <tr>
            <td id="otelCollector--priorityClassName"><a href="./values.yaml#L2265">otelCollector.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class for the Otel Collector pods.</td>
        </tr>
        <tr>
            <td id="otelCollector--nodeSelector"><a href="./values.yaml#L2269">otelCollector.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--tolerations"><a href="./values.yaml#L2273">otelCollector.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--affinity"><a href="./values.yaml#L2277">otelCollector.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--topologySpreadConstraints"><a href="./values.yaml#L2281">otelCollector.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="otelCollector--podSecurityContext"><a href="./values.yaml#L2291">otelCollector.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Pod-level security context.</td>
        </tr>
        <tr>
            <td id="otelCollector--containerSecurityContext"><a href="./values.yaml#L2297">otelCollector.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for the container.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling"><a href="./values.yaml#L2308">otelCollector.autoscaling</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Autoscaling configuration (HPA).</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda"><a href="./values.yaml#L2345">otelCollector.autoscaling.keda</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: null
cooldownPeriod: "300"
enabled: false
maxReplicaCount: "5"
minReplicaCount: "1"
pollingInterval: "30"
triggers: []</pre>
</div>
            </td>
            <td>KEDA-based autoscaling configuration.</td>
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
            <td id="otelCollector--service"><a href="./values.yaml#L1896">otelCollector.service</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
labels: {}
loadBalancerSourceRanges: []
type: ClusterIP</pre>
</div>
            </td>
            <td>Service configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress"><a href="./values.yaml#L2220">otelCollector.ingress</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
className: ""
enabled: false
hosts:
    - host: otelcollector.domain.com
      paths:
        - path: /
          pathType: ImplementationSpecific
          port: 4318
tls: []</pre>
</div>
            </td>
            <td>Ingress configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress--hosts"><a href="./values.yaml#L2238">otelCollector.ingress.hosts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Hostname and path configurations for the ingress.</td>
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
            <td id="otelCollector--ports"><a href="./values.yaml#L2012">otelCollector.ports</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Port configurations for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp"><a href="./values.yaml#L2015">otelCollector.ports.otlp</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">containerPort: 4317
enabled: true
nodePort: ""
protocol: TCP
servicePort: 4317</pre>
</div>
            </td>
            <td>OTLP gRPC port configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp-http"><a href="./values.yaml#L2033">otelCollector.ports.otlp-http</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">containerPort: 4318
enabled: true
nodePort: ""
protocol: TCP
servicePort: 4318</pre>
</div>
            </td>
            <td>OTLP HTTP port configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-thrift"><a href="./values.yaml#L2051">otelCollector.ports.jaeger-thrift</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">containerPort: 14268
enabled: true
nodePort: ""
protocol: TCP
servicePort: 14268</pre>
</div>
            </td>
            <td>Jaeger Thrift port configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-grpc"><a href="./values.yaml#L2069">otelCollector.ports.jaeger-grpc</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">containerPort: 14250
enabled: true
nodePort: ""
protocol: TCP
servicePort: 14250</pre>
</div>
            </td>
            <td>Jaeger gRPC port configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--metrics"><a href="./values.yaml#L2087">otelCollector.ports.metrics</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">containerPort: 8888
enabled: true
nodePort: ""
protocol: TCP
servicePort: 8888</pre>
</div>
            </td>
            <td>Internal metrics port configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zpages"><a href="./values.yaml#L2105">otelCollector.ports.zpages</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">containerPort: 55679
enabled: false
nodePort: ""
protocol: TCP
servicePort: 55679</pre>
</div>
            </td>
            <td>ZPages port configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--pprof"><a href="./values.yaml#L2123">otelCollector.ports.pprof</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">containerPort: 1777
enabled: false
nodePort: ""
protocol: TCP
servicePort: 1777</pre>
</div>
            </td>
            <td>pprof port configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsheroku"><a href="./values.yaml#L2141">otelCollector.ports.logsheroku</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">containerPort: 8081
enabled: true
nodePort: ""
protocol: TCP
servicePort: 8081</pre>
</div>
            </td>
            <td>Heroku logs port configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsjson"><a href="./values.yaml#L2159">otelCollector.ports.logsjson</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">containerPort: 8082
enabled: true
nodePort: ""
protocol: TCP
servicePort: 8082</pre>
</div>
            </td>
            <td>JSON logs port configuration.</td>
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
            <td id="otelCollector--config"><a href="./values.yaml#L2370">otelCollector.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Main configuration for the OpenTelemetry Collector pipelines.</td>
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
            <td id="postgresql--enabled"><a href="./values.yaml#L2512">postgresql.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Install PostgreSQL.</td>
        </tr>
        <tr>
            <td id="postgresql--namespace"><a href="./values.yaml#L2515">postgresql.namespace</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Which namespace to install postgresql to (defaults to namespace chart is installed to)</td>
        </tr>
        <tr>
            <td id="postgresql--nameOverride"><a href="./values.yaml#L2518">postgresql.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name override for postgresql</td>
        </tr>
        <tr>
            <td id="postgresql--fullnameOverride"><a href="./values.yaml#L2521">postgresql.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Fullname override for postgreql</td>
        </tr>
        <tr>
            <td id="postgresql--replicaCount"><a href="./values.yaml#L2526">postgresql.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Number of Postgres replicas.</td>
        </tr>
        <tr>
            <td id="postgresql--image--repository"><a href="./values.yaml#L2532">postgresql.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">postgres</pre>
</div>
            </td>
            <td>Postgres image repository.</td>
        </tr>
        <tr>
            <td id="postgresql--image--tag"><a href="./values.yaml#L2536">postgresql.image.tag</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"15"</pre>
</div>
            </td>
            <td>Postgres image tag.</td>
        </tr>
        <tr>
            <td id="postgresql--image--pullPolicy"><a href="./values.yaml#L2540">postgresql.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Image pull policy.</td>
        </tr>
        <tr>
            <td id="postgresql--imagePullSecrets"><a href="./values.yaml#L2545">postgresql.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for Postgres pods</td>
        </tr>
        <tr>
            <td id="postgresql--service--annotations"><a href="./values.yaml#L2551">postgresql.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the Postgres service object.</td>
        </tr>
        <tr>
            <td id="postgresql--service--labels"><a href="./values.yaml#L2555">postgresql.service.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels for the Postgres service object.</td>
        </tr>
        <tr>
            <td id="postgresql--service--type"><a href="./values.yaml#L2559">postgresql.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>The service type (`ClusterIP`, `NodePort`, `LoadBalancer`).</td>
        </tr>
        <tr>
            <td id="postgresql--service--port"><a href="./values.yaml#L2563">postgresql.service.port</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5432</pre>
</div>
            </td>
            <td>The external port for Postgres service</td>
        </tr>
        <tr>
            <td id="postgresql--auth--username"><a href="./values.yaml#L2569">postgresql.auth.username</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz</pre>
</div>
            </td>
            <td>Username for the custom user to create.</td>
        </tr>
        <tr>
            <td id="postgresql--auth--password"><a href="./values.yaml#L2572">postgresql.auth.password</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz123</pre>
</div>
            </td>
            <td>Password for the custom user to create, stored in the Secret `<fullname>-auth` under the key `password`. Ignored if `auth.existingSecret` is provided, and then no Secret is created.</td>
        </tr>
        <tr>
            <td id="postgresql--auth--database"><a href="./values.yaml#L2576">postgresql.auth.database</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name for a custom database to create.</td>
        </tr>
        <tr>
            <td id="postgresql--auth--existingSecret"><a href="./values.yaml#L2580">postgresql.auth.existingSecret</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of existing secret to use for PostgreSQL credentials. `auth.password` will be ignored and picked up from this secret.</td>
        </tr>
        <tr>
            <td id="postgresql--auth--secretKeys--userPasswordKey"><a href="./values.yaml#L2585">postgresql.auth.secretKeys.userPasswordKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">password</pre>
</div>
            </td>
            <td>Name of key in existing secret to use for PostgreSQL credentials. Only used when `auth.existingSecret` is set.</td>
        </tr>
        <tr>
            <td id="postgresql--resources"><a href="./values.yaml#L2590">postgresql.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resource requests and limits for Postgres pods.</td>
        </tr>
        <tr>
            <td id="postgresql--priorityClassName"><a href="./values.yaml#L2595">postgresql.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class name for Postgres pods.</td>
        </tr>
        <tr>
            <td id="postgresql--podSecurityContext"><a href="./values.yaml#L2600">postgresql.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context for Postgres pods.</td>
        </tr>
        <tr>
            <td id="postgresql--securityContext"><a href="./values.yaml#L2605">postgresql.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Container security context for Postgres containers.</td>
        </tr>
        <tr>
            <td id="postgresql--podAnnotations"><a href="./values.yaml#L2610">postgresql.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for Postgres pods.</td>
        </tr>
        <tr>
            <td id="postgresql--annotations"><a href="./values.yaml#L2615">postgresql.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional annotations for Postgres resources.</td>
        </tr>
        <tr>
            <td id="postgresql--nodeSelector"><a href="./values.yaml#L2620">postgresql.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for Postgres pods.</td>
        </tr>
        <tr>
            <td id="postgresql--tolerations"><a href="./values.yaml#L2625">postgresql.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for Postgres pods.</td>
        </tr>
        <tr>
            <td id="postgresql--affinity"><a href="./values.yaml#L2630">postgresql.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for Postgres pods.</td>
        </tr>
        <tr>
            <td id="postgresql--topologySpreadConstraints"><a href="./values.yaml#L2635">postgresql.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for Postgres pods.</td>
        </tr>
        <tr>
            <td id="postgresql--livenessProbe--enabled"><a href="./values.yaml#L2641">postgresql.livenessProbe.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable liveness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--livenessProbe--initialDelaySeconds"><a href="./values.yaml#L2645">postgresql.livenessProbe.initialDelaySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">20</pre>
</div>
            </td>
            <td>Initial delay seconds for liveness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--livenessProbe--periodSeconds"><a href="./values.yaml#L2649">postgresql.livenessProbe.periodSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10</pre>
</div>
            </td>
            <td>Period seconds for liveness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--livenessProbe--timeoutSeconds"><a href="./values.yaml#L2653">postgresql.livenessProbe.timeoutSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Timeout seconds for liveness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--livenessProbe--successThreshold"><a href="./values.yaml#L2657">postgresql.livenessProbe.successThreshold</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Success threshold for liveness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--livenessProbe--failureThreshold"><a href="./values.yaml#L2661">postgresql.livenessProbe.failureThreshold</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">6</pre>
</div>
            </td>
            <td>Failure threshold for liveness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--readinessProbe--enabled"><a href="./values.yaml#L2667">postgresql.readinessProbe.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable readiness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--readinessProbe--initialDelaySeconds"><a href="./values.yaml#L2671">postgresql.readinessProbe.initialDelaySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Initial delay seconds for readiness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--readinessProbe--periodSeconds"><a href="./values.yaml#L2675">postgresql.readinessProbe.periodSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Period seconds for readiness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--readinessProbe--timeoutSeconds"><a href="./values.yaml#L2679">postgresql.readinessProbe.timeoutSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3</pre>
</div>
            </td>
            <td>Timeout seconds for readiness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--readinessProbe--successThreshold"><a href="./values.yaml#L2683">postgresql.readinessProbe.successThreshold</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Success threshold for readiness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--readinessProbe--failureThreshold"><a href="./values.yaml#L2687">postgresql.readinessProbe.failureThreshold</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">6</pre>
</div>
            </td>
            <td>Failure threshold for readiness probe.</td>
        </tr>
        <tr>
            <td id="postgresql--startupProbe--enabled"><a href="./values.yaml#L2697">postgresql.startupProbe.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the startup probe.</td>
        </tr>
        <tr>
            <td id="postgresql--startupProbe--initialDelaySeconds"><a href="./values.yaml#L2701">postgresql.startupProbe.initialDelaySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">0</pre>
</div>
            </td>
            <td>Delay before the first startup probe.</td>
        </tr>
        <tr>
            <td id="postgresql--startupProbe--periodSeconds"><a href="./values.yaml#L2705">postgresql.startupProbe.periodSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10</pre>
</div>
            </td>
            <td>Interval between startup probes.</td>
        </tr>
        <tr>
            <td id="postgresql--startupProbe--timeoutSeconds"><a href="./values.yaml#L2709">postgresql.startupProbe.timeoutSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Timeout of each startup probe.</td>
        </tr>
        <tr>
            <td id="postgresql--startupProbe--successThreshold"><a href="./values.yaml#L2713">postgresql.startupProbe.successThreshold</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Consecutive successes for the startup probe to pass.</td>
        </tr>
        <tr>
            <td id="postgresql--startupProbe--failureThreshold"><a href="./values.yaml#L2718">postgresql.startupProbe.failureThreshold</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">180</pre>
</div>
            </td>
            <td>Consecutive failures before the container is restarted.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--enabled"><a href="./values.yaml#L2724">postgresql.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable persistent storage for Postgres.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--existingClaim"><a href="./values.yaml#L2732">postgresql.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">none, the chart's claim template</pre>
</div>
            </td>
            <td>Name of an existing claim to use.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--size"><a href="./values.yaml#L2736">postgresql.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10Gi</pre>
</div>
            </td>
            <td>Size of the persistent volume claim.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--storageClass"><a href="./values.yaml#L2740">postgresql.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Storage class for the persistent volume claim.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--accessModes"><a href="./values.yaml#L2744">postgresql.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access modes for the persistent volume claim.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--mountPath"><a href="./values.yaml#L2754">postgresql.persistence.mountPath</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">/var/lib/postgresql</pre>
</div>
            </td>
            <td>Mount path of the data claim.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--subPath"><a href="./values.yaml#L2758">postgresql.persistence.subPath</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Subpath within the volume for Postgres data.</td>
        </tr>
        <tr>
            <td id="postgresql--persistence--dataDir"><a href="./values.yaml#L2768">postgresql.persistence.dataDir</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">/var/lib/postgresql/data</pre>
</div>
            </td>
            <td>Data directory of Postgres (`PGDATA`).</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--enabled"><a href="./values.yaml#L2785">postgresql.upgradeBackupHook.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Run the hook on `helm upgrade`.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--activeDeadlineSeconds"><a href="./values.yaml#L2791">postgresql.upgradeBackupHook.activeDeadlineSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">240</pre>
</div>
            </td>
            <td>Time limit of the Job before it, and with it the upgrade, is marked failed.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--resources"><a href="./values.yaml#L2797">postgresql.upgradeBackupHook.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">requests 50m CPU and 64Mi memory, limits 1 CPU and 256Mi memory</pre>
</div>
            </td>
            <td>Resource requests and limits for the container.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--nodeSelector"><a href="./values.yaml#L2809">postgresql.upgradeBackupHook.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the value of `nodeSelector`</pre>
</div>
            </td>
            <td>Node labels for pod assignment.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--tolerations"><a href="./values.yaml#L2814">postgresql.upgradeBackupHook.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--priorityClassName"><a href="./values.yaml#L2818">postgresql.upgradeBackupHook.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">the value of `priorityClassName`</pre>
</div>
            </td>
            <td>Priority class of the pod.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--podAnnotations"><a href="./values.yaml#L2821">postgresql.upgradeBackupHook.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the pod.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--podLabels"><a href="./values.yaml#L2825">postgresql.upgradeBackupHook.podLabels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels to add to the pod.</td>
        </tr>
        <tr>
            <td id="postgresql--upgradeBackupHook--annotations"><a href="./values.yaml#L2830">postgresql.upgradeBackupHook.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the Job.</td>
        </tr>
        <tr>
            <td id="postgresql--additionalArgs"><a href="./values.yaml#L2835">postgresql.additionalArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional command-line arguments for Postgres containers.</td>
        </tr>
        <tr>
            <td id="postgresql--additionalVolumes"><a href="./values.yaml#L2840">postgresql.additionalVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volumes for Postgres pods.</td>
        </tr>
        <tr>
            <td id="postgresql--additionalVolumeMounts"><a href="./values.yaml#L2845">postgresql.additionalVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volume mounts for Postgres containers.</td>
        </tr>
        <tr>
            <td id="postgresql--extraEnv"><a href="./values.yaml#L2850">postgresql.extraEnv</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra environment variables for Postgres containers.</td>
        </tr>
        <tr>
            <td id="postgresql--serviceAccount--create"><a href="./values.yaml#L2856">postgresql.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a service account should be created.</td>
        </tr>
        <tr>
            <td id="postgresql--serviceAccount--annotations"><a href="./values.yaml#L2860">postgresql.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the service account.</td>
        </tr>
        <tr>
            <td id="postgresql--serviceAccount--name"><a href="./values.yaml#L2864">postgresql.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>The name of the service account to use. If not set and `create` is true, a name is generated.</td>
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
            <td id="signoz-otel-gateway"><a href="./values.yaml#L2867">signoz-otel-gateway</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false
strategy: ""</pre>
</div>
            </td>
            <td>This component is configurable with licensed version of SigNoz.</td>
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
            <td id="signoz-otel-gateway--strategy"><a href="./values.yaml#L2874">signoz-otel-gateway.strategy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">RollingUpdate</pre>
</div>
            </td>
            <td>Deployment strategy to use</td>
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
            <td id="redpanda"><a href="./values.yaml#L3087">redpanda</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>This component is configurable with licensed version of SigNoz.</td>
        </tr>
    </tbody>
</table>

