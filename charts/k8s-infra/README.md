
# K8s-Infra

![Version: 0.14.0](https://img.shields.io/badge/Version-0.14.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.109.0](https://img.shields.io/badge/AppVersion-0.109.0-informational?style=flat-square)

Monitoring your Kubernetes cluster is essential for ensuring performance, stability, and reliability. The SigNoz k8s-infra Helm chart provides a comprehensive solution for collecting and analyzing metrics, logs, and events from your entire Kubernetes environment.

### TL;DR;

```sh
helm repo add signoz https://charts.signoz.io
helm install -n platform --create-namespace "my-release" signoz/k8s-infra
```

### Introduction

The `k8s-infra` chart provides Kubernetes infrastructure observability by deploying OpenTelemetry components and related resources using the [Helm](https://helm.sh) package manager.

It enables collection of metrics, logs, and events from your Kubernetes cluster, making it easier to monitor and troubleshoot your infrastructure with SigNoz.

Refer to the documentation for a more detailed explanation of [k8s-infra](https://signoz.io/docs/collection-agents/k8s/k8s-infra/overview/)
### Prerequisites

- Kubernetes 1.16+
- Helm 3.0+

### Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm repo add signoz https://charts.signoz.io
helm -n platform --create-namespace install "my-release" signoz/k8s-infra
```

These commands deploy K8s-infra on the Kubernetes cluster in the default configuration.
The [Configuration](#configuration) section lists the parameters that can be configured during installation:

>[!NOTE]
> ### Installing K8s-Infra on Windows
> Follow these steps to configure k8s-infra for Windows environments.
>
> #### Use OpenTelemetry Collector Contrib for Windows
>
> OpenTelemetry provides Windows-compatible [opentelemetry-collector-contrib](https://hub.docker.com/r/otel/opentelemetry-collector-contrib/tags?name=windows) container images which can be used for k8s-infra. You must specify the Windows image tags in your Helm values configuration.
>
> Add the following configuration to your Helm values file:
>
> ```yaml
> otelAgent:
>   image:
>     tag: 0.123.0-windows-2022-amd64
>
> otelDeployment:
>   image:
>     tag: 0.123.0-windows-2022-amd64
> ```
>
> #### Remove Root Path for Host Metrics
>
> The host metrics receiver requires configuring the `root_path` when using the host receiver for Linux in containers. However, Windows deployments do not require this configuration and the k8s-infra installation may fail if included. Remove the path from the `root_path` key under `presets.hostMetrics` in your Helm values:
>
> ```yaml
> presets:
>   hostMetrics:
>     root_path: ""
> ```
>
> After completing these steps, you can proceed with the [standard k8s-infra installation](https://github.com/SigNoz/charts/tree/main/charts/k8s-infra#installing-the-chart).

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
>
> #### Version 0.14.1
>
> **Configuration Migration Required:**
> - `presets.loggingExporter` has been deprecated and must be migrated to `presets.debugExporter`.
>
> This change aligns with OpenTelemetry's deprecation of the [logging exporter](https://github.com/open-telemetry/opentelemetry-collector/tree/v0.110.0/exporter/loggingexporter) in favor of the [debug exporter](https://github.com/open-telemetry/opentelemetry-collector/blob/v0.110.0/exporter/debugexporter/README.md).
>
> **Migration Example:**
>
> Replace this configuration:
> ```yaml
> presets:
>   loggingExporter: 
>     enabled: true
>     verbosity: basic
>     samplingInitial: 2
>     samplingThereafter: 500
> ```
>
> With this configuration:
> ```yaml
> presets:
>   debugExporter: 
>     enabled: true
>     verbosity: basic
>     samplingInitial: 2
>     samplingThereafter: 500
> ```

## Values

<h3>Global Configuration</h3>
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
deploymentEnvironment: ""
imagePullSecrets: []
imageRegistry: null
storageClass: null</pre>
</div>
            </td>
            <td>Global override values.</td>
        </tr>
        <tr>
            <td id="global--imageRegistry"><a href="./values.yaml#L6">global.imageRegistry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Overrides the Docker registry globally for all images.</td>
        </tr>
        <tr>
            <td id="global--imagePullSecrets"><a href="./values.yaml#L9">global.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Global Image Pull Secrets.</td>
        </tr>
        <tr>
            <td id="global--storageClass"><a href="./values.yaml#L12">global.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Overrides the storage class for all PVCs with persistence enabled.</td>
        </tr>
        <tr>
            <td id="global--clusterDomain"><a href="./values.yaml#L15">global.clusterDomain</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">cluster.local</pre>
</div>
            </td>
            <td>Kubernetes cluster domain. Used only when components are installed in different namespaces.</td>
        </tr>
        <tr>
            <td id="global--clusterName"><a href="./values.yaml#L18">global.clusterName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Kubernetes cluster name. Used to attach to telemetry data via the resource detection processor.</td>
        </tr>
        <tr>
            <td id="global--deploymentEnvironment"><a href="./values.yaml#L21">global.deploymentEnvironment</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Deployment environment to be attached to telemetry data.</td>
        </tr>
        <tr>
            <td id="global--cloud"><a href="./values.yaml#L24">global.cloud</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">other</pre>
</div>
            </td>
            <td>Kubernetes cluster cloud provider, along with distribution if any (e.g., `aws`, `azure`, `gcp`, `gcp/autogke`, `other`).</td>
        </tr>
    </tbody>
</table>
<h3>General Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="nameOverride"><a href="./values.yaml#L28">nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>K8s infra chart name override.</td>
        </tr>
        <tr>
            <td id="fullnameOverride"><a href="./values.yaml#L32">fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>K8s infra chart full name override.</td>
        </tr>
        <tr>
            <td id="enabled"><a href="./values.yaml#L36">enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to enable the K8s infra chart.</td>
        </tr>
        <tr>
            <td id="clusterName"><a href="./values.yaml#L40">clusterName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the K8s cluster. Used by OtelCollectors to attach in telemetry data.</td>
        </tr>
        <tr>
            <td id="otelCollectorEndpoint"><a href="./values.yaml#L47">otelCollectorEndpoint</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Endpoint/IP Address of the SigNoz or any other OpenTelemetry backend. Set it to `ingest.signoz.io:4317` for SigNoz Cloud. If set to null and the chart is installed as a dependency, it will attempt to autogenerate the endpoint of the SigNoz OtelCollector.</td>
        </tr>
        <tr>
            <td id="otelInsecure"><a href="./values.yaml#L52">otelInsecure</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether the OTLP endpoint is insecure. Set this to false in case of a secure OTLP endpoint.</td>
        </tr>
        <tr>
            <td id="insecureSkipVerify"><a href="./values.yaml#L56">insecureSkipVerify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to skip verifying the OTLP endpoint's certificate.</td>
        </tr>
        <tr>
            <td id="namespace"><a href="./values.yaml#L100">namespace</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>The namespace to install k8s-infra components into.</td>
        </tr>
    </tbody>
</table>
<h3>API Key Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="signozApiKey"><a href="./values.yaml#L60">signozApiKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>API key for SigNoz Cloud.</td>
        </tr>
        <tr>
            <td id="apiKeyExistingSecretName"><a href="./values.yaml#L63">apiKeyExistingSecretName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Existing secret name to be used for the API key.</td>
        </tr>
        <tr>
            <td id="apiKeyExistingSecretKey"><a href="./values.yaml#L66">apiKeyExistingSecretKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Existing secret key to be used for the API key.</td>
        </tr>
    </tbody>
</table>
<h3>OTLP Receiver TLS Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="otelTlsSecrets--enabled"><a href="./values.yaml#L72">otelTlsSecrets.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to enable OpenTelemetry OTLP secrets for secure communication.</td>
        </tr>
        <tr>
            <td id="otelTlsSecrets--path"><a href="./values.yaml#L76">otelTlsSecrets.path</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">/secrets</pre>
</div>
            </td>
            <td>Path for the secrets volume when mounted in the container.</td>
        </tr>
        <tr>
            <td id="otelTlsSecrets--existingSecretName"><a href="./values.yaml#L81">otelTlsSecrets.existingSecretName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Name of an existing secret with TLS certificate, key, and CA to be used. Files in the secret must be named `cert.pem`, `key.pem`, and `ca.pem`.</td>
        </tr>
        <tr>
            <td id="otelTlsSecrets--certificate"><a href="./values.yaml#L85">otelTlsSecrets.certificate</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">|
    <INCLUDE_CERTIFICATE_HERE></pre>
</div>
            </td>
            <td>TLS certificate to be included in the secret.</td>
        </tr>
        <tr>
            <td id="otelTlsSecrets--key"><a href="./values.yaml#L90">otelTlsSecrets.key</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">|
    <INCLUDE_PRIVATE_KEY_HERE></pre>
</div>
            </td>
            <td>TLS private key to be included in the secret.</td>
        </tr>
        <tr>
            <td id="otelTlsSecrets--ca"><a href="./values.yaml#L95">otelTlsSecrets.ca</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>TLS certificate authority (CA) certificate to be included in the secret.</td>
        </tr>
    </tbody>
</table><h3>Presets Configuration</h3>
  <p>Presets to easily set up OtelCollector configurations. For more details, see the <a href="https://signoz.io/docs/collection-agents/k8s/k8s-infra/configure-k8s-infra/">documentation</a>.</p>
<h4>Debug Exporter Presets</h4>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="presets--debugExporter"><a href="./values.yaml#L110">presets.debugExporter</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false
samplingInitial: 2
samplingThereafter: 500
verbosity: basic</pre>
</div>
            </td>
            <td>Configuration for the debug exporter, used for debugging telemetry data.</td>
        </tr>
        <tr>
            <td id="presets--debugExporter--enabled"><a href="./values.yaml#L113">presets.debugExporter.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable the debug exporter.</td>
        </tr>
        <tr>
            <td id="presets--debugExporter--verbosity"><a href="./values.yaml#L116">presets.debugExporter.verbosity</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">basic</pre>
</div>
            </td>
            <td>Verbosity of the debug exporter: `basic`, `normal`, or `detailed`.</td>
        </tr>
        <tr>
            <td id="presets--debugExporter--samplingInitial"><a href="./values.yaml#L119">presets.debugExporter.samplingInitial</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">2</pre>
</div>
            </td>
            <td>Number of messages initially logged each second.</td>
        </tr>
        <tr>
            <td id="presets--debugExporter--samplingThereafter"><a href="./values.yaml#L122">presets.debugExporter.samplingThereafter</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">500</pre>
</div>
            </td>
            <td>Sampling rate after the initial messages are logged.</td>
        </tr>
    </tbody>
</table>
<h4>OTLP Exporter Presets</h4>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="presets--otlpExporter"><a href="./values.yaml#L125">presets.otlpExporter</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: true</pre>
</div>
            </td>
            <td>OTLP Exporter for the OTLP exporter.</td>
        </tr>
        <tr>
            <td id="presets--otlphttpExporter"><a href="./values.yaml#L132">presets.otlphttpExporter</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>OTLP HTTP Exporter to which data will be sent. Set this to true to enable the OTLP HTTP exporter, which uses the HTTP endpoint instead of the gRPC endpoint.</td>
        </tr>
    </tbody>
</table>
<h4>Self Telemetry Presets</h4>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="presets--selfTelemetry"><a href="./values.yaml#L138">presets.selfTelemetry</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">apiKeyExistingSecretKey: ""
apiKeyExistingSecretName: ""
endpoint: ""
insecure: true
insecureSkipVerify: true
logs:
    enabled: false
metrics:
    enabled: false
signozApiKey: ""
traces:
    enabled: false</pre>
</div>
            </td>
            <td>Configuration for sending the collector's own telemetry data.</td>
        </tr>
        <tr>
            <td id="presets--selfTelemetry--endpoint"><a href="./values.yaml#L141">presets.selfTelemetry.endpoint</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>OTLP HTTP endpoint to send own telemetry data to.</td>
        </tr>
        <tr>
            <td id="presets--selfTelemetry--traces--enabled"><a href="./values.yaml#L162">presets.selfTelemetry.traces.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable self-telemetry for traces.</td>
        </tr>
        <tr>
            <td id="presets--selfTelemetry--metrics--enabled"><a href="./values.yaml#L168">presets.selfTelemetry.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable self-telemetry for metrics.</td>
        </tr>
        <tr>
            <td id="presets--selfTelemetry--logs"><a href="./values.yaml#L171">presets.selfTelemetry.logs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: false</pre>
</div>
            </td>
            <td>Configuration for self-telemetry logs.</td>
        </tr>
        <tr>
            <td id="presets--selfTelemetry--logs--enabled"><a href="./values.yaml#L174">presets.selfTelemetry.logs.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable self-telemetry for logs.</td>
        </tr>
    </tbody>
</table>
<h4>Logs Collection Presets</h4>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="presets--logsCollection"><a href="./values.yaml#L178">presets.logsCollection</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please check out the values.yml for default values</pre>
</div>
            </td>
            <td>Configuration for collecting logs from pods.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--enabled"><a href="./values.yaml#L181">presets.logsCollection.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable log collection.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--startAt"><a href="./values.yaml#L184">presets.logsCollection.startAt</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">end</pre>
</div>
            </td>
            <td>Where to start reading logs from: `end` or `beginning`.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--includeFilePath"><a href="./values.yaml#L187">presets.logsCollection.includeFilePath</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Include the log file path as an attribute.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--includeFileName"><a href="./values.yaml#L190">presets.logsCollection.includeFileName</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Include the log file name as an attribute.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--include"><a href="./values.yaml#L193">presets.logsCollection.include</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- /var/log/pods/*/*/*.log</pre>
</div>
            </td>
            <td>Include path patterns for log files to be collected. By default, all container logs are collected.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--blacklist"><a href="./values.yaml#L197">presets.logsCollection.blacklist</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">additionalExclude: []
containers: []
enabled: true
namespaces:
    - kube-system
pods:
    - hotrod
    - locust
signozLogs: true</pre>
</div>
            </td>
            <td>Exclude certain log files from being collected.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--whitelist"><a href="./values.yaml#L221">presets.logsCollection.whitelist</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">additionalInclude: []
containers: []
enabled: false
namespaces: []
pods: []
signozLogs: true</pre>
</div>
            </td>
            <td>Whitelist certain log files to be collected. If enabled, `include` is ignored.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--operators"><a href="./values.yaml#L242">presets.logsCollection.operators</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- id: container-parser
  type: container</pre>
</div>
            </td>
            <td>A list of log processing operators.</td>
        </tr>
    </tbody>
</table>
<h4>Host Metrics Presets</h4>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="presets--hostMetrics"><a href="./values.yaml#L248">presets.hostMetrics</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please check out the values.yml for default values</pre>
</div>
            </td>
            <td>Configuration for collecting host-level metrics from nodes.</td>
        </tr>
        <tr>
            <td id="presets--hostMetrics--enabled"><a href="./values.yaml#L251">presets.hostMetrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable host metrics collection.</td>
        </tr>
        <tr>
            <td id="presets--hostMetrics--rootPath"><a href="./values.yaml#L255">presets.hostMetrics.rootPath</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">/hostfs</pre>
</div>
            </td>
            <td>Root path for host metrics collection (Linux only).</td>
        </tr>
        <tr>
            <td id="presets--hostMetrics--collectionInterval"><a href="./values.yaml#L258">presets.hostMetrics.collectionInterval</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">30s</pre>
</div>
            </td>
            <td>Frequency at which to scrape host metrics.</td>
        </tr>
        <tr>
            <td id="presets--hostMetrics--scrapers"><a href="./values.yaml#L262">presets.hostMetrics.scrapers</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please check out the values.yml for default values</pre>
</div>
            </td>
            <td>Fine-grained control over which host metric scrapers are enabled.</td>
        </tr>
        <tr>
            <td id="presets--hostMetrics--scrapers--cpu"><a href="./values.yaml#L265">presets.hostMetrics.scrapers.cpu</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Enable CPU metrics collection.</td>
        </tr>
        <tr>
            <td id="presets--hostMetrics--scrapers--load"><a href="./values.yaml#L268">presets.hostMetrics.scrapers.load</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Enable load metrics collection.</td>
        </tr>
        <tr>
            <td id="presets--hostMetrics--scrapers--memory"><a href="./values.yaml#L271">presets.hostMetrics.scrapers.memory</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Enable memory metrics collection.</td>
        </tr>
        <tr>
            <td id="presets--hostMetrics--scrapers--disk"><a href="./values.yaml#L274">presets.hostMetrics.scrapers.disk</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">exclude:
    devices:
        - ^ram\d+$
        - ^zram\d+$
        - ^loop\d+$
        - ^fd\d+$
        - ^hd[a-z]\d+$
        - ^sd[a-z]\d+$
        - ^vd[a-z]\d+$
        - ^xvd[a-z]\d+$
        - ^nvme\d+n\d+p\d+$
    match_type: regexp</pre>
</div>
            </td>
            <td>Enable disk metrics collection.</td>
        </tr>
        <tr>
            <td id="presets--hostMetrics--scrapers--network"><a href="./values.yaml#L330">presets.hostMetrics.scrapers.network</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">exclude:
    interfaces:
        - ^veth.*$
        - ^docker.*$
        - ^br-.*$
        - ^flannel.*$
        - ^cali.*$
        - ^cbr.*$
        - ^cni.*$
        - ^dummy.*$
        - ^tailscale.*$
        - ^lo$
    match_type: regexp</pre>
</div>
            </td>
            <td>Enable network metrics collection.</td>
        </tr>
    </tbody>
</table>
<h4>Kubelet Metrics Presets</h4>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="presets--kubeletMetrics"><a href="./values.yaml#L347">presets.kubeletMetrics</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please check out the values.yml for default values</pre>
</div>
            </td>
            <td>Configuration for collecting metrics from Kubelet.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--enabled"><a href="./values.yaml#L350">presets.kubeletMetrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable Kubelet metrics collection.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--collectionInterval"><a href="./values.yaml#L353">presets.kubeletMetrics.collectionInterval</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">30s</pre>
</div>
            </td>
            <td>Frequency at which to scrape Kubelet metrics.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--authType"><a href="./values.yaml#L356">presets.kubeletMetrics.authType</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">serviceAccount</pre>
</div>
            </td>
            <td>Authentication type to use with Kubelet: `serviceAccount` or `tls`.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--endpoint"><a href="./values.yaml#L359">presets.kubeletMetrics.endpoint</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">${env:K8S_HOST_IP}:10250</pre>
</div>
            </td>
            <td>Kubelet endpoint.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--insecureSkipVerify"><a href="./values.yaml#L362">presets.kubeletMetrics.insecureSkipVerify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Skip verifying Kubelet's certificate.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--extraMetadataLabels"><a href="./values.yaml#L365">presets.kubeletMetrics.extraMetadataLabels</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- container.id
- k8s.volume.type</pre>
</div>
            </td>
            <td>List of extra metadata labels to collect.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--metricGroups"><a href="./values.yaml#L370">presets.kubeletMetrics.metricGroups</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- container
- pod
- node
- volume</pre>
</div>
            </td>
            <td>Groups of metrics to collect from Kubelet.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--metrics"><a href="./values.yaml#L377">presets.kubeletMetrics.metrics</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">container.cpu.usage:
    enabled: true
container.uptime:
    enabled: true
k8s.container.cpu_limit_utilization:
    enabled: true
k8s.container.cpu_request_utilization:
    enabled: true
k8s.container.memory_limit_utilization:
    enabled: true
k8s.container.memory_request_utilization:
    enabled: true
k8s.node.cpu.usage:
    enabled: true
k8s.node.uptime:
    enabled: true
k8s.pod.cpu.usage:
    enabled: true
k8s.pod.cpu_limit_utilization:
    enabled: true
k8s.pod.cpu_request_utilization:
    enabled: true
k8s.pod.memory_limit_utilization:
    enabled: true
k8s.pod.memory_request_utilization:
    enabled: true
k8s.pod.uptime:
    enabled: true</pre>
</div>
            </td>
            <td>Fine-grained control over which Kubelet metrics are enabled.</td>
        </tr>
    </tbody>
</table>
<h4>Kubernetes Attributes Processor Presets</h4>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="presets--kubernetesAttributes"><a href="./values.yaml#L409">presets.kubernetesAttributes</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please check out the values.yml for default values</pre>
</div>
            </td>
            <td>Processor for adding Kubernetes attributes to telemetry data.</td>
        </tr>
        <tr>
            <td id="presets--kubernetesAttributes--enabled"><a href="./values.yaml#L412">presets.kubernetesAttributes.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the Kubernetes attributes processor.</td>
        </tr>
        <tr>
            <td id="presets--kubernetesAttributes--passthrough"><a href="./values.yaml#L415">presets.kubernetesAttributes.passthrough</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>If true, agents will not make k8s API calls, do discovery, or extract metadata.</td>
        </tr>
        <tr>
            <td id="presets--kubernetesAttributes--filter"><a href="./values.yaml#L418">presets.kubernetesAttributes.filter</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">node_from_env_var: K8S_NODE_NAME</pre>
</div>
            </td>
            <td>Limit agents to query pods based on specific selectors to reduce resource usage.</td>
        </tr>
        <tr>
            <td id="presets--kubernetesAttributes--filter--node_from_env_var"><a href="./values.yaml#L421">presets.kubernetesAttributes.filter.node_from_env_var</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">K8S_NODE_NAME</pre>
</div>
            </td>
            <td>Restrict each agent to query pods on the same node.</td>
        </tr>
        <tr>
            <td id="presets--kubernetesAttributes--podAssociation"><a href="./values.yaml#L424">presets.kubernetesAttributes.podAssociation</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- sources:
    - from: resource_attribute
      name: k8s.pod.ip
- sources:
    - from: resource_attribute
      name: k8s.pod.uid
- sources:
    - from: connection</pre>
</div>
            </td>
            <td>Rules for tagging telemetry with pod metadata.</td>
        </tr>
        <tr>
            <td id="presets--kubernetesAttributes--extractMetadatas"><a href="./values.yaml#L435">presets.kubernetesAttributes.extractMetadatas</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- k8s.namespace.name
- k8s.deployment.name
- k8s.statefulset.name
- k8s.daemonset.name
- k8s.cronjob.name
- k8s.job.name
- k8s.node.name
- k8s.node.uid
- k8s.pod.name
- k8s.pod.uid
- k8s.pod.start_time</pre>
</div>
            </td>
            <td>Pod/namespace metadata to extract from a list of default metadata fields.</td>
        </tr>
        <tr>
            <td id="presets--kubernetesAttributes--extractLabels"><a href="./values.yaml#L449">presets.kubernetesAttributes.extractLabels</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Pod labels to extract as attributes.</td>
        </tr>
        <tr>
            <td id="presets--kubernetesAttributes--extractAnnotations"><a href="./values.yaml#L452">presets.kubernetesAttributes.extractAnnotations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Pod annotations to extract as attributes.</td>
        </tr>
    </tbody>
</table>
<h4>Cluster Metrics Presets</h4>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="presets--clusterMetrics"><a href="./values.yaml#L456">presets.clusterMetrics</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please check out the values.yml for default values</pre>
</div>
            </td>
            <td>Configuration for collecting cluster-level metrics.</td>
        </tr>
        <tr>
            <td id="presets--clusterMetrics--enabled"><a href="./values.yaml#L459">presets.clusterMetrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable cluster metrics collection.</td>
        </tr>
        <tr>
            <td id="presets--clusterMetrics--collectionInterval"><a href="./values.yaml#L462">presets.clusterMetrics.collectionInterval</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">30s</pre>
</div>
            </td>
            <td>Frequency at which to scrape cluster metrics.</td>
        </tr>
        <tr>
            <td id="presets--clusterMetrics--resourceAttributes"><a href="./values.yaml#L465">presets.clusterMetrics.resourceAttributes</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">container.runtime:
    enabled: true
container.runtime.version:
    enabled: true
k8s.container.status.last_terminated_reason:
    enabled: true
k8s.kubelet.version:
    enabled: true
k8s.pod.qos_class:
    enabled: true</pre>
</div>
            </td>
            <td>Resource attributes to report.</td>
        </tr>
        <tr>
            <td id="presets--clusterMetrics--nodeConditionsToReport"><a href="./values.yaml#L478">presets.clusterMetrics.nodeConditionsToReport</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- Ready
- MemoryPressure
- DiskPressure
- PIDPressure
- NetworkUnavailable</pre>
</div>
            </td>
            <td>Node conditions to report as metrics.</td>
        </tr>
        <tr>
            <td id="presets--clusterMetrics--allocatableTypesToReport"><a href="./values.yaml#L486">presets.clusterMetrics.allocatableTypesToReport</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- cpu
- memory</pre>
</div>
            </td>
            <td>Allocatable resource types to report.</td>
        </tr>
        <tr>
            <td id="presets--clusterMetrics--metrics"><a href="./values.yaml#L493">presets.clusterMetrics.metrics</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">k8s.node.condition:
    enabled: true
k8s.pod.status_reason:
    enabled: true</pre>
</div>
            </td>
            <td>Fine-grained control over which cluster metrics are enabled.</td>
        </tr>
    </tbody>
</table>
<h4>Prometheus Metrics Presets</h4>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="presets--prometheus"><a href="./values.yaml#L500">presets.prometheus</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotationsPrefix: signoz.io
enabled: false
includeContainerName: false
includePodLabel: false
namespaceScoped: false
namespaces: []
scrapeInterval: 60s</pre>
</div>
            </td>
            <td>Configuration for scraping Prometheus metrics from pod annotations.</td>
        </tr>
        <tr>
            <td id="presets--prometheus--enabled"><a href="./values.yaml#L503">presets.prometheus.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable Prometheus metrics scraping.</td>
        </tr>
        <tr>
            <td id="presets--prometheus--annotationsPrefix"><a href="./values.yaml#L506">presets.prometheus.annotationsPrefix</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz.io</pre>
</div>
            </td>
            <td>Prefix for the pod annotations used for metrics scraping (e.g., `signoz.io`).</td>
        </tr>
        <tr>
            <td id="presets--prometheus--scrapeInterval"><a href="./values.yaml#L509">presets.prometheus.scrapeInterval</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">60s</pre>
</div>
            </td>
            <td>How often to scrape metrics.</td>
        </tr>
        <tr>
            <td id="presets--prometheus--namespaceScoped"><a href="./values.yaml#L512">presets.prometheus.namespaceScoped</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Only scrape metrics from pods in the same namespace.</td>
        </tr>
        <tr>
            <td id="presets--prometheus--namespaces"><a href="./values.yaml#L515">presets.prometheus.namespaces</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>If set, only scrape metrics from pods in the specified namespaces.</td>
        </tr>
        <tr>
            <td id="presets--prometheus--includePodLabel"><a href="./values.yaml#L518">presets.prometheus.includePodLabel</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Include all pod labels in the metrics (can cause high cardinality).</td>
        </tr>
        <tr>
            <td id="presets--prometheus--includeContainerName"><a href="./values.yaml#L521">presets.prometheus.includeContainerName</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Include container name in metrics (not recommended for multi-container pods).</td>
        </tr>
    </tbody>
</table>
<h4>Resource Detection Processor Presets</h4>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="presets--resourceDetection"><a href="./values.yaml#L524">presets.resourceDetection</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: true
envResourceAttributes: ""
override: false
timeout: 2s</pre>
</div>
            </td>
            <td>Processor for detecting resource information from the environment (e.g., cloud provider, k8s).</td>
        </tr>
        <tr>
            <td id="presets--resourceDetection--enabled"><a href="./values.yaml#L527">presets.resourceDetection.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the resource detection processor.</td>
        </tr>
        <tr>
            <td id="presets--resourceDetection--timeout"><a href="./values.yaml#L530">presets.resourceDetection.timeout</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">2s</pre>
</div>
            </td>
            <td>Timeout for resource detection.</td>
        </tr>
        <tr>
            <td id="presets--resourceDetection--override"><a href="./values.yaml#L533">presets.resourceDetection.override</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Whether to override existing resource attributes.</td>
        </tr>
        <tr>
            <td id="presets--resourceDetection--envResourceAttributes"><a href="./values.yaml#L536">presets.resourceDetection.envResourceAttributes</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Additional resource attributes from environment variables.</td>
        </tr>
    </tbody>
</table>
<h4>Kubernetes Events Collection Presets</h4>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="presets--k8sEvents"><a href="./values.yaml#L539">presets.k8sEvents</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">authType: serviceAccount
enabled: true
namespaces: []</pre>
</div>
            </td>
            <td>Configuration for collecting Kubernetes events as logs.</td>
        </tr>
        <tr>
            <td id="presets--k8sEvents--enabled"><a href="./values.yaml#L542">presets.k8sEvents.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable Kubernetes events collection.</td>
        </tr>
        <tr>
            <td id="presets--k8sEvents--authType"><a href="./values.yaml#L545">presets.k8sEvents.authType</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">serviceAccount</pre>
</div>
            </td>
            <td>Authentication type: `serviceAccount` or `kubeconfig`.</td>
        </tr>
        <tr>
            <td id="presets--k8sEvents--namespaces"><a href="./values.yaml#L548">presets.k8sEvents.namespaces</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>List of namespaces to watch for events. Empty list means all namespaces.</td>
        </tr>
    </tbody>
</table>
<h3>OpenTelemetry Agent (DaemonSet)</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="otelAgent--enabled"><a href="./values.yaml#L555">otelAgent.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the OtelAgent DaemonSet.</td>
        </tr>
        <tr>
            <td id="otelAgent--name"><a href="./values.yaml#L558">otelAgent.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">otel-agent</pre>
</div>
            </td>
            <td>Name of the OtelAgent DaemonSet.</td>
        </tr>
        <tr>
            <td id="otelAgent--image"><a href="./values.yaml#L561">otelAgent.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">pullPolicy: IfNotPresent
registry: docker.io
repository: otel/opentelemetry-collector-contrib
tag: 0.109.0</pre>
</div>
            </td>
            <td>Image configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--image--registry"><a href="./values.yaml#L564">otelAgent.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">docker.io</pre>
</div>
            </td>
            <td>Docker registry for the OtelAgent image.</td>
        </tr>
        <tr>
            <td id="otelAgent--image--repository"><a href="./values.yaml#L567">otelAgent.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">otel/opentelemetry-collector-contrib</pre>
</div>
            </td>
            <td>Repository for the OtelAgent image.</td>
        </tr>
        <tr>
            <td id="otelAgent--image--tag"><a href="./values.yaml#L571">otelAgent.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">0.109.0</pre>
</div>
            </td>
            <td>Tag for the OtelAgent image. In case of your Host OS is windows, use the `0.123.0-windows-2022-amd64` tag.</td>
        </tr>
        <tr>
            <td id="otelAgent--image--pullPolicy"><a href="./values.yaml#L574">otelAgent.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Image pull policy for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--imagePullSecrets"><a href="./values.yaml#L578">otelAgent.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image Pull Secrets for the OtelAgent. Merged with `global.imagePullSecrets`.</td>
        </tr>
        <tr>
            <td id="otelAgent--command"><a href="./values.yaml#L583">otelAgent.command</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">extraArgs: []
name: /otelcol-contrib</pre>
</div>
            </td>
            <td>Command and arguments for the OtelAgent container.</td>
        </tr>
        <tr>
            <td id="otelAgent--command--name"><a href="./values.yaml#L586">otelAgent.command.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">/otelcol-contrib</pre>
</div>
            </td>
            <td>OtelAgent command name.</td>
        </tr>
        <tr>
            <td id="otelAgent--command--extraArgs"><a href="./values.yaml#L589">otelAgent.command.extraArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra arguments for the OtelAgent command.</td>
        </tr>
        <tr>
            <td id="otelAgent--configMap"><a href="./values.yaml#L593">otelAgent.configMap</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">create: true</pre>
</div>
            </td>
            <td>ConfigMap configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--configMap--create"><a href="./values.yaml#L596">otelAgent.configMap.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a ConfigMap should be created.</td>
        </tr>
        <tr>
            <td id="otelAgent--service"><a href="./values.yaml#L600">otelAgent.service</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
internalTrafficPolicy: Local
type: ClusterIP</pre>
</div>
            </td>
            <td>Service configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--service--annotations"><a href="./values.yaml#L603">otelAgent.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the OtelAgent service.</td>
        </tr>
        <tr>
            <td id="otelAgent--service--type"><a href="./values.yaml#L606">otelAgent.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>Service type: `ClusterIP`, `NodePort`, or `LoadBalancer`.</td>
        </tr>
        <tr>
            <td id="otelAgent--service--internalTrafficPolicy"><a href="./values.yaml#L610">otelAgent.service.internalTrafficPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Local</pre>
</div>
            </td>
            <td>Internal traffic policy: `Local` or `Cluster`. ref: https://kubernetes.io/docs/reference/networking/virtual-ips/#internal-traffic-policy</td>
        </tr>
        <tr>
            <td id="otelAgent--serviceAccount"><a href="./values.yaml#L614">otelAgent.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
create: true
name: null</pre>
</div>
            </td>
            <td>ServiceAccount configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--serviceAccount--create"><a href="./values.yaml#L617">otelAgent.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a ServiceAccount should be created.</td>
        </tr>
        <tr>
            <td id="otelAgent--serviceAccount--annotations"><a href="./values.yaml#L620">otelAgent.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ServiceAccount.</td>
        </tr>
        <tr>
            <td id="otelAgent--serviceAccount--name"><a href="./values.yaml#L623">otelAgent.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>The name of the ServiceAccount to use. A name is generated if not set.</td>
        </tr>
        <tr>
            <td id="otelAgent--annotations"><a href="./values.yaml#L627">otelAgent.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the OtelAgent DaemonSet.</td>
        </tr>
        <tr>
            <td id="otelAgent--podAnnotations"><a href="./values.yaml#L630">otelAgent.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the OtelAgent pods.</td>
        </tr>
        <tr>
            <td id="otelAgent--additionalEnvs"><a href="./values.yaml#L652">otelAgent.additionalEnvs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional environment variables for the OtelAgent container. You can specify variables in two ways: 1. Flexible structure for advanced configurations (recommended):    Example:      additionalEnvs:        MY_KEY:          value: my-value        SECRET_KEY:          valueFrom:            secretKeyRef:              name: my-secret              key: my-key 2. Simple key-value pairs (backward-compatible):    Example:      additionalEnvs:        MY_KEY: my-value</td>
        </tr>
        <tr>
            <td id="otelAgent--minReadySeconds"><a href="./values.yaml#L656">otelAgent.minReadySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Minimum number of seconds for which a newly created Pod should be ready.</td>
        </tr>
        <tr>
            <td id="otelAgent--clusterRole"><a href="./values.yaml#L661">otelAgent.clusterRole</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the values.yml for default values</pre>
</div>
            </td>
            <td>ClusterRole configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--clusterRole--create"><a href="./values.yaml#L664">otelAgent.clusterRole.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a ClusterRole should be created.</td>
        </tr>
        <tr>
            <td id="otelAgent--clusterRole--annotations"><a href="./values.yaml#L667">otelAgent.clusterRole.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ClusterRole.</td>
        </tr>
        <tr>
            <td id="otelAgent--clusterRole--name"><a href="./values.yaml#L670">otelAgent.clusterRole.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>The name of the ClusterRole to use. A name is generated if not set.</td>
        </tr>
        <tr>
            <td id="otelAgent--clusterRole--rules"><a href="./values.yaml#L675">otelAgent.clusterRole.rules</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the values.yml for default values</pre>
</div>
            </td>
            <td>RBAC rules for the OtelAgent. ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/</td>
        </tr>
        <tr>
            <td id="otelAgent--clusterRole--clusterRoleBinding"><a href="./values.yaml#L706">otelAgent.clusterRole.clusterRoleBinding</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
name: ""</pre>
</div>
            </td>
            <td>ClusterRoleBinding configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports"><a href="./values.yaml#L717">otelAgent.ports</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the values.yml for default values</pre>
</div>
            </td>
            <td>Port configurations for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--otlp--enabled"><a href="./values.yaml#L722">otelAgent.ports.otlp.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable service port for OTLP gRPC.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--otlp-http--enabled"><a href="./values.yaml#L737">otelAgent.ports.otlp-http.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable service port for OTLP HTTP.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--zipkin--enabled"><a href="./values.yaml#L752">otelAgent.ports.zipkin.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable service port for Zipkin.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--metrics--enabled"><a href="./values.yaml#L767">otelAgent.ports.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable service port for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--zpages--enabled"><a href="./values.yaml#L782">otelAgent.ports.zpages.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable service port for ZPages.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--health-check--enabled"><a href="./values.yaml#L797">otelAgent.ports.health-check.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable service port for health checks.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--pprof--enabled"><a href="./values.yaml#L812">otelAgent.ports.pprof.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable service port for pprof.</td>
        </tr>
        <tr>
            <td id="otelAgent--hostNetwork"><a href="./values.yaml#L826">otelAgent.hostNetwork</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Host networking requested for this pod. Use the host's network namespace. Please make sure while enabling hostNetwork that the host ports are available as it can lead to port conflicts.</td>
        </tr>
        <tr>
            <td id="otelAgent--livenessProbe"><a href="./values.yaml#L830">otelAgent.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: true
failureThreshold: 6
initialDelaySeconds: 10
path: /
periodSeconds: 10
port: 13133
successThreshold: 1
timeoutSeconds: 5</pre>
</div>
            </td>
            <td>Configure liveness probe. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command</td>
        </tr>
        <tr>
            <td id="otelAgent--readinessProbe"><a href="./values.yaml#L851">otelAgent.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: true
failureThreshold: 6
initialDelaySeconds: 10
path: /
periodSeconds: 10
port: 13133
successThreshold: 1
timeoutSeconds: 5</pre>
</div>
            </td>
            <td>Configure readiness probe. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes</td>
        </tr>
        <tr>
            <td id="otelAgent--customLivenessProbe"><a href="./values.yaml#L871">otelAgent.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom liveness probe configuration.</td>
        </tr>
        <tr>
            <td id="otelAgent--customReadinessProbe"><a href="./values.yaml#L874">otelAgent.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom readiness probe configuration.</td>
        </tr>
        <tr>
            <td id="otelAgent--ingress"><a href="./values.yaml#L878">otelAgent.ingress</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
className: ""
enabled: false
hosts:
    - host: otel-agent.domain.com
      paths:
        - path: /
          pathType: ImplementationSpecific
          port: 4317
tls: []</pre>
</div>
            </td>
            <td>Ingress configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--ingress--enabled"><a href="./values.yaml#L881">otelAgent.ingress.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable Ingress for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--ingress--className"><a href="./values.yaml#L884">otelAgent.ingress.className</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Ingress Class Name to be used.</td>
        </tr>
        <tr>
            <td id="otelAgent--ingress--annotations"><a href="./values.yaml#L887">otelAgent.ingress.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the OtelAgent Ingress.</td>
        </tr>
        <tr>
            <td id="otelAgent--ingress--hosts"><a href="./values.yaml#L895">otelAgent.ingress.hosts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- host: otel-agent.domain.com
  paths:
    - path: /
      pathType: ImplementationSpecific
      port: 4317</pre>
</div>
            </td>
            <td>OtelAgent Ingress hostnames with their path details.</td>
        </tr>
        <tr>
            <td id="otelAgent--ingress--tls"><a href="./values.yaml#L903">otelAgent.ingress.tls</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>OtelAgent Ingress TLS configuration.</td>
        </tr>
        <tr>
            <td id="otelAgent--resources"><a href="./values.yaml#L911">otelAgent.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">requests:
    cpu: 100m
    memory: 100Mi</pre>
</div>
            </td>
            <td>Configure resource requests and limits for the OtelAgent. ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
        </tr>
        <tr>
            <td id="otelAgent--priorityClassName"><a href="./values.yaml#L922">otelAgent.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>OtelAgent Priority Class name.</td>
        </tr>
        <tr>
            <td id="otelAgent--nodeSelector"><a href="./values.yaml#L926">otelAgent.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for OtelAgent pod assignment.</td>
        </tr>
        <tr>
            <td id="otelAgent--tolerations"><a href="./values.yaml#L930">otelAgent.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- operator: Exists</pre>
</div>
            </td>
            <td>Toleration labels for OtelAgent pod assignment.</td>
        </tr>
        <tr>
            <td id="otelAgent--affinity"><a href="./values.yaml#L935">otelAgent.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for the OtelAgent pod.</td>
        </tr>
        <tr>
            <td id="otelAgent--podSecurityContext"><a href="./values.yaml#L939">otelAgent.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Pod-level security configuration.</td>
        </tr>
        <tr>
            <td id="otelAgent--securityContext"><a href="./values.yaml#L944">otelAgent.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Container-level security configuration.</td>
        </tr>
        <tr>
            <td id="otelAgent--config"><a href="./values.yaml#L955">otelAgent.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please Checkout the values.yml for default values</pre>
</div>
            </td>
            <td>Base configuration for the OtelAgent Collector.</td>
        </tr>
        <tr>
            <td id="otelAgent--config--processors--batch"><a href="./values.yaml#L970">otelAgent.config.processors.batch</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">send_batch_size: 10000
timeout: 200ms</pre>
</div>
            </td>
            <td>Batch processor config. ref: https://github.com/open-telemetry/opentelemetry-collector/blob/main/processor/batchprocessor/README.md</td>
        </tr>
        <tr>
            <td id="otelAgent--extraVolumes"><a href="./values.yaml#L1012">otelAgent.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volumes for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--extraVolumeMounts"><a href="./values.yaml#L1022">otelAgent.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volume mounts for the OtelAgent.</td>
        </tr>
    </tbody>
</table>
<h3>OpenTelemetry Deployment</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="otelDeployment--enabled"><a href="./values.yaml#L1034">otelDeployment.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--name"><a href="./values.yaml#L1037">otelDeployment.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">otel-deployment</pre>
</div>
            </td>
            <td>Name of the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--image"><a href="./values.yaml#L1040">otelDeployment.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">pullPolicy: IfNotPresent
registry: docker.io
repository: otel/opentelemetry-collector-contrib
tag: 0.109.0</pre>
</div>
            </td>
            <td>Image configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--image--registry"><a href="./values.yaml#L1043">otelDeployment.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">docker.io</pre>
</div>
            </td>
            <td>Docker registry for the OtelDeployment image.</td>
        </tr>
        <tr>
            <td id="otelDeployment--image--repository"><a href="./values.yaml#L1046">otelDeployment.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">otel/opentelemetry-collector-contrib</pre>
</div>
            </td>
            <td>Repository for the OtelDeployment image.</td>
        </tr>
        <tr>
            <td id="otelDeployment--image--tag"><a href="./values.yaml#L1050">otelDeployment.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">0.109.0</pre>
</div>
            </td>
            <td>Tag for the OtelDeployment image. In case of your Host OS is windows, use the `0.123.0-windows-2022-amd64` tag.</td>
        </tr>
        <tr>
            <td id="otelDeployment--image--pullPolicy"><a href="./values.yaml#L1053">otelDeployment.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Image pull policy for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--imagePullSecrets"><a href="./values.yaml#L1057">otelDeployment.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image Pull Secrets for the OtelDeployment. Merged with `global.imagePullSecrets`.</td>
        </tr>
        <tr>
            <td id="otelDeployment--command"><a href="./values.yaml#L1062">otelDeployment.command</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">extraArgs: []
name: /otelcol-contrib</pre>
</div>
            </td>
            <td>Command and arguments for the OtelDeployment container.</td>
        </tr>
        <tr>
            <td id="otelDeployment--command--name"><a href="./values.yaml#L1065">otelDeployment.command.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">/otelcol-contrib</pre>
</div>
            </td>
            <td>OtelDeployment command name.</td>
        </tr>
        <tr>
            <td id="otelDeployment--command--extraArgs"><a href="./values.yaml#L1068">otelDeployment.command.extraArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Extra arguments for the OtelDeployment command.</td>
        </tr>
        <tr>
            <td id="otelDeployment--configMap"><a href="./values.yaml#L1072">otelDeployment.configMap</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">create: true</pre>
</div>
            </td>
            <td>ConfigMap configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--configMap--create"><a href="./values.yaml#L1075">otelDeployment.configMap.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a ConfigMap should be created.</td>
        </tr>
        <tr>
            <td id="otelDeployment--service"><a href="./values.yaml#L1079">otelDeployment.service</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
type: ClusterIP</pre>
</div>
            </td>
            <td>Service configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--service--annotations"><a href="./values.yaml#L1082">otelDeployment.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the OtelDeployment service.</td>
        </tr>
        <tr>
            <td id="otelDeployment--service--type"><a href="./values.yaml#L1085">otelDeployment.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>Service type.</td>
        </tr>
        <tr>
            <td id="otelDeployment--serviceAccount"><a href="./values.yaml#L1089">otelDeployment.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
create: true
name: null</pre>
</div>
            </td>
            <td>ServiceAccount configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--serviceAccount--create"><a href="./values.yaml#L1092">otelDeployment.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a ServiceAccount should be created.</td>
        </tr>
        <tr>
            <td id="otelDeployment--serviceAccount--annotations"><a href="./values.yaml#L1095">otelDeployment.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ServiceAccount.</td>
        </tr>
        <tr>
            <td id="otelDeployment--serviceAccount--name"><a href="./values.yaml#L1098">otelDeployment.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>The name of the ServiceAccount to use. A name is generated if not set.</td>
        </tr>
        <tr>
            <td id="otelDeployment--annotations"><a href="./values.yaml#L1102">otelDeployment.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--podAnnotations"><a href="./values.yaml#L1105">otelDeployment.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the OtelDeployment pods.</td>
        </tr>
        <tr>
            <td id="otelDeployment--additionalEnvs"><a href="./values.yaml#L1112">otelDeployment.additionalEnvs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional environment variables for the OtelDeployment container.</td>
        </tr>
        <tr>
            <td id="otelDeployment--podSecurityContext"><a href="./values.yaml#L1116">otelDeployment.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Pod-level security configuration.</td>
        </tr>
        <tr>
            <td id="otelDeployment--securityContext"><a href="./values.yaml#L1121">otelDeployment.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Container-level security configuration.</td>
        </tr>
        <tr>
            <td id="otelDeployment--minReadySeconds"><a href="./values.yaml#L1131">otelDeployment.minReadySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">5</pre>
</div>
            </td>
            <td>Minimum number of seconds for which a newly created Pod should be ready.</td>
        </tr>
        <tr>
            <td id="otelDeployment--progressDeadlineSeconds"><a href="./values.yaml#L1135">otelDeployment.progressDeadlineSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">120</pre>
</div>
            </td>
            <td>Seconds to wait for the Deployment to progress before it's considered failed.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ports"><a href="./values.yaml#L1139">otelDeployment.ports</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">health-check:
    containerPort: 13133
    enabled: true
    nodePort: ""
    protocol: TCP
    servicePort: 13133
metrics:
    containerPort: 8888
    enabled: false
    nodePort: ""
    protocol: TCP
    servicePort: 8888
pprof:
    containerPort: 1777
    enabled: false
    nodePort: ""
    protocol: TCP
    servicePort: 1777
zpages:
    containerPort: 55679
    enabled: false
    nodePort: ""
    protocol: TCP
    servicePort: 55679</pre>
</div>
            </td>
            <td>Port configurations for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ports--metrics--enabled"><a href="./values.yaml#L1144">otelDeployment.ports.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable service port for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ports--zpages--enabled"><a href="./values.yaml#L1157">otelDeployment.ports.zpages.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable service port for ZPages.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ports--health-check--enabled"><a href="./values.yaml#L1170">otelDeployment.ports.health-check.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Enable service port for health checks.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ports--pprof--enabled"><a href="./values.yaml#L1183">otelDeployment.ports.pprof.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable service port for pprof.</td>
        </tr>
        <tr>
            <td id="otelDeployment--livenessProbe"><a href="./values.yaml#L1195">otelDeployment.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: true
failureThreshold: 6
initialDelaySeconds: 10
path: /
periodSeconds: 10
port: 13133
successThreshold: 1
timeoutSeconds: 5</pre>
</div>
            </td>
            <td>Configure liveness probe.</td>
        </tr>
        <tr>
            <td id="otelDeployment--readinessProbe"><a href="./values.yaml#L1215">otelDeployment.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">enabled: true
failureThreshold: 6
initialDelaySeconds: 10
path: /
periodSeconds: 10
port: 13133
successThreshold: 1
timeoutSeconds: 5</pre>
</div>
            </td>
            <td>Configure readiness probe.</td>
        </tr>
        <tr>
            <td id="otelDeployment--customLivenessProbe"><a href="./values.yaml#L1235">otelDeployment.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom liveness probe configuration.</td>
        </tr>
        <tr>
            <td id="otelDeployment--customReadinessProbe"><a href="./values.yaml#L1239">otelDeployment.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Custom readiness probe configuration.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ingress"><a href="./values.yaml#L1243">otelDeployment.ingress</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
className: ""
enabled: false
hosts:
    - host: otel-deployment.domain.com
      paths:
        - path: /
          pathType: ImplementationSpecific
          port: 13133
tls: []</pre>
</div>
            </td>
            <td>Ingress configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ingress--enabled"><a href="./values.yaml#L1246">otelDeployment.ingress.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Enable Ingress for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ingress--className"><a href="./values.yaml#L1249">otelDeployment.ingress.className</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Ingress Class Name to be used.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ingress--annotations"><a href="./values.yaml#L1252">otelDeployment.ingress.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the OtelDeployment Ingress.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ingress--hosts"><a href="./values.yaml#L1255">otelDeployment.ingress.hosts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- host: otel-deployment.domain.com
  paths:
    - path: /
      pathType: ImplementationSpecific
      port: 13133</pre>
</div>
            </td>
            <td>OtelDeployment Ingress hostnames.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ingress--tls"><a href="./values.yaml#L1263">otelDeployment.ingress.tls</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>OtelDeployment Ingress TLS configuration.</td>
        </tr>
        <tr>
            <td id="otelDeployment--resources"><a href="./values.yaml#L1270">otelDeployment.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">requests:
    cpu: 100m
    memory: 100Mi</pre>
</div>
            </td>
            <td>Configure resource requests and limits for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--priorityClassName"><a href="./values.yaml#L1281">otelDeployment.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>OtelDeployment Priority Class name.</td>
        </tr>
        <tr>
            <td id="otelDeployment--nodeSelector"><a href="./values.yaml#L1285">otelDeployment.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for OtelDeployment pod assignment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--tolerations"><a href="./values.yaml#L1289">otelDeployment.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Toleration labels for OtelDeployment pod assignment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--affinity"><a href="./values.yaml#L1293">otelDeployment.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity settings for the OtelDeployment pod.</td>
        </tr>
        <tr>
            <td id="otelDeployment--topologySpreadConstraints"><a href="./values.yaml#L1297">otelDeployment.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Describes how OtelDeployment pods ought to spread.</td>
        </tr>
        <tr>
            <td id="otelDeployment--clusterRole"><a href="./values.yaml#L1302">otelDeployment.clusterRole</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please Checkout the values.yml for default values</pre>
</div>
            </td>
            <td>ClusterRole configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--clusterRole--create"><a href="./values.yaml#L1305">otelDeployment.clusterRole.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Specifies whether a ClusterRole should be created.</td>
        </tr>
        <tr>
            <td id="otelDeployment--clusterRole--annotations"><a href="./values.yaml#L1308">otelDeployment.clusterRole.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ClusterRole.</td>
        </tr>
        <tr>
            <td id="otelDeployment--clusterRole--name"><a href="./values.yaml#L1311">otelDeployment.clusterRole.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>The name of the ClusterRole to use. A name is generated if not set.</td>
        </tr>
        <tr>
            <td id="otelDeployment--clusterRole--rules"><a href="./values.yaml#L1315">otelDeployment.clusterRole.rules</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please checkout the values.yml for default values</pre>
</div>
            </td>
            <td>RBAC rules for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--clusterRole--clusterRoleBinding"><a href="./values.yaml#L1345">otelDeployment.clusterRole.clusterRoleBinding</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
name: ""</pre>
</div>
            </td>
            <td>ClusterRoleBinding configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--config"><a href="./values.yaml#L1356">otelDeployment.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">Please Checkout the values.yml for default values</pre>
</div>
            </td>
            <td>Base configuration for the OtelDeployment Collector.</td>
        </tr>
        <tr>
            <td id="otelDeployment--config--processors--batch"><a href="./values.yaml#L1363">otelDeployment.config.processors.batch</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">send_batch_size: 10000
timeout: 1s</pre>
</div>
            </td>
            <td>Batch processor config.</td>
        </tr>
        <tr>
            <td id="otelDeployment--extraVolumes"><a href="./values.yaml#L1403">otelDeployment.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volumes for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--extraVolumeMounts"><a href="./values.yaml#L1413">otelDeployment.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volume mounts for the OtelDeployment.</td>
        </tr>
    </tbody>
</table>

