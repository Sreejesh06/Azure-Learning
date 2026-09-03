# Azure Learning Repository Standards

You are operating within the `azure-learning` repository. When the user asks you to create or summarize a new module/lab, you MUST strictly adhere to the following file structures, documentation standards, and behavioral rules.

## 1. Zero "AI Slop" & No Skimming
- **Complete Information:** Never summarize or "skim" the source material. You must include all detailed concepts, architecture flows, debugging steps, and additional resource links provided in the raw material.
- **Tone & Formatting:** Do NOT use emojis in any of the documentation files (`.md` or `.mdx`). The writing style MUST be casual, conversational, and direct, exactly mirroring how the user speaks in their prompts (e.g., shorthand, casual phrasing, bro/ryt, no robotic or corporate speak). 
- **Visualizations:** Every module MUST include a clear, properly understandable visual flow or architecture diagram. The docs need to visually break down how things connect so it's easy to grasp at a glance.
- **Sync Requirement:** The core body content inside the `README.md` (in the lab directory) and the `.mdx` file (in the content directory) must be EXACTLY the same. *Exception:* The `.mdx` file uses YAML frontmatter at the top, while the `README.md` replaces that frontmatter with a standard `#` Markdown heading.

## 2. Documentation Pedagogy (The "Why" and the "Gotchas")
- **The "Why" Rule:** Inside the markdown documentation, every single CLI command block MUST be preceded by a **Why:** explanation. Do not just dump commands without explaining the rationale.
- **The "Gotcha" (Debugging) Format:** Any errors, roadblocks, or troubleshooting steps encountered during the lab MUST be documented using this strict format:
  - **Symptom:** (What broke or the error message)
  - **Why it happened:** (The underlying concept or configuration missing)
  - **The Fix:** (The exact command or action to resolve it)

## 3. Directory Structure & File Placement
Every new lab must touch two primary locations:

**A. The Content Directory (For the Static Site)**
- **Path:** `content/docs/lab-XX-<topic>.mdx`
- **Rules:**
  - Must be an `.mdx` file.
  - Must NOT use a top-level `#` Markdown heading.
  - MUST start with YAML frontmatter containing `title` and `description`.
    ```yaml
    ---
    title: XX - <Topic Name>
    description: <Comprehensive description of the lab>
    ---
    ```
  - MUST include a `## Visual Flow` section at the top to anchor any architecture diagrams.

**B. The Lab Environment Directory (For Hands-on Code)**
- **Path:** `labs/lab-XX-<topic>/`
- **Rules:**
  - **CRITICAL:** If the module requires any actual code files (e.g., Python scripts like `app.py`, `Dockerfile`, `requirements.txt`, or config files), they MUST be created exclusively in this `labs/lab-XX/` directory and nowhere else.
  - Must contain a `README.md` that mirrors the `.mdx` documentation (following the Sync Requirement).
  - Must contain a `commands_cheatsheet.sh` file.

## 4. The `commands_cheatsheet.sh` Standard
The cheatsheet must be an executable bash script containing the exact, real-world CLI commands used in the lab.
- Define variables at the top (e.g., `RESOURCE_GROUP="container-learning"`).
- Comment heavily to explain the *Why* of each command.
- Include debugging commands or prerequisite fixes (e.g., `az provider register`) if they were encountered.

**Enforcement:**
If you fail to follow these structural, pedagogical, and tonal guidelines, you are failing the user's explicit learning methodology. Double-check your output for emojis, missing concepts, and structural formatting before completing a turn.

---

## 5. Image Asset Handling & Responsive Display Standards
- **Copy to Codebase**: Whenever the user provides or pastes images, always copy them into **both** `public/images/` (for the website) AND `labs/lab-XX-<topic>/images/` (for local codebase reference).
- **Dimension Analysis**: Inspect image dimensions (`pixelWidth` and `pixelHeight`) using `sips` or image analysis tools before embedding images in documentation.
- **Proper Scaling & HTML Sizing**: Never embed images at raw unconstrained sizes if they distort the page layout.
  - For narrow vertical screenshots (e.g. sidebar tools), constrain the width (e.g., `<img src="..." width="350" alt="..." />`).
  - For standard rectangular diagrams/windows, use appropriate width limits (e.g., `<img src="..." width="600" alt="..." />`).
  - Ensure images render cleanly across both GitHub Markdown previews and MDX docs.

