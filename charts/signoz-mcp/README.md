
# SigNoz MCP Server

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.18.0](https://img.shields.io/badge/AppVersion-v0.18.0-informational?style=flat-square)

This chart installs the [SigNoz MCP server](https://github.com/SigNoz/signoz-mcp-server) in HTTP mode, as a Deployment, a ServiceAccount and a ClusterIP Service on port 8000, with an optional Ingress and HorizontalPodAutoscaler. The server's documentation is at [signoz.io/docs/ai/signoz-mcp-server](https://signoz.io/docs/ai/signoz-mcp-server/). SigNoz itself is installed separately.

### Prerequisites

Helm 3, and Kubernetes 1.19 or later (1.23 or later when `autoscaling.enabled` is true).

### Installing the Chart

```bash
helm repo add signoz https://charts.signoz.io
helm install signoz-mcp signoz/signoz-mcp --namespace signoz --create-namespace \
  --set env.SIGNOZ_URL=http://signoz:8080
```

`env.SIGNOZ_URL` is the address of the SigNoz API as seen from the pod; `http://signoz:8080` is an example. The server needs `SIGNOZ_URL` or `SIGNOZ_INSTANCE_URL_ALLOWLIST` to start. See [Environment Variables](https://github.com/SigNoz/signoz-mcp-server#environment-variables) for what each one means.

### Configuration

Server settings go in the `env` map, one entry per environment variable. An entry is a plain value or a `valueFrom` reference:

```yaml
env:
  SIGNOZ_URL: http://signoz:8080
  SIGNOZ_API_KEY:
    valueFrom:
      secretKeyRef:
        name: signoz-mcp
        key: SIGNOZ_API_KEY
```

- Names are case-sensitive and used as written.
- `env` must be a map. A list of `name`/`value` pairs is rejected.
- The chart sets `TRANSPORT_MODE=http` and `MCP_SERVER_PORT=8000`. An entry in `env` with the same name replaces the chart's value.
- The container port and probes stay on 8000, so changing `MCP_SERVER_PORT` stops the pod from becoming Ready.

For the list of variables, including the multi-tenant allowlist, the docs refresh intervals and the server's own telemetry, see [Environment Variables](https://github.com/SigNoz/signoz-mcp-server#environment-variables). For the authentication modes (a key sent by each client, a key held by the server, or OAuth), see [HTTP Mode](https://github.com/SigNoz/signoz-mcp-server#http-mode).

### Reaching the Server

Forward the Service port to your machine:

```bash
kubectl --namespace signoz port-forward svc/signoz-mcp 8000:8000
```

The MCP endpoint is then `http://localhost:8000/mcp`. For example, to add it to Claude Code with a key sent by the client:

```bash
claude mcp add --transport http signoz http://localhost:8000/mcp --header "SIGNOZ-API-KEY: <your-key>"
```

For other clients, see [Connect to SigNoz's MCP server](https://signoz.io/docs/ai/signoz-mcp-server/#connect-to-signozs-mcp-server).

To reach the server from outside the cluster, enable the Ingress:

```yaml
ingress:
  enabled: true
  hosts:
    - host: mcp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: mcp-example-com-tls
      hosts:
        - mcp.example.com
```

Clients then use `https://mcp.example.com/mcp`. Keep the path `/`, because the OAuth endpoints sit at the root of the host. When the server holds a `SIGNOZ_API_KEY`, anyone who can reach the Ingress can query SigNoz with that key.

### Uninstalling the chart

```bash
helm uninstall signoz-mcp --namespace signoz
```

## Values

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
            <td id="global--imageRegistry"><a href="./values.yaml#L4">global.imageRegistry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Image registry that replaces `image.registry` when set.</td>
        </tr>
        <tr>
            <td id="nameOverride"><a href="./values.yaml#L8">nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>String to partially override the fullname template (retains the release name).</td>
        </tr>
        <tr>
            <td id="fullnameOverride"><a href="./values.yaml#L12">fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>String to fully override the fullname template. It is used as the exact name of every object and is never cut; rendering fails when it is longer than 63 characters.</td>
        </tr>
        <tr>
            <td id="replicaCount"><a href="./values.yaml#L15">replicaCount</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Number of server replicas. Ignored while `autoscaling.enabled` is true.</td>
        </tr>
    </tbody>
</table>
<h3>Image Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="image--registry"><a href="./values.yaml#L21">image.registry</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">docker.io</pre>
</div>
            </td>
            <td>Image registry. `global.imageRegistry` replaces it when set. Set it to an empty string to use the repository without a registry.</td>
        </tr>
        <tr>
            <td id="image--repository"><a href="./values.yaml#L24">image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/signoz-mcp-server</pre>
</div>
            </td>
            <td>Image repository.</td>
        </tr>
        <tr>
            <td id="image--tag"><a href="./values.yaml#L27">image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Image tag. Defaults to the chart's appVersion when empty.</td>
        </tr>
        <tr>
            <td id="image--pullPolicy"><a href="./values.yaml#L30">image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Image pull policy.</td>
        </tr>
        <tr>
            <td id="imagePullSecrets"><a href="./values.yaml#L33">imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for the pod, as a list of `{name: ...}` objects.</td>
        </tr>
    </tbody>
</table>
<h3>Environment Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="env"><a href="./values.yaml#L81">env</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Environment variables for the server, as a map of NAME: value. See the comments above this key in values.yaml for examples.</td>
        </tr>
    </tbody>
</table>
<h3>Service Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="service--type"><a href="./values.yaml#L86">service.type</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">ClusterIP</pre>
</div>
            </td>
            <td>Service type.</td>
        </tr>
        <tr>
            <td id="service--port"><a href="./values.yaml#L89">service.port</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">8000</pre>
</div>
            </td>
            <td>Port clients connect to. It forwards to the container's `http` port (8000).</td>
        </tr>
        <tr>
            <td id="service--nodePort"><a href="./values.yaml#L93">service.nodePort</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">null</pre>
</div>
            </td>
            <td>Node port for the Service. Used only when `service.type` is `NodePort` or `LoadBalancer`. When unset, Kubernetes picks one.</td>
        </tr>
        <tr>
            <td id="service--loadBalancerSourceRanges"><a href="./values.yaml#L97">service.loadBalancerSourceRanges</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Client IP ranges allowed to reach the Service. Used only when `service.type` is `LoadBalancer`.</td>
        </tr>
        <tr>
            <td id="service--annotations"><a href="./values.yaml#L100">service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the Service.</td>
        </tr>
        <tr>
            <td id="service--labels"><a href="./values.yaml#L103">service.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional labels on the Service.</td>
        </tr>
    </tbody>
</table>
<h3>Ingress Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="ingress--enabled"><a href="./values.yaml#L108">ingress.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create an Ingress for the server.</td>
        </tr>
        <tr>
            <td id="ingress--className"><a href="./values.yaml#L111">ingress.className</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>IngressClass name.</td>
        </tr>
        <tr>
            <td id="ingress--annotations"><a href="./values.yaml#L117">ingress.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the Ingress. A tool call can run for up to 600 seconds and the server accepts request bodies up to 4 MiB, so the proxy's read timeout and body size limit may need raising. The commented examples are for ingress-nginx; other controllers have their own annotation names.</td>
        </tr>
        <tr>
            <td id="ingress--labels"><a href="./values.yaml#L122">ingress.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional labels on the Ingress.</td>
        </tr>
        <tr>
            <td id="ingress--hosts"><a href="./values.yaml#L126">ingress.hosts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">- host: mcp.example.com
  paths:
    - path: /
      pathType: Prefix</pre>
</div>
            </td>
            <td>Hosts and paths for the Ingress. Each path routes to the Service's `http` port. Keep the path `/` for OAuth, whose endpoints sit at the root of the host.</td>
        </tr>
        <tr>
            <td id="ingress--tls"><a href="./values.yaml#L133">ingress.tls</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>TLS configuration for the Ingress. Keys travel in a request header, so use TLS.</td>
        </tr>
    </tbody>
</table>
<h3>Autoscaling Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="autoscaling--enabled"><a href="./values.yaml#L142">autoscaling.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create a HorizontalPodAutoscaler. While it is enabled the Deployment leaves `replicas` unset.</td>
        </tr>
        <tr>
            <td id="autoscaling--minReplicas"><a href="./values.yaml#L145">autoscaling.minReplicas</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">2</pre>
</div>
            </td>
            <td>Minimum number of replicas.</td>
        </tr>
        <tr>
            <td id="autoscaling--maxReplicas"><a href="./values.yaml#L148">autoscaling.maxReplicas</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10</pre>
</div>
            </td>
            <td>Maximum number of replicas.</td>
        </tr>
        <tr>
            <td id="autoscaling--targetCPUUtilizationPercentage"><a href="./values.yaml#L152">autoscaling.targetCPUUtilizationPercentage</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">60</pre>
</div>
            </td>
            <td>Target average CPU utilization. At least one utilization target must be set while autoscaling is enabled.</td>
        </tr>
        <tr>
            <td id="autoscaling--targetMemoryUtilizationPercentage"><a href="./values.yaml#L155">autoscaling.targetMemoryUtilizationPercentage</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">60</pre>
</div>
            </td>
            <td>Target average memory utilization.</td>
        </tr>
        <tr>
            <td id="autoscaling--behavior"><a href="./values.yaml#L158">autoscaling.behavior</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Scaling behavior of the HorizontalPodAutoscaler.</td>
        </tr>
    </tbody>
</table>
<h3>ServiceAccount Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="serviceAccount--create"><a href="./values.yaml#L163">serviceAccount.create</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Create a ServiceAccount for the pod. The pod does not mount its token.</td>
        </tr>
        <tr>
            <td id="serviceAccount--name"><a href="./values.yaml#L167">serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of the ServiceAccount the pod runs as. When empty, it is the fullname if `serviceAccount.create` is true, and `default` if it is false.</td>
        </tr>
        <tr>
            <td id="serviceAccount--annotations"><a href="./values.yaml#L170">serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the ServiceAccount.</td>
        </tr>
    </tbody>
</table>
<h3>Pod Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="resources"><a href="./values.yaml#L174">resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">requests:
    cpu: 500m
    memory: 1024Mi</pre>
</div>
            </td>
            <td>Resource requests and limits for the server container.</td>
        </tr>
        <tr>
            <td id="podSecurityContext"><a href="./values.yaml#L181">podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">runAsGroup: 65532
runAsNonRoot: true
runAsUser: 65532
seccompProfile:
    type: RuntimeDefault</pre>
</div>
            </td>
            <td>Pod-level security settings. 65532 is the `nonroot` user of distroless images.</td>
        </tr>
        <tr>
            <td id="securityContext"><a href="./values.yaml#L189">securityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">allowPrivilegeEscalation: false
capabilities:
    drop:
        - ALL
readOnlyRootFilesystem: true</pre>
</div>
            </td>
            <td>Container-level security settings.</td>
        </tr>
        <tr>
            <td id="podAnnotations"><a href="./values.yaml#L197">podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional annotations on the pod.</td>
        </tr>
        <tr>
            <td id="podLabels"><a href="./values.yaml#L200">podLabels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional labels on the pod.</td>
        </tr>
        <tr>
            <td id="nodeSelector"><a href="./values.yaml#L203">nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for the pod.</td>
        </tr>
        <tr>
            <td id="tolerations"><a href="./values.yaml#L206">tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for the pod.</td>
        </tr>
        <tr>
            <td id="affinity"><a href="./values.yaml#L209">affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for the pod.</td>
        </tr>
        <tr>
            <td id="topologySpreadConstraints"><a href="./values.yaml#L212">topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for the pod.</td>
        </tr>
        <tr>
            <td id="priorityClassName"><a href="./values.yaml#L215">priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>PriorityClass name for the pod.</td>
        </tr>
        <tr>
            <td id="volumes"><a href="./values.yaml#L218">volumes</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volumes for the pod. See the example below this key in values.yaml.</td>
        </tr>
        <tr>
            <td id="volumeMounts"><a href="./values.yaml#L236">volumeMounts</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional volume mounts for the `mcp` container.</td>
        </tr>
        <tr>
            <td id="livenessProbe"><a href="./values.yaml#L240">livenessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">failureThreshold: 5
httpGet:
    path: /livez
    port: http
initialDelaySeconds: 10
periodSeconds: 10
timeoutSeconds: 1</pre>
</div>
            </td>
            <td>Liveness probe for the `mcp` container. Helm merges maps, so setting one field, such as `livenessProbe.failureThreshold`, keeps the others.</td>
        </tr>
        <tr>
            <td id="readinessProbe"><a href="./values.yaml#L251">readinessProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">failureThreshold: 3
httpGet:
    path: /readyz
    port: http
initialDelaySeconds: 10
periodSeconds: 10
timeoutSeconds: 1</pre>
</div>
            </td>
            <td>Readiness probe for the `mcp` container. Helm merges maps, so setting one field, such as `readinessProbe.initialDelaySeconds`, keeps the others.</td>
        </tr>
        <tr>
            <td id="startupProbe"><a href="./values.yaml#L261">startupProbe</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Startup probe for the `mcp` container. Not set by default.</td>
        </tr>
    </tbody>
</table>

