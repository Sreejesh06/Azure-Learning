#!/bin/bash

# ======================================================
# LAB 04: Sidecar-Enabled AI Applications on Azure App Service
# ======================================================
# Environment aligned with Lab 01 & Lab 03 repository standards.

set -e

# 1. Environment Variables
RESOURCE_GROUP="container-learning"
REGISTRY_NAME="acrlab06"
PLAN_NAME="inference-plan"
APP_NAME="inference-sidecar-app" # Unique Web App Name
MAIN_IMAGE="$REGISTRY_NAME.azurecr.io/inference-api:latest"
SIDECAR_IMAGE="$REGISTRY_NAME.azurecr.io/model-server:latest"

echo "=== 1. Checking Provider & Resource Group ==="
az provider register -n Microsoft.Web
az group create -n $RESOURCE_GROUP -l eastus -o table || true

echo "=== 2. Creating Linux App Service Plan ($PLAN_NAME) ==="
az appservice plan create \
  -n $PLAN_NAME \
  -g $RESOURCE_GROUP \
  --is-linux \
  --sku B1 \
  -o table || true

echo "=== 3. Creating Sitecontainer-Enabled Web App ($APP_NAME) ==="
az webapp create \
  -g $RESOURCE_GROUP \
  -p $PLAN_NAME \
  -n $APP_NAME \
  --sitecontainers-app \
  -o table

echo "=== 4. Setting Source App Settings ==="
az webapp config appsettings set \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --settings \
    MODEL_ENDPOINT_VALUE="http://localhost:11434" \
    MODEL_NAME_VALUE="phi-3-mini-instruct" \
  -o table

echo "=== 5. Enabling System-Assigned Managed Identity ==="
PRINCIPAL_ID=$(az webapp identity assign \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --query principalId \
  -o tsv)

ACR_ID=$(az acr show \
  -g $RESOURCE_GROUP \
  -n $REGISTRY_NAME \
  --query id \
  -o tsv)

echo "=== 6. Granting AcrPull Role on $REGISTRY_NAME ==="
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --scope $ACR_ID \
  --role AcrPull \
  -o table || true

echo "=== 7. Deploying Declarative Sitecontainer Specification ==="
az webapp sitecontainers create \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --sitecontainers-spec-file ./sitecontainers-spec.json \
  -o table

echo "=== 8. Verifying Sitecontainers Deployment ==="
az webapp sitecontainers list \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  -o table

az webapp sitecontainers show \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --container-name model-server

echo "=== 9. Diagnostic Commands ==="
echo "Checking Sidecar Platform Runtime Status..."
az webapp sitecontainers status \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --container-name model-server || true

echo "Retrieving Sidecar Container Process Logs..."
az webapp sitecontainers log \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --container-name model-server || true

