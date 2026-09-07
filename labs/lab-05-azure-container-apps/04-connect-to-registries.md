# 04 - Connect to Private Registries

## Visual Flow

<Mermaid chart={`
%%{init: {'theme': 'default'}}%%
flowchart TB
    subgraph Registry [Azure Container Registry]
        Images[("Private AI Images")]
        Bouncer{"Auth Gate (RBAC)"}
        Images -. Protected by .- Bouncer
    end

    subgraph Identity [Azure AD / Entra ID]
        MI["Managed Identity<br/>(Badge)"]
    end

    subgraph App [Azure Container App]
        Kubelet["Runtime Injector"]
        Kubelet -. Wears .- MI
    end

    Kubelet -->|Attempts Pull| Bouncer
    Bouncer -->|Verifies AcrPull Role| MI
    Bouncer -->|Allows Pull| Images
`} />

### Flow Explanation
The architecture above shows how Azure Container Apps securely downloads proprietary images. Instead of hardcoding passwords, the Container App is assigned a **Managed Identity** (its ID badge). When the container runtime attempts to pull an image, the registry (the bouncer) checks Azure AD to verify that this exact identity has the `AcrPull` permission. If verified, the image pull succeeds.

## Overview
When deploying production AI services, you never put your code in public Docker registries. Private registries like Azure Container Registry (ACR) protect your intellectual property, control supply chain risk, and enforce vulnerability scanning. 

However, since the registry is private, Azure Container Apps (ACA) needs permission to pull those images. This lesson covers the two ways to authenticate: the old legacy way, and the secure cloud-native way.

## Method 1: Username and Password

The quickest way to connect to a registry is to pass the explicit admin username and password.

**Why:** You might use this method for a quick proof of concept or if you are connecting to a third-party non-Azure registry that doesn't support Managed Identities. 

```bash
az containerapp registry set \
  -n ai-api \
  -g rg-aca-demo \
  --server myregistry.azurecr.io \
  --username MyRegistryUsername \
  --password MyRegistryPassword
```

This method is heavily discouraged for production because managing passwords is a massive operational overhead. Passwords leak, they have to be rotated manually, and if you forget to update your apps when rotating a password, everything breaks.

## Method 2: Managed Identity (Best Practice)

This is the cloud-native standard for Azure. Instead of relying on passwords, you grant the Container App an invisible identity. You then assign that identity the exact minimum permission it needs (the `AcrPull` role) directly on the registry.

**Why:** You use this method to eliminate secret rotation and drastically reduce your attack surface. There are zero passwords to leak.

```bash
az containerapp registry set \
  -n ai-api \
  -g rg-aca-demo \
  --server myregistry.azurecr.io \
  --identity system
```

## Debugging and Validation

When debugging image pull failures, checking the configured registries is always step one.

### Gotcha: App gets stuck or fails to start

- **Symptom:** You deploy a new revision, but the container app never boots. The deployment times out or logs show "ImagePullBackOff" or permission errors.
- **Why it happened:** The registry configuration is completely separate from application configuration. If the app lacks the `AcrPull` permission or has a stale password, the orchestrator cannot pull the image to run it.
- **The Fix:** Verify exactly which registries are configured on the app and test the authentication.

**Why:** You need to list the attached registries to verify there is no configuration drift.

```bash
az containerapp registry list \
  -n ai-api \
  -g rg-aca-demo
```

**Why:** You need to inspect the exact configuration (whether it's using passwords or managed identities) for a specific registry endpoint.

```bash
az containerapp registry show \
  -n ai-api \
  -g rg-aca-demo \
  --server myregistry.azurecr.io
```

## Strategic Best Practices
- **Prefer managed identity for Azure Container Registry:** Use the `--identity` flag to completely drop reliance on long-lived credentials.
- **Grant least privilege:** Never give "Contributor" access. Assign only the `AcrPull` role to identities that pull images.
- **Validate auth during rollout:** Deploy a new revision and manually verify it starts successfully before walking away, ensuring the registry connection works.
