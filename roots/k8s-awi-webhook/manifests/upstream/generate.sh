helm repo add azure-workload-identity https://azure.github.io/azure-workload-identity/charts
helm repo update
helm template workload-identity-webhook azure-workload-identity/workload-identity-webhook \
   --namespace azure-workload-identity-system \
   --version "1.6.0" \
   --create-namespace \
   --set azureTenantID="REPLACE_THIS" > azure-wi-webhook.yaml
