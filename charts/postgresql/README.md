
# PostgreSQL
![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 15.0.0](https://img.shields.io/badge/AppVersion-15.0.0-informational?style=flat-square)

This Helm chart is installed as a subchart/dependency of the SigNoz Helm chart with default values.

### TL;DR;

```sh
helm repo add signoz https://charts.signoz.io
helm install -n platform --create-namespace "my-release" signoz/postgresql
```

### Introduction

SigNoz uses a relational database like SQLite, Postgres exclusively for storing metadata and control-plane information, such as organizations, users, dashboards, and configurations.

It does not replace ClickHouse, which remains necessary for storing and querying all observability telemetry data (traces, metrics, and logs).

Refer to the documentation for a more detailed explanation of [Relational Database in Signoz](https://signoz.io/docs/manage/administrator-guide/configuration/relational-database/)

### Prerequisites

- Kubernetes 1.16+
- Helm 3.0+

### Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm repo add signoz https://charts.signoz.io
helm -n platform --create-namespace install "my-release" signoz/postgresql
```

To uninstall/delete the `my-release` resources:

```bash
helm -n platform uninstall "my-release"
```

See the [Helm docs](https://helm.sh/docs/helm/helm_uninstall/) for documentation on the helm uninstall command.

## Values

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
		<td id="namespace"><a href="./values.yaml#L2">namespace</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Which namespace to install postgresql to (defaults to namespace chart is installed to)</td>
	</tr>
	<tr>
		<td id="nameOverride"><a href="./values.yaml#L4">nameOverride</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Name override for postgresql</td>
	</tr>
	<tr>
		<td id="fullnameOverride"><a href="./values.yaml#L6">fullnameOverride</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Fullname override for postgreql</td>
	</tr>
	<tr>
		<td id="replicaCount"><a href="./values.yaml#L10">replicaCount</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
		</td>
		<td>Number of Postgres replicas.</td>
	</tr>
	<tr>
		<td id="image--repository"><a href="./values.yaml#L15">image.repository</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">postgres</pre>
</div>
		</td>
		<td>Postgres image repository.</td>
	</tr>
	<tr>
		<td id="image--tag"><a href="./values.yaml#L18">image.tag</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">"15"</pre>
</div>
		</td>
		<td>Postgres image tag.</td>
	</tr>
	<tr>
		<td id="image--pullPolicy"><a href="./values.yaml#L21">image.pullPolicy</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
		</td>
		<td>Image pull policy.</td>
	</tr>
	<tr>
		<td id="imagePullSecrets"><a href="./values.yaml#L25">imagePullSecrets</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Image pull secrets for Postgres pods</td>
	</tr>
	<tr>
		<td id="service--annotations"><a href="./values.yaml#L30">service.annotations</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Annotations for the Postgres service object.</td>
	</tr>
	<tr>
		<td id="service--labels"><a href="./values.yaml#L33">service.labels</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Labels for the Postgres service object.</td>
	</tr>
	<tr>
		<td id="service--type"><a href="./values.yaml#L36">service.type</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
		</td>
		<td>The service type (`ClusterIP`, `NodePort`, `LoadBalancer`).</td>
	</tr>
	<tr>
		<td id="service--port"><a href="./values.yaml#L39">service.port</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">5432</pre>
</div>
		</td>
		<td>The external port for Postgres service</td>
	</tr>
	<tr>
		<td id="auth--username"><a href="./values.yaml#L44">auth.username</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">signoz</pre>
</div>
		</td>
		<td>Username for the custom user to create.</td>
	</tr>
	<tr>
		<td id="auth--password"><a href="./values.yaml#L47">auth.password</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">signoz@123</pre>
</div>
		</td>
		<td>Password for the custom user to create. Ignored if `auth.existingSecret` is provided.</td>
	</tr>
	<tr>
		<td id="auth--database"><a href="./values.yaml#L50">auth.database</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Name for a custom database to create.</td>
	</tr>
	<tr>
		<td id="auth--existingSecret"><a href="./values.yaml#L53">auth.existingSecret</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Name of existing secret to use for PostgreSQL credentials. `auth.password` will be ignored and picked up from this secret.</td>
	</tr>
	<tr>
		<td id="auth--secretKeys--userPasswordKey"><a href="./values.yaml#L57">auth.secretKeys.userPasswordKey</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">password</pre>
</div>
		</td>
		<td>Name of key in existing secret to use for PostgreSQL credentials. Only used when `auth.existingSecret` is set.</td>
	</tr>
	<tr>
		<td id="resources"><a href="./values.yaml#L61">resources</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Resource requests and limits for Postgres pods.</td>
	</tr>
	<tr>
		<td id="priorityClassName"><a href="./values.yaml#L65">priorityClassName</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Priority class name for Postgres pods.</td>
	</tr>
	<tr>
		<td id="podSecurityContext"><a href="./values.yaml#L69">podSecurityContext</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Security context for Postgres pods.</td>
	</tr>
	<tr>
		<td id="securityContext"><a href="./values.yaml#L73">securityContext</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Container security context for Postgres containers.</td>
	</tr>
	<tr>
		<td id="podAnnotations"><a href="./values.yaml#L77">podAnnotations</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Annotations for Postgres pods.</td>
	</tr>
	<tr>
		<td id="annotations"><a href="./values.yaml#L81">annotations</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Additional annotations for Postgres resources.</td>
	</tr>
	<tr>
		<td id="nodeSelector"><a href="./values.yaml#L85">nodeSelector</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Node selector for Postgres pods.</td>
	</tr>
	<tr>
		<td id="tolerations"><a href="./values.yaml#L89">tolerations</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Tolerations for Postgres pods.</td>
	</tr>
	<tr>
		<td id="affinity"><a href="./values.yaml#L93">affinity</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Affinity rules for Postgres pods.</td>
	</tr>
	<tr>
		<td id="topologySpreadConstraints"><a href="./values.yaml#L97">topologySpreadConstraints</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Topology spread constraints for Postgres pods.</td>
	</tr>
	<tr>
		<td id="livenessProbe--enabled"><a href="./values.yaml#L102">livenessProbe.enabled</a></td>
		<td>bool</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
		</td>
		<td>Enable liveness probe.</td>
	</tr>
	<tr>
		<td id="livenessProbe--initialDelaySeconds"><a href="./values.yaml#L105">livenessProbe.initialDelaySeconds</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">20</pre>
</div>
		</td>
		<td>Initial delay seconds for liveness probe.</td>
	</tr>
	<tr>
		<td id="livenessProbe--periodSeconds"><a href="./values.yaml#L108">livenessProbe.periodSeconds</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">10</pre>
</div>
		</td>
		<td>Period seconds for liveness probe.</td>
	</tr>
	<tr>
		<td id="livenessProbe--timeoutSeconds"><a href="./values.yaml#L111">livenessProbe.timeoutSeconds</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
		</td>
		<td>Timeout seconds for liveness probe.</td>
	</tr>
	<tr>
		<td id="livenessProbe--successThreshold"><a href="./values.yaml#L114">livenessProbe.successThreshold</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
		</td>
		<td>Success threshold for liveness probe.</td>
	</tr>
	<tr>
		<td id="livenessProbe--failureThreshold"><a href="./values.yaml#L117">livenessProbe.failureThreshold</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">6</pre>
</div>
		</td>
		<td>Failure threshold for liveness probe.</td>
	</tr>
	<tr>
		<td id="readinessProbe--enabled"><a href="./values.yaml#L122">readinessProbe.enabled</a></td>
		<td>bool</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
		</td>
		<td>Enable readiness probe.</td>
	</tr>
	<tr>
		<td id="readinessProbe--initialDelaySeconds"><a href="./values.yaml#L125">readinessProbe.initialDelaySeconds</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
		</td>
		<td>Initial delay seconds for readiness probe.</td>
	</tr>
	<tr>
		<td id="readinessProbe--periodSeconds"><a href="./values.yaml#L128">readinessProbe.periodSeconds</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
		</td>
		<td>Period seconds for readiness probe.</td>
	</tr>
	<tr>
		<td id="readinessProbe--timeoutSeconds"><a href="./values.yaml#L131">readinessProbe.timeoutSeconds</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">3</pre>
</div>
		</td>
		<td>Timeout seconds for readiness probe.</td>
	</tr>
	<tr>
		<td id="readinessProbe--successThreshold"><a href="./values.yaml#L134">readinessProbe.successThreshold</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
		</td>
		<td>Success threshold for readiness probe.</td>
	</tr>
	<tr>
		<td id="readinessProbe--failureThreshold"><a href="./values.yaml#L137">readinessProbe.failureThreshold</a></td>
		<td>int</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">6</pre>
</div>
		</td>
		<td>Failure threshold for readiness probe.</td>
	</tr>
	<tr>
		<td id="persistence--enabled"><a href="./values.yaml#L142">persistence.enabled</a></td>
		<td>bool</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
		</td>
		<td>Enable persistent storage for Postgres.</td>
	</tr>
	<tr>
		<td id="persistence--existingClaim"><a href="./values.yaml#L145">persistence.existingClaim</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Use an existing PVC for Postgres data.</td>
	</tr>
	<tr>
		<td id="persistence--size"><a href="./values.yaml#L148">persistence.size</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">10Gi</pre>
</div>
		</td>
		<td>Size of the persistent volume claim.</td>
	</tr>
	<tr>
		<td id="persistence--storageClass"><a href="./values.yaml#L151">persistence.storageClass</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
		</td>
		<td>Storage class for the persistent volume claim.</td>
	</tr>
	<tr>
		<td id="persistence--accessModes"><a href="./values.yaml#L154">persistence.accessModes</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">- ReadWriteOnce</pre>
</div>
		</td>
		<td>Access modes for the persistent volume claim.</td>
	</tr>
	<tr>
		<td id="persistence--mountPath"><a href="./values.yaml#L158">persistence.mountPath</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">/signoz/postgresql</pre>
</div>
		</td>
		<td>Mount path for Postgres data.</td>
	</tr>
	<tr>
		<td id="persistence--subPath"><a href="./values.yaml#L161">persistence.subPath</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
		</td>
		<td>Subpath within the volume for Postgres data.</td>
	</tr>
	<tr>
		<td id="persistence--dataDir"><a href="./values.yaml#L164">persistence.dataDir</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">/signoz/postgresql/data</pre>
</div>
		</td>
		<td>Data directory for Postgres data.</td>
	</tr>
	<tr>
		<td id="additionalArgs"><a href="./values.yaml#L168">additionalArgs</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Additional command-line arguments for Postgres containers.</td>
	</tr>
	<tr>
		<td id="additionalVolumes"><a href="./values.yaml#L172">additionalVolumes</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Additional volumes for Postgres pods.</td>
	</tr>
	<tr>
		<td id="additionalVolumeMounts"><a href="./values.yaml#L176">additionalVolumeMounts</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Additional volume mounts for Postgres containers.</td>
	</tr>
	<tr>
		<td id="extraEnv"><a href="./values.yaml#L180">extraEnv</a></td>
		<td>list</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
		</td>
		<td>Extra environment variables for Postgres containers.</td>
	</tr>
	<tr>
		<td id="serviceAccount--create"><a href="./values.yaml#L185">serviceAccount.create</a></td>
		<td>bool</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
		</td>
		<td>Specifies whether a service account should be created.</td>
	</tr>
	<tr>
		<td id="serviceAccount--annotations"><a href="./values.yaml#L188">serviceAccount.annotations</a></td>
		<td>object</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
		</td>
		<td>Annotations to add to the service account.</td>
	</tr>
	<tr>
		<td id="serviceAccount--name"><a href="./values.yaml#L191">serviceAccount.name</a></td>
		<td>string</td>
		<td>
			<div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
		</td>
		<td>The name of the service account to use. If not set and `create` is true, a name is generated.</td>
	</tr>
	</tbody>
</table>

