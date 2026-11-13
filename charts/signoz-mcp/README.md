
# SigNoz MCP Server

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.18.0](https://img.shields.io/badge/AppVersion-v0.18.0-informational?style=flat-square)

MCP, the [Model Context Protocol](https://modelcontextprotocol.io), is how AI clients such as Claude Code, Cursor and VS Code call tools on a server, and the [SigNoz MCP server](https://github.com/SigNoz/signoz-mcp-server) gives them tools to query the logs, traces, metrics, dashboards and alerts of a SigNoz instance.

### TL;DR;

```sh
helm repo add signoz https://charts.signoz.io
helm install signoz-mcp signoz/signoz-mcp --namespace platform \
  --set env.SIGNOZ_URL=http://my-release-signoz.platform.svc.cluster.local:8080
```

### Introduction

This chart runs the SigNoz MCP server in HTTP mode, so that several people can share one deployment. The server holds no data: it turns each client request into SigNoz API calls.

The chart is an add-on. It does not install SigNoz; install the [signoz](https://github.com/SigNoz/charts/tree/main/charts/signoz) chart first, or point the server at a SigNoz outside the cluster.

The chart creates a Deployment and a ClusterIP Service, and optionally an Ingress and a HorizontalPodAutoscaler. It creates no Secret, ConfigMap, ServiceAccount or RBAC object.

### Prerequisites

- Kubernetes 1.19+, where the `networking.k8s.io/v1` Ingress API became stable. Kubernetes 1.23+ when `autoscaling.enabled` is true, where the `autoscaling/v2` API became stable.
- Helm 3
- A SigNoz instance the cluster can reach, and a SigNoz API key for each user. A SigNoz Admin creates keys in the SigNoz UI under Settings, API Keys.

### Installing the Chart

The examples in this README assume SigNoz runs as release `my-release` in namespace `platform`, and install the MCP server in the same namespace.

To install the chart with the release name `signoz-mcp`:

```bash
helm repo add signoz https://charts.signoz.io
helm install signoz-mcp signoz/signoz-mcp --namespace platform \
  --set env.SIGNOZ_URL=http://my-release-signoz.platform.svc.cluster.local:8080
```

Giving the release the same name as the chart names the Deployment and Service `signoz-mcp`. Another release name gives `<release>-signoz-mcp`, unless the release name already contains `signoz-mcp`. Set `fullnameOverride` to choose the name directly.

The install prints the in-cluster endpoint, a port-forward command and the command that connects Claude Code. To print them again:

```bash
helm get notes signoz-mcp --namespace platform
```

The server needs `env.SIGNOZ_URL` or `env.SIGNOZ_INSTANCE_URL_ALLOWLIST`. The chart installs without either, but the server then exits at startup, the pod restarts repeatedly, and `kubectl logs` shows this message:

```text
SIGNOZ_INSTANCE_URL_ALLOWLIST is required for HTTP transport mode when SIGNOZ_URL is not set
```

### Configuring the SigNoz address

#### One SigNoz

Set `env.SIGNOZ_URL` to the address of the SigNoz API as seen from inside the cluster. For SigNoz installed with the `signoz` chart, it is:

```text
http://<release>-signoz.<namespace>.svc.cluster.local:8080
```

When the SigNoz release name already contains `signoz`, the Service is named `<release>` instead of `<release>-signoz`. For a SigNoz outside the cluster, use the address at which its API is reachable from the cluster.

The pod becomes Ready without contacting SigNoz, so a wrong address shows up only when a tool call fails. When `SIGNOZ_URL` is a plain value, the install notes print a command that tests the address from inside the cluster.

#### Several SigNoz instances (multi-tenant)

One server can serve several SigNoz instances. List their host names in `env.SIGNOZ_INSTANCE_URL_ALLOWLIST`, separated by commas, and leave `SIGNOZ_URL` unset:

```yaml
env:
  SIGNOZ_INSTANCE_URL_ALLOWLIST: signoz-a.example.com,signoz-b.example.com
```

An entry such as `*.example.com` matches any subdomain of `example.com`. Each client names its instance in the `X-SigNoz-URL` header and sends a key for that instance:

```bash
claude mcp add --transport http signoz http://localhost:8000/mcp \
  --header "SIGNOZ-API-KEY: <your-key>" \
  --header "X-SigNoz-URL: https://signoz-a.example.com"
```

The server refuses an instance whose host is not in the list. When `SIGNOZ_URL` is set as well, that instance is always allowed.

### Authentication

The server uses the SigNoz API key the client sends in the `SIGNOZ-API-KEY` header. It falls back to a key of its own, `env.SIGNOZ_API_KEY`, only when the request carries no key.

#### Each client sends its own key (default)

Nothing beyond the SigNoz address is set in the chart, and no key is stored in the release. Each user sends their own key:

```bash
claude mcp add --transport http signoz http://localhost:8000/mcp --header "SIGNOZ-API-KEY: <your-key>"
```

Any MCP client needs the same URL and header. Tool calls run with that user's key. A request without a key is refused with HTTP 401.

#### The server holds one key

Create a Secret holding the key, and reference it from `env`:

```bash
kubectl -n platform create secret generic signoz-mcp --from-literal=SIGNOZ_API_KEY=<key>
```

```yaml
env:
  SIGNOZ_URL: http://my-release-signoz.platform.svc.cluster.local:8080
  SIGNOZ_API_KEY:
    valueFrom:
      secretKeyRef:
        name: signoz-mcp
        key: SIGNOZ_API_KEY
```

```bash
helm install signoz-mcp signoz/signoz-mcp --namespace platform -f my-values.yaml
```

Clients then need only the URL. The server uses its key for any request that carries no key, so anyone who can reach the server can query SigNoz with that key. A client that sends its own key still uses its own. The server sends its key only to `SIGNOZ_URL`. The install notes print a warning when this key is set and the Ingress is enabled.

#### OAuth

With OAuth, a client is configured with the URL only and the user signs in through a browser. OAuth needs a public address for the server, so it is set up together with the Ingress. Create a Secret holding a token secret of at least 32 bytes:

```bash
kubectl -n platform create secret generic signoz-mcp \
  --from-literal=OAUTH_TOKEN_SECRET="$(openssl rand -base64 32)"
```

```yaml
env:
  SIGNOZ_URL: http://my-release-signoz.platform.svc.cluster.local:8080
  OAUTH_ENABLED: "true"
  OAUTH_ISSUER_URL: https://mcp.example.com
  OAUTH_TOKEN_SECRET:
    valueFrom:
      secretKeyRef:
        name: signoz-mcp
        key: OAUTH_TOKEN_SECRET
ingress:
  enabled: true
  className: nginx
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

```bash
claude mcp add --transport http signoz https://mcp.example.com/mcp
```

- `OAUTH_ISSUER_URL` is the public address of this server. The chart does not derive it from the Ingress host; the install notes print a warning when its host is not one of the Ingress hosts.
- Keep the Ingress path `/`. The OAuth discovery and token endpoints sit at the root of the host, not under `/mcp`.
- The chart does not check the OAuth variables. The server exits at startup when `OAUTH_TOKEN_SECRET` is shorter than 32 bytes or `OAUTH_ISSUER_URL` is missing.
- The chart does not create the TLS Secret named in `ingress.tls`.

### Names under `env` are case-sensitive

- Names are case-sensitive and used exactly as written. A lower-case name such as `signoz_url` is a different variable from `SIGNOZ_URL`, and the server does not read it. Other misspelled names also reach the server, which ignores them.
- `env` is a map of names to values, not a list. Each value is a string, number or bool, a map with exactly `value`, or a map with exactly `valueFrom`. Every value is rendered as a quoted string.
- The chart sets `TRANSPORT_MODE=http` and `MCP_SERVER_PORT=8000`. An entry with the same name replaces the chart's value. The container port and probes stay on 8000, so changing `MCP_SERVER_PORT` stops the pod from becoming Ready. To change the port clients connect to, set `service.port`.
- Variables are rendered sorted by name, so a `$(VAR)` reference in a value resolves only to a name that sorts earlier.

### Where a key is stored

A key written as a plain `env` string can be read by anyone who can read the Deployment, and it is kept in the Helm release record. A key referenced with `valueFrom` stays in your Secret. Use `valueFrom` for `SIGNOZ_API_KEY` and `OAUTH_TOKEN_SECRET`.

### Sharing the server

#### Port-forward

Each user with access to the namespace can reach the server through a port-forward:

```bash
kubectl -n platform port-forward svc/signoz-mcp 8000:8000
```

The URL is then `http://localhost:8000/mcp`.

#### Ingress

An Ingress gives everyone one address:

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-body-size: 4m
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

Clients then use `https://mcp.example.com/mcp`.

- Keys travel in a request header, so an Ingress without TLS sends them in clear text.
- A tool call can run for up to 600 seconds, and many Ingress controllers cut a response that takes longer than 60 seconds. The server accepts request bodies up to 4 MiB, and ingress-nginx rejects bodies over 1 MiB by default. The annotations above raise both limits for ingress-nginx; other controllers use their own annotation names.

### Clusters with no outbound access

Each replica keeps a docs index in memory and refreshes it from the public internet every 6 hours by default. Without outbound access the refresh fails and the server keeps serving the index built into the image. To turn the refresh off:

```yaml
env:
  SIGNOZ_DOCS_REFRESH_INTERVAL: "0"
  SIGNOZ_DOCS_FULL_REFRESH_INTERVAL: "0"
```

The image is pulled from `docker.io`. To pull it from a mirror, set `image.registry` or `global.imageRegistry`.

### The server's own telemetry

The server exports no telemetry by default. Set `env.OTEL_EXPORTER_OTLP_ENDPOINT` to an OTLP gRPC endpoint to export its traces and metrics, for example to the collector of the `signoz` chart:

```yaml
env:
  OTEL_EXPORTER_OTLP_ENDPOINT: http://my-release-signoz-otel-collector.platform.svc.cluster.local:4317
```

Logs are written to stderr as JSON:

```bash
kubectl -n platform logs deployment/signoz-mcp
```

### Rotating a Secret

Variables read from a Secret are fixed when the container starts. After changing the Secret, restart the pods:

```bash
kubectl -n platform rollout restart deployment/signoz-mcp
```

### Moving from foundry's kustomize output

foundry's kustomize output names the Deployment and Service `<installation>-mcp`, with a different selector from this chart's. Helm does not take over objects it did not create, and a Deployment's selector cannot be changed, so replace them:

1. Stop applying the MCP objects from foundry's output, or the next apply creates them again.
2. Delete them:

   ```bash
   kubectl -n <namespace> delete deployment/<installation>-mcp service/<installation>-mcp
   ```

3. Install the chart with the same `env` entries. To keep the Service address clients already use, set `fullnameOverride` to `<installation>-mcp`.

The server keeps no state, so this costs a short outage and no data.

### Using the chart from foundry

foundry's Helm mode does not deploy the MCP server yet; it stops with an error when MCP is enabled. A values file holding only `fullnameOverride`, `image.registry`, `image.repository`, `image.tag`, `replicaCount` and plain strings under `env` is enough to install the chart. `env` must include `SIGNOZ_URL` for the server to start. The `TRANSPORT_MODE` and `MCP_SERVER_PORT` entries foundry adds are accepted. The Deployment and Service are named exactly `fullnameOverride`, and the Service listens on port 8000 while `service.port` is left at its default.

foundry writes `env` values as plain strings. A Secret reference is added with a patch on the values file foundry writes for this chart:

```yaml
spec:
  patches:
    - target: "deployment/<values file for this chart>"
      operations:
        - op: add
          path: /env/SIGNOZ_API_KEY
          value:
            valueFrom:
              secretKeyRef:
                name: signoz-mcp
                key: SIGNOZ_API_KEY
```

### Troubleshooting

#### The pod is not Ready

```bash
kubectl -n platform describe pod -l app.kubernetes.io/instance=signoz-mcp
kubectl -n platform logs deployment/signoz-mcp
```

- `env.MCP_SERVER_PORT` set to a port other than 8000, or `env.TRANSPORT_MODE` set to anything other than `http`: the probes on port 8000 never succeed. Remove the entry.
- The container restarts at startup: see "The pod restarts repeatedly" below.
- The container is killed for memory: a memory limit is set below what the server uses. The server's README recommends at least 512Mi.

#### The pod restarts repeatedly

The server exits at startup when a setting it needs is missing or invalid, so the container restarts over and over. Its log names the setting. Read it with the command below, where `<name>` is the Deployment's name, as described under Installing the Chart:

```bash
kubectl -n <namespace> logs deploy/<name>
```

- Neither `env.SIGNOZ_URL` nor `env.SIGNOZ_INSTANCE_URL_ALLOWLIST` is set. The log shows:

  ```text
  SIGNOZ_INSTANCE_URL_ALLOWLIST is required for HTTP transport mode when SIGNOZ_URL is not set
  ```

  Set one of them, in upper case, and upgrade the release.
- OAuth is on: `OAUTH_TOKEN_SECRET` must be at least 32 bytes and `OAUTH_ISSUER_URL` must be set.

#### HTTP 401

The request carried no `SIGNOZ-API-KEY` header and the server holds no key. The response body is `Authorization or SIGNOZ-API-KEY header required`. Add the header to the client, as in the client command above. A server that holds a key also answers 401 when a request without a key names another instance in `X-SigNoz-URL`. With OAuth on, sign in again.

#### Tool calls fail while the pod is Ready

Readiness does not contact SigNoz, so a wrong `SIGNOZ_URL` gives a Ready pod whose tool calls fail. Test the address from inside the cluster:

```bash
kubectl -n platform run signoz-mcp-check --rm -i --restart=Never --image=busybox:1.35 -- \
  wget -qO- 'http://my-release-signoz.platform.svc.cluster.local:8080/api/v1/health?live=1'
```

If SigNoz answers, check the key. When SigNoz rejects the key, the tool call fails with the code `UNAUTHORIZED` or `PERMISSION_DENIED`.

#### The install fails with "env must be a map"

```text
env must be a map of NAME: value, for example env: {SIGNOZ_URL: http://...}; got a slice. A list of name/value pairs is not accepted.
```

`env` was written as a list of `name`/`value` pairs. Write it as a map:

```yaml
env:
  SIGNOZ_URL: http://my-release-signoz.platform.svc.cluster.local:8080
```

### Uninstalling the chart

To uninstall/delete the `signoz-mcp` release:

```bash
helm uninstall signoz-mcp --namespace platform
```

This removes the objects the chart created. Secrets you created for it are left in place.

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
            <td id="service--annotations"><a href="./values.yaml#L92">service.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the Service.</td>
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
            <td id="ingress--enabled"><a href="./values.yaml#L97">ingress.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create an Ingress for the server.</td>
        </tr>
        <tr>
            <td id="ingress--className"><a href="./values.yaml#L100">ingress.className</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>IngressClass name.</td>
        </tr>
        <tr>
            <td id="ingress--annotations"><a href="./values.yaml#L106">ingress.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Annotations for the Ingress. A tool call can run for up to 600 seconds and the server accepts request bodies up to 4 MiB, so the proxy's read timeout and body size limit may need raising. The commented examples are for ingress-nginx; other controllers have their own annotation names.</td>
        </tr>
        <tr>
            <td id="ingress--hosts"><a href="./values.yaml#L112">ingress.hosts</a></td>
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
            <td id="ingress--tls"><a href="./values.yaml#L119">ingress.tls</a></td>
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
            <td id="autoscaling--enabled"><a href="./values.yaml#L128">autoscaling.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Create a HorizontalPodAutoscaler. While it is enabled the Deployment leaves `replicas` unset.</td>
        </tr>
        <tr>
            <td id="autoscaling--minReplicas"><a href="./values.yaml#L131">autoscaling.minReplicas</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">2</pre>
</div>
            </td>
            <td>Minimum number of replicas.</td>
        </tr>
        <tr>
            <td id="autoscaling--maxReplicas"><a href="./values.yaml#L134">autoscaling.maxReplicas</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10</pre>
</div>
            </td>
            <td>Maximum number of replicas.</td>
        </tr>
        <tr>
            <td id="autoscaling--targetCPUUtilizationPercentage"><a href="./values.yaml#L138">autoscaling.targetCPUUtilizationPercentage</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">60</pre>
</div>
            </td>
            <td>Target average CPU utilization. At least one utilization target must be set while autoscaling is enabled.</td>
        </tr>
        <tr>
            <td id="autoscaling--targetMemoryUtilizationPercentage"><a href="./values.yaml#L141">autoscaling.targetMemoryUtilizationPercentage</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">60</pre>
</div>
            </td>
            <td>Target average memory utilization.</td>
        </tr>
        <tr>
            <td id="autoscaling--behavior"><a href="./values.yaml#L144">autoscaling.behavior</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Scaling behavior of the HorizontalPodAutoscaler.</td>
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
            <td id="resources"><a href="./values.yaml#L148">resources</a></td>
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
            <td id="podSecurityContext"><a href="./values.yaml#L155">podSecurityContext</a></td>
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
            <td id="securityContext"><a href="./values.yaml#L163">securityContext</a></td>
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
            <td id="podAnnotations"><a href="./values.yaml#L171">podAnnotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional annotations on the pod.</td>
        </tr>
        <tr>
            <td id="podLabels"><a href="./values.yaml#L174">podLabels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional labels on the pod.</td>
        </tr>
        <tr>
            <td id="nodeSelector"><a href="./values.yaml#L177">nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for the pod.</td>
        </tr>
        <tr>
            <td id="tolerations"><a href="./values.yaml#L180">tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for the pod.</td>
        </tr>
        <tr>
            <td id="affinity"><a href="./values.yaml#L183">affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for the pod.</td>
        </tr>
    </tbody>
</table>

