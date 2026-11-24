<p align="center">
  <a href="https://signoz.io" target="_blank">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="docs/readme-assets/signoz-hero-dark.png" width="900">
      <source media="(prefers-color-scheme: light)" srcset="docs/readme-assets/signoz-hero-light.png" width="900">
      <img alt="SigNoz" src="docs/readme-assets/signoz-hero-light.png" width="900">
    </picture>
  </a>
</p>

<h1 align="center" style="border-bottom: none">SigNoz Helm Charts</h1>

<p align="center">
  <a href="https://github.com/SigNoz/charts/actions/workflows/release.yaml"><img alt="Release Charts" src="https://github.com/SigNoz/charts/actions/workflows/release.yaml/badge.svg"></a>
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
  <a href="https://github.com/SigNoz/charts/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/SigNoz/charts?style=flat"></a>
  <a href="https://github.com/SigNoz/charts/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/SigNoz/charts"></a>
  <a href="https://signoz.io/slack"><img alt="Slack" src="https://img.shields.io/badge/Slack-SigNoz-4A154B?logo=slack"></a>
</p>

<p align="center"><b>Run SigNoz on Kubernetes with Helm.</b></p>

<p align="center">Helm charts for running SigNoz and its Kubernetes components.</p>

<h3 align="center">
  <a href="https://signoz.io/docs/"><b>SigNoz Documentation</b></a> &bull;
  <a href="https://signoz.io/teams/"><b>SigNoz Cloud</b></a> &bull;
  <a href="https://signoz.io/slack"><b>Slack</b></a> &bull;
  <a href="https://signoz.io"><b>Website</b></a>
</h3>

## Overview

This repository holds the Helm charts for running [SigNoz](https://signoz.io) on Kubernetes. The charts are published to the Helm repository at `https://charts.signoz.io`.

Each chart lives in its own directory under [`charts/`](charts) and is released on its own. The README in each chart directory documents its values and its installation.

These charts install SigNoz with Helm; to install it with Kustomize, use [Foundry](https://github.com/SigNoz/foundry) and the [Kustomize guide](https://signoz.io/docs/setup/kubernetes/kustomize/).

## Charts

| Chart | Description | Version | |
|---|---|---|---|
| [SigNoz](charts/signoz) | SigNoz, with the SigNoz OTel Collector and ClickHouse. | ![signoz version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2FSigNoz%2Fcharts%2Fmain%2Fcharts%2Fsignoz%2FChart.yaml&query=%24.version&label=chart&color=F25733) | [Get&nbsp;started](charts/signoz/README.md#installing-the-chart) |
| [Kubernetes&nbsp;Collection&nbsp;Agent](charts/k8s-infra) | Sends the metrics, logs and events of a cluster to SigNoz. | ![k8s-infra version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2FSigNoz%2Fcharts%2Fmain%2Fcharts%2Fk8s-infra%2FChart.yaml&query=%24.version&label=chart&color=F25733) | [Get&nbsp;started](charts/k8s-infra/README.md#installing-the-chart) |
| [SigNoz&nbsp;MCP&nbsp;Server](charts/signoz-mcp-server) | Lets AI clients query SigNoz through MCP (Model Context Protocol). | ![signoz-mcp-server version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2FSigNoz%2Fcharts%2Fmain%2Fcharts%2Fsignoz-mcp-server%2FChart.yaml&query=%24.version&label=chart&color=F25733) | [Get&nbsp;started](charts/signoz-mcp-server/README.md#installing-the-chart) |
| [SigNoz&nbsp;Operator](charts/signoz-operator) | Manages SigNoz resources as Kubernetes custom resources. | ![signoz-operator version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2FSigNoz%2Fcharts%2Fmain%2Fcharts%2Fsignoz-operator%2FChart.yaml&query=%24.version&label=chart&color=F25733) | [Get&nbsp;started](charts/signoz-operator/README.md#installing-the-chart) |

## Getting Started

### Add the repository

[Helm](https://helm.sh/docs/intro/install/) must be installed to use the charts.

```bash
helm repo add signoz https://charts.signoz.io
helm repo update signoz
```

### Install SigNoz

Install the [`signoz`](charts/signoz) chart with the release name `my-release`:

```bash
helm upgrade --install my-release signoz/signoz \
  --namespace signoz --create-namespace
```

Verify that the Pods are running:

```bash
kubectl -n signoz get pods
```

The [chart README](charts/signoz/README.md) lists the values you can set.

### Install the other charts

Each of the other charts needs a few values of its own, such as the address of SigNoz. Follow the "Get started" link of the chart in the [Charts](#charts) table.

## Upgrading

Read the [upgrade guides](https://signoz.io/docs/operate/migration/) before moving to a new chart version.

## Development

The checks that CI runs on a pull request are run from the repository root:

```bash
helm unittest charts/<chart> --file 'tests/**/*_test.yaml'
ct lint --config ct.yaml --charts charts/<chart>
make chart-docs CHARTS=charts/<chart>
```

`make chart-docs` regenerates a chart's README from the comments in its `values.yaml`.

## Contributing

We ❤️ contributions big or small. Read the [contributing guide](CONTRIBUTING.md), then open an [issue](https://github.com/SigNoz/charts/issues) or a pull request to get started. Not sure where to begin? Just ping us on `#contributing` in our [Slack community](https://signoz.io/slack).

## Community

Come say Hi to us on [Slack](https://signoz.io/slack) 👋 to talk observability, OpenTelemetry, and SigNoz, and to connect with other users and contributors. If you have ideas, questions, or feedback, share them on [GitHub Discussions](https://github.com/SigNoz/signoz/discussions).

## License

Licensed under the [MIT License](LICENSE).
