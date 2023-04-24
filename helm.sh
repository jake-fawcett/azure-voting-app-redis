# Script looking at Helm Quickstart
# https://learn.microsoft.com/en-us/azure/aks/quickstart-helm?tabs=azure-cli

helm create azure-vote-front-helm

# Modifications from Quickstart

helm install azure-vote-front azure-vote-front-helm/

# Additional deployment created in azure-pipelines.yml to test Pipeline Deployment

# - - - - - - - - - - - - - - - - Publish Helm - - - - - - - - - - - - - - - -

USER_NAME="00000000-0000-0000-0000-000000000000"
PASSWORD=$(az acr login --name $containerRegistryLoginServer --expose-token --output tsv --query accessToken)

helm push hello-world-0.1.0.tgz oci://$containerRegistry.azurecr.io/helm