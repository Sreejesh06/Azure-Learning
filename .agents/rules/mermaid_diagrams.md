---
description: Guidelines for choosing between standard flowcharts and architecture-beta syntax for Mermaid diagrams.
---

# Mermaid Diagram Guidelines

When creating architectural diagrams for documentation in this repository, you should choose the Mermaid syntax that best balances visual clarity and readability for the specific context.

## 1. Standard Flowchart (Preferred for complex logic)
Use standard `flowchart LR` (or `TD`) with custom styling when mapping out complex logic, multi-node connections, or when elements need to be highly distinct (e.g., a KEDA scaler routing traffic to multiple worker replicas).

**Requirements:**
- Use `subgraph` blocks to logically group related components (e.g., "External Traffic" vs "Azure Container Apps").
- Apply inline styles (e.g., `style node fill:#ffb900`) to color-code and highlight critical components like decision engines or databases.
- Ensure strict compliance with the `no_emojis_in_docs.md` rule (do not use emojis in node labels).

## 2. Architecture-Beta (Preferred for simple, linear flows)
You may use the experimental `architecture-beta` syntax for simple, linear, point-to-point diagrams (e.g., Azure Service Bus -> Background Worker) where the clean, native icons look professional and overlapping text bugs are unlikely to occur. 

**Requirements:**
- **DO NOT** use `architecture-beta` if there are multiple overlapping edges connecting to a single central node (e.g., a hub-and-spoke model). The beta layout engine struggles with this and will crash the nodes together into an unreadable mess.
- Stick to standard 1-to-1 mappings when using the beta syntax.

## 3. Diagram Frequency and Placement
There is **no limit** to the number of diagrams you can place on a single page. 
- You should proactively insert diagrams *anywhere* a complex concept, architecture, or workflow is being introduced.
- If a diagram makes the content easier to grasp, understand, or visualize for the reader, add it immediately—do not hesitate to use multiple diagrams throughout a document to break down different parts of a complex system.
