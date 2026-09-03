#!/bin/bash

# ======================================================
# LAB 03: Deploying Containers to Azure App Service
# ======================================================
# This script contains the exact CLI commands used during the lab.
# Update the variables below before running.

# 1. Variables
RESOURCE_GROUP="container-learning"
REGISTRY_NAME="acrlab06"
PLAN_NAME="inference-plan"
APP_NAME="inference-api-test" # Must be globally unique
IMAGE_NAME="$REGISTRY_NAME.azurecr.io/inference-api:latest"

# 2. Setup & Provider Check
# az provider register -n Microsoft.Web
# az provider show -n Microsoft.Web --query "registrationState"

# 3. Create App Service Plan (B1 Linux Tier)
az appservice plan create \
  -n $PLAN_NAME \
  -g $RESOURCE_GROUP \
  --is-linux \
  --sku B1

# 4. Create Web App and Specify Container Image
az webapp create \
  -g $RESOURCE_GROUP \
  -p $PLAN_NAME \
  -n $APP_NAME \
  --container-image-name $IMAGE_NAME

# ======================================================
# 5. Production Authentication: Managed Identity (AcrPull Role)
# ======================================================

# A. Enable System-Assigned Identity on Web App
az webapp identity assign \
  -g $RESOURCE_GROUP \
  -n $APP_NAME

# B. Get Web App Principal ID and ACR Scope ID
PRINCIPAL_ID=$(az webapp identity show -g $RESOURCE_GROUP -n $APP_NAME --query principalId -o tsv)
ACR_ID=$(az acr show -g $RESOURCE_GROUP -n $REGISTRY_NAME --query id -o tsv)

# C. Assign AcrPull Role to Web App Identity
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --scope $ACR_ID \
  --role AcrPull

# D. Configure App Service to Use Managed Identity for ACR Pulls
az webapp config set \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --acr-use-identity true \
  --acr-identity [system]

az webapp config container set \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --container-image-name $IMAGE_NAME \
  --container-registry-url "https://$REGISTRY_NAME.azurecr.io"

# 6. Verify URL
echo "App URL:"
az webapp show -g $RESOURCE_GROUP -n $APP_NAME --query defaultHostName -o tsv

# ======================================================
# 7. Configure Container Runtime Behavior
# ======================================================

# A. Override Startup Command
az webapp config set \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --startup-file "gunicorn --bind=0.0.0.0:8000 --workers=4 app:application"

# B. Configure Container Port (e.g., app listens on 8000)
az webapp config appsettings set \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --settings WEBSITES_PORT=8000

# C. Enable Persistent Storage at /home
az webapp config appsettings set \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=true

# D. Enable Always-On (Eliminates Cold Starts)
az webapp config set \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --always-on true

# E. Configure Automated Health Check Endpoint (/health)
az webapp config set \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --generic-configurations '{"healthCheckPath": "/health"}'

# ======================================================
# 8. Configure Application Settings & Secrets
# ======================================================

# A. Set Environment Variables
az webapp config appsettings set \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --settings \
    STORAGE_ACCOUNT_NAME=mystorageaccount \
    LOG_LEVEL=INFO \
    MAX_DOCUMENT_SIZE_MB=50

# B. Export App Settings to JSON
az webapp config appsettings list \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --output json > settings.json

# C. Bulk Import App Settings from JSON (@settings.json)
# az webapp config appsettings set -g $RESOURCE_GROUP -n $APP_NAME --settings @settings.json

# D. Set Slot-Sticky Settings (Will NOT swap during slot swaps)
# az webapp config appsettings set -g $RESOURCE_GROUP -n $APP_NAME --slot staging --slot-settings ENVIRONMENT=staging

# E. Configure Key Vault Reference
# az webapp config appsettings set -g $RESOURCE_GROUP -n $APP_NAME --settings API_KEY="@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/api-key)"

# ======================================================
# 9. Observability, Logging & Troubleshooting
# ======================================================

# A. Enable Container Logging (Filesystem)
az webapp log config \
  -g $RESOURCE_GROUP \
  -n $APP_NAME \
  --docker-container-logging filesystem

# B. Tail Real-Time Container Output
# az webapp log tail -g $RESOURCE_GROUP -n $APP_NAME

# C. Connect to Container SSH Shell (Port 2222 required inside image)
# az webapp ssh -g $RESOURCE_GROUP -n $APP_NAME

# D. Debug ACR Task Builds
# az acr task list-runs --registry $REGISTRY_NAME --output table
# az acr task logs --registry $REGISTRY_NAME --run-id <RUN_ID>

# 10. Enable Continuous Deployment (CD Webhook)
# az webapp deployment container config -g $RESOURCE_GROUP -n $APP_NAME --enable-cd true
