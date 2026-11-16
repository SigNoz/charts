
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
            <td>ClickHouse settings. The ClickHouseInstallation, its ConfigMaps and ServiceAccount are rendered by this chart; see the keys below.</td>
        </tr>
        <tr>
            <td id="clickhouse--enabled"><a href="./values.yaml#L62">clickhouse.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to install ClickHouse. If false, `externalClickhouse.host` must be set.</td>
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
            <td>The namespace ClickHouse (the ClickHouseInstallation, its ConfigMaps, ServiceAccount and hooks) is installed into. Defaults to the release namespace. When set to another namespace the chart creates it. The operator stays in the release namespace; to make it manage ClickHouse there, either set `altinity-clickhouse-operator.namespaceOverride` to the same value (operator runs next to ClickHouse, as older chart versions did), or set `altinity-clickhouse-operator.watchNamespaces` to a list with that one namespace as a plain name (no regexp, one entry; two entries or a regexp make the operator watch all namespaces) and `altinity-clickhouse-operator.rbac.namespaceScoped: false`. The chart only checks that one of these watch settings (or the watch list in the operator's config file) is set, not its value.</td>
        </tr>
        <tr>
            <td id="clickhouse--image"><a href="./values.yaml#L85">clickhouse.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">pullPolicy: IfNotPresent
repository: clickhouse/clickhouse-server
tag: 25.12.5</pre>
</div>
            </td>
            <td>ClickHouse image configuration.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--repository"><a href="./values.yaml#L89">clickhouse.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">clickhouse/clickhouse-server</pre>
</div>
            </td>
            <td>Image repository. May start with a registry (`registry.k8s.io/kubectl`); `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--tag"><a href="./values.yaml#L94">clickhouse.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">25.12.5</pre>
</div>
            </td>
            <td>ClickHouse image tag to use. SigNoz is not always tested with the latest version of ClickHouse. Only override if you know what you are doing.</td>
        </tr>
        <tr>
            <td id="clickhouse--image--pullPolicy"><a href="./values.yaml#L98">clickhouse.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>ClickHouse image pull policy.</td>
        </tr>
        <tr>
            <td id="clickhouse--imagePullSecrets"><a href="./values.yaml#L102">clickhouse.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image Registry Secret Names for ClickHouse. Merged with `global.imagePullSecrets` if set.</td>
        </tr>
        <tr>
            <td id="clickhouse--layout"><a href="./values.yaml#L108">clickhouse.layout</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">replicasCount: 1
shardsCount: 1</pre>
</div>
            </td>
            <td>ClickHouse cluster layout. (Experimental, use at own risk) For a full list of options, see https://github.com/Altinity/clickhouse-operator/blob/master/docs/custom_resource_explained.md</td>
        </tr>
        <tr>
            <td id="clickhouse--cluster"><a href="./values.yaml#L114">clickhouse.cluster</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster</pre>
</div>
            </td>
            <td>ClickHouse cluster name.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount"><a href="./values.yaml#L117">clickhouse.serviceAccount</a></td>
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
            <td id="clickhouse--serviceAccount--create"><a href="./values.yaml#L121">clickhouse.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a service account should be created.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount--annotations"><a href="./values.yaml#L125">clickhouse.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations to add to the service account.</td>
        </tr>
        <tr>
            <td id="clickhouse--serviceAccount--name"><a href="./values.yaml#L129">clickhouse.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>The name of the service account to use. If not set and create is true, a name is generated.</td>
        </tr>
        <tr>
            <td id="clickhouse--labels"><a href="./values.yaml#L132">clickhouse.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ClickHouse instance labels</td>
        </tr>
        <tr>
            <td id="clickhouse--annotations"><a href="./values.yaml#L136">clickhouse.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ClickHouse instance.</td>
        </tr>
        <tr>
            <td id="clickhouse--podLabels"><a href="./values.yaml#L139">clickhouse.podLabels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ClickHouse pod labels</td>
        </tr>
        <tr>
            <td id="clickhouse--podAnnotations"><a href="./values.yaml#L142">clickhouse.podAnnotations</a></td>
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
            <td id="clickhouse--service"><a href="./values.yaml#L148">clickhouse.service</a></td>
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
            <td id="clickhouse--service--annotations"><a href="./values.yaml#L152">clickhouse.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ClickHouse service.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--type"><a href="./values.yaml#L156">clickhouse.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>Service type. `LoadBalancer` allows external access; `NodePort` is more secure and has no extra cost.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--httpPort"><a href="./values.yaml#L160">clickhouse.service.httpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8123</pre>
</div>
            </td>
            <td>ClickHouse HTTP port.</td>
        </tr>
        <tr>
            <td id="clickhouse--service--tcpPort"><a href="./values.yaml#L164">clickhouse.service.tcpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">9000</pre>
</div>
            </td>
            <td>ClickHouse TCP port.</td>
        </tr>
        <tr>
            <td id="clickhouse--database"><a href="./values.yaml#L168">clickhouse.database</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_metrics</pre>
</div>
            </td>
            <td>ClickHouse Settings for SigNoz Metrics.</td>
        </tr>
        <tr>
            <td id="clickhouse--traceDatabase"><a href="./values.yaml#L172">clickhouse.traceDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_traces</pre>
</div>
            </td>
            <td>ClickHouse Settings for SigNoz Traces.</td>
        </tr>
        <tr>
            <td id="clickhouse--logDatabase"><a href="./values.yaml#L176">clickhouse.logDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_logs</pre>
</div>
            </td>
            <td>ClickHouse Settings for SigNoz Logs.</td>
        </tr>
        <tr>
            <td id="clickhouse--meterDatabase"><a href="./values.yaml#L180">clickhouse.meterDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_meter</pre>
</div>
            </td>
            <td>Clickhouse meter Database (SigNoz Meter)</td>
        </tr>
        <tr>
            <td id="clickhouse--user"><a href="./values.yaml#L184">clickhouse.user</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">admin</pre>
</div>
            </td>
            <td>ClickHouse user.</td>
        </tr>
        <tr>
            <td id="clickhouse--password"><a href="./values.yaml#L189">clickhouse.password</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">27ff0399-0d3a-4bd8-919d-17c2181e6fb9</pre>
</div>
            </td>
            <td>ClickHouse password. Rendered as given, in plain text, into the ClickHouseInstallation and into the `CLICKHOUSE_PASSWORD` env of the components that connect to ClickHouse.</td>
        </tr>
        <tr>
            <td id="clickhouse--secure"><a href="./values.yaml#L193">clickhouse.secure</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to use a TLS connection when connecting to ClickHouse.</td>
        </tr>
        <tr>
            <td id="clickhouse--verify"><a href="./values.yaml#L197">clickhouse.verify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to verify the TLS certificate on connection to ClickHouse.</td>
        </tr>
        <tr>
            <td id="clickhouse--allowedNetworkIps"><a href="./values.yaml#L204">clickhouse.allowedNetworkIps</a></td>
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
            <td id="clickhouse--externalZookeeper"><a href="./values.yaml#L216">clickhouse.externalZookeeper</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Configuration for an external Zookeeper. When set, its `servers` list (one `host` and `port` per entry) is used as the installation's ZooKeeper nodes instead of the bundled ZooKeeper's pods. The bundled ZooKeeper is still installed unless `zookeeper.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--profiles"><a href="./values.yaml#L228">clickhouse.profiles</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ClickHouse user profile configuration. Use this to override profile settings, e.g., `default/max_memory_usage: 40000000000`. For the full list of settings, see: - https://clickhouse.com/docs/en/operations/settings/settings-profiles/ - https://clickhouse.com/docs/en/operations/settings/settings/</td>
        </tr>
        <tr>
            <td id="clickhouse--defaultProfiles"><a href="./values.yaml#L232">clickhouse.defaultProfiles</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Default user profile configuration for ClickHouse. !!! Please DO NOT override this !!!</td>
        </tr>
        <tr>
            <td id="clickhouse--settings"><a href="./values.yaml#L244">clickhouse.settings</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>ClickHouse settings configuration. You can use this to override settings, e.g., `prometheus/port: 9363`. For the full list of settings, see https://clickhouse.com/docs/en/operations/settings/settings/</td>
        </tr>
        <tr>
            <td id="clickhouse--defaultSettings"><a href="./values.yaml#L253">clickhouse.defaultSettings</a></td>
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
            <td id="clickhouse--files"><a href="./values.yaml#L263">clickhouse.files</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>ClickHouse configuration files. Refs: - https://clickhouse.com/docs/en/operations/configuration-files/ - https://github.com/Altinity/clickhouse-operator/blob/master/docs/chi-examples/05-settings-05-files-nested.yaml</td>
        </tr>
        <tr>
            <td id="clickhouse--templates"><a href="./values.yaml#L311">clickhouse.templates</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">volumeClaimTemplates: []</pre>
</div>
            </td>
            <td>Custom volume claim templates for ClickHouse pod This is only used when persistence.enabled is false</td>
        </tr>
        <tr>
            <td id="clickhouse--templates--volumeClaimTemplates"><a href="./values.yaml#L315">clickhouse.templates.volumeClaimTemplates</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Volume claim templates added to the installation when `persistence.enabled` is false; each entry is read for `name`, `accessModes`, `resources.requests.storage` and `storageClassName`.</td>
        </tr>
        <tr>
            <td id="clickhouse--podDistribution"><a href="./values.yaml#L321">clickhouse.podDistribution</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topologies for distributing the ClickHouse pods. Possible values can be found here: https://github.com/Altinity/clickhouse-operator/blob/1414503921da3ae475eb6f9a296d3475a6993768/docs/chi-examples/99-clickhouseinstallation-max.yaml#L428-L481</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage"><a href="./values.yaml#L333">clickhouse.coldStorage</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Cold storage configuration.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--enabled"><a href="./values.yaml#L337">clickhouse.coldStorage.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable S3/GCS cold storage.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--defaultKeepFreeSpaceBytes"><a href="./values.yaml#L341">clickhouse.coldStorage.defaultKeepFreeSpaceBytes</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">"10485760"</pre>
</div>
            </td>
            <td>Reserve free space on the default disk (in bytes).</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--type"><a href="./values.yaml#L345">clickhouse.coldStorage.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">s3</pre>
</div>
            </td>
            <td>Type of cold storage: `s3` or `gcs`.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--endpoint"><a href="./values.yaml#L352">clickhouse.coldStorage.endpoint</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">https://<bucket-name>.s3-<region>.amazonaws.com/data/</pre>
</div>
            </td>
            <td>Endpoint for S3 or GCS. For S3 (us-east-1): https://s3.amazonaws.com For S3 (other regions): https://s3-<region>.amazonaws.com For GCS: https://storage.googleapis.com/<bucket-name>/data/</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--accessKey"><a href="./values.yaml#L357">clickhouse.coldStorage.accessKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml"><access_key_id></pre>
</div>
            </td>
            <td>Access Key ID for S3 or GCS. Used for `gcs`, and for `s3` when `role.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--secretAccess"><a href="./values.yaml#L362">clickhouse.coldStorage.secretAccess</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml"><secret_access_key></pre>
</div>
            </td>
            <td>Secret Access Key for S3 or GCS. Used for `gcs`, and for `s3` when `role.enabled` is false.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--role"><a href="./values.yaml#L365">clickhouse.coldStorage.role</a></td>
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
            <td id="clickhouse--coldStorage--role--enabled"><a href="./values.yaml#L370">clickhouse.coldStorage.role.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable using an AWS IAM ARN role. Used only for `s3`: ClickHouse then takes credentials from the environment instead of `accessKey` and `secretAccess`.</td>
        </tr>
        <tr>
            <td id="clickhouse--coldStorage--role--annotations"><a href="./values.yaml#L374">clickhouse.coldStorage.role.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">eks.amazonaws.com/role-arn: arn:aws:iam::******:role/*****</pre>
</div>
            </td>
            <td>Annotations for the service account to assume the AWS role. Added to the ClickHouse ServiceAccount when `coldStorage.enabled` and `role.enabled` are both true.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs"><a href="./values.yaml#L379">clickhouse.logs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Collection of ClickHouse system table entries as logs, by a `signoz-otel-collector` sidecar in the ClickHouse pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--enabled"><a href="./values.yaml#L383">clickhouse.logs.system.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable collection of system table entries as logs</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--image--repository"><a href="./values.yaml#L388">clickhouse.logs.system.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/signoz-otel-collector</pre>
</div>
            </td>
            <td>Image repository. May start with a registry (`registry.k8s.io/kubectl`); `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--image--tag"><a href="./values.yaml#L392">clickhouse.logs.system.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">0.111.16</pre>
</div>
            </td>
            <td>Tag of the system logs sidecar image.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--image--pullPolicy"><a href="./values.yaml#L396">clickhouse.logs.system.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Pull policy of the system logs sidecar image.</td>
        </tr>
        <tr>
            <td id="clickhouse--logs--system--config"><a href="./values.yaml#L400">clickhouse.logs.system.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Config of the opentelemetry collector</td>
        </tr>
        <tr>
            <td id="clickhouse--installCustomStorageClass"><a href="./values.yaml#L453">clickhouse.installCustomStorageClass</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>When enabled with `cloud` as `gcp` or `aws`, creates a custom storage class with volume expansion permission. The StorageClass (`gp2-resizable` for `aws`, `gce-resizable` for `gcp`) renders only when `clickhouse.enabled` and this key are both true and `global.cloud` starts with `aws` or `gcp`. The chart does not select it for any volume; set `clickhouse.persistence.storageClass` to its name to use it.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook"><a href="./values.yaml#L463">clickhouse.operatorUpgradeHook</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Pre-upgrade hook for installs created before the operator came from Altinity's chart. The old operator Deployment has different selector labels, and a Deployment selector cannot be changed in place, so the hook deletes the old Deployment and Helm then creates the new one under the same name. It selects by the old labels only, so it finds nothing on later upgrades and on fresh installs it never runs (pre-upgrade only). Set `clickhouse.operatorUpgradeHook.enabled` to false to skip it; then delete the old Deployment yourself before upgrading:   kubectl delete deployment <release>-clickhouse-operator -n <namespace></td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--enabled"><a href="./values.yaml#L466">clickhouse.operatorUpgradeHook.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Run the hook on `helm upgrade`.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--repository"><a href="./values.yaml#L470">clickhouse.operatorUpgradeHook.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">registry.k8s.io/kubectl</pre>
</div>
            </td>
            <td>Image repository. May start with a registry (`registry.k8s.io/kubectl`); `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--tag"><a href="./values.yaml#L473">clickhouse.operatorUpgradeHook.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">v1.36.3</pre>
</div>
            </td>
            <td>Tag of the kubectl image. The image publishes no `latest` tag.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--image--pullPolicy"><a href="./values.yaml#L476">clickhouse.operatorUpgradeHook.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Pull policy of the kubectl image.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--backoffLimit"><a href="./values.yaml#L479">clickhouse.operatorUpgradeHook.backoffLimit</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3</pre>
</div>
            </td>
            <td>Retries before the Job, and with it the upgrade, is marked failed.</td>
        </tr>
        <tr>
            <td id="clickhouse--operatorUpgradeHook--resources"><a href="./values.yaml#L482">clickhouse.operatorUpgradeHook.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resources of the hook container.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers"><a href="./values.yaml#L486">clickhouse.initContainers</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Init container to copy the histogramQuantile UDF.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers--enabled"><a href="./values.yaml#L490">clickhouse.initContainers.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Renders the init containers of the ClickHouse pod; when false, neither `udf` nor `init` runs.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers--udf--enabled"><a href="./values.yaml#L495">clickhouse.initContainers.udf.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Adds the init container that downloads the histogramQuantile binary from GitHub into the ClickHouse user scripts volume.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers--udf--image--repository"><a href="./values.yaml#L500">clickhouse.initContainers.udf.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">alpine</pre>
</div>
            </td>
            <td>Image repository. May start with a registry (`registry.k8s.io/kubectl`); `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers--udf--image--tag"><a href="./values.yaml#L504">clickhouse.initContainers.udf.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3.18.2</pre>
</div>
            </td>
            <td>Tag of the `udf` init container image.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers--udf--image--pullPolicy"><a href="./values.yaml#L508">clickhouse.initContainers.udf.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Pull policy of the `udf` init container image.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers--udf--command"><a href="./values.yaml#L512">clickhouse.initContainers.udf.command</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Command of the `udf` init container; by default it downloads the histogramQuantile binary for the node's OS and architecture.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers--init--enabled"><a href="./values.yaml#L531">clickhouse.initContainers.init.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Adds an init container that runs `clickhouse.initContainers.init.command`.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers--init--image--repository"><a href="./values.yaml#L536">clickhouse.initContainers.init.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">busybox</pre>
</div>
            </td>
            <td>Image repository. May start with a registry (`registry.k8s.io/kubectl`); `global.imageRegistry` replaces that registry when set.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers--init--image--tag"><a href="./values.yaml#L540">clickhouse.initContainers.init.image.tag</a></td>
            <td>float</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1.35</pre>
</div>
            </td>
            <td>Tag of the `init` container image.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers--init--image--pullPolicy"><a href="./values.yaml#L544">clickhouse.initContainers.init.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Pull policy of the `init` container image.</td>
        </tr>
        <tr>
            <td id="clickhouse--initContainers--init--command"><a href="./values.yaml#L548">clickhouse.initContainers.init.command</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Command of the `init` container; by default a loop that runs `curl` against `http://signoz-clickhouse:8123/` until it succeeds.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraContainers"><a href="./values.yaml#L558">clickhouse.extraContainers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra containers for ClickHouse pod</td>
        </tr>
        <tr>
            <td id="clickhouse--startupProbe"><a href="./values.yaml#L566">clickhouse.startupProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Startup probe of the ClickHouse container, a Kubernetes probe object (`httpGet`, `exec`, `tcpSocket` or `grpc`, with its timing fields), rendered as given. Set to `null` to render no probe. To use `exec`, `tcpSocket` or `grpc`, also set `httpGet: null`, because Helm merges a user's map over the default map and a probe may have only one handler.</td>
        </tr>
        <tr>
            <td id="clickhouse--livenessProbe"><a href="./values.yaml#L578">clickhouse.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Liveness probe of the ClickHouse container, a Kubernetes probe object (`httpGet`, `exec`, `tcpSocket` or `grpc`, with its timing fields), rendered as given. Set to `null` to render no probe. To use `exec`, `tcpSocket` or `grpc`, also set `httpGet: null`, because Helm merges a user's map over the default map and a probe may have only one handler.</td>
        </tr>
        <tr>
            <td id="clickhouse--readinessProbe"><a href="./values.yaml#L590">clickhouse.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Readiness probe of the ClickHouse container, a Kubernetes probe object (`httpGet`, `exec`, `tcpSocket` or `grpc`, with its timing fields), rendered as given. Set to `null` to render no probe. To use `exec`, `tcpSocket` or `grpc`, also set `httpGet: null`, because Helm merges a user's map over the default map and a probe may have only one handler.</td>
        </tr>
        <tr>
            <td id="clickhouse--resources"><a href="./values.yaml#L603">clickhouse.resources</a></td>
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
            <td id="clickhouse--podSecurityContext"><a href="./values.yaml#L613">clickhouse.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">fsGroup: 101
fsGroupChangePolicy: OnRootMismatch
runAsGroup: 101
runAsUser: 101</pre>
</div>
            </td>
            <td>Pod security context of the ClickHouse pod, a Kubernetes PodSecurityContext object rendered as given. Set to `null` to render no pod security context; an empty map keeps the defaults, because Helm merges maps.</td>
        </tr>
        <tr>
            <td id="clickhouse--priorityClassName"><a href="./values.yaml#L621">clickhouse.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Clickhouse priority class name. Rendered into the ClickHouse pod template as given; an empty value sets no priority class.</td>
        </tr>
        <tr>
            <td id="clickhouse--nodeSelector"><a href="./values.yaml#L625">clickhouse.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for assigning the ClickHouse pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--tolerations"><a href="./values.yaml#L629">clickhouse.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Toleration labels for ClickHouse pod assignment.</td>
        </tr>
        <tr>
            <td id="clickhouse--affinity"><a href="./values.yaml#L633">clickhouse.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for the ClickHouse pod.</td>
        </tr>
        <tr>
            <td id="clickhouse--topologySpreadConstraints"><a href="./values.yaml#L636">clickhouse.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>TopologySpreadConstraints describes how clickhouse pods ought to spread</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence"><a href="./values.yaml#L640">clickhouse.persistence</a></td>
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
            <td id="clickhouse--persistence--enabled"><a href="./values.yaml#L644">clickhouse.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable data persistence using a PVC for ClickHouse data.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--existingClaim"><a href="./values.yaml#L648">clickhouse.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Use a manually managed Persistent Volume Claim. If defined, the PVC must be created manually.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--storageClass"><a href="./values.yaml#L652">clickhouse.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Persistent Volume Storage Class. If "-", disables dynamic provisioning. If null, uses the default provisioner.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--accessModes"><a href="./values.yaml#L656">clickhouse.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>Access Modes for the persistent volume.</td>
        </tr>
        <tr>
            <td id="clickhouse--persistence--size"><a href="./values.yaml#L661">clickhouse.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">20Gi</pre>
</div>
            </td>
            <td>Persistent Volume size.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraVolumes"><a href="./values.yaml#L664">clickhouse.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the ClickHouse pod, a list of Kubernetes Volume objects.</td>
        </tr>
        <tr>
            <td id="clickhouse--extraVolumeMounts"><a href="./values.yaml#L667">clickhouse.extraVolumeMounts</a></td>
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
            <td id="zookeeper"><a href="./values.yaml#L673">zookeeper</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">See values.yaml</pre>
</div>
            </td>
            <td>Zookeeper default values. Ref: https://github.com/bitnami/charts/blob/main/bitnami/zookeeper/values.yaml</td>
        </tr>
        <tr>
            <td id="zookeeper--image"><a href="./values.yaml#L685">zookeeper.image</a></td>
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
            <td id="zookeeper--image--registry"><a href="./values.yaml#L688">zookeeper.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Zookeeper image registry to use.</td>
        </tr>
        <tr>
            <td id="zookeeper--image--repository"><a href="./values.yaml#L691">zookeeper.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/zookeeper</pre>
</div>
            </td>
            <td>Zookeeper image repository to use.</td>
        </tr>
        <tr>
            <td id="zookeeper--image--tag"><a href="./values.yaml#L696">zookeeper.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">3.7.1</pre>
</div>
            </td>
            <td>Zookeeper image tag. Note: SigNoz ClickHouse does not support all versions of Zookeeper. Please override the default only if you know what you are doing.</td>
        </tr>
        <tr>
            <td id="zookeeper--nameOverride"><a href="./values.yaml#L700">zookeeper.nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name override for zookeeper app</td>
        </tr>
        <tr>
            <td id="zookeeper--fullnameOverride"><a href="./values.yaml#L703">zookeeper.fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Fullname override for zookeeper app</td>
        </tr>
        <tr>
            <td id="zookeeper--namespaceOverride"><a href="./values.yaml#L707">zookeeper.namespaceOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Whether to install zookeeper into a different namespace than the parent</td>
        </tr>
        <tr>
            <td id="zookeeper--podAnnotations"><a href="./values.yaml#L711">zookeeper.podAnnotations</a></td>
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
            <td id="zookeeper--autopurge"><a href="./values.yaml#L718">zookeeper.autopurge</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">purgeInterval: 1</pre>
</div>
            </td>
            <td>Ongoing data directory cleanup configuration.</td>
        </tr>
        <tr>
            <td id="zookeeper--autopurge--purgeInterval"><a href="./values.yaml#L721">zookeeper.autopurge.purgeInterval</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>The time interval (in hours) for which the purge task has to be triggered</td>
        </tr>
        <tr>
            <td id="zookeeper--metrics"><a href="./values.yaml#L725">zookeeper.metrics</a></td>
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
            <td id="zookeeper--metrics--enabled"><a href="./values.yaml#L728">zookeeper.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable Prometheus to access ZooKeeper metrics endpoint.</td>
        </tr>
        <tr>
            <td id="zookeeper--metrics--service--annotations"><a href="./values.yaml#L734">zookeeper.metrics.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>ZooKeeper metrics service annotation</td>
        </tr>
        <tr>
            <td id="zookeeper--logLevel"><a href="./values.yaml#L741">zookeeper.logLevel</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">INFO</pre>
</div>
            </td>
            <td>Zookeeper log level.</td>
        </tr>
        <tr>
            <td id="zookeeper--livenessProbe"><a href="./values.yaml#L745">zookeeper.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>Zookeeper liveness probe settings.</td>
        </tr>
        <tr>
            <td id="zookeeper--readinessProbe"><a href="./values.yaml#L749">zookeeper.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>Zookeeper readiness probe settings.</td>
        </tr>
        <tr>
            <td id="zookeeper--customLivenessProbe"><a href="./values.yaml#L753">zookeeper.customLivenessProbe</a></td>
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
            <td id="zookeeper--customReadinessProbe"><a href="./values.yaml#L763">zookeeper.customReadinessProbe</a></td>
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
            <td id="zookeeper--minServerId"><a href="./values.yaml#L777">zookeeper.minServerId</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Minimal SERVER_ID value, nodes increment their IDs respectively. Servers increment their ID starting at this minimal value. Eg. with `minServerId=10` and 3 replicas, server IDs will be 10, 11, 12 for z-0, z-1 and z-2 respectively.</td>
        </tr>
        <tr>
            <td id="zookeeper--replicaCount"><a href="./values.yaml#L781">zookeeper.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Replica count for zookeeper</td>
        </tr>
        <tr>
            <td id="zookeeper--pdb"><a href="./values.yaml#L786">zookeeper.pdb</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">create: false</pre>
</div>
            </td>
            <td>ZooKeeper Pod Disruption Budget Ref: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/</td>
        </tr>
        <tr>
            <td id="zookeeper--pdb--create"><a href="./values.yaml#L789">zookeeper.pdb.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Specifies whether a Pod Disruption Budget should be created</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence"><a href="./values.yaml#L795">zookeeper.persistence</a></td>
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
            <td id="zookeeper--persistence--enabled"><a href="./values.yaml#L798">zookeeper.persistence.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable ZooKeeper data persistence using PVC. If false, use emptyDir</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--existingClaim"><a href="./values.yaml#L802">zookeeper.persistence.existingClaim</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of an existing PVC to use (only when deploying a single replica)</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--storageClass"><a href="./values.yaml#L811">zookeeper.persistence.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>PVC Storage Class for ZooKeeper data volume If defined, storageClassName: <storageClass> If set to "-", storageClassName: "", which disables dynamic provisioning If undefined (the default) or set to null, no storageClassName spec is   set, choosing the default provisioner.  (gp2 on AWS, standard on   GKE, AWS & OpenStack)</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--accessModes"><a href="./values.yaml#L815">zookeeper.persistence.accessModes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
            </td>
            <td>PVC Access modes</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--size"><a href="./values.yaml#L820">zookeeper.persistence.size</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8Gi</pre>
</div>
            </td>
            <td>PVC Storage Request for ZooKeeper data volume</td>
        </tr>
        <tr>
            <td id="zookeeper--persistence--annotations"><a href="./values.yaml#L824">zookeeper.persistence.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the PVC</td>
        </tr>
        <tr>
            <td id="zookeeper--resources"><a href="./values.yaml#L828">zookeeper.resources</a></td>
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
            <td id="externalClickhouse"><a href="./values.yaml#L1041">externalClickhouse</a></td>
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
            <td id="externalClickhouse--host"><a href="./values.yaml#L1046">externalClickhouse.host</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Host of the external ClickHouse cluster. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--cluster"><a href="./values.yaml#L1051">externalClickhouse.cluster</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster</pre>
</div>
            </td>
            <td>Name of the external cluster to run DDL queries on. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--database"><a href="./values.yaml#L1056">externalClickhouse.database</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_metrics</pre>
</div>
            </td>
            <td>Database name for the external cluster. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--traceDatabase"><a href="./values.yaml#L1061">externalClickhouse.traceDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_traces</pre>
</div>
            </td>
            <td>Database name for SigNoz Traces on the external cluster. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--logDatabase"><a href="./values.yaml#L1066">externalClickhouse.logDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_logs</pre>
</div>
            </td>
            <td>Database name for SigNoz Logs on the external cluster. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--meterDatabase"><a href="./values.yaml#L1071">externalClickhouse.meterDatabase</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz_meter</pre>
</div>
            </td>
            <td>Database name for SigNoz Meter on the external cluster. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--user"><a href="./values.yaml#L1076">externalClickhouse.user</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Username to connect to the external cluster. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--password"><a href="./values.yaml#L1081">externalClickhouse.password</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Password for the external cluster. Ignored if `externalClickhouse.existingSecret` is set. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--existingSecret"><a href="./values.yaml#L1086">externalClickhouse.existingSecret</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of an existing Kubernetes secret containing the password. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--existingSecretPasswordKey"><a href="./values.yaml#L1091">externalClickhouse.existingSecretPasswordKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Key in the existing secret that contains the password. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--secure"><a href="./values.yaml#L1096">externalClickhouse.secure</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to use a TLS connection when connecting to ClickHouse. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--verify"><a href="./values.yaml#L1101">externalClickhouse.verify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to verify the TLS certificate on connection to ClickHouse. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--httpPort"><a href="./values.yaml#L1106">externalClickhouse.httpPort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8123</pre>
</div>
            </td>
            <td>HTTP port of the external ClickHouse instance. Used only when `clickhouse.enabled` is false.</td>
        </tr>
        <tr>
            <td id="externalClickhouse--tcpPort"><a href="./values.yaml#L1111">externalClickhouse.tcpPort</a></td>
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
            <td id="signoz"><a href="./values.yaml#L1115">signoz</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Default values for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--name"><a href="./values.yaml#L1119">signoz.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz</pre>
</div>
            </td>
            <td>The name of the SigNoz component.</td>
        </tr>
        <tr>
            <td id="signoz--replicaCount"><a href="./values.yaml#L1123">signoz.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>The number of pod replicas for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--image"><a href="./values.yaml#L1126">signoz.image</a></td>
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
            <td id="signoz--imagePullSecrets"><a href="./values.yaml#L1144">signoz.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for SigNoz. This has higher precedence than the root level or global value.</td>
        </tr>
        <tr>
            <td id="signoz--serviceAccount"><a href="./values.yaml#L1147">signoz.serviceAccount</a></td>
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
            <td id="signoz--annotations"><a href="./values.yaml#L1191">signoz.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--additionalArgs"><a href="./values.yaml#L1195">signoz.additionalArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional command-line arguments for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--env"><a href="./values.yaml#L1219">signoz.env</a></td>
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
            <td id="signoz--podSecurityContext"><a href="./values.yaml#L1236">signoz.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Pod-level security context.</td>
        </tr>
        <tr>
            <td id="signoz--podAnnotations"><a href="./values.yaml#L1242">signoz.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--securityContext"><a href="./values.yaml#L1246">signoz.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Container-level security context.</td>
        </tr>
        <tr>
            <td id="signoz--additionalVolumeMounts"><a href="./values.yaml#L1257">signoz.additionalVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volume mounts for the SigNoz container.</td>
        </tr>
        <tr>
            <td id="signoz--additionalVolumes"><a href="./values.yaml#L1261">signoz.additionalVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volumes for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--livenessProbe"><a href="./values.yaml#L1265">signoz.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Liveness probe configuration.</td>
        </tr>
        <tr>
            <td id="signoz--readinessProbe"><a href="./values.yaml#L1277">signoz.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Readiness probe configuration.</td>
        </tr>
        <tr>
            <td id="signoz--customLivenessProbe"><a href="./values.yaml#L1289">signoz.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom liveness probe to override the default.</td>
        </tr>
        <tr>
            <td id="signoz--customReadinessProbe"><a href="./values.yaml#L1293">signoz.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom readiness probe to override the default.</td>
        </tr>
        <tr>
            <td id="signoz--resources"><a href="./values.yaml#L1328">signoz.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Resource requests and limits. Ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
        </tr>
        <tr>
            <td id="signoz--priorityClassName"><a href="./values.yaml#L1339">signoz.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class for the SigNoz pods.</td>
        </tr>
        <tr>
            <td id="signoz--nodeSelector"><a href="./values.yaml#L1343">signoz.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--tolerations"><a href="./values.yaml#L1347">signoz.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--affinity"><a href="./values.yaml#L1351">signoz.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--topologySpreadConstraints"><a href="./values.yaml#L1355">signoz.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="signoz--persistence"><a href="./values.yaml#L1358">signoz.persistence</a></td>
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
            <td id="signoz--service"><a href="./values.yaml#L1160">signoz.service</a></td>
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
            <td id="signoz--ingress"><a href="./values.yaml#L1296">signoz.ingress</a></td>
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
            <td id="telemetryStoreMigrator"><a href="./values.yaml#L1378">telemetryStoreMigrator</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Default values for the Telemetry Store Migrator.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--enabled"><a href="./values.yaml#L1382">telemetryStoreMigrator.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Telemetry Store Migrator component.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--name"><a href="./values.yaml#L1386">telemetryStoreMigrator.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz-telemetrystore-migrator</pre>
</div>
            </td>
            <td>The name of the Telemetry Store Migrator component.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--annotations"><a href="./values.yaml#L1390">telemetryStoreMigrator.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the Telemetry Store Migrator job.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--upgradeHelmHooks"><a href="./values.yaml#L1394">telemetryStoreMigrator.upgradeHelmHooks</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable Helm pre-upgrade hooks and ArgoCD Sync hooks.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--enableReplication"><a href="./values.yaml#L1398">telemetryStoreMigrator.enableReplication</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to enable replication for the Telemetry Store Migrator.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--timeout"><a href="./values.yaml#L1402">telemetryStoreMigrator.timeout</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10m</pre>
</div>
            </td>
            <td>Timeout for the migration.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--nodeSelector"><a href="./values.yaml#L1406">telemetryStoreMigrator.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--tolerations"><a href="./values.yaml#L1410">telemetryStoreMigrator.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--affinity"><a href="./values.yaml#L1414">telemetryStoreMigrator.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--topologySpreadConstraints"><a href="./values.yaml#L1418">telemetryStoreMigrator.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--resources"><a href="./values.yaml#L1422">telemetryStoreMigrator.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Resource requests and limits for all migrator containers.</td>
        </tr>
        <tr>
            <td id="telemetryStoreMigrator--serviceAccount"><a href="./values.yaml#L1425">telemetryStoreMigrator.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
create: true
name: null</pre>
</div>
            </td>
            <td>Service Account configuration for the Telemetry Store Migrator.</td>
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
            <td id="otelCollector"><a href="./values.yaml#L1439">otelCollector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Default values for the OpenTelemetry Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--name"><a href="./values.yaml#L1443">otelCollector.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">otel-collector</pre>
</div>
            </td>
            <td>The name of the Otel Collector component.</td>
        </tr>
        <tr>
            <td id="otelCollector--image"><a href="./values.yaml#L1447">otelCollector.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Image configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--imagePullSecrets"><a href="./values.yaml#L1464">otelCollector.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for the Otel Collector. This has higher precedence than the root level or global value.</td>
        </tr>
        <tr>
            <td id="otelCollector--strategy"><a href="./values.yaml#L1468">otelCollector.strategy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">RollingUpdate</pre>
</div>
            </td>
            <td>Deployment strategy to use</td>
        </tr>
        <tr>
            <td id="otelCollector--command"><a href="./values.yaml#L1471">otelCollector.command</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">extraArgs: null
name: /signoz-otel-collector</pre>
</div>
            </td>
            <td>Configuration for the Otel Collector executable.</td>
        </tr>
        <tr>
            <td id="otelCollector--configMap"><a href="./values.yaml#L1479">otelCollector.configMap</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">create: true</pre>
</div>
            </td>
            <td>ConfigMap settings.</td>
        </tr>
        <tr>
            <td id="otelCollector--serviceAccount"><a href="./values.yaml#L1485">otelCollector.serviceAccount</a></td>
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
            <td id="otelCollector--annotations"><a href="./values.yaml#L1513">otelCollector.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the Otel Collector Deployment.</td>
        </tr>
        <tr>
            <td id="otelCollector--podAnnotations"><a href="./values.yaml#L1517">otelCollector.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the Otel Collector pod(s).</td>
        </tr>
        <tr>
            <td id="otelCollector--podLabels"><a href="./values.yaml#L1523">otelCollector.podLabels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels for the Otel Collector pod(s).</td>
        </tr>
        <tr>
            <td id="otelCollector--additionalEnvs"><a href="./values.yaml#L1527">otelCollector.additionalEnvs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional environment variables for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--lowCardinalityExceptionGrouping"><a href="./values.yaml#L1533">otelCollector.lowCardinalityExceptionGrouping</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable grouping of exceptions with the same name but different stack traces. This is a tradeoff between cardinality and accuracy.</td>
        </tr>
        <tr>
            <td id="otelCollector--minReadySeconds"><a href="./values.yaml#L1537">otelCollector.minReadySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Minimum number of seconds for a new pod to be ready.</td>
        </tr>
        <tr>
            <td id="otelCollector--progressDeadlineSeconds"><a href="./values.yaml#L1541">otelCollector.progressDeadlineSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">600</pre>
</div>
            </td>
            <td>Maximum time in seconds for a deployment to make progress before it is considered failed.</td>
        </tr>
        <tr>
            <td id="otelCollector--replicaCount"><a href="./values.yaml#L1545">otelCollector.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>The number of pod replicas for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole"><a href="./values.yaml#L1549">otelCollector.clusterRole</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>RBAC ClusterRole configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--livenessProbe"><a href="./values.yaml#L1792">otelCollector.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Liveness probe configuration. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes</td>
        </tr>
        <tr>
            <td id="otelCollector--readinessProbe"><a href="./values.yaml#L1804">otelCollector.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Readiness probe configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--customLivenessProbe"><a href="./values.yaml#L1816">otelCollector.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom liveness probe to override the default.</td>
        </tr>
        <tr>
            <td id="otelCollector--customReadinessProbe"><a href="./values.yaml#L1820">otelCollector.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom readiness probe to override the default.</td>
        </tr>
        <tr>
            <td id="otelCollector--extraVolumeMounts"><a href="./values.yaml#L1824">otelCollector.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the Otel Collector pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--extraVolumes"><a href="./values.yaml#L1828">otelCollector.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the Otel Collector pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--resources"><a href="./values.yaml#L1865">otelCollector.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Resource requests and limits. Ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
        </tr>
        <tr>
            <td id="otelCollector--priorityClassName"><a href="./values.yaml#L1876">otelCollector.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class for the Otel Collector pods.</td>
        </tr>
        <tr>
            <td id="otelCollector--nodeSelector"><a href="./values.yaml#L1880">otelCollector.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--tolerations"><a href="./values.yaml#L1884">otelCollector.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--affinity"><a href="./values.yaml#L1888">otelCollector.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--topologySpreadConstraints"><a href="./values.yaml#L1892">otelCollector.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="otelCollector--podSecurityContext"><a href="./values.yaml#L1902">otelCollector.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Pod-level security context.</td>
        </tr>
        <tr>
            <td id="otelCollector--securityContext"><a href="./values.yaml#L1908">otelCollector.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Container-level security context.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling"><a href="./values.yaml#L1919">otelCollector.autoscaling</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Autoscaling configuration (HPA).</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda"><a href="./values.yaml#L1956">otelCollector.autoscaling.keda</a></td>
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
            <td id="otelCollector--service"><a href="./values.yaml#L1497">otelCollector.service</a></td>
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
            <td id="otelCollector--ingress"><a href="./values.yaml#L1831">otelCollector.ingress</a></td>
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
            <td id="otelCollector--ingress--hosts"><a href="./values.yaml#L1849">otelCollector.ingress.hosts</a></td>
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
            <td id="otelCollector--ports"><a href="./values.yaml#L1589">otelCollector.ports</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Port configurations for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp"><a href="./values.yaml#L1592">otelCollector.ports.otlp</a></td>
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
            <td id="otelCollector--ports--otlp-http"><a href="./values.yaml#L1610">otelCollector.ports.otlp-http</a></td>
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
            <td id="otelCollector--ports--jaeger-compact"><a href="./values.yaml#L1628">otelCollector.ports.jaeger-compact</a></td>
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
            <td id="otelCollector--ports--jaeger-thrift"><a href="./values.yaml#L1646">otelCollector.ports.jaeger-thrift</a></td>
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
            <td id="otelCollector--ports--jaeger-grpc"><a href="./values.yaml#L1664">otelCollector.ports.jaeger-grpc</a></td>
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
            <td id="otelCollector--ports--zipkin"><a href="./values.yaml#L1682">otelCollector.ports.zipkin</a></td>
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
            <td id="otelCollector--ports--metrics"><a href="./values.yaml#L1700">otelCollector.ports.metrics</a></td>
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
            <td id="otelCollector--ports--zpages"><a href="./values.yaml#L1718">otelCollector.ports.zpages</a></td>
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
            <td id="otelCollector--ports--pprof"><a href="./values.yaml#L1736">otelCollector.ports.pprof</a></td>
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
            <td id="otelCollector--ports--logsheroku"><a href="./values.yaml#L1754">otelCollector.ports.logsheroku</a></td>
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
            <td id="otelCollector--ports--logsjson"><a href="./values.yaml#L1772">otelCollector.ports.logsjson</a></td>
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
            <td id="otelCollector--config"><a href="./values.yaml#L1981">otelCollector.config</a></td>
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
            <td id="postgresql--enabled"><a href="./values.yaml#L2123">postgresql.enabled</a></td>
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
            <td id="signoz-otel-gateway"><a href="./values.yaml#L2126">signoz-otel-gateway</a></td>
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
            <td id="signoz-otel-gateway--strategy"><a href="./values.yaml#L2133">signoz-otel-gateway.strategy</a></td>
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
            <td id="redpanda"><a href="./values.yaml#L2346">redpanda</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>This component is configurable with licensed version of SigNoz.</td>
        </tr>
    </tbody>
</table>

