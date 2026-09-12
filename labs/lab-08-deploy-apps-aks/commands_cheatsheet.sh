#!/bin/bash

# ==============================================================================
# AKS Deployment Lab Cheatsheet
# ==============================================================================
# Define variables
RESOURCE_GROUP="rg-ai-aks-lab"
REGISTRY_NAME="acr7225c45a"
CLUSTER_NAME="aks-7225c45a"
LOCATION="eastasia"
# Using Standard_B2s_v2 because student policy blocks D2s_v3 and quota blocks D2s_v5
VM_SIZE="Standard_B2s_v2"

# ------------------------------------------------------------------------------
# 1. Local Docker Build (ACR Tasks Bypass)
# ------------------------------------------------------------------------------
# Why: Azure for Students disables `az acr build`. We must log in locally to push.
az acr login --name $REGISTRY_NAME

# Why: Build the Docker image locally, forcing linux/amd64 architecture for AKS.
docker build --platform linux/amd64 -t ${REGISTRY_NAME}.azurecr.io/aks-api:latest ./api

# Why: Push the locally built image to the Azure Container Registry.
docker push ${REGISTRY_NAME}.azurecr.io/aks-api:latest

# ------------------------------------------------------------------------------
# 2. AKS Cluster Creation
# ------------------------------------------------------------------------------
# Why: Provision a managed Kubernetes cluster that satisfies both quota and policy.
# We attach the ACR so the cluster has permission to pull our images.
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --location $LOCATION \
  --node-count 1 \
  --node-vm-size $VM_SIZE \
  --tier free \
  --network-plugin azure \
  --no-ssh-key \
  --attach-acr $REGISTRY_NAME \
  --enable-managed-identity

# ------------------------------------------------------------------------------
# 3. Kubernetes Deployment
# ------------------------------------------------------------------------------
# Why: Download the Kubeconfig credentials so kubectl can connect to the new cluster.
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing

# Why: Apply the Deployment and Service manifests to spin up the API and Load Balancer.
# (Note: We had to fix deployment.yaml to set OPENAI_API_ENDPOINT="https://www.microsoft.com"
# to prevent the readiness probe from crashing the pod).
kubectl apply -f k8s/

# Why: Watch the LoadBalancer provision a public IP address.
kubectl get service aks-api-service --watch

# ------------------------------------------------------------------------------
# 4. Client Testing & Cleanup
# ------------------------------------------------------------------------------
# Why: Tell the local client script where the cloud API is hosted.
export API_ENDPOINT="http://<YOUR_EXTERNAL_IP>"
python3 client/main.py

# Why: Delete the entire resource group to avoid burning through free credits!
az group delete --name $RESOURCE_GROUP --yes --no-wait
