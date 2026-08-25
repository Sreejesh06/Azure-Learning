# Azure AI Cloud Developer Associate (AI-200) Learning Lab

Welcome to the hands-on learning workspace for **Microsoft Certified: Azure AI Cloud Developer Associate (AI-200)**.

This repository is organized into progressive, code-first modules designed to build real-world, cloud-native AI systems on Microsoft Azure.

---

## 🗺️ Learning Roadmap & Exam Domains

```mermaid
flowchart TD
    M1["01: Identity, Auth & Model Inference\n(DefaultAzureCredential, AI Foundry SDK)"] --> M2["02: Vector Search & Data Ingestion\n(Azure AI Search, Cosmos DB Vector Index)"]
    M2 --> M3["03: Cloud-Native AI Compute\n(FastAPI, Docker, Azure Container Apps)"]
    M3 --> M4["04: Async & Event-Driven AI\n(Service Bus, Event Grid)"]
    M4 --> M5["05: Observability & Evaluation\n(App Insights, OpenTelemetry, AI Guardrails)"]
```

---

## 📂 Module Breakdown

| Module | Core Topics | Key Azure Services / SDKs |
| :--- | :--- | :--- |
| **`01-ai-foundry-identity-inference`** | Zero-trust auth, Entra ID, chat completions, streaming, retry policies | `azure-identity`, `azure-ai-inference`, `openai` |
| **`02-vector-search-and-data`** | Embeddings, vector indexing, hybrid search (BM25 + vector), RAG | `azure-search-documents`, `azure-cosmos` |
| **`03-container-apps-and-compute`** | Microservice AI APIs, ACA scaling, health probes, Docker | Azure Container Apps, Azure Container Registry, FastAPI |
| **`04-event-driven-ai-pipelines`** | Async batch processing, message queuing, dead-lettering | Azure Service Bus, Event Grid, Storage Queues |
| **`05-observability-and-evaluation`** | Distributed tracing, token tracking, latency, groundness evaluation | Azure Monitor, Application Insights, OpenTelemetry |

---

## 🔑 Key Cloud AI Principle: Zero-Trust & Passwordless
In AI-200, **hardcoded API keys are considered an anti-pattern**. 
Production backends use **Microsoft Entra ID Role-Based Access Control (RBAC)** and **Managed Identities** (`DefaultAzureCredential`) so secrets never leak into code or environment files.
