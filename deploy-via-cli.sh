resourceGroup="kube-app"
containerRegistry="jakefkubeacr"
containerRegistryLoginServer="${containerRegistry}.azurecr.io"
clusterName="kube-cluster"

az group create --name $resourceGroup --location uksouth
az acr create --resource-group $resourceGroup --name $containerRegistry --sku Basic

az acr login --name $containerRegistryLoginServer
docker login # Errors without Docker login

docker tag mcr.microsoft.com/azuredocs/azure-vote-front:v1 $containerRegistryLoginServer/azure-vote-front:v1
docker push $containerRegistryLoginServer/azure-vote-front:v1

az aks create \
    --resource-group $resourceGroup \
    --name $clusterName \
    --node-count 2 \
    --generate-ssh-keys \
    --attach-acr $containerRegistry

az aks get-credentials --resource-group $resourceGroup --name $clusterName

kubectl apply -f azure-vote-all-in-one-redis.yaml

# - - - - - - - - - - - - - - - - Scale Application - - - - - - - - - - - - - - - -
# Example Scale:
# kubectl scale --replicas=5 deployment/azure-vote-front

# Example Autoscale:
# kubectl autoscale deployment azure-vote-front --cpu-percent=50 --min=3 --max=10

# Autoscale via Manefest file:
# kubectl apply -f azure-vote-hpa.yaml

# Scale nodes:
# az aks scale --resource-group $resourceGroup --name $clusterName --node-count 3

# - - - - - - - - - - - - - - - - Update Application - - - - - - - - - - - - - - - -
# Pushing update:
# Update App (i.e. config_file.cfg)
# Build Image (docker-compose up)
# Tag Image (docker tag mcr.microsoft.com/azuredocs/azure-vote-front:v1 $containerRegistryLoginServer/azure-vote-front:v2)
# Push Image (docker push $containerRegistryLoginServer/azure-vote-front:v2)
# Update K8 (kubectl set image deployment azure-vote-front azure-vote-front=$containerRegistryLoginServer/azure-vote-front:v2)


# - - - - - - - - - - - - - - - - Upgrading Clusters - - - - - - - - - - - - - - - -

# Check version and upgrades:
# az aks get-upgrades --resource-group $resourceGroup --name $clusterName

# Note:
# You can only upgrade one minor version at a time. 
# For example, you can upgrade from 1.14.x to 1.15.x, but you cannot upgrade from 1.14.x to 1.16.x directly. 
# To upgrade from 1.14.x to 1.16.x, you must first upgrade from 1.14.x to 1.15.x, then perform another upgrade from 1.15.x to 1.16.x.

# Upgrade:
# az aks upgrade \
#     --resource-group $resourceGroup \
#     --name $clusterName \
#     --kubernetes-version 1.26.0