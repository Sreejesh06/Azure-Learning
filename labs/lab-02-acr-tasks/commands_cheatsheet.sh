#!/usr/bin/env bash
# ==============================================================================
# Azure Container Registry (ACR) Tasks - Command Reference & Practice Cheatsheet
# ==============================================================================

# Variables (Replace with your own values when running in Azure)
RESOURCE_GROUP="rg-azure-learning"
LOCATION="eastus"
REGISTRY_NAME="myazurelearningacr$RANDOM" # ACR names must be globally unique alphanumeric
IMAGE_NAME="inference-api"
IMAGE_TAG="v1.0.0"

# ==============================================================================
# 0. SETUP: Create Resource Group and Azure Container Registry (if needed)
# ==============================================================================
# az group create --name $RESOURCE_GROUP --location $LOCATION
# az acr create --resource-group $RESOURCE_GROUP --name $REGISTRY_NAME --sku Basic --admin-enabled true

# ==============================================================================
# 1. QUICK TASKS: On-Demand Cloud Builds (No Local Docker Needed)
# ==============================================================================

# Option A: Build from local directory context (.)
# ACR compresses local directory, uploads it, builds image in Azure, and pushes to registry
az acr build \
  --registry $REGISTRY_NAME \
  --image ${IMAGE_NAME}:${IMAGE_TAG} \
  .

# Option B: Build directly from a remote Git repository (No local clone needed)
az acr build \
  --registry $REGISTRY_NAME \
  --image ${IMAGE_NAME}:${IMAGE_TAG} \
  https://github.com/Azure-Samples/acr-build-helloworld-node.git

# ==============================================================================
# 2. AUTOMATIC TRIGGERS: Source Code & Base Image Updates
# ==============================================================================

# A. Source Code Commit Trigger (GitHub / Azure DevOps)
# {{.Run.ID}} automatically assigns a unique build identifier to the tag
# az acr task create \
#   --registry $REGISTRY_NAME \
#   --name task-build-on-commit \
#   --image ${IMAGE_NAME}:{{.Run.ID}} \
#   --context https://github.com/myorg/inference-api.git#main \
#   --file Dockerfile \
#   --git-access-token "$GITHUB_PAT"

# B. Scheduled Trigger (Cron syntax: Minute Hour Day Month DayOfWeek)
# Example: Runs nightly build at midnight (00:00 UTC)
# az acr task create \
#   --registry $REGISTRY_NAME \
#   --name task-nightly-build \
#   --image ${IMAGE_NAME}:nightly \
#   --context https://github.com/myorg/inference-api.git \
#   --schedule "0 0 * * *" \
#   --file Dockerfile \
#   --git-access-token "$GITHUB_PAT"

# C. Base Image Trigger (Enabled by default!)
# When python:3.11-slim or a parent image updates, ACR detects it automatically
# To check or update base image trigger status:
# az acr task update \
#   --registry $REGISTRY_NAME \
#   --name task-build-on-commit \
#   --base-image-trigger-enabled true

# ==============================================================================
# 3. MULTI-STEP TASKS: Build -> Test with Pytest -> Push
# ==============================================================================

# Run multi-step task immediately from local context using acr-task.yaml:
az acr run \
  --registry $REGISTRY_NAME \
  --file acr-task.yaml \
  .

# ==============================================================================
# 4. SMOKE TESTING & RUNNING CONTAINERS IN ACR (az acr run)
# ==============================================================================

# Execute a quick command inside the container in the cloud without deploying
# The /dev/null context tells ACR no source files need to be uploaded
az acr run \
  --registry $REGISTRY_NAME \
  --cmd '$Registry/inference-api:v1.0.0 python -c "import fastapi; print(fastapi.__version__)"' \
  /dev/null

# ==============================================================================
# 5. MONITORING, LOGS & MANAGEMENT
# ==============================================================================

# List all registered tasks in ACR
az acr task list --registry $REGISTRY_NAME --output table

# View real-time logs of a specific build run
# az acr task logs --registry $REGISTRY_NAME --run-id <run-id>

# List all repositories & tags in your registry
az acr repository list --name $REGISTRY_NAME --output table
az acr repository show-tags --name $REGISTRY_NAME --repository $IMAGE_NAME --output table
