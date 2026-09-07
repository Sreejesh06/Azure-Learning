#!/bin/bash
# ----------------------------------------------------------------------------
# 04 - Connect to Private Registries Cheatsheet
# ----------------------------------------------------------------------------
# Variables
APP_NAME="ai-api"
RG_NAME="rg-aca-demo"
REGISTRY_SERVER="myregistry.azurecr.io"

# ----------------------------------------------------------------------------
# Method 1: Username & Password (Not Recommended for Production)
# Why: Used for quick tests or third-party registries lacking managed identity support.
# ----------------------------------------------------------------------------
# az containerapp registry set \
#   -n $APP_NAME \
#   -g $RG_NAME \
#   --server $REGISTRY_SERVER \
#   --username MyRegistryUsername \
#   --password MyRegistryPassword

# ----------------------------------------------------------------------------
# Method 2: Managed Identity (Best Practice)
# Why: Assigns the 'system' managed identity, eliminating secret rotation and leaks.
# ----------------------------------------------------------------------------
az containerapp registry set \
  -n $APP_NAME \
  -g $RG_NAME \
  --server $REGISTRY_SERVER \
  --identity system

# ----------------------------------------------------------------------------
# Debugging & Validation
# ----------------------------------------------------------------------------
# Why: List all attached registries to verify there is no configuration drift.
az containerapp registry list \
  -n $APP_NAME \
  -g $RG_NAME

# Why: Inspect the exact authentication configuration for a specific registry endpoint.
az containerapp registry show \
  -n $APP_NAME \
  -g $RG_NAME \
  --server $REGISTRY_SERVER
