---
name: design-doc-render
description: Render a clean, concise, interactive HTML visualization of a design document or implementation plan for fast human review. Includes interactive Mermaid schemas, decision matrices, and phase checklists. If you are the main agent writing a design doc, delegate this rendering to a sub-agent. If you are called explicitly or are running as a sub-agent, render directly.
license: MIT
allowed-tools: Bash(open *) Bash(xdg-open *) Bash(start *)
argument-hint: Path to design document markdown file
---

Render a design document (`docs/design/yyyy-MM-dd-<slug>.md` or current plan) into a self-contained, visually clean HTML report for human review.

## Role & Delegation Rules

- **Main agent writing design docs**: Spawn a sub-agent to run `design-doc-render`. This keeps your main context window lean and focused on requirements and decisions.
- **Explicit invocation or sub-agent**: If the user explicitly asks for `design-doc-render`, or if you are already running as a sub-agent spawned by `design-doc`, perform the rendering directly. Do not spawn another nested sub-agent.

## Workflow

1. **Read source design doc**: Read the target Markdown file (default: latest `docs/design/*.md` or specified path).
2. **Structure content**:
   - **Hero section**: Title, status badge (`draft`, `grilled`, `reviewed`, `implemented`), date, author/slug.
   - **Executive summary**: Problem statement, bulleted goals, and explicit non-goals.
   - **Schemas & diagrams**: Simple yet complete Mermaid diagrams for end-to-end data flow, system architecture, sequence interactions, or state transitions.
   - **Locked decisions**: Visual grid/cards of decisions with rationale and rejected alternatives.
   - **Fact base**: Code citations (`file:line`) with brief descriptions.
   - **Implementation roadmap**: Visual phase breakdown with deliverable checklist and verification criteria.
   - **Open questions & risks**: Concise callout boxes.
3. **Generate self-contained HTML**:
   - Target location: `<tmpdir>/design-doc-<slug>-<timestamp>.html` (use `$TMPDIR` or `/tmp`).
   - Use Tailwind CSS via CDN (`https://cdn.tailwindcss.com`).
   - Use Mermaid via CDN (`https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js`) with `mermaid.initialize({ startOnLoad: true, theme: 'neutral' })`.
   - Dark/light mode compatible, modern font stack, clean spacing, high contrast.
   - Self-contained: No local server or build tools required.
4. **Open and report**:
   - Open in browser: `open <path>` (macOS), `xdg-open <path>` (Linux), or `start <path>` (Windows).
   - Return the absolute path in the tool response.

## HTML Template Blueprint

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Design Doc: ${TITLE}</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
  <script>
    mermaid.initialize({ startOnLoad: true, theme: 'default', securityLevel: 'loose' });
  </script>
</head>
<body class="bg-slate-50 text-slate-900 antialiased min-h-screen py-10 px-4 sm:px-8 max-w-5xl mx-auto">
  <!-- Header -->
  <header class="mb-8 border-b pb-6 border-slate-200">
    <div class="flex items-center justify-between gap-4 mb-2">
      <h1 class="text-3xl font-bold tracking-tight text-slate-900">${TITLE}</h1>
      <span class="px-3 py-1 rounded-full text-xs font-semibold uppercase tracking-wider bg-blue-100 text-blue-800">${STATUS}</span>
    </div>
    <div class="text-sm text-slate-500 flex gap-4">
      <span>Date: ${DATE}</span>
      <span>Doc: <code>${FILE_PATH}</code></span>
    </div>
  </header>

  <!-- Problem & Scope -->
  <section class="grid md:grid-cols-2 gap-6 mb-8">
    <div class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
      <h2 class="text-lg font-semibold text-slate-800 mb-3">Problem & Context</h2>
      <p class="text-slate-600 text-sm leading-relaxed">${PROBLEM_TEXT}</p>
    </div>
    <div class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
      <h2 class="text-lg font-semibold text-slate-800 mb-3">Scope</h2>
      <div class="mb-3">
        <span class="text-xs font-semibold text-emerald-700 uppercase tracking-wider">Goals:</span>
        <ul class="list-disc list-inside text-xs text-slate-600 mt-1 space-y-1">
          <!-- Goals items -->
        </ul>
      </div>
      <div>
        <span class="text-xs font-semibold text-rose-700 uppercase tracking-wider">Non-Goals:</span>
        <ul class="list-disc list-inside text-xs text-slate-600 mt-1 space-y-1">
          <!-- Non-goals items -->
        </ul>
      </div>
    </div>
  </section>

  <!-- Architecture Schemas -->
  <section class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm mb-8">
    <h2 class="text-xl font-semibold text-slate-800 mb-4">Architecture & Data Flow</h2>
    <div class="mermaid flex justify-center py-4 overflow-x-auto">
      ${MERMAID_DIAGRAM}
    </div>
  </section>

  <!-- Locked Decisions -->
  <section class="mb-8">
    <h2 class="text-xl font-semibold text-slate-800 mb-4">Locked Decisions</h2>
    <div class="grid md:grid-cols-2 gap-4">
      <!-- Repeatable decision cards -->
      <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
        <div class="flex items-center gap-2 mb-2">
          <span class="w-6 h-6 rounded-full bg-slate-900 text-white text-xs flex items-center justify-center font-bold">1</span>
          <h3 class="font-medium text-slate-900">${DECISION_TITLE}</h3>
        </div>
        <p class="text-xs text-slate-600 mb-2"><strong>Decision:</strong> ${DECISION_TEXT}</p>
        <p class="text-xs text-slate-500 mb-1"><strong>Rationale:</strong> ${RATIONALE}</p>
        <p class="text-xs text-slate-400"><strong>Rejected alternative:</strong> ${REJECTED}</p>
      </div>
    </div>
  </section>

  <!-- Implementation Roadmap -->
  <section class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm mb-8">
    <h2 class="text-xl font-semibold text-slate-800 mb-4">Implementation Roadmap</h2>
    <div class="space-y-4">
      <!-- Roadmap phases -->
    </div>
  </section>
</body>
</html>
```

## Review Guidelines

- Diagrams must be clear, complete, and accurately reflect code facts.
- Include all non-goals and constraints.
- Make the rendered page self-sufficient so any engineer can review the entire proposal without checking external tabs.
