# Fumadocs MDX Frontmatter Requirements

When creating or editing `.mdx` files in this repository (which uses Fumadocs/Next.js), you **MUST** include YAML frontmatter at the top of the file containing at least a `title` string. 

## The Root Cause
The Fumadocs `mdx.js` parser strictly expects frontmatter in every MDX file. If an `.mdx` file is completely empty or is missing the `title` field, the Next.js Turbopack build process will instantly fail during Vercel deployment with the following error:
`Error: [MDX] invalid frontmatter in /path/to/file.mdx: title: Invalid input: expected string, received undefined`

## The Solution
Never leave an `.mdx` file empty. Every MDX file must start with this minimum structure:
```mdx
---
title: Your Page Title
description: Your page description
---

# Your Content Here
```
