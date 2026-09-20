---
description: Defines the required teaching flow when the user provides MS Learn content.
---

# Teaching Flow for MS Learn Content

When the user provides content from an MS Learn module to process and add to the documentation, follow this strict flow:

1. **NO SKIMMING / 100% KNOWLEDGE RETENTION**:
   - You are explicitly forbidden from summarizing away the depth of the provided text. Do not provide a "TL;DR".
   - You must transfer 100% of the concepts, constraints, rules, and technical nuances exactly as they appear in the source text.
   - If the text mentions 4 rules, you must teach all 4 rules. If it mentions a side-effect (e.g., RU financial penalties), you must teach the side-effect.

2. **Teach First, Do Not Skip Points**: 
   - Analyze the provided text thoroughly.
   - Teach the content to the user comprehensively **in the chat first**. 
   - Break down every point, explain the *what* and *why*, and wait for their acknowledgment.

3. **Format as Context ➡️ Concept ➡️ Code**:
   - Structure your teaching (and the resulting documentation) strictly as:
     - **Context:** The real-world scenario or problem.
     - **Concept:** The Database configuration or technical rule.
     - **Code:** The specific JSON/SQL or implementation.
   - Explicitly separate Database Configuration (Step 1) from Application Execution (Step 2) when applicable.

4. **Wait for Confirmation**: 
   - Do not update or write the `.mdx` files until the chat explanation is complete and the user is ready.

5. **Mermaid Diagram Safety**: 
   - When generating Mermaid diagrams for MDX (Fumadocs), ensure strict syntax. 
   - Never use special characters or unescaped characters in node text. 
   - Always wrap node text containing spaces or symbols entirely in quotes (e.g., `NodeId["Text with spaces (and symbols)"]`). 
   - Never do `NodeId["Text" (symbols)]` as it will break the Markdown parser and crash the dev server.
