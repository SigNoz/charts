# How to Contribute

There are primarily 3 charts in the SigNoz Helm Charts repository:

- SigNoz (frontend, query service, otel collector, and otel collector metrics)
- ClickHouse
- Alertmanager

SigNoz chart is where most of the developments are done.
ClickHouse chart is seldom updated to to sync major enhancements.
Alertmanager chart is rarely updated.

### To run helm chart for local development

- run `git clone https://github.com/SigNoz/charts.git` followed by `cd charts`
- it is recommended to use lightweight kubernetes (k8s) cluster for local development:
  - [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
  - [k3d](https://k3d.io/#installation)
  - [minikube](https://minikube.sigs.k8s.io/docs/start/)
- create a k8s cluster and make sure `kubectl` points to the locally created k8s cluster
- run `helm install -n platform --create-namespace my-release charts/signoz` to install SigNoz chart
- run `kubectl -n platform port-forward svc/my-release-frontend 3301:3301` to make SigNoz UI available at [localhost:3301](http://localhost:3301)

**To load data with HotROD sample app:**

```sh
kubectl create ns sample-application

kubectl -n sample-application apply -f https://raw.githubusercontent.com/SigNoz/signoz/main/sample-apps/hotrod/hotrod.yaml

kubectl -n sample-application run strzal --image=djbingham/curl \
--restart='OnFailure' -i --tty --rm --command -- curl -X POST -F \
'locust_count=6' -F 'hatch_rate=2' http://locust-master:8089/swarm
```

**To stop the load generation:**

```sh
kubectl -n sample-application run strzal --image=djbingham/curl \
 --restart='OnFailure' -i --tty --rm --command -- curl \
 http://locust-master:8089/stop
```

---

## General Instructions

You can always reach out to `prashant@signoz.io` to understand more about the SigNoz helm chart and product.
We are very responsive over email and [slack](https://signoz.io/slack).

Please use the label `helm-chart` for your issues and pull requests.

- If you find any bugs, please create an issue
- If you find anything missing in documentation, you can create an issue with label `documentation`
- If you want to build any new feature, please create an issue with label `enhancement`
- If you want to discuss something about the helm chart, please use the [Helm chart discussion](https://github.com/SigNoz/signoz/discussions/713)

### Conventions to follow when submitting commits, PRs

1. We try to follow https://www.conventionalcommits.org/en/v1.0.0/

More specifically the commits and PRs should have type specifiers prefixed in the name. [This](https://www.conventionalcommits.org/en/v1.0.0/#specification) should give you a better idea.

2. Follow [GitHub Flow](https://guides.github.com/introduction/flow/) guidelines for your contribution flows

3. Feel free to ping us on `#contributing` on our slack community if you need any help on this :)
