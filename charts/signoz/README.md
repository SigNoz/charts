
# SigNoz

![Version: 0.87.1](https://img.shields.io/badge/Version-0.87.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.90.1](https://img.shields.io/badge/AppVersion-v0.90.1-informational?style=flat-square)

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

### Breaking Changes

#### Version 0.87.0

**Configuration Migration Required:**
- `signoz.configVars` has been deprecated
- `signoz.smtpVars` has been deprecated

Both configuration options must now be specified under `signoz.env` instead.

**Before:**
```yaml
signoz:
  configVars:
    storage: clickhouse
  smtpVars:
    existingSecret:
      name: my-secret-name
      hostKey: my-smtp-host-key
```

**After:**
```yaml
signoz:
  env:
    storage: clickhouse
    smtp_port:
      valueFrom:
        secretKeyRef:
          name: my-secret-name
          key: my-smtp-host-key
```

## Configuration

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
				<div style="max-width: 300px;"><pre lang="tpl/array">cloud: other
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
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Overrides the Image registry globally for all components.</td>
		</tr>
		<tr>
			<td id="global--imagePullSecrets"><a href="./values.yaml#L11">global.imagePullSecrets</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Global Image Pull Secrets.</td>
		</tr>
		<tr>
			<td id="global--storageClass"><a href="./values.yaml#L17">global.storageClass</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Overrides the storage class for all PVCs with persistence enabled. If not set, the default storage class is used. If set to "-", storageClassName will be an empty string, which disables dynamic provisioning.</td>
		</tr>
		<tr>
			<td id="global--clusterDomain"><a href="./values.yaml#L22">global.clusterDomain</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">cluster.local</pre>
</div>
			</td>
			<td>The Kubernetes cluster domain. It is used only when components are installed in different namespaces.</td>
		</tr>
		<tr>
			<td id="global--clusterName"><a href="./values.yaml#L27">global.clusterName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>The Kubernetes cluster name. It is used to attach to telemetry data via the resource detection processor.</td>
		</tr>
		<tr>
			<td id="global--cloud"><a href="./values.yaml#L34">global.cloud</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">other</pre>
</div>
			</td>
			<td>The Kubernetes cluster cloud provider and distribution (if any). example: `aws`, `azure`, `gcp`, `gcp/autogke`, `hcloud`, `other` The storage class for persistent volumes is selected based on this value. When set to 'aws' or 'gcp' with `installCustomStorageClass` enabled, a new expandable storage class is created.</td>
		</tr>
		<tr>
			<td id="nameOverride"><a href="./values.yaml#L38">nameOverride</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Override the default chart name.</td>
		</tr>
		<tr>
			<td id="fullnameOverride"><a href="./values.yaml#L43">fullnameOverride</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Override the default full chart name.</td>
		</tr>
		<tr>
			<td id="clusterName"><a href="./values.yaml#L48">clusterName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Name of the K8s cluster. Used by SigNoz OtelCollectors to attach to telemetry data.</td>
		</tr>
		<tr>
			<td id="imagePullSecrets"><a href="./values.yaml#L55">imagePullSecrets</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Image Registry Secret Names for all SigNoz components. If `global.imagePullSecrets` is set, it will be merged with this list. This has lower precedence than `imagePullSecrets` at the individual component level.</td>
		</tr>
		<tr>
			<td id="externalClickhouse"><a href="./values.yaml#L672">externalClickhouse</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">cluster: cluster
database: signoz_metrics
existingSecret: null
existingSecretPasswordKey: null
host: null
httpPort: 8123
logDatabase: signoz_logs
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
			<td id="signoz"><a href="./values.yaml#L715">signoz</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">See values</pre>
</div>
			</td>
			<td>Default values for SigNoz.</td>
		</tr>
		<tr>
			<td id="signoz--name"><a href="./values.yaml#L718">signoz.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">signoz</pre>
</div>
			</td>
			<td>The name of the SigNoz component.</td>
		</tr>
		<tr>
			<td id="signoz--replicaCount"><a href="./values.yaml#L721">signoz.replicaCount</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">1</pre>
</div>
			</td>
			<td>The number of pod replicas for SigNoz.</td>
		</tr>
		<tr>
			<td id="signoz--image"><a href="./values.yaml#L724">signoz.image</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">pullPolicy: IfNotPresent
registry: docker.io
repository: signoz/signoz
tag: v0.90.1</pre>
</div>
			</td>
			<td>Image configuration for SigNoz.</td>
		</tr>
		<tr>
			<td id="signoz--image--registry"><a href="./values.yaml#L727">signoz.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">docker.io</pre>
</div>
			</td>
			<td>The container image registry.</td>
		</tr>
		<tr>
			<td id="signoz--image--repository"><a href="./values.yaml#L730">signoz.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">signoz/signoz</pre>
</div>
			</td>
			<td>The container image repository.</td>
		</tr>
		<tr>
			<td id="signoz--image--tag"><a href="./values.yaml#L733">signoz.image.tag</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">v0.90.1</pre>
</div>
			</td>
			<td>The container image tag.</td>
		</tr>
		<tr>
			<td id="signoz--image--pullPolicy"><a href="./values.yaml#L736">signoz.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">IfNotPresent</pre>
</div>
			</td>
			<td>The image pull policy.</td>
		</tr>
		<tr>
			<td id="signoz--imagePullSecrets"><a href="./values.yaml#L741">signoz.imagePullSecrets</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Image pull secrets for SigNoz. This has higher precedence than the root level or global value.</td>
		</tr>
		<tr>
			<td id="signoz--serviceAccount"><a href="./values.yaml#L745">signoz.serviceAccount</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">annotations: {}
create: true
name: null</pre>
</div>
			</td>
			<td>Service Account configuration for SigNoz.</td>
		</tr>
		<tr>
			<td id="signoz--serviceAccount--create"><a href="./values.yaml#L748">signoz.serviceAccount.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Specifies whether a service account should be created.</td>
		</tr>
		<tr>
			<td id="signoz--serviceAccount--annotations"><a href="./values.yaml#L751">signoz.serviceAccount.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations to add to the service account.</td>
		</tr>
		<tr>
			<td id="signoz--serviceAccount--name"><a href="./values.yaml#L754">signoz.serviceAccount.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>The name of the service account to use. If not set and `create` is true, a name is generated.</td>
		</tr>
		<tr>
			<td id="signoz--service"><a href="./values.yaml#L760">signoz.service</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Service configuration for SigNoz. This allows you to configure how SigNoz is exposed within the Kubernetes cluster.</td>
		</tr>
		<tr>
			<td id="signoz--service--annotations"><a href="./values.yaml#L763">signoz.service.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations for the SigNoz service object.</td>
		</tr>
		<tr>
			<td id="signoz--service--labels"><a href="./values.yaml#L766">signoz.service.labels</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Labels for the SigNoz service object.</td>
		</tr>
		<tr>
			<td id="signoz--service--type"><a href="./values.yaml#L769">signoz.service.type</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">ClusterIP</pre>
</div>
			</td>
			<td>The service type (`ClusterIP`, `NodePort`, `LoadBalancer`).</td>
		</tr>
		<tr>
			<td id="signoz--service--port"><a href="./values.yaml#L772">signoz.service.port</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">8080</pre>
</div>
			</td>
			<td>The external HTTP port for SigNoz.</td>
		</tr>
		<tr>
			<td id="signoz--service--internalPort"><a href="./values.yaml#L775">signoz.service.internalPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">8085</pre>
</div>
			</td>
			<td>The internal gRPC port for SigNoz.</td>
		</tr>
		<tr>
			<td id="signoz--service--opampPort"><a href="./values.yaml#L778">signoz.service.opampPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">4320</pre>
</div>
			</td>
			<td>The internal OpAMP port for SigNoz.</td>
		</tr>
		<tr>
			<td id="signoz--service--nodePort"><a href="./values.yaml#L781">signoz.service.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Manually specify the nodePort for HTTP when `service.type` is `NodePort`.</td>
		</tr>
		<tr>
			<td id="signoz--service--internalNodePort"><a href="./values.yaml#L784">signoz.service.internalNodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Manually specify the nodePort for the internal port when `service.type` is `NodePort`.</td>
		</tr>
		<tr>
			<td id="signoz--service--opampInternalNodePort"><a href="./values.yaml#L787">signoz.service.opampInternalNodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Manually specify the nodePort for OpAMP when `service.type` is `NodePort`.</td>
		</tr>
		<tr>
			<td id="signoz--annotations"><a href="./values.yaml#L792">signoz.annotations</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Annotations for the SigNoz pod.</td>
		</tr>
		<tr>
			<td id="signoz--additionalArgs"><a href="./values.yaml#L796">signoz.additionalArgs</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Additional command-line arguments for SigNoz.</td>
		</tr>
		<tr>
			<td id="signoz--env"><a href="./values.yaml#L821">signoz.env</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">dot_metrics_enabled: true
signoz_alertmanager_provider: signoz
signoz_alertmanager_signoz_external_url: http://localhost:8080
signoz_emailing_enabled: false
signoz_prometheus_active_query_tracker_enabled: false
signoz_telemetrystore_provider: clickhouse</pre>
</div>
			</td>
			<td>Environment variables for SigNoz. Refer to the official documentation for a complete list: https://github.com/SigNoz/signoz/blob/main/conf/example.yaml Note on Variable Naming: Environment variables are derived from the YAML configuration. For example, a key `provider` under the `telemetry_store` section becomes `signoz_telemetrystore_provider`.</td>
		</tr>
		<tr>
			<td id="signoz--initContainers"><a href="./values.yaml#L843">signoz.initContainers</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">See values</pre>
</div>
			</td>
			<td>Init containers for the SigNoz pod.</td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--enabled"><a href="./values.yaml#L847">signoz.initContainers.init.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Enable the init container to wait for ClickHouse.</td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--image"><a href="./values.yaml#L850">signoz.initContainers.init.image</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Image for the init container.</td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--command"><a href="./values.yaml#L857">signoz.initContainers.init.command</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Command settings for the init container.</td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--resources"><a href="./values.yaml#L864">signoz.initContainers.init.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Resource requests and limits for the init container.</td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--enabled"><a href="./values.yaml#L868">signoz.initContainers.migration.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td>Enable a migration init container.</td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--image"><a href="./values.yaml#L871">signoz.initContainers.migration.image</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Image for the migration container.</td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--args"><a href="./values.yaml#L878">signoz.initContainers.migration.args</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Arguments for the migration container's command.</td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--command"><a href="./values.yaml#L881">signoz.initContainers.migration.command</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Command for the migration container.</td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--resources"><a href="./values.yaml#L884">signoz.initContainers.migration.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Resource requests and limits for the migration container.</td>
		</tr>
		<tr>
			<td id="signoz--podSecurityContext"><a href="./values.yaml#L889">signoz.podSecurityContext</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Pod-level security context.</td>
		</tr>
		<tr>
			<td id="signoz--podAnnotations"><a href="./values.yaml#L895">signoz.podAnnotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations for the SigNoz pod.</td>
		</tr>
		<tr>
			<td id="signoz--securityContext"><a href="./values.yaml#L900">signoz.securityContext</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Container-level security context.</td>
		</tr>
		<tr>
			<td id="signoz--additionalVolumeMounts"><a href="./values.yaml#L911">signoz.additionalVolumeMounts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Additional volume mounts for the SigNoz container.</td>
		</tr>
		<tr>
			<td id="signoz--additionalVolumes"><a href="./values.yaml#L915">signoz.additionalVolumes</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Additional volumes for the SigNoz pod.</td>
		</tr>
		<tr>
			<td id="signoz--livenessProbe"><a href="./values.yaml#L920">signoz.livenessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Liveness probe configuration.</td>
		</tr>
		<tr>
			<td id="signoz--readinessProbe"><a href="./values.yaml#L933">signoz.readinessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Readiness probe configuration.</td>
		</tr>
		<tr>
			<td id="signoz--customLivenessProbe"><a href="./values.yaml#L946">signoz.customLivenessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Custom liveness probe to override the default.</td>
		</tr>
		<tr>
			<td id="signoz--customReadinessProbe"><a href="./values.yaml#L950">signoz.customReadinessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Custom readiness probe to override the default.</td>
		</tr>
		<tr>
			<td id="signoz--ingress"><a href="./values.yaml#L954">signoz.ingress</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">annotations: {}
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
			<td id="signoz--ingress--enabled"><a href="./values.yaml#L957">signoz.ingress.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td>Enable ingress controller resource.</td>
		</tr>
		<tr>
			<td id="signoz--ingress--className"><a href="./values.yaml#L960">signoz.ingress.className</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Ingress class name.</td>
		</tr>
		<tr>
			<td id="signoz--ingress--annotations"><a href="./values.yaml#L963">signoz.ingress.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations for the ingress resource.</td>
		</tr>
		<tr>
			<td id="signoz--ingress--hosts"><a href="./values.yaml#L968">signoz.ingress.hosts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">- host: signoz.domain.com
  paths:
    - path: /
      pathType: ImplementationSpecific
      port: 8080</pre>
</div>
			</td>
			<td>Hostname and path configurations for the ingress.</td>
		</tr>
		<tr>
			<td id="signoz--ingress--tls"><a href="./values.yaml#L976">signoz.ingress.tls</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>TLS configuration for the ingress.</td>
		</tr>
		<tr>
			<td id="signoz--resources"><a href="./values.yaml#L985">signoz.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Resource requests and limits. Ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
		</tr>
		<tr>
			<td id="signoz--priorityClassName"><a href="./values.yaml#L996">signoz.priorityClassName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Priority class for the SigNoz pods.</td>
		</tr>
		<tr>
			<td id="signoz--nodeSelector"><a href="./values.yaml#L1000">signoz.nodeSelector</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Node selector for pod assignment.</td>
		</tr>
		<tr>
			<td id="signoz--tolerations"><a href="./values.yaml#L1004">signoz.tolerations</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Tolerations for pod assignment.</td>
		</tr>
		<tr>
			<td id="signoz--affinity"><a href="./values.yaml#L1008">signoz.affinity</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Affinity settings for pod assignment.</td>
		</tr>
		<tr>
			<td id="signoz--topologySpreadConstraints"><a href="./values.yaml#L1012">signoz.topologySpreadConstraints</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Topology spread constraints for pod distribution.</td>
		</tr>
		<tr>
			<td id="signoz--persistence"><a href="./values.yaml#L1016">signoz.persistence</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">accessModes:
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
			<td id="signoz--persistence--enabled"><a href="./values.yaml#L1019">signoz.persistence.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Enable data persistence using a PVC.</td>
		</tr>
		<tr>
			<td id="signoz--persistence--existingClaim"><a href="./values.yaml#L1022">signoz.persistence.existingClaim</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Use a manually managed PVC.</td>
		</tr>
		<tr>
			<td id="signoz--persistence--storageClass"><a href="./values.yaml#L1025">signoz.persistence.storageClass</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>The storage class for the PVC. If "-", disables dynamic provisioning.</td>
		</tr>
		<tr>
			<td id="signoz--persistence--accessModes"><a href="./values.yaml#L1028">signoz.persistence.accessModes</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">- ReadWriteOnce</pre>
</div>
			</td>
			<td>Access modes for the persistent volume.</td>
		</tr>
		<tr>
			<td id="signoz--persistence--size"><a href="./values.yaml#L1032">signoz.persistence.size</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">1Gi</pre>
</div>
			</td>
			<td>The size of the persistent volume.</td>
		</tr>
		<tr>
			<td id="schemaMigrator"><a href="./values.yaml#L1036">schemaMigrator</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">See values</pre>
</div>
			</td>
			<td>Default values for the Schema Migrator.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--enabled"><a href="./values.yaml#L1039">schemaMigrator.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Enable the Schema Migrator component.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--name"><a href="./values.yaml#L1042">schemaMigrator.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">schema-migrator</pre>
</div>
			</td>
			<td>The name of the Schema Migrator component.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--image"><a href="./values.yaml#L1045">schemaMigrator.image</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">pullPolicy: IfNotPresent
registry: docker.io
repository: signoz/signoz-schema-migrator
tag: v0.128.2</pre>
</div>
			</td>
			<td>Image configuration for the Schema Migrator.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--image--registry"><a href="./values.yaml#L1048">schemaMigrator.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">docker.io</pre>
</div>
			</td>
			<td>The container image registry.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--image--repository"><a href="./values.yaml#L1051">schemaMigrator.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">signoz/signoz-schema-migrator</pre>
</div>
			</td>
			<td>The container image repository.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--image--tag"><a href="./values.yaml#L1054">schemaMigrator.image.tag</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">v0.128.2</pre>
</div>
			</td>
			<td>The container image tag.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--image--pullPolicy"><a href="./values.yaml#L1057">schemaMigrator.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">IfNotPresent</pre>
</div>
			</td>
			<td>The image pull policy.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--args"><a href="./values.yaml#L1060">schemaMigrator.args</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">- --up=</pre>
</div>
			</td>
			<td>Arguments for the Schema Migrator.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--annotations"><a href="./values.yaml#L1065">schemaMigrator.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations for the Schema Migrator job. Required for ArgoCD hooks if `upgradeHelmHooks` is enabled.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--upgradeHelmHooks"><a href="./values.yaml#L1068">schemaMigrator.upgradeHelmHooks</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Enable Helm pre-upgrade hooks for Helm or Sync Waves for ArgoCD.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--enableReplication"><a href="./values.yaml#L1071">schemaMigrator.enableReplication</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td>Whether to enable replication for the Schema Migrator.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--nodeSelector"><a href="./values.yaml#L1076">schemaMigrator.nodeSelector</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Node selector for pod assignment.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--tolerations"><a href="./values.yaml#L1080">schemaMigrator.tolerations</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Tolerations for pod assignment.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--affinity"><a href="./values.yaml#L1084">schemaMigrator.affinity</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Affinity settings for pod assignment.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--topologySpreadConstraints"><a href="./values.yaml#L1088">schemaMigrator.topologySpreadConstraints</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Topology spread constraints for pod distribution.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers"><a href="./values.yaml#L1093">schemaMigrator.initContainers</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">See values</pre>
</div>
			</td>
			<td>Init containers for the Schema Migrator pod.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--enabled"><a href="./values.yaml#L1097">schemaMigrator.initContainers.init.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Enable the init container to wait for ClickHouse.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--image"><a href="./values.yaml#L1100">schemaMigrator.initContainers.init.image</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Image for the init container.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--command"><a href="./values.yaml#L1107">schemaMigrator.initContainers.init.command</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Command settings for the init container.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--resources"><a href="./values.yaml#L1114">schemaMigrator.initContainers.init.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Resource requests and limits for the init container.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--wait--enabled"><a href="./values.yaml#L1132">schemaMigrator.initContainers.wait.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Enable the init container to wait for other resources.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--wait--image"><a href="./values.yaml#L1135">schemaMigrator.initContainers.wait.image</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Image for the wait container.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--wait--env"><a href="./values.yaml#L1142">schemaMigrator.initContainers.wait.env</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Environment variables for the wait container.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--serviceAccount"><a href="./values.yaml#L1146">schemaMigrator.serviceAccount</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">annotations: {}
create: true
name: null</pre>
</div>
			</td>
			<td>Service Account configuration for the Schema Migrator.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--serviceAccount--create"><a href="./values.yaml#L1149">schemaMigrator.serviceAccount.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Specifies whether a service account should be created.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--serviceAccount--annotations"><a href="./values.yaml#L1152">schemaMigrator.serviceAccount.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations to add to the service account.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--serviceAccount--name"><a href="./values.yaml#L1155">schemaMigrator.serviceAccount.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>The name of the service account to use. If not set and `create` is true, a name is generated.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--role"><a href="./values.yaml#L1160">schemaMigrator.role</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>RBAC configuration for the Schema Migrator.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--create"><a href="./values.yaml#L1163">schemaMigrator.role.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Specifies whether a ClusterRole should be created.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--annotations"><a href="./values.yaml#L1166">schemaMigrator.role.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations to add to the ClusterRole.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--name"><a href="./values.yaml#L1169">schemaMigrator.role.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>The name of the ClusterRole to use. If not set and `create` is true, a name is generated.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--rules"><a href="./values.yaml#L1173">schemaMigrator.role.rules</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>A set of RBAC rules. ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/</td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--roleBinding"><a href="./values.yaml#L1178">schemaMigrator.role.roleBinding</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">annotations: {}
name: ""</pre>
</div>
			</td>
			<td>ClusterRoleBinding configuration.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--roleBinding--annotations"><a href="./values.yaml#L1181">schemaMigrator.role.roleBinding.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations to add to the ClusterRoleBinding.</td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--roleBinding--name"><a href="./values.yaml#L1184">schemaMigrator.role.roleBinding.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>The name of the ClusterRoleBinding to use. If not set, a name is generated.</td>
		</tr>
		<tr>
			<td id="otelCollector"><a href="./values.yaml#L1189">otelCollector</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">See values</pre>
</div>
			</td>
			<td>Default values for the OpenTelemetry Collector.</td>
		</tr>
		<tr>
			<td id="otelCollector--name"><a href="./values.yaml#L1192">otelCollector.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">otel-collector</pre>
</div>
			</td>
			<td>The name of the Otel Collector component.</td>
		</tr>
		<tr>
			<td id="otelCollector--image"><a href="./values.yaml#L1195">otelCollector.image</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">pullPolicy: IfNotPresent
registry: docker.io
repository: signoz/signoz-otel-collector
tag: v0.128.2</pre>
</div>
			</td>
			<td>Image configuration for the Otel Collector.</td>
		</tr>
		<tr>
			<td id="otelCollector--image--registry"><a href="./values.yaml#L1198">otelCollector.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">docker.io</pre>
</div>
			</td>
			<td>The container image registry.</td>
		</tr>
		<tr>
			<td id="otelCollector--image--repository"><a href="./values.yaml#L1201">otelCollector.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">signoz/signoz-otel-collector</pre>
</div>
			</td>
			<td>The container image repository.</td>
		</tr>
		<tr>
			<td id="otelCollector--image--tag"><a href="./values.yaml#L1204">otelCollector.image.tag</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">v0.128.2</pre>
</div>
			</td>
			<td>The container image tag.</td>
		</tr>
		<tr>
			<td id="otelCollector--image--pullPolicy"><a href="./values.yaml#L1207">otelCollector.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">IfNotPresent</pre>
</div>
			</td>
			<td>The image pull policy.</td>
		</tr>
		<tr>
			<td id="otelCollector--imagePullSecrets"><a href="./values.yaml#L1212">otelCollector.imagePullSecrets</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Image pull secrets for the Otel Collector. This has higher precedence than the root level or global value.</td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers"><a href="./values.yaml#L1216">otelCollector.initContainers</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">See values</pre>
</div>
			</td>
			<td>Init containers for the Otel Collector pod.</td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--enabled"><a href="./values.yaml#L1220">otelCollector.initContainers.init.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td>Enable the init container to wait for ClickHouse.</td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--image"><a href="./values.yaml#L1223">otelCollector.initContainers.init.image</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Image for the init container.</td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--command"><a href="./values.yaml#L1230">otelCollector.initContainers.init.command</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Command settings for the init container.</td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--resources"><a href="./values.yaml#L1237">otelCollector.initContainers.init.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Resource requests and limits for the init container.</td>
		</tr>
		<tr>
			<td id="otelCollector--command"><a href="./values.yaml#L1241">otelCollector.command</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">extraArgs:
    - --feature-gates=-pkg.translator.prometheus.NormalizeName
name: /signoz-otel-collector</pre>
</div>
			</td>
			<td>Configuration for the Otel Collector executable.</td>
		</tr>
		<tr>
			<td id="otelCollector--command--name"><a href="./values.yaml#L1244">otelCollector.command.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">/signoz-otel-collector</pre>
</div>
			</td>
			<td>Otel Collector command name.</td>
		</tr>
		<tr>
			<td id="otelCollector--command--extraArgs"><a href="./values.yaml#L1247">otelCollector.command.extraArgs</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">- --feature-gates=-pkg.translator.prometheus.NormalizeName</pre>
</div>
			</td>
			<td>Extra command-line arguments for the Otel Collector.</td>
		</tr>
		<tr>
			<td id="otelCollector--configMap"><a href="./values.yaml#L1251">otelCollector.configMap</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">create: true</pre>
</div>
			</td>
			<td>ConfigMap settings.</td>
		</tr>
		<tr>
			<td id="otelCollector--configMap--create"><a href="./values.yaml#L1254">otelCollector.configMap.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Specifies whether a ConfigMap should be created.</td>
		</tr>
		<tr>
			<td id="otelCollector--serviceAccount"><a href="./values.yaml#L1258">otelCollector.serviceAccount</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">annotations: {}
create: true
name: null</pre>
</div>
			</td>
			<td>Service Account configuration for the Otel Collector.</td>
		</tr>
		<tr>
			<td id="otelCollector--serviceAccount--create"><a href="./values.yaml#L1261">otelCollector.serviceAccount.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Specifies whether a service account should be created.</td>
		</tr>
		<tr>
			<td id="otelCollector--serviceAccount--annotations"><a href="./values.yaml#L1264">otelCollector.serviceAccount.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations to add to the service account.</td>
		</tr>
		<tr>
			<td id="otelCollector--serviceAccount--name"><a href="./values.yaml#L1267">otelCollector.serviceAccount.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>The name of the service account to use. If not set and `create` is true, a name is generated.</td>
		</tr>
		<tr>
			<td id="otelCollector--service"><a href="./values.yaml#L1271">otelCollector.service</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">annotations: {}
labels: {}
loadBalancerSourceRanges: []
type: ClusterIP</pre>
</div>
			</td>
			<td>Service configuration for the Otel Collector.</td>
		</tr>
		<tr>
			<td id="otelCollector--service--annotations"><a href="./values.yaml#L1274">otelCollector.service.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations for the Otel Collector service object.</td>
		</tr>
		<tr>
			<td id="otelCollector--service--labels"><a href="./values.yaml#L1277">otelCollector.service.labels</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Labels for the Otel Collector service object.</td>
		</tr>
		<tr>
			<td id="otelCollector--service--type"><a href="./values.yaml#L1280">otelCollector.service.type</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">ClusterIP</pre>
</div>
			</td>
			<td>The service type (`ClusterIP`, `NodePort`, `LoadBalancer`).</td>
		</tr>
		<tr>
			<td id="otelCollector--service--loadBalancerSourceRanges"><a href="./values.yaml#L1283">otelCollector.service.loadBalancerSourceRanges</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Allowed source ranges when service type is `LoadBalancer`.</td>
		</tr>
		<tr>
			<td id="otelCollector--annotations"><a href="./values.yaml#L1288">otelCollector.annotations</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Annotations for the Otel Collector Deployment.</td>
		</tr>
		<tr>
			<td id="otelCollector--podAnnotations"><a href="./values.yaml#L1292">otelCollector.podAnnotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Annotations for the Otel Collector pod(s).</td>
		</tr>
		<tr>
			<td id="otelCollector--podLabels"><a href="./values.yaml#L1298">otelCollector.podLabels</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Labels for the Otel Collector pod(s).</td>
		</tr>
		<tr>
			<td id="otelCollector--additionalEnvs"><a href="./values.yaml#L1302">otelCollector.additionalEnvs</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Additional environment variables for the Otel Collector.</td>
		</tr>
		<tr>
			<td id="otelCollector--lowCardinalityExceptionGrouping"><a href="./values.yaml#L1308">otelCollector.lowCardinalityExceptionGrouping</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td>Whether to enable grouping of exceptions with the same name but different stack traces. This is a tradeoff between cardinality and accuracy.</td>
		</tr>
		<tr>
			<td id="otelCollector--minReadySeconds"><a href="./values.yaml#L1312">otelCollector.minReadySeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">5</pre>
</div>
			</td>
			<td>Minimum number of seconds for a new pod to be ready.</td>
		</tr>
		<tr>
			<td id="otelCollector--progressDeadlineSeconds"><a href="./values.yaml#L1316">otelCollector.progressDeadlineSeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">600</pre>
</div>
			</td>
			<td>Maximum time in seconds for a deployment to make progress before it is considered failed.</td>
		</tr>
		<tr>
			<td id="otelCollector--replicaCount"><a href="./values.yaml#L1320">otelCollector.replicaCount</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">1</pre>
</div>
			</td>
			<td>The number of pod replicas for the Otel Collector.</td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole"><a href="./values.yaml#L1325">otelCollector.clusterRole</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">See values</pre>
</div>
			</td>
			<td>RBAC ClusterRole configuration for the Otel Collector.</td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--create"><a href="./values.yaml#L1328">otelCollector.clusterRole.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Specifies whether a ClusterRole should be created.</td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--annotations"><a href="./values.yaml#L1331">otelCollector.clusterRole.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations to add to the ClusterRole.</td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--name"><a href="./values.yaml#L1334">otelCollector.clusterRole.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>The name of the ClusterRole to use. If not set, a name is generated.</td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--rules"><a href="./values.yaml#L1338">otelCollector.clusterRole.rules</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">See values</pre>
</div>
			</td>
			<td>A set of RBAC rules. Required for the k8sattributes processor. ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/</td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--clusterRoleBinding"><a href="./values.yaml#L1352">otelCollector.clusterRole.clusterRoleBinding</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">annotations: {}
name: ""</pre>
</div>
			</td>
			<td>ClusterRoleBinding configuration.</td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--clusterRoleBinding--annotations"><a href="./values.yaml#L1355">otelCollector.clusterRole.clusterRoleBinding.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations to add to the ClusterRoleBinding.</td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--clusterRoleBinding--name"><a href="./values.yaml#L1358">otelCollector.clusterRole.clusterRoleBinding.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>The name of the ClusterRoleBinding to use. If not set, a name is generated.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports"><a href="./values.yaml#L1363">otelCollector.ports</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">See values</pre>
</div>
			</td>
			<td>Port configurations for the Otel Collector.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp--enabled"><a href="./values.yaml#L1367">otelCollector.ports.otlp.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Whether to enable the service port for OTLP gRPC.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp--containerPort"><a href="./values.yaml#L1370">otelCollector.ports.otlp.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">4317</pre>
</div>
			</td>
			<td>Container port for OTLP gRPC.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp--servicePort"><a href="./values.yaml#L1373">otelCollector.ports.otlp.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">4317</pre>
</div>
			</td>
			<td>Service port for OTLP gRPC.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp--nodePort"><a href="./values.yaml#L1376">otelCollector.ports.otlp.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Node port for OTLP gRPC.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp--protocol"><a href="./values.yaml#L1379">otelCollector.ports.otlp.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">TCP</pre>
</div>
			</td>
			<td>Protocol for OTLP gRPC.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp-http--enabled"><a href="./values.yaml#L1383">otelCollector.ports.otlp-http.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Whether to enable the service port for OTLP HTTP.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp-http--containerPort"><a href="./values.yaml#L1386">otelCollector.ports.otlp-http.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">4318</pre>
</div>
			</td>
			<td>Container port for OTLP HTTP.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp-http--servicePort"><a href="./values.yaml#L1389">otelCollector.ports.otlp-http.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">4318</pre>
</div>
			</td>
			<td>Service port for OTLP HTTP.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp-http--nodePort"><a href="./values.yaml#L1392">otelCollector.ports.otlp-http.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Node port for OTLP HTTP.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp-http--protocol"><a href="./values.yaml#L1395">otelCollector.ports.otlp-http.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">TCP</pre>
</div>
			</td>
			<td>Protocol for OTLP HTTP.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-compact--enabled"><a href="./values.yaml#L1399">otelCollector.ports.jaeger-compact.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td>Whether to enable the service port for Jaeger Compact.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-compact--containerPort"><a href="./values.yaml#L1402">otelCollector.ports.jaeger-compact.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">6831</pre>
</div>
			</td>
			<td>Container port for Jaeger Compact.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-compact--servicePort"><a href="./values.yaml#L1405">otelCollector.ports.jaeger-compact.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">6831</pre>
</div>
			</td>
			<td>Service port for Jaeger Compact.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-compact--nodePort"><a href="./values.yaml#L1408">otelCollector.ports.jaeger-compact.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Node port for Jaeger Compact.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-compact--protocol"><a href="./values.yaml#L1411">otelCollector.ports.jaeger-compact.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">UDP</pre>
</div>
			</td>
			<td>Protocol for Jaeger Compact.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-thrift--enabled"><a href="./values.yaml#L1415">otelCollector.ports.jaeger-thrift.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Whether to enable the service port for Jaeger Thrift HTTP.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-thrift--containerPort"><a href="./values.yaml#L1418">otelCollector.ports.jaeger-thrift.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">14268</pre>
</div>
			</td>
			<td>Container port for Jaeger Thrift.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-thrift--servicePort"><a href="./values.yaml#L1421">otelCollector.ports.jaeger-thrift.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">14268</pre>
</div>
			</td>
			<td>Service port for Jaeger Thrift.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-thrift--nodePort"><a href="./values.yaml#L1424">otelCollector.ports.jaeger-thrift.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Node port for Jaeger Thrift.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-thrift--protocol"><a href="./values.yaml#L1427">otelCollector.ports.jaeger-thrift.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">TCP</pre>
</div>
			</td>
			<td>Protocol for Jaeger Thrift.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-grpc--enabled"><a href="./values.yaml#L1431">otelCollector.ports.jaeger-grpc.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Whether to enable the service port for Jaeger gRPC.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-grpc--containerPort"><a href="./values.yaml#L1434">otelCollector.ports.jaeger-grpc.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">14250</pre>
</div>
			</td>
			<td>Container port for Jaeger gRPC.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-grpc--servicePort"><a href="./values.yaml#L1437">otelCollector.ports.jaeger-grpc.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">14250</pre>
</div>
			</td>
			<td>Service port for Jaeger gRPC.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-grpc--nodePort"><a href="./values.yaml#L1440">otelCollector.ports.jaeger-grpc.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Node port for Jaeger gRPC.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-grpc--protocol"><a href="./values.yaml#L1443">otelCollector.ports.jaeger-grpc.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">TCP</pre>
</div>
			</td>
			<td>Protocol for Jaeger gRPC.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zipkin--enabled"><a href="./values.yaml#L1447">otelCollector.ports.zipkin.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td>Whether to enable the service port for Zipkin.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zipkin--containerPort"><a href="./values.yaml#L1450">otelCollector.ports.zipkin.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">9411</pre>
</div>
			</td>
			<td>Container port for Zipkin.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zipkin--servicePort"><a href="./values.yaml#L1453">otelCollector.ports.zipkin.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">9411</pre>
</div>
			</td>
			<td>Service port for Zipkin.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zipkin--nodePort"><a href="./values.yaml#L1456">otelCollector.ports.zipkin.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Node port for Zipkin.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zipkin--protocol"><a href="./values.yaml#L1459">otelCollector.ports.zipkin.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">TCP</pre>
</div>
			</td>
			<td>Protocol for Zipkin.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--metrics--enabled"><a href="./values.yaml#L1463">otelCollector.ports.metrics.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Whether to enable the service port for internal metrics.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--metrics--containerPort"><a href="./values.yaml#L1466">otelCollector.ports.metrics.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">8888</pre>
</div>
			</td>
			<td>Container port for internal metrics.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--metrics--servicePort"><a href="./values.yaml#L1469">otelCollector.ports.metrics.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">8888</pre>
</div>
			</td>
			<td>Service port for internal metrics.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--metrics--nodePort"><a href="./values.yaml#L1472">otelCollector.ports.metrics.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Node port for internal metrics.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--metrics--protocol"><a href="./values.yaml#L1475">otelCollector.ports.metrics.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">TCP</pre>
</div>
			</td>
			<td>Protocol for internal metrics.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zpages--enabled"><a href="./values.yaml#L1479">otelCollector.ports.zpages.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td>Whether to enable the service port for ZPages.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zpages--containerPort"><a href="./values.yaml#L1482">otelCollector.ports.zpages.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">55679</pre>
</div>
			</td>
			<td>Container port for ZPages.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zpages--servicePort"><a href="./values.yaml#L1485">otelCollector.ports.zpages.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">55679</pre>
</div>
			</td>
			<td>Service port for ZPages.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zpages--nodePort"><a href="./values.yaml#L1488">otelCollector.ports.zpages.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Node port for ZPages.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zpages--protocol"><a href="./values.yaml#L1491">otelCollector.ports.zpages.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">TCP</pre>
</div>
			</td>
			<td>Protocol for ZPages.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--pprof--enabled"><a href="./values.yaml#L1495">otelCollector.ports.pprof.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td>Whether to enable the service port for pprof.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--pprof--containerPort"><a href="./values.yaml#L1498">otelCollector.ports.pprof.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">1777</pre>
</div>
			</td>
			<td>Container port for pprof.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--pprof--servicePort"><a href="./values.yaml#L1501">otelCollector.ports.pprof.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">1777</pre>
</div>
			</td>
			<td>Service port for pprof.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--pprof--nodePort"><a href="./values.yaml#L1504">otelCollector.ports.pprof.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Node port for pprof.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--pprof--protocol"><a href="./values.yaml#L1507">otelCollector.ports.pprof.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">TCP</pre>
</div>
			</td>
			<td>Protocol for pprof.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsheroku--enabled"><a href="./values.yaml#L1511">otelCollector.ports.logsheroku.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Whether to enable the service port for Heroku logs.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsheroku--containerPort"><a href="./values.yaml#L1514">otelCollector.ports.logsheroku.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">8081</pre>
</div>
			</td>
			<td>Container port for Heroku logs.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsheroku--servicePort"><a href="./values.yaml#L1517">otelCollector.ports.logsheroku.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">8081</pre>
</div>
			</td>
			<td>Service port for Heroku logs.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsheroku--nodePort"><a href="./values.yaml#L1520">otelCollector.ports.logsheroku.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Node port for Heroku logs.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsheroku--protocol"><a href="./values.yaml#L1523">otelCollector.ports.logsheroku.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">TCP</pre>
</div>
			</td>
			<td>Protocol for Heroku logs.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsjson--enabled"><a href="./values.yaml#L1527">otelCollector.ports.logsjson.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">true</pre>
</div>
			</td>
			<td>Whether to enable the service port for JSON logs.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsjson--containerPort"><a href="./values.yaml#L1530">otelCollector.ports.logsjson.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">8082</pre>
</div>
			</td>
			<td>Container port for JSON logs.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsjson--servicePort"><a href="./values.yaml#L1533">otelCollector.ports.logsjson.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">8082</pre>
</div>
			</td>
			<td>Service port for JSON logs.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsjson--nodePort"><a href="./values.yaml#L1536">otelCollector.ports.logsjson.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Node port for JSON logs.</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsjson--protocol"><a href="./values.yaml#L1539">otelCollector.ports.logsjson.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">TCP</pre>
</div>
			</td>
			<td>Protocol for JSON logs.</td>
		</tr>
		<tr>
			<td id="otelCollector--livenessProbe"><a href="./values.yaml#L1545">otelCollector.livenessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Liveness probe configuration. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes</td>
		</tr>
		<tr>
			<td id="otelCollector--readinessProbe"><a href="./values.yaml#L1557">otelCollector.readinessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">See values</pre>
</div>
			</td>
			<td>Readiness probe configuration.</td>
		</tr>
		<tr>
			<td id="otelCollector--customLivenessProbe"><a href="./values.yaml#L1569">otelCollector.customLivenessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Custom liveness probe to override the default.</td>
		</tr>
		<tr>
			<td id="otelCollector--customReadinessProbe"><a href="./values.yaml#L1573">otelCollector.customReadinessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Custom readiness probe to override the default.</td>
		</tr>
		<tr>
			<td id="otelCollector--extraVolumeMounts"><a href="./values.yaml#L1578">otelCollector.extraVolumeMounts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Extra volume mounts for the Otel Collector pod.</td>
		</tr>
		<tr>
			<td id="otelCollector--extraVolumes"><a href="./values.yaml#L1582">otelCollector.extraVolumes</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Extra volumes for the Otel Collector pod.</td>
		</tr>
		<tr>
			<td id="otelCollector--ingress"><a href="./values.yaml#L1586">otelCollector.ingress</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">annotations: {}
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
			<td id="otelCollector--ingress--enabled"><a href="./values.yaml#L1589">otelCollector.ingress.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td>Enable ingress controller resource.</td>
		</tr>
		<tr>
			<td id="otelCollector--ingress--className"><a href="./values.yaml#L1592">otelCollector.ingress.className</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Ingress class name.</td>
		</tr>
		<tr>
			<td id="otelCollector--ingress--annotations"><a href="./values.yaml#L1595">otelCollector.ingress.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Annotations for the ingress resource.</td>
		</tr>
		<tr>
			<td id="otelCollector--ingress--hosts"><a href="./values.yaml#L1603">otelCollector.ingress.hosts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Hostname and path configurations for the ingress.</td>
		</tr>
		<tr>
			<td id="otelCollector--ingress--tls"><a href="./values.yaml#L1611">otelCollector.ingress.tls</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>TLS configuration for the ingress.</td>
		</tr>
		<tr>
			<td id="otelCollector--resources"><a href="./values.yaml#L1620">otelCollector.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Resource requests and limits. Ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
		</tr>
		<tr>
			<td id="otelCollector--priorityClassName"><a href="./values.yaml#L1631">otelCollector.priorityClassName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">""</pre>
</div>
			</td>
			<td>Priority class for the Otel Collector pods.</td>
		</tr>
		<tr>
			<td id="otelCollector--nodeSelector"><a href="./values.yaml#L1635">otelCollector.nodeSelector</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Node selector for pod assignment.</td>
		</tr>
		<tr>
			<td id="otelCollector--tolerations"><a href="./values.yaml#L1639">otelCollector.tolerations</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Tolerations for pod assignment.</td>
		</tr>
		<tr>
			<td id="otelCollector--affinity"><a href="./values.yaml#L1643">otelCollector.affinity</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Affinity settings for pod assignment.</td>
		</tr>
		<tr>
			<td id="otelCollector--topologySpreadConstraints"><a href="./values.yaml#L1647">otelCollector.topologySpreadConstraints</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Topology spread constraints for pod distribution.</td>
		</tr>
		<tr>
			<td id="otelCollector--podSecurityContext"><a href="./values.yaml#L1658">otelCollector.podSecurityContext</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Pod-level security context.</td>
		</tr>
		<tr>
			<td id="otelCollector--securityContext"><a href="./values.yaml#L1664">otelCollector.securityContext</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Container-level security context.</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling"><a href="./values.yaml#L1675">otelCollector.autoscaling</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">See values</pre>
</div>
			</td>
			<td>Autoscaling configuration (HPA).</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--enabled"><a href="./values.yaml#L1678">otelCollector.autoscaling.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td>Enable Horizontal Pod Autoscaler.</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--minReplicas"><a href="./values.yaml#L1681">otelCollector.autoscaling.minReplicas</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">1</pre>
</div>
			</td>
			<td>Minimum number of replicas.</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--maxReplicas"><a href="./values.yaml#L1684">otelCollector.autoscaling.maxReplicas</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">11</pre>
</div>
			</td>
			<td>Maximum number of replicas.</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--targetCPUUtilizationPercentage"><a href="./values.yaml#L1687">otelCollector.autoscaling.targetCPUUtilizationPercentage</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">50</pre>
</div>
			</td>
			<td>Target CPU utilization percentage.</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--targetMemoryUtilizationPercentage"><a href="./values.yaml#L1690">otelCollector.autoscaling.targetMemoryUtilizationPercentage</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">50</pre>
</div>
			</td>
			<td>Target memory utilization percentage.</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--behavior"><a href="./values.yaml#L1693">otelCollector.autoscaling.behavior</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">{}</pre>
</div>
			</td>
			<td>Scaling behavior policies.</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--autoscalingTemplate"><a href="./values.yaml#L1696">otelCollector.autoscaling.autoscalingTemplate</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>Template for autoscaling.</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda"><a href="./values.yaml#L1699">otelCollector.autoscaling.keda</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">annotations: null
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
			<td id="otelCollector--autoscaling--keda--annotations"><a href="./values.yaml#L1702">otelCollector.autoscaling.keda.annotations</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">null</pre>
</div>
			</td>
			<td>Annotations for the KEDA ScaledObject.</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--enabled"><a href="./values.yaml#L1705">otelCollector.autoscaling.keda.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td>Enable KEDA autoscaling.</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--pollingInterval"><a href="./values.yaml#L1708">otelCollector.autoscaling.keda.pollingInterval</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">"30"</pre>
</div>
			</td>
			<td>Polling interval for metrics data (in seconds).</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--cooldownPeriod"><a href="./values.yaml#L1711">otelCollector.autoscaling.keda.cooldownPeriod</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">"300"</pre>
</div>
			</td>
			<td>Cooldown period before downscaling (in seconds).</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--minReplicaCount"><a href="./values.yaml#L1714">otelCollector.autoscaling.keda.minReplicaCount</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">"1"</pre>
</div>
			</td>
			<td>Minimum replica count for KEDA.</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--maxReplicaCount"><a href="./values.yaml#L1717">otelCollector.autoscaling.keda.maxReplicaCount</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">"5"</pre>
</div>
			</td>
			<td>Maximum replica count for KEDA.</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--triggers"><a href="./values.yaml#L1720">otelCollector.autoscaling.keda.triggers</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">[]</pre>
</div>
			</td>
			<td>KEDA trigger configuration.</td>
		</tr>
		<tr>
			<td id="otelCollector--config"><a href="./values.yaml#L1725">otelCollector.config</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">See values</pre>
</div>
			</td>
			<td>Main configuration for the OpenTelemetry Collector pipelines.</td>
		</tr>
		<tr>
			<td id="signoz-otel-gateway--enabled"><a href="./values.yaml#L1808">signoz-otel-gateway.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><pre lang="tpl/array">false</pre>
</div>
			</td>
			<td></td>
		</tr>
	</tbody>
</table>

