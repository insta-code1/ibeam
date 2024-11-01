build:
	docker build -t ibkr-web-portal .

# Define variables
CHART_DIR := ./chart
OUTPUT_DIR := ./local-charts
K3S_NAMESPACE := ibeam
RELEASE_NAME := ibeam

# Target to render Helm chart templates locally
helm-template:
	helm template $(RELEASE_NAME) $(CHART_DIR) --namespace $(K3S_NAMESPACE) > $(OUTPUT_DIR)/rendered-template.yaml
	@echo "Helm chart templates rendered and saved to $(OUTPUT_DIR)/rendered-template.yaml"

# Ensure the output directory exists
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Target to generate a new release of the Helm chart and save it locally
helm-generate-chart: $(OUTPUT_DIR)
	helm package $(CHART_DIR) -d $(OUTPUT_DIR)
	@echo "Helm chart packaged and saved to $(OUTPUT_DIR)"


# Target to deploy the Helm chart to the k3s server
helm-deploy-to-k3s: helm-generate-chart
	helm upgrade --install $(RELEASE_NAME) $(OUTPUT_DIR)/$(RELEASE_NAME)-*.tgz --create-namespace --namespace $(K3S_NAMESPACE)
	@echo "Helm chart deployed to k3s server at $(K3S_SERVER)"

# Target to install the Helm chart to the k3s server
helm-install: helm-generate-chart
	helm install $(RELEASE_NAME) $(OUTPUT_DIR)/$(RELEASE_NAME)-*.tgz --namespace $(K3S_NAMESPACE) --create-namespace
	@echo "Helm chart installed to k3s server in namespace $(K3S_NAMESPACE)"


# Target to uninstall the Helm release from the k3s server
helm-uninstall:
	helm uninstall $(RELEASE_NAME) --namespace $(K3S_NAMESPACE)
	@echo "Helm release $(RELEASE_NAME) uninstalled from k3s server at $(K3S_SERVER)"

.PHONY: helm-template helm-generate-chart helm-deploy-to-k3s helm-install helm-uninstall

