
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
			<td id="global--imageRegistry"><a href="./values.yaml#L4">global.imageRegistry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>Overrides the Image registry globally</td>
		</tr>
		<tr>
			<td id="global--imagePullSecrets"><a href="./values.yaml#L6">global.imagePullSecrets</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Global Image Pull Secrets</td>
		</tr>
		<tr>
			<td id="global--storageClass"><a href="./values.yaml#L10">global.storageClass</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>Overrides the storage class for all PVC with persistence enabled. If not set, the default storage class is used. If set to "-", storageClassName: "", which disables dynamic provisioning</td>
		</tr>
		<tr>
			<td id="global--clusterDomain"><a href="./values.yaml#L13">global.clusterDomain</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"cluster.local"</code>
</div>
			</td>
			<td>Kubernetes cluster domain It is used only when components are installed in different namespace</td>
		</tr>
		<tr>
			<td id="global--clusterName"><a href="./values.yaml#L16">global.clusterName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Kubernetes cluster name It is used to attached to telemetry data via resource detection processor</td>
		</tr>
		<tr>
			<td id="global--cloud"><a href="./values.yaml#L21">global.cloud</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"other"</code>
</div>
			</td>
			<td>Kubernetes cluster cloud provider along with distribution if any. example: `aws`, `azure`, `gcp`, `gcp/autogke`, `hcloud`, `other` Based on the cloud, storage class for the persistent volume is selected. When set to 'aws' or 'gcp' along with `installCustomStorageClass` enabled, then new expandible storage class is created.</td>
		</tr>
		<tr>
			<td id="nameOverride"><a href="./values.yaml#L23">nameOverride</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>SigNoz chart name override</td>
		</tr>
		<tr>
			<td id="fullnameOverride"><a href="./values.yaml#L25">fullnameOverride</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>SigNoz chart full name override</td>
		</tr>
		<tr>
			<td id="clusterName"><a href="./values.yaml#L27">clusterName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Name of the K8s cluster. Used by SigNoz OtelCollectors to attach in telemetry data.</td>
		</tr>
		<tr>
			<td id="imagePullSecrets"><a href="./values.yaml#L31">imagePullSecrets</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Image Registry Secret Names for all SigNoz components. If global.imagePullSecrets is set as well, it will merged. However, this has lower precedence than the imagePullSecrets at inner component level.</td>
		</tr>
		<tr>
			<td id="externalClickhouse--host"><a href="./values.yaml#L532">externalClickhouse.host</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>Host of the external cluster.</td>
		</tr>
		<tr>
			<td id="externalClickhouse--cluster"><a href="./values.yaml#L534">externalClickhouse.cluster</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"cluster"</code>
</div>
			</td>
			<td>Name of the external cluster to run DDL queries on.</td>
		</tr>
		<tr>
			<td id="externalClickhouse--database"><a href="./values.yaml#L536">externalClickhouse.database</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"signoz_metrics"</code>
</div>
			</td>
			<td>Database name for the external cluster</td>
		</tr>
		<tr>
			<td id="externalClickhouse--traceDatabase"><a href="./values.yaml#L538">externalClickhouse.traceDatabase</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"signoz_traces"</code>
</div>
			</td>
			<td>Clickhouse trace database (SigNoz Traces)</td>
		</tr>
		<tr>
			<td id="externalClickhouse--logDatabase"><a href="./values.yaml#L540">externalClickhouse.logDatabase</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"signoz_logs"</code>
</div>
			</td>
			<td>Clickhouse log database (SigNoz Logs)</td>
		</tr>
		<tr>
			<td id="externalClickhouse--user"><a href="./values.yaml#L542">externalClickhouse.user</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>User name for the external cluster to connect to the external cluster as</td>
		</tr>
		<tr>
			<td id="externalClickhouse--password"><a href="./values.yaml#L544">externalClickhouse.password</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Password for the cluster. Ignored if externalClickhouse.existingSecret is set</td>
		</tr>
		<tr>
			<td id="externalClickhouse--existingSecret"><a href="./values.yaml#L546">externalClickhouse.existingSecret</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>Name of an existing Kubernetes secret object containing the password</td>
		</tr>
		<tr>
			<td id="externalClickhouse--existingSecretPasswordKey"><a href="./values.yaml#L548">externalClickhouse.existingSecretPasswordKey</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>Name of the key pointing to the password in your Kubernetes secret</td>
		</tr>
		<tr>
			<td id="externalClickhouse--secure"><a href="./values.yaml#L550">externalClickhouse.secure</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td>Whether to use TLS connection connecting to ClickHouse</td>
		</tr>
		<tr>
			<td id="externalClickhouse--verify"><a href="./values.yaml#L552">externalClickhouse.verify</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td>Whether to verify TLS connection connecting to ClickHouse</td>
		</tr>
		<tr>
			<td id="externalClickhouse--httpPort"><a href="./values.yaml#L554">externalClickhouse.httpPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>8123</code>
</div>
			</td>
			<td>HTTP port of Clickhouse</td>
		</tr>
		<tr>
			<td id="externalClickhouse--tcpPort"><a href="./values.yaml#L556">externalClickhouse.tcpPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>9000</code>
</div>
			</td>
			<td>TCP port of Clickhouse</td>
		</tr>
		<tr>
			<td id="signoz--name"><a href="./values.yaml#L559">signoz.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"signoz"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--replicaCount"><a href="./values.yaml#L560">signoz.replicaCount</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>1</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--image--registry"><a href="./values.yaml#L562">signoz.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"docker.io"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--image--repository"><a href="./values.yaml#L563">signoz.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"signoz/signoz"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--image--tag"><a href="./values.yaml#L564">signoz.image.tag</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"v0.90.1"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--image--pullPolicy"><a href="./values.yaml#L565">signoz.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"IfNotPresent"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--imagePullSecrets"><a href="./values.yaml#L568">signoz.imagePullSecrets</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Image Registry Secret Names for signoz If set, this has higher precedence than the root level or global value of imagePullSecrets.</td>
		</tr>
		<tr>
			<td id="signoz--serviceAccount--create"><a href="./values.yaml#L572">signoz.serviceAccount.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--serviceAccount--annotations"><a href="./values.yaml#L574">signoz.serviceAccount.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--serviceAccount--name"><a href="./values.yaml#L577">signoz.serviceAccount.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--service--annotations"><a href="./values.yaml#L581">signoz.service.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Annotations to use by service associated to signoz</td>
		</tr>
		<tr>
			<td id="signoz--service--labels"><a href="./values.yaml#L583">signoz.service.labels</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Labels to use by service associated to signoz</td>
		</tr>
		<tr>
			<td id="signoz--service--type"><a href="./values.yaml#L585">signoz.service.type</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"ClusterIP"</code>
</div>
			</td>
			<td>Service Type: LoadBalancer (allows external access) or NodePort (more secure, no extra cost)</td>
		</tr>
		<tr>
			<td id="signoz--service--port"><a href="./values.yaml#L587">signoz.service.port</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>8080</code>
</div>
			</td>
			<td>signoz HTTP port</td>
		</tr>
		<tr>
			<td id="signoz--service--internalPort"><a href="./values.yaml#L589">signoz.service.internalPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>8085</code>
</div>
			</td>
			<td>signoz Internal port</td>
		</tr>
		<tr>
			<td id="signoz--service--opampPort"><a href="./values.yaml#L591">signoz.service.opampPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>4320</code>
</div>
			</td>
			<td>signoz OpAMP Internal port</td>
		</tr>
		<tr>
			<td id="signoz--service--nodePort"><a href="./values.yaml#L594">signoz.service.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>Set this if you want to force a specific nodePort for http. Must be use with service.type=NodePort</td>
		</tr>
		<tr>
			<td id="signoz--service--internalNodePort"><a href="./values.yaml#L597">signoz.service.internalNodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>Set this if you want to force a specific nodePort for internal. Must be use with service.type=NodePort</td>
		</tr>
		<tr>
			<td id="signoz--service--opampInternalNodePort"><a href="./values.yaml#L600">signoz.service.opampInternalNodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>Set this if you want to force a specific nodePort for OpAMP. Must be use with service.type=NodePort</td>
		</tr>
		<tr>
			<td id="signoz--annotations"><a href="./values.yaml#L602">signoz.annotations</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>signoz annotations</td>
		</tr>
		<tr>
			<td id="signoz--additionalArgs"><a href="./values.yaml#L604">signoz.additionalArgs</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>signoz additional arguments for command line</td>
		</tr>
		<tr>
			<td id="signoz--env--signoz_telemetrystore_provider"><a href="./values.yaml#L625">signoz.env.signoz_telemetrystore_provider</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"clickhouse"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--env--signoz_alertmanager_provider"><a href="./values.yaml#L626">signoz.env.signoz_alertmanager_provider</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"signoz"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--env--dot_metrics_enabled"><a href="./values.yaml#L627">signoz.env.dot_metrics_enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--env--signoz_emailing_enabled"><a href="./values.yaml#L635">signoz.env.signoz_emailing_enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td>Enable SMTP for user invitations. Sets `SIGNOZ_EMAILING_ENABLED` to true when enabled. Please check out the docs: https://signoz.io/docs/manage/administrator-guide/configuration/smtp-email-invitations/#version-greater-than-084x for more details.</td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--enabled"><a href="./values.yaml#L639">signoz.initContainers.init.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--image--registry"><a href="./values.yaml#L641">signoz.initContainers.init.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"docker.io"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--image--repository"><a href="./values.yaml#L642">signoz.initContainers.init.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"busybox"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--image--tag"><a href="./values.yaml#L643">signoz.initContainers.init.image.tag</a></td>
			<td>float</td>
			<td>
				<div style="max-width: 300px;"><code>1.35</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--image--pullPolicy"><a href="./values.yaml#L644">signoz.initContainers.init.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"IfNotPresent"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--command--delay"><a href="./values.yaml#L646">signoz.initContainers.init.command.delay</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>5</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--command--endpoint"><a href="./values.yaml#L647">signoz.initContainers.init.command.endpoint</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"/ping"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--command--waitMessage"><a href="./values.yaml#L648">signoz.initContainers.init.command.waitMessage</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"waiting for clickhouseDB"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--command--doneMessage"><a href="./values.yaml#L649">signoz.initContainers.init.command.doneMessage</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"clickhouse ready, starting query service now"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--init--resources"><a href="./values.yaml#L650">signoz.initContainers.init.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--enabled"><a href="./values.yaml#L658">signoz.initContainers.migration.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--image--registry"><a href="./values.yaml#L660">signoz.initContainers.migration.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"docker.io"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--image--repository"><a href="./values.yaml#L661">signoz.initContainers.migration.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"busybox"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--image--tag"><a href="./values.yaml#L662">signoz.initContainers.migration.image.tag</a></td>
			<td>float</td>
			<td>
				<div style="max-width: 300px;"><code>1.35</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--image--pullPolicy"><a href="./values.yaml#L663">signoz.initContainers.migration.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"IfNotPresent"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--args"><a href="./values.yaml#L664">signoz.initContainers.migration.args</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--command"><a href="./values.yaml#L665">signoz.initContainers.migration.command</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--resources"><a href="./values.yaml#L672">signoz.initContainers.migration.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--additionalVolumeMounts"><a href="./values.yaml#L680">signoz.initContainers.migration.additionalVolumeMounts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Additional volume mounts for signoz</td>
		</tr>
		<tr>
			<td id="signoz--initContainers--migration--additionalVolumes"><a href="./values.yaml#L682">signoz.initContainers.migration.additionalVolumes</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Additional volumes for signoz</td>
		</tr>
		<tr>
			<td id="signoz--podSecurityContext"><a href="./values.yaml#L685">signoz.podSecurityContext</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Pod security context for signoz</td>
		</tr>
		<tr>
			<td id="signoz--podAnnotations"><a href="./values.yaml#L688">signoz.podAnnotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Pod annotations for signoz</td>
		</tr>
		<tr>
			<td id="signoz--securityContext"><a href="./values.yaml#L690">signoz.securityContext</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Security context for signoz</td>
		</tr>
		<tr>
			<td id="signoz--additionalVolumeMounts"><a href="./values.yaml#L699">signoz.additionalVolumeMounts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Additional volume mounts for signoz</td>
		</tr>
		<tr>
			<td id="signoz--additionalVolumes"><a href="./values.yaml#L701">signoz.additionalVolumes</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Additional volumes for signoz</td>
		</tr>
		<tr>
			<td id="signoz--livenessProbe"><a href="./values.yaml#L704">signoz.livenessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{
  "enabled": true,
  "failureThreshold": 6,
  "initialDelaySeconds": 5,
  "path": "/api/v1/health",
  "periodSeconds": 10,
  "port": "http",
  "successThreshold": 1,
  "timeoutSeconds": 5
}</code>
</div>
			</td>
			<td>Configure liveness and readiness probes. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes</td>
		</tr>
		<tr>
			<td id="signoz--readinessProbe--enabled"><a href="./values.yaml#L714">signoz.readinessProbe.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--readinessProbe--port"><a href="./values.yaml#L715">signoz.readinessProbe.port</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"http"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--readinessProbe--path"><a href="./values.yaml#L716">signoz.readinessProbe.path</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"/api/v1/health?live=1"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--readinessProbe--initialDelaySeconds"><a href="./values.yaml#L717">signoz.readinessProbe.initialDelaySeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>5</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--readinessProbe--periodSeconds"><a href="./values.yaml#L718">signoz.readinessProbe.periodSeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>10</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--readinessProbe--timeoutSeconds"><a href="./values.yaml#L719">signoz.readinessProbe.timeoutSeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>5</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--readinessProbe--failureThreshold"><a href="./values.yaml#L720">signoz.readinessProbe.failureThreshold</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>6</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--readinessProbe--successThreshold"><a href="./values.yaml#L721">signoz.readinessProbe.successThreshold</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>1</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="signoz--customLivenessProbe"><a href="./values.yaml#L723">signoz.customLivenessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Custom liveness probe</td>
		</tr>
		<tr>
			<td id="signoz--customReadinessProbe"><a href="./values.yaml#L725">signoz.customReadinessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Custom readiness probe</td>
		</tr>
		<tr>
			<td id="signoz--ingress--enabled"><a href="./values.yaml#L728">signoz.ingress.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td>Enable ingress for signoz</td>
		</tr>
		<tr>
			<td id="signoz--ingress--className"><a href="./values.yaml#L730">signoz.ingress.className</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Ingress Class Name to be used to identify ingress controllers</td>
		</tr>
		<tr>
			<td id="signoz--ingress--annotations"><a href="./values.yaml#L732">signoz.ingress.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Annotations to signoz Ingress</td>
		</tr>
		<tr>
			<td id="signoz--ingress--hosts"><a href="./values.yaml#L737">signoz.ingress.hosts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[
  {
    "host": "signoz.domain.com",
    "paths": [
      {
        "path": "/",
        "pathType": "ImplementationSpecific",
        "port": 8080
      }
    ]
  }
]</code>
</div>
			</td>
			<td>signoz Ingress Host names with their path details</td>
		</tr>
		<tr>
			<td id="signoz--ingress--tls"><a href="./values.yaml#L744">signoz.ingress.tls</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>signoz Ingress TLS</td>
		</tr>
		<tr>
			<td id="signoz--resources"><a href="./values.yaml#L753">signoz.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>Configure resource requests and limits. Update according to your own use case as these values might not be suitable for your workload. Ref: http://kubernetes.io/docs/user-guide/compute-resources/ </td>
		</tr>
		<tr>
			<td id="signoz--priorityClassName"><a href="./values.yaml#L761">signoz.priorityClassName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Priority class name for signoz</td>
		</tr>
		<tr>
			<td id="signoz--nodeSelector"><a href="./values.yaml#L763">signoz.nodeSelector</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Node selector for settings for signoz pod</td>
		</tr>
		<tr>
			<td id="signoz--tolerations"><a href="./values.yaml#L765">signoz.tolerations</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Toleration labels for signoz pod assignment</td>
		</tr>
		<tr>
			<td id="signoz--affinity"><a href="./values.yaml#L767">signoz.affinity</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Affinity settings for signoz pod</td>
		</tr>
		<tr>
			<td id="signoz--topologySpreadConstraints"><a href="./values.yaml#L769">signoz.topologySpreadConstraints</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>TopologySpreadConstraints describes how g pods ought to spread</td>
		</tr>
		<tr>
			<td id="signoz--persistence--enabled"><a href="./values.yaml#L772">signoz.persistence.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td>Enable data persistence using PVC for SQLiteDB data.</td>
		</tr>
		<tr>
			<td id="signoz--persistence--existingClaim"><a href="./values.yaml#L774">signoz.persistence.existingClaim</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Name of an existing PVC to use (only when deploying a single replica)</td>
		</tr>
		<tr>
			<td id="signoz--persistence--storageClass"><a href="./values.yaml#L781">signoz.persistence.storageClass</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>Persistent Volume Storage Class to use. If defined, `storageClassName: <storageClass>`. If set to "-", `storageClassName: ""`, which disables dynamic provisioning If undefined (the default) or set to `null`, no storageClassName spec is set, choosing the default provisioner. </td>
		</tr>
		<tr>
			<td id="signoz--persistence--accessModes"><a href="./values.yaml#L783">signoz.persistence.accessModes</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[
  "ReadWriteOnce"
]</code>
</div>
			</td>
			<td>Access Modes for persistent volume</td>
		</tr>
		<tr>
			<td id="signoz--persistence--size"><a href="./values.yaml#L786">signoz.persistence.size</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"1Gi"</code>
</div>
			</td>
			<td>Persistent Volume size</td>
		</tr>
		<tr>
			<td id="schemaMigrator--enabled"><a href="./values.yaml#L789">schemaMigrator.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--name"><a href="./values.yaml#L790">schemaMigrator.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"schema-migrator"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--image--registry"><a href="./values.yaml#L792">schemaMigrator.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"docker.io"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--image--repository"><a href="./values.yaml#L793">schemaMigrator.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"signoz/signoz-schema-migrator"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--image--tag"><a href="./values.yaml#L794">schemaMigrator.image.tag</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"v0.128.2"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--image--pullPolicy"><a href="./values.yaml#L795">schemaMigrator.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"IfNotPresent"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--args[0]"><a href="./values.yaml#L797">schemaMigrator.args[0]</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"--up="</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--annotations"><a href="./values.yaml#L801">schemaMigrator.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--upgradeHelmHooks"><a href="./values.yaml#L804">schemaMigrator.upgradeHelmHooks</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--enableReplication"><a href="./values.yaml#L806">schemaMigrator.enableReplication</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td>Whether to enable replication for schemaMigrator</td>
		</tr>
		<tr>
			<td id="schemaMigrator--nodeSelector"><a href="./values.yaml#L808">schemaMigrator.nodeSelector</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Node selector for settings for schemaMigrator</td>
		</tr>
		<tr>
			<td id="schemaMigrator--tolerations"><a href="./values.yaml#L810">schemaMigrator.tolerations</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Toleration labels for schemaMigrator assignment</td>
		</tr>
		<tr>
			<td id="schemaMigrator--affinity"><a href="./values.yaml#L812">schemaMigrator.affinity</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Affinity settings for schemaMigrator</td>
		</tr>
		<tr>
			<td id="schemaMigrator--topologySpreadConstraints"><a href="./values.yaml#L814">schemaMigrator.topologySpreadConstraints</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>TopologySpreadConstraints describes how schemaMigrator pods ought to spread</td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--enabled"><a href="./values.yaml#L817">schemaMigrator.initContainers.init.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--image--registry"><a href="./values.yaml#L819">schemaMigrator.initContainers.init.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"docker.io"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--image--repository"><a href="./values.yaml#L820">schemaMigrator.initContainers.init.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"busybox"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--image--tag"><a href="./values.yaml#L821">schemaMigrator.initContainers.init.image.tag</a></td>
			<td>float</td>
			<td>
				<div style="max-width: 300px;"><code>1.35</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--image--pullPolicy"><a href="./values.yaml#L822">schemaMigrator.initContainers.init.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"IfNotPresent"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--command--delay"><a href="./values.yaml#L824">schemaMigrator.initContainers.init.command.delay</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>5</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--command--endpoint"><a href="./values.yaml#L825">schemaMigrator.initContainers.init.command.endpoint</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"/ping"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--command--waitMessage"><a href="./values.yaml#L826">schemaMigrator.initContainers.init.command.waitMessage</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"waiting for clickhouseDB"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--command--doneMessage"><a href="./values.yaml#L827">schemaMigrator.initContainers.init.command.doneMessage</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"clickhouse ready, starting schema migrator now"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--init--resources"><a href="./values.yaml#L828">schemaMigrator.initContainers.init.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--wait--enabled"><a href="./values.yaml#L900">schemaMigrator.initContainers.wait.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--wait--image--registry"><a href="./values.yaml#L902">schemaMigrator.initContainers.wait.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"docker.io"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--wait--image--repository"><a href="./values.yaml#L903">schemaMigrator.initContainers.wait.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"groundnuty/k8s-wait-for"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--wait--image--tag"><a href="./values.yaml#L904">schemaMigrator.initContainers.wait.image.tag</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"v2.0"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--wait--image--pullPolicy"><a href="./values.yaml#L905">schemaMigrator.initContainers.wait.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"IfNotPresent"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--initContainers--wait--env"><a href="./values.yaml#L906">schemaMigrator.initContainers.wait.env</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--serviceAccount--create"><a href="./values.yaml#L910">schemaMigrator.serviceAccount.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--serviceAccount--annotations"><a href="./values.yaml#L912">schemaMigrator.serviceAccount.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--serviceAccount--name"><a href="./values.yaml#L915">schemaMigrator.serviceAccount.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--create"><a href="./values.yaml#L919">schemaMigrator.role.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td>Specifies whether a clusterRole should be created</td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--annotations"><a href="./values.yaml#L921">schemaMigrator.role.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Annotations to add to the clusterRole</td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--name"><a href="./values.yaml#L924">schemaMigrator.role.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>The name of the clusterRole to use. If not set and create is true, a name is generated using the fullname template</td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--rules"><a href="./values.yaml#L928">schemaMigrator.role.rules</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>A set of rules as documented here. ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/</td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--roleBinding--annotations"><a href="./values.yaml#L935">schemaMigrator.role.roleBinding.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="schemaMigrator--role--roleBinding--name"><a href="./values.yaml#L938">schemaMigrator.role.roleBinding.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--name"><a href="./values.yaml#L941">otelCollector.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"otel-collector"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--image--registry"><a href="./values.yaml#L943">otelCollector.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"docker.io"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--image--repository"><a href="./values.yaml#L944">otelCollector.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"signoz/signoz-otel-collector"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--image--tag"><a href="./values.yaml#L945">otelCollector.image.tag</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"v0.128.2"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--image--pullPolicy"><a href="./values.yaml#L946">otelCollector.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"IfNotPresent"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--imagePullSecrets"><a href="./values.yaml#L949">otelCollector.imagePullSecrets</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Image Registry Secret Names for OtelCollector If set, this has higher precedence than the root level or global value of imagePullSecrets.</td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--enabled"><a href="./values.yaml#L952">otelCollector.initContainers.init.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--image--registry"><a href="./values.yaml#L954">otelCollector.initContainers.init.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"docker.io"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--image--repository"><a href="./values.yaml#L955">otelCollector.initContainers.init.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"busybox"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--image--tag"><a href="./values.yaml#L956">otelCollector.initContainers.init.image.tag</a></td>
			<td>float</td>
			<td>
				<div style="max-width: 300px;"><code>1.35</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--image--pullPolicy"><a href="./values.yaml#L957">otelCollector.initContainers.init.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"IfNotPresent"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--command--delay"><a href="./values.yaml#L959">otelCollector.initContainers.init.command.delay</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>5</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--command--endpoint"><a href="./values.yaml#L960">otelCollector.initContainers.init.command.endpoint</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"/ping"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--command--waitMessage"><a href="./values.yaml#L961">otelCollector.initContainers.init.command.waitMessage</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"waiting for clickhouseDB"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--command--doneMessage"><a href="./values.yaml#L962">otelCollector.initContainers.init.command.doneMessage</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"clickhouse ready, starting otel collector now"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--initContainers--init--resources"><a href="./values.yaml#L963">otelCollector.initContainers.init.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--command--name"><a href="./values.yaml#L973">otelCollector.command.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"/signoz-otel-collector"</code>
</div>
			</td>
			<td>OtelCollector command name</td>
		</tr>
		<tr>
			<td id="otelCollector--command--extraArgs"><a href="./values.yaml#L975">otelCollector.command.extraArgs</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[
  "--feature-gates=-pkg.translator.prometheus.NormalizeName"
]</code>
</div>
			</td>
			<td>OtelCollector command extra arguments</td>
		</tr>
		<tr>
			<td id="otelCollector--configMap--create"><a href="./values.yaml#L979">otelCollector.configMap.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td>Specifies whether a configMap should be created (true by default)</td>
		</tr>
		<tr>
			<td id="otelCollector--serviceAccount--create"><a href="./values.yaml#L983">otelCollector.serviceAccount.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--serviceAccount--annotations"><a href="./values.yaml#L985">otelCollector.serviceAccount.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--serviceAccount--name"><a href="./values.yaml#L988">otelCollector.serviceAccount.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--service--annotations"><a href="./values.yaml#L992">otelCollector.service.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Annotations to use by service associated to OtelCollector</td>
		</tr>
		<tr>
			<td id="otelCollector--service--labels"><a href="./values.yaml#L994">otelCollector.service.labels</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Labels to use by service associated to OtelCollector</td>
		</tr>
		<tr>
			<td id="otelCollector--service--type"><a href="./values.yaml#L996">otelCollector.service.type</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"ClusterIP"</code>
</div>
			</td>
			<td>Service Type: LoadBalancer (allows external access) or NodePort (more secure, no extra cost)</td>
		</tr>
		<tr>
			<td id="otelCollector--service--loadBalancerSourceRanges"><a href="./values.yaml#L998">otelCollector.service.loadBalancerSourceRanges</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>LoadBalancer Source Ranges when service type is LoadBalancer</td>
		</tr>
		<tr>
			<td id="otelCollector--annotations"><a href="./values.yaml#L1000">otelCollector.annotations</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>OtelCollector Deployment annotation.</td>
		</tr>
		<tr>
			<td id="otelCollector--podAnnotations"><a href="./values.yaml#L1002">otelCollector.podAnnotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{
  "signoz.io/port": "8888",
  "signoz.io/scrape": "true"
}</code>
</div>
			</td>
			<td>OtelCollector pod(s) annotation.</td>
		</tr>
		<tr>
			<td id="otelCollector--podLabels"><a href="./values.yaml#L1006">otelCollector.podLabels</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>OtelCollector pod(s) labels.</td>
		</tr>
		<tr>
			<td id="otelCollector--additionalEnvs"><a href="./values.yaml#L1008">otelCollector.additionalEnvs</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Additional environments to set for OtelCollector</td>
		</tr>
		<tr>
			<td id="otelCollector--lowCardinalityExceptionGrouping"><a href="./values.yaml#L1014">otelCollector.lowCardinalityExceptionGrouping</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td>Whether to enable grouping of exceptions with same name and different stack trace. This is useful when you have a lot of exceptions with same name but different stack trace. This is a tradeoff between cardinality and accuracy of exception grouping.</td>
		</tr>
		<tr>
			<td id="otelCollector--minReadySeconds"><a href="./values.yaml#L1015">otelCollector.minReadySeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>5</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--progressDeadlineSeconds"><a href="./values.yaml#L1016">otelCollector.progressDeadlineSeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>600</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--replicaCount"><a href="./values.yaml#L1017">otelCollector.replicaCount</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>1</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--create"><a href="./values.yaml#L1021">otelCollector.clusterRole.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td>Specifies whether a clusterRole should be created</td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--annotations"><a href="./values.yaml#L1023">otelCollector.clusterRole.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Annotations to add to the clusterRole</td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--name"><a href="./values.yaml#L1026">otelCollector.clusterRole.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>The name of the clusterRole to use. If not set and create is true, a name is generated using the fullname template</td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--rules"><a href="./values.yaml#L1030">otelCollector.clusterRole.rules</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>A set of rules as documented here. ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/</td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--clusterRoleBinding--annotations"><a href="./values.yaml#L1047">otelCollector.clusterRole.clusterRoleBinding.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--clusterRole--clusterRoleBinding--name"><a href="./values.yaml#L1050">otelCollector.clusterRole.clusterRoleBinding.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp--enabled"><a href="./values.yaml#L1055">otelCollector.ports.otlp.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td>Whether to enable service port for OTLP gRPC</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp--containerPort"><a href="./values.yaml#L1057">otelCollector.ports.otlp.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>4317</code>
</div>
			</td>
			<td>Container port for OTLP gRPC</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp--servicePort"><a href="./values.yaml#L1059">otelCollector.ports.otlp.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>4317</code>
</div>
			</td>
			<td>Service port for OTLP gRPC</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp--nodePort"><a href="./values.yaml#L1061">otelCollector.ports.otlp.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Node port for OTLP gRPC</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp--protocol"><a href="./values.yaml#L1063">otelCollector.ports.otlp.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"TCP"</code>
</div>
			</td>
			<td>Protocol to use for OTLP gRPC</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp-http--enabled"><a href="./values.yaml#L1066">otelCollector.ports.otlp-http.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td>Whether to enable service port for OTLP HTTP</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp-http--containerPort"><a href="./values.yaml#L1068">otelCollector.ports.otlp-http.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>4318</code>
</div>
			</td>
			<td>Container port for OTLP HTTP</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp-http--servicePort"><a href="./values.yaml#L1070">otelCollector.ports.otlp-http.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>4318</code>
</div>
			</td>
			<td>Service port for OTLP HTTP</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp-http--nodePort"><a href="./values.yaml#L1072">otelCollector.ports.otlp-http.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Node port for OTLP HTTP</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--otlp-http--protocol"><a href="./values.yaml#L1074">otelCollector.ports.otlp-http.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"TCP"</code>
</div>
			</td>
			<td>Protocol to use for OTLP HTTP</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-compact--enabled"><a href="./values.yaml#L1077">otelCollector.ports.jaeger-compact.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td>Whether to enable service port for Jaeger Compact</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-compact--containerPort"><a href="./values.yaml#L1079">otelCollector.ports.jaeger-compact.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>6831</code>
</div>
			</td>
			<td>Container port for Jaeger Compact</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-compact--servicePort"><a href="./values.yaml#L1081">otelCollector.ports.jaeger-compact.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>6831</code>
</div>
			</td>
			<td>Service port for Jaeger Compact</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-compact--nodePort"><a href="./values.yaml#L1083">otelCollector.ports.jaeger-compact.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Node port for Jaeger Compact</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-compact--protocol"><a href="./values.yaml#L1085">otelCollector.ports.jaeger-compact.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"UDP"</code>
</div>
			</td>
			<td>Protocol to use for Jaeger Compact</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-thrift--enabled"><a href="./values.yaml#L1088">otelCollector.ports.jaeger-thrift.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td>Whether to enable service port for Jaeger Thrift HTTP</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-thrift--containerPort"><a href="./values.yaml#L1090">otelCollector.ports.jaeger-thrift.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>14268</code>
</div>
			</td>
			<td>Container port for Jaeger Thrift</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-thrift--servicePort"><a href="./values.yaml#L1092">otelCollector.ports.jaeger-thrift.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>14268</code>
</div>
			</td>
			<td>Service port for Jaeger Thrift</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-thrift--nodePort"><a href="./values.yaml#L1094">otelCollector.ports.jaeger-thrift.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Node port for Jaeger Thrift</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-thrift--protocol"><a href="./values.yaml#L1096">otelCollector.ports.jaeger-thrift.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"TCP"</code>
</div>
			</td>
			<td>Protocol to use for Jaeger Thrift</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-grpc--enabled"><a href="./values.yaml#L1099">otelCollector.ports.jaeger-grpc.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td>Whether to enable service port for Jaeger gRPC</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-grpc--containerPort"><a href="./values.yaml#L1101">otelCollector.ports.jaeger-grpc.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>14250</code>
</div>
			</td>
			<td>Container port for Jaeger gRPC</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-grpc--servicePort"><a href="./values.yaml#L1103">otelCollector.ports.jaeger-grpc.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>14250</code>
</div>
			</td>
			<td>Service port for Jaeger gRPC</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-grpc--nodePort"><a href="./values.yaml#L1105">otelCollector.ports.jaeger-grpc.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Node port for Jaeger gRPC</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--jaeger-grpc--protocol"><a href="./values.yaml#L1107">otelCollector.ports.jaeger-grpc.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"TCP"</code>
</div>
			</td>
			<td>Protocol to use for Jaeger gRPC</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zipkin--enabled"><a href="./values.yaml#L1110">otelCollector.ports.zipkin.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td>Whether to enable service port for Zipkin</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zipkin--containerPort"><a href="./values.yaml#L1112">otelCollector.ports.zipkin.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>9411</code>
</div>
			</td>
			<td>Container port for Zipkin</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zipkin--servicePort"><a href="./values.yaml#L1114">otelCollector.ports.zipkin.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>9411</code>
</div>
			</td>
			<td>Service port for Zipkin</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zipkin--nodePort"><a href="./values.yaml#L1116">otelCollector.ports.zipkin.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Node port for Zipkin</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zipkin--protocol"><a href="./values.yaml#L1118">otelCollector.ports.zipkin.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"TCP"</code>
</div>
			</td>
			<td>Protocol to use for Zipkin</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--metrics--enabled"><a href="./values.yaml#L1121">otelCollector.ports.metrics.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td>Whether to enable service port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--metrics--containerPort"><a href="./values.yaml#L1123">otelCollector.ports.metrics.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>8888</code>
</div>
			</td>
			<td>Container port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--metrics--servicePort"><a href="./values.yaml#L1125">otelCollector.ports.metrics.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>8888</code>
</div>
			</td>
			<td>Service port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--metrics--nodePort"><a href="./values.yaml#L1127">otelCollector.ports.metrics.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Node port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--metrics--protocol"><a href="./values.yaml#L1129">otelCollector.ports.metrics.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"TCP"</code>
</div>
			</td>
			<td>Protocol to use for internal metrics</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zpages--enabled"><a href="./values.yaml#L1132">otelCollector.ports.zpages.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td>Whether to enable service port for ZPages</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zpages--containerPort"><a href="./values.yaml#L1134">otelCollector.ports.zpages.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>55679</code>
</div>
			</td>
			<td>Container port for Zpages</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zpages--servicePort"><a href="./values.yaml#L1136">otelCollector.ports.zpages.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>55679</code>
</div>
			</td>
			<td>Service port for Zpages</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zpages--nodePort"><a href="./values.yaml#L1138">otelCollector.ports.zpages.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Node port for Zpages</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--zpages--protocol"><a href="./values.yaml#L1140">otelCollector.ports.zpages.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"TCP"</code>
</div>
			</td>
			<td>Protocol to use for Zpages</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--pprof--enabled"><a href="./values.yaml#L1143">otelCollector.ports.pprof.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td>Whether to enable service port for pprof</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--pprof--containerPort"><a href="./values.yaml#L1145">otelCollector.ports.pprof.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>1777</code>
</div>
			</td>
			<td>Container port for pprof</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--pprof--servicePort"><a href="./values.yaml#L1147">otelCollector.ports.pprof.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>1777</code>
</div>
			</td>
			<td>Service port for pprof</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--pprof--nodePort"><a href="./values.yaml#L1149">otelCollector.ports.pprof.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Node port for pprof</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--pprof--protocol"><a href="./values.yaml#L1151">otelCollector.ports.pprof.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"TCP"</code>
</div>
			</td>
			<td>Protocol to use for pprof</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsheroku--enabled"><a href="./values.yaml#L1154">otelCollector.ports.logsheroku.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td>Whether to enable service port for logsheroku</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsheroku--containerPort"><a href="./values.yaml#L1156">otelCollector.ports.logsheroku.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>8081</code>
</div>
			</td>
			<td>Container port for logsheroku</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsheroku--servicePort"><a href="./values.yaml#L1158">otelCollector.ports.logsheroku.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>8081</code>
</div>
			</td>
			<td>Service port for logsheroku</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsheroku--nodePort"><a href="./values.yaml#L1160">otelCollector.ports.logsheroku.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Node port for logsheroku</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsheroku--protocol"><a href="./values.yaml#L1162">otelCollector.ports.logsheroku.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"TCP"</code>
</div>
			</td>
			<td>Protocol to use for logsheroku</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsjson--enabled"><a href="./values.yaml#L1165">otelCollector.ports.logsjson.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td>Whether to enable service port for logsjson</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsjson--containerPort"><a href="./values.yaml#L1167">otelCollector.ports.logsjson.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>8082</code>
</div>
			</td>
			<td>Container port for logsjson</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsjson--servicePort"><a href="./values.yaml#L1169">otelCollector.ports.logsjson.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>8082</code>
</div>
			</td>
			<td>Service port for logsjson</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsjson--nodePort"><a href="./values.yaml#L1171">otelCollector.ports.logsjson.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Node port for logsjson</td>
		</tr>
		<tr>
			<td id="otelCollector--ports--logsjson--protocol"><a href="./values.yaml#L1173">otelCollector.ports.logsjson.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"TCP"</code>
</div>
			</td>
			<td>Protocol to use for logsjson</td>
		</tr>
		<tr>
			<td id="otelCollector--livenessProbe"><a href="./values.yaml#L1176">otelCollector.livenessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{
  "enabled": true,
  "failureThreshold": 6,
  "initialDelaySeconds": 5,
  "path": "/",
  "periodSeconds": 10,
  "port": 13133,
  "successThreshold": 1,
  "timeoutSeconds": 5
}</code>
</div>
			</td>
			<td>Configure liveness and readiness probes. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes</td>
		</tr>
		<tr>
			<td id="otelCollector--readinessProbe--enabled"><a href="./values.yaml#L1186">otelCollector.readinessProbe.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>true</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--readinessProbe--port"><a href="./values.yaml#L1187">otelCollector.readinessProbe.port</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>13133</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--readinessProbe--path"><a href="./values.yaml#L1188">otelCollector.readinessProbe.path</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"/"</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--readinessProbe--initialDelaySeconds"><a href="./values.yaml#L1189">otelCollector.readinessProbe.initialDelaySeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>5</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--readinessProbe--periodSeconds"><a href="./values.yaml#L1190">otelCollector.readinessProbe.periodSeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>10</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--readinessProbe--timeoutSeconds"><a href="./values.yaml#L1191">otelCollector.readinessProbe.timeoutSeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>5</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--readinessProbe--failureThreshold"><a href="./values.yaml#L1192">otelCollector.readinessProbe.failureThreshold</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>6</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--readinessProbe--successThreshold"><a href="./values.yaml#L1193">otelCollector.readinessProbe.successThreshold</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>1</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--customLivenessProbe"><a href="./values.yaml#L1195">otelCollector.customLivenessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Custom liveness probe</td>
		</tr>
		<tr>
			<td id="otelCollector--customReadinessProbe"><a href="./values.yaml#L1197">otelCollector.customReadinessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Custom readiness probe</td>
		</tr>
		<tr>
			<td id="otelCollector--extraVolumeMounts"><a href="./values.yaml#L1199">otelCollector.extraVolumeMounts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Extra volumes mount for OtelCollector pod</td>
		</tr>
		<tr>
			<td id="otelCollector--extraVolumes"><a href="./values.yaml#L1201">otelCollector.extraVolumes</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Extra volumes for OtelCollector pod</td>
		</tr>
		<tr>
			<td id="otelCollector--ingress--enabled"><a href="./values.yaml#L1204">otelCollector.ingress.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td>Enable ingress for OtelCollector</td>
		</tr>
		<tr>
			<td id="otelCollector--ingress--className"><a href="./values.yaml#L1206">otelCollector.ingress.className</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>Ingress Class Name to be used to identify ingress controllers</td>
		</tr>
		<tr>
			<td id="otelCollector--ingress--annotations"><a href="./values.yaml#L1208">otelCollector.ingress.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Annotations to OtelCollector Ingress</td>
		</tr>
		<tr>
			<td id="otelCollector--ingress--hosts"><a href="./values.yaml#L1215">otelCollector.ingress.hosts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[
  {
    "host": "otelcollector.domain.com",
    "paths": [
      {
        "path": "/",
        "pathType": "ImplementationSpecific",
        "port": 4318
      }
    ]
  }
]</code>
</div>
			</td>
			<td>OtelCollector Ingress Host names with their path details</td>
		</tr>
		<tr>
			<td id="otelCollector--ingress--tls"><a href="./values.yaml#L1222">otelCollector.ingress.tls</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>OtelCollector Ingress TLS</td>
		</tr>
		<tr>
			<td id="otelCollector--resources"><a href="./values.yaml#L1231">otelCollector.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>Configure resource requests and limits. Update according to your own use case as these values might not be suitable for your workload. Ref: http://kubernetes.io/docs/user-guide/compute-resources/ </td>
		</tr>
		<tr>
			<td id="otelCollector--priorityClassName"><a href="./values.yaml#L1239">otelCollector.priorityClassName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>""</code>
</div>
			</td>
			<td>OtelCollector priority class name</td>
		</tr>
		<tr>
			<td id="otelCollector--nodeSelector"><a href="./values.yaml#L1241">otelCollector.nodeSelector</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Node selector for settings for OtelCollector pod</td>
		</tr>
		<tr>
			<td id="otelCollector--tolerations"><a href="./values.yaml#L1243">otelCollector.tolerations</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td>Toleration labels for OtelCollector pod assignment</td>
		</tr>
		<tr>
			<td id="otelCollector--affinity"><a href="./values.yaml#L1245">otelCollector.affinity</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td>Affinity settings for OtelCollector pod</td>
		</tr>
		<tr>
			<td id="otelCollector--topologySpreadConstraints"><a href="./values.yaml#L1247">otelCollector.topologySpreadConstraints</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[
  {
    "labelSelector": {
      "matchLabels": {
        "app.kubernetes.io/component": "otel-collector"
      }
    },
    "maxSkew": 1,
    "topologyKey": "kubernetes.io/hostname",
    "whenUnsatisfiable": "ScheduleAnyway"
  }
]</code>
</div>
			</td>
			<td>TopologySpreadConstraints describes how OtelCollector pods ought to spread</td>
		</tr>
		<tr>
			<td id="otelCollector--podSecurityContext"><a href="./values.yaml#L1254">otelCollector.podSecurityContext</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--securityContext"><a href="./values.yaml#L1257">otelCollector.securityContext</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--enabled"><a href="./values.yaml#L1266">otelCollector.autoscaling.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--minReplicas"><a href="./values.yaml#L1267">otelCollector.autoscaling.minReplicas</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>1</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--maxReplicas"><a href="./values.yaml#L1268">otelCollector.autoscaling.maxReplicas</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>11</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--targetCPUUtilizationPercentage"><a href="./values.yaml#L1269">otelCollector.autoscaling.targetCPUUtilizationPercentage</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>50</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--targetMemoryUtilizationPercentage"><a href="./values.yaml#L1270">otelCollector.autoscaling.targetMemoryUtilizationPercentage</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;"><code>50</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--behavior"><a href="./values.yaml#L1271">otelCollector.autoscaling.behavior</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>{}</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--autoscalingTemplate"><a href="./values.yaml#L1285">otelCollector.autoscaling.autoscalingTemplate</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--annotations"><a href="./values.yaml#L1287">otelCollector.autoscaling.keda.annotations</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--enabled"><a href="./values.yaml#L1288">otelCollector.autoscaling.keda.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--pollingInterval"><a href="./values.yaml#L1291">otelCollector.autoscaling.keda.pollingInterval</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"30"</code>
</div>
			</td>
			<td>Polling interval for metrics data Checks 30sec periodically for metrics data</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--cooldownPeriod"><a href="./values.yaml#L1294">otelCollector.autoscaling.keda.cooldownPeriod</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"300"</code>
</div>
			</td>
			<td>Cooldown period for metrics data Once the load decreased, it will wait for 5 min and downscale</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--minReplicaCount"><a href="./values.yaml#L1297">otelCollector.autoscaling.keda.minReplicaCount</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"1"</code>
</div>
			</td>
			<td>Minimum replica count Should be >= replicaCount specified in values.yaml</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--maxReplicaCount"><a href="./values.yaml#L1299">otelCollector.autoscaling.keda.maxReplicaCount</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;"><code>"5"</code>
</div>
			</td>
			<td>Maximum replica count</td>
		</tr>
		<tr>
			<td id="otelCollector--autoscaling--keda--triggers"><a href="./values.yaml#L1300">otelCollector.autoscaling.keda.triggers</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;"><code>[]</code>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelCollector--config"><a href="./values.yaml#L1311">otelCollector.config</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;"><code>null</code>
</div>
			</td>
			<td>Configurations for OtelCollector</td>
		</tr>
		<tr>
			<td id="signoz-otel-gateway--enabled"><a href="./values.yaml#L1403">signoz-otel-gateway.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;"><code>false</code>
</div>
			</td>
			<td></td>
		</tr>
	</tbody>
</table>

