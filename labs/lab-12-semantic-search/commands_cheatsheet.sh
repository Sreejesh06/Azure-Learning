#!/bin/bash

# ==============================================================================
# Lab 12: Semantic Search - Azure CLI Cheatsheet
# ==============================================================================

# Variables from Lab 11
RESOURCE_GROUP="rg-cosmos-rag-lab"
LOCATION="centralindia"
# Retrieve your specific Cosmos Account Name (since it had random hex characters)
COSMOS_ACCOUNT_NAME=$(az cosmosdb list --resource-group $RESOURCE_GROUP --query "[0].name" --output tsv)

echo "Cosmos DB Account: $COSMOS_ACCOUNT_NAME"

# 1. Update existing account to support Vector Search
# In a production environment, this is often done at creation time. 
# We are attempting to update our existing account to save time.
az cosmosdb update \
    --name $COSMOS_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --capabilities EnableNoSQLVectorSearch
