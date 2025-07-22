
# K8s-Infra

![Version: 0.13.0](https://img.shields.io/badge/Version-0.13.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.109.0](https://img.shields.io/badge/AppVersion-0.109.0-informational?style=flat-square)

Monitoring your Kubernetes cluster is essential for ensuring performance, stability, and reliability. The SigNoz k8s-infra Helm chart provides a comprehensive solution for collecting and analyzing metrics, logs, and events from your entire Kubernetes environment.

### TL;DR;

```sh
helm repo add signoz https://charts.signoz.io
helm install -n platform --create-namespace "my-release" signoz/k8s-infra
```

### Introduction

The `k8s-infra` chart provides Kubernetes infrastructure observability by deploying OpenTelemetry components and related resources using the [Helm](https://helm.sh) package manager.

It enables collection of metrics, logs, and events from your Kubernetes cluster, making it easier to monitor and troubleshoot your infrastructure with SigNoz.

Refer to the documentation for a more detailed explanation of [k8s-infra](https://signoz.io/docs/infrastructure-monitoring/k8s-infra-architecture).
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
                <div style="max-width: 300px;"><pre lang="json">
{
  "cloud": "other",
  "clusterDomain": "cluster.local",
  "clusterName": "",
  "deploymentEnvironment": "",
  "imagePullSecrets": [],
  "imageRegistry": null,
  "storageClass": null
}
</pre>
</div>
            </td>
            <td>Global override values.</td>
        </tr>
        <tr>
            <td id="global--imageRegistry"><a href="./values.yaml#L6">global.imageRegistry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
null
</pre>
</div>
            </td>
            <td>Overrides the Docker registry globally for all images.</td>
        </tr>
        <tr>
            <td id="global--imagePullSecrets"><a href="./values.yaml#L9">global.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>Global Image Pull Secrets.</td>
        </tr>
        <tr>
            <td id="global--storageClass"><a href="./values.yaml#L12">global.storageClass</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
null
</pre>
</div>
            </td>
            <td>Overrides the storage class for all PVCs with persistence enabled.</td>
        </tr>
        <tr>
            <td id="global--clusterDomain"><a href="./values.yaml#L15">global.clusterDomain</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"cluster.local"
</pre>
</div>
            </td>
            <td>Kubernetes cluster domain. Used only when components are installed in different namespaces.</td>
        </tr>
        <tr>
            <td id="global--clusterName"><a href="./values.yaml#L18">global.clusterName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>Kubernetes cluster name. Used to attach to telemetry data via the resource detection processor.</td>
        </tr>
        <tr>
            <td id="global--deploymentEnvironment"><a href="./values.yaml#L21">global.deploymentEnvironment</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>Deployment environment to be attached to telemetry data.</td>
        </tr>
        <tr>
            <td id="global--cloud"><a href="./values.yaml#L24">global.cloud</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"other"
</pre>
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
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>K8s infra chart name override.</td>
        </tr>
        <tr>
            <td id="fullnameOverride"><a href="./values.yaml#L32">fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>K8s infra chart full name override.</td>
        </tr>
        <tr>
            <td id="enabled"><a href="./values.yaml#L36">enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Whether to enable the K8s infra chart.</td>
        </tr>
        <tr>
            <td id="clusterName"><a href="./values.yaml#L40">clusterName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>Name of the K8s cluster. Used by OtelCollectors to attach in telemetry data.</td>
        </tr>
        <tr>
            <td id="otelCollectorEndpoint"><a href="./values.yaml#L47">otelCollectorEndpoint</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
null
</pre>
</div>
            </td>
            <td>Endpoint/IP Address of the SigNoz or any other OpenTelemetry backend. Set it to `ingest.signoz.io:4317` for SigNoz Cloud. If set to null and the chart is installed as a dependency, it will attempt to autogenerate the endpoint of the SigNoz OtelCollector.</td>
        </tr>
        <tr>
            <td id="otelInsecure"><a href="./values.yaml#L52">otelInsecure</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Whether the OTLP endpoint is insecure. Set this to false in case of a secure OTLP endpoint.</td>
        </tr>
        <tr>
            <td id="insecureSkipVerify"><a href="./values.yaml#L56">insecureSkipVerify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Whether to skip verifying the OTLP endpoint's certificate.</td>
        </tr>
        <tr>
            <td id="namespace"><a href="./values.yaml#L100">namespace</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="">
By default, components are installed in the same namespace as the chart.
</pre>
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
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>API key for SigNoz Cloud.</td>
        </tr>
        <tr>
            <td id="apiKeyExistingSecretName"><a href="./values.yaml#L63">apiKeyExistingSecretName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>Existing secret name to be used for the API key.</td>
        </tr>
        <tr>
            <td id="apiKeyExistingSecretKey"><a href="./values.yaml#L66">apiKeyExistingSecretKey</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
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
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Whether to enable OpenTelemetry OTLP secrets for secure communication.</td>
        </tr>
        <tr>
            <td id="otelTlsSecrets--path"><a href="./values.yaml#L76">otelTlsSecrets.path</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"/secrets"
</pre>
</div>
            </td>
            <td>Path for the secrets volume when mounted in the container.</td>
        </tr>
        <tr>
            <td id="otelTlsSecrets--existingSecretName"><a href="./values.yaml#L81">otelTlsSecrets.existingSecretName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
null
</pre>
</div>
            </td>
            <td>Name of an existing secret with TLS certificate, key, and CA to be used. Files in the secret must be named `cert.pem`, `key.pem`, and `ca.pem`.</td>
        </tr>
        <tr>
            <td id="otelTlsSecrets--certificate"><a href="./values.yaml#L85">otelTlsSecrets.certificate</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"\u003cINCLUDE_CERTIFICATE_HERE\u003e\n"
</pre>
</div>
            </td>
            <td>TLS certificate to be included in the secret.</td>
        </tr>
        <tr>
            <td id="otelTlsSecrets--key"><a href="./values.yaml#L90">otelTlsSecrets.key</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"\u003cINCLUDE_PRIVATE_KEY_HERE\u003e\n"
</pre>
</div>
            </td>
            <td>TLS private key to be included in the secret.</td>
        </tr>
        <tr>
            <td id="otelTlsSecrets--ca"><a href="./values.yaml#L95">otelTlsSecrets.ca</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>TLS certificate authority (CA) certificate to be included in the secret.</td>
        </tr>
    </tbody>
</table>
<h3>Configuration Presets</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="presets"><a href="./values.yaml#L107">presets</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="">
"Please check out the values.yml for default values"
</pre>
</div>
            </td>
            <td>Presets to easily set up OtelCollector configurations. For more details, see the documentation: https://signoz.io/docs/metrics-management/k8s-infra-otel-config</td>
        </tr>
        <tr>
            <td id="presets--loggingExporter"><a href="./values.yaml#L110">presets.loggingExporter</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "enabled": false,
  "samplingInitial": 2,
  "samplingThereafter": 500,
  "verbosity": "basic"
}
</pre>
</div>
            </td>
            <td>Configuration for the logging exporter, used for debugging telemetry data.</td>
        </tr>
        <tr>
            <td id="presets--otlpExporter"><a href="./values.yaml#L125">presets.otlpExporter</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "enabled": true
}
</pre>
</div>
            </td>
            <td>Configuration for the OTLP exporter.</td>
        </tr>
        <tr>
            <td id="presets--selfTelemetry"><a href="./values.yaml#L131">presets.selfTelemetry</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "apiKeyExistingSecretKey": "",
  "apiKeyExistingSecretName": "",
  "endpoint": "",
  "insecure": true,
  "insecureSkipVerify": true,
  "logs": {
    "enabled": false
  },
  "metrics": {
    "enabled": false
  },
  "signozApiKey": "",
  "traces": {
    "enabled": false
  }
}
</pre>
</div>
            </td>
            <td>Configuration for sending the collector's own telemetry data.</td>
        </tr>
        <tr>
            <td id="presets--selfTelemetry--endpoint"><a href="./values.yaml#L134">presets.selfTelemetry.endpoint</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>OTLP HTTP endpoint to send own telemetry data to.</td>
        </tr>
        <tr>
            <td id="presets--selfTelemetry--traces--enabled"><a href="./values.yaml#L155">presets.selfTelemetry.traces.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable self-telemetry for traces.</td>
        </tr>
        <tr>
            <td id="presets--selfTelemetry--metrics--enabled"><a href="./values.yaml#L161">presets.selfTelemetry.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable self-telemetry for metrics.</td>
        </tr>
        <tr>
            <td id="presets--selfTelemetry--logs"><a href="./values.yaml#L164">presets.selfTelemetry.logs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "enabled": false
}
</pre>
</div>
            </td>
            <td>Configuration for self-telemetry logs.</td>
        </tr>
        <tr>
            <td id="presets--selfTelemetry--logs--enabled"><a href="./values.yaml#L167">presets.selfTelemetry.logs.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable self-telemetry for logs.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection"><a href="./values.yaml#L170">presets.logsCollection</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "blacklist": {
    "additionalExclude": [],
    "containers": [],
    "enabled": true,
    "namespaces": [
      "kube-system"
    ],
    "pods": [
      "hotrod",
      "locust"
    ],
    "signozLogs": true
  },
  "enabled": true,
  "include": [
    "/var/log/pods/*/*/*.log"
  ],
  "includeFileName": false,
  "includeFilePath": true,
  "operators": [
    {
      "id": "container-parser",
      "type": "container"
    }
  ],
  "startAt": "end",
  "whitelist": {
    "additionalInclude": [],
    "containers": [],
    "enabled": false,
    "namespaces": [],
    "pods": [],
    "signozLogs": true
  }
}
</pre>
</div>
            </td>
            <td>Configuration for collecting logs from pods.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--enabled"><a href="./values.yaml#L173">presets.logsCollection.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable log collection.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--startAt"><a href="./values.yaml#L176">presets.logsCollection.startAt</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"end"
</pre>
</div>
            </td>
            <td>Where to start reading logs from: `end` or `beginning`.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--whitelist"><a href="./values.yaml#L213">presets.logsCollection.whitelist</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "additionalInclude": [],
  "containers": [],
  "enabled": false,
  "namespaces": [],
  "pods": [],
  "signozLogs": true
}
</pre>
</div>
            </td>
            <td>Whitelist certain log files to be collected. If enabled, `include` is ignored.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--whitelist--enabled"><a href="./values.yaml#L216">presets.logsCollection.whitelist.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable the whitelist.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--whitelist--signozLogs"><a href="./values.yaml#L219">presets.logsCollection.whitelist.signozLogs</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Include SigNoz's own logs.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--whitelist--namespaces"><a href="./values.yaml#L222">presets.logsCollection.whitelist.namespaces</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>List of namespaces to include in log collection.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--whitelist--pods"><a href="./values.yaml#L225">presets.logsCollection.whitelist.pods</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>List of pod names to include.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--whitelist--containers"><a href="./values.yaml#L228">presets.logsCollection.whitelist.containers</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>List of container names to include.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--whitelist--additionalInclude"><a href="./values.yaml#L231">presets.logsCollection.whitelist.additionalInclude</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>List of additional file path patterns to include.</td>
        </tr>
        <tr>
            <td id="presets--logsCollection--operators"><a href="./values.yaml#L234">presets.logsCollection.operators</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[
  {
    "id": "container-parser",
    "type": "container"
  }
]
</pre>
</div>
            </td>
            <td>A list of log processing operators.</td>
        </tr>
        <tr>
            <td id="presets--hostMetrics"><a href="./values.yaml#L239">presets.hostMetrics</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "collectionInterval": "30s",
  "enabled": true,
  "scrapers": {
    "cpu": {},
    "disk": {
      "exclude": {
        "devices": [
          "^ram\\d+$",
          "^zram\\d+$",
          "^loop\\d+$",
          "^fd\\d+$",
          "^hd[a-z]\\d+$",
          "^sd[a-z]\\d+$",
          "^vd[a-z]\\d+$",
          "^xvd[a-z]\\d+$",
          "^nvme\\d+n\\d+p\\d+$"
        ],
        "match_type": "regexp"
      }
    },
    "filesystem": {
      "exclude_fs_types": {
        "fs_types": [
          "autofs",
          "binfmt_misc",
          "bpf",
          "cgroup2?",
          "configfs",
          "debugfs",
          "devpts",
          "devtmpfs",
          "fusectl",
          "hugetlbfs",
          "iso9660",
          "mqueue",
          "nsfs",
          "overlay",
          "proc",
          "procfs",
          "pstore",
          "rpc_pipefs",
          "securityfs",
          "selinuxfs",
          "squashfs",
          "sysfs",
          "tracefs"
        ],
        "match_type": "strict"
      },
      "exclude_mount_points": {
        "match_type": "regexp",
        "mount_points": [
          "/dev/*",
          "/proc/*",
          "/sys/*",
          "/run/credentials/*",
          "/run/k3s/containerd/*",
          "/var/lib/docker/*",
          "/var/lib/containers/storage/*",
          "/var/lib/kubelet/*",
          "/snap/*"
        ]
      }
    },
    "load": {},
    "memory": {},
    "network": {
      "exclude": {
        "interfaces": [
          "^veth.*$",
          "^docker.*$",
          "^br-.*$",
          "^flannel.*$",
          "^cali.*$",
          "^cbr.*$",
          "^cni.*$",
          "^dummy.*$",
          "^tailscale.*$",
          "^lo$"
        ],
        "match_type": "regexp"
      }
    }
  }
}
</pre>
</div>
            </td>
            <td>Configuration for collecting host-level metrics from nodes.</td>
        </tr>
        <tr>
            <td id="presets--hostMetrics--enabled"><a href="./values.yaml#L242">presets.hostMetrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable host metrics collection.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics"><a href="./values.yaml#L320">presets.kubeletMetrics</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "authType": "serviceAccount",
  "collectionInterval": "30s",
  "enabled": true,
  "endpoint": "${env:K8S_HOST_IP}:10250",
  "extraMetadataLabels": [
    "container.id",
    "k8s.volume.type"
  ],
  "insecureSkipVerify": true,
  "metricGroups": [
    "container",
    "pod",
    "node",
    "volume"
  ],
  "metrics": {
    "container.cpu.usage": {
      "enabled": true
    },
    "container.uptime": {
      "enabled": true
    },
    "k8s.container.cpu_limit_utilization": {
      "enabled": true
    },
    "k8s.container.cpu_request_utilization": {
      "enabled": true
    },
    "k8s.container.memory_limit_utilization": {
      "enabled": true
    },
    "k8s.container.memory_request_utilization": {
      "enabled": true
    },
    "k8s.node.cpu.usage": {
      "enabled": true
    },
    "k8s.node.uptime": {
      "enabled": true
    },
    "k8s.pod.cpu.usage": {
      "enabled": true
    },
    "k8s.pod.cpu_limit_utilization": {
      "enabled": true
    },
    "k8s.pod.cpu_request_utilization": {
      "enabled": true
    },
    "k8s.pod.memory_limit_utilization": {
      "enabled": true
    },
    "k8s.pod.memory_request_utilization": {
      "enabled": true
    },
    "k8s.pod.uptime": {
      "enabled": true
    }
  }
}
</pre>
</div>
            </td>
            <td>Configuration for collecting metrics from Kubelet.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--enabled"><a href="./values.yaml#L323">presets.kubeletMetrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable Kubelet metrics collection.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--endpoint"><a href="./values.yaml#L332">presets.kubeletMetrics.endpoint</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"${env:K8S_HOST_IP}:10250"
</pre>
</div>
            </td>
            <td>Kubelet endpoint.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--insecureSkipVerify"><a href="./values.yaml#L335">presets.kubeletMetrics.insecureSkipVerify</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Skip verifying Kubelet's certificate.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--extraMetadataLabels"><a href="./values.yaml#L338">presets.kubeletMetrics.extraMetadataLabels</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[
  "container.id",
  "k8s.volume.type"
]
</pre>
</div>
            </td>
            <td>List of extra metadata labels to collect.</td>
        </tr>
        <tr>
            <td id="presets--kubeletMetrics--metricGroups"><a href="./values.yaml#L343">presets.kubeletMetrics.metricGroups</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[
  "container",
  "pod",
  "node",
  "volume"
]
</pre>
</div>
            </td>
            <td>Groups of metrics to collect from Kubelet.</td>
        </tr>
        <tr>
            <td id="presets--kubernetesAttributes"><a href="./values.yaml#L381">presets.kubernetesAttributes</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "enabled": true,
  "extractAnnotations": [],
  "extractLabels": [],
  "extractMetadatas": [
    "k8s.namespace.name",
    "k8s.deployment.name",
    "k8s.statefulset.name",
    "k8s.daemonset.name",
    "k8s.cronjob.name",
    "k8s.job.name",
    "k8s.node.name",
    "k8s.node.uid",
    "k8s.pod.name",
    "k8s.pod.uid",
    "k8s.pod.start_time"
  ],
  "filter": {
    "node_from_env_var": "K8S_NODE_NAME"
  },
  "passthrough": false,
  "podAssociation": [
    {
      "sources": [
        {
          "from": "resource_attribute",
          "name": "k8s.pod.ip"
        }
      ]
    },
    {
      "sources": [
        {
          "from": "resource_attribute",
          "name": "k8s.pod.uid"
        }
      ]
    },
    {
      "sources": [
        {
          "from": "connection"
        }
      ]
    }
  ]
}
</pre>
</div>
            </td>
            <td>Processor for adding Kubernetes attributes to telemetry data.</td>
        </tr>
        <tr>
            <td id="presets--kubernetesAttributes--enabled"><a href="./values.yaml#L384">presets.kubernetesAttributes.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable the Kubernetes attributes processor.</td>
        </tr>
        <tr>
            <td id="presets--clusterMetrics"><a href="./values.yaml#L427">presets.clusterMetrics</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "allocatableTypesToReport": [
    "cpu",
    "memory"
  ],
  "collectionInterval": "30s",
  "enabled": true,
  "metrics": {
    "k8s.node.condition": {
      "enabled": true
    },
    "k8s.pod.status_reason": {
      "enabled": true
    }
  },
  "nodeConditionsToReport": [
    "Ready",
    "MemoryPressure",
    "DiskPressure",
    "PIDPressure",
    "NetworkUnavailable"
  ],
  "resourceAttributes": {
    "container.runtime": {
      "enabled": true
    },
    "container.runtime.version": {
      "enabled": true
    },
    "k8s.container.status.last_terminated_reason": {
      "enabled": true
    },
    "k8s.kubelet.version": {
      "enabled": true
    },
    "k8s.pod.qos_class": {
      "enabled": true
    }
  }
}
</pre>
</div>
            </td>
            <td>Configuration for collecting cluster-level metrics.</td>
        </tr>
        <tr>
            <td id="presets--clusterMetrics--enabled"><a href="./values.yaml#L430">presets.clusterMetrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable cluster metrics collection.</td>
        </tr>
        <tr>
            <td id="presets--clusterMetrics--resourceAttributes"><a href="./values.yaml#L436">presets.clusterMetrics.resourceAttributes</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "container.runtime": {
    "enabled": true
  },
  "container.runtime.version": {
    "enabled": true
  },
  "k8s.container.status.last_terminated_reason": {
    "enabled": true
  },
  "k8s.kubelet.version": {
    "enabled": true
  },
  "k8s.pod.qos_class": {
    "enabled": true
  }
}
</pre>
</div>
            </td>
            <td>Resource attributes to report.</td>
        </tr>
        <tr>
            <td id="presets--clusterMetrics--nodeConditionsToReport"><a href="./values.yaml#L449">presets.clusterMetrics.nodeConditionsToReport</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[
  "Ready",
  "MemoryPressure",
  "DiskPressure",
  "PIDPressure",
  "NetworkUnavailable"
]
</pre>
</div>
            </td>
            <td>Node conditions to report as metrics.</td>
        </tr>
        <tr>
            <td id="presets--clusterMetrics--allocatableTypesToReport"><a href="./values.yaml#L457">presets.clusterMetrics.allocatableTypesToReport</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[
  "cpu",
  "memory"
]
</pre>
</div>
            </td>
            <td>Allocatable resource types to report.</td>
        </tr>
        <tr>
            <td id="presets--clusterMetrics--metrics"><a href="./values.yaml#L464">presets.clusterMetrics.metrics</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "k8s.node.condition": {
    "enabled": true
  },
  "k8s.pod.status_reason": {
    "enabled": true
  }
}
</pre>
</div>
            </td>
            <td>Fine-grained control over which cluster metrics are enabled.</td>
        </tr>
        <tr>
            <td id="presets--prometheus"><a href="./values.yaml#L471">presets.prometheus</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "annotationsPrefix": "signoz.io",
  "enabled": false,
  "includeContainerName": false,
  "includePodLabel": false,
  "namespaceScoped": false,
  "namespaces": [],
  "scrapeInterval": "60s"
}
</pre>
</div>
            </td>
            <td>Configuration for scraping Prometheus metrics from pod annotations.</td>
        </tr>
        <tr>
            <td id="presets--prometheus--enabled"><a href="./values.yaml#L474">presets.prometheus.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable Prometheus metrics scraping.</td>
        </tr>
        <tr>
            <td id="presets--resourceDetection"><a href="./values.yaml#L495">presets.resourceDetection</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "enabled": true,
  "envResourceAttributes": "",
  "override": false,
  "timeout": "2s"
}
</pre>
</div>
            </td>
            <td>Processor for detecting resource information from the environment (e.g., cloud provider, k8s).</td>
        </tr>
        <tr>
            <td id="presets--k8sEvents"><a href="./values.yaml#L510">presets.k8sEvents</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "authType": "serviceAccount",
  "enabled": true,
  "namespaces": []
}
</pre>
</div>
            </td>
            <td>Configuration for collecting Kubernetes events as logs.</td>
        </tr>
        <tr>
            <td id="presets--k8sEvents--enabled"><a href="./values.yaml#L513">presets.k8sEvents.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable Kubernetes events collection.</td>
        </tr>
        <tr>
            <td id="presets--k8sEvents--authType"><a href="./values.yaml#L516">presets.k8sEvents.authType</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"serviceAccount"
</pre>
</div>
            </td>
            <td>Authentication type: `serviceAccount` or `kubeconfig`.</td>
        </tr>
        <tr>
            <td id="presets--k8sEvents--namespaces"><a href="./values.yaml#L519">presets.k8sEvents.namespaces</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
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
            <td id="otelAgent--enabled"><a href="./values.yaml#L526">otelAgent.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable the OtelAgent DaemonSet.</td>
        </tr>
        <tr>
            <td id="otelAgent--name"><a href="./values.yaml#L529">otelAgent.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"otel-agent"
</pre>
</div>
            </td>
            <td>Name of the OtelAgent DaemonSet.</td>
        </tr>
        <tr>
            <td id="otelAgent--image"><a href="./values.yaml#L532">otelAgent.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "pullPolicy": "IfNotPresent",
  "registry": "docker.io",
  "repository": "otel/opentelemetry-collector-contrib",
  "tag": "0.109.0"
}
</pre>
</div>
            </td>
            <td>Image configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--image--registry"><a href="./values.yaml#L535">otelAgent.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"docker.io"
</pre>
</div>
            </td>
            <td>Docker registry for the OtelAgent image.</td>
        </tr>
        <tr>
            <td id="otelAgent--image--repository"><a href="./values.yaml#L538">otelAgent.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"otel/opentelemetry-collector-contrib"
</pre>
</div>
            </td>
            <td>Repository for the OtelAgent image.</td>
        </tr>
        <tr>
            <td id="otelAgent--image--tag"><a href="./values.yaml#L541">otelAgent.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"0.109.0"
</pre>
</div>
            </td>
            <td>Tag for the OtelAgent image.</td>
        </tr>
        <tr>
            <td id="otelAgent--image--pullPolicy"><a href="./values.yaml#L544">otelAgent.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"IfNotPresent"
</pre>
</div>
            </td>
            <td>Image pull policy for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--imagePullSecrets"><a href="./values.yaml#L548">otelAgent.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>Image Pull Secrets for the OtelAgent. Merged with `global.imagePullSecrets`.</td>
        </tr>
        <tr>
            <td id="otelAgent--command"><a href="./values.yaml#L553">otelAgent.command</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "extraArgs": [],
  "name": "/otelcol-contrib"
}
</pre>
</div>
            </td>
            <td>Command and arguments for the OtelAgent container.</td>
        </tr>
        <tr>
            <td id="otelAgent--command--name"><a href="./values.yaml#L556">otelAgent.command.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"/otelcol-contrib"
</pre>
</div>
            </td>
            <td>OtelAgent command name.</td>
        </tr>
        <tr>
            <td id="otelAgent--command--extraArgs"><a href="./values.yaml#L559">otelAgent.command.extraArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>Extra arguments for the OtelAgent command.</td>
        </tr>
        <tr>
            <td id="otelAgent--configMap"><a href="./values.yaml#L563">otelAgent.configMap</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "create": true
}
</pre>
</div>
            </td>
            <td>ConfigMap configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--configMap--create"><a href="./values.yaml#L566">otelAgent.configMap.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Specifies whether a ConfigMap should be created.</td>
        </tr>
        <tr>
            <td id="otelAgent--service"><a href="./values.yaml#L570">otelAgent.service</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "annotations": {},
  "internalTrafficPolicy": "Local",
  "type": "ClusterIP"
}
</pre>
</div>
            </td>
            <td>Service configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--service--annotations"><a href="./values.yaml#L573">otelAgent.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Annotations for the OtelAgent service.</td>
        </tr>
        <tr>
            <td id="otelAgent--service--type"><a href="./values.yaml#L576">otelAgent.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"ClusterIP"
</pre>
</div>
            </td>
            <td>Service type: `ClusterIP`, `NodePort`, or `LoadBalancer`.</td>
        </tr>
        <tr>
            <td id="otelAgent--service--internalTrafficPolicy"><a href="./values.yaml#L580">otelAgent.service.internalTrafficPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"Local"
</pre>
</div>
            </td>
            <td>Internal traffic policy: `Local` or `Cluster`. ref: https://kubernetes.io/docs/reference/networking/virtual-ips/#internal-traffic-policy</td>
        </tr>
        <tr>
            <td id="otelAgent--serviceAccount"><a href="./values.yaml#L584">otelAgent.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "annotations": {},
  "create": true,
  "name": null
}
</pre>
</div>
            </td>
            <td>ServiceAccount configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--serviceAccount--create"><a href="./values.yaml#L587">otelAgent.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Specifies whether a ServiceAccount should be created.</td>
        </tr>
        <tr>
            <td id="otelAgent--serviceAccount--annotations"><a href="./values.yaml#L590">otelAgent.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Annotations for the ServiceAccount.</td>
        </tr>
        <tr>
            <td id="otelAgent--serviceAccount--name"><a href="./values.yaml#L593">otelAgent.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
null
</pre>
</div>
            </td>
            <td>The name of the ServiceAccount to use. A name is generated if not set.</td>
        </tr>
        <tr>
            <td id="otelAgent--annotations"><a href="./values.yaml#L597">otelAgent.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Annotations for the OtelAgent DaemonSet.</td>
        </tr>
        <tr>
            <td id="otelAgent--podAnnotations"><a href="./values.yaml#L600">otelAgent.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Annotations for the OtelAgent pods.</td>
        </tr>
        <tr>
            <td id="otelAgent--additionalEnvs"><a href="./values.yaml#L622">otelAgent.additionalEnvs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Additional environment variables for the OtelAgent container. You can specify variables in two ways: 1. Flexible structure for advanced configurations (recommended):    Example:      additionalEnvs:        MY_KEY:          value: my-value        SECRET_KEY:          valueFrom:            secretKeyRef:              name: my-secret              key: my-key 2. Simple key-value pairs (backward-compatible):    Example:      additionalEnvs:        MY_KEY: my-value</td>
        </tr>
        <tr>
            <td id="otelAgent--minReadySeconds"><a href="./values.yaml#L626">otelAgent.minReadySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
5
</pre>
</div>
            </td>
            <td>Minimum number of seconds for which a newly created Pod should be ready.</td>
        </tr>
        <tr>
            <td id="otelAgent--clusterRole"><a href="./values.yaml#L631">otelAgent.clusterRole</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="">
"Please checkout the values.yml for default values"
</pre>
</div>
            </td>
            <td>ClusterRole configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--clusterRole--create"><a href="./values.yaml#L634">otelAgent.clusterRole.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Specifies whether a ClusterRole should be created.</td>
        </tr>
        <tr>
            <td id="otelAgent--clusterRole--annotations"><a href="./values.yaml#L637">otelAgent.clusterRole.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Annotations for the ClusterRole.</td>
        </tr>
        <tr>
            <td id="otelAgent--clusterRole--name"><a href="./values.yaml#L640">otelAgent.clusterRole.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>The name of the ClusterRole to use. A name is generated if not set.</td>
        </tr>
        <tr>
            <td id="otelAgent--clusterRole--rules"><a href="./values.yaml#L645">otelAgent.clusterRole.rules</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="">
"Please checkout the values.yml for default values"
</pre>
</div>
            </td>
            <td>RBAC rules for the OtelAgent. ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/</td>
        </tr>
        <tr>
            <td id="otelAgent--clusterRole--clusterRoleBinding"><a href="./values.yaml#L676">otelAgent.clusterRole.clusterRoleBinding</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "annotations": {},
  "name": ""
}
</pre>
</div>
            </td>
            <td>ClusterRoleBinding configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports"><a href="./values.yaml#L687">otelAgent.ports</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="">
"Please checkout the values.yml for default values"
</pre>
</div>
            </td>
            <td>Port configurations for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--otlp--enabled"><a href="./values.yaml#L692">otelAgent.ports.otlp.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable service port for OTLP gRPC.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--otlp-http--enabled"><a href="./values.yaml#L707">otelAgent.ports.otlp-http.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable service port for OTLP HTTP.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--zipkin--enabled"><a href="./values.yaml#L722">otelAgent.ports.zipkin.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable service port for Zipkin.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--metrics--enabled"><a href="./values.yaml#L737">otelAgent.ports.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable service port for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--zpages--enabled"><a href="./values.yaml#L752">otelAgent.ports.zpages.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable service port for ZPages.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--health-check--enabled"><a href="./values.yaml#L767">otelAgent.ports.health-check.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable service port for health checks.</td>
        </tr>
        <tr>
            <td id="otelAgent--ports--pprof--enabled"><a href="./values.yaml#L782">otelAgent.ports.pprof.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable service port for pprof.</td>
        </tr>
        <tr>
            <td id="otelAgent--livenessProbe"><a href="./values.yaml#L797">otelAgent.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "enabled": true,
  "failureThreshold": 6,
  "initialDelaySeconds": 10,
  "path": "/",
  "periodSeconds": 10,
  "port": 13133,
  "successThreshold": 1,
  "timeoutSeconds": 5
}
</pre>
</div>
            </td>
            <td>Configure liveness probe. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command</td>
        </tr>
        <tr>
            <td id="otelAgent--readinessProbe"><a href="./values.yaml#L818">otelAgent.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "enabled": true,
  "failureThreshold": 6,
  "initialDelaySeconds": 10,
  "path": "/",
  "periodSeconds": 10,
  "port": 13133,
  "successThreshold": 1,
  "timeoutSeconds": 5
}
</pre>
</div>
            </td>
            <td>Configure readiness probe. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes</td>
        </tr>
        <tr>
            <td id="otelAgent--customLivenessProbe"><a href="./values.yaml#L838">otelAgent.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Custom liveness probe configuration.</td>
        </tr>
        <tr>
            <td id="otelAgent--customReadinessProbe"><a href="./values.yaml#L841">otelAgent.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Custom readiness probe configuration.</td>
        </tr>
        <tr>
            <td id="otelAgent--ingress"><a href="./values.yaml#L845">otelAgent.ingress</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "annotations": {},
  "className": "",
  "enabled": false,
  "hosts": [
    {
      "host": "otel-agent.domain.com",
      "paths": [
        {
          "path": "/",
          "pathType": "ImplementationSpecific",
          "port": 4317
        }
      ]
    }
  ],
  "tls": []
}
</pre>
</div>
            </td>
            <td>Ingress configuration for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--ingress--enabled"><a href="./values.yaml#L848">otelAgent.ingress.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable Ingress for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--ingress--className"><a href="./values.yaml#L851">otelAgent.ingress.className</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>Ingress Class Name to be used.</td>
        </tr>
        <tr>
            <td id="otelAgent--ingress--annotations"><a href="./values.yaml#L854">otelAgent.ingress.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Annotations for the OtelAgent Ingress.</td>
        </tr>
        <tr>
            <td id="otelAgent--ingress--hosts"><a href="./values.yaml#L862">otelAgent.ingress.hosts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[
  {
    "host": "otel-agent.domain.com",
    "paths": [
      {
        "path": "/",
        "pathType": "ImplementationSpecific",
        "port": 4317
      }
    ]
  }
]
</pre>
</div>
            </td>
            <td>OtelAgent Ingress hostnames with their path details.</td>
        </tr>
        <tr>
            <td id="otelAgent--ingress--tls"><a href="./values.yaml#L870">otelAgent.ingress.tls</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>OtelAgent Ingress TLS configuration.</td>
        </tr>
        <tr>
            <td id="otelAgent--resources"><a href="./values.yaml#L878">otelAgent.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "requests": {
    "cpu": "100m",
    "memory": "100Mi"
  }
}
</pre>
</div>
            </td>
            <td>Configure resource requests and limits for the OtelAgent. ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
        </tr>
        <tr>
            <td id="otelAgent--priorityClassName"><a href="./values.yaml#L889">otelAgent.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>OtelAgent Priority Class name.</td>
        </tr>
        <tr>
            <td id="otelAgent--nodeSelector"><a href="./values.yaml#L893">otelAgent.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Node selector for OtelAgent pod assignment.</td>
        </tr>
        <tr>
            <td id="otelAgent--tolerations"><a href="./values.yaml#L897">otelAgent.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[
  {
    "operator": "Exists"
  }
]
</pre>
</div>
            </td>
            <td>Toleration labels for OtelAgent pod assignment.</td>
        </tr>
        <tr>
            <td id="otelAgent--affinity"><a href="./values.yaml#L902">otelAgent.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Affinity settings for the OtelAgent pod.</td>
        </tr>
        <tr>
            <td id="otelAgent--podSecurityContext"><a href="./values.yaml#L906">otelAgent.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Pod-level security configuration.</td>
        </tr>
        <tr>
            <td id="otelAgent--securityContext"><a href="./values.yaml#L911">otelAgent.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Container-level security configuration.</td>
        </tr>
        <tr>
            <td id="otelAgent--config"><a href="./values.yaml#L921">otelAgent.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "exporters": {},
  "extensions": {
    "health_check": {
      "endpoint": "0.0.0.0:13133"
    },
    "pprof": {
      "endpoint": "localhost:1777"
    },
    "zpages": {
      "endpoint": "localhost:55679"
    }
  },
  "processors": {
    "batch": {
      "send_batch_size": 10000,
      "timeout": "200ms"
    }
  },
  "receivers": {
    "otlp": {
      "protocols": {
        "grpc": {
          "endpoint": "0.0.0.0:4317",
          "max_recv_msg_size_mib": 4
        },
        "http": {
          "endpoint": "0.0.0.0:4318"
        }
      }
    }
  },
  "service": {
    "extensions": [
      "health_check",
      "zpages",
      "pprof"
    ],
    "pipelines": {
      "logs": {
        "exporters": [],
        "processors": [
          "batch"
        ],
        "receivers": [
          "otlp"
        ]
      },
      "metrics": {
        "exporters": [],
        "processors": [
          "batch"
        ],
        "receivers": [
          "otlp"
        ]
      },
      "traces": {
        "exporters": [],
        "processors": [
          "batch"
        ],
        "receivers": [
          "otlp"
        ]
      }
    },
    "telemetry": {
      "logs": {
        "encoding": "json"
      },
      "metrics": {
        "address": "0.0.0.0:8888"
      }
    }
  }
}
</pre>
</div>
            </td>
            <td>Base configuration for the OtelAgent Collector.</td>
        </tr>
        <tr>
            <td id="otelAgent--config--processors--batch"><a href="./values.yaml#L936">otelAgent.config.processors.batch</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "send_batch_size": 10000,
  "timeout": "200ms"
}
</pre>
</div>
            </td>
            <td>Batch processor config. ref: https://github.com/open-telemetry/opentelemetry-collector/blob/main/processor/batchprocessor/README.md</td>
        </tr>
        <tr>
            <td id="otelAgent--extraVolumes"><a href="./values.yaml#L978">otelAgent.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>Additional volumes for the OtelAgent.</td>
        </tr>
        <tr>
            <td id="otelAgent--extraVolumeMounts"><a href="./values.yaml#L988">otelAgent.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
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
            <td id="otelDeployment--enabled"><a href="./values.yaml#L1000">otelDeployment.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--name"><a href="./values.yaml#L1003">otelDeployment.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"otel-deployment"
</pre>
</div>
            </td>
            <td>Name of the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--image"><a href="./values.yaml#L1006">otelDeployment.image</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "pullPolicy": "IfNotPresent",
  "registry": "docker.io",
  "repository": "otel/opentelemetry-collector-contrib",
  "tag": "0.109.0"
}
</pre>
</div>
            </td>
            <td>Image configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--image--registry"><a href="./values.yaml#L1009">otelDeployment.image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"docker.io"
</pre>
</div>
            </td>
            <td>Docker registry for the OtelDeployment image.</td>
        </tr>
        <tr>
            <td id="otelDeployment--image--repository"><a href="./values.yaml#L1012">otelDeployment.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"otel/opentelemetry-collector-contrib"
</pre>
</div>
            </td>
            <td>Repository for the OtelDeployment image.</td>
        </tr>
        <tr>
            <td id="otelDeployment--image--tag"><a href="./values.yaml#L1015">otelDeployment.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"0.109.0"
</pre>
</div>
            </td>
            <td>Tag for the OtelDeployment image.</td>
        </tr>
        <tr>
            <td id="otelDeployment--image--pullPolicy"><a href="./values.yaml#L1018">otelDeployment.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"IfNotPresent"
</pre>
</div>
            </td>
            <td>Image pull policy for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--imagePullSecrets"><a href="./values.yaml#L1022">otelDeployment.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>Image Pull Secrets for the OtelDeployment. Merged with `global.imagePullSecrets`.</td>
        </tr>
        <tr>
            <td id="otelDeployment--command"><a href="./values.yaml#L1027">otelDeployment.command</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "extraArgs": [],
  "name": "/otelcol-contrib"
}
</pre>
</div>
            </td>
            <td>Command and arguments for the OtelDeployment container.</td>
        </tr>
        <tr>
            <td id="otelDeployment--command--name"><a href="./values.yaml#L1030">otelDeployment.command.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"/otelcol-contrib"
</pre>
</div>
            </td>
            <td>OtelDeployment command name.</td>
        </tr>
        <tr>
            <td id="otelDeployment--command--extraArgs"><a href="./values.yaml#L1033">otelDeployment.command.extraArgs</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>Extra arguments for the OtelDeployment command.</td>
        </tr>
        <tr>
            <td id="otelDeployment--configMap"><a href="./values.yaml#L1037">otelDeployment.configMap</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "create": true
}
</pre>
</div>
            </td>
            <td>ConfigMap configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--configMap--create"><a href="./values.yaml#L1040">otelDeployment.configMap.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Specifies whether a ConfigMap should be created.</td>
        </tr>
        <tr>
            <td id="otelDeployment--service"><a href="./values.yaml#L1044">otelDeployment.service</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "annotations": {},
  "type": "ClusterIP"
}
</pre>
</div>
            </td>
            <td>Service configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--service--annotations"><a href="./values.yaml#L1047">otelDeployment.service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Annotations for the OtelDeployment service.</td>
        </tr>
        <tr>
            <td id="otelDeployment--service--type"><a href="./values.yaml#L1050">otelDeployment.service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
"ClusterIP"
</pre>
</div>
            </td>
            <td>Service type.</td>
        </tr>
        <tr>
            <td id="otelDeployment--serviceAccount"><a href="./values.yaml#L1054">otelDeployment.serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "annotations": {},
  "create": true,
  "name": null
}
</pre>
</div>
            </td>
            <td>ServiceAccount configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--serviceAccount--create"><a href="./values.yaml#L1057">otelDeployment.serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Specifies whether a ServiceAccount should be created.</td>
        </tr>
        <tr>
            <td id="otelDeployment--serviceAccount--annotations"><a href="./values.yaml#L1060">otelDeployment.serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Annotations for the ServiceAccount.</td>
        </tr>
        <tr>
            <td id="otelDeployment--serviceAccount--name"><a href="./values.yaml#L1063">otelDeployment.serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
null
</pre>
</div>
            </td>
            <td>The name of the ServiceAccount to use. A name is generated if not set.</td>
        </tr>
        <tr>
            <td id="otelDeployment--annotations"><a href="./values.yaml#L1067">otelDeployment.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Annotations for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--podAnnotations"><a href="./values.yaml#L1070">otelDeployment.podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Annotations for the OtelDeployment pods.</td>
        </tr>
        <tr>
            <td id="otelDeployment--additionalEnvs"><a href="./values.yaml#L1077">otelDeployment.additionalEnvs</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Additional environment variables for the OtelDeployment container.</td>
        </tr>
        <tr>
            <td id="otelDeployment--podSecurityContext"><a href="./values.yaml#L1081">otelDeployment.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Pod-level security configuration.</td>
        </tr>
        <tr>
            <td id="otelDeployment--securityContext"><a href="./values.yaml#L1086">otelDeployment.securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Container-level security configuration.</td>
        </tr>
        <tr>
            <td id="otelDeployment--minReadySeconds"><a href="./values.yaml#L1096">otelDeployment.minReadySeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
5
</pre>
</div>
            </td>
            <td>Minimum number of seconds for which a newly created Pod should be ready.</td>
        </tr>
        <tr>
            <td id="otelDeployment--progressDeadlineSeconds"><a href="./values.yaml#L1100">otelDeployment.progressDeadlineSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
120
</pre>
</div>
            </td>
            <td>Seconds to wait for the Deployment to progress before it's considered failed.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ports"><a href="./values.yaml#L1104">otelDeployment.ports</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "health-check": {
    "containerPort": 13133,
    "enabled": true,
    "nodePort": "",
    "protocol": "TCP",
    "servicePort": 13133
  },
  "metrics": {
    "containerPort": 8888,
    "enabled": false,
    "nodePort": "",
    "protocol": "TCP",
    "servicePort": 8888
  },
  "pprof": {
    "containerPort": 1777,
    "enabled": false,
    "nodePort": "",
    "protocol": "TCP",
    "servicePort": 1777
  },
  "zpages": {
    "containerPort": 55679,
    "enabled": false,
    "nodePort": "",
    "protocol": "TCP",
    "servicePort": 55679
  }
}
</pre>
</div>
            </td>
            <td>Port configurations for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ports--metrics--enabled"><a href="./values.yaml#L1109">otelDeployment.ports.metrics.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable service port for internal metrics.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ports--zpages--enabled"><a href="./values.yaml#L1122">otelDeployment.ports.zpages.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable service port for ZPages.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ports--health-check--enabled"><a href="./values.yaml#L1135">otelDeployment.ports.health-check.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Enable service port for health checks.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ports--pprof--enabled"><a href="./values.yaml#L1148">otelDeployment.ports.pprof.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable service port for pprof.</td>
        </tr>
        <tr>
            <td id="otelDeployment--livenessProbe"><a href="./values.yaml#L1160">otelDeployment.livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "enabled": true,
  "failureThreshold": 6,
  "initialDelaySeconds": 10,
  "path": "/",
  "periodSeconds": 10,
  "port": 13133,
  "successThreshold": 1,
  "timeoutSeconds": 5
}
</pre>
</div>
            </td>
            <td>Configure liveness probe.</td>
        </tr>
        <tr>
            <td id="otelDeployment--readinessProbe"><a href="./values.yaml#L1180">otelDeployment.readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "enabled": true,
  "failureThreshold": 6,
  "initialDelaySeconds": 10,
  "path": "/",
  "periodSeconds": 10,
  "port": 13133,
  "successThreshold": 1,
  "timeoutSeconds": 5
}
</pre>
</div>
            </td>
            <td>Configure readiness probe.</td>
        </tr>
        <tr>
            <td id="otelDeployment--customLivenessProbe"><a href="./values.yaml#L1200">otelDeployment.customLivenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Custom liveness probe configuration.</td>
        </tr>
        <tr>
            <td id="otelDeployment--customReadinessProbe"><a href="./values.yaml#L1204">otelDeployment.customReadinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Custom readiness probe configuration.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ingress"><a href="./values.yaml#L1208">otelDeployment.ingress</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "annotations": {},
  "className": "",
  "enabled": false,
  "hosts": [
    {
      "host": "otel-deployment.domain.com",
      "paths": [
        {
          "path": "/",
          "pathType": "ImplementationSpecific",
          "port": 13133
        }
      ]
    }
  ],
  "tls": []
}
</pre>
</div>
            </td>
            <td>Ingress configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ingress--enabled"><a href="./values.yaml#L1211">otelDeployment.ingress.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
false
</pre>
</div>
            </td>
            <td>Enable Ingress for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ingress--className"><a href="./values.yaml#L1214">otelDeployment.ingress.className</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>Ingress Class Name to be used.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ingress--annotations"><a href="./values.yaml#L1217">otelDeployment.ingress.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Annotations for the OtelDeployment Ingress.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ingress--hosts"><a href="./values.yaml#L1220">otelDeployment.ingress.hosts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[
  {
    "host": "otel-deployment.domain.com",
    "paths": [
      {
        "path": "/",
        "pathType": "ImplementationSpecific",
        "port": 13133
      }
    ]
  }
]
</pre>
</div>
            </td>
            <td>OtelDeployment Ingress hostnames.</td>
        </tr>
        <tr>
            <td id="otelDeployment--ingress--tls"><a href="./values.yaml#L1228">otelDeployment.ingress.tls</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>OtelDeployment Ingress TLS configuration.</td>
        </tr>
        <tr>
            <td id="otelDeployment--resources"><a href="./values.yaml#L1235">otelDeployment.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "requests": {
    "cpu": "100m",
    "memory": "100Mi"
  }
}
</pre>
</div>
            </td>
            <td>Configure resource requests and limits for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--priorityClassName"><a href="./values.yaml#L1246">otelDeployment.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>OtelDeployment Priority Class name.</td>
        </tr>
        <tr>
            <td id="otelDeployment--nodeSelector"><a href="./values.yaml#L1250">otelDeployment.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Node selector for OtelDeployment pod assignment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--tolerations"><a href="./values.yaml#L1254">otelDeployment.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>Toleration labels for OtelDeployment pod assignment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--affinity"><a href="./values.yaml#L1258">otelDeployment.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Affinity settings for the OtelDeployment pod.</td>
        </tr>
        <tr>
            <td id="otelDeployment--topologySpreadConstraints"><a href="./values.yaml#L1262">otelDeployment.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>Describes how OtelDeployment pods ought to spread.</td>
        </tr>
        <tr>
            <td id="otelDeployment--clusterRole"><a href="./values.yaml#L1266">otelDeployment.clusterRole</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "annotations": {},
  "clusterRoleBinding": {
    "annotations": {},
    "name": ""
  },
  "create": true,
  "name": "",
  "rules": [
    {
      "apiGroups": [
        ""
      ],
      "resources": [
        "events",
        "namespaces",
        "namespaces/status",
        "nodes",
        "nodes/spec",
        "pods",
        "pods/status",
        "replicationcontrollers",
        "replicationcontrollers/status",
        "resourcequotas",
        "services"
      ],
      "verbs": [
        "get",
        "list",
        "watch"
      ]
    },
    {
      "apiGroups": [
        "apps"
      ],
      "resources": [
        "daemonsets",
        "deployments",
        "replicasets",
        "statefulsets"
      ],
      "verbs": [
        "get",
        "list",
        "watch"
      ]
    },
    {
      "apiGroups": [
        "extensions"
      ],
      "resources": [
        "daemonsets",
        "deployments",
        "replicasets"
      ],
      "verbs": [
        "get",
        "list",
        "watch"
      ]
    },
    {
      "apiGroups": [
        "batch"
      ],
      "resources": [
        "jobs",
        "cronjobs"
      ],
      "verbs": [
        "get",
        "list",
        "watch"
      ]
    },
    {
      "apiGroups": [
        "autoscaling"
      ],
      "resources": [
        "horizontalpodautoscalers"
      ],
      "verbs": [
        "get",
        "list",
        "watch"
      ]
    }
  ]
}
</pre>
</div>
            </td>
            <td>ClusterRole configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--clusterRole--create"><a href="./values.yaml#L1269">otelDeployment.clusterRole.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
true
</pre>
</div>
            </td>
            <td>Specifies whether a ClusterRole should be created.</td>
        </tr>
        <tr>
            <td id="otelDeployment--clusterRole--annotations"><a href="./values.yaml#L1272">otelDeployment.clusterRole.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{}
</pre>
</div>
            </td>
            <td>Annotations for the ClusterRole.</td>
        </tr>
        <tr>
            <td id="otelDeployment--clusterRole--name"><a href="./values.yaml#L1275">otelDeployment.clusterRole.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
""
</pre>
</div>
            </td>
            <td>The name of the ClusterRole to use. A name is generated if not set.</td>
        </tr>
        <tr>
            <td id="otelDeployment--clusterRole--rules"><a href="./values.yaml#L1279">otelDeployment.clusterRole.rules</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="">
"Please checkout the values.yml for default values"
</pre>
</div>
            </td>
            <td>RBAC rules for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--clusterRole--clusterRoleBinding"><a href="./values.yaml#L1309">otelDeployment.clusterRole.clusterRoleBinding</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "annotations": {},
  "name": ""
}
</pre>
</div>
            </td>
            <td>ClusterRoleBinding configuration for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--config"><a href="./values.yaml#L1319">otelDeployment.config</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "exporters": {},
  "extensions": {
    "health_check": {
      "endpoint": "0.0.0.0:13133"
    },
    "pprof": {
      "endpoint": "localhost:1777"
    },
    "zpages": {
      "endpoint": "localhost:55679"
    }
  },
  "processors": {
    "batch": {
      "send_batch_size": 10000,
      "timeout": "1s"
    }
  },
  "receivers": {},
  "service": {
    "extensions": [
      "health_check",
      "zpages",
      "pprof"
    ],
    "pipelines": {
      "logs": {
        "exporters": [],
        "processors": [
          "batch"
        ],
        "receivers": []
      },
      "metrics/internal": {
        "exporters": [],
        "processors": [
          "batch"
        ],
        "receivers": []
      },
      "metrics/scraper": {
        "exporters": [],
        "processors": [
          "batch"
        ],
        "receivers": []
      }
    },
    "telemetry": {
      "logs": {
        "encoding": "json"
      },
      "metrics": {
        "address": "0.0.0.0:8888"
      }
    }
  }
}
</pre>
</div>
            </td>
            <td>Base configuration for the OtelDeployment Collector.</td>
        </tr>
        <tr>
            <td id="otelDeployment--config--processors--batch"><a href="./values.yaml#L1326">otelDeployment.config.processors.batch</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
{
  "send_batch_size": 10000,
  "timeout": "1s"
}
</pre>
</div>
            </td>
            <td>Batch processor config.</td>
        </tr>
        <tr>
            <td id="otelDeployment--extraVolumes"><a href="./values.yaml#L1366">otelDeployment.extraVolumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>Additional volumes for the OtelDeployment.</td>
        </tr>
        <tr>
            <td id="otelDeployment--extraVolumeMounts"><a href="./values.yaml#L1376">otelDeployment.extraVolumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="json">
[]
</pre>
</div>
            </td>
            <td>Additional volume mounts for the OtelDeployment.</td>
        </tr>
    </tbody>
</table>

