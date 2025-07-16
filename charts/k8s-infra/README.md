
# SigNoz

![Version: 0.13.0](https://img.shields.io/badge/Version-0.13.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.109.0](https://img.shields.io/badge/AppVersion-0.109.0-informational?style=flat-square)

SigNoz is an open-source APM. It helps developers monitor their applications & troubleshoot problems,
an open-source alternative to DataDog, NewRelic, etc. Open source Application Performance Monitoring (APM)
& Observability tool.

### TL;DR;

```sh
helm repo add signoz https://charts.signoz.io
helm install -n platform --create-namespace "my-release" signoz/k8s-infra
```

### Introduction

The `k8s-infra` chart provides Kubernetes infrastructure observability by deploying OpenTelemetry components and related resources using the [Helm](https://helm.sh) package manager.

It enables collection of metrics, logs, and events from your Kubernetes cluster, making it easier to monitor and troubleshoot your infrastructure with SigNoz.

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

<h2> Configuration </h2>

<table height="400px" >
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
				<div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div>
			</td>
			<td>Overrides the Docker registry globally for all images</td>
		</tr>
		<tr>
			<td id="global--imagePullSecrets"><a href="./values.yaml#L6">global.imagePullSecrets</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>Global Image Pull Secrets</td>
		</tr>
		<tr>
			<td id="global--storageClass"><a href="./values.yaml#L8">global.storageClass</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div>
			</td>
			<td>Overrides the storage class for all PVC with persistence enabled.</td>
		</tr>
		<tr>
			<td id="global--clusterDomain"><a href="./values.yaml#L11">global.clusterDomain</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"cluster.local"
</pre>
</div>
			</td>
			<td>Kubernetes cluster domain It is used only when components are installed in different namespace</td>
		</tr>
		<tr>
			<td id="global--clusterName"><a href="./values.yaml#L14">global.clusterName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Kubernetes cluster name It is used to attached to telemetry data via resource detection processor</td>
		</tr>
		<tr>
			<td id="global--deploymentEnvironment"><a href="./values.yaml#L16">global.deploymentEnvironment</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Deployment environment to be attached to telemetry data</td>
		</tr>
		<tr>
			<td id="global--cloud"><a href="./values.yaml#L19">global.cloud</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"other"
</pre>
</div>
			</td>
			<td>Kubernetes cluster cloud provider along with distribution if any. example: `aws`, `azure`, `gcp`, `gcp/autogke`, `azure`, and `other`</td>
		</tr>
		<tr>
			<td id="nameOverride"><a href="./values.yaml#L22">nameOverride</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>K8s infra chart name override</td>
		</tr>
		<tr>
			<td id="fullnameOverride"><a href="./values.yaml#L25">fullnameOverride</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>K8s infra chart full name override</td>
		</tr>
		<tr>
			<td id="enabled"><a href="./values.yaml#L28">enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Whether to enable K8s infra chart</td>
		</tr>
		<tr>
			<td id="clusterName"><a href="./values.yaml#L31">clusterName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Name of the K8s cluster. Used by OtelCollectors to attach in telemetry data.</td>
		</tr>
		<tr>
			<td id="otelCollectorEndpoint"><a href="./values.yaml#L38">otelCollectorEndpoint</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div>
			</td>
			<td>Endpoint/IP Address of the SigNoz or any other OpenTelemetry backend. Set it to `ingest.signoz.io:4317` for SigNoz SaaS.  If set to null and the chart is installed as dependency, it will attempt to autogenerate the endpoint of SigNoz OtelCollector.</td>
		</tr>
		<tr>
			<td id="otelInsecure"><a href="./values.yaml#L42">otelInsecure</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Whether the OTLP endpoint is insecure. Set this to false, in case of secure OTLP endpoint.</td>
		</tr>
		<tr>
			<td id="insecureSkipVerify"><a href="./values.yaml#L45">insecureSkipVerify</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Whether to skip verifying the certificate.</td>
		</tr>
		<tr>
			<td id="signozApiKey"><a href="./values.yaml#L48">signozApiKey</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>API key of SigNoz SaaS</td>
		</tr>
		<tr>
			<td id="apiKeyExistingSecretName"><a href="./values.yaml#L50">apiKeyExistingSecretName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Existing secret name to be used for API key.</td>
		</tr>
		<tr>
			<td id="apiKeyExistingSecretKey"><a href="./values.yaml#L52">apiKeyExistingSecretKey</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Existing secret key to be used for API key.</td>
		</tr>
		<tr>
			<td id="otelTlsSecrets--enabled"><a href="./values.yaml#L57">otelTlsSecrets.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Whether to enable OpenTelemetry OTLP secrets</td>
		</tr>
		<tr>
			<td id="otelTlsSecrets--path"><a href="./values.yaml#L60">otelTlsSecrets.path</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"/secrets"
</pre>
</div>
			</td>
			<td>Path for the secrets volume</td>
		</tr>
		<tr>
			<td id="otelTlsSecrets--existingSecretName"><a href="./values.yaml#L64">otelTlsSecrets.existingSecretName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div>
			</td>
			<td>Name of the existing secret with TLS certificate, key and CA to be used. Files in the secret must be named `cert.pem`, `key.pem` and `ca.pem`.</td>
		</tr>
		<tr>
			<td id="otelTlsSecrets--certificate"><a href="./values.yaml#L67">otelTlsSecrets.certificate</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"\u003cINCLUDE_CERTIFICATE_HERE\u003e\n"
</pre>
</div>
			</td>
			<td>TLS certificate to be included in the secret</td>
		</tr>
		<tr>
			<td id="otelTlsSecrets--key"><a href="./values.yaml#L71">otelTlsSecrets.key</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"\u003cINCLUDE_PRIVATE_KEY_HERE\u003e\n"
</pre>
</div>
			</td>
			<td>TLS private key to be included in the secret</td>
		</tr>
		<tr>
			<td id="otelTlsSecrets--ca"><a href="./values.yaml#L75">otelTlsSecrets.ca</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>TLS certificate authority (CA) certificate to be included in the secret</td>
		</tr>
		<tr>
			<td id="namespace"><a href="./values.yaml#L79">namespace</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Which namespace to install k8s-infra components. By default installed to the namespace same as the chart.</td>
		</tr>
		<tr>
			<td id="presets"><a href="./values.yaml#L82">presets</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{
  "clusterMetrics": {
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
  },
  "hostMetrics": {
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
  },
  "k8sEvents": {
    "authType": "serviceAccount",
    "enabled": true,
    "namespaces": []
  },
  "kubeletMetrics": {
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
  },
  "kubernetesAttributes": {
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
  },
  "loggingExporter": {
    "enabled": false,
    "samplingInitial": 2,
    "samplingThereafter": 500,
    "verbosity": "basic"
  },
  "logsCollection": {
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
  },
  "otlpExporter": {
    "enabled": true
  },
  "prometheus": {
    "annotationsPrefix": "signoz.io",
    "enabled": false,
    "includeContainerName": false,
    "includePodLabel": false,
    "namespaceScoped": false,
    "namespaces": [],
    "scrapeInterval": "60s"
  },
  "resourceDetection": {
    "enabled": true,
    "envResourceAttributes": "",
    "override": false,
    "timeout": "2s"
  },
  "selfTelemetry": {
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
}
</pre>
</div>
			</td>
			<td>Presets to easily set up OtelCollector configurations.</td>
		</tr>
		<tr>
			<td id="presets--selfTelemetry--signozApiKey"><a href="./values.yaml#L101">presets.selfTelemetry.signozApiKey</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>API key of SigNoz SaaS</td>
		</tr>
		<tr>
			<td id="presets--selfTelemetry--apiKeyExistingSecretName"><a href="./values.yaml#L103">presets.selfTelemetry.apiKeyExistingSecretName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Existing secret name to be used for API key.</td>
		</tr>
		<tr>
			<td id="presets--selfTelemetry--apiKeyExistingSecretKey"><a href="./values.yaml#L105">presets.selfTelemetry.apiKeyExistingSecretKey</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Existing secret key to be used for API key.</td>
		</tr>
		<tr>
			<td id="presets--kubernetesAttributes--passthrough"><a href="./values.yaml#L267">presets.kubernetesAttributes.passthrough</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Whether to detect the IP address of agents and add it as an attribute to all telemetry resources. If set to true, Agents will not make any k8s API calls, do any discovery of pods or extract any metadata.</td>
		</tr>
		<tr>
			<td id="presets--kubernetesAttributes--filter"><a href="./values.yaml#L270">presets.kubernetesAttributes.filter</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{
  "node_from_env_var": "K8S_NODE_NAME"
}
</pre>
</div>
			</td>
			<td>Filters can be used to limit each OpenTelemetry agent to query pods based on specific selector to only dramatically reducing resource requirements for very large clusters.</td>
		</tr>
		<tr>
			<td id="presets--kubernetesAttributes--filter--node_from_env_var"><a href="./values.yaml#L272">presets.kubernetesAttributes.filter.node_from_env_var</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"K8S_NODE_NAME"
</pre>
</div>
			</td>
			<td>Restrict each OpenTelemetry agent to query pods running on the same node</td>
		</tr>
		<tr>
			<td id="presets--kubernetesAttributes--podAssociation"><a href="./values.yaml#L275">presets.kubernetesAttributes.podAssociation</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[
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
</pre>
</div>
			</td>
			<td>Pod Association section allows to define rules for tagging spans, metrics, and logs with Pod metadata.</td>
		</tr>
		<tr>
			<td id="presets--kubernetesAttributes--extractMetadatas"><a href="./values.yaml#L285">presets.kubernetesAttributes.extractMetadatas</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[
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
]
</pre>
</div>
			</td>
			<td>Which pod/namespace metadata to extract from a list of default metadata fields.</td>
		</tr>
		<tr>
			<td id="presets--kubernetesAttributes--extractLabels"><a href="./values.yaml#L298">presets.kubernetesAttributes.extractLabels</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>Which labels to extract from a list of metadata fields.</td>
		</tr>
		<tr>
			<td id="presets--kubernetesAttributes--extractAnnotations"><a href="./values.yaml#L300">presets.kubernetesAttributes.extractAnnotations</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>Which annotations to extract from a list of metadata fields.</td>
		</tr>
		<tr>
			<td id="presets--prometheus--enabled"><a href="./values.yaml#L333">presets.prometheus.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Whether to enable metrics scraping using pod annotation</td>
		</tr>
		<tr>
			<td id="presets--prometheus--annotationsPrefix"><a href="./values.yaml#L335">presets.prometheus.annotationsPrefix</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"signoz.io"
</pre>
</div>
			</td>
			<td>Prefix for the pod annotations to be used for metrics scraping</td>
		</tr>
		<tr>
			<td id="presets--prometheus--scrapeInterval"><a href="./values.yaml#L337">presets.prometheus.scrapeInterval</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"60s"
</pre>
</div>
			</td>
			<td>How often to scrape metrics</td>
		</tr>
		<tr>
			<td id="presets--prometheus--namespaceScoped"><a href="./values.yaml#L339">presets.prometheus.namespaceScoped</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Whether to only scrape metrics from pods in the same namespace</td>
		</tr>
		<tr>
			<td id="presets--prometheus--namespaces"><a href="./values.yaml#L341">presets.prometheus.namespaces</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>If set, only scrape metrics from pods in the specified namespaces</td>
		</tr>
		<tr>
			<td id="presets--prometheus--includePodLabel"><a href="./values.yaml#L344">presets.prometheus.includePodLabel</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>This will include all pod labels in the metrics, could potentially cause performance issues with large number of pods with many labels</td>
		</tr>
		<tr>
			<td id="presets--prometheus--includeContainerName"><a href="./values.yaml#L348">presets.prometheus.includeContainerName</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>This is not recommended in case of multiple containers or init containers in a pod Since it will create multiple timeseries for the same pod metrics with different container names containers with `-init` suffix in the name will be ignored</td>
		</tr>
		<tr>
			<td id="presets--k8sEvents--namespaces"><a href="./values.yaml#L359">presets.k8sEvents.namespaces</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>List of namespaces to watch for events. all namespaces by default</td>
		</tr>
		<tr>
			<td id="otelAgent--enabled"><a href="./values.yaml#L363">otelAgent.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelAgent--name"><a href="./values.yaml#L364">otelAgent.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"otel-agent"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelAgent--image--registry"><a href="./values.yaml#L366">otelAgent.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"docker.io"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelAgent--image--repository"><a href="./values.yaml#L367">otelAgent.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"otel/opentelemetry-collector-contrib"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelAgent--image--tag"><a href="./values.yaml#L368">otelAgent.image.tag</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"0.109.0"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelAgent--image--pullPolicy"><a href="./values.yaml#L369">otelAgent.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"IfNotPresent"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelAgent--imagePullSecrets"><a href="./values.yaml#L373">otelAgent.imagePullSecrets</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>Image Registry Secret Names for OtelAgent. If global.imagePullSecrets is set as well, it will merged.</td>
		</tr>
		<tr>
			<td id="otelAgent--command--name"><a href="./values.yaml#L379">otelAgent.command.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"/otelcol-contrib"
</pre>
</div>
			</td>
			<td>OtelAgent command name</td>
		</tr>
		<tr>
			<td id="otelAgent--command--extraArgs"><a href="./values.yaml#L381">otelAgent.command.extraArgs</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>OtelAgent command extra arguments</td>
		</tr>
		<tr>
			<td id="otelAgent--configMap--create"><a href="./values.yaml#L385">otelAgent.configMap.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Specifies whether a configMap should be created (true by default)</td>
		</tr>
		<tr>
			<td id="otelAgent--service--annotations"><a href="./values.yaml#L390">otelAgent.service.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Annotations to use by service associated to OtelAgent</td>
		</tr>
		<tr>
			<td id="otelAgent--service--type"><a href="./values.yaml#L392">otelAgent.service.type</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ClusterIP"
</pre>
</div>
			</td>
			<td>Service Type: LoadBalancer (allows external access) or NodePort (more secure, no extra cost)</td>
		</tr>
		<tr>
			<td id="otelAgent--service--internalTrafficPolicy"><a href="./values.yaml#L395">otelAgent.service.internalTrafficPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"Local"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelAgent--serviceAccount--create"><a href="./values.yaml#L399">otelAgent.serviceAccount.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelAgent--serviceAccount--annotations"><a href="./values.yaml#L401">otelAgent.serviceAccount.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelAgent--serviceAccount--name"><a href="./values.yaml#L404">otelAgent.serviceAccount.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelAgent--annotations"><a href="./values.yaml#L407">otelAgent.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>OtelAgent daemonset annotation.</td>
		</tr>
		<tr>
			<td id="otelAgent--podAnnotations"><a href="./values.yaml#L409">otelAgent.podAnnotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>OtelAgent pod(s) annotation.</td>
		</tr>
		<tr>
			<td id="otelAgent--additionalEnvs"><a href="./values.yaml#L415">otelAgent.additionalEnvs</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Additional environments to set for OtelAgent</td>
		</tr>
		<tr>
			<td id="otelAgent--minReadySeconds"><a href="./values.yaml#L434">otelAgent.minReadySeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td>Minimum number of seconds for which a newly created Pod should be ready without any of its containers crashing, for it to be considered available.</td>
		</tr>
		<tr>
			<td id="otelAgent--clusterRole--create"><a href="./values.yaml#L439">otelAgent.clusterRole.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Specifies whether a clusterRole should be created</td>
		</tr>
		<tr>
			<td id="otelAgent--clusterRole--annotations"><a href="./values.yaml#L441">otelAgent.clusterRole.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Annotations to add to the clusterRole</td>
		</tr>
		<tr>
			<td id="otelAgent--clusterRole--name"><a href="./values.yaml#L444">otelAgent.clusterRole.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>The name of the clusterRole to use. If not set and create is true, a name is generated using the fullname template</td>
		</tr>
		<tr>
			<td id="otelAgent--clusterRole--rules"><a href="./values.yaml#L448">otelAgent.clusterRole.rules</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="">
See `values.yaml` for defaults
</pre>
</div>
			</td>
			<td>A set of rules as documented here. ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/</td>
		</tr>
		<tr>
			<td id="otelAgent--clusterRole--clusterRoleBinding--annotations"><a href="./values.yaml#L480">otelAgent.clusterRole.clusterRoleBinding.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelAgent--clusterRole--clusterRoleBinding--name"><a href="./values.yaml#L483">otelAgent.clusterRole.clusterRoleBinding.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelAgent--ports--otlp--enabled"><a href="./values.yaml#L489">otelAgent.ports.otlp.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Whether to enable service port for OTLP gRPC</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--otlp--containerPort"><a href="./values.yaml#L491">otelAgent.ports.otlp.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
4317
</pre>
</div>
			</td>
			<td>Container port for OTLP gRPC</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--otlp--servicePort"><a href="./values.yaml#L493">otelAgent.ports.otlp.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
4317
</pre>
</div>
			</td>
			<td>Service port for OTLP gRPC</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--otlp--nodePort"><a href="./values.yaml#L495">otelAgent.ports.otlp.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Node port for OTLP gRPC</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--otlp--hostPort"><a href="./values.yaml#L497">otelAgent.ports.otlp.hostPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
4317
</pre>
</div>
			</td>
			<td>Host port for OTLP gRPC</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--otlp--protocol"><a href="./values.yaml#L499">otelAgent.ports.otlp.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"TCP"
</pre>
</div>
			</td>
			<td>Protocol to use for OTLP gRPC</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--otlp-http--enabled"><a href="./values.yaml#L502">otelAgent.ports.otlp-http.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Whether to enable service port for OTLP HTTP</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--otlp-http--containerPort"><a href="./values.yaml#L504">otelAgent.ports.otlp-http.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
4318
</pre>
</div>
			</td>
			<td>Container port for OTLP HTTP</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--otlp-http--servicePort"><a href="./values.yaml#L506">otelAgent.ports.otlp-http.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
4318
</pre>
</div>
			</td>
			<td>Service port for OTLP HTTP</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--otlp-http--nodePort"><a href="./values.yaml#L508">otelAgent.ports.otlp-http.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Node port for OTLP HTTP</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--otlp-http--hostPort"><a href="./values.yaml#L510">otelAgent.ports.otlp-http.hostPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
4318
</pre>
</div>
			</td>
			<td>Host port for OTLP HTTP</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--otlp-http--protocol"><a href="./values.yaml#L512">otelAgent.ports.otlp-http.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"TCP"
</pre>
</div>
			</td>
			<td>Protocol to use for OTLP HTTP</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--zipkin--enabled"><a href="./values.yaml#L515">otelAgent.ports.zipkin.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Whether to enable service port for Zipkin</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--zipkin--containerPort"><a href="./values.yaml#L517">otelAgent.ports.zipkin.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
9411
</pre>
</div>
			</td>
			<td>Container port for Zipkin</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--zipkin--servicePort"><a href="./values.yaml#L519">otelAgent.ports.zipkin.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
9411
</pre>
</div>
			</td>
			<td>Service port for Zipkin</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--zipkin--nodePort"><a href="./values.yaml#L521">otelAgent.ports.zipkin.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Node port for Zipkin</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--zipkin--hostPort"><a href="./values.yaml#L523">otelAgent.ports.zipkin.hostPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
9411
</pre>
</div>
			</td>
			<td>Host port for Zipkin</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--zipkin--protocol"><a href="./values.yaml#L525">otelAgent.ports.zipkin.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"TCP"
</pre>
</div>
			</td>
			<td>Protocol to use for Zipkin</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--metrics--enabled"><a href="./values.yaml#L528">otelAgent.ports.metrics.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Whether to enable service port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--metrics--containerPort"><a href="./values.yaml#L530">otelAgent.ports.metrics.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
8888
</pre>
</div>
			</td>
			<td>Container port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--metrics--servicePort"><a href="./values.yaml#L532">otelAgent.ports.metrics.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
8888
</pre>
</div>
			</td>
			<td>Service port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--metrics--nodePort"><a href="./values.yaml#L534">otelAgent.ports.metrics.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Node port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--metrics--hostPort"><a href="./values.yaml#L536">otelAgent.ports.metrics.hostPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
8888
</pre>
</div>
			</td>
			<td>Host port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--metrics--protocol"><a href="./values.yaml#L538">otelAgent.ports.metrics.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"TCP"
</pre>
</div>
			</td>
			<td>Protocol to use for internal metrics</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--zpages--enabled"><a href="./values.yaml#L541">otelAgent.ports.zpages.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Whether to enable service port for ZPages</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--zpages--containerPort"><a href="./values.yaml#L543">otelAgent.ports.zpages.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
55679
</pre>
</div>
			</td>
			<td>Container port for Zpages</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--zpages--servicePort"><a href="./values.yaml#L545">otelAgent.ports.zpages.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
55679
</pre>
</div>
			</td>
			<td>Service port for Zpages</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--zpages--nodePort"><a href="./values.yaml#L547">otelAgent.ports.zpages.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Node port for Zpages</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--zpages--hostPort"><a href="./values.yaml#L549">otelAgent.ports.zpages.hostPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
55679
</pre>
</div>
			</td>
			<td>Host port for Zpages</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--zpages--protocol"><a href="./values.yaml#L551">otelAgent.ports.zpages.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"TCP"
</pre>
</div>
			</td>
			<td>Protocol to use for Zpages</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--health-check--enabled"><a href="./values.yaml#L554">otelAgent.ports.health-check.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Whether to enable service port for health check</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--health-check--containerPort"><a href="./values.yaml#L556">otelAgent.ports.health-check.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
13133
</pre>
</div>
			</td>
			<td>Container port for health check</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--health-check--servicePort"><a href="./values.yaml#L558">otelAgent.ports.health-check.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
13133
</pre>
</div>
			</td>
			<td>Service port for health check</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--health-check--nodePort"><a href="./values.yaml#L560">otelAgent.ports.health-check.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Node port for health check</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--health-check--hostPort"><a href="./values.yaml#L562">otelAgent.ports.health-check.hostPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
13133
</pre>
</div>
			</td>
			<td>Host port for health check</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--health-check--protocol"><a href="./values.yaml#L564">otelAgent.ports.health-check.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"TCP"
</pre>
</div>
			</td>
			<td>Protocol to use for health check</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--pprof--enabled"><a href="./values.yaml#L567">otelAgent.ports.pprof.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Whether to enable service port for pprof</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--pprof--containerPort"><a href="./values.yaml#L569">otelAgent.ports.pprof.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1777
</pre>
</div>
			</td>
			<td>Container port for pprof</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--pprof--servicePort"><a href="./values.yaml#L571">otelAgent.ports.pprof.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1777
</pre>
</div>
			</td>
			<td>Service port for pprof</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--pprof--nodePort"><a href="./values.yaml#L573">otelAgent.ports.pprof.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Node port for pprof</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--pprof--hostPort"><a href="./values.yaml#L575">otelAgent.ports.pprof.hostPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1777
</pre>
</div>
			</td>
			<td>Host port for pprof</td>
		</tr>
		<tr>
			<td id="otelAgent--ports--pprof--protocol"><a href="./values.yaml#L577">otelAgent.ports.pprof.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"TCP"
</pre>
</div>
			</td>
			<td>Protocol to use for pprof</td>
		</tr>
		<tr>
			<td id="otelAgent--livenessProbe"><a href="./values.yaml#L581">otelAgent.livenessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
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
			<td id="otelAgent--readinessProbe"><a href="./values.yaml#L593">otelAgent.readinessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
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
			<td id="otelAgent--customLivenessProbe"><a href="./values.yaml#L604">otelAgent.customLivenessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Custom liveness probe</td>
		</tr>
		<tr>
			<td id="otelAgent--customReadinessProbe"><a href="./values.yaml#L606">otelAgent.customReadinessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Custom readiness probe</td>
		</tr>
		<tr>
			<td id="otelAgent--ingress--enabled"><a href="./values.yaml#L610">otelAgent.ingress.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Enable ingress for OtelAgent</td>
		</tr>
		<tr>
			<td id="otelAgent--ingress--className"><a href="./values.yaml#L612">otelAgent.ingress.className</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Ingress Class Name to be used to identify ingress controllers</td>
		</tr>
		<tr>
			<td id="otelAgent--ingress--annotations"><a href="./values.yaml#L614">otelAgent.ingress.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Annotations to OtelAgent Ingress</td>
		</tr>
		<tr>
			<td id="otelAgent--ingress--hosts"><a href="./values.yaml#L621">otelAgent.ingress.hosts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
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
			<td>OtelAgent Ingress Host names with their path details</td>
		</tr>
		<tr>
			<td id="otelAgent--ingress--tls"><a href="./values.yaml#L628">otelAgent.ingress.tls</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>OtelAgent Ingress TLS</td>
		</tr>
		<tr>
			<td id="otelAgent--resources"><a href="./values.yaml#L637">otelAgent.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="">
See `values.yaml` for defaults
</pre>
</div>
			</td>
			<td>Configure resource requests and limits. Update according to your own use case as these values might not be suitable for your workload. ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
		</tr>
		<tr>
			<td id="otelAgent--priorityClassName"><a href="./values.yaml#L646">otelAgent.priorityClassName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>OtelAgent priority class name</td>
		</tr>
		<tr>
			<td id="otelAgent--nodeSelector"><a href="./values.yaml#L649">otelAgent.nodeSelector</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>OtelAgent node selector</td>
		</tr>
		<tr>
			<td id="otelAgent--tolerations"><a href="./values.yaml#L652">otelAgent.tolerations</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[
  {
    "operator": "Exists"
  }
]
</pre>
</div>
			</td>
			<td>Toleration labels for OtelAgent pod assignment</td>
		</tr>
		<tr>
			<td id="otelAgent--affinity"><a href="./values.yaml#L656">otelAgent.affinity</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Affinity settings for OtelAgent pod</td>
		</tr>
		<tr>
			<td id="otelAgent--podSecurityContext"><a href="./values.yaml#L659">otelAgent.podSecurityContext</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Pod-level security configuration</td>
		</tr>
		<tr>
			<td id="otelAgent--securityContext"><a href="./values.yaml#L663">otelAgent.securityContext</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Container security configuration</td>
		</tr>
		<tr>
			<td id="otelAgent--config"><a href="./values.yaml#L673">otelAgent.config</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="">
See `values.yaml` for defaults
</pre>
</div>
			</td>
			<td>Configurations for OtelAgent</td>
		</tr>
		<tr>
			<td id="otelAgent--extraVolumes"><a href="./values.yaml#L722">otelAgent.extraVolumes</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>Additional volumes for otelAgent</td>
		</tr>
		<tr>
			<td id="otelAgent--extraVolumeMounts"><a href="./values.yaml#L731">otelAgent.extraVolumeMounts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>Additional volume mounts for otelAgent</td>
		</tr>
		<tr>
			<td id="otelDeployment--enabled"><a href="./values.yaml#L740">otelDeployment.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelDeployment--name"><a href="./values.yaml#L741">otelDeployment.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"otel-deployment"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelDeployment--image--registry"><a href="./values.yaml#L743">otelDeployment.image.registry</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"docker.io"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelDeployment--image--repository"><a href="./values.yaml#L744">otelDeployment.image.repository</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"otel/opentelemetry-collector-contrib"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelDeployment--image--tag"><a href="./values.yaml#L745">otelDeployment.image.tag</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"0.109.0"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelDeployment--image--pullPolicy"><a href="./values.yaml#L746">otelDeployment.image.pullPolicy</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"IfNotPresent"
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelDeployment--imagePullSecrets"><a href="./values.yaml#L750">otelDeployment.imagePullSecrets</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>Image Registry Secret Names for OtelDeployment. If global.imagePullSecrets is set as well, it will merged.</td>
		</tr>
		<tr>
			<td id="otelDeployment--command--name"><a href="./values.yaml#L756">otelDeployment.command.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"/otelcol-contrib"
</pre>
</div>
			</td>
			<td>OtelDeployment command name</td>
		</tr>
		<tr>
			<td id="otelDeployment--command--extraArgs"><a href="./values.yaml#L758">otelDeployment.command.extraArgs</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>OtelDeployment command extra arguments</td>
		</tr>
		<tr>
			<td id="otelDeployment--configMap--create"><a href="./values.yaml#L762">otelDeployment.configMap.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Specifies whether a configMap should be created (true by default)</td>
		</tr>
		<tr>
			<td id="otelDeployment--service--annotations"><a href="./values.yaml#L767">otelDeployment.service.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Annotations to use by service associated to OtelDeployment</td>
		</tr>
		<tr>
			<td id="otelDeployment--service--type"><a href="./values.yaml#L769">otelDeployment.service.type</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"ClusterIP"
</pre>
</div>
			</td>
			<td>Service Type: LoadBalancer (allows external access) or NodePort (more secure, no extra cost)</td>
		</tr>
		<tr>
			<td id="otelDeployment--serviceAccount--create"><a href="./values.yaml#L773">otelDeployment.serviceAccount.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelDeployment--serviceAccount--annotations"><a href="./values.yaml#L775">otelDeployment.serviceAccount.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelDeployment--serviceAccount--name"><a href="./values.yaml#L778">otelDeployment.serviceAccount.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
null
</pre>
</div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td id="otelDeployment--annotations"><a href="./values.yaml#L781">otelDeployment.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>OtelDeployment deployment annotation.</td>
		</tr>
		<tr>
			<td id="otelDeployment--podAnnotations"><a href="./values.yaml#L783">otelDeployment.podAnnotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>OtelDeployment pod(s) annotation.</td>
		</tr>
		<tr>
			<td id="otelDeployment--additionalEnvs"><a href="./values.yaml#L789">otelDeployment.additionalEnvs</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Additional environments to set for OtelDeployment</td>
		</tr>
		<tr>
			<td id="otelDeployment--podSecurityContext"><a href="./values.yaml#L807">otelDeployment.podSecurityContext</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Pod-level security configuration</td>
		</tr>
		<tr>
			<td id="otelDeployment--securityContext"><a href="./values.yaml#L811">otelDeployment.securityContext</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Container security configuration</td>
		</tr>
		<tr>
			<td id="otelDeployment--minReadySeconds"><a href="./values.yaml#L821">otelDeployment.minReadySeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
5
</pre>
</div>
			</td>
			<td>Minimum number of seconds for which a newly created Pod should be ready without any of its containers crashing, for it to be considered available.</td>
		</tr>
		<tr>
			<td id="otelDeployment--progressDeadlineSeconds"><a href="./values.yaml#L825">otelDeployment.progressDeadlineSeconds</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
120
</pre>
</div>
			</td>
			<td>Number of seconds to wait for the OtelDeployment to progress before the system reports back that the OtelDeployment has failed.</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--metrics--enabled"><a href="./values.yaml#L831">otelDeployment.ports.metrics.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Whether to enable service port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--metrics--containerPort"><a href="./values.yaml#L833">otelDeployment.ports.metrics.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
8888
</pre>
</div>
			</td>
			<td>Container port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--metrics--servicePort"><a href="./values.yaml#L835">otelDeployment.ports.metrics.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
8888
</pre>
</div>
			</td>
			<td>Service port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--metrics--nodePort"><a href="./values.yaml#L837">otelDeployment.ports.metrics.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Node port for internal metrics</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--metrics--protocol"><a href="./values.yaml#L839">otelDeployment.ports.metrics.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"TCP"
</pre>
</div>
			</td>
			<td>Protocol to use for internal metrics</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--zpages--enabled"><a href="./values.yaml#L842">otelDeployment.ports.zpages.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Whether to enable service port for ZPages</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--zpages--containerPort"><a href="./values.yaml#L844">otelDeployment.ports.zpages.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
55679
</pre>
</div>
			</td>
			<td>Container port for Zpages</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--zpages--servicePort"><a href="./values.yaml#L846">otelDeployment.ports.zpages.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
55679
</pre>
</div>
			</td>
			<td>Service port for Zpages</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--zpages--nodePort"><a href="./values.yaml#L848">otelDeployment.ports.zpages.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Node port for Zpages</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--zpages--protocol"><a href="./values.yaml#L850">otelDeployment.ports.zpages.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"TCP"
</pre>
</div>
			</td>
			<td>Protocol to use for Zpages</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--health-check--enabled"><a href="./values.yaml#L853">otelDeployment.ports.health-check.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Whether to enable service port for health check</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--health-check--containerPort"><a href="./values.yaml#L855">otelDeployment.ports.health-check.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
13133
</pre>
</div>
			</td>
			<td>Container port for health check</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--health-check--servicePort"><a href="./values.yaml#L857">otelDeployment.ports.health-check.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
13133
</pre>
</div>
			</td>
			<td>Service port for health check</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--health-check--nodePort"><a href="./values.yaml#L859">otelDeployment.ports.health-check.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Node port for health check</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--health-check--protocol"><a href="./values.yaml#L861">otelDeployment.ports.health-check.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"TCP"
</pre>
</div>
			</td>
			<td>Protocol to use for health check</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--pprof--enabled"><a href="./values.yaml#L864">otelDeployment.ports.pprof.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Whether to enable service port for pprof</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--pprof--containerPort"><a href="./values.yaml#L866">otelDeployment.ports.pprof.containerPort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1777
</pre>
</div>
			</td>
			<td>Container port for pprof</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--pprof--servicePort"><a href="./values.yaml#L868">otelDeployment.ports.pprof.servicePort</a></td>
			<td>int</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
1777
</pre>
</div>
			</td>
			<td>Service port for pprof</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--pprof--nodePort"><a href="./values.yaml#L870">otelDeployment.ports.pprof.nodePort</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Node port for pprof</td>
		</tr>
		<tr>
			<td id="otelDeployment--ports--pprof--protocol"><a href="./values.yaml#L872">otelDeployment.ports.pprof.protocol</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
"TCP"
</pre>
</div>
			</td>
			<td>Protocol to use for pprof</td>
		</tr>
		<tr>
			<td id="otelDeployment--livenessProbe"><a href="./values.yaml#L876">otelDeployment.livenessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
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
			<td id="otelDeployment--readinessProbe"><a href="./values.yaml#L888">otelDeployment.readinessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
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
			<td id="otelDeployment--customLivenessProbe"><a href="./values.yaml#L899">otelDeployment.customLivenessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Custom liveness probe</td>
		</tr>
		<tr>
			<td id="otelDeployment--customReadinessProbe"><a href="./values.yaml#L902">otelDeployment.customReadinessProbe</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Custom readiness probe</td>
		</tr>
		<tr>
			<td id="otelDeployment--ingress--enabled"><a href="./values.yaml#L906">otelDeployment.ingress.enabled</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
false
</pre>
</div>
			</td>
			<td>Enable ingress for OtelDeployment</td>
		</tr>
		<tr>
			<td id="otelDeployment--ingress--className"><a href="./values.yaml#L908">otelDeployment.ingress.className</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>Ingress Class Name to be used to identify ingress controllers</td>
		</tr>
		<tr>
			<td id="otelDeployment--ingress--annotations"><a href="./values.yaml#L910">otelDeployment.ingress.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Annotations to OtelDeployment Ingress</td>
		</tr>
		<tr>
			<td id="otelDeployment--ingress--hosts"><a href="./values.yaml#L917">otelDeployment.ingress.hosts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
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
			<td>OtelDeployment Ingress Host names with their path details</td>
		</tr>
		<tr>
			<td id="otelDeployment--ingress--tls"><a href="./values.yaml#L924">otelDeployment.ingress.tls</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>OtelDeployment Ingress TLS</td>
		</tr>
		<tr>
			<td id="otelDeployment--resources"><a href="./values.yaml#L933">otelDeployment.resources</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="">
See `values.yaml` for defaults
</pre>
</div>
			</td>
			<td>Configure resource requests and limits. Update according to your own use case as these values might not be suitable for your workload. ref: http://kubernetes.io/docs/user-guide/compute-resources/</td>
		</tr>
		<tr>
			<td id="otelDeployment--priorityClassName"><a href="./values.yaml#L942">otelDeployment.priorityClassName</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>OtelDeployment priority class name</td>
		</tr>
		<tr>
			<td id="otelDeployment--nodeSelector"><a href="./values.yaml#L945">otelDeployment.nodeSelector</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>OtelDeployment node selector</td>
		</tr>
		<tr>
			<td id="otelDeployment--tolerations"><a href="./values.yaml#L948">otelDeployment.tolerations</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>Toleration labels for OtelDeployment pod assignment</td>
		</tr>
		<tr>
			<td id="otelDeployment--affinity"><a href="./values.yaml#L951">otelDeployment.affinity</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Affinity settings for OtelDeployment pod</td>
		</tr>
		<tr>
			<td id="otelDeployment--topologySpreadConstraints"><a href="./values.yaml#L954">otelDeployment.topologySpreadConstraints</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>TopologySpreadConstraints describes how OtelDeployment pods ought to spread</td>
		</tr>
		<tr>
			<td id="otelDeployment--clusterRole--create"><a href="./values.yaml#L959">otelDeployment.clusterRole.create</a></td>
			<td>bool</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
true
</pre>
</div>
			</td>
			<td>Specifies whether a clusterRole should be created</td>
		</tr>
		<tr>
			<td id="otelDeployment--clusterRole--annotations"><a href="./values.yaml#L961">otelDeployment.clusterRole.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Annotations to add to the clusterRole</td>
		</tr>
		<tr>
			<td id="otelDeployment--clusterRole--name"><a href="./values.yaml#L964">otelDeployment.clusterRole.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>The name of the clusterRole to use. If not set and create is true, a name is generated using the fullname template</td>
		</tr>
		<tr>
			<td id="otelDeployment--clusterRole--rules"><a href="./values.yaml#L968">otelDeployment.clusterRole.rules</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="">
See `values.yaml` for defaults
</pre>
</div>
			</td>
			<td>A set of rules as documented here. ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/</td>
		</tr>
		<tr>
			<td id="otelDeployment--clusterRole--clusterRoleBinding--annotations"><a href="./values.yaml#L999">otelDeployment.clusterRole.clusterRoleBinding.annotations</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
{}
</pre>
</div>
			</td>
			<td>Annotations to add to the clusterRoleBinding</td>
		</tr>
		<tr>
			<td id="otelDeployment--clusterRole--clusterRoleBinding--name"><a href="./values.yaml#L1002">otelDeployment.clusterRole.clusterRoleBinding.name</a></td>
			<td>string</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
""
</pre>
</div>
			</td>
			<td>The name of the clusterRoleBinding to use. If not set and create is true, a name is generated using the fullname template</td>
		</tr>
		<tr>
			<td id="otelDeployment--config"><a href="./values.yaml#L1006">otelDeployment.config</a></td>
			<td>object</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="">
See `values.yaml` for defaults
</pre>
</div>
			</td>
			<td>Configurations for OtelDeployment</td>
		</tr>
		<tr>
			<td id="otelDeployment--extraVolumes"><a href="./values.yaml#L1048">otelDeployment.extraVolumes</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>Additional volumes for otelDeployment</td>
		</tr>
		<tr>
			<td id="otelDeployment--extraVolumeMounts"><a href="./values.yaml#L1057">otelDeployment.extraVolumeMounts</a></td>
			<td>list</td>
			<td>
				<div style="max-width: 300px;">
<pre lang="json">
[]
</pre>
</div>
			</td>
			<td>Additional volume mounts for otelDeployment</td>
		</tr>
	</tbody>
</table>

