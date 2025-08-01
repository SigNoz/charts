# Contributing Guidelines

Thank you for your interest in contributing to our project! We greatly value feedback and contributions from our community. This document will guide you through the contribution process.

## How can I contribute?

### Finding Issues to Work On
- Check our [existing open issues](https://github.com/SigNoz/charts/issues?q=is%3Aopen+is%3Aissue)
- Look for [good first issues](https://github.com/SigNoz/charts/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) to start with
- Review [recently closed issues](https://github.com/SigNoz/charts/issues?q=is%3Aissue+is%3Aclosed) to avoid duplicates

### Types of Contributions

1. **Report Bugs**: Use our [Bug Report template](https://github.com/SigNoz/signoz/issues/new?assignees=&labels=&template=bug_report.md&title=)
2. **Request Features**: Submit using [Feature Request template](https://github.com/SigNoz/signoz/issues/new?assignees=&labels=&template=feature_request.md&title=)
3. **Improve Documentation**: Create an issue with the `documentation` label
6. **Report Security Issues**: Follow our [Security Policy](https://github.com/SigNoz/signoz/security/policy)
7. **Join Discussions**: Participate in [project discussions](https://github.com/SigNoz/signoz/discussions)

### Creating Helpful Issues

When creating issues, include:

- **For Feature Requests**:
  - Clear use case and requirements
  - Proposed solution or improvement
  - Any open questions or considerations

- **For Bug Reports**:
  - Step-by-step reproduction steps
  - Version information
  - Relevant environment details
  - Any modifications you've made
  - Expected vs actual behavior

### Submitting Pull Requests

1. **Development**:
   - Setup your [development environment](#where-do-i-go-from-here)
   - Work against the latest `main` branch
   - Focus on specific changes
   - Ensure all tests pass locally
   - Follow our [commit convention](#commit-convention)

2. **Submit PR**:
   - Ensure your branch can be auto-merged
   - Address any CI failures
   - Respond to review comments promptly

For substantial changes, please split your contribution into multiple PRs:

1. First PR: Overall structure (README, configurations, interfaces)
2. Second PR: Core implementation (split further if needed)
3. Final PR: Documentation updates and end-to-end tests

### Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). All commits and PRs should include type specifiers (e.g., `feat:`, `fix:`, `docs:`, etc.).

## How can I contribute to the charts repository?

There are primarily 3 charts in the SigNoz Helm Charts repository:

- signoz: signoz and signoz collector
- clickhouse: clickhouse and zookeeper
- k8s-infra: k8s-infra component

signoz chart and k8s-infra is where most of the developments are done.
clickhouse chart is seldom updated to to sync major enhancement


## Where do I go from here? 


### To run helm chart for local development

- run `git clone https://github.com/SigNoz/charts.git` followed by `cd charts`
- it is recommended to use lightweight kubernetes (k8s) cluster for local development:
  - [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
  - [k3d](https://k3d.io/#installation)
  - [minikube](https://minikube.sigs.k8s.io/docs/start/)
- create a k8s cluster and make sure `kubectl` points to the locally created k8s cluster
- run `make dev-install` to install SigNoz chart with `my-release` release name in `platform` namespace.
- run `kubectl -n platform port-forward svc/my-release-signoz 8080:8080` to make SigNoz UI available at [localhost:8080](http://localhost:8080)

## How can I get help?

Need assistance? Join our Slack community:
- [`#contributing`](https://signoz-community.slack.com/archives/C01LWQ8KS7M)
- [`#contributing-frontend`](https://signoz-community.slack.com/archives/C027134DM8B)


