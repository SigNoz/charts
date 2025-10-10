
# SigNoz

![Version: 0.93.2](https://img.shields.io/badge/Version-0.93.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.96.1](https://img.shields.io/badge/AppVersion-v0.96.1-informational?style=flat-square)

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
            <td id="externalClickhouse"><a href="./values.yaml#L701">externalClickhouse</a></td>
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
            <td id="signoz"><a href="./values.yaml#L747">signoz</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Default values for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--name"><a href="./values.yaml#L751">signoz.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz</pre>
</div>
            </td>
            <td>The name of the SigNoz component.</td>
        </tr>
        <tr>
            <td id="signoz--replicaCount"><a href="./values.yaml#L755">signoz.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>The number of pod replicas for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--image"><a href="./values.yaml#L758">signoz.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">pullPolicy: IfNotPresent
registry: docker.io
repository: signoz/signoz
tag: v0.96.1</pre>
</div>
            </td>
            <td>Image configuration for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--imagePullSecrets"><a href="./values.yaml#L776">signoz.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for SigNoz. This has higher precedence than the root level or global value.</td>
        </tr>
        <tr>
            <td id="signoz--serviceAccount"><a href="./values.yaml#L779">signoz.serviceAccount</a></td>
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
            <td id="signoz--annotations"><a href="./values.yaml#L823">signoz.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--additionalArgs"><a href="./values.yaml#L827">signoz.additionalArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional command-line arguments for SigNoz.</td>
        </tr>
        <tr>
            <td id="signoz--env"><a href="./values.yaml#L851">signoz.env</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">dot_metrics_enabled: true
signoz_alertmanager_provider: signoz
signoz_alertmanager_signoz_external__url: http://localhost:8080
signoz_emailing_enabled: false
signoz_prometheus_active_query_tracker_enabled: false
signoz_telemetrystore_provider: clickhouse</pre>
</div>
            </td>
            <td>Environment variables for SigNoz. Refer to the official documentation for a complete list: https://github.com/SigNoz/signoz/blob/main/conf/example.yaml Note on Variable Naming: Environment variables are derived from the YAML configuration. For example, a key `provider` under the `telemetry_store` section becomes `signoz_telemetrystore_provider`.</td>
        </tr>
        <tr>
            <td id="signoz--initContainers"><a href="./values.yaml#L869">signoz.initContainers</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Init containers for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--initContainers--init"><a href="./values.yaml#L874">signoz.initContainers.init</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Signoz init container configuration. This container is used to wait for ClickHouse to be ready before starting the main SigNoz service.</td>
        </tr>
        <tr>
            <td id="signoz--initContainers--migration"><a href="./values.yaml#L898">signoz.initContainers.migration</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">args: []
command: []
enabled: false
image:
    pullPolicy: IfNotPresent
    registry: docker.io
    repository: busybox
    tag: 1.35
resources: {}</pre>
</div>
            </td>
            <td>Migration init container configuration. This container is used to run migrations before the main SigNoz service starts.</td>
        </tr>
        <tr>
            <td id="signoz--podSecurityContext"><a href="./values.yaml#L921">signoz.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Pod-level security context.</td>
        </tr>
        <tr>
            <td id="signoz--podAnnotations"><a href="./values.yaml#L927">signoz.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--securityContext"><a href="./values.yaml#L931">signoz.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Container-level security context.</td>
        </tr>
        <tr>
            <td id="signoz--additionalVolumeMounts"><a href="./values.yaml#L942">signoz.additionalVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volume mounts for the SigNoz container.</td>
        </tr>
        <tr>
            <td id="signoz--additionalVolumes"><a href="./values.yaml#L946">signoz.additionalVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volumes for the SigNoz pod.</td>
        </tr>
        <tr>
            <td id="signoz--livenessProbe"><a href="./values.yaml#L950">signoz.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Liveness probe configuration.</td>
        </tr>
        <tr>
            <td id="signoz--readinessProbe"><a href="./values.yaml#L962">signoz.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Readiness probe configuration.</td>
        </tr>
        <tr>
            <td id="signoz--customLivenessProbe"><a href="./values.yaml#L974">signoz.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom liveness probe to override the default.</td>
        </tr>
        <tr>
            <td id="signoz--customReadinessProbe"><a href="./values.yaml#L978">signoz.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom readiness probe to override the default.</td>
        </tr>
        <tr>
            <td id="signoz--resources"><a href="./values.yaml#L1013">signoz.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Resource requests and limits. Ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
        </tr>
        <tr>
            <td id="signoz--priorityClassName"><a href="./values.yaml#L1024">signoz.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class for the SigNoz pods.</td>
        </tr>
        <tr>
            <td id="signoz--nodeSelector"><a href="./values.yaml#L1028">signoz.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--tolerations"><a href="./values.yaml#L1032">signoz.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--affinity"><a href="./values.yaml#L1036">signoz.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="signoz--topologySpreadConstraints"><a href="./values.yaml#L1040">signoz.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="signoz--persistence"><a href="./values.yaml#L1043">signoz.persistence</a></td>
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
            <td id="signoz--service"><a href="./values.yaml#L792">signoz.service</a></td>
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
            <td id="signoz--ingress"><a href="./values.yaml#L981">signoz.ingress</a></td>
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
<h3>Schema Migrator</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="schemaMigrator"><a href="./values.yaml#L1063">schemaMigrator</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Default values for the Schema Migrator.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--enabled"><a href="./values.yaml#L1067">schemaMigrator.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Schema Migrator component.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--name"><a href="./values.yaml#L1071">schemaMigrator.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">schema-migrator</pre>
</div>
            </td>
            <td>The name of the Schema Migrator component.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--image"><a href="./values.yaml#L1074">schemaMigrator.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">pullPolicy: IfNotPresent
registry: docker.io
repository: signoz/signoz-schema-migrator
tag: v0.129.6</pre>
</div>
            </td>
            <td>Image configuration for the Schema Migrator.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--args"><a href="./values.yaml#L1090">schemaMigrator.args</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- --up=</pre>
</div>
            </td>
            <td>Arguments for the Schema Migrator.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--annotations"><a href="./values.yaml#L1096">schemaMigrator.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the Schema Migrator job. Required for ArgoCD hooks if `upgradeHelmHooks` is enabled.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--upgradeHelmHooks"><a href="./values.yaml#L1100">schemaMigrator.upgradeHelmHooks</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable Helm pre-upgrade hooks for Helm or Sync Waves for ArgoCD.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--enableReplication"><a href="./values.yaml#L1104">schemaMigrator.enableReplication</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable replication for the Schema Migrator.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--nodeSelector"><a href="./values.yaml#L1108">schemaMigrator.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--tolerations"><a href="./values.yaml#L1112">schemaMigrator.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--affinity"><a href="./values.yaml#L1116">schemaMigrator.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--topologySpreadConstraints"><a href="./values.yaml#L1120">schemaMigrator.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--initContainers"><a href="./values.yaml#L1124">schemaMigrator.initContainers</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Init containers for the Schema Migrator pod.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--initContainers--init"><a href="./values.yaml#L1129">schemaMigrator.initContainers.init</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Schema Migrator init container configuration. This container is used to wait for ClickHouse to be ready before starting the main Schema Migrator service.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--initContainers--chReady"><a href="./values.yaml#L1154">schemaMigrator.initContainers.chReady</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>ClickHouse ready check container configuration. This container is used to ensure ClickHouse is ready with the correct version, shard count, and replica count before starting the Schema Migrator.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--initContainers--wait"><a href="./values.yaml#L1215">schemaMigrator.initContainers.wait</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Wait container configuration. This container is used to wait for other resources before starting the Schema Migrator.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--serviceAccount"><a href="./values.yaml#L1234">schemaMigrator.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
create: true
name: null</pre>
</div>
            </td>
            <td>Service Account configuration for the Schema Migrator.</td>
        </tr>
        <tr>
            <td id="schemaMigrator--role"><a href="./values.yaml#L1247">schemaMigrator.role</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>RBAC configuration for the Schema Migrator.</td>
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
            <td id="otelCollector"><a href="./values.yaml#L1276">otelCollector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Default values for the OpenTelemetry Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--name"><a href="./values.yaml#L1280">otelCollector.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">otel-collector</pre>
</div>
            </td>
            <td>The name of the Otel Collector component.</td>
        </tr>
        <tr>
            <td id="otelCollector--image"><a href="./values.yaml#L1284">otelCollector.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Image configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--imagePullSecrets"><a href="./values.yaml#L1301">otelCollector.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for the Otel Collector. This has higher precedence than the root level or global value.</td>
        </tr>
        <tr>
            <td id="otelCollector--initContainers"><a href="./values.yaml#L1305">otelCollector.initContainers</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Init containers for the Otel Collector pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--initContainers--init"><a href="./values.yaml#L1310">otelCollector.initContainers.init</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Otel Collector init container configuration. This container is used to wait for ClickHouse to be ready before starting the main Otel Collector service.</td>
        </tr>
        <tr>
            <td id="otelCollector--command"><a href="./values.yaml#L1333">otelCollector.command</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">extraArgs:
    - --feature-gates=-pkg.translator.prometheus.NormalizeName
name: /signoz-otel-collector</pre>
</div>
            </td>
            <td>Configuration for the Otel Collector executable.</td>
        </tr>
        <tr>
            <td id="otelCollector--configMap"><a href="./values.yaml#L1343">otelCollector.configMap</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">create: true</pre>
</div>
            </td>
            <td>ConfigMap settings.</td>
        </tr>
        <tr>
            <td id="otelCollector--serviceAccount"><a href="./values.yaml#L1349">otelCollector.serviceAccount</a></td>
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
            <td id="otelCollector--annotations"><a href="./values.yaml#L1377">otelCollector.annotations</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the Otel Collector Deployment.</td>
        </tr>
        <tr>
            <td id="otelCollector--podAnnotations"><a href="./values.yaml#L1381">otelCollector.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Annotations for the Otel Collector pod(s).</td>
        </tr>
        <tr>
            <td id="otelCollector--podLabels"><a href="./values.yaml#L1387">otelCollector.podLabels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Labels for the Otel Collector pod(s).</td>
        </tr>
        <tr>
            <td id="otelCollector--additionalEnvs"><a href="./values.yaml#L1391">otelCollector.additionalEnvs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional environment variables for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--lowCardinalityExceptionGrouping"><a href="./values.yaml#L1397">otelCollector.lowCardinalityExceptionGrouping</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable grouping of exceptions with the same name but different stack traces. This is a tradeoff between cardinality and accuracy.</td>
        </tr>
        <tr>
            <td id="otelCollector--minReadySeconds"><a href="./values.yaml#L1401">otelCollector.minReadySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Minimum number of seconds for a new pod to be ready.</td>
        </tr>
        <tr>
            <td id="otelCollector--progressDeadlineSeconds"><a href="./values.yaml#L1405">otelCollector.progressDeadlineSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">600</pre>
</div>
            </td>
            <td>Maximum time in seconds for a deployment to make progress before it is considered failed.</td>
        </tr>
        <tr>
            <td id="otelCollector--replicaCount"><a href="./values.yaml#L1409">otelCollector.replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>The number of pod replicas for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--clusterRole"><a href="./values.yaml#L1413">otelCollector.clusterRole</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>RBAC ClusterRole configuration for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--livenessProbe"><a href="./values.yaml#L1656">otelCollector.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Liveness probe configuration. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes</td>
        </tr>
        <tr>
            <td id="otelCollector--readinessProbe"><a href="./values.yaml#L1668">otelCollector.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Readiness probe configuration.</td>
        </tr>
        <tr>
            <td id="otelCollector--customLivenessProbe"><a href="./values.yaml#L1680">otelCollector.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom liveness probe to override the default.</td>
        </tr>
        <tr>
            <td id="otelCollector--customReadinessProbe"><a href="./values.yaml#L1684">otelCollector.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom readiness probe to override the default.</td>
        </tr>
        <tr>
            <td id="otelCollector--extraVolumeMounts"><a href="./values.yaml#L1688">otelCollector.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volume mounts for the Otel Collector pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--extraVolumes"><a href="./values.yaml#L1692">otelCollector.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra volumes for the Otel Collector pod.</td>
        </tr>
        <tr>
            <td id="otelCollector--resources"><a href="./values.yaml#L1729">otelCollector.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Resource requests and limits. Ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
        </tr>
        <tr>
            <td id="otelCollector--priorityClassName"><a href="./values.yaml#L1740">otelCollector.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class for the Otel Collector pods.</td>
        </tr>
        <tr>
            <td id="otelCollector--nodeSelector"><a href="./values.yaml#L1744">otelCollector.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--tolerations"><a href="./values.yaml#L1748">otelCollector.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--affinity"><a href="./values.yaml#L1752">otelCollector.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for pod assignment.</td>
        </tr>
        <tr>
            <td id="otelCollector--topologySpreadConstraints"><a href="./values.yaml#L1756">otelCollector.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Topology spread constraints for pod distribution.</td>
        </tr>
        <tr>
            <td id="otelCollector--podSecurityContext"><a href="./values.yaml#L1766">otelCollector.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Pod-level security context.</td>
        </tr>
        <tr>
            <td id="otelCollector--securityContext"><a href="./values.yaml#L1772">otelCollector.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Container-level security context.</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling"><a href="./values.yaml#L1783">otelCollector.autoscaling</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Autoscaling configuration (HPA).</td>
        </tr>
        <tr>
            <td id="otelCollector--autoscaling--keda"><a href="./values.yaml#L1820">otelCollector.autoscaling.keda</a></td>
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
            <td id="otelCollector--service"><a href="./values.yaml#L1361">otelCollector.service</a></td>
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
            <td id="otelCollector--ingress"><a href="./values.yaml#L1695">otelCollector.ingress</a></td>
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
            <td id="otelCollector--ingress--hosts"><a href="./values.yaml#L1713">otelCollector.ingress.hosts</a></td>
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
            <td id="otelCollector--ports"><a href="./values.yaml#L1453">otelCollector.ports</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Port configurations for the Otel Collector.</td>
        </tr>
        <tr>
            <td id="otelCollector--ports--otlp"><a href="./values.yaml#L1456">otelCollector.ports.otlp</a></td>
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
            <td id="otelCollector--ports--otlp-http"><a href="./values.yaml#L1474">otelCollector.ports.otlp-http</a></td>
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
            <td id="otelCollector--ports--jaeger-compact"><a href="./values.yaml#L1492">otelCollector.ports.jaeger-compact</a></td>
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
            <td id="otelCollector--ports--jaeger-thrift"><a href="./values.yaml#L1510">otelCollector.ports.jaeger-thrift</a></td>
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
            <td id="otelCollector--ports--jaeger-grpc"><a href="./values.yaml#L1528">otelCollector.ports.jaeger-grpc</a></td>
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
            <td id="otelCollector--ports--zipkin"><a href="./values.yaml#L1546">otelCollector.ports.zipkin</a></td>
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
            <td id="otelCollector--ports--metrics"><a href="./values.yaml#L1564">otelCollector.ports.metrics</a></td>
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
            <td id="otelCollector--ports--zpages"><a href="./values.yaml#L1582">otelCollector.ports.zpages</a></td>
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
            <td id="otelCollector--ports--pprof"><a href="./values.yaml#L1600">otelCollector.ports.pprof</a></td>
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
            <td id="otelCollector--ports--logsheroku"><a href="./values.yaml#L1618">otelCollector.ports.logsheroku</a></td>
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
            <td id="otelCollector--ports--logsjson"><a href="./values.yaml#L1636">otelCollector.ports.logsjson</a></td>
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
            <td id="otelCollector--config"><a href="./values.yaml#L1845">otelCollector.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the default values in values.yml</pre>
</div>
            </td>
            <td>Main configuration for the OpenTelemetry Collector pipelines.</td>
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
            <td id="signoz-otel-gateway"><a href="./values.yaml#L1949">signoz-otel-gateway</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>This component is configurable with licensed version of SigNoz.</td>
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
            <td id="redpanda"><a href="./values.yaml#L2355">redpanda</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>This component is configurable with licensed version of SigNoz.</td>
        </tr>
    </tbody>
</table>

<h3>Other Values</h3>
<table>
	<thead>
		<th>Key</th>
		<th>Type</th>
		<th>Default</th>
		<th>Description</th>
	</thead>
	<tbody>
	<tr>
		<td id="postgres--enabled"><a href="./values.yaml#L2167">postgres.enabled</a></td>
		<td>bool</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">false</pre>
</div>
		</td>
		<td>Enable or disable the Postgres for signoz.</td>
	</tr>
	<tr>
		<td id="postgres--replicaCount"><a href="./values.yaml#L2171">postgres.replicaCount</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">1</pre>
</div>
		</td>
		<td>Number of Postgres replicas.</td>
	</tr>
	<tr>
		<td id="postgres--image--repository"><a href="./values.yaml#L2176">postgres.image.repository</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">postgres</pre>
</div>
		</td>
		<td>Postgres image repository.</td>
	</tr>
	<tr>
		<td id="postgres--image--tag"><a href="./values.yaml#L2179">postgres.image.tag</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">16-alpine</pre>
</div>
		</td>
		<td>Postgres image tag.</td>
	</tr>
	<tr>
		<td id="postgres--image--pullPolicy"><a href="./values.yaml#L2182">postgres.image.pullPolicy</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">IfNotPresent</pre>
</div>
		</td>
		<td>Image pull policy.</td>
	</tr>
	<tr>
		<td id="postgres--imagePullSecrets"><a href="./values.yaml#L2186">postgres.imagePullSecrets</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Image pull secrets for Postgres.</td>
	</tr>
	<tr>
		<td id="postgres--service--annotations"><a href="./values.yaml#L2191">postgres.service.annotations</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Annotations for the Postgres service object.</td>
	</tr>
	<tr>
		<td id="postgres--service--labels"><a href="./values.yaml#L2194">postgres.service.labels</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Labels for the Postgres service object.</td>
	</tr>
	<tr>
		<td id="postgres--service--type"><a href="./values.yaml#L2197">postgres.service.type</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">ClusterIP</pre>
</div>
		</td>
		<td>The service type (`ClusterIP`, `NodePort`, `LoadBalancer`).</td>
	</tr>
	<tr>
		<td id="postgres--service--port"><a href="./values.yaml#L2200">postgres.service.port</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">5432</pre>
</div>
		</td>
		<td>The external port for Postgres.</td>
	</tr>
	<tr>
		<td id="postgres--auth--username"><a href="./values.yaml#L2205">postgres.auth.username</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">signoz</pre>
</div>
		</td>
		<td>Username for the custom user to create.</td>
	</tr>
	<tr>
		<td id="postgres--auth--password"><a href="./values.yaml#L2208">postgres.auth.password</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">signoz@123</pre>
</div>
		</td>
		<td>Password for the custom user to create. Ignored if `auth.existingSecret` is provided.</td>
	</tr>
	<tr>
		<td id="postgres--auth--database"><a href="./values.yaml#L2211">postgres.auth.database</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Name for a custom database to create.</td>
	</tr>
	<tr>
		<td id="postgres--auth--existingSecret"><a href="./values.yaml#L2214">postgres.auth.existingSecret</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Name of existing secret to use for PostgreSQL credentials. `auth.password` will be ignored and picked up from this secret.</td>
	</tr>
	<tr>
		<td id="postgres--auth--secretKeys--userPasswordKey"><a href="./values.yaml#L2218">postgres.auth.secretKeys.userPasswordKey</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">password</pre>
</div>
		</td>
		<td>Name of key in existing secret to use for PostgreSQL credentials. Only used when `auth.existingSecret` is set.</td>
	</tr>
	<tr>
		<td id="postgres--resources"><a href="./values.yaml#L2222">postgres.resources</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Resource requests and limits for Postgres pods.</td>
	</tr>
	<tr>
		<td id="postgres--priorityClassName"><a href="./values.yaml#L2226">postgres.priorityClassName</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Priority class name for Postgres pods.</td>
	</tr>
	<tr>
		<td id="postgres--podSecurityContext"><a href="./values.yaml#L2230">postgres.podSecurityContext</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Security context for Postgres pods.</td>
	</tr>
	<tr>
		<td id="postgres--securityContext"><a href="./values.yaml#L2234">postgres.securityContext</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Container security context for Postgres.</td>
	</tr>
	<tr>
		<td id="postgres--podAnnotations"><a href="./values.yaml#L2238">postgres.podAnnotations</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Annotations for Postgres pods.</td>
	</tr>
	<tr>
		<td id="postgres--annotations"><a href="./values.yaml#L2242">postgres.annotations</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Additional annotations for Postgres resources.</td>
	</tr>
	<tr>
		<td id="postgres--nodeSelector"><a href="./values.yaml#L2246">postgres.nodeSelector</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Node selector for Postgres pods.</td>
	</tr>
	<tr>
		<td id="postgres--tolerations"><a href="./values.yaml#L2250">postgres.tolerations</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Tolerations for Postgres pods.</td>
	</tr>
	<tr>
		<td id="postgres--affinity"><a href="./values.yaml#L2254">postgres.affinity</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Affinity rules for Postgres pods.</td>
	</tr>
	<tr>
		<td id="postgres--topologySpreadConstraints"><a href="./values.yaml#L2258">postgres.topologySpreadConstraints</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Topology spread constraints for Postgres pods.</td>
	</tr>
	<tr>
		<td id="postgres--livenessProbe--enabled"><a href="./values.yaml#L2263">postgres.livenessProbe.enabled</a></td>
		<td>bool</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">true</pre>
</div>
		</td>
		<td>Enable liveness probe.</td>
	</tr>
	<tr>
		<td id="postgres--livenessProbe--initialDelaySeconds"><a href="./values.yaml#L2266">postgres.livenessProbe.initialDelaySeconds</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">20</pre>
</div>
		</td>
		<td>Initial delay seconds for liveness probe.</td>
	</tr>
	<tr>
		<td id="postgres--livenessProbe--periodSeconds"><a href="./values.yaml#L2269">postgres.livenessProbe.periodSeconds</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">10</pre>
</div>
		</td>
		<td>Period seconds for liveness probe.</td>
	</tr>
	<tr>
		<td id="postgres--livenessProbe--timeoutSeconds"><a href="./values.yaml#L2272">postgres.livenessProbe.timeoutSeconds</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">5</pre>
</div>
		</td>
		<td>Timeout seconds for liveness probe.</td>
	</tr>
	<tr>
		<td id="postgres--livenessProbe--successThreshold"><a href="./values.yaml#L2275">postgres.livenessProbe.successThreshold</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">1</pre>
</div>
		</td>
		<td>Success threshold for liveness probe.</td>
	</tr>
	<tr>
		<td id="postgres--livenessProbe--failureThreshold"><a href="./values.yaml#L2278">postgres.livenessProbe.failureThreshold</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">6</pre>
</div>
		</td>
		<td>Failure threshold for liveness probe.</td>
	</tr>
	<tr>
		<td id="postgres--readinessProbe--enabled"><a href="./values.yaml#L2283">postgres.readinessProbe.enabled</a></td>
		<td>bool</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">true</pre>
</div>
		</td>
		<td>Enable readiness probe.</td>
	</tr>
	<tr>
		<td id="postgres--readinessProbe--initialDelaySeconds"><a href="./values.yaml#L2286">postgres.readinessProbe.initialDelaySeconds</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">5</pre>
</div>
		</td>
		<td>Initial delay seconds for readiness probe.</td>
	</tr>
	<tr>
		<td id="postgres--readinessProbe--periodSeconds"><a href="./values.yaml#L2289">postgres.readinessProbe.periodSeconds</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">5</pre>
</div>
		</td>
		<td>Period seconds for readiness probe.</td>
	</tr>
	<tr>
		<td id="postgres--readinessProbe--timeoutSeconds"><a href="./values.yaml#L2292">postgres.readinessProbe.timeoutSeconds</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">3</pre>
</div>
		</td>
		<td>Timeout seconds for readiness probe.</td>
	</tr>
	<tr>
		<td id="postgres--readinessProbe--successThreshold"><a href="./values.yaml#L2295">postgres.readinessProbe.successThreshold</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">1</pre>
</div>
		</td>
		<td>Success threshold for readiness probe.</td>
	</tr>
	<tr>
		<td id="postgres--readinessProbe--failureThreshold"><a href="./values.yaml#L2298">postgres.readinessProbe.failureThreshold</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">6</pre>
</div>
		</td>
		<td>Failure threshold for readiness probe.</td>
	</tr>
	<tr>
		<td id="postgres--persistence--enabled"><a href="./values.yaml#L2303">postgres.persistence.enabled</a></td>
		<td>bool</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">true</pre>
</div>
		</td>
		<td>Enable persistent storage for Postgres.</td>
	</tr>
	<tr>
		<td id="postgres--persistence--existingClaim"><a href="./values.yaml#L2306">postgres.persistence.existingClaim</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Use an existing PVC for Postgres data.</td>
	</tr>
	<tr>
		<td id="postgres--persistence--size"><a href="./values.yaml#L2309">postgres.persistence.size</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">10Gi</pre>
</div>
		</td>
		<td>Size of the persistent volume claim.</td>
	</tr>
	<tr>
		<td id="postgres--persistence--storageClass"><a href="./values.yaml#L2312">postgres.persistence.storageClass</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">null</pre>
</div>
		</td>
		<td>Storage class for the persistent volume claim.</td>
	</tr>
	<tr>
		<td id="postgres--persistence--accessModes"><a href="./values.yaml#L2315">postgres.persistence.accessModes</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
		</td>
		<td>Access modes for the persistent volume claim.</td>
	</tr>
	<tr>
		<td id="postgres--persistence--mountPath"><a href="./values.yaml#L2319">postgres.persistence.mountPath</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">/signoz/postgresql</pre>
</div>
		</td>
		<td>Mount path for Postgres data.</td>
	</tr>
	<tr>
		<td id="postgres--persistence--subPath"><a href="./values.yaml#L2322">postgres.persistence.subPath</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Subpath within the volume for Postgres data.</td>
	</tr>
	<tr>
		<td id="postgres--persistence--dataDir"><a href="./values.yaml#L2325">postgres.persistence.dataDir</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">/signoz/postgresql/data</pre>
</div>
		</td>
		<td>Data directory for Postgres.</td>
	</tr>
	<tr>
		<td id="postgres--additionalArgs"><a href="./values.yaml#L2329">postgres.additionalArgs</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Additional command-line arguments for Postgres.</td>
	</tr>
	<tr>
		<td id="postgres--additionalVolumes"><a href="./values.yaml#L2333">postgres.additionalVolumes</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Additional volumes for Postgres pods.</td>
	</tr>
	<tr>
		<td id="postgres--additionalVolumeMounts"><a href="./values.yaml#L2337">postgres.additionalVolumeMounts</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Additional volume mounts for Postgres containers.</td>
	</tr>
	<tr>
		<td id="postgres--extraEnv"><a href="./values.yaml#L2341">postgres.extraEnv</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Extra environment variables for Postgres containers.</td>
	</tr>
	<tr>
		<td id="postgres--serviceAccount--create"><a href="./values.yaml#L2346">postgres.serviceAccount.create</a></td>
		<td>bool</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">true</pre>
</div>
		</td>
		<td>Specifies whether a service account should be created.</td>
	</tr>
	<tr>
		<td id="postgres--serviceAccount--annotations"><a href="./values.yaml#L2349">postgres.serviceAccount.annotations</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Annotations to add to the service account.</td>
	</tr>
	<tr>
		<td id="postgres--serviceAccount--name"><a href="./values.yaml#L2352">postgres.serviceAccount.name</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 200px;"><pre lang="yaml">null</pre>
</div>
		</td>
		<td>The name of the service account to use. If not set and `create` is true, a name is generated.</td>
	</tr>
	</tbody>
</table>

