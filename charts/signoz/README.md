
# SigNoz

![Version: 0.149.0](https://img.shields.io/badge/Version-0.149.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.149.0](https://img.shields.io/badge/AppVersion-v0.149.0-informational?style=flat-square)

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

<h3>Global</h3>
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
<h3>General</h3>
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
            <td>ClickHouse settings. The ClickHouseInstallation, its ConfigMaps and ServiceAccount are rendered by this chart; see the keys below.</td>
        </tr>
        <tr>
            <td id="clickhouse--enabled"><a href="./values.yaml#L62">clickhouse.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to install ClickHouse. If false, `clickhouse.host` must be set.</td>
        </tr>
        <tr>
            <td id="clickhouse--name"><a href="./values.yaml#L65">clickhouse.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">clickhouse</pre>
</div>
            </td>
            <td>Name of the clickhouse component</td>
        </tr>
        <tr>
            <td id="clickhouse--nameOverride"><a href="./values.yaml#L69">clickhouse.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name override for ClickHouse.</td>
        </tr>
        <tr>
            <td id="clickhouse--fullnameOverride"><a href="./values.yaml#L73">clickhouse.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Fullname override for ClickHouse.</td>
        </tr>
        <tr>
            <td id="clickhouse--namespace"><a href="./values.yaml#L82">clickhouse.namespace</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>The namespace ClickHouse (the ClickHouseInstallation, its ConfigMaps, ServiceAccount and hooks) is installed into. Defaults to the release namespace. When set to another namespace the chart creates it. The operator stays in the release namespace; to make it manage ClickHouse there, either set `altinity-clickhouse-operator.namespaceOverride` to the same value (operator runs next to ClickHouse, as older chart versions did), or set `altinity-clickhouse-operator.watchNamespaces` to a list with that one namespace as a plain name (no regexp, one entry; two entries or a regexp make the operator watch all namespaces) and `altinity-clickhouse-operator.rbac.namespaceScoped: false`.</td>
        </tr>
        <tr>
            <td id="clickhouse--image"><a href="./values.yaml#L85">clickhouse.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">pullPolicy: IfNotPresent
registry: docker.io
repository: clickhouse/clickhouse-server
tag: 25.12.5</pre>
</div>
            </td>
            <td>ClickHouse image configuration.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--registry"><a href="./values.yaml#L89">clickhouse.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">docker.io</pre>
</div>
            </td>
            <td>ClickHouse image registry to use.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--repository"><a href="./values.yaml#L93">clickhouse.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">clickhouse/clickhouse-server</pre>
</div>
            </td>
            <td>ClickHouse image repository to use.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--tag"><a href="./values.yaml#L98">clickhouse.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">25.12.5</pre>
</div>
            </td>
            <td>ClickHouse image tag to use. SigNoz is not always tested with the latest version of ClickHouse. Only override if you know what you are doing.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--pullPolicy"><a href="./values.yaml#L102">clickhouse.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>ClickHouse image pull policy.</td>
        </tr>
        <tr>
            <td id="clickhouse--imagePullSecrets"><a href="./values.yaml#L106">clickhouse.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image Registry Secret Names for ClickHouse. Merged with `global.imagePullSecrets` if set.</td>
        </tr>
        <tr>
            <td id="clickhouse--layout"><a href="./values.yaml#L112">clickhouse.layout</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">replicasCount: 1
shardsCount: 1</pre>
</div>
            </td>
            <td>ClickHouse cluster layout. (Experimental, use at own risk) For a full list of options, see https://github.com/Altinity/clickhouse-operator/blob/master/docs/custom_resource_explained.md</td>
        </tr>
        <tr>
            <td id="clickhouse--cluster"><a href="./values.yaml#L118">clickhouse.cluster</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster</pre>
</div>
            </td>
            <td>ClickHouse cluster name.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount"><a href="./values.yaml#L121">clickhouse.serviceAccount</a></td>
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
            <td id="clickhouse--serviceAccount--create"><a href="./values.yaml#L125">clickhouse.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a service account should be created.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount--annotations"><a href="./values.yaml#L129">clickhouse.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the service account.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount--name"><a href="./values.yaml#L133">clickhouse.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>The name of the service account to use. If not set and create is true, a name is generated.</td>
        </tr>
        <tr>
            <td id="clickhouse--labels"><a href="./values.yaml#L136">clickhouse.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ClickHouse instance labels</td>
        </tr>
        <tr>
            <td id="clickhouse--annotations"><a href="./values.yaml#L140">clickhouse.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ClickHouse instance.</td>
        </tr>
        <tr>
            <td id="clickhouse--podLabels"><a href="./values.yaml#L143">clickhouse.podLabels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ClickHouse pod labels</td>
        </tr>
        <tr>
            <td id="clickhouse--podAnnotations"><a href="./values.yaml#L146">clickhouse.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io/path: /metrics
signoz.io/port: "9363"
signoz.io/scrape: "true"</pre>
</div>
            </td>
            <td>Annotations for the ClickHouse pod(s).</td>
        </tr>
        <tr>
            <td id="clickhouse--service"><a href="./values.yaml#L152">clickhouse.service</a></td>
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
            <td id="clickhouse--service--annotations"><a href="./values.yaml#L156">clickhouse.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ClickHouse service.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--type"><a href="./values.yaml#L160">clickhouse.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>Service type. `LoadBalancer` allows external access; `NodePort` is more secure and has no extra cost.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--httpPort"><a href="./values.yaml#L164">clickhouse.service.httpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8123</pre>
</div>
            </td>
            <td>ClickHouse HTTP port.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--tcpPort"><a href="./values.yaml#L168">clickhouse.service.tcpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">9000</pre>
</div>
            </td>
            <td>ClickHouse TCP port.</td>
        </tr>
        <tr>
            <td id="clickhouse--database"><a href="./values.yaml#L172">clickhouse.database</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_metrics</pre>
</div>
            </td>
            <td>ClickHouse Settings for SigNoz Metrics.</td>
        </tr>
        <tr>
            <td id="clickhouse--traceDatabase"><a href="./values.yaml#L176">clickhouse.traceDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_traces</pre>
</div>
            </td>
            <td>ClickHouse Settings for SigNoz Traces.</td>
        </tr>
        <tr>
            <td id="clickhouse--logDatabase"><a href="./values.yaml#L180">clickhouse.logDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_logs</pre>
</div>
            </td>
            <td>ClickHouse Settings for SigNoz Logs.</td>
        </tr>
        <tr>
            <td id="clickhouse--meterDatabase"><a href="./values.yaml#L184">clickhouse.meterDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_meter</pre>
</div>
            </td>
            <td>Clickhouse meter Database (SigNoz Meter)</td>
        </tr>
        <tr>
            <td id="clickhouse--user"><a href="./values.yaml#L188">clickhouse.user</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">admin</pre>
</div>
            </td>
            <td>ClickHouse user.</td>
        </tr>
        <tr>
            <td id="clickhouse--password"><a href="./values.yaml#L192">clickhouse.password</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">27ff0399-0d3a-4bd8-919d-17c2181e6fb9</pre>
</div>
            </td>
            <td>ClickHouse password.</td>
        </tr>
        <tr>
            <td id="clickhouse--secure"><a href="./values.yaml#L196">clickhouse.secure</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to use a TLS connection when connecting to ClickHouse.</td>
        </tr>
        <tr>
            <td id="clickhouse--verify"><a href="./values.yaml#L200">clickhouse.verify</a></td>
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
            <td>An allowlist of IP addresses or network masks the ClickHouse user can access from. By default, private network ranges are allowed. Refs: - https://clickhouse.com/docs/en/operations/settings/settings-users/#user-namenetworks - https://en.wikipedia.org/wiki/Reserved_IP_addresses#IPv4</td>
        </tr>
        <tr>
            <td id="clickhouse--externalZookeeper"><a href="./values.yaml#L217">clickhouse.externalZookeeper</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Configuration for an external Zookeeper.</td>
        </tr>
        <tr>
            <td id="clickhouse--profiles"><a href="./values.yaml#L229">clickhouse.profiles</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ClickHouse user profile configuration. Use this to override profile settings, e.g., `default/max_memory_usage: 40000000000`. For the full list of settings, see: - https://clickhouse.com/docs/en/operations/settings/settings-profiles/ - https://clickhouse.com/docs/en/operations/settings/settings/</td>
        </tr>
        <tr>
            <td id="clickhouse--defaultProfiles"><a href="./values.yaml#L233">clickhouse.defaultProfiles</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Default user profile configuration for ClickHouse. !!! Please DO NOT override this !!!</td>
        </tr>
        <tr>
            <td id="clickhouse--settings"><a href="./values.yaml#L245">clickhouse.settings</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>ClickHouse settings configuration. You can use this to override settings, e.g., `prometheus/port: 9363`. For the full list of settings, see https://clickhouse.com/docs/en/operations/settings/settings/</td>
        </tr>
        <tr>
            <td id="clickhouse--defaultSettings"><a href="./values.yaml#L254">clickhouse.defaultSettings</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">format_schema_path: /etc/clickhouse-server/config.d/
user_defined_executable_functions_config: /etc/clickhouse-server/functions/custom-functions.xml
user_scripts_path: /var/lib/clickhouse/user_scripts/</pre>
</div>
            </td>
            <td>Default settings for ClickHouse. !!! Please DO NOT override this !!!</td>
        </tr>
        <tr>
            <td id="clickhouse--files"><a href="./values.yaml#L264">clickhouse.files</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>ClickHouse configuration files. Refs: - https://clickhouse.com/docs/en/operations/configuration-files/ - https://github.com/Altinity/clickhouse-operator/blob/master/docs/chi-examples/05-settings-05-files-nested.yaml</td>
        </tr>
        <tr>
            <td id="clickhouse--templates"><a href="./values.yaml#L312">clickhouse.templates</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">volumeClaimTemplates: []</pre>
</div>
            </td>
            <td>Custom volume claim templates for ClickHouse pod This is only used when persistence.enabled is false</td>
        </tr>
        <tr>
            <td id="clickhouse--podDistribution"><a href="./values.yaml#L319">clickhouse.podDistribution</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topologies for distributing the ClickHouse pods. Possible values can be found here: https://github.com/Altinity/clickhouse-operator/blob/1414503921da3ae475eb6f9a296d3475a6993768/docs/chi-examples/99-clickhouseinstallation-max.yaml#L428-L481</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage"><a href="./values.yaml#L331">clickhouse.coldStorage</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Cold storage configuration.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--enabled"><a href="./values.yaml#L335">clickhouse.coldStorage.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable S3/GCS cold storage.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--defaultKeepFreeSpaceBytes"><a href="./values.yaml#L339">clickhouse.coldStorage.defaultKeepFreeSpaceBytes</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"10485760"</pre>
</div>
            </td>
            <td>Reserve free space on the default disk (in bytes).</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--type"><a href="./values.yaml#L343">clickhouse.coldStorage.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">s3</pre>
</div>
            </td>
            <td>Type of cold storage: `s3` or `gcs`.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--endpoint"><a href="./values.yaml#L350">clickhouse.coldStorage.endpoint</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">https://<bucket-name>.s3-<region>.amazonaws.com/data/</pre>
</div>
            </td>
            <td>Endpoint for S3 or GCS. For S3 (us-east-1): https://s3.amazonaws.com For S3 (other regions): https://s3-<region>.amazonaws.com For GCS: https://storage.googleapis.com/<bucket-name>/data/</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--accessKey"><a href="./values.yaml#L354">clickhouse.coldStorage.accessKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml"><access_key_id></pre>
</div>
            </td>
            <td>Access Key ID for S3 or GCS.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--secretAccess"><a href="./values.yaml#L358">clickhouse.coldStorage.secretAccess</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml"><secret_access_key></pre>
</div>
            </td>
            <td>Secret Access Key for S3 or GCS.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--role"><a href="./values.yaml#L361">clickhouse.coldStorage.role</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::******:role/*****
enabled: false</pre>
</div>
            </td>
            <td>AWS IAM role configuration to use environment variables instead of keys.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--role--enabled"><a href="./values.yaml#L365">clickhouse.coldStorage.role.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable using an AWS IAM ARN role.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--role--annotations"><a href="./values.yaml#L368">clickhouse.coldStorage.role.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">eks.amazonaws.com/role-arn: arn:aws:iam::******:role/*****</pre>
</div>
            </td>
            <td>Annotations for the service account to assume the AWS role.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs"><a href="./values.yaml#L373">clickhouse.logs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Collection of ClickHouse system table entries as logs, by a `signoz-otel-collector` sidecar in the ClickHouse pod.</td>
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
            <td id="clickhouse--logs--system--config"><a href="./values.yaml#L387">clickhouse.logs.system.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Config of the opentelemetry collector</td>
        </tr>
        <tr>
            <td id="clickhouse--installCustomStorageClass"><a href="./values.yaml#L438">clickhouse.installCustomStorageClass</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>When enabled with `cloud` as `gcp` or `aws`, creates a custom storage class with volume expansion permission.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook"><a href="./values.yaml#L448">clickhouse.operatorUpgradeHook</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Pre-upgrade hook for installs created before the operator came from Altinity's chart. The old operator Deployment has different selector labels, and a Deployment selector cannot be changed in place, so the hook deletes the old Deployment and Helm then creates the new one under the same name. It selects by the old labels only, so it finds nothing on later upgrades and on fresh installs it never runs (pre-upgrade only). Set `clickhouse.operatorUpgradeHook.enabled` to false to skip it; then delete the old Deployment yourself before upgrading:   kubectl delete deployment <release>-clickhouse-operator -n <namespace></td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--enabled"><a href="./values.yaml#L451">clickhouse.operatorUpgradeHook.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Run the hook on `helm upgrade`.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--registry"><a href="./values.yaml#L455">clickhouse.operatorUpgradeHook.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">registry.k8s.io</pre>
</div>
            </td>
            <td>Registry of the kubectl image. `global.imageRegistry` takes precedence when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--repository"><a href="./values.yaml#L458">clickhouse.operatorUpgradeHook.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">kubectl</pre>
</div>
            </td>
            <td>Repository of the kubectl image.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--tag"><a href="./values.yaml#L461">clickhouse.operatorUpgradeHook.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v1.36.3</pre>
</div>
            </td>
            <td>Tag of the kubectl im  age. The image publishes no `latest` tag.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--pullPolicy"><a href="./values.yaml#L464">clickhouse.operatorUpgradeHook.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Pull policy of the kubectl image.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--backoffLimit"><a href="./values.yaml#L467">clickhouse.operatorUpgradeHook.backoffLimit</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3</pre>
</div>
            </td>
            <td>Retries before the Job, and with it the upgrade, is marked failed.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--resources"><a href="./values.yaml#L470">clickhouse.operatorUpgradeHook.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resources of the hook container.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers"><a href="./values.yaml#L474">clickhouse.initContainers</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Init container to copy the histogramQuantile UDF.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraContainers"><a href="./values.yaml#L515">clickhouse.extraContainers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra containers for ClickHouse pod</td>
        </tr>
        <tr>
            <td id="clickhouse--startupProbe"><a href="./values.yaml#L523">clickhouse.startupProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Startup probe of the ClickHouse container (HTTP GET on `path`). When `enabled` is false, `customStartupProbe` is used if set.</td>
        </tr>
        <tr>
            <td id="clickhouse--livenessProbe"><a href="./values.yaml#L535">clickhouse.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Liveness probe of the ClickHouse container (HTTP GET on `path`). When `enabled` is false, `customLivenessProbe` is used if set.</td>
        </tr>
        <tr>
            <td id="clickhouse--readinessProbe"><a href="./values.yaml#L547">clickhouse.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Readiness probe of the ClickHouse container (HTTP GET on `path`). When `enabled` is false, `customReadinessProbe` is used if set.</td>
        </tr>
        <tr>
            <td id="clickhouse--customStartupProbe"><a href="./values.yaml#L560">clickhouse.customStartupProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom startup probe of the ClickHouse container, used when `startupProbe.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--customLivenessProbe"><a href="./values.yaml#L563">clickhouse.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom liveness probe of the ClickHouse container, used when `livenessProbe.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--customReadinessProbe"><a href="./values.yaml#L566">clickhouse.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom readiness probe of the ClickHouse container, used when `readinessProbe.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--resources"><a href="./values.yaml#L571">clickhouse.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">requests:
    cpu: 100m
    memory: 200Mi</pre>
</div>
            </td>
            <td>Configure resource requests and limits. Update according to your use case. Ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
        </tr>
        <tr>
            <td id="clickhouse--securityContext"><a href="./values.yaml#L581">clickhouse.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: true
fsGroup: 101
fsGroupChangePolicy: OnRootMismatch
runAsGroup: 101
runAsUser: 101</pre>
</div>
            </td>
            <td>Security context for the ClickHouse node.</td>
        </tr>
        <tr>
            <td id="clickhouse--priorityClassName"><a href="./values.yaml#L589">clickhouse.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Clickhouse priority class name</td>
        </tr>
        <tr>
            <td id="clickhouse--nodeSelector"><a href="./values.yaml#L593">clickhouse.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for assigning the ClickHouse pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--tolerations"><a href="./values.yaml#L597">clickhouse.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Toleration labels for ClickHouse pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--affinity"><a href="./values.yaml#L601">clickhouse.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for the ClickHouse pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--topologySpreadConstraints"><a href="./values.yaml#L604">clickhouse.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>TopologySpreadConstraints describes how clickhouse pods ought to spread</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence"><a href="./values.yaml#L608">clickhouse.persistence</a></td>
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
            <td id="clickhouse--persistence--enabled"><a href="./values.yaml#L612">clickhouse.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable data persistence using a PVC for ClickHouse data.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--existingClaim"><a href="./values.yaml#L616">clickhouse.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Use a manually managed Persistent Volume Claim. If defined, the PVC must be created manually.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--storageClass"><a href="./values.yaml#L620">clickhouse.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Persistent Volume Storage Class. If "-", disables dynamic provisioning. If null, uses the default provisioner.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--accessModes"><a href="./values.yaml#L624">clickhouse.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access Modes for the persistent volume.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--size"><a href="./values.yaml#L629">clickhouse.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">20Gi</pre>
</div>
            </td>
            <td>Persistent Volume size.</td>
        </tr>
        <tr>
            <td id="clickhouse--additionalVolumes"><a href="./values.yaml#L632">clickhouse.additionalVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volumes for ClickHouse pod</td>
        </tr>
        <tr>
            <td id="clickhouse--additionalVolumeMounts"><a href="./values.yaml#L635">clickhouse.additionalVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volume mounts for ClickHouse pod</td>
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
            <td id="zookeeper"><a href="./values.yaml#L641">zookeeper</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Zookeeper default values. Ref: https://github.com/bitnami/charts/blob/main/bitnami/zookeeper/values.yaml</td>
        </tr>
        <tr>
            <td id="zookeeper--image"><a href="./values.yaml#L653">zookeeper.image</a></td>
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
            <td id="zookeeper--image--registry"><a href="./values.yaml#L656">zookeeper.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Zookeeper image registry to use.</td>
        </tr>
        <tr>
            <td id="zookeeper--image--repository"><a href="./values.yaml#L659">zookeeper.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/zookeeper</pre>
</div>
            </td>
            <td>Zookeeper image repository to use.</td>
        </tr>
        <tr>
            <td id="zookeeper--image--tag"><a href="./values.yaml#L664">zookeeper.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3.7.1</pre>
</div>
            </td>
            <td>Zookeeper image tag. Note: SigNoz ClickHouse does not support all versions of Zookeeper. Please override the default only if you know what you are doing.</td>
        </tr>
        <tr>
            <td id="zookeeper--nameOverride"><a href="./values.yaml#L668">zookeeper.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name override for zookeeper app</td>
        </tr>
        <tr>
            <td id="zookeeper--fullnameOverride"><a href="./values.yaml#L671">zookeeper.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Fullname override for zookeeper app</td>
        </tr>
        <tr>
            <td id="zookeeper--namespaceOverride"><a href="./values.yaml#L675">zookeeper.namespaceOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Whether to install zookeeper into a different namespace than the parent</td>
        </tr>
        <tr>
            <td id="zookeeper--podAnnotations"><a href="./values.yaml#L679">zookeeper.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io/path: /metrics
signoz.io/port: "9141"
signoz.io/scrape: "true"</pre>
</div>
            </td>
            <td>Zookeeper pod(s) annotation.</td>
        </tr>
        <tr>
            <td id="zookeeper--autopurge"><a href="./values.yaml#L686">zookeeper.autopurge</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">purgeInterval: 1</pre>
</div>
            </td>
            <td>Ongoing data directory cleanup configuration.</td>
        </tr>
        <tr>
            <td id="zookeeper--autopurge--purgeInterval"><a href="./values.yaml#L689">zookeeper.autopurge.purgeInterval</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>The time interval (in hours) for which the purge task has to be triggered</td>
        </tr>
        <tr>
            <td id="zookeeper--metrics"><a href="./values.yaml#L693">zookeeper.metrics</a></td>
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
            <td id="zookeeper--metrics--enabled"><a href="./values.yaml#L696">zookeeper.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable Prometheus to access ZooKeeper metrics endpoint.</td>
        </tr>
        <tr>
            <td id="zookeeper--metrics--service--annotations"><a href="./values.yaml#L702">zookeeper.metrics.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ZooKeeper metrics service annotation</td>
        </tr>
        <tr>
            <td id="zookeeper--logLevel"><a href="./values.yaml#L709">zookeeper.logLevel</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">INFO</pre>
</div>
            </td>
            <td>Zookeeper log level.</td>
        </tr>
        <tr>
            <td id="zookeeper--livenessProbe"><a href="./values.yaml#L713">zookeeper.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>Zookeeper liveness probe settings.</td>
        </tr>
        <tr>
            <td id="zookeeper--readinessProbe"><a href="./values.yaml#L717">zookeeper.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>Zookeeper readiness probe settings.</td>
        </tr>
        <tr>
            <td id="zookeeper--customLivenessProbe"><a href="./values.yaml#L721">zookeeper.customLivenessProbe</a></td>
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
            <td>Custom liveness probe for Zookeeper.</td>
        </tr>
        <tr>
            <td id="zookeeper--customReadinessProbe"><a href="./values.yaml#L731">zookeeper.customReadinessProbe</a></td>
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
            <td>Custom readiness probe for Zookeeper.</td>
        </tr>
        <tr>
            <td id="zookeeper--minServerId"><a href="./values.yaml#L745">zookeeper.minServerId</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Minimal SERVER_ID value, nodes increment their IDs respectively. Servers increment their ID starting at this minimal value. Eg. with `minServerId=10` and 3 replicas, server IDs will be 10, 11, 12 for z-0, z-1 and z-2 respectively.</td>
        </tr>
        <tr>
            <td id="zookeeper--replicaCount"><a href="./values.yaml#L749">zookeeper.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Replica count for zookeeper</td>
        </tr>
        <tr>
            <td id="zookeeper--pdb"><a href="./values.yaml#L754">zookeeper.pdb</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">create: false</pre>
</div>
            </td>
            <td>ZooKeeper Pod Disruption Budget Ref: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/</td>
        </tr>
        <tr>
            <td id="zookeeper--pdb--create"><a href="./values.yaml#L757">zookeeper.pdb.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Specifies whether a Pod Disruption Budget should be created</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence"><a href="./values.yaml#L763">zookeeper.persistence</a></td>
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
            <td>Enable persistence using Persistent Volume Claims  Ref: https://kubernetes.io/docs/user-guide/persistent-volumes/</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--enabled"><a href="./values.yaml#L766">zookeeper.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable ZooKeeper data persistence using PVC. If false, use emptyDir</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--existingClaim"><a href="./values.yaml#L770">zookeeper.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of an existing PVC to use (only when deploying a single replica)</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--storageClass"><a href="./values.yaml#L779">zookeeper.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>PVC Storage Class for ZooKeeper data volume If defined, storageClassName: <storageClass> If set to "-", storageClassName: "", which disables dynamic provisioning If undefined (the default) or set to null, no storageClassName spec is   set, choosing the default provisioner.  (gp2 on AWS, standard on   GKE, AWS & OpenStack)</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--accessModes"><a href="./values.yaml#L783">zookeeper.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>PVC Access modes</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--size"><a href="./values.yaml#L788">zookeeper.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8Gi</pre>
</div>
            </td>
            <td>PVC Storage Request for ZooKeeper data volume</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--annotations"><a href="./values.yaml#L792">zookeeper.persistence.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the PVC</td>
        </tr>
        <tr>
            <td id="zookeeper--resources"><a href="./values.yaml#L796">zookeeper.resources</a></td>
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
            <td id="externalClickhouse"><a href="./values.yaml#L1660">externalClickhouse</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster: cluster
database: signoz_metrics
existingSecret: null
existingSecretPasswordKey: null
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
            <td id="externalClickhouse--host"><a href="./values.yaml#L1664">externalClickhouse.host</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Host of the external ClickHouse cluster.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--cluster"><a href="./values.yaml#L1668">externalClickhouse.cluster</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster</pre>
</div>
            </td>
            <td>Name of the external cluster to run DDL queries on.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--database"><a href="./values.yaml#L1672">externalClickhouse.database</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_metrics</pre>
</div>
            </td>
            <td>Database name for the external cluster.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--traceDatabase"><a href="./values.yaml#L1676">externalClickhouse.traceDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_traces</pre>
</div>
            </td>
            <td>Database name for SigNoz Traces on the external cluster.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--logDatabase"><a href="./values.yaml#L1680">externalClickhouse.logDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_logs</pre>
</div>
            </td>
            <td>Database name for SigNoz Logs on the external cluster.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--meterDatabase"><a href="./values.yaml#L1684">externalClickhouse.meterDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_meter</pre>
</div>
            </td>
            <td>Database name for SigNoz Meter on the external cluster.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--user"><a href="./values.yaml#L1688">externalClickhouse.user</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Username to connect to the external cluster.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--password"><a href="./values.yaml#L1692">externalClickhouse.password</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Password for the external cluster. Ignored if `externalClickhouse.existingSecret` is set.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--existingSecret"><a href="./values.yaml#L1696">externalClickhouse.existingSecret</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of an existing Kubernetes secret containing the password.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--existingSecretPasswordKey"><a href="./values.yaml#L1700">externalClickhouse.existingSecretPasswordKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Key in the existing secret that contains the password.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--secure"><a href="./values.yaml#L1704">externalClickhouse.secure</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to use a TLS connection when connecting to ClickHouse.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--verify"><a href="./values.yaml#L1708">externalClickhouse.verify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to verify the TLS certificate on connection to ClickHouse.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--httpPort"><a href="./values.yaml#L1712">externalClickhouse.httpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8123</pre>
</div>
            </td>
            <td>HTTP port of the external ClickHouse instance.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--tcpPort"><a href="./values.yaml#L1716">externalClickhouse.tcpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">9000</pre>
</div>
            </td>
            <td>TCP port of the external ClickHouse instance.</td>
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
            <td id="telemetryStoreMigrator"><a href="./values.yaml#L1720">telemetryStoreMigrator</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Default values for the Telemetry Store Migrator.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--enabled"><a href="./values.yaml#L1724">telemetryStoreMigrator.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Telemetry Store Migrator component.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--name"><a href="./values.yaml#L1728">telemetryStoreMigrator.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz-telemetrystore-migrator</pre>
</div>
            </td>
            <td>The name of the Telemetry Store Migrator component.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--upgradeHelmHooks"><a href="./values.yaml#L1732">telemetryStoreMigrator.upgradeHelmHooks</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable Helm pre-upgrade hooks and ArgoCD Sync hooks.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--serviceAccount"><a href="./values.yaml#L1735">telemetryStoreMigrator.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
create: true
name: null</pre>
</div>
            </td>
            <td>Service Account configuration for the Telemetry Store Migrator.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--serviceAccount--create"><a href="./values.yaml#L1739">telemetryStoreMigrator.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a service account should be created.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--serviceAccount--annotations"><a href="./values.yaml#L1743">telemetryStoreMigrator.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the service account.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--serviceAccount--name"><a href="./values.yaml#L1747">telemetryStoreMigrator.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>The name of the service account to use. If not set and `create` is true, a name is generated.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--annotations"><a href="./values.yaml#L1751">telemetryStoreMigrator.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the Telemetry Store Migrator job.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--enableReplication"><a href="./values.yaml#L1755">telemetryStoreMigrator.enableReplication</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to enable replication for the Telemetry Store Migrator.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--timeout"><a href="./values.yaml#L1759">telemetryStoreMigrator.timeout</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10m</pre>
</div>
            </td>
            <td>Timeout for the migration.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--resources"><a href="./values.yaml#L1763">telemetryStoreMigrator.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resource requests and limits for all migrator containers.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--nodeSelector"><a href="./values.yaml#L1767">telemetryStoreMigrator.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--tolerations"><a href="./values.yaml#L1771">telemetryStoreMigrator.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--affinity"><a href="./values.yaml#L1775">telemetryStoreMigrator.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--topologySpreadConstraints"><a href="./values.yaml#L1779">telemetryStoreMigrator.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
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
            <td id="signoz"><a href="./values.yaml#L1783">signoz</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Default values for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--name"><a href="./values.yaml#L1787">signoz.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz</pre>
</div>
            </td>
            <td>The name of the SigNoz component.</td>
        </tr>
        <tr>
            <td id="signoz--image"><a href="./values.yaml#L1790">signoz.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">pullPolicy: IfNotPresent
registry: docker.io
repository: signoz/signoz
tag: v0.149.0</pre>
</div>
            </td>
            <td>Image configuration for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--image--registry"><a href="./values.yaml#L1794">signoz.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">docker.io</pre>
</div>
            </td>
            <td>The container image registry.</td>
        </tr>
        <tr>
            <td id="signoz--image--repository"><a href="./values.yaml#L1798">signoz.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/signoz</pre>
</div>
            </td>
            <td>The container image repository.</td>
        </tr>
        <tr>
            <td id="signoz--image--tag"><a href="./values.yaml#L1801">signoz.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v0.149.0</pre>
</div>
            </td>
            <td>The container image tag.</td>
        </tr>
        <tr>
            <td id="signoz--image--pullPolicy"><a href="./values.yaml#L1805">signoz.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>The image pull policy.</td>
        </tr>
        <tr>
            <td id="signoz--imagePullSecrets"><a href="./values.yaml#L1810">signoz.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for SigNoz. This has higher precedence than the root level or global value.</td>
        </tr>
        <tr>
            <td id="signoz--replicaCount"><a href="./values.yaml#L1814">signoz.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>The number of pod replicas for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--serviceAccount"><a href="./values.yaml#L1817">signoz.serviceAccount</a></td>
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
            <td id="signoz--serviceAccount--create"><a href="./values.yaml#L1821">signoz.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a service account should be created.</td>
        </tr>
        <tr>
            <td id="signoz--serviceAccount--annotations"><a href="./values.yaml#L1825">signoz.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the service account.</td>
        </tr>
        <tr>
            <td id="signoz--serviceAccount--name"><a href="./values.yaml#L1829">signoz.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>The name of the service account to use. If not set and `create` is true, a name is generated.</td>
        </tr>
        <tr>
            <td id="signoz--annotations"><a href="./values.yaml#L1833">signoz.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--podAnnotations"><a href="./values.yaml#L1837">signoz.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--service"><a href="./values.yaml#L1841">signoz.service</a></td>
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
            <td id="signoz--service--annotations"><a href="./values.yaml#L1845">signoz.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the SigNoz service object.</td>
        </tr>
        <tr>
            <td id="signoz--service--labels"><a href="./values.yaml#L1849">signoz.service.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels for the SigNoz service object.</td>
        </tr>
        <tr>
            <td id="signoz--service--type"><a href="./values.yaml#L1853">signoz.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>The service type (`ClusterIP`, `NodePort`, `LoadBalancer`).</td>
        </tr>
        <tr>
            <td id="signoz--service--port"><a href="./values.yaml#L1857">signoz.service.port</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8080</pre>
</div>
            </td>
            <td>The external HTTP port for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--service--internalPort"><a href="./values.yaml#L1861">signoz.service.internalPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8085</pre>
</div>
            </td>
            <td>The internal gRPC port for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--service--opampPort"><a href="./values.yaml#L1865">signoz.service.opampPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">4320</pre>
</div>
            </td>
            <td>The internal OpAMP port for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--service--nodePort"><a href="./values.yaml#L1869">signoz.service.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Manually specify the nodePort for HTTP when `service.type` is `NodePort`.</td>
        </tr>
        <tr>
            <td id="signoz--service--internalNodePort"><a href="./values.yaml#L1873">signoz.service.internalNodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Manually specify the nodePort for the internal port when `service.type` is `NodePort`.</td>
        </tr>
        <tr>
            <td id="signoz--service--opampInternalNodePort"><a href="./values.yaml#L1877">signoz.service.opampInternalNodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Manually specify the nodePort for OpAMP when `service.type` is `NodePort`.</td>
        </tr>
        <tr>
            <td id="signoz--ingress"><a href="./values.yaml#L1880">signoz.ingress</a></td>
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
        <tr>
            <td id="signoz--ingress--enabled"><a href="./values.yaml#L1884">signoz.ingress.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable ingress controller resource.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--className"><a href="./values.yaml#L1888">signoz.ingress.className</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Ingress class name.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--annotations"><a href="./values.yaml#L1892">signoz.ingress.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ingress resource.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--hosts"><a href="./values.yaml#L1898">signoz.ingress.hosts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- host: signoz.domain.com
  paths:
    - path: /
      pathType: ImplementationSpecific
      port: 8080</pre>
</div>
            </td>
            <td>Hostname and path configurations for the ingress.</td>
        </tr>
        <tr>
            <td id="signoz--ingress--tls"><a href="./values.yaml#L1907">signoz.ingress.tls</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>TLS configuration for the ingress.</td>
        </tr>
        <tr>
            <td id="signoz--additionalArgs"><a href="./values.yaml#L1914">signoz.additionalArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional command-line arguments for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--env"><a href="./values.yaml#L1938">signoz.env</a></td>
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
            <td id="signoz--livenessProbe"><a href="./values.yaml#L1955">signoz.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Liveness probe configuration.</td>
        </tr>
        <tr>
            <td id="signoz--readinessProbe"><a href="./values.yaml#L1967">signoz.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Readiness probe configuration.</td>
        </tr>
        <tr>
            <td id="signoz--customLivenessProbe"><a href="./values.yaml#L1979">signoz.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom liveness probe to override the default.</td>
        </tr>
        <tr>
            <td id="signoz--customReadinessProbe"><a href="./values.yaml#L1983">signoz.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom readiness probe to override the default.</td>
        </tr>
        <tr>
            <td id="signoz--resources"><a href="./values.yaml#L1987">signoz.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">requests:
    cpu: 100m
    memory: 100Mi</pre>
</div>
            </td>
            <td>Resource requests and limits. Ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
        </tr>
        <tr>
            <td id="signoz--podSecurityContext"><a href="./values.yaml#L1998">signoz.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Pod-level security context.</td>
        </tr>
        <tr>
            <td id="signoz--securityContext"><a href="./values.yaml#L2004">signoz.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Container-level security context.</td>
        </tr>
        <tr>
            <td id="signoz--priorityClassName"><a href="./values.yaml#L2015">signoz.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class for the SigNoz pods.</td>
        </tr>
        <tr>
            <td id="signoz--nodeSelector"><a href="./values.yaml#L2019">signoz.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--tolerations"><a href="./values.yaml#L2023">signoz.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--affinity"><a href="./values.yaml#L2027">signoz.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--topologySpreadConstraints"><a href="./values.yaml#L2031">signoz.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="signoz--persistence"><a href="./values.yaml#L2034">signoz.persistence</a></td>
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
        <tr>
            <td id="signoz--persistence--enabled"><a href="./values.yaml#L2038">signoz.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable data persistence using a PVC.</td>
        </tr>
        <tr>
            <td id="signoz--persistence--existingClaim"><a href="./values.yaml#L2042">signoz.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Use a manually managed PVC.</td>
        </tr>
        <tr>
            <td id="signoz--persistence--storageClass"><a href="./values.yaml#L2046">signoz.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>The storage class for the PVC. If "-", disables dynamic provisioning.</td>
        </tr>
        <tr>
            <td id="signoz--persistence--accessModes"><a href="./values.yaml#L2050">signoz.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access modes for the persistent volume.</td>
        </tr>
        <tr>
            <td id="signoz--persistence--size"><a href="./values.yaml#L2055">signoz.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1Gi</pre>
</div>
            </td>
            <td>The size of the persistent volume.</td>
        </tr>
        <tr>
            <td id="signoz--additionalVolumes"><a href="./values.yaml#L2059">signoz.additionalVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volumes for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--additionalVolumeMounts"><a href="./values.yaml#L2063">signoz.additionalVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volume mounts for the SigNoz container.</td>
        </tr>
    </tbody>
</table>
<h3>OTel Collector</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="otelCollector"><a href="./values.yaml#L2068">otelCollector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Default values for the OpenTelemetry Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--name"><a href="./values.yaml#L2072">otelCollector.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">otel-collector</pre>
</div>
            </td>
            <td>The name of the Otel Collector component.</td>
        </tr>
        <tr>
            <td id="otelCollector--image"><a href="./values.yaml#L2075">otelCollector.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">pullPolicy: IfNotPresent
registry: docker.io
repository: signoz/signoz-otel-collector
tag: v0.144.15</pre>
</div>
            </td>
            <td>Image configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--image--registry"><a href="./values.yaml#L2079">otelCollector.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">docker.io</pre>
</div>
            </td>
            <td>The container image registry.</td>
        </tr>
        <tr>
            <td id="otelCollector--image--repository"><a href="./values.yaml#L2083">otelCollector.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/signoz-otel-collector</pre>
</div>
            </td>
            <td>The container image repository.</td>
        </tr>
        <tr>
            <td id="otelCollector--image--tag"><a href="./values.yaml#L2086">otelCollector.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v0.144.15</pre>
</div>
            </td>
            <td>The container image tag.</td>
        </tr>
        <tr>
            <td id="otelCollector--image--pullPolicy"><a href="./values.yaml#L2090">otelCollector.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>The image pull policy.</td>
        </tr>
        <tr>
            <td id="otelCollector--imagePullSecrets"><a href="./values.yaml#L2095">otelCollector.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for the Otel Collector. This has higher precedence than the root level or global value.</td>
        </tr>
        <tr>
            <td id="otelCollector--replicaCount"><a href="./values.yaml#L2099">otelCollector.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>The number of pod replicas for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--strategy"><a href="./values.yaml#L2103">otelCollector.strategy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">RollingUpdate</pre>
</div>
            </td>
            <td>Deployment strategy to use</td>
        </tr>
        <tr>
            <td id="otelCollector--minReadySeconds"><a href="./values.yaml#L2107">otelCollector.minReadySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Minimum number of seconds for a new pod to be ready.</td>
        </tr>
        <tr>
            <td id="otelCollector--progressDeadlineSeconds"><a href="./values.yaml#L2111">otelCollector.progressDeadlineSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">600</pre>
</div>
            </td>
            <td>Maximum time in seconds for a deployment to make progress before it is considered failed.</td>
        </tr>
        <tr>
            <td id="otelCollector--serviceAccount"><a href="./values.yaml#L2114">otelCollector.serviceAccount</a></td>
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
            <td id="otelCollector--serviceAccount--create"><a href="./values.yaml#L2118">otelCollector.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a service account should be created.</td>
        </tr>
        <tr>
            <td id="otelCollector--serviceAccount--annotations"><a href="./values.yaml#L2122">otelCollector.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the service account.</td>
        </tr>
        <tr>
            <td id="otelCollector--serviceAccount--name"><a href="./values.yaml#L2126">otelCollector.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>The name of the service account to use. If not set and `create` is true, a name is generated.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole"><a href="./values.yaml#L2130">otelCollector.clusterRole</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>RBAC ClusterRole configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--create"><a href="./values.yaml#L2134">otelCollector.clusterRole.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a ClusterRole should be created.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--annotations"><a href="./values.yaml#L2138">otelCollector.clusterRole.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ClusterRole.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--name"><a href="./values.yaml#L2142">otelCollector.clusterRole.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>The name of the ClusterRole to use. If not set, a name is generated.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--rules"><a href="./values.yaml#L2147">otelCollector.clusterRole.rules</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>A set of RBAC rules. Required for the k8sattributes processor. ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--clusterRoleBinding"><a href="./values.yaml#L2162">otelCollector.clusterRole.clusterRoleBinding</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
name: ""</pre>
</div>
            </td>
            <td>ClusterRoleBinding configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--clusterRoleBinding--annotations"><a href="./values.yaml#L2166">otelCollector.clusterRole.clusterRoleBinding.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the ClusterRoleBinding.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole--clusterRoleBinding--name"><a href="./values.yaml#L2170">otelCollector.clusterRole.clusterRoleBinding.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>The name of the ClusterRoleBinding to use. If not set, a name is generated.</td>
        </tr>
        <tr>
            <td id="otelCollector--annotations"><a href="./values.yaml#L2174">otelCollector.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the Otel Collector Deployment.</td>
        </tr>
        <tr>
            <td id="otelCollector--podLabels"><a href="./values.yaml#L2178">otelCollector.podLabels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels for the Otel Collector pod(s).</td>
        </tr>
        <tr>
            <td id="otelCollector--podAnnotations"><a href="./values.yaml#L2181">otelCollector.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io/port: "8888"
signoz.io/scrape: "true"</pre>
</div>
            </td>
            <td>Annotations for the Otel Collector pod(s).</td>
        </tr>
        <tr>
            <td id="otelCollector--service"><a href="./values.yaml#L2186">otelCollector.service</a></td>
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
            <td id="otelCollector--service--annotations"><a href="./values.yaml#L2190">otelCollector.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the Otel Collector service object.</td>
        </tr>
        <tr>
            <td id="otelCollector--service--labels"><a href="./values.yaml#L2194">otelCollector.service.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels for the Otel Collector service object.</td>
        </tr>
        <tr>
            <td id="otelCollector--service--type"><a href="./values.yaml#L2198">otelCollector.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>The service type (`ClusterIP`, `NodePort`, `LoadBalancer`).</td>
        </tr>
        <tr>
            <td id="otelCollector--service--loadBalancerSourceRanges"><a href="./values.yaml#L2202">otelCollector.service.loadBalancerSourceRanges</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Allowed source ranges when service type is `LoadBalancer`.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports"><a href="./values.yaml#L2206">otelCollector.ports</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Port configurations for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp"><a href="./values.yaml#L2209">otelCollector.ports.otlp</a></td>
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
            <td id="otelCollector--ports--otlp--enabled"><a href="./values.yaml#L2213">otelCollector.ports.otlp.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to enable the service port for OTLP gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp--containerPort"><a href="./values.yaml#L2217">otelCollector.ports.otlp.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">4317</pre>
</div>
            </td>
            <td>Container port for OTLP gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp--servicePort"><a href="./values.yaml#L2221">otelCollector.ports.otlp.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">4317</pre>
</div>
            </td>
            <td>Service port for OTLP gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp--nodePort"><a href="./values.yaml#L2225">otelCollector.ports.otlp.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Node port for OTLP gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp--protocol"><a href="./values.yaml#L2229">otelCollector.ports.otlp.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for OTLP gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp-http"><a href="./values.yaml#L2232">otelCollector.ports.otlp-http</a></td>
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
            <td id="otelCollector--ports--otlp-http--enabled"><a href="./values.yaml#L2236">otelCollector.ports.otlp-http.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to enable the service port for OTLP HTTP.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp-http--containerPort"><a href="./values.yaml#L2240">otelCollector.ports.otlp-http.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">4318</pre>
</div>
            </td>
            <td>Container port for OTLP HTTP.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp-http--servicePort"><a href="./values.yaml#L2244">otelCollector.ports.otlp-http.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">4318</pre>
</div>
            </td>
            <td>Service port for OTLP HTTP.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp-http--nodePort"><a href="./values.yaml#L2248">otelCollector.ports.otlp-http.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Node port for OTLP HTTP.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp-http--protocol"><a href="./values.yaml#L2252">otelCollector.ports.otlp-http.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for OTLP HTTP.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-compact"><a href="./values.yaml#L2255">otelCollector.ports.jaeger-compact</a></td>
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
            <td id="otelCollector--ports--jaeger-compact--enabled"><a href="./values.yaml#L2259">otelCollector.ports.jaeger-compact.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable the service port for Jaeger Compact.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-compact--containerPort"><a href="./values.yaml#L2263">otelCollector.ports.jaeger-compact.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">6831</pre>
</div>
            </td>
            <td>Container port for Jaeger Compact.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-compact--servicePort"><a href="./values.yaml#L2267">otelCollector.ports.jaeger-compact.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">6831</pre>
</div>
            </td>
            <td>Service port for Jaeger Compact.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-compact--nodePort"><a href="./values.yaml#L2271">otelCollector.ports.jaeger-compact.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Node port for Jaeger Compact.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-compact--protocol"><a href="./values.yaml#L2275">otelCollector.ports.jaeger-compact.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">UDP</pre>
</div>
            </td>
            <td>Protocol for Jaeger Compact.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-thrift"><a href="./values.yaml#L2278">otelCollector.ports.jaeger-thrift</a></td>
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
            <td id="otelCollector--ports--jaeger-thrift--enabled"><a href="./values.yaml#L2282">otelCollector.ports.jaeger-thrift.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to enable the service port for Jaeger Thrift HTTP.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-thrift--containerPort"><a href="./values.yaml#L2286">otelCollector.ports.jaeger-thrift.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">14268</pre>
</div>
            </td>
            <td>Container port for Jaeger Thrift.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-thrift--servicePort"><a href="./values.yaml#L2290">otelCollector.ports.jaeger-thrift.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">14268</pre>
</div>
            </td>
            <td>Service port for Jaeger Thrift.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-thrift--nodePort"><a href="./values.yaml#L2294">otelCollector.ports.jaeger-thrift.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Node port for Jaeger Thrift.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-thrift--protocol"><a href="./values.yaml#L2298">otelCollector.ports.jaeger-thrift.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for Jaeger Thrift.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-grpc"><a href="./values.yaml#L2301">otelCollector.ports.jaeger-grpc</a></td>
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
            <td id="otelCollector--ports--jaeger-grpc--enabled"><a href="./values.yaml#L2305">otelCollector.ports.jaeger-grpc.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to enable the service port for Jaeger gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-grpc--containerPort"><a href="./values.yaml#L2309">otelCollector.ports.jaeger-grpc.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">14250</pre>
</div>
            </td>
            <td>Container port for Jaeger gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-grpc--servicePort"><a href="./values.yaml#L2313">otelCollector.ports.jaeger-grpc.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">14250</pre>
</div>
            </td>
            <td>Service port for Jaeger gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-grpc--nodePort"><a href="./values.yaml#L2317">otelCollector.ports.jaeger-grpc.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Node port for Jaeger gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--jaeger-grpc--protocol"><a href="./values.yaml#L2321">otelCollector.ports.jaeger-grpc.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for Jaeger gRPC.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zipkin"><a href="./values.yaml#L2324">otelCollector.ports.zipkin</a></td>
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
            <td id="otelCollector--ports--zipkin--enabled"><a href="./values.yaml#L2328">otelCollector.ports.zipkin.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable the service port for Zipkin.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zipkin--containerPort"><a href="./values.yaml#L2332">otelCollector.ports.zipkin.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">9411</pre>
</div>
            </td>
            <td>Container port for Zipkin.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zipkin--servicePort"><a href="./values.yaml#L2336">otelCollector.ports.zipkin.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">9411</pre>
</div>
            </td>
            <td>Service port for Zipkin.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zipkin--nodePort"><a href="./values.yaml#L2340">otelCollector.ports.zipkin.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Node port for Zipkin.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zipkin--protocol"><a href="./values.yaml#L2344">otelCollector.ports.zipkin.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for Zipkin.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--metrics"><a href="./values.yaml#L2347">otelCollector.ports.metrics</a></td>
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
            <td id="otelCollector--ports--metrics--enabled"><a href="./values.yaml#L2351">otelCollector.ports.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to enable the service port for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--metrics--containerPort"><a href="./values.yaml#L2355">otelCollector.ports.metrics.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8888</pre>
</div>
            </td>
            <td>Container port for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--metrics--servicePort"><a href="./values.yaml#L2359">otelCollector.ports.metrics.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8888</pre>
</div>
            </td>
            <td>Service port for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--metrics--nodePort"><a href="./values.yaml#L2363">otelCollector.ports.metrics.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Node port for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--metrics--protocol"><a href="./values.yaml#L2367">otelCollector.ports.metrics.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zpages"><a href="./values.yaml#L2370">otelCollector.ports.zpages</a></td>
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
            <td id="otelCollector--ports--zpages--enabled"><a href="./values.yaml#L2374">otelCollector.ports.zpages.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable the service port for ZPages.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zpages--containerPort"><a href="./values.yaml#L2378">otelCollector.ports.zpages.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">55679</pre>
</div>
            </td>
            <td>Container port for ZPages.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zpages--servicePort"><a href="./values.yaml#L2382">otelCollector.ports.zpages.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">55679</pre>
</div>
            </td>
            <td>Service port for ZPages.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zpages--nodePort"><a href="./values.yaml#L2386">otelCollector.ports.zpages.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Node port for ZPages.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--zpages--protocol"><a href="./values.yaml#L2390">otelCollector.ports.zpages.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for ZPages.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--pprof"><a href="./values.yaml#L2393">otelCollector.ports.pprof</a></td>
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
            <td id="otelCollector--ports--pprof--enabled"><a href="./values.yaml#L2397">otelCollector.ports.pprof.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable the service port for pprof.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--pprof--containerPort"><a href="./values.yaml#L2401">otelCollector.ports.pprof.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1777</pre>
</div>
            </td>
            <td>Container port for pprof.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--pprof--servicePort"><a href="./values.yaml#L2405">otelCollector.ports.pprof.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1777</pre>
</div>
            </td>
            <td>Service port for pprof.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--pprof--nodePort"><a href="./values.yaml#L2409">otelCollector.ports.pprof.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Node port for pprof.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--pprof--protocol"><a href="./values.yaml#L2413">otelCollector.ports.pprof.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for pprof.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsheroku"><a href="./values.yaml#L2416">otelCollector.ports.logsheroku</a></td>
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
            <td id="otelCollector--ports--logsheroku--enabled"><a href="./values.yaml#L2420">otelCollector.ports.logsheroku.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to enable the service port for Heroku logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsheroku--containerPort"><a href="./values.yaml#L2424">otelCollector.ports.logsheroku.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8081</pre>
</div>
            </td>
            <td>Container port for Heroku logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsheroku--servicePort"><a href="./values.yaml#L2428">otelCollector.ports.logsheroku.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8081</pre>
</div>
            </td>
            <td>Service port for Heroku logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsheroku--nodePort"><a href="./values.yaml#L2432">otelCollector.ports.logsheroku.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Node port for Heroku logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsheroku--protocol"><a href="./values.yaml#L2436">otelCollector.ports.logsheroku.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for Heroku logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsjson"><a href="./values.yaml#L2439">otelCollector.ports.logsjson</a></td>
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
        <tr>
            <td id="otelCollector--ports--logsjson--enabled"><a href="./values.yaml#L2443">otelCollector.ports.logsjson.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to enable the service port for JSON logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsjson--containerPort"><a href="./values.yaml#L2447">otelCollector.ports.logsjson.containerPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8082</pre>
</div>
            </td>
            <td>Container port for JSON logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsjson--servicePort"><a href="./values.yaml#L2451">otelCollector.ports.logsjson.servicePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8082</pre>
</div>
            </td>
            <td>Service port for JSON logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsjson--nodePort"><a href="./values.yaml#L2455">otelCollector.ports.logsjson.nodePort</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Node port for JSON logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--logsjson--protocol"><a href="./values.yaml#L2459">otelCollector.ports.logsjson.protocol</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">TCP</pre>
</div>
            </td>
            <td>Protocol for JSON logs.</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress"><a href="./values.yaml#L2462">otelCollector.ingress</a></td>
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
            <td id="otelCollector--ingress--enabled"><a href="./values.yaml#L2466">otelCollector.ingress.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable ingress controller resource.</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress--className"><a href="./values.yaml#L2470">otelCollector.ingress.className</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Ingress class name.</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress--annotations"><a href="./values.yaml#L2474">otelCollector.ingress.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ingress resource.</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress--hosts"><a href="./values.yaml#L2482">otelCollector.ingress.hosts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- host: otelcollector.domain.com
  paths:
    - path: /
      pathType: ImplementationSpecific
      port: 4318</pre>
</div>
            </td>
            <td>Hostname and path configurations for the ingress.</td>
        </tr>
        <tr>
            <td id="otelCollector--ingress--tls"><a href="./values.yaml#L2491">otelCollector.ingress.tls</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>TLS configuration for the ingress.</td>
        </tr>
        <tr>
            <td id="otelCollector--command"><a href="./values.yaml#L2497">otelCollector.command</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">extraArgs: null
name: /signoz-otel-collector</pre>
</div>
            </td>
            <td>Configuration for the Otel Collector executable.</td>
        </tr>
        <tr>
            <td id="otelCollector--command--name"><a href="./values.yaml#L2501">otelCollector.command.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">/signoz-otel-collector</pre>
</div>
            </td>
            <td>Otel Collector command name.</td>
        </tr>
        <tr>
            <td id="otelCollector--command--extraArgs"><a href="./values.yaml#L2504">otelCollector.command.extraArgs</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Extra command-line arguments for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--configMap"><a href="./values.yaml#L2507">otelCollector.configMap</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">create: true</pre>
</div>
            </td>
            <td>ConfigMap settings.</td>
        </tr>
        <tr>
            <td id="otelCollector--configMap--create"><a href="./values.yaml#L2511">otelCollector.configMap.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a ConfigMap should be created.</td>
        </tr>
        <tr>
            <td id="otelCollector--config"><a href="./values.yaml#L2515">otelCollector.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Main configuration for the OpenTelemetry Collector pipelines.</td>
        </tr>
        <tr>
            <td id="otelCollector--lowCardinalityExceptionGrouping"><a href="./values.yaml#L2654">otelCollector.lowCardinalityExceptionGrouping</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable grouping of exceptions with the same name but different stack traces. This is a tradeoff between cardinality and accuracy.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling"><a href="./values.yaml#L2658">otelCollector.autoscaling</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Autoscaling configuration (HPA).</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--enabled"><a href="./values.yaml#L2662">otelCollector.autoscaling.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable Horizontal Pod Autoscaler.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--minReplicas"><a href="./values.yaml#L2666">otelCollector.autoscaling.minReplicas</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Minimum number of replicas.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--maxReplicas"><a href="./values.yaml#L2670">otelCollector.autoscaling.maxReplicas</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">11</pre>
</div>
            </td>
            <td>Maximum number of replicas.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--targetCPUUtilizationPercentage"><a href="./values.yaml#L2674">otelCollector.autoscaling.targetCPUUtilizationPercentage</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">50</pre>
</div>
            </td>
            <td>Target CPU utilization percentage.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--targetMemoryUtilizationPercentage"><a href="./values.yaml#L2678">otelCollector.autoscaling.targetMemoryUtilizationPercentage</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">50</pre>
</div>
            </td>
            <td>Target memory utilization percentage.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--behavior"><a href="./values.yaml#L2682">otelCollector.autoscaling.behavior</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Scaling behavior policies.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--autoscalingTemplate"><a href="./values.yaml#L2699">otelCollector.autoscaling.autoscalingTemplate</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Template for autoscaling.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda"><a href="./values.yaml#L2702">otelCollector.autoscaling.keda</a></td>
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
        <tr>
            <td id="otelCollector--autoscaling--keda--annotations"><a href="./values.yaml#L2706">otelCollector.autoscaling.keda.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the KEDA ScaledObject.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--enabled"><a href="./values.yaml#L2710">otelCollector.autoscaling.keda.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable KEDA autoscaling.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--pollingInterval"><a href="./values.yaml#L2714">otelCollector.autoscaling.keda.pollingInterval</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"30"</pre>
</div>
            </td>
            <td>Polling interval for metrics data (in seconds).</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--cooldownPeriod"><a href="./values.yaml#L2718">otelCollector.autoscaling.keda.cooldownPeriod</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"300"</pre>
</div>
            </td>
            <td>Cooldown period before downscaling (in seconds).</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--minReplicaCount"><a href="./values.yaml#L2722">otelCollector.autoscaling.keda.minReplicaCount</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"1"</pre>
</div>
            </td>
            <td>Minimum replica count for KEDA.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--maxReplicaCount"><a href="./values.yaml#L2726">otelCollector.autoscaling.keda.maxReplicaCount</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"5"</pre>
</div>
            </td>
            <td>Maximum replica count for KEDA.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda--triggers"><a href="./values.yaml#L2730">otelCollector.autoscaling.keda.triggers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>KEDA trigger configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--additionalEnvs"><a href="./values.yaml#L2734">otelCollector.additionalEnvs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional environment variables for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--livenessProbe"><a href="./values.yaml#L2741">otelCollector.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Liveness probe configuration. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes</td>
        </tr>
        <tr>
            <td id="otelCollector--readinessProbe"><a href="./values.yaml#L2753">otelCollector.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Readiness probe configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--customLivenessProbe"><a href="./values.yaml#L2765">otelCollector.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom liveness probe to override the default.</td>
        </tr>
        <tr>
            <td id="otelCollector--customReadinessProbe"><a href="./values.yaml#L2769">otelCollector.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom readiness probe to override the default.</td>
        </tr>
        <tr>
            <td id="otelCollector--resources"><a href="./values.yaml#L2773">otelCollector.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">requests:
    cpu: 100m
    memory: 200Mi</pre>
</div>
            </td>
            <td>Resource requests and limits. Ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
        </tr>
        <tr>
            <td id="otelCollector--podSecurityContext"><a href="./values.yaml#L2784">otelCollector.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Pod-level security context.</td>
        </tr>
        <tr>
            <td id="otelCollector--securityContext"><a href="./values.yaml#L2790">otelCollector.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Container-level security context.</td>
        </tr>
        <tr>
            <td id="otelCollector--priorityClassName"><a href="./values.yaml#L2801">otelCollector.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class for the Otel Collector pods.</td>
        </tr>
        <tr>
            <td id="otelCollector--nodeSelector"><a href="./values.yaml#L2805">otelCollector.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--tolerations"><a href="./values.yaml#L2809">otelCollector.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--affinity"><a href="./values.yaml#L2813">otelCollector.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--topologySpreadConstraints"><a href="./values.yaml#L2816">otelCollector.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- labelSelector:
    matchLabels:
        app.kubernetes.io/component: otel-collector
  maxSkew: 1
  topologyKey: kubernetes.io/hostname
  whenUnsatisfiable: ScheduleAnyway</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="otelCollector--extraVolumes"><a href="./values.yaml#L2826">otelCollector.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the Otel Collector pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--extraVolumeMounts"><a href="./values.yaml#L2830">otelCollector.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the Otel Collector pod.</td>
        </tr>
    </tbody>
</table>
<h3>PostgreSQL</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="postgresql--enabled"><a href="./values.yaml#L2837">postgresql.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable or disable the PostgreSQL for signoz. For more details, check out the postgresql chart: https://github.com/SigNoz/charts/tree/main/charts/postgresql</td>
        </tr>
    </tbody>
</table>
<h3>OTel Gateway</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="signoz-otel-gateway"><a href="./values.yaml#L2840">signoz-otel-gateway</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false
strategy: ""</pre>
</div>
            </td>
            <td>This component is configurable with licensed version of SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz-otel-gateway--strategy"><a href="./values.yaml#L2847">signoz-otel-gateway.strategy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">RollingUpdate</pre>
</div>
            </td>
            <td>Deployment strategy to use</td>
        </tr>
    </tbody>
</table>
<h3>Redpanda</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="redpanda"><a href="./values.yaml#L3060">redpanda</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>This component is configurable with licensed version of SigNoz.</td>
        </tr>
    </tbody>
</table>

