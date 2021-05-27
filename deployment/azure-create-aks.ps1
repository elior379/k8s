############################
### Global ocnfigruation ###
############################

## Variables
$AZ_USERNAME = "***"
$AZ_PASSWORD = "***"
Write-Host "AZ_USERNAME: $AZ_USERNAME"
Write-Host "AZ_PASSWORD: $AZ_PASSWORD"

$AZ_LOCATION = "japaneast"
$AZ_SUBSCRIPTION = "au10tix-prod-ejp"

Write-Host "AZ_LOCATION: $AZ_LOCATION"
Write-Host "AZ_SUBSCRIPTION: $AZ_SUBSCRIPTION"

## Resource
$RESOURCE_PREFIX    = "prod-ejp"
$RESOURCE_NAME      = "aks"
Write-Host "RESOURCE_PREFIX: $RESOURCE_PREFIX"
Write-Host "RESOURCE_NAME: $RESOURCE_NAME"

# Cluster
$AKS_VM_STANDARD_NODES_COUNT = 1
$AKS_VM_STANDARD = "Standard_B2s"
Write-Host "AKS_VM_STANDARD_NODES_COUNT: $AKS_VM_STANDARD_NODES_COUNT"
Write-Host "AKS_VM_STANDARD: $AKS_VM_STANDARD"

$AKS_VM_GPU_NODES_COUNT = 1
$AKS_VM_GPU = "Standard_NC6_Promo"
Write-Host "AKS_VM_GPU_NODES_COUNT: $AKS_VM_GPU_NODES_COUNT"
Write-Host "AKS_VM_GPU: $AKS_VM_GPU"

# Service principal Section
$SERVICE_PRINCIPAL_ID = SERVICE_PRINCIPAL_ID
Write-Host "SERVICE_PRINCIPAL_ID: $SERVICE_PRINCIPAL_ID"

# The resource group in which all the resources will be under
$RESOURCE_GROUP = "$RESOURCE_PREFIX-$RESOURCE_NAME"
Write-Host "RESOURCE_GROUP: $RESOURCE_GROUP"

# Cluster
$AKS_CLUSTER_NAME = "$RESOURCE_PREFIX-$RESOURCE_NAME-cluster"
Write-Host "AKS_CLUSTER_NAME: $AKS_CLUSTER_NAME"

# Login 
az logout
$COMMAND = "az login ``
	-u $AZ_USERNAME ``
	-p $AZ_PASSWORD ``
	--output table"
Write-Host $COMMAND
Invoke-Expression $Command

# Set subscription
$COMMAND = "az account set -s $AZ_SUBSCRIPTION"
Write-Host $COMMAND
Invoke-Expression $Command

# Verify subscription
$COMMAND = "az account show --output table"
Write-Host $COMMAND
Invoke-Expression $Command

# Get the K8S version
$COMMAND = "az aks get-versions -l $AZ_LOCATION --query 'orchestrators[-1].orchestratorVersion' -o tsv"
Write-Host $COMMAND
$AKS_K8S_VERSION = Invoke-Expression $Command
Invoke-Expression $Command
Write-Host "AKS_K8S_VERSION: $AKS_K8S_VERSION"

# Check to see if the resource group already exist

$COMMAND = "``
az group create ``
    --name $RESOURCE_GROUP ``
    --location $AZ_LOCATION ``
    --output table"
Write-Host $COMMAND
Invoke-Expression $Command

#create aks cluster
$COMMAND = "``
az aks create ``
    --node-count $AKS_VM_STANDARD_NODES_COUNT ``
    --min-count 1 ``
    --max-count 3 ``
    --generate-ssh-keys ``
    --network-plugin azure ``
    --name $AKS_CLUSTER_NAME ``
    --enable-cluster-autoscaler ``
    --node-vm-size Standard_B2s ``
    --load-balancer-sku Standard ``
    --resource-group $RESOURCE_GROUP ``
    --vm-set-type VirtualMachineScaleSets ``
    --kubernetes-version $AKS_K8S_VERSION ``
    --enable-addons monitoring,http_application_routing ``
    --client-secret *** ``
    --service-principal *** ``
    --verbose ``
    --output json"
Write-Host $COMMAND
Invoke-Expression $Command

# add the AKS node
$COMMAND = "``
az aks nodepool add ``
	--cluster-name $AKS_CLUSTER_NAME ``
	--name nodegpu ``
	--resource-group $RESOURCE_GROUP ``
    --node-vm-size Standard_NC6_Promo ``
    --enable-cluster-autoscaler ``
    --node-count $AKS_VM_STANDARD_NODES_COUNT ``
    --min-count 1 ``
    --max-count 3 ``
    --kubernetes-version $AKS_K8S_VERSION"
Write-Host $COMMAND
Invoke-Expression $Command

# add the AKS node
$COMMAND = "``
az aks nodepool add ``
	--cluster-name $AKS_CLUSTER_NAME ``
	--name nodegpu2 ``
	--resource-group $RESOURCE_GROUP ``
    --node-vm-size Standard_NC12_Promo ``
    --enable-cluster-autoscaler ``
    --node-count $AKS_VM_STANDARD_NODES_COUNT ``
    --min-count 1 ``
    --max-count 3 ``
    --kubernetes-version $AKS_K8S_VERSION"
Write-Host $COMMAND
Invoke-Expression $Command

