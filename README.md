# SigNoz Helm Chart

SigNoz helm chart ready to be deployed on Kubernetes using [Kubernetes Helm](https://github.com/helm/helm).

## TL;DR

```bash
$ helm repo add signoz https://charts.signoz.io
$ helm install -n platform  --create-namespace my-release signoz/signoz
```

## Before you begin

### Setup a Kubernetes Cluster

The quickest way to set up a staging/production Kubernetes cluster is with [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/),
[AWS Elastic Kubernetes Service](https://aws.amazon.com/eks/) or [Azure Kubernetes Service](https://azure.microsoft.com/en-us/services/kubernetes-service/)
using their respective quick-start guides.

For setting up Kubernetes on other cloud platforms, bare-metal servers, or local machines refer to the Kubernetes
[getting started guide](https://kubernetes.io/docs/setup/).

### Install kubectl

The [Kubernetes](https://kubernetes.io/) command-line tool, `kubectl`, allows you to
run commands against Kubernetes clusters. You can use kubectl to deploy applications,
inspect and manage cluster resources, and view logs.

To install `kubectl` follow the instructions [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

### Install Helm

[Helm](https://helm.sh/) is a tool for managing Kubernetes charts. Charts are packages
of pre-configured Kubernetes resources.

To install Helm follow the instructions [here](https://helm.sh/docs/intro/install/).

### Add SigNoz Repository

To add the SigNoz helm repository:

```bash
$ helm repo add signoz https://charts.signoz.io
```

### Usage

See the [README of SigNoz helm chart](./charts/signoz/README.md).

### Contribute the Chart

See the [instructions here to contribute](./CONTRIBUTING.md).

# License

MIT License

Copyright (c) 2022 SigNoz
