
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

To install the chart with the release name `my-release`:

```bash
helm repo add signoz https://charts.signoz.io
helm -n platform --create-namespace install "my-release" signoz/signoz
```

These commands deploy SigNoz on the Kubernetes cluster in the default configuration.
The [Configuration](#configuration) section lists the parameters that can be configured during installation:

> **Tip**: List all releases using `helm list`

### Uninstalling the chart

To uninstall/delete the `my-release` resources:

```bash
helm -n platform uninstall "my-release"
```

See the [Helm docs](https://helm.sh/docs/helm/helm_uninstall/) for documentation on the helm uninstall command.

The command above removes all the Kubernetes components associated
with the chart and deletes the release.

Deletion of the StatefulSet doesn't cascade to deleting associated PVCs. To delete them:

```bash
kubectl -n platform delete pvc --selector app.kubernetes.io/instance=my-release
```

Sometimes everything doesn't get properly removed. If that happens try deleting the namespace:

```bash
kubectl delete namespace platform
```

> [!WARNING]
> ### Breaking Changes
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
            <td id="global--imagePullSecrets"><a href="./values.yaml#L11">global.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Global Image Pull Secrets.</td>
        </tr>
        <tr>
            <td id="global--storageClass"><a href="./values.yaml#L17">global.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Overrides the storage class for all PVCs with persistence enabled. If not set, the default storage class is used. If set to "-", storageClassName will be an empty string, which disables dynamic provisioning.</td>
        </tr>
        <tr>
            <td id="global--clusterDomain"><a href="./values.yaml#L22">global.clusterDomain</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster.local</pre>
</div>
            </td>
            <td>The Kubernetes cluster domain. It is used only when components are installed in different namespaces.</td>
        </tr>
        <tr>
            <td id="global--clusterName"><a href="./values.yaml#L27">global.clusterName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>The Kubernetes cluster name. It is used to attach to telemetry data via the resource detection processor.</td>
        </tr>
        <tr>
            <td id="global--cloud"><a href="./values.yaml#L34">global.cloud</a></td>
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
            <td id="nameOverride"><a href="./values.yaml#L38">nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Override the default chart name.</td>
        </tr>
        <tr>
            <td id="fullnameOverride"><a href="./values.yaml#L42">fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Override the default full chart name.</td>
        </tr>
        <tr>
            <td id="clusterName"><a href="./values.yaml#L46">clusterName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the K8s cluster. Used by SigNoz OtelCollectors to attach to telemetry data.</td>
        </tr>
        <tr>
            <td id="imagePullSecrets"><a href="./values.yaml#L52">imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image Registry Secret Names for all SigNoz components. If `global.imagePullSecrets` is set, it will be merged with this list. This has lower precedence than `imagePullSecrets` at the individual component level.</td>
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
            <td id="clickhouse"><a href="./values.yaml#L58">clickhouse</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>The ClickHouse this chart installs, a ClickHouseInstallation that the operator from `altinity-clickhouse-operator` reconciles.</td>
        </tr>
        <tr>
            <td id="clickhouse--enabled"><a href="./values.yaml#L63">clickhouse.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Install ClickHouse, with the operator and ZooKeeper it needs. When false, every component connects to `externalClickhouse` instead, and `externalClickhouse.host` must be set.</td>
        </tr>
        <tr>
            <td id="clickhouse--name"><a href="./values.yaml#L66">clickhouse.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">clickhouse</pre>
</div>
            </td>
            <td>Value of the `app.kubernetes.io/component` label on the ClickHouse objects and pods.</td>
        </tr>
        <tr>
            <td id="clickhouse--nameOverride"><a href="./values.yaml#L70">clickhouse.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Replaces `clickhouse` in the ClickHouse name `<release>-clickhouse` and in its `app.kubernetes.io/name` label.</td>
        </tr>
        <tr>
            <td id="clickhouse--fullnameOverride"><a href="./values.yaml#L75">clickhouse.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the ClickHouseInstallation and its Service in place of `<release>-clickhouse`, and the prefix of its other objects. At most 34 characters, because the operator derives longer names from it; set it when a long release name fails the render.</td>
        </tr>
        <tr>
            <td id="clickhouse--namespace"><a href="./values.yaml#L81">clickhouse.namespace</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Namespace of the ClickHouseInstallation; empty means the release namespace. Any other value makes the chart create that namespace and keep it on uninstall (`helm.sh/resource-policy: keep`), and needs the operator pointed at it: `altinity-clickhouse-operator.namespaceOverride` set to the same value, or `watchNamespaces: [<value>]` with `rbac.namespaceScoped: false`.</td>
        </tr>
        <tr>
            <td id="clickhouse--image"><a href="./values.yaml#L84">clickhouse.image</a></td>
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
            <td id="clickhouse--image--repository"><a href="./values.yaml#L88">clickhouse.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">clickhouse/clickhouse-server</pre>
</div>
            </td>
            <td>Image repository, optionally prefixed with a registry; `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--tag"><a href="./values.yaml#L92">clickhouse.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">25.12.5</pre>
</div>
            </td>
            <td>ClickHouse server version. SigNoz is tested against this tag; move off it only to a version SigNoz supports.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--pullPolicy"><a href="./values.yaml#L96">clickhouse.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>ClickHouse image pull policy.</td>
        </tr>
        <tr>
            <td id="clickhouse--imagePullSecrets"><a href="./values.yaml#L100">clickhouse.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image Registry Secret Names for ClickHouse. Merged with `global.imagePullSecrets` if set.</td>
        </tr>
        <tr>
            <td id="clickhouse--layout"><a href="./values.yaml#L106">clickhouse.layout</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">replicasCount: 1
shardsCount: 1</pre>
</div>
            </td>
            <td>Shards and replicas of the ClickHouse cluster (experimental), the operator's cluster `layout` rendered as given: https://github.com/Altinity/clickhouse-operator/blob/master/docs/custom_resource_explained.md</td>
        </tr>
        <tr>
            <td id="clickhouse--cluster"><a href="./values.yaml#L112">clickhouse.cluster</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster</pre>
</div>
            </td>
            <td>Name of the ClickHouse cluster, which the migrator creates SigNoz's tables on and SigNoz queries.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount"><a href="./values.yaml#L115">clickhouse.serviceAccount</a></td>
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
            <td id="clickhouse--serviceAccount--create"><a href="./values.yaml#L119">clickhouse.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Create a ServiceAccount for the ClickHouse pod; when false the pod runs as `name`, or as `default` when `name` is empty.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount--annotations"><a href="./values.yaml#L123">clickhouse.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the service account.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount--name"><a href="./values.yaml#L127">clickhouse.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of the ServiceAccount to create (empty: the ClickHouse name), or of an existing one to run as when `create` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--labels"><a href="./values.yaml#L130">clickhouse.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels added to the ClickHouseInstallation.</td>
        </tr>
        <tr>
            <td id="clickhouse--annotations"><a href="./values.yaml#L134">clickhouse.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations added to the ClickHouseInstallation.</td>
        </tr>
        <tr>
            <td id="clickhouse--podLabels"><a href="./values.yaml#L137">clickhouse.podLabels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels added to the ClickHouse pods.</td>
        </tr>
        <tr>
            <td id="clickhouse--podAnnotations"><a href="./values.yaml#L141">clickhouse.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io/path: /metrics
signoz.io/port: "9363"
signoz.io/scrape: "true"</pre>
</div>
            </td>
            <td>Annotations on the ClickHouse pods; the `signoz.io/*` defaults let the SigNoz collectors scrape the metrics endpoint set in `clickhouse.settings`.</td>
        </tr>
        <tr>
            <td id="clickhouse--service"><a href="./values.yaml#L147">clickhouse.service</a></td>
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
            <td id="clickhouse--service--annotations"><a href="./values.yaml#L151">clickhouse.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ClickHouse service.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--type"><a href="./values.yaml#L155">clickhouse.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>Type of the ClickHouse Service; `LoadBalancer` or `NodePort` exposes ClickHouse outside the cluster.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--httpPort"><a href="./values.yaml#L159">clickhouse.service.httpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8123</pre>
</div>
            </td>
            <td>HTTP port of the ClickHouse Service, which the components connect to.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--tcpPort"><a href="./values.yaml#L163">clickhouse.service.tcpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">9000</pre>
</div>
            </td>
            <td>Native TCP port of the ClickHouse Service, which SigNoz, the collector and the migrator connect to.</td>
        </tr>
        <tr>
            <td id="clickhouse--database"><a href="./values.yaml#L167">clickhouse.database</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_metrics</pre>
</div>
            </td>
            <td>Database the collector writes metrics to.</td>
        </tr>
        <tr>
            <td id="clickhouse--traceDatabase"><a href="./values.yaml#L171">clickhouse.traceDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_traces</pre>
</div>
            </td>
            <td>Database the collector writes traces to.</td>
        </tr>
        <tr>
            <td id="clickhouse--logDatabase"><a href="./values.yaml#L175">clickhouse.logDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_logs</pre>
</div>
            </td>
            <td>Database the collector writes logs to.</td>
        </tr>
        <tr>
            <td id="clickhouse--meterDatabase"><a href="./values.yaml#L179">clickhouse.meterDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_meter</pre>
</div>
            </td>
            <td>Database the collector writes meter data to.</td>
        </tr>
        <tr>
            <td id="clickhouse--user"><a href="./values.yaml#L183">clickhouse.user</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">admin</pre>
</div>
            </td>
            <td>ClickHouse user the installation creates and every component connects as.</td>
        </tr>
        <tr>
            <td id="clickhouse--password"><a href="./values.yaml#L187">clickhouse.password</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">27ff0399-0d3a-4bd8-919d-17c2181e6fb9</pre>
</div>
            </td>
            <td>Password of `clickhouse.user`. Written into the Secret `<clickhouse.fullname>-credentials`, which the ClickHouseInstallation and every component that connects to ClickHouse read; ignored when `clickhouse.existingSecret` is set.</td>
        </tr>
        <tr>
            <td id="clickhouse--existingSecret"><a href="./values.yaml#L191">clickhouse.existingSecret</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of a Secret you created that holds the password of `clickhouse.user`. When set, the chart creates no Secret and reads this one. With `clickhouse.namespace` set to another namespace, the Secret must exist there as well as in the release namespace.</td>
        </tr>
        <tr>
            <td id="clickhouse--existingSecretPasswordKey"><a href="./values.yaml#L195">clickhouse.existingSecretPasswordKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">password</pre>
</div>
            </td>
            <td>Key of the password inside `clickhouse.existingSecret`.</td>
        </tr>
        <tr>
            <td id="clickhouse--secure"><a href="./values.yaml#L199">clickhouse.secure</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to use a TLS connection when connecting to ClickHouse.</td>
        </tr>
        <tr>
            <td id="clickhouse--verify"><a href="./values.yaml#L203">clickhouse.verify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to verify the TLS certificate on connection to ClickHouse.</td>
        </tr>
        <tr>
            <td id="clickhouse--allowedNetworkIps"><a href="./values.yaml#L207">clickhouse.allowedNetworkIps</a></td>
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
            <td id="clickhouse--externalZookeeper"><a href="./values.yaml#L218">clickhouse.externalZookeeper</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ZooKeeper that ClickHouse coordinates through instead of the bundled one, as a `servers` list of `host` and `port` entries. Set `zookeeper.enabled: false` with it, or the bundled ZooKeeper is still installed.</td>
        </tr>
        <tr>
            <td id="clickhouse--profiles"><a href="./values.yaml#L227">clickhouse.profiles</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ClickHouse settings profiles as `<profile>/<setting>: value`, for example `default/max_memory_usage: 40000000000`; they override `defaultProfiles`. Settings: https://clickhouse.com/docs/en/operations/settings/settings/</td>
        </tr>
        <tr>
            <td id="clickhouse--defaultProfiles"><a href="./values.yaml#L231">clickhouse.defaultProfiles</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Profile settings SigNoz's queries rely on. Do not replace this map; override a single setting through `clickhouse.profiles`.</td>
        </tr>
        <tr>
            <td id="clickhouse--settings"><a href="./values.yaml#L242">clickhouse.settings</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>ClickHouse server settings as `<path>: value`; they override `defaultSettings`. The `prometheus/*` defaults serve the metrics that `clickhouse.podAnnotations` point at. Settings: https://clickhouse.com/docs/en/operations/server-configuration-parameters/settings</td>
        </tr>
        <tr>
            <td id="clickhouse--defaultSettings"><a href="./values.yaml#L252">clickhouse.defaultSettings</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">format_schema_path: /etc/clickhouse-server/config.d/
user_defined_executable_functions_config: /etc/clickhouse-server/functions/custom-functions.xml
user_scripts_path: /var/lib/clickhouse/user_scripts/</pre>
</div>
            </td>
            <td>Server settings that load the histogramQuantile function and the `events.proto` format schema. Do not replace this map; override a single setting through `clickhouse.settings`.</td>
        </tr>
        <tr>
            <td id="clickhouse--files"><a href="./values.yaml#L259">clickhouse.files</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>ClickHouse configuration files as `<path>: <content>`; files under `config.d/` merge into the server config.</td>
        </tr>
        <tr>
            <td id="clickhouse--templates"><a href="./values.yaml#L306">clickhouse.templates</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">volumeClaimTemplates: []</pre>
</div>
            </td>
            <td>Volume claim templates of the ClickHouse installation, used only when `clickhouse.persistence.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--templates--volumeClaimTemplates"><a href="./values.yaml#L312">clickhouse.templates.volumeClaimTemplates</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Volume claim templates (`name`, `accessModes`, `resources.requests.storage`, `storageClassName`) added when `persistence.enabled` is false. Mount each through `clickhouse.extraVolumeMounts` under the same `name`; without a mount at `/var/lib/clickhouse` the data is not kept.</td>
        </tr>
        <tr>
            <td id="clickhouse--podDistribution"><a href="./values.yaml#L318">clickhouse.podDistribution</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Operator rules that spread the ClickHouse pods across nodes, rendered as given; types: https://github.com/Altinity/clickhouse-operator/blob/1414503921da3ae475eb6f9a296d3475a6993768/docs/chi-examples/99-clickhouseinstallation-max.yaml#L428-L481</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage"><a href="./values.yaml#L330">clickhouse.coldStorage</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>S3 or GCS disk added as the `s3` volume of a `tiered` storage policy, where SigNoz's retention settings move older data.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--enabled"><a href="./values.yaml#L334">clickhouse.coldStorage.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable S3/GCS cold storage.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--defaultKeepFreeSpaceBytes"><a href="./values.yaml#L338">clickhouse.coldStorage.defaultKeepFreeSpaceBytes</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"10485760"</pre>
</div>
            </td>
            <td>Reserve free space on the default disk (in bytes).</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--type"><a href="./values.yaml#L342">clickhouse.coldStorage.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">s3</pre>
</div>
            </td>
            <td>Type of cold storage: `s3` or `gcs`.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--endpoint"><a href="./values.yaml#L347">clickhouse.coldStorage.endpoint</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">https://<bucket-name>.s3-<region>.amazonaws.com/data/</pre>
</div>
            </td>
            <td>Bucket URL including the path ClickHouse writes under, for example `https://<bucket>.s3-<region>.amazonaws.com/data/` or `https://storage.googleapis.com/<bucket>/data/`.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--accessKey"><a href="./values.yaml#L352">clickhouse.coldStorage.accessKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml"><access_key_id></pre>
</div>
            </td>
            <td>Access Key ID for S3 or GCS. Used for `gcs`, and for `s3` when `role.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--secretAccess"><a href="./values.yaml#L357">clickhouse.coldStorage.secretAccess</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml"><secret_access_key></pre>
</div>
            </td>
            <td>Secret Access Key for S3 or GCS. Used for `gcs`, and for `s3` when `role.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--role"><a href="./values.yaml#L360">clickhouse.coldStorage.role</a></td>
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
            <td id="clickhouse--coldStorage--role--enabled"><a href="./values.yaml#L364">clickhouse.coldStorage.role.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Use the role for `s3`: ClickHouse takes credentials from its environment instead of `accessKey` and `secretAccess`.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--role--annotations"><a href="./values.yaml#L367">clickhouse.coldStorage.role.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">eks.amazonaws.com/role-arn: arn:aws:iam::******:role/*****</pre>
</div>
            </td>
            <td>ServiceAccount annotations that bind the role, added when `coldStorage.enabled` and `role.enabled` are both true.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs"><a href="./values.yaml#L373">clickhouse.logs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Sidecar collector in the ClickHouse pod that sends `system.query_log` entries as logs to an OTLP receiver on the node's port 4317, such as the k8s-infra agent.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--enabled"><a href="./values.yaml#L377">clickhouse.logs.system.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable collection of system table entries as logs</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--image--repository"><a href="./values.yaml#L382">clickhouse.logs.system.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/signoz-otel-collector</pre>
</div>
            </td>
            <td>Image repository, optionally prefixed with a registry; `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--image--tag"><a href="./values.yaml#L386">clickhouse.logs.system.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v0.144.15</pre>
</div>
            </td>
            <td>Tag of the system logs sidecar image.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--image--pullPolicy"><a href="./values.yaml#L390">clickhouse.logs.system.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Pull policy of the system logs sidecar image.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--resources"><a href="./values.yaml#L394">clickhouse.logs.system.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resources of the system logs sidecar container, a Kubernetes ResourceRequirements object rendered as given.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--config"><a href="./values.yaml#L398">clickhouse.logs.system.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Configuration of the sidecar collector, rendered as given into its config file.</td>
        </tr>
        <tr>
            <td id="clickhouse--installCustomStorageClass"><a href="./values.yaml#L448">clickhouse.installCustomStorageClass</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create an expandable StorageClass: `gp2-resizable` when `global.cloud` starts with `aws`, `gce-resizable` when it starts with `gcp`. No volume uses it until `clickhouse.persistence.storageClass` names it.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook"><a href="./values.yaml#L453">clickhouse.operatorUpgradeHook</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Pre-upgrade Job that deletes the operator Deployment an older chart created, whose selector labels cannot change in place; it matches nothing afterwards. When disabled, delete that Deployment yourself before upgrading: `kubectl delete deployment <release>-clickhouse-operator -n <namespace>`.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--enabled"><a href="./values.yaml#L456">clickhouse.operatorUpgradeHook.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Run the hook on `helm upgrade`.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--repository"><a href="./values.yaml#L460">clickhouse.operatorUpgradeHook.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">registry.k8s.io/kubectl</pre>
</div>
            </td>
            <td>Image repository, optionally prefixed with a registry; `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--tag"><a href="./values.yaml#L463">clickhouse.operatorUpgradeHook.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v1.36.3</pre>
</div>
            </td>
            <td>Tag of the kubectl image. The image publishes no `latest` tag.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--pullPolicy"><a href="./values.yaml#L466">clickhouse.operatorUpgradeHook.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Pull policy of the kubectl image.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--backoffLimit"><a href="./values.yaml#L469">clickhouse.operatorUpgradeHook.backoffLimit</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3</pre>
</div>
            </td>
            <td>Retries before the Job, and with it the upgrade, is marked failed.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--resources"><a href="./values.yaml#L472">clickhouse.operatorUpgradeHook.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resources of the hook container.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--enabled"><a href="./values.yaml#L478">clickhouse.udf.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Download the histogramQuantile binary, which SigNoz's histogram percentile queries call, from GitHub in an init container. Without GitHub access, set it to false and supply the binary through `clickhouse.extraInitContainers`.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--command"><a href="./values.yaml#L482">clickhouse.udf.command</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Command of the download init container; by default it fetches the histogramQuantile release for the node's OS and architecture.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--env"><a href="./values.yaml#L500">clickhouse.udf.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Environment of the download init container, Kubernetes EnvVar objects rendered as given, for example a proxy setting or a mirror credential from a Secret.</td>
        </tr>
        <tr>
            <td id="clickhouse--udf--envFrom"><a href="./values.yaml#L504">clickhouse.udf.envFrom</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>envFrom of the download init container, Kubernetes EnvFromSource objects rendered as given.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraInitContainers"><a href="./values.yaml#L508">clickhouse.extraInitContainers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Init containers added to the ClickHouse pod after the histogramQuantile download, Kubernetes Container objects rendered as given. The user scripts volume is `shared-binary-volume`, mounted at `/var/lib/clickhouse/user_scripts`.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraContainers"><a href="./values.yaml#L511">clickhouse.extraContainers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra containers in the ClickHouse pod, Kubernetes Container objects rendered as given.</td>
        </tr>
        <tr>
            <td id="clickhouse--startupProbe"><a href="./values.yaml#L517">clickhouse.startupProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Startup probe of the ClickHouse container, a Kubernetes probe object rendered as given; `null` renders none. For a handler other than `httpGet`, also set `httpGet: null`, since Helm merges your map into the default.</td>
        </tr>
        <tr>
            <td id="clickhouse--livenessProbe"><a href="./values.yaml#L530">clickhouse.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Liveness probe of the ClickHouse container, a Kubernetes probe object rendered as given; `null` renders none. For a handler other than `httpGet`, also set `httpGet: null`, since Helm merges your map into the default.</td>
        </tr>
        <tr>
            <td id="clickhouse--readinessProbe"><a href="./values.yaml#L543">clickhouse.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Readiness probe of the ClickHouse container, a Kubernetes probe object rendered as given; `null` renders none. For a handler other than `httpGet`, also set `httpGet: null`, since Helm merges your map into the default.</td>
        </tr>
        <tr>
            <td id="clickhouse--resources"><a href="./values.yaml#L555">clickhouse.resources</a></td>
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
            <td id="clickhouse--podSecurityContext"><a href="./values.yaml#L566">clickhouse.podSecurityContext</a></td>
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
            <td id="clickhouse--containerSecurityContext"><a href="./values.yaml#L574">clickhouse.containerSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Security context of the ClickHouse container, a Kubernetes SecurityContext object rendered as given; rendered only when set. ClickHouse runs under `allowPrivilegeEscalation: false`, `capabilities: {drop: [ALL]}`, `runAsNonRoot: true` and `seccompProfile: {type: RuntimeDefault}`.</td>
        </tr>
        <tr>
            <td id="clickhouse--priorityClassName"><a href="./values.yaml#L577">clickhouse.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class of the ClickHouse pods; empty sets none.</td>
        </tr>
        <tr>
            <td id="clickhouse--nodeSelector"><a href="./values.yaml#L581">clickhouse.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for assigning the ClickHouse pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--tolerations"><a href="./values.yaml#L585">clickhouse.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Toleration labels for ClickHouse pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--affinity"><a href="./values.yaml#L589">clickhouse.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for the ClickHouse pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--topologySpreadConstraints"><a href="./values.yaml#L592">clickhouse.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints of the ClickHouse pods, Kubernetes objects rendered as given.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence"><a href="./values.yaml#L596">clickhouse.persistence</a></td>
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
            <td id="clickhouse--persistence--enabled"><a href="./values.yaml#L601">clickhouse.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Keep ClickHouse data on a PersistentVolumeClaim. When false, the data lives in an `emptyDir` and is lost with the pod, unless `clickhouse.templates.volumeClaimTemplates` provides volumes.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--existingClaim"><a href="./values.yaml#L605">clickhouse.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of a PersistentVolumeClaim you created for the ClickHouse data, used instead of a claim from the template.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--storageClass"><a href="./values.yaml#L610">clickhouse.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>StorageClass of the ClickHouse data claim; `-` disables dynamic provisioning, null uses the cluster default, and `global.storageClass` overrides it.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--accessModes"><a href="./values.yaml#L614">clickhouse.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access Modes for the persistent volume.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--size"><a href="./values.yaml#L619">clickhouse.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">20Gi</pre>
</div>
            </td>
            <td>Persistent Volume size.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraVolumes"><a href="./values.yaml#L622">clickhouse.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the ClickHouse pod, a list of Kubernetes Volume objects.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraVolumeMounts"><a href="./values.yaml#L625">clickhouse.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the ClickHouse container, a list of Kubernetes VolumeMount objects.</td>
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
            <td id="zookeeper"><a href="./values.yaml#L631">zookeeper</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Values of the bundled ZooKeeper chart, which ClickHouse coordinates through; its keys follow Bitnami's chart: https://github.com/bitnami/charts/blob/main/bitnami/zookeeper/values.yaml</td>
        </tr>
        <tr>
            <td id="zookeeper--image"><a href="./values.yaml#L637">zookeeper.image</a></td>
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
            <td id="zookeeper--image--registry"><a href="./values.yaml#L640">zookeeper.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Zookeeper image registry to use.</td>
        </tr>
        <tr>
            <td id="zookeeper--image--repository"><a href="./values.yaml#L643">zookeeper.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/zookeeper</pre>
</div>
            </td>
            <td>Zookeeper image repository to use.</td>
        </tr>
        <tr>
            <td id="zookeeper--image--tag"><a href="./values.yaml#L646">zookeeper.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3.7.1</pre>
</div>
            </td>
            <td>ZooKeeper version; ClickHouse does not work with every ZooKeeper version, so change it only to one ClickHouse supports.</td>
        </tr>
        <tr>
            <td id="zookeeper--nameOverride"><a href="./values.yaml#L650">zookeeper.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Replaces `zookeeper` in the ZooKeeper name `<release>-zookeeper`, by which the ClickHouse installation finds it.</td>
        </tr>
        <tr>
            <td id="zookeeper--fullnameOverride"><a href="./values.yaml#L653">zookeeper.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the ZooKeeper objects in place of `<release>-zookeeper`, by which the ClickHouse installation finds it.</td>
        </tr>
        <tr>
            <td id="zookeeper--namespaceOverride"><a href="./values.yaml#L657">zookeeper.namespaceOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Namespace of ZooKeeper, which must already exist; empty means the release namespace.</td>
        </tr>
        <tr>
            <td id="zookeeper--podAnnotations"><a href="./values.yaml#L661">zookeeper.podAnnotations</a></td>
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
            <td id="zookeeper--autopurge"><a href="./values.yaml#L668">zookeeper.autopurge</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">purgeInterval: 1</pre>
</div>
            </td>
            <td>Periodic purge of old ZooKeeper snapshots and transaction logs.</td>
        </tr>
        <tr>
            <td id="zookeeper--autopurge--purgeInterval"><a href="./values.yaml#L671">zookeeper.autopurge.purgeInterval</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Hours between purges; 0 disables purging.</td>
        </tr>
        <tr>
            <td id="zookeeper--metrics"><a href="./values.yaml#L675">zookeeper.metrics</a></td>
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
            <td id="zookeeper--metrics--enabled"><a href="./values.yaml#L678">zookeeper.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Serve ZooKeeper's Prometheus metrics on port 9141, the port `podAnnotations` point the collectors at.</td>
        </tr>
        <tr>
            <td id="zookeeper--metrics--service--annotations"><a href="./values.yaml#L684">zookeeper.metrics.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ZooKeeper metrics service annotation</td>
        </tr>
        <tr>
            <td id="zookeeper--logLevel"><a href="./values.yaml#L691">zookeeper.logLevel</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">INFO</pre>
</div>
            </td>
            <td>Zookeeper log level.</td>
        </tr>
        <tr>
            <td id="zookeeper--livenessProbe"><a href="./values.yaml#L695">zookeeper.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>Bitnami's built-in liveness probe, off because `customLivenessProbe` replaces it.</td>
        </tr>
        <tr>
            <td id="zookeeper--readinessProbe"><a href="./values.yaml#L699">zookeeper.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>Bitnami's built-in readiness probe, off because `customReadinessProbe` replaces it.</td>
        </tr>
        <tr>
            <td id="zookeeper--customLivenessProbe"><a href="./values.yaml#L703">zookeeper.customLivenessProbe</a></td>
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
            <td id="zookeeper--customReadinessProbe"><a href="./values.yaml#L713">zookeeper.customReadinessProbe</a></td>
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
            <td id="zookeeper--minServerId"><a href="./values.yaml#L724">zookeeper.minServerId</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>ZooKeeper server ID of the first replica; each further replica takes the next ID.</td>
        </tr>
        <tr>
            <td id="zookeeper--replicaCount"><a href="./values.yaml#L728">zookeeper.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Number of ZooKeeper replicas, each listed as a coordination node of the ClickHouse installation; use an odd number to keep a quorum.</td>
        </tr>
        <tr>
            <td id="zookeeper--pdb"><a href="./values.yaml#L732">zookeeper.pdb</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">create: false</pre>
</div>
            </td>
            <td>PodDisruptionBudget of the ZooKeeper pods.</td>
        </tr>
        <tr>
            <td id="zookeeper--pdb--create"><a href="./values.yaml#L735">zookeeper.pdb.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Specifies whether a Pod Disruption Budget should be created</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence"><a href="./values.yaml#L739">zookeeper.persistence</a></td>
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
            <td id="zookeeper--persistence--enabled"><a href="./values.yaml#L742">zookeeper.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable ZooKeeper data persistence using PVC. If false, use emptyDir</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--existingClaim"><a href="./values.yaml#L746">zookeeper.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of an existing PVC to use (only when deploying a single replica)</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--storageClass"><a href="./values.yaml#L750">zookeeper.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>StorageClass of the ZooKeeper data claim; `-` disables dynamic provisioning, null uses the cluster default, and `global.storageClass` overrides it.</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--accessModes"><a href="./values.yaml#L754">zookeeper.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>PVC Access modes</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--size"><a href="./values.yaml#L759">zookeeper.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8Gi</pre>
</div>
            </td>
            <td>PVC Storage Request for ZooKeeper data volume</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--annotations"><a href="./values.yaml#L763">zookeeper.persistence.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the PVC</td>
        </tr>
        <tr>
            <td id="zookeeper--resources"><a href="./values.yaml#L767">zookeeper.resources</a></td>
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
            <td id="externalClickhouse"><a href="./values.yaml#L975">externalClickhouse</a></td>
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
            <td id="externalClickhouse--host"><a href="./values.yaml#L980">externalClickhouse.host</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Host of the external ClickHouse cluster. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--cluster"><a href="./values.yaml#L985">externalClickhouse.cluster</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster</pre>
</div>
            </td>
            <td>Cluster of the external ClickHouse that the migrator creates SigNoz's tables on and SigNoz queries. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--database"><a href="./values.yaml#L990">externalClickhouse.database</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_metrics</pre>
</div>
            </td>
            <td>Database the collector writes metrics to. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--traceDatabase"><a href="./values.yaml#L995">externalClickhouse.traceDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_traces</pre>
</div>
            </td>
            <td>Database the collector writes traces to. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--logDatabase"><a href="./values.yaml#L1000">externalClickhouse.logDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_logs</pre>
</div>
            </td>
            <td>Database the collector writes logs to. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--meterDatabase"><a href="./values.yaml#L1005">externalClickhouse.meterDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_meter</pre>
</div>
            </td>
            <td>Database the collector writes meter data to. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--user"><a href="./values.yaml#L1010">externalClickhouse.user</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Username to connect to the external cluster. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--password"><a href="./values.yaml#L1016">externalClickhouse.password</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Password of `externalClickhouse.user`, written into the Secret `<clickhouse.fullname>-credentials` that the components read; ignored when `externalClickhouse.existingSecret` is set. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--existingSecret"><a href="./values.yaml#L1022">externalClickhouse.existingSecret</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of a Secret you created that holds the password of `externalClickhouse.user`; when set, the chart creates no Secret and the components read this one. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--existingSecretPasswordKey"><a href="./values.yaml#L1027">externalClickhouse.existingSecretPasswordKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">password</pre>
</div>
            </td>
            <td>Key of the password inside `externalClickhouse.existingSecret`. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--secure"><a href="./values.yaml#L1032">externalClickhouse.secure</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to use a TLS connection when connecting to ClickHouse. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--verify"><a href="./values.yaml#L1037">externalClickhouse.verify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to verify the TLS certificate on connection to ClickHouse. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--httpPort"><a href="./values.yaml#L1042">externalClickhouse.httpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8123</pre>
</div>
            </td>
            <td>HTTP port of the external ClickHouse instance. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--tcpPort"><a href="./values.yaml#L1047">externalClickhouse.tcpPort</a></td>
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
            <td id="signoz"><a href="./values.yaml#L1051">signoz</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Default values for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--name"><a href="./values.yaml#L1055">signoz.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz</pre>
</div>
            </td>
            <td>The name of the SigNoz component.</td>
        </tr>
        <tr>
            <td id="signoz--replicaCount"><a href="./values.yaml#L1059">signoz.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>The number of pod replicas for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--image"><a href="./values.yaml#L1062">signoz.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">pullPolicy: IfNotPresent
registry: docker.io
repository: signoz/signoz
tag: v0.151.0</pre>
</div>
            </td>
            <td>Image configuration for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--imagePullSecrets"><a href="./values.yaml#L1080">signoz.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for SigNoz. This has higher precedence than the root level or global value.</td>
        </tr>
        <tr>
            <td id="signoz--serviceAccount"><a href="./values.yaml#L1083">signoz.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
create: true
name: null</pre>
</div>
            </td>
            <td>Service Account configuration for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--annotations"><a href="./values.yaml#L1127">signoz.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--additionalArgs"><a href="./values.yaml#L1131">signoz.additionalArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional command-line arguments for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--env"><a href="./values.yaml#L1155">signoz.env</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_alertmanager_provider: signoz
signoz_alertmanager_signoz_external__url: http://localhost:8080
signoz_emailing_enabled: false
signoz_prometheus_active__query__tracker_enabled: false
signoz_telemetrystore_provider: clickhouse</pre>
</div>
            </td>
            <td>Environment variables for SigNoz. Refer to the official documentation for a complete list: https://github.com/SigNoz/signoz/blob/main/conf/example.yaml Note on Variable Naming: Environment variables are derived from the YAML configuration. For example, a key `provider` under the `telemetry_store` section becomes `signoz_telemetrystore_provider`.</td>
        </tr>
        <tr>
            <td id="signoz--podSecurityContext"><a href="./values.yaml#L1172">signoz.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Pod-level security context.</td>
        </tr>
        <tr>
            <td id="signoz--podAnnotations"><a href="./values.yaml#L1178">signoz.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--securityContext"><a href="./values.yaml#L1182">signoz.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Container-level security context.</td>
        </tr>
        <tr>
            <td id="signoz--additionalVolumeMounts"><a href="./values.yaml#L1193">signoz.additionalVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volume mounts for the SigNoz container.</td>
        </tr>
        <tr>
            <td id="signoz--additionalVolumes"><a href="./values.yaml#L1197">signoz.additionalVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volumes for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--livenessProbe"><a href="./values.yaml#L1201">signoz.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Liveness probe configuration.</td>
        </tr>
        <tr>
            <td id="signoz--readinessProbe"><a href="./values.yaml#L1213">signoz.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Readiness probe configuration.</td>
        </tr>
        <tr>
            <td id="signoz--customLivenessProbe"><a href="./values.yaml#L1225">signoz.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom liveness probe to override the default.</td>
        </tr>
        <tr>
            <td id="signoz--customReadinessProbe"><a href="./values.yaml#L1229">signoz.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom readiness probe to override the default.</td>
        </tr>
        <tr>
            <td id="signoz--resources"><a href="./values.yaml#L1264">signoz.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Resource requests and limits. Ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
        </tr>
        <tr>
            <td id="signoz--priorityClassName"><a href="./values.yaml#L1275">signoz.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class for the SigNoz pods.</td>
        </tr>
        <tr>
            <td id="signoz--nodeSelector"><a href="./values.yaml#L1279">signoz.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--tolerations"><a href="./values.yaml#L1283">signoz.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--affinity"><a href="./values.yaml#L1287">signoz.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--topologySpreadConstraints"><a href="./values.yaml#L1291">signoz.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="signoz--persistence"><a href="./values.yaml#L1294">signoz.persistence</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">accessModes:
    - ReadWriteOnce
enabled: true
existingClaim: ""
size: 1Gi
storageClass: null</pre>
</div>
            </td>
            <td>Persistence configuration for the internal SQLite database.</td>
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
            <td id="signoz--service"><a href="./values.yaml#L1096">signoz.service</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
internalNodePort: null
internalPort: 8085
labels: {}
nodePort: null
opampInternalNodePort: null
opampPort: 4320
port: 8080
type: ClusterIP</pre>
</div>
            </td>
            <td>Service configuration for SigNoz. This allows you to configure how SigNoz is exposed within the Kubernetes cluster.</td>
        </tr>
        <tr>
            <td id="signoz--ingress"><a href="./values.yaml#L1232">signoz.ingress</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
className: ""
enabled: false
hosts:
    - host: signoz.domain.com
      paths:
        - path: /
          pathType: ImplementationSpecific
          port: 8080
tls: []</pre>
</div>
            </td>
            <td>Ingress configuration for SigNoz.</td>
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
            <td id="telemetryStoreMigrator"><a href="./values.yaml#L1314">telemetryStoreMigrator</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Default values for the Telemetry Store Migrator.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--enabled"><a href="./values.yaml#L1318">telemetryStoreMigrator.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Telemetry Store Migrator component.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--name"><a href="./values.yaml#L1322">telemetryStoreMigrator.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz-telemetrystore-migrator</pre>
</div>
            </td>
            <td>The name of the Telemetry Store Migrator component.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--annotations"><a href="./values.yaml#L1326">telemetryStoreMigrator.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the Telemetry Store Migrator job.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--enableReplication"><a href="./values.yaml#L1330">telemetryStoreMigrator.enableReplication</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to enable replication for the Telemetry Store Migrator.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--timeout"><a href="./values.yaml#L1334">telemetryStoreMigrator.timeout</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10m</pre>
</div>
            </td>
            <td>Timeout for the migration.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--ttlSecondsAfterFinished"><a href="./values.yaml#L1340">telemetryStoreMigrator.ttlSecondsAfterFinished</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Seconds Kubernetes keeps a finished migrator Job, and its logs, before deleting it. Set it (for example `604800`) to clean up Jobs a failed upgrade leaves behind; leave it unset under Argo CD, which recreates a deleted Job and re-runs the migrator.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--nodeSelector"><a href="./values.yaml#L1344">telemetryStoreMigrator.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--tolerations"><a href="./values.yaml#L1348">telemetryStoreMigrator.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--affinity"><a href="./values.yaml#L1352">telemetryStoreMigrator.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--topologySpreadConstraints"><a href="./values.yaml#L1356">telemetryStoreMigrator.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--resources"><a href="./values.yaml#L1360">telemetryStoreMigrator.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resource requests and limits for all migrator containers.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--serviceAccount"><a href="./values.yaml#L1365">telemetryStoreMigrator.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
create: false
name: null</pre>
</div>
            </td>
            <td>ServiceAccount of the migrator Job; by default none is created and the Job runs as `default`. Set `create: true` when a policy or credential is bound to a ServiceAccount. On an install from a chart before 0.152.0, first delete the old `signoz-telemetrystore-migrator` ServiceAccount or upgrade with `--take-ownership`.</td>
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
            <td id="otelCollector"><a href="./values.yaml#L1379">otelCollector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Default values for the OpenTelemetry Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--name"><a href="./values.yaml#L1383">otelCollector.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">otel-collector</pre>
</div>
            </td>
            <td>The name of the Otel Collector component.</td>
        </tr>
        <tr>
            <td id="otelCollector--image"><a href="./values.yaml#L1387">otelCollector.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Image configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--imagePullSecrets"><a href="./values.yaml#L1404">otelCollector.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for the Otel Collector. This has higher precedence than the root level or global value.</td>
        </tr>
        <tr>
            <td id="otelCollector--strategy"><a href="./values.yaml#L1408">otelCollector.strategy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">RollingUpdate</pre>
</div>
            </td>
            <td>Deployment strategy to use</td>
        </tr>
        <tr>
            <td id="otelCollector--command"><a href="./values.yaml#L1411">otelCollector.command</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">extraArgs: null
name: /signoz-otel-collector</pre>
</div>
            </td>
            <td>Configuration for the Otel Collector executable.</td>
        </tr>
        <tr>
            <td id="otelCollector--configMap"><a href="./values.yaml#L1419">otelCollector.configMap</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">create: true</pre>
</div>
            </td>
            <td>ConfigMap settings.</td>
        </tr>
        <tr>
            <td id="otelCollector--serviceAccount"><a href="./values.yaml#L1425">otelCollector.serviceAccount</a></td>
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
            <td id="otelCollector--annotations"><a href="./values.yaml#L1453">otelCollector.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the Otel Collector Deployment.</td>
        </tr>
        <tr>
            <td id="otelCollector--podAnnotations"><a href="./values.yaml#L1457">otelCollector.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the Otel Collector pod(s).</td>
        </tr>
        <tr>
            <td id="otelCollector--podLabels"><a href="./values.yaml#L1463">otelCollector.podLabels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels for the Otel Collector pod(s).</td>
        </tr>
        <tr>
            <td id="otelCollector--additionalEnvs"><a href="./values.yaml#L1467">otelCollector.additionalEnvs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional environment variables for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--lowCardinalityExceptionGrouping"><a href="./values.yaml#L1473">otelCollector.lowCardinalityExceptionGrouping</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable grouping of exceptions with the same name but different stack traces. This is a tradeoff between cardinality and accuracy.</td>
        </tr>
        <tr>
            <td id="otelCollector--minReadySeconds"><a href="./values.yaml#L1477">otelCollector.minReadySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Minimum number of seconds for a new pod to be ready.</td>
        </tr>
        <tr>
            <td id="otelCollector--progressDeadlineSeconds"><a href="./values.yaml#L1481">otelCollector.progressDeadlineSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">600</pre>
</div>
            </td>
            <td>Maximum time in seconds for a deployment to make progress before it is considered failed.</td>
        </tr>
        <tr>
            <td id="otelCollector--replicaCount"><a href="./values.yaml#L1485">otelCollector.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>The number of pod replicas for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole"><a href="./values.yaml#L1489">otelCollector.clusterRole</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>RBAC ClusterRole configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--livenessProbe"><a href="./values.yaml#L1732">otelCollector.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Liveness probe configuration. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes</td>
        </tr>
        <tr>
            <td id="otelCollector--readinessProbe"><a href="./values.yaml#L1744">otelCollector.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Readiness probe configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--customLivenessProbe"><a href="./values.yaml#L1756">otelCollector.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom liveness probe to override the default.</td>
        </tr>
        <tr>
            <td id="otelCollector--customReadinessProbe"><a href="./values.yaml#L1760">otelCollector.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom readiness probe to override the default.</td>
        </tr>
        <tr>
            <td id="otelCollector--extraVolumeMounts"><a href="./values.yaml#L1764">otelCollector.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the Otel Collector pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--extraVolumes"><a href="./values.yaml#L1768">otelCollector.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the Otel Collector pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--resources"><a href="./values.yaml#L1805">otelCollector.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Resource requests and limits. Ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
        </tr>
        <tr>
            <td id="otelCollector--priorityClassName"><a href="./values.yaml#L1816">otelCollector.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class for the Otel Collector pods.</td>
        </tr>
        <tr>
            <td id="otelCollector--nodeSelector"><a href="./values.yaml#L1820">otelCollector.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--tolerations"><a href="./values.yaml#L1824">otelCollector.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--affinity"><a href="./values.yaml#L1828">otelCollector.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--topologySpreadConstraints"><a href="./values.yaml#L1832">otelCollector.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="otelCollector--podSecurityContext"><a href="./values.yaml#L1842">otelCollector.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Pod-level security context.</td>
        </tr>
        <tr>
            <td id="otelCollector--securityContext"><a href="./values.yaml#L1848">otelCollector.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Container-level security context.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling"><a href="./values.yaml#L1859">otelCollector.autoscaling</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Autoscaling configuration (HPA).</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda"><a href="./values.yaml#L1896">otelCollector.autoscaling.keda</a></td>
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
            <td id="otelCollector--service"><a href="./values.yaml#L1437">otelCollector.service</a></td>
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
            <td id="otelCollector--ingress"><a href="./values.yaml#L1771">otelCollector.ingress</a></td>
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
            <td id="otelCollector--ingress--hosts"><a href="./values.yaml#L1789">otelCollector.ingress.hosts</a></td>
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
            <td id="otelCollector--ports"><a href="./values.yaml#L1529">otelCollector.ports</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Port configurations for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp"><a href="./values.yaml#L1532">otelCollector.ports.otlp</a></td>
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
            <td id="otelCollector--ports--otlp-http"><a href="./values.yaml#L1550">otelCollector.ports.otlp-http</a></td>
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
            <td id="otelCollector--ports--jaeger-compact"><a href="./values.yaml#L1568">otelCollector.ports.jaeger-compact</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">containerPort: 6831
enabled: false
nodePort: ""
protocol: UDP
servicePort: 6831</pre>
</div>
            </td>
            <td>Jaeger Compact port configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-thrift"><a href="./values.yaml#L1586">otelCollector.ports.jaeger-thrift</a></td>
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
            <td id="otelCollector--ports--jaeger-grpc"><a href="./values.yaml#L1604">otelCollector.ports.jaeger-grpc</a></td>
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
            <td id="otelCollector--ports--zipkin"><a href="./values.yaml#L1622">otelCollector.ports.zipkin</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">containerPort: 9411
enabled: false
nodePort: ""
protocol: TCP
servicePort: 9411</pre>
</div>
            </td>
            <td>Zipkin port configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--metrics"><a href="./values.yaml#L1640">otelCollector.ports.metrics</a></td>
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
            <td id="otelCollector--ports--zpages"><a href="./values.yaml#L1658">otelCollector.ports.zpages</a></td>
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
            <td id="otelCollector--ports--pprof"><a href="./values.yaml#L1676">otelCollector.ports.pprof</a></td>
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
            <td id="otelCollector--ports--logsheroku"><a href="./values.yaml#L1694">otelCollector.ports.logsheroku</a></td>
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
            <td id="otelCollector--ports--logsjson"><a href="./values.yaml#L1712">otelCollector.ports.logsjson</a></td>
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
            <td id="otelCollector--config"><a href="./values.yaml#L1921">otelCollector.config</a></td>
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
            <td id="postgresql--enabled"><a href="./values.yaml#L2063">postgresql.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable or disable the PostgreSQL for signoz. For more details, check out the postgresql chart: https://github.com/SigNoz/charts/tree/main/charts/postgresql</td>
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
            <td id="signoz-otel-gateway"><a href="./values.yaml#L2066">signoz-otel-gateway</a></td>
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
            <td id="signoz-otel-gateway--strategy"><a href="./values.yaml#L2073">signoz-otel-gateway.strategy</a></td>
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
            <td id="redpanda"><a href="./values.yaml#L2286">redpanda</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>This component is configurable with licensed version of SigNoz.</td>
        </tr>
    </tbody>
</table>

