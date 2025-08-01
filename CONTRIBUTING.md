# Contributing Guidelines
Thank you for your interest in contributing to our project! We greatly value feedback and contributions from our community. This document will guide you through the contribution process.

## How can I contribute?

### Finding Issues to Work On
- Check our [existing open issues](https://github.com/SigNoz/charts/issues?q=is%3Aopen+is%3Aissue)
- Look for [good first issues](https://github.com/SigNoz/charts/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) to start with
- Review [recently closed issues](https://github.com/SigNoz/charts/issues?q=is%3Aissue+is%3Aclosed) to avoid duplicates

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
- signoz: signoz, signoz otel collector and schema Migrator
- clickhouse: clickhouse and zookeeper
- k8s-infra: k8s-infra collection agent


## Where do I go from here? 
### To run the helm chart for local development
- run `git clone https://github.com/SigNoz/charts.git` followed by `cd charts`
- It is recommended to use a lightweight Kubernetes (k8s) cluster for local development:
  - [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
  - [k3d](https://k3d.io/#installation)
  - [minikube](https://minikube.sigs.k8s.io/docs/start/)
- Create a k8s cluster and make sure `kubectl` points to the locally created k8s cluster

## How can I get help?
Need assistance? Join our Slack community:
- [`#contributing`](https://signoz-community.slack.com/archives/C01LWQ8KS7M)
