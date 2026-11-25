###############################################################
# variables
###############################################################
SHELL                   := /bin/bash
.DEFAULT_GOAL           := help
OS                      ?= $(shell uname -s | tr '[A-Z]' '[a-z]')
ARCH                    ?= $(shell uname -m | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g')
TMP_DIR                 ?= $(shell pwd)/tmp
BIN_DIR                 ?= $(shell pwd)/tmp/bin
# Every chart under charts/ except the ones ct.yaml excludes.
CI_CHARTS               ?= $(shell for d in charts/*/; do [ -f "$$d/Chart.yaml" ] && echo "$${d%/}"; done | grep -vE '^charts/(redpanda|zookeeper|signoz-otel-gateway)$$')
# ct calls helm from PATH, so the pinned helm comes first.
export PATH := $(BIN_DIR):$(PATH)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

###############################################################
# helm-tools
###############################################################
# Tool targets are phony so the version check runs every time: bumping a version below reinstalls the tool.
# renovate: datasource=github-releases depName=helm/helm
HELM_VERSION            ?= v3.20.0
# Pinned SigNoz-wide (primus helm.mk); v1.0.2 predates the release-tarball install, so it installs from git.
# renovate: datasource=github-releases depName=helm-unittest/helm-unittest
HELM_UNITTEST_VERSION   ?= v1.0.2
# renovate: datasource=github-releases depName=norwoodj/helm-docs
HELM_DOCS_VERSION       ?= v1.14.2
HELM_PLUGINS            ?= $(BIN_DIR)
# helm-docs names its assets Linux/Darwin and x86_64/arm64.
HELM_DOCS_OS            ?= $(shell uname -s)
HELM_DOCS_ARCH          ?= $(shell uname -m | sed 's/aarch64/arm64/g')

HELM ?= $(BIN_DIR)/helm
.PHONY: $(HELM)
$(HELM): $(BIN_DIR)
	@echo ">> Downloading helm $(HELM_VERSION)"
	@if [ "$$($(HELM) version --template '{{ .Version }}' 2>/dev/null)" = "$(HELM_VERSION)" ]; then \
		echo ">> helm $(HELM_VERSION) already exists, skipping download!"; \
	else \
		curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | DESIRED_VERSION=$(HELM_VERSION) HELM_INSTALL_DIR=$(BIN_DIR) USE_SUDO=false bash; \
	fi

HELM_UNITTEST ?= $(BIN_DIR)/helm-unittest.git/install-binary.sh
.PHONY: $(HELM_UNITTEST)
$(HELM_UNITTEST): $(BIN_DIR) $(HELM)
	@echo ">> Downloading helm-unittest $(HELM_UNITTEST_VERSION)"
	@if HELM_PLUGINS=$(HELM_PLUGINS) $(HELM) plugin list | grep -qE '^unittest[[:space:]]+$(HELM_UNITTEST_VERSION:v%=%)[[:space:]]'; then \
		echo ">> helm-unittest $(HELM_UNITTEST_VERSION) already exists, skipping download!"; \
	else \
		HELM_PLUGINS=$(HELM_PLUGINS) $(HELM) plugin uninstall unittest >/dev/null 2>&1; \
		HELM_PLUGINS=$(HELM_PLUGINS) $(HELM) plugin install https://github.com/helm-unittest/helm-unittest.git --version $(HELM_UNITTEST_VERSION); \
	fi

HELM_DOCS ?= $(BIN_DIR)/helm-docs
.PHONY: $(HELM_DOCS)
$(HELM_DOCS): $(BIN_DIR)
	@echo ">> Downloading helm-docs $(HELM_DOCS_VERSION)"
	@if $(HELM_DOCS) --version 2>/dev/null | grep -qF "version $(HELM_DOCS_VERSION:v%=%)"; then \
		echo ">> helm-docs $(HELM_DOCS_VERSION) already exists, skipping download!"; \
	else \
		curl -fsSL https://github.com/norwoodj/helm-docs/releases/download/$(HELM_DOCS_VERSION)/helm-docs_$(HELM_DOCS_VERSION:v%=%)_$(HELM_DOCS_OS)_$(HELM_DOCS_ARCH).tar.gz | tar -xz -C $(BIN_DIR) helm-docs; \
	fi

###############################################################
# ct-tools
###############################################################
# renovate: datasource=github-releases depName=helm/chart-testing
CT_VERSION              ?= v3.14.0

CT ?= $(BIN_DIR)/ct
.PHONY: $(CT)
$(CT): $(BIN_DIR)
	@echo ">> Downloading ct $(CT_VERSION)"
	@if $(CT) version 2>/dev/null | grep -qF "$(CT_VERSION)"; then \
		echo ">> ct $(CT_VERSION) already exists, skipping download!"; \
	else \
		curl -fsSL https://github.com/helm/chart-testing/releases/download/$(CT_VERSION)/chart-testing_$(CT_VERSION:v%=%)_$(OS)_$(ARCH).tar.gz | tar -xz -C $(BIN_DIR) ct; \
	fi

###############################################################
# kubeconform-tools
###############################################################
# renovate: datasource=github-releases depName=yannh/kubeconform
KUBECONFORM_VERSION     ?= v0.8.0

KUBECONFORM ?= $(BIN_DIR)/kubeconform
.PHONY: $(KUBECONFORM)
$(KUBECONFORM): $(BIN_DIR)
	@echo ">> Downloading kubeconform $(KUBECONFORM_VERSION)"
	@if [ "$$($(KUBECONFORM) -v 2>/dev/null)" = "$(KUBECONFORM_VERSION)" ]; then \
		echo ">> kubeconform $(KUBECONFORM_VERSION) already exists, skipping download!"; \
	else \
		curl -fsSL https://github.com/yannh/kubeconform/releases/download/$(KUBECONFORM_VERSION)/kubeconform-$(OS)-$(ARCH).tar.gz | tar -xz -C $(BIN_DIR) kubeconform; \
	fi

###############################################################
# chainsaw-tools
###############################################################
# renovate: datasource=github-releases depName=kyverno/chainsaw
CHAINSAW_VERSION        ?= v0.2.15

CHAINSAW ?= $(BIN_DIR)/chainsaw
.PHONY: $(CHAINSAW)
$(CHAINSAW): $(BIN_DIR)
	@echo ">> Downloading chainsaw $(CHAINSAW_VERSION)"
	@if $(CHAINSAW) version 2>/dev/null | grep -qE "^Version: +$(CHAINSAW_VERSION:v%=%)$$"; then \
		echo ">> chainsaw $(CHAINSAW_VERSION) already exists, skipping download!"; \
	else \
		curl -fsSL https://github.com/kyverno/chainsaw/releases/download/$(CHAINSAW_VERSION)/chainsaw_$(OS)_$(ARCH).tar.gz | tar -xz -C $(BIN_DIR) chainsaw; \
	fi

###############################################################
# common commands
###############################################################
.PHONY: help
help: ## Displays help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-z0-9A-Z_-]+:.*?##/ { printf "  \033[36m%-40s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: tools
tools: ## Downloads the pinned chart tools into tmp/bin.
tools: $(HELM) $(HELM_UNITTEST) $(HELM_DOCS) $(CT) $(KUBECONFORM) $(CHAINSAW)

###############################################################
# chart-deps commands
###############################################################
.PHONY: chart-deps
chart-deps: ## Builds the dependency archives of every chart that declares dependencies.
chart-deps: $(HELM)
	@echo ">> Adding chart repositories"
	@$(HELM) repo add --force-update signoz https://charts.signoz.io >/dev/null
	@$(HELM) repo add --force-update altinity https://helm.altinity.com >/dev/null
	@for chart in $(CI_CHARTS) ; do \
		if grep -q '^dependencies:' $$chart/Chart.yaml; then \
			echo ">> Building dependencies for chart $$chart"; \
			$(HELM) dependency build $$chart || exit 1; \
		fi; \
	done

###############################################################
# chart-lint commands
###############################################################
# helm lint --strict through ct, so ct.yaml stays the one exclusion list. The yamllint and
# yamale checks are off, so no Python is needed.
.PHONY: chart-lint
chart-lint: ## Runs helm lint --strict for all charts.
chart-lint: $(CT) chart-deps
	@echo ">> Running lint for all charts"
	@$(CT) lint --config ct.yaml --all --validate-yaml=false --validate-chart-schema=false --helm-lint-extra-args "--strict"

###############################################################
# chart-validate commands
###############################################################
# Custom resources without a schema (ClickHouse, prometheus-operator, KEDA, external-secrets) are skipped.
.PHONY: chart-validate
chart-validate: ## Validates rendered manifests against the Kubernetes schemas with kubeconform.
chart-validate: $(KUBECONFORM) chart-deps
	@rc=0; for chart in $(CI_CHARTS) ; do \
		echo ">> Running kubeconform for chart $$chart"; \
		set -o pipefail; \
		$(HELM) template $$(basename $$chart) $$chart | $(KUBECONFORM) -strict -summary -ignore-missing-schemas -schema-location default || rc=1; \
	done; exit $$rc

###############################################################
# chart-unittest commands
###############################################################
.PHONY: chart-unittest
chart-unittest: ## Runs helm unittest for every chart with test suites.
chart-unittest: $(HELM_UNITTEST) chart-deps
	@rc=0; for chart in $(CI_CHARTS) ; do \
		if [ -n "$$(find $$chart/tests -name '*_test.yaml' 2>/dev/null)" ]; then \
			echo ">> Running unittest for chart $$chart"; \
			HELM_PLUGINS=$(HELM_PLUGINS) $(HELM) unittest $$chart --file 'tests/**/*_test.yaml' || rc=1; \
		fi; \
	done; exit $$rc

###############################################################
# chart-docs commands
###############################################################
# Usage: make chart-docs CHARTS=charts/signoz,charts/k8s-infra
CHARTS ?= charts/signoz,charts/k8s-infra,charts/signoz-operator,charts/signoz-mcp-server

.PHONY: chart-docs
chart-docs: ## Generates the README of every chart in CHARTS with helm-docs.
chart-docs: $(HELM_DOCS)
	@echo ">> Generating chart docs"
	@$(HELM_DOCS) --chart-search-root=charts --template-files=README.md.gotmpl --chart-to-generate=$(CHARTS) --sort-values-order=file

.PHONY: chart-docs-check
chart-docs-check: ## Fails when a generated README differs from the committed one.
chart-docs-check: chart-docs
	@git diff --exit-code -- charts || { echo; echo ">> Docs are out of date. Run 'make chart-docs' and commit the result."; exit 1; }

###############################################################
# chart-install commands
###############################################################
# ct.yaml sets debug, which echoes ">>>" commands to stdout; only changed chart paths are kept.
# No tool prerequisite: its ">> Downloading" lines would land on stdout too. Run make tools first.
.PHONY: chart-list-changed
chart-list-changed: ## Prints the charts changed against main.
	@set -o pipefail; $(CT) list-changed --config ct.yaml | { grep -v '^>>>' || true; }

# Each chart's install test lives in charts/<chart>/tests/e2e/chainsaw-test.yaml: it installs the chart,
# runs helm test, then uninstalls it the way the chart's README documents, and fails on any timeout.
# INSTALL_CHARTS defaults to the charts changed against main; set it to a chart list (INSTALL_CHARTS=charts/signoz)
# or to all.
INSTALL_CHARTS          ?=

.PHONY: chart-install-test
chart-install-test: ## Installs, tests and uninstalls the changed charts on the current cluster with chainsaw.
chart-install-test: $(CHAINSAW) $(CT) chart-deps
	@charts="$(if $(filter all,$(INSTALL_CHARTS)),$(CI_CHARTS),$(INSTALL_CHARTS))"; \
	if [ -z "$$charts" ]; then charts="$$($(CT) list-changed --config ct.yaml | grep -v '^>>>')"; fi; \
	if [ -z "$$charts" ]; then echo ">> No chart changed, skipping install tests"; exit 0; fi; \
	dirs=""; for chart in $$charts; do \
		if [ ! -f $$chart/tests/e2e/chainsaw-test.yaml ]; then echo ">> $$chart has no install test at $$chart/tests/e2e/chainsaw-test.yaml"; exit 1; fi; \
		dirs="$$dirs --test-dir $$chart/tests/e2e"; \
	done; \
	echo ">> Running install tests for" $$charts; \
	$(CHAINSAW) test $$dirs --no-color

# Kept only to compare install times against chainsaw; ct's clean-up runs a plain helm uninstall.
.PHONY: chart-install-test-ct
chart-install-test-ct: ## Installs and tests every chart on the current cluster with ct install.
chart-install-test-ct: $(CT)
	@echo ">> Installing all charts with ct"
	@$(CT) install --config ct.yaml --all --helm-extra-set-args '--set=otelCollectorEndpoint=endpoint-that-does-not-exist:4317 --set=env[0].name=SIGNOZ_URL --set=env[0].value=http://signoz.invalid:8080'

###############################################################
# chart-dev commands
###############################################################
RELEASE_NAME            ?= my-release
NAMESPACE               ?= platform

.PHONY: chart-dev-install
chart-dev-install: ## Installs or upgrades the local signoz chart as RELEASE_NAME in NAMESPACE.
chart-dev-install: chart-deps
	@echo ">> Installing charts/signoz as $(RELEASE_NAME) in namespace $(NAMESPACE)"
	@$(HELM) upgrade --install $(RELEASE_NAME) charts/signoz --namespace $(NAMESPACE) --create-namespace

.PHONY: chart-dev-uninstall
chart-dev-uninstall: ## Uninstalls RELEASE_NAME from NAMESPACE, keeping its volumes.
chart-dev-uninstall: $(HELM)
	@echo ">> Uninstalling $(RELEASE_NAME) from namespace $(NAMESPACE)"
	@$(HELM) uninstall $(RELEASE_NAME) --namespace $(NAMESPACE) --ignore-not-found

.PHONY: chart-dev-purge
chart-dev-purge: ## Uninstalls RELEASE_NAME and deletes NAMESPACE with everything in it, volumes included.
chart-dev-purge: chart-dev-uninstall
	@echo ">> Deleting namespace $(NAMESPACE)"
	@kubectl delete namespace $(NAMESPACE) --ignore-not-found
