#!/bin/bash

# ==============================================================================
# AKS Configuration Lab Cheatsheet
# ==============================================================================
# Define variables
RESOURCE_GROUP="rg-ai-aks-lab"
CLUSTER_NAME="aks-7225c45a"

# ------------------------------------------------------------------------------
# 1. Connect to the Cluster
# ------------------------------------------------------------------------------
# Why: Download the Kubeconfig credentials so kubectl can connect to the AKS cluster.
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing

# (Additional commands for ConfigMaps, Secrets, and Volumes will be added here 
# as we progress through the lab exercises.)
