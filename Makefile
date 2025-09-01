RELEASE_NAME := my-release
NAMESPACE := platform # k8s namespace for installing the chart

delete-namespace:
	kubectl delete namespace $(NAMESPACE)

add-repository:
	helm repo add --force-update signoz https://charts.signoz.io

update-repository:
	helm repo update

dependency-update:
	helm dependency update charts/signoz

setup: add-repository update-repository

local-setup: dependency-update

# print resulting manifests to console without applying them
debug:
	helm install --dry-run --debug $(RELEASE_NAME) signoz/signoz

# install the chart to configured namespace
install: setup
	helm upgrade -i $(RELEASE_NAME) -n $(NAMESPACE) --create-namespace signoz/signoz

# uninstall the chart and resources from configured namespace
uninstall:
	helm uninstall -n $(NAMESPACE) $(RELEASE_NAME)

# delete all resources from configured namespace
delete: uninstall
	kubectl delete all,pvc,cm --all -n $(NAMESPACE)

upgrade: create-namespace
	helm upgrade $(RELEASE_NAME) -n $(NAMESPACE) --create-namespace

list:
	kubectl get all -n $(NAMESPACE)

list-all:
	kubectl get all,pvc,cm -n $(NAMESPACE)

# install the local development chart to configured namespace
dev-install: local-setup
	helm upgrade -i $(RELEASE_NAME) -n $(NAMESPACE) --create-namespace charts/signoz

re-install: delete install

purge: delete delete-namespace

# generate docs for the signoz and k8s-infra chart with respective templates
# generate docs for specified charts with respective templates
# Usage: make chart-docs CHARTS=chart1,chart2
# Example: make chart-docs CHARTS=charts/signoz,charts/k8s-infra
CHARTS ?= charts/signoz,charts/k8s-infra
HELM_DOCS = go run github.com/norwoodj/helm-docs/cmd/helm-docs@v1.14.2
chart-docs:
	$(HELM_DOCS) --chart-search-root=charts --template-files=README.md.gotmpl --chart-to-generate=$(CHARTS) --sort-values-order=file
