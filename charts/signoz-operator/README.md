
# SigNoz Operator

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.1.0](https://img.shields.io/badge/AppVersion-v0.1.0-informational?style=flat-square)

The SigNoz Operator manages SigNoz resources as Kubernetes custom resources, so they can be version controlled and applied the same way as the rest of your manifests.

### TL;DR;

```sh
helm repo add signoz https://charts.signoz.io
helm install signoz-operator signoz/signoz-operator \
  --namespace signoz-operator --create-namespace
```

### Introduction

This chart installs the SigNoz Operator and the CRDs it reconciles using the [Helm](https://helm.sh) package manager.

The operator does not run SigNoz itself — install the [signoz](https://github.com/SigNoz/charts/tree/main/charts/signoz) chart, or point the operator at SigNoz Cloud. It reconciles nothing until it can reach a SigNoz API, which you configure with a `ProviderConfig` (namespaced) or a `ClusterProviderConfig` (cluster-wide).

### Prerequisites

- Kubernetes 1.16+
- Helm 3.0+

### Installing the Chart

To install the chart with the release name `signoz-operator`:

```bash
helm repo add signoz https://charts.signoz.io
helm install signoz-operator signoz/signoz-operator \
  --namespace signoz-operator --create-namespace
```

Giving the release the same name as the chart keeps the generated resource names short — the Deployment, ServiceAccount and ClusterRole are all called `signoz-operator` rather than repeating the name twice.

Then create a `ProviderConfig` in the namespace holding your custom resources, or a cluster-wide `ClusterProviderConfig`, pointing at your SigNoz API. The fields it takes ship with the CRD:

```bash
kubectl explain providerconfigs.resources.signoz.io.spec
```

> [!NOTE]
> ### Custom Resource Definitions
>
> The CRDs are regular templates in this chart, so `helm upgrade` keeps them current — there is no separate `kubectl apply` step.
>
> They carry the `helm.sh/resource-policy: keep` annotation by default, which means `helm uninstall` leaves both the CRDs and your custom resources in place. Set `crds.keep=false` if you want an uninstall to remove them, keeping in mind that deleting a CRD garbage collects every custom resource of that kind in the cluster.
>
> To let another tool own the CRDs, install with `crds.install=false`.

### Uninstalling the chart

To uninstall/delete the `signoz-operator` release:

```bash
helm uninstall signoz-operator --namespace signoz-operator
```

See the [Helm docs](https://helm.sh/docs/helm/helm_uninstall/) for documentation on the helm uninstall command.

The command above removes the operator and its RBAC, but leaves the CRDs and your custom resources behind. To remove those as well:

```bash
kubectl delete crd -l app.kubernetes.io/instance=signoz-operator
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
            <td id="nameOverride"><a href="./values.yaml#L3">nameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>String to partially override the fullname template (retains the release name).</td>
        </tr>
        <tr>
            <td id="fullnameOverride"><a href="./values.yaml#L6">fullnameOverride</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>String to fully override the fullname template.</td>
        </tr>
    </tbody>
</table>
<h3>CRDs Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="crds"><a href="./values.yaml#L10">crds</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
install: true
keep: true
labels: {}</pre>
</div>
            </td>
            <td>Custom Resource Definitions the operator reconciles.</td>
        </tr>
        <tr>
            <td id="crds--install"><a href="./values.yaml#L14">crds.install</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Whether to install the CRDs. Set to false when the CRDs are managed out of band, e.g. by a cluster addon or a separate `kubectl apply`.</td>
        </tr>
        <tr>
            <td id="crds--keep"><a href="./values.yaml#L20">crds.keep</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Adds the `helm.sh/resource-policy: keep` annotation to every CRD, so `helm uninstall` leaves them in place. Set to false only if you want an uninstall to remove the CRDs -- doing so garbage collects every SigNoz custom resource in the cluster along with them.</td>
        </tr>
        <tr>
            <td id="crds--annotations"><a href="./values.yaml#L23">crds.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional annotations to add to every CRD.</td>
        </tr>
        <tr>
            <td id="crds--labels"><a href="./values.yaml#L26">crds.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional labels to add to every CRD.</td>
        </tr>
    </tbody>
</table>
<h3>Controller Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="controller"><a href="./values.yaml#L30">controller</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">affinity: {}
annotations: {}
args: []
enabled: true
env: []
image:
    pullPolicy: IfNotPresent
    repository: signoz/signoz-operator
    tag: ""
imagePullSecrets: []
labels: {}
nodeSelector: {}
pod:
    annotations: {}
    labels: {}
podSecurityContext:
    runAsNonRoot: true
    seccompProfile:
        type: RuntimeDefault
priorityClassName: ""
replicas: 1
resources:
    limits:
        cpu: 500m
        memory: 128Mi
    requests:
        cpu: 10m
        memory: 64Mi
securityContext:
    allowPrivilegeEscalation: false
    capabilities:
        drop:
            - ALL
    readOnlyRootFilesystem: true
strategy: {}
terminationGracePeriodSeconds: 10
tolerations: []
topologySpreadConstraints: []</pre>
</div>
            </td>
            <td>Controller deployment.</td>
        </tr>
        <tr>
            <td id="controller--enabled"><a href="./values.yaml#L33">controller.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Set to false to install only the CRDs and RBAC.</td>
        </tr>
        <tr>
            <td id="controller--replicas"><a href="./values.yaml#L37">controller.replicas</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">1</pre>
</div>
            </td>
            <td>Number of controller replicas. Leader election keeps a single replica reconciling at a time, so anything above 1 is for failover only.</td>
        </tr>
        <tr>
            <td id="controller--image--repository"><a href="./values.yaml#L41">controller.image.repository</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">signoz/signoz-operator</pre>
</div>
            </td>
            <td>Controller image repository.</td>
        </tr>
        <tr>
            <td id="controller--image--tag"><a href="./values.yaml#L44">controller.image.tag</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Controller image tag. Defaults to the chart's appVersion when unset.</td>
        </tr>
        <tr>
            <td id="controller--image--pullPolicy"><a href="./values.yaml#L47">controller.image.pullPolicy</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">IfNotPresent</pre>
</div>
            </td>
            <td>Controller image pull policy.</td>
        </tr>
        <tr>
            <td id="controller--imagePullSecrets"><a href="./values.yaml#L50">controller.imagePullSecrets</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Image pull secrets for the controller pod.</td>
        </tr>
        <tr>
            <td id="controller--args"><a href="./values.yaml#L53">controller.args</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional arguments passed to the controller.</td>
        </tr>
        <tr>
            <td id="controller--env"><a href="./values.yaml#L58">controller.env</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Additional environment variables for the controller. `SIGNOZ_OPERATOR_OPERATOR_NAMESPACE` is always set to the release namespace and cannot be removed.</td>
        </tr>
        <tr>
            <td id="controller--podSecurityContext"><a href="./values.yaml#L61">controller.podSecurityContext</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">runAsNonRoot: true
seccompProfile:
    type: RuntimeDefault</pre>
</div>
            </td>
            <td>Pod-level security settings.</td>
        </tr>
        <tr>
            <td id="controller--securityContext"><a href="./values.yaml#L67">controller.securityContext</a></td>
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
            <td id="controller--resources"><a href="./values.yaml#L75">controller.resources</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">limits:
    cpu: 500m
    memory: 128Mi
requests:
    cpu: 10m
    memory: 64Mi</pre>
</div>
            </td>
            <td>Resource requests and limits for the controller container.</td>
        </tr>
        <tr>
            <td id="controller--affinity"><a href="./values.yaml#L84">controller.affinity</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Affinity rules for the controller pod.</td>
        </tr>
        <tr>
            <td id="controller--nodeSelector"><a href="./values.yaml#L87">controller.nodeSelector</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Node selector for the controller pod.</td>
        </tr>
        <tr>
            <td id="controller--tolerations"><a href="./values.yaml#L90">controller.tolerations</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Tolerations for the controller pod.</td>
        </tr>
        <tr>
            <td id="controller--topologySpreadConstraints"><a href="./values.yaml#L93">controller.topologySpreadConstraints</a></td>
            <td>list</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">[]</pre>
</div>
            </td>
            <td>Topology spread constraints for the controller pod.</td>
        </tr>
        <tr>
            <td id="controller--strategy"><a href="./values.yaml#L96">controller.strategy</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Deployment strategy for the controller.</td>
        </tr>
        <tr>
            <td id="controller--priorityClassName"><a href="./values.yaml#L99">controller.priorityClassName</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Priority class name for the controller pod.</td>
        </tr>
        <tr>
            <td id="controller--terminationGracePeriodSeconds"><a href="./values.yaml#L102">controller.terminationGracePeriodSeconds</a></td>
            <td>int</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">10</pre>
</div>
            </td>
            <td>Grace period before the controller pod is killed.</td>
        </tr>
        <tr>
            <td id="controller--labels"><a href="./values.yaml#L105">controller.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional labels on the controller Deployment.</td>
        </tr>
        <tr>
            <td id="controller--annotations"><a href="./values.yaml#L108">controller.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional annotations on the controller Deployment.</td>
        </tr>
        <tr>
            <td id="controller--pod--labels"><a href="./values.yaml#L112">controller.pod.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional labels on the controller pod.</td>
        </tr>
        <tr>
            <td id="controller--pod--annotations"><a href="./values.yaml#L115">controller.pod.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional annotations on the controller pod.</td>
        </tr>
    </tbody>
</table>
<h3>RBAC Configuration</h3>
<table>
    <thead>
        <th>Key</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td id="rbac"><a href="./values.yaml#L119">rbac</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">namespaced: false</pre>
</div>
            </td>
            <td>RBAC resources for the controller.</td>
        </tr>
        <tr>
            <td id="rbac--namespaced"><a href="./values.yaml#L125">rbac.namespaced</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">false</pre>
</div>
            </td>
            <td>Install the controller rules as a Role/RoleBinding scoped to the release namespace instead of a ClusterRole/ClusterRoleBinding. The operator reconciles resources cluster-wide, so leave this false unless the operator is deliberately confined to a single namespace.</td>
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
            <td id="serviceAccount"><a href="./values.yaml#L129">serviceAccount</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">annotations: {}
enabled: true
labels: {}
name: ""</pre>
</div>
            </td>
            <td>ServiceAccount used by the controller.</td>
        </tr>
        <tr>
            <td id="serviceAccount--enabled"><a href="./values.yaml#L132">serviceAccount.enabled</a></td>
            <td>bool</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">true</pre>
</div>
            </td>
            <td>Set to false to reuse an existing ServiceAccount.</td>
        </tr>
        <tr>
            <td id="serviceAccount--name"><a href="./values.yaml#L136">serviceAccount.name</a></td>
            <td>string</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">""</pre>
</div>
            </td>
            <td>Name of an existing ServiceAccount. Only read when `serviceAccount.enabled` is false.</td>
        </tr>
        <tr>
            <td id="serviceAccount--annotations"><a href="./values.yaml#L139">serviceAccount.annotations</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional annotations on the ServiceAccount.</td>
        </tr>
        <tr>
            <td id="serviceAccount--labels"><a href="./values.yaml#L142">serviceAccount.labels</a></td>
            <td>object</td>
            <td>
                <div style="max-width: 300px;"><pre lang="yaml">{}</pre>
</div>
            </td>
            <td>Additional labels on the ServiceAccount.</td>
        </tr>
    </tbody>
</table>

